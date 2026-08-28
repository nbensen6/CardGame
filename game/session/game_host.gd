## Authoritative co-op host (CLAUDE.md §2, §6, §7). Owns the ONLY real game state
## (a /core Run of Titan encounters), maps each peer to a hunter slot, validates
## every command against the rules, and sends per-hunter snapshots. Clients never
## mutate state — they ask; the host decides.
##
## Snapshot split (THE core idea, §2):
##   shared  — what everyone sees: run phase/encounter, the Titan (+ who it
##             targets), both hunters' public status, round, log.
##   private — only the recipient's own hand (or, in REWARD, their card choices).
## Each snapshot carries `you` = the recipient's hunter slot.
class_name GameHost
extends RefCounted

var _transport: Transport
var _run: Run
var _seed: int
var _required: int
var _slot_of: Dictionary = {}  # peer_id -> hunter slot
var _peers: Array = []         # peer_ids in join order (slot = position)
var paused: bool = false       # a hunter dropped mid-run; play is halted
var _disconnected_slot: int = -1
var _character_of: Dictionary = {}  # peer_id -> chosen character id (lobby select)
# Solo: one player controls BOTH hunters. required=1; both characters picked by
# the one peer; commands carry an explicit "slot".
var _solo: bool = false
var _solo_chars: Array = ["", ""]
var _ascension: int = 0  # difficulty tier chosen at the menu
var _unlocked_wins: int = Content.UNLOCKED_ALL  # career-total gate on locked content (backlog #42)
var _daily_date: String = ""  # set => start_new_run() rolls a shared daily (backlog #49)
var _history_recorded: bool = false  # this run's ending has been logged (backlog #65)

func _init(transport: Transport, seed_value: int = 0, required_players: int = 2, solo: bool = false,
		ascension: int = 0, unlocked_wins: int = Content.UNLOCKED_ALL, daily_date: String = "") -> void:
	_ascension = ascension
	_unlocked_wins = unlocked_wins
	_transport = transport
	_seed = seed_value
	_solo = solo
	_required = 1 if solo else required_players
	_daily_date = daily_date
	_transport.command_received.connect(_on_command)
	_transport.peer_left.connect(_on_peer_left)

## Resume a saved run instead of rolling a new one. The lobby's character select
## is skipped entirely — the hunters were chosen when the run began, and their
## decks have been played with since.
func resume_run(saved: Run) -> void:
	_run = saved
	_history_recorded = false
	_ascension = saved.ascension
	_unlocked_wins = saved.unlocked_wins()
	# A save now captures an in-progress fight too (backlog #14 — Combat has its
	# own to_dict/from_dict), so a resumed run can land back inside COMBAT rather
	# than always bouncing to the map. Defensive fallback for the
	# should-never-happen case of a COMBAT-phase save with no combat in it.
	if _run.phase == Run.Phase.COMBAT and _run.combat == null:
		_run.phase = Run.Phase.MAP
	_broadcast_state()


func start_new_run() -> void:
	var char_ids := _solo_chars if _solo else _co_op_char_ids()
	var decks: Array = []
	var names: Array = []
	var passives: Array = []
	for cid_v in char_ids:
		var cid := String(cid_v)
		decks.append(Content.character_deck(cid))
		names.append(Content.character_name(cid))
		passives.append(Content.character_passive(cid))
	if _daily_date != "":
		_run = Run.new_daily(decks, names, _daily_date, passives, _unlocked_wins)
	else:
		_run = Run.new(decks, names, _seed, passives, _ascension, _unlocked_wins)
	_history_recorded = false
	_run.start()
	_broadcast_state()

# --- Command handling (client -> host) ------------------------------------

