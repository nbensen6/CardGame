## The boss — a Combatant with a telegraphed, repeating move pattern.
##
## Intent is always visible to the player (no hover — CLAUDE.md §5): the view
## reads current_move() and shows what the boss will do next. The pattern loops.
##
## A move is a Dictionary: { "type": "attack"|"block", "value": int }.
class_name Boss
extends Combatant

var id: String = ""            # the data key — the view needs a STABLE identity,
                               # since art paths are shared between beasts
var moves: Array = []
var art: String = ""           # path to the beast's silhouette (shown in the combat view)
var vulnerable: int = 0        # "exposed" stacks — each consumed hit deals bonus damage
var strength: int = 0          # added to every attack (grows via "enrage" moves)
var wound: int = 0             # bleed — the Titan takes this much at the start of each of its turns
var weak_point_height: int = 0 # 0 = low sigil (always reachable); >0 needs Foothold to strike (SotC climb)
var ledges: Array = []         # safe rest Heights between the base and the sigil (SotC holds)
var weak_point_threshold: int = 0  # sigil damage a hunter can deal per visit before it bucks them off (0 = no limit)
var limiter: Dictionary = {}   # {"type": ..., "value": ...} — a rule this Titan bends against a
                                # specific strategy, applied generically by Combat._apply_limiter()
                                # (design/sts2-comparison.md §3.4). {} = none.
var _move_index: int = 0

## The move the boss will perform on its next enemy turn (telegraphed now).
func current_move() -> Dictionary:
	if moves.is_empty():
		return {"type": "attack", "value": 0}
	return moves[_move_index % moves.size()]

## Advance the pattern after the boss acts.
func advance_move() -> void:
	_move_index += 1
