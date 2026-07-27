## Authoritative game host (CLAUDE.md §2, §7 build step 2). Owns the ONLY real
## game state (a /core Combat), validates every client command against the rules,
## and broadcasts per-player snapshots. Clients never mutate state — they ask;
## the host decides. This is what makes casting/mobile cheap later: views are
## disposable, the host is the single source of truth.
##
## Layering: /session binds /core (rules) to /net (transport). /core still
## depends on nothing; this host depends on both, one level up.
##
## Snapshot split (THE core idea, §2):
##   shared  — the board everyone sees: boss, turn, log, public player status.
##   private — only this player's hand (never sent to anyone else).
class_name GameHost
extends RefCounted

const PLAYER_HP := 42
const BOSS_ID := "gatekeeper"

var _transport: Transport
var _combat: Combat
var _seed: int
var _peers: Array[int] = []

func _init(transport: Transport, seed_value: int = 0) -> void:
	_transport = transport
	_seed = seed_value
	_transport.command_received.connect(_on_command)

func start_new_combat() -> void:
	var deck := Content.build_starter_deck()
	var player := Combatant.new("You", PLAYER_HP)
	var boss := Content.build_boss(BOSS_ID)
	_combat = Combat.new(deck, player, boss, _seed)
	_combat.start()
	_broadcast_state()

# --- Command handling (client -> host) ------------------------------------

func _on_command(peer_id: int, command: Dictionary) -> void:
	match String(command.get("type", "")):
		"join":
			if peer_id not in _peers:
				_peers.append(peer_id)
			if _combat == null:
				start_new_combat()
			else:
				_broadcast_state()
		"play_card":
			if _combat != null:
				_combat.play_card(int(command.get("index", -1)))
			_broadcast_state()
		"end_turn":
			if _combat != null:
				_combat.end_turn()
			_broadcast_state()
		"restart":
			start_new_combat()
		_:
			push_warning("GameHost: unknown command '%s'" % command.get("type", ""))

# --- Snapshots (host -> clients) ------------------------------------------

func _broadcast_state() -> void:
	if _combat == null:
		return
	var shared := _build_shared()
	for pid in _peers:
		_transport.broadcast({
			"type": "snapshot",
			"for_peer": pid,
			"shared": shared,
			"private": _build_private(pid),
		})

func _build_shared() -> Dictionary:
	var b := _combat.boss
	var p := _combat.player
	return {
		"boss": {
			"name": b.name, "hp": b.hp, "max_hp": b.max_hp,
			"block": b.block, "intent": b.current_move(),
		},
		"player": {"hp": p.hp, "max_hp": p.max_hp, "block": p.block},
		"energy": _combat.energy,
		"base_energy": Combat.BASE_ENERGY,
		"turn": _combat.turn,
		"log": _combat.log.slice(maxi(_combat.log.size() - 6, 0)),
		"over": _combat.is_over(),
		"result": _result_string(),
	}

func _build_private(_peer_id: int) -> Dictionary:
	# Single-player for now: one hand. In co-op (build step 3) each peer maps to
	# its own player/hand — same message shape, per-peer contents.
	var cards: Array = []
	for i in range(_combat.hand.size()):
		var c: Card = _combat.hand[i]
		cards.append({
			"index": i, "name": c.name, "cost": c.cost,
			"text": c.text, "playable": _combat.can_play(i),
		})
	return {"hand": cards}

func _result_string() -> String:
	match _combat.result():
		Combat.Result.WIN:
			return "win"
		Combat.Result.LOSE:
			return "lose"
		_:
			return "ongoing"