func _on_command(peer_id: int, command: Dictionary) -> void:
	match String(command.get("type", "")):
		"join":
			_handle_join(peer_id)
		"select_character":
			if _run == null:
				if _solo:
					_solo_chars[clampi(int(command.get("slot", 0)), 0, 1)] = String(command.get("character", ""))
				else:
					_character_of[peer_id] = String(command.get("character", ""))
			_try_start_or_broadcast()
		"play_card":
			var ps0 := _acting_slot(peer_id, command)
			_in_combat_action(ps0, func() -> void:
				_run.combat.play_card(ps0, int(command.get("index", -1)), bool(command.get("timing", true)),
					int(command.get("sac", -1)), int(command.get("target", -1)), -1,
					int(command.get("quality", Combat.TIMING_PERFECT)), int(command.get("enemy", -1))))
		"end_turn":
			var ps1 := _acting_slot(peer_id, command)
			_in_combat_action(ps1, func() -> void:
				_run.combat.end_turn(ps1))
		"fall":  # the client's real-time grip timer ran out while climbing
			var psf := _acting_slot(peer_id, command)
			_in_combat_action(psf, func() -> void:
				_run.combat.fall(psf))
		"use_potion":  # backlog #26/#45 -- mid-fight only, same reason Run.use_potion() gates it
			var up := _acting_slot(peer_id, command)
			_in_combat_action(up, func() -> void:
				_run.use_potion(up, int(command.get("index", -1))))
		"resolve_scry":  # backlog #59 -- which of the revealed top cards to bin
			var sc := _acting_slot(peer_id, command)
			_in_combat_action(sc, func() -> void:
				_run.combat.resolve_scry(sc, command.get("bin", [])))
		"discard_potion":  # legal any phase you're carrying one -- not gated on combat
			var dp := _acting_slot(peer_id, command)
			if not paused and _run != null and dp >= 0:
				_run.discard_potion(dp, int(command.get("index", -1)))
			_broadcast_state()
		"pick_node":  # the route is a shared choice — any hunter may step
			if not paused and _run != null:
				_run.pick_node(int(command.get("col", -1)))
			_broadcast_state()
		"pick_event":  # events are a shared choice, like the route
			if not paused and _run != null:
				_run.pick_event(int(command.get("choice", -1)))
			_broadcast_state()
		"campfire":
			var cs := _acting_slot(peer_id, command)
			if not paused and _run != null and cs >= 0:
				_run.campfire_action(cs, String(command.get("action", "")), int(command.get("index", -1)))
			_broadcast_state()
		"skip_reward":
			var sk := _acting_slot(peer_id, command)
			if not paused and _run != null and sk >= 0:
				_run.skip_reward(sk)
			_broadcast_state()
		"buy":
			if not paused and _run != null:
				_run.buy(int(command.get("index", -1)), int(command.get("card_index", -1)))
			_broadcast_state()
		"leave_shop":
			if not paused and _run != null:
				_run.leave_shop()
			_broadcast_state()
		"pick_card":
			var pslot := _acting_slot(peer_id, command)
			if not paused and _run != null and pslot >= 0:
				_run.pick_reward(pslot, int(command.get("choice", -1)))
			_broadcast_state()
		"restart":
			if _run != null:
				start_new_run()
		_:
			push_warning("GameHost: unknown command '%s'" % command.get("type", ""))

func _in_combat_action(pi: int, action: Callable) -> void:
	if not paused and _run != null and _run.phase == Run.Phase.COMBAT and pi >= 0 and pi < _run.player_count():
		action.call()
		_run.sync()
	_broadcast_state()

## Persist the run every time the state settles, which is the honest definition
## of "a safe point": the host has just finished resolving something — a card
## played, a turn ended, mid-fight included since RunSave now covers Combat
## (backlog #14). Finishing the run clears the slot — a dead or won run must
## not offer to be continued.
func _autosave() -> void:
	if _run == null or not _solo:
		return  # co-op resume needs a rendezvous, not a file (see RunSave)
	if _run.is_over():
		RunSave.clear()
		return
	RunSave.save(_run)


## Which hunter slot a command acts on: in solo the peer names it; in co-op it's
## the peer's own slot.
func _acting_slot(peer_id: int, command: Dictionary) -> int:
	if _solo:
		return int(command.get("slot", -1))
	return _slot(peer_id)

func _co_op_char_ids() -> Array:
	var ids: Array = []
	for pid in _peers:
		ids.append(String(_character_of.get(pid, "frog")))
	return ids

## A hunter dropped. In the lobby we free their slot; mid-run we pause.
func _on_peer_left(peer_id: int) -> void:
	if not _slot_of.has(peer_id):
		return
	if _run == null:
		_peers.erase(peer_id)
		_slot_of.erase(peer_id)
		_reindex_slots()
	else:
		paused = true
		_disconnected_slot = _slot(peer_id)
	_broadcast_state()

