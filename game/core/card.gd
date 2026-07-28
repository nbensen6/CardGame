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
var timed: bool        # playing it triggers a timing bar; nailing it grants the timed bonus
var timed_grip: int    # bonus Height on a well-timed throw (Goblin Engineer's grapple)
var timed_damage: int  # bonus damage on a well-timed strike (interactive attacks)
var timed_hits: int    # how many timing windows in a row you must nail (default 1; Satchel = 3)
var damage_per_rhythm: int  # bonus damage per Rhythm (Frog combo) you've built this turn
var grip_per_rhythm: int    # bonus Height per Rhythm you've built this turn
var ally_grip: int     # Foothold given to the ALLY (vines/ropes — shared climbing)
var create: String     # card id this card builds and adds to your hand (Goblin Mech)
var pull_ally: int     # grapple the ally UP to your Height, if the gap is within this
var block_per_play: int # extra Block for each earlier time you've played this card this fight
var prepare: String    # arms a delayed effect that resolves at the start of your next turn
var exhaust_pick: bool # requires picking a card from your hand to EXHAUST (gone for the fight)
var cheapen_pick: bool # requires picking a card from your hand to permanently cut its cost
var cheapen_amount: int # how much cheapen_pick reduces the chosen card's cost (default 1)
var sac_ally_grip: int # Height your ally climbs, IF you sacrificed a card (Catapult)
var meld: bool         # fuse two chosen hand cards into one (their effects combined, cost sum -1)
var damage_per_vulnerable: int  # bonus damage per Exposed stack on the Titan
var damage_per_foothold: int    # bonus damage per Height climbed (Mountain Climbers)
var strength: int      # Strength gained by the player (attacks deal +Strength this fight)
var wound: int         # Wound applied to the Titan (it bleeds each of its turns)
var hits: int          # how many times the damage lands (default 1) — multi-strike
var draw: int          # extra cards drawn
var target: String     # "self" | "ally" | "enemy" — who the card acts on (UI clarity)
var icon: String       # optional icon-key override (else the view infers one from effects)
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
	c.timed_damage = int(d.get("timed_damage", 0))
	c.timed_hits = int(d.get("timed_hits", 1))
	c.damage_per_rhythm = int(d.get("damage_per_rhythm", 0))
	c.grip_per_rhythm = int(d.get("grip_per_rhythm", 0))
	c.ally_grip = int(d.get("ally_grip", 0))
	c.create = String(d.get("create", ""))
	c.pull_ally = int(d.get("pull_ally", 0))
	c.block_per_play = int(d.get("block_per_play", 0))
	c.prepare = String(d.get("prepare", ""))
	c.exhaust_pick = bool(d.get("exhaust_pick", false))
	c.cheapen_pick = bool(d.get("cheapen_pick", false))
	c.cheapen_amount = int(d.get("cheapen_amount", 1))
	c.sac_ally_grip = int(d.get("sac_ally_grip", 0))
	c.meld = bool(d.get("meld", false))
	c.damage_per_vulnerable = int(d.get("damage_per_vulnerable", 0))
	c.damage_per_foothold = int(d.get("damage_per_foothold", 0))
	c.strength = int(d.get("strength", 0))
	c.wound = int(d.get("wound", 0))
	c.hits = int(d.get("hits", 1))
	c.draw = int(d.get("draw", 0))
	c.target = String(d.get("target", "self"))
	c.icon = String(d.get("icon", ""))
	c.text = String(d.get("text", ""))
	return c
