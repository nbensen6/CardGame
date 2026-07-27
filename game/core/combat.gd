## Single-player turn-based combat — the authoritative game rules (CLAUDE.md §7,
## build step 1). Deterministic and unit-testable: NO rendering, input, or net.
##
## Turn structure (classic deckbuilder):
##   Player turn: reset player block, refill energy, draw a fresh hand, play
##                cards until out of energy/cards, then End Turn.
##   Enemy turn:  boss performs its telegraphed move, then advances its pattern.
##   Repeat until the boss dies (WIN) or the player dies (LOSE).
##
## Determinism: pass a non-zero seed for reproducible shuffles (tests do this);
## seed 0 randomizes for real play.
class_name Combat
extends RefCounted

enum Result { ONGOING, WIN, LOSE }
enum Phase { PLAYER, ENEMY, OVER }

const HAND_SIZE := 5
const BASE_ENERGY := 3

var player: Combatant
var boss: Boss
var draw_pile: Array = []
var hand: Array = []
var discard_pile: Array = []
var energy: int = 0
var turn: int = 1
var phase: int = Phase.PLAYER
var log: Array = []

var _rng := RandomNumberGenerator.new()

func _init(deck: Array, p_player: Combatant, p_boss: Boss, seed_value: int = 0) -> void:
	player = p_player
	boss = p_boss
	if seed_value == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value
	draw_pile = deck.duplicate()
	_shuffle(draw_pile)

## Begin the fight (draws the opening hand).
func start() -> void:
	_begin_player_turn()

# --- Player actions -------------------------------------------------------

func can_play(index: int) -> bool:
	if phase != Phase.PLAYER:
		return false
	if index < 0 or index >= hand.size():
		return false
	return hand[index].cost <= energy

## Play the card at hand[index]. Returns false if it can't be played.
func play_card(index: int) -> bool:
	if not can_play(index):
		return false
	var card: Card = hand[index]
	energy -= card.cost
	hand.remove_at(index)
	discard_pile.append(card)

	if card.damage > 0:
		boss.take_damage(card.damage)
		_log("You play %s — %d damage." % [card.name, card.damage])
	if card.block > 0:
		player.gain_block(card.block)
		_log("You play %s — +%d block." % [card.name, card.block])
	if card.draw > 0:
		_draw(card.draw)
		_log("You play %s — draw %d." % [card.name, card.draw])

	_check_end()
	return true

## End the player's turn: discard the hand, then the boss acts.
func end_turn() -> void:
	if phase != Phase.PLAYER:
		return
	while not hand.is_empty():
		discard_pile.append(hand.pop_back())
	_enemy_turn()

# --- State queries --------------------------------------------------------

func result() -> int:
	if boss.is_dead():
		return Result.WIN
	if player.is_dead():
		return Result.LOSE
	return Result.ONGOING

func is_over() -> bool:
	return phase == Phase.OVER

# --- Internals ------------------------------------------------------------

func _begin_player_turn() -> void:
	phase = Phase.PLAYER
	player.block = 0
	energy = BASE_ENERGY
	_draw(HAND_SIZE)
	_log("— Turn %d —" % turn)

func _enemy_turn() -> void:
	phase = Phase.ENEMY
	if _check_end():
		return
	boss.block = 0
	var move := boss.current_move()
	match String(move.get("type", "")):
		"attack":
			player.take_damage(int(move.get("value", 0)))
			_log("%s attacks for %d." % [boss.name, int(move.get("value", 0))])
		"block":
			boss.gain_block(int(move.get("value", 0)))
			_log("%s defends (+%d block)." % [boss.name, int(move.get("value", 0))])
		_:
			_log("%s hesitates." % boss.name)
	boss.advance_move()
	if _check_end():
		return
	turn += 1
	_begin_player_turn()

func _draw(n: int) -> void:
	for _i in n:
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				return  # nothing left to draw
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			_shuffle(draw_pile)
		hand.append(draw_pile.pop_back())

## Seeded Fisher-Yates so shuffles are reproducible from the RNG seed.
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
	if player.is_dead():
		phase = Phase.OVER
		_log("You have fallen. Defeat.")
		return true
	return false

func _log(msg: String) -> void:
	log.append(msg)