func _reindex_slots() -> void:
	_slot_of.clear()
	for i in range(_peers.size()):
		_slot_of[_peers[i]] = i

func _handle_join(peer_id: int) -> void:
	if _slot_of.has(peer_id):
		# A rejoin that happens to land on its OLD peer id (unusual for ENet,
		# which hands out a fresh one, but the local loopback transport used in
		# tests can) still needs to clear the pause -- otherwise it sits
		# "known" but frozen forever.
		if paused and _slot(peer_id) == _disconnected_slot:
			paused = false
			_disconnected_slot = -1
		_try_start_or_broadcast()
		return
	# backlog #51: a hunter dropped mid-run leaves their slot held (_on_peer_left
	# does not erase it) so the NEXT unrecognised "join" -- a fresh ENet
	# connection, since a rejoin always gets a new peer id -- reclaims that
	# slot instead of being turned away for the party already being full.
	if paused and _disconnected_slot >= 0:
		_reclaim_slot(peer_id, _disconnected_slot)
		return
	if _peers.size() < _required:
		_slot_of[peer_id] = _peers.size()
		_peers.append(peer_id)
	_try_start_or_broadcast()

## Hand a rejoining peer the slot its predecessor held and resume play. The
## dropped connection's own id is forgotten -- it can never come back to life,
## and holding onto it would just be a stale key nothing looks up again.
func _reclaim_slot(peer_id: int, slot: int) -> void:
	var old_peer_id: int = _peers[slot]
	_slot_of.erase(old_peer_id)
	_peers[slot] = peer_id
	_slot_of[peer_id] = slot
	paused = false
	_disconnected_slot = -1
	_broadcast_state()

## Start the run once everyone has joined AND chosen a character; else broadcast.
func _try_start_or_broadcast() -> void:
	if _run == null and _peers.size() >= _required and _all_selected():
		start_new_run()
	else:
		_broadcast_state()

func _all_selected() -> bool:
	if _solo:
		return _solo_chars[0] != "" and _solo_chars[1] != ""
	for pid in _peers:
		if not _character_of.has(pid):
			return false
	return true

# --- Snapshots (host -> clients) ------------------------------------------

func _broadcast_state() -> void:
	_autosave()
	if _run == null:
		# Lobby: character select. Solo picks both hunters; co-op one each.
		for pid in _peers:
			var sh := {"waiting": true, "phase": "select", "solo": _solo,
				"joined": _peers.size(), "required": _required}
			var pv := {"characters": Content.list_characters()}
			if _solo:
				sh["selections"] = _solo_selections()
				sh["current_slot"] = _first_unpicked_solo()
			else:
				sh["selections"] = _selections()
				pv["selected"] = String(_character_of.get(pid, ""))
			_transport.send_to(pid, {"type": "snapshot", "for_peer": pid, "you": _slot(pid),
				"shared": sh, "private": pv})
		return
	_note_progress()
	var shared := _build_shared()
	for pid in _peers:
		var pi := _slot(pid)
		_transport.send_to(pid, {
			"type": "snapshot", "for_peer": pid, "you": pi,
			"shared": shared, "private": _build_private(pi),
		})

