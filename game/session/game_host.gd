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

func _init(transport: Transport, seed_value: int = 0, required_players: int = 2) -> void:
	_transport = transport
	_seed = seed_value
	_required = required_players
	_transport.command_received.connect(_on_command)

func start_new_run() -> void:
	var decks: Array = []
	var names: Array = []
	for i in range(_peers.size()):
		decks.append(Content.build_starter_deck())
		names.append(_player_name(i))
	_run = Run.new(decks, names, _seed)
	_run.start()
	_broadcast_state()

# --- Command handling (client -> host) ------------------------------------

func _on_command(peer_id: int, command: Dictionary) -> void:
	match String(command.get("type", "")):
		"join":
			_handle_join(peer_id)
		"play_card":
			_in_combat_action(peer_id, func(pi: int) -> void:
				_run.combat.play_card(pi, int(command.get("index", -1))))
		"end_turn":
			_in_combat_action(peer_id, func(pi: int) -> void:
				_run.combat.end_turn(pi))
		"pick_card":
			var pslot := _slot(peer_id)
			if _run != null and pslot >= 0:
				_run.pick_reward(pslot, int(command.get("choice", -1)))
			_broadcast_state()
		"restart":
			if _run != null:
				start_new_run()
		_:
			push_warning("GameHost: unknown command '%s'" % command.get("type", ""))

func _in_combat_action(peer_id: int, action: Callable) -> void:
	var pi := _slot(peer_id)
	if _run != null and _run.phase == Run.Phase.COMBAT and pi >= 0:
		action.call(pi)
		_run.sync()
	_broadcast_state()

func _handle_join(peer_id: int) -> void:
	if not _slot_of.has(peer_id) and _peers.size() < _required:
		_slot_of[peer_id] = _peers.size()
		_peers.append(peer_id)
	if _run == null and _peers.size() >= _required:
		start_new_run()
	else:
		_broadcast_state()

# --- Snapshots (host -> clients) ------------------------------------------

func _broadcast_state() -> void:
	if _run == null:
		for pid in _peers:
			_transport.send_to(pid, {
				"type": "snapshot", "for_peer": pid, "you": _slot(pid),
				"shared": {"waiting": true, "joined": _peers.size(), "required": _required},
				"private": {},
			})
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
	}
	if _run.phase == Run.Phase.COMBAT:
		var c: Combat = _run.combat
		var b: Boss = c.boss
		s["boss"] = {
			"name": b.name, "hp": b.hp, "max_hp": b.max_hp, "block": b.block,
			"intent": b.current_move(), "target": c.boss_target_index(),
			"vulnerable": b.vulnerable, "strength": b.strength,
			"weak_point_height": b.weak_point_height, "foothold": c.foothold,
			"foothold_max": Combat.FOOTHOLD_MAX, "sigil_reached": c.sigil_reached(),
		}
		s["round"] = c.round_num
		s["base_energy"] = Combat.BASE_ENERGY
		s["log"] = c.log.slice(maxi(c.log.size() - 7, 0))
	return s

func _players_public() -> Array:
	var out: Array = []
	if _run.phase == Run.Phase.COMBAT:
		for ps in _run.combat.players:
			out.append({
				"name": ps.combatant.name, "hp": ps.combatant.hp, "max_hp": ps.combatant.max_hp,
				"block": ps.combatant.block, "energy": ps.energy, "ended": ps.ended_turn,
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
	if _run.phase == Run.Phase.COMBAT:
		var ps: PlayerState = _run.combat.players[pi]
		var cards: Array = []
		for i in range(ps.hand.size()):
			var c: Card = ps.hand[i]
			cards.append({
				"index": i, "name": c.name, "cost": c.cost, "target": c.target,
				"text": c.text, "icon": _card_icon(c), "playable": _run.combat.can_play(pi, i),
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

## A silhouette-icon key for a card, chosen by its dominant effect (view art).
func _card_icon(c: Card) -> String:
	if c.taunt:
		return "taunt"
	if c.grip > 0:
		return "grip"
	if c.vulnerable > 0 and c.damage == 0:
		return "expose"
	if c.damage > 0:
		return "sword"
	if c.ally_block > 0 or c.ally_energy > 0:
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
