## A card — pure data (CLAUDE.md §11: cards are data, not hard-coded logic).
##
## /core has NO rendering/input/net deps. Cards are immutable during combat:
## the same instance may appear many times in a deck, so never mutate one.
class_name Card
extends RefCounted

var id: String
var name: String
var type: String       # "attack" | "skill"
var cost: int          # energy to play
var damage: int        # dealt to the Titan
var block: int         # gained by the player who plays it
var ally_block: int    # gained by the ALLY — a co-op combo effect (CLAUDE.md §6)
var ally_energy: int   # energy given to the ALLY (combo enabler)
var vulnerable: int    # "exposed" stacks added to the Titan (next hits deal bonus)
var taunt: bool        # you become the Titan's target this round (tank for your ally)
var draw: int          # extra cards drawn
var target: String     # "self" | "ally" | "enemy" — who the card acts on (UI clarity)
var text: String       # rules text, shown on the card face (no hover needed — §5)

static func from_dict(d: Dictionary) -> Card:
	var c := Card.new()
	c.id = String(d.get("id", ""))
	c.name = String(d.get("name", ""))
	c.type = String(d.get("type", "skill"))
	c.cost = int(d.get("cost", 0))
	c.damage = int(d.get("damage", 0))
	c.block = int(d.get("block", 0))
	c.ally_block = int(d.get("ally_block", 0))
	c.ally_energy = int(d.get("ally_energy", 0))
	c.vulnerable = int(d.get("vulnerable", 0))
	c.taunt = bool(d.get("taunt", false))
	c.draw = int(d.get("draw", 0))
	c.target = String(d.get("target", "self"))
	c.text = String(d.get("text", ""))
	return c