func _build_shared() -> Dictionary:
	var s := {
		"waiting": false,
		"phase": _phase_string(),
		"encounter": _run.encounter_index + 1,
		"total_encounters": _run.total_encounters(),
		# Which kind of node is being resolved. The reward screen needs it: a
		# treasure cache opens the same REWARD phase a felled Titan does, and
		# announcing "Titan felled!" over a chest is a lie about what just
		# happened (Nick, 2026-08-16).
		"node_type": _run.node_type,
		"over": _run.is_over(),
		"result": _result_string(),
		"players": _players_public(),
		"relics": _relic_names(),
		"paused": paused,
		"disconnected_slot": _disconnected_slot,
		"solo": _solo,
		"ascension": _ascension,
		"gold": _run.gold,
		# Relic effects the CLIENT owns (the grip timer and timing windows are
		# client-side skill, so their relics have to travel in the snapshot).
		"mods": _run.relic_totals(),
		# Readable so it can be shown and shared (backlog #38) — a bug report or
		# a race between two co-op groups needs a number a player can type back in.
		"seed": _run.seed_value(),
		"is_daily": _run.is_daily,
	}
	if _run.phase == Run.Phase.MAP and _run.map != null:
		s["map"] = {
			"rows": _run.map.rows, "row": _run.map_row, "col": _run.map_col,
			"available": _run.available_nodes(),
			"boss_art": _boss_art_per_act(),
		}
	# the reward screen is staged over the beast you just felled, so the view
	# needs to know which one it was — combat is gone by every other measure
	if _run.phase == Run.Phase.REWARD and _run.combat != null and _run.combat.boss != null:
		s["felled"] = _run.combat.boss.id
	if _run.phase == Run.Phase.EVENT:
		s["event"] = _run.event
	if _run.phase == Run.Phase.SHOP:
		s["shop"] = {"stock": _run.shop_stock, "min_deck": Run.MIN_DECK}
	if _run.phase == Run.Phase.CAMPFIRE:
		s["campfire"] = {"done": _run.campfire_done, "min_deck": Run.MIN_DECK,
			"heal": Run.REST_HEAL}
	if _run.phase == Run.Phase.COMBAT:
		var c: Combat = _run.combat
		var b: Boss = c.boss
		# backlog #63: secondary "adds" alongside the boss, if this beast has
		# any — public the same way the rest of the boss dict already is
		# (there's nothing PRIVATE about an enemy combatant).
		var add_views: Array = []
		for add_v in c.adds:
			var av: Boss = add_v
			add_views.append({"id": av.id, "name": av.name, "hp": av.hp,
				"max_hp": av.max_hp, "block": av.block, "art": av.art})
		s["boss"] = {
			"id": b.id, "name": b.name, "hp": b.hp, "max_hp": b.max_hp, "block": b.block,
			"intent": b.current_move(c.boss_context()), "target": c.boss_target_index(),
			"vulnerable": b.vulnerable, "strength": b.strength, "wound": b.wound,
			# backlog Later (found auditing #54): Frail/Artifact/Thorns are real
			# Combatant fields the boss computes correctly but never forwarded to
			# the board — a Titan you've Frailed showed nothing to look at.
			"frail": b.frail, "artifact": b.artifact, "thorns": b.thorns,
			# Same gap for Dexterity/Intangible/Buffer/Plated Armour (#60/#61):
			# nothing grants the boss any of these yet, so this side forwards
			# zeroes for now, but the hunter side below is live and the two
			# should stay symmetric.
			"dexterity": b.dexterity, "intangible": b.intangible,
			"buffer": b.buffer, "plated_armour": b.plated_armour,
			"weak_point_height": b.weak_point_height, "foothold_max": Combat.FOOTHOLD_MAX,
			"ledges": b.ledges, "weak_point_threshold": b.weak_point_threshold,
			"art": b.art, "adds": add_views,
		}
		s["round"] = c.round_num
		s["base_energy"] = Combat.BASE_ENERGY
		s["log"] = c.log.slice(maxi(c.log.size() - 18, 0))  # enough for the expanded log view
	return s

## Each act's Titan portrait, so the route can show what it's building toward.
func _boss_art_per_act() -> Array:
	var out: Array = []
	for id in Run.ENCOUNTERS:
		out.append(Content.build_boss(String(id)).art)
	return out

## A hunter's held potions, public (backlog #45 -- see _players_public()).
func _potion_view(pi: int) -> Array:
	var out: Array = []
	if pi < 0 or pi >= _run.potions.size():
		return out
	for i in range(_run.potions[pi].size()):
		var p: Dictionary = _run.potions[pi][i]
		out.append({"index": i, "name": String(p.get("name", "")), "text": String(p.get("text", ""))})
	return out

## A hunter's active powers, public (backlog #57 — same reasoning as potions in
## _potion_view: a played power is a standing board fact, not a secret hand
## card, so the ally should see it too). Looks the id up fresh each time
## (Content.make_card is cached) rather than storing name/text on PlayerState,
## the same "one generic rule" trick _handle_power_effects uses to apply it.
func _powers_view(pi: int) -> Array:
	var out: Array = []
	if _run.phase != Run.Phase.COMBAT or pi < 0 or pi >= _run.combat.players.size():
		return out
	var ps: PlayerState = _run.combat.players[pi]
	for id in ps.powers.keys():
		var entry: Dictionary = ps.powers[id]
		var stacks: int = int(entry.get("stacks", 0))
		if stacks <= 0:
			continue
		var pc := Content.make_card(String(id))
		out.append({"id": String(id), "name": pc.name, "text": pc.text, "stacks": stacks})
	return out

