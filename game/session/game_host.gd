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

func _init(transport: Transport, seed_value: int = 0, required_players: int = 2, solo: bool = false) -> void:
	_transport = transport
	_seed = seed_value
	_solo = solo
	_required = 1 if solo else required_players
	_transport.command_received.connect(_on_command)
	_transport.peer_left.connect(_on_peer_left)

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
	_run = Run.new(decks, names, _seed, passives)
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
					int(command.get("sac", -1)), int(command.get("target", -1))))
		"end_turn":
			var ps1 := _acting_slot(peer_id, command)
			_in_combat_action(ps1, func() -> void:
				_run.combat.end_turn(ps1))
		"fall":  # the client's real-time grip timer ran out while climbing
			var psf := _acting_slot(peer_id, command)
			_in_combat_action(psf, func() -> void:
				_run.combat.fall(psf))
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
	if not _slot_of.has(peer_id) and _peers.size() < _required:
		_slot_of[peer_id] = _peers.size()
		_peers.append(peer_id)
	_try_start_or_broadcast()

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
		"over": _run.is_over(),
		"result": _result_string(),
		"players": _players_public(),
		"relics": _relic_names(),
		"paused": paused,
		"disconnected_slot": _disconnected_slot,
		"solo": _solo,
	}
	if _run.phase == Run.Phase.COMBAT:
		var c: Combat = _run.combat
		var b: Boss = c.boss
		s["boss"] = {
			"name": b.name, "hp": b.hp, "max_hp": b.max_hp, "block": b.block,
			"intent": b.current_move(), "target": c.boss_target_index(),
			"vulnerable": b.vulnerable, "strength": b.strength, "wound": b.wound,
			"weak_point_height": b.weak_point_height, "foothold_max": Combat.FOOTHOLD_MAX,
			"ledges": b.ledges, "weak_point_threshold": b.weak_point_threshold,
			"art": b.art,
		}
		s["round"] = c.round_num
		s["base_energy"] = Combat.BASE_ENERGY
		s["log"] = c.log.slice(maxi(c.log.size() - 7, 0))
	return s

func _players_public() -> Array:
	var out: Array = []
	if _run.phase == Run.Phase.COMBAT:
		var c: Combat = _run.combat
		for i in range(c.players.size()):
			var ps: PlayerState = c.players[i]
			out.append({
				"name": Content.character_name(ps.character), "hp": ps.combatant.hp,
				"max_hp": ps.combatant.max_hp, "block": ps.combatant.block, "energy": ps.energy,
				"ended": ps.ended_turn, "strength": ps.strength,
				"foothold": ps.foothold, "reached": c.sigil_reached(i),
				"secure": c.is_secure(i), "next_safe": c.next_safe_height(i),
				"wp_damage": ps.weak_point_damage,
				"weak_point_height": c.boss.weak_point_height,
			})
	else:
		for i in range(_run.player_count()):
			out.append({
				"name": _run.names[i], "hp": _run.hp[i], "max_hp": _run.max_hp[i],
				"picked": _run.phase == Run.Phase.REWARD and bool(_run.reward_picked[i]),
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
			cards.append({
				"index": i, "name": c.name, "cost": _run.combat.effective_cost(pi, c), "target": c.target,
				"text": c.text, "icon": _card_icon(c), "timed": c.timed,
				"exhaust_pick": c.exhaust_pick, "cheapen_pick": c.cheapen_pick,
				"playable": _run.combat.can_play(pi, i),
			})
		return {"hand": cards, "energy": ps.energy, "ended": ps.ended_turn}
	if _run.phase == Run.Phase.REWARD:
		var kind := _run.reward_kind
		var choices: Array = []
		for i in range(_run.reward_choices[pi].size()):
			var rc: Variant = _run.reward_choices[pi][i]
			if kind == "relic":
				choices.append({"index": i, "name": rc["name"], "text": rc["text"],
					"icon": "relic", "no_cost": true})
			else:
				choices.append({"index": i, "name": rc.name, "cost": rc.cost, "text": rc.text,
					"target": rc.target, "icon": _card_icon(rc)})
		return {"reward": {"kind": kind, "choices": choices, "picked": bool(_run.reward_picked[pi])}}
	return {}


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
	if c.taunt:
		return "taunt"
	if c.prepare != "" or c.grip > 0:
		return "grip"
	if c.pull_ally > 0 or c.sac_ally_grip > 0:
		return "support"
	if c.exhaust_pick:
		return "expose"
	if c.vulnerable > 0 and c.damage == 0:
		return "expose"
	if c.damage > 0:
		return "sword"
	if c.ally_block > 0 or c.ally_energy > 0 or c.strength > 0:
		return "support"
	if c.block > 0:
		return "shield"
	if c.draw > 0:
		return "aim"
	return ""

func _slot(peer_id: int) -> int:
	return int(_slot_of.get(peer_id, -1))

func _player_name(slot: int) -> String:
	return "Hunter %d" % (slot + 1)

func _phase_string() -> String:
	match _run.phase:
		Run.Phase.COMBAT: return "combat"
		Run.Phase.REWARD: return "reward"
		Run.Phase.WON: return "won"
		Run.Phase.LOST: return "lost"
		_: return "combat"

func _result_string() -> String:
	match _run.phase:
		Run.Phase.WON: return "win"
		Run.Phase.LOST: return "lose"
		_: return "ongoing"
