## The boss — a Combatant with a telegraphed, repeating move pattern.
##
## Intent is always visible to the player (no hover — CLAUDE.md §5): the view
## reads current_move() and shows what the boss will do next. The pattern loops.
##
## A move is a Dictionary: { "type": "attack"|"block", "value": int }.
class_name Boss
extends Combatant

var moves: Array = []
var vulnerable: int = 0  # "exposed" stacks — each consumed hit deals bonus damage
var strength: int = 0    # added to every attack (grows via "enrage" moves)
var _move_index: int = 0

## The move the boss will perform on its next enemy turn (telegraphed now).
func current_move() -> Dictionary:
	if moves.is_empty():
		return {"type": "attack", "value": 0}
	return moves[_move_index % moves.size()]

## Advance the pattern after the boss acts.
func advance_move() -> void:
	_move_index += 1