## The cards a hunter is currently deciding whether to bin, public (backlog
## #59: "scrying tells your ally what is coming" is the whole co-op reason for
## the mechanic, so it rides the same public-board reasoning as potions/powers
## rather than the private hand). Empty outside a pending scry.
func _scry_view(pi: int) -> Array:
	var out: Array = []
	if _run.phase != Run.Phase.COMBAT or pi < 0 or pi >= _run.combat.players.size():
		return out
	var ps: PlayerState = _run.combat.players[pi]
	for i in range(ps.scry_pending.size()):
		var c: Card = ps.scry_pending[i]
		out.append({"index": i, "name": c.name, "text": c.text})
	return out

func _players_public() -> Array:
	var out: Array = []
	if _run.phase == Run.Phase.COMBAT:
		var c: Combat = _run.combat
		for i in range(c.players.size()):
			var ps: PlayerState = c.players[i]
			out.append({
				"name": Content.character_name(ps.character), "hp": ps.combatant.hp,
				"portrait": Content.character_portrait(ps.character),
				# The id, so the view picks a model by CHARACTER rather than by
				# parsing a portrait filename (that guess already misfired for beasts).
				"character": ps.character,
				"max_hp": ps.combatant.max_hp, "block": ps.combatant.block, "energy": ps.energy,
				"ended": ps.ended_turn, "strength": ps.strength, "rhythm": ps.rhythm,
				# Same gap as the boss dict above, mirrored: a hunter carrying
				# Thorns, warded by Artifact, or Frailed by a beast's own "frail"
				# move showed nothing (backlog Later, found auditing #54).
				"frail": ps.combatant.frail, "artifact": ps.combatant.artifact,
				"thorns": ps.combatant.thorns,
				# Dexterity/Intangible/Buffer/Plated Armour (#60/#61) are the same
				# kind of gap: real Combatant fields cards already grant a hunter,
				# never forwarded, so an ally couldn't see a teammate's own banked
				# Dexterity or defensive stacks.
				"dexterity": ps.combatant.dexterity, "intangible": ps.combatant.intangible,
				"buffer": ps.combatant.buffer, "plated_armour": ps.combatant.plated_armour,
				# The Lightbearer's own resource (backlog #47) is the same kind of
				# gap again: PlayerState.light is a real, banked value cards already
				# read and spend, but nothing ever put it on the wire — not even for
				# the OWNING player's own client, since it was also absent from
				# _slot_private()'s combat dict. #78's HUD (needs a screen) has
				# nothing to read until this lands.
				"light": ps.light,
				"foothold": ps.foothold, "reached": c.sigil_reached(i),
				"secure": c.is_secure(i), "next_safe": c.next_safe_height(i),
				"wp_damage": ps.weak_point_damage,
				"weak_point_height": c.boss.weak_point_height,
					"incoming": c.incoming_for(i),  # {raw, through} — survivability at a glance
				# Potions aren't secret (backlog #45): a teammate can see what you're
				# holding, same as they see your HP -- only USING one is yours alone,
				# enforced by _acting_slot ignoring a co-op peer's claimed slot.
				"potions": _potion_view(i),
				"powers": _powers_view(i),
				"scry_pending": _scry_view(i),
			})
	else:
		for i in range(_run.player_count()):
			out.append({
				"name": _run.names[i], "hp": _run.hp[i], "max_hp": _run.max_hp[i],
				"portrait": Content.character_portrait(_slot_char(i)),
				# Same reason combat sends it: the view picks a model by CHARACTER.
				# Without this the campfire and the shop fell back to guessing from
				# the portrait filename, and "sloth"/"goat"/"monkey" are not model
				# keys — so every hunter but the Frog rendered as the Frog's bunny,
				# and you met yourself twice at every campfire (Nick, 2026-08-16).
				"character": _slot_char(i),
				"picked": _run.phase == Run.Phase.REWARD and bool(_run.reward_picked[i]),
				"potions": _potion_view(i),
			})
	return out

