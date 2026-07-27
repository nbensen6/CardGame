## Authoritative co-op host (CLAUDE.md §2, §6, §7 build step 3). Owns the ONLY
## real game state (a /core Combat), maps each connected peer to a player slot,
## validates every command against the rules, and broadcasts per-player snapshots.
## Clients never mutate state — they ask; the host decides.
##
## Snapshot split (THE core idea, §2):
##   shared  — the board everyone sees: boss (+ who it targets), BOTH players'
##             public status, round, log.
##   private — only the recipient's own hand (never sent to anyone else).
## Each snapshot also carries `you` = the recipient's player slot, so a client
## knows which player on the shared board is itself (and who the ally is).
class_name GameHost
extends RefCounted

const PLAYER_HP := 42
const BOSS_ID := "gatekeeper"

var _transport: Transport
var _combat: Combat
var _seed: int
var _required: int
var _slot_of: Dictionary = {}  # peer_id -> player slot
var _peers: Array = []         # peer_ids in join order (slot = position)

func _init(transport: Transport, seed_value: int = 0, required_players: int = 2) -> void:
	_transport = transport
	_seed = seed_value
	_required = required_players
	_transport.command_received.connect(_on_command)

func start_new_combat() -> void:
	var decks: Array = []
	var combatants: Array = []
	for i in range(_peers.size()):
		decks.append(Content.build_starter_deck())           # each player, own deck
		combatants.append(Combatant.new(_player_name(i), PLAYER_HP))
	_combat = Combat.new(decks, combatants, Content.build_boss(BOSS_ID), _seed)
	_combat.start()
	_broadcast_state()

# --- Command handling (client -> host) ------------------------------------

func _on_command(peer_id: int, command: Dictionary) -> void:
	match String(command.get("type", "")):
		"join":
			_handle_join(peer_id)
		"play_card":
			var pi := _slot(peer_id)
			if _combat != null and pi >= 0:
				_combat.play_card(pi, int(command.get("index", -1)))
			_broadcast_state()
		"end_turn":
			var pi2 := _slot(peer_id)
			if _combat != null and pi2 >= 0:
				_combat.end_turn(pi2)
			_broadcast_state()
		"restart":
			if _combat != null:
				start_new_combat()
		_:
			push_warning("GameHost: unknown command '%s'" % command.get("type", ""))

func _handle_join(peer_id: int) -> void:
	if not _slot_of.has(peer_id) and _peers.size() < _required:
		_slot_of[peer_id] = _peers.size()
		_peers.append(peer_id)
	if _combat == null and _peers.size() >= _required:
		start_new_combat()
	else:
		_broadcast_state()

# --- Snapshots (host -> clients) ------------------------------------------

func _broadcast_state() -> void:
	if _combat == null:
		# Lobby: still waiting for players to join.
		for pid in _peers:
			_transport.broadcast({
				"type": "snapshot", "for_peer": pid, "you": _slot(pid),
				"shared": {"waiting": true, "joined": _peers.size(), "required": _required},
				"private": {},
			})
		return
	var shared := _build_shared()
	for pid in _peers:
		var pi := _slot(pid)
		_transport.broadcast({
			"type": "snapshot", "for_peer": pid, "you": pi,
			"shared": shared, "private": _build_private(pi),
		})

func _build_shared() -> Dictionary:
	var players_pub: Array = []
	for ps in _combat.players:
		players_pub.append({
			"name": ps.combatant.name, "hp": ps.combatant.hp, "max_hp": ps.combatant.max_hp,
			"block": ps.combatant.block, "energy": ps.energy, "ended": ps.ended_turn,
		})
	var b := _combat.boss
	return {
		"waiting": false,
		"boss": {
			"name": b.name, "hp": b.hp, "max_hp": b.max_hp, "block": b.block,
			"intent": b.current_move(), "target": _combat.boss_target_index(),
		},
		"players": players_pub,
		"round": _combat.round_num,
		"base_energy": Combat.BASE_ENERGY,
		"log": _combat.log.slice(maxi(_combat.log.size() - 7, 0)),
		"over": _combat.is_over(),
		"result": _result_string(),
	}

func _build_private(pi: int) -> Dictionary:
	var ps: PlayerState = _combat.players[pi]
	var cards: Array = []
	for i in range(ps.hand.size()):
		var c: Card = ps.hand[i]
		cards.append({
			"index": i, "name": c.name, "cost": c.cost, "target": c.target,
			"text": c.text, "playable": _combat.can_play(pi, i),
		})
	return {"hand": cards, "energy": ps.energy, "ended": ps.ended_turn}

func _slot(peer_id: int) -> int:
	return int(_slot_of.get(peer_id, -1))

func _player_name(slot: int) -> String:
	return "Player %d" % (slot + 1)

func _result_string() -> String:
	match _combat.result():
		Combat.Result.WIN:
			return "win"
		Combat.Result.LOSE:
			return "lose"
		_:
			return "ongoing"
