## A card — pure data (CLAUDE.md §11: cards are data, not hard-coded logic).
##
## /core has NO rendering/input/net deps. Cards are immutable during combat:
## the same instance may appear many times in a deck, so never mutate one.
class_name Card
extends RefCounted

var id: String
var name: String
var type: String  # "attack" | "skill"
var cost: int     # energy to play
var damage: int   # dealt to the boss
var block: int    # gained by the player
var draw: int     # extra cards drawn
var text: String  # rules text, shown on the card face (no hover needed — §5)

static func from_dict(d: Dictionary) -> Card:
	var c := Card.new()
	c.id = String(d.get("id", ""))
	c.name = String(d.get("name", ""))
	c.type = String(d.get("type", "skill"))
	c.cost = int(d.get("cost", 0))
	c.damage = int(d.get("damage", 0))
	c.block = int(d.get("block", 0))
	c.draw = int(d.get("draw", 0))
	c.text = String(d.get("text", ""))
	return c