func _build_private(pi: int) -> Dictionary:
	if pi < 0 or _run == null:
		return {}
	# Solo controls both hunters, so send both slots' private data.
	if _solo:
		return {"solo": true, "slots": [_slot_private(0), _slot_private(1)]}
	return _slot_private(pi)

func _slot_private(pi: int) -> Dictionary:
	if _run.phase == Run.Phase.COMBAT:
		var ps: PlayerState = _run.combat.players[pi]
		var cards: Array = []
		for i in range(ps.hand.size()):
			var c: Card = ps.hand[i]
			# LIVE numbers, not the printed ones. The player should never have to
			# compute "3 dmg, +3 per EACH hunter's Height" under a draining grip bar.
			# `miss` is the same card without its timed bonus, so the face can show
			# both outcomes of a timed play. `good` is the THIRD tier graded timing
			# (backlog #33/#45) added — without it a client can only ever preview
			# the PERFECT payout, so a shrinking hit circle has no honest number to
			# show for landing just outside dead-centre.
			var hit: Dictionary = _run.combat.preview(pi, c, true)
			var miss: Dictionary = _run.combat.preview(pi, c, false)
			var good: Dictionary = _run.combat.preview(pi, c, true, Combat.TIMING_GOOD)
			cards.append({
				"index": i, "name": c.name, "cost": _run.combat.effective_cost(pi, c), "target": c.target,
				"text": c.text, "icon": _card_icon(c), "timed": c.timed, "timed_hits": c.timed_hits,
				"exhaust_pick": c.exhaust_pick, "cheapen_pick": c.cheapen_pick, "meld": c.meld,
				"playable": _run.combat.can_play(pi, i),
				"rarity": c.rarity, "keywords": _keywords_of(c),
				"preview": hit, "preview_miss": miss, "preview_good": good,
				# The non-numeric effects, so the face can write ONE sentence
				# instead of printing a formula beside a live readout.
				"fx": {
					"wound": c.wound, "vulnerable": c.vulnerable, "strength": c.strength,
					"draw": c.draw, "taunt": c.taunt, "rhythm": c.rhythm,
					"create": c.create, "prepare": c.prepare, "meld": c.meld,
					"exhaust_pick": c.exhaust_pick, "cheapen_pick": c.cheapen_pick,
					"pull_ally": c.pull_ally, "sac_ally_grip": c.sac_ally_grip,
					"hits": c.hits,
					"power_effect": c.power_effect, "power_value": c.power_value,
				},
				# The card's PRINTED values. The face compares live against these to
				# know which numbers a buff or scaling changed, and highlights only
				# those — that's how a player learns their Strength is doing something.
				"base": {
					"damage": c.damage, "block": c.block, "grip": c.grip,
					"ally_block": c.ally_block, "ally_grip": c.ally_grip,
				},
			})
		return {
			"hand": cards, "energy": ps.energy, "ended": ps.ended_turn,
			# Pile sizes. The Goblin's kit scales off the exhaust pile, which was
			# invisible to the player until now.
			"draw": ps.draw_pile.size(), "discard": ps.discard_pile.size(),
			"exhaust": ps.exhaust_pile.size(),
		}
	if _run.phase == Run.Phase.CAMPFIRE:
		return {"deck": _deck_cards(pi), "done": bool(_run.campfire_done[pi])}
	if _run.phase == Run.Phase.SHOP:
		return {"deck": _deck_cards(pi)}
	if _run.phase == Run.Phase.REWARD:
		var kind := _run.reward_kind
		var choices: Array = []
		for i in range(_run.reward_choices[pi].size()):
			var rc: Variant = _run.reward_choices[pi][i]
			if kind == "relic":
				choices.append({"index": i, "name": rc["name"], "text": rc["text"],
					"icon": "relic", "no_cost": true})
			else:
				# `timed` rides along so the clock badge shows on a card you are
				# choosing, not only on one already in your hand — whether a card
				# needs a timing window is half of whether you want it.
				choices.append({"index": i, "name": rc.name, "cost": rc.cost, "text": rc.text,
					"target": rc.target, "icon": _card_icon(rc), "timed": rc.timed,
					"timed_hits": rc.timed_hits, "rarity": rc.rarity,
					# So a card you are DECIDING on can be asked about, which is
					# when "what does Poison do" matters most.
					"keywords": _keywords_of(rc)})
		return {"reward": {"kind": kind, "choices": choices, "picked": bool(_run.reward_picked[pi])}}
	return {}


