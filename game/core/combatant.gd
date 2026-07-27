## A combatant in a fight — the player or (via Boss) the enemy.
## Pure state + rules; /core has no rendering/input/net deps.
##
## Block absorbs damage before HP and is reset at the start of that
## combatant's own turn (classic deckbuilder rule — see Combat).
class_name Combatant
extends RefCounted

var name: String
var max_hp: int
var hp: int
var block: int = 0

func _init(p_name: String = "", p_max_hp: int = 1) -> void:
	name = p_name
	max_hp = maxi(p_max_hp, 1)
	hp = max_hp

## Damage hits block first, then HP. HP never goes below 0.
func take_damage(amount: int) -> void:
	var remaining := maxi(amount, 0)
	var absorbed := mini(block, remaining)
	block -= absorbed
	remaining -= absorbed
	hp = maxi(hp - remaining, 0)

func gain_block(amount: int) -> void:
	block += maxi(amount, 0)

func is_dead() -> bool:
	return hp <= 0
