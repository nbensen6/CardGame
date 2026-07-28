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
var grip: int          # Foothold gained — climb toward a high weak point (SotC)
var timed: bool        # playing it triggers a timing bar; nailing it grants timed_grip
var timed_grip: int    # bonus Height on a well-timed throw (Goblin Engineer's grapple)
var ally_grip: int     # Foothold given to the ALLY (vines/ropes — shared climbing)
var create: String     # card id this card builds and adds to your hand (Goblin Mech)
var damage_per_vulnerable: int  # bonus damage per Exposed stack on the Titan
var damage_per_foothold: int    # bonus damage per Height climbed (Mountain Climbers)
var strength: int      # Strength gained by the player (attacks deal +Strength this fight)
var wound: int         # Wound applied to the Titan (it bleeds each of its turns)
var hits: int          # how many times the damage lands (default 1) — multi-strike
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
	c.grip = int(d.get("grip", 0))
	c.timed = bool(d.get("timed", false))
	c.timed_grip = int(d.get("timed_grip", 0))
	c.ally_grip = int(d.get("ally_grip", 0))
	c.create = String(d.get("create", ""))
	c.damage_per_vulnerable = int(d.get("damage_per_vulnerable", 0))
	c.damage_per_foothold = int(d.get("damage_per_foothold", 0))
	c.strength = int(d.get("strength", 0))
	c.wound = int(d.get("wound", 0))
	c.hits = int(d.get("hits", 1))
	c.draw = int(d.get("draw", 0))
	c.target = String(d.get("target", "self"))
	c.text = String(d.get("text", ""))
	return c