## Which keywords a card touches, derived from its FIELDS rather than declared per
## card — so a new card gets the right tooltips for free and nobody has to remember
## to tag it. Returns [{id, name, text}] for the inspector to render.
func _keywords_of(c: Card) -> Array:
	var ids: Array = []
	if c.timed or c.timed_damage > 0:
		ids.append("timed")
	if c.wound > 0 or c.damage_per_wound > 0:
		ids.append("poison")
	if c.vulnerable > 0 or c.damage_per_vulnerable > 0:
		ids.append("expose")
	if c.rhythm > 0 or c.damage_per_rhythm > 0 or c.grip_per_rhythm > 0:
		ids.append("rhythm")
	if c.strength > 0:
		ids.append("strength")
	if c.dexterity > 0:
		ids.append("dexterity")
	if c.block > 0 or c.ally_block > 0 or c.block_per_play > 0 \
			or c.block_per_exhausted > 0 or c.timed_block > 0 or c.timed_ally_block > 0:
		# "player_block", not "block" — keywords.json's move-vocabulary section
		# (see its own "_comment_moves") uses ids that match a boss move `type`
		# verbatim, and a beast's Defend move is already "block" there. The two
		# collided under one JSON key until backlog's Later-section note caught
		# it: JSON keeps only the last of two duplicate keys, so this card-side
		# lookup was silently resolving to the beast's "the beast guards" text.
		ids.append("player_block")
	if c.grip > 0 or c.ally_grip > 0 or c.timed_grip > 0 or c.pull_ally > 0 \
			or c.sac_ally_grip > 0 or c.damage_per_foothold > 0 or c.damage_per_ally_foothold > 0 \
			or c.targets_hold:
		ids.append("height")
		ids.append("armoured")
	if c.taunt:
		ids.append("taunt")
	if c.exhaust_pick or c.damage_per_exhausted > 0 or c.block_per_exhausted > 0:
		ids.append("burn")
	if c.enchant != "":
		ids.append("enchant")
	if c.ally_energy > 0:
		ids.append("energy")
	if c.create != "":
		ids.append("build")
	if c.prepare != "":
		ids.append("prime")
	if c.cheapen_pick or c.cheapen_amount > 0:
		ids.append("cheapen")
	if c.meld:
		ids.append("meld")
	if c.hits > 1:
		ids.append("multistrike")
	if c.status:
		ids.append("status")
	if c.retain:
		ids.append("retain")
	if c.innate:
		ids.append("innate")
	if c.ethereal:
		ids.append("ethereal")
	if c.cost == -1 or c.damage_per_x > 0 or c.block_per_x > 0:
		ids.append("x_cost")
	if c.frail > 0:
		ids.append("frail")
	if c.thorns > 0:
		ids.append("thorns")
	if c.intangible > 0:
		ids.append("intangible")
	if c.buffer > 0:
		ids.append("buffer")
	if c.plated_armour > 0:
		ids.append("plated_armour")
	if c.light_gain > 0 or c.light_cost > 0 or c.damage_per_light > 0:
		ids.append("light")
	if c.ally_heal > 0:
		ids.append("mend")
	if c.type == "power" or c.power_effect != "" or c.power_value != 0:
		ids.append("power")
	if c.scry > 0:
		ids.append("scry")
	if c.discard > 0 or c.damage_per_discarded > 0 or c.block_per_discarded > 0:
		ids.append("discard")
	if c.hits_all_enemies:
		ids.append("cleave")
	if c.topdeck != "" or c.shuffle_in != "" or c.tutor != "":
		ids.append("reach")
	var out: Array = []
	for id in ids:
		var k := Content.keyword(String(id))
		if not k.is_empty():
			out.append(k)
	return out


