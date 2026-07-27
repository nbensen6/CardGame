## Co-op turn-based combat — the authoritative game rules (CLAUDE.md §6, §7,
## build step 3). Deterministic and unit-testable: NO rendering, input, or net.
## Supports N players (1 for the solo loop, 2 for co-op) vs a shared boss.
##
## Round structure (co-op):
##   Player phase: every player refreshes block/energy and draws a fresh hand,
##                 then plays cards and ends their turn independently. A player
##                 who has ended can't act, but the round continues until ALL
##                 players have ended.
##   Enemy phase:  the boss performs its telegraphed move against its telegraphed
##                 target, then advances its pattern.
##   Repeat until the boss dies (WIN) or ANY player dies (LOSE) — so keeping your
##   ally alive matters, which is what the ally-targeting cards are for (§6).
##
## Determinism: pass a non-zero seed for reproducible shuffles (tests do this).
class_name Combat
extends RefCounted

enum Result { ONGOING, WIN, LOSE }
enum Phase { PLAYERS, ENEMY, OVER }

const HAND_SIZE := 5
const BASE_ENERGY := 3

var players: Array = []  # Array[PlayerState], index = player slot
var boss: Boss
var round_num: int = 1
var phase: int = Phase.PLAYERS
var log: Array = []

var _rng := RandomNumberGenerator.new()

## decks[i] and combatants[i] belong to player i.
func _init(decks: Array, combatants: Array, p_boss: Boss, seed_value: int = 0) -> void:
	boss = p_boss
	if seed_value == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value
	for i in range(combatants.size()):
		var ps := PlayerState.new()
		ps.combatant = combatants[i]
		ps.draw_pile = (decks[i] as Array).duplicate()
		_shuffle(ps.draw_pile)
		players.append(ps)

func start() -> void:
	_begin_round()

# --- Queries --------------------------------------------------------------

func player_count() -> int:
	return players.size()

## The ally a player's ally-targeting cards help. 2-player: the other player.
func ally_index(pi: int) -> int:
	return (pi + 1) % players.size()

## The player the boss's next attack will hit (telegraphed). Rotates by round.
func boss_target_index() -> int:
	return (round_num - 1) % players.size()

func can_play(pi: int, ci: int) -> bool:
	if phase != Phase.PLAYERS:
		return false
	if pi < 0 or pi >= players.size():
		return false
	var ps: PlayerState = players[pi]
	if ps.ended_turn:
		return false
	if ci < 0 or ci >= ps.hand.size():
		return false
	return ps.hand[ci].cost <= ps.energy

func result() -> int:
	if boss.is_dead():
		return Result.WIN
	for ps in players:
		if ps.combatant.is_dead():
			return Result.LOSE
	return Result.ONGOING

func is_over() -> bool:
	return phase == Phase.OVER

# --- Player actions -------------------------------------------------------

## Player pi plays the card at hand index ci. Returns false if it can't.
func play_card(pi: int, ci: int) -> bool:
	if not can_play(pi, ci):
		return false
	var ps: PlayerState = players[pi]
	var card: Card = ps.hand[ci]
	ps.energy -= card.cost
	ps.hand.remove_at(ci)
	ps.discard_pile.append(card)
	var who: String = ps.combatant.name

	if card.damage > 0:
		boss.take_damage(card.damage)
		_log("%s plays %s — %d damage." % [who, card.name, card.damage])
	if card.block > 0:
		ps.combatant.gain_block(card.block)
		_log("%s plays %s — +%d block." % [who, card.name, card.block])
	if card.ally_block > 0:
		var ally: PlayerState = players[ally_index(pi)]
		ally.combatant.gain_block(card.ally_block)
		_log("%s plays %s — +%d block to %s." % [who, card.name, card.ally_block, ally.combatant.name])
	if card.draw > 0:
		_draw(ps, card.draw)
		_log("%s plays %s — draw %d." % [who, card.name, card.draw])

	_check_end()
	return true

## Player pi ends their turn. When every player has ended, the boss acts.
func end_turn(pi: int) -> void:
	if phase != Phase.PLAYERS:
		return
	if pi < 0 or pi >= players.size():
		return
	var ps: PlayerState = players[pi]
	if ps.ended_turn:
		return
	ps.ended_turn = true
	while not ps.hand.is_empty():
		ps.discard_pile.append(ps.hand.pop_back())
	_log("%s ends their turn." % ps.combatant.name)
	if _all_ended():
		_enemy_turn()

# --- Internals ------------------------------------------------------------

func _begin_round() -> void:
	phase = Phase.PLAYERS
	for ps in players:
		ps.combatant.block = 0
		ps.energy = BASE_ENERGY
		ps.ended_turn = false
		_draw(ps, HAND_SIZE)
	_log("— Round %d —" % round_num)

func _all_ended() -> bool:
	for ps in players:
		if not ps.ended_turn:
			return false
	return true

func _enemy_turn() -> void:
	phase = Phase.ENEMY
	if _check_end():
		return
	boss.block = 0
	var move := boss.current_move()
	match String(move.get("type", "")):
		"attack":
			var target: PlayerState = players[boss_target_index()]
			target.combatant.take_damage(int(move.get("value", 0)))
			_log("%s attacks %s for %d." % [boss.name, target.combatant.name, int(move.get("value", 0))])
		"block":
			boss.gain_block(int(move.get("value", 0)))
			_log("%s defends (+%d block)." % [boss.name, int(move.get("value", 0))])
		_:
			_log("%s hesitates." % boss.name)
	boss.advance_move()
	if _check_end():
		return
	round_num += 1
	_begin_round()

func _draw(ps: PlayerState, n: int) -> void:
	for _i in n:
		if ps.draw_pile.is_empty():
			if ps.discard_pile.is_empty():
				return
			ps.draw_pile = ps.discard_pile.duplicate()
			ps.discard_pile.clear()
			_shuffle(ps.draw_pile)
		ps.hand.append(ps.draw_pile.pop_back())

func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp

func _check_end() -> bool:
	if boss.is_dead():
		phase = Phase.OVER
		_log("%s is defeated. Victory!" % boss.name)
		return true
	for ps in players:
		if ps.combatant.is_dead():
			phase = Phase.OVER
			_log("%s has fallen. Defeat." % ps.combatant.name)
			return true
	return false

func _log(msg: String) -> void:
	log.append(msg)