## The hunter's persistent deck, as card dicts the view can render.
func _deck_cards(pi: int) -> Array:
	var out: Array = []
	var deck: Array = _run.decks[pi]
	for i in range(deck.size()):
		var c: Card = deck[i]
		out.append({
			"index": i, "name": c.name, "cost": c.cost, "target": c.target,
			"text": c.text, "icon": _card_icon(c), "upgraded": c.upgraded,
			"timed": c.timed, "timed_hits": c.timed_hits, "rarity": c.rarity,
			"keywords": _keywords_of(c),
		})
	return out

func _relic_names() -> Array:
	var out: Array = []
	for r in _run.team_relics:
		out.append(String(r.get("name", "")))
	return out

## Lobby: each hunter's chosen character (name + whether picked), in slot order.
func _selections() -> Array:
	var out: Array = []
	for pid in _peers:
		var cid := String(_character_of.get(pid, ""))
		out.append({"name": Content.character_name(cid) if cid != "" else "", "picked": cid != ""})
	return out

func _solo_selections() -> Array:
	var out: Array = []
	for cid_v in _solo_chars:
		var cid := String(cid_v)
		out.append({"name": Content.character_name(cid) if cid != "" else "", "picked": cid != ""})
	return out

func _first_unpicked_solo() -> int:
	for i in range(_solo_chars.size()):
		if String(_solo_chars[i]) == "":
			return i
	return -1

## A silhouette-icon key for a card, chosen by its dominant effect (view art).
func _card_icon(c: Card) -> String:
	if c.icon != "":
		return c.icon  # explicit override from cards.json
	if c.power_effect != "":  # backlog #57 — infer from the recurring payoff, not a one-off field
		match c.power_effect:
			"block": return "shield"
			"strength", "heal": return "flask"
			"wound": return "skull"
			"vulnerable", "frail": return "expose"
			"thorns": return "shield"
	if c.taunt:
		return "taunt"
	if c.meld or c.create != "":
		return "gadget"
	if c.exhaust_pick:
		return "bomb"  # sacrifice/burn a card
	if c.prepare != "":
		return "climb"  # jetpack — get up the beast
	if c.pull_ally > 0 or c.sac_ally_grip > 0 or c.ally_block > 0 or c.ally_energy > 0:
		return "support"
	if c.grip > 0 or c.ally_grip > 0:
		return "climb"
	if c.ally_heal > 0:
		return "support"
	if c.light_gain > 0 or c.damage_per_light > 0:
		return "flask"
	if c.wound > 0:
		return "skull"
	if c.vulnerable > 0 and c.damage == 0:
		return "expose"
	if c.strength > 0:
		return "flask"
	if c.dexterity > 0:
		return "shield"
	if c.intangible > 0 or c.buffer > 0 or c.plated_armour > 0:
		return "shield"
	if c.draw > 0 or c.scry > 0 or c.discard > 0:
		return "draw"
	if c.damage > 0 or c.damage_per_discarded > 0:
		return "sword"
	if c.block > 0 or c.block_per_play > 0 or c.block_per_discarded > 0:
		return "shield"
	return ""

## The character id chosen for a hunter slot (works in solo and co-op).
func _slot_char(slot: int) -> String:
	if _solo:
		return String(_solo_chars[slot]) if slot < _solo_chars.size() else ""
	if slot < _peers.size():
		return String(_character_of.get(_peers[slot], ""))
	return ""

func _slot(peer_id: int) -> int:
	return int(_slot_of.get(peer_id, -1))

func _player_name(slot: int) -> String:
	return "Hunter %d" % (slot + 1)

func _phase_string() -> String:
	match _run.phase:
		Run.Phase.MAP: return "map"
		Run.Phase.EVENT: return "event"
		Run.Phase.CAMPFIRE: return "campfire"
		Run.Phase.SHOP: return "shop"
		Run.Phase.COMBAT: return "combat"
		Run.Phase.REWARD: return "reward"
		Run.Phase.WON: return "won"
		Run.Phase.LOST: return "lost"
		_: return "combat"

func _note_progress() -> void:
	if _run == null or not _run.is_over() or _history_recorded:
		return
	_history_recorded = true  # broadcasts repeat on a finished run; the log must not
	if _run.phase == Run.Phase.WON:
		Progress.record_win(_ascension)
	Progress.record_run(_run.history_entry())

func _result_string() -> String:
	match _run.phase:
		Run.Phase.WON: return "win"
		Run.Phase.LOST: return "lose"
		_: return "ongoing"
