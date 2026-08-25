## A card — pure data (CLAUDE.md §11: cards are data, not hard-coded logic).
##
## /core has NO rendering/input/net deps. Cards are immutable during combat:
## the same instance may appear many times in a deck, so never mutate one.
class_name Card
extends RefCounted

var id: String
var name: String
var type: String       # "attack" | "skill"
var rarity: String     # "common" | "uncommon" | "rare" — weights how often it's offered
var cost: int          # energy to play
var damage: int        # dealt to the Titan
var block: int         # gained by the player who plays it
var ally_block: int    # gained by the ALLY — a co-op combo effect (CLAUDE.md §6)
var ally_energy: int   # energy given to the ALLY (combo enabler)
var vulnerable: int    # "exposed" stacks added to the Titan (next hits deal bonus)
var taunt: bool        # you become the Titan's target this round (tank for your ally)
var grip: int          # Foothold gained — climb toward a high weak point (SotC)
var targets_hold: bool # climbs straight to a named hold (a ledge or the sigil) instead of
                        # adding `grip` — see Combat._resolve_hold_target() (#24, the climb
                        # ENGINE; item 25 is the drag UI that will choose which hold)
var timed: bool        # playing it triggers a timing bar; nailing it grants the timed bonus
var timed_grip: int    # bonus Height on a well-timed throw (Goblin Engineer's grapple)
var timed_damage: int  # bonus damage on a well-timed strike (interactive attacks)
var timed_hits: int    # how many timing windows in a row you must nail (default 1; Satchel = 3)
var timed_block: int   # bonus Block on a well-timed brace — mistime it and the guard slips away
var timed_ally_block: int  # bonus Block for the ALLY on a well-timed anchor (roped defence)
var damage_per_rhythm: int  # bonus damage per Rhythm (Frog combo) you've built this turn
var grip_per_rhythm: int    # bonus Height per Rhythm you've built this turn
var rhythm: int             # Rhythm granted outright (the Frog's combo starter)
var ally_grip: int     # Foothold given to the ALLY (vines/ropes — shared climbing)
var create: String     # card id this card builds and adds to your hand (Goblin Mech)
var pull_ally: int     # grapple the ally UP to your Height, if the gap is within this
var block_per_play: int # extra Block for each earlier time you've played this card this fight
var damage_per_exhausted: int # bonus damage per card burned to the exhaust pile this fight (Goblin)
var block_per_exhausted: int  # bonus Block per card burned to the exhaust pile this fight (Goblin)
var prepare: String    # arms a delayed effect that resolves at the start of your next turn
var exhaust_pick: bool # requires picking a card from your hand to EXHAUST (gone for the fight)
var cheapen_pick: bool # requires picking a card from your hand to permanently cut its cost
var cheapen_amount: int # how much cheapen_pick reduces the chosen card's cost (default 1)
var sac_ally_grip: int # Height your ally climbs, IF you sacrificed a card (Catapult)
var meld: bool         # fuse two chosen hand cards into one (their effects combined, cost sum -1)
var damage_per_vulnerable: int  # bonus damage per Exposed stack on the Titan
var damage_per_foothold: int    # bonus damage per Height climbed (Mountain Climbers)
var damage_per_wound: int       # bonus damage per Wound stack on the Titan (Vine-Weaver)
var damage_per_ally_foothold: int  # bonus damage per your ALLY's Height (Mountain Climbers coordination)
var strength: int      # Strength gained by the player (attacks deal +Strength this fight)
var wound: int         # Wound applied to the Titan (it bleeds each of its turns)
var hits: int          # how many times the damage lands (default 1) — multi-strike
var draw: int          # extra cards drawn
var target: String     # "self" | "ally" | "enemy" — who the card acts on (UI clarity)
var icon: String       # optional icon-key override (else the view infers one from effects)
var text: String       # rules text, shown on the card face (no hover needed — §5)
var upgraded: bool     # a campfire-sharpened card (name gets a +)
var enchant: String    # id of an attached enchant (data/enchants.json); "" = none
var status: bool       # a status/curse card — clogs your deck, no beneficial effect;
                        # inflicted (an event's curse_card), not drafted (backlog #27)
var retain: bool        # stays in hand at end of turn instead of being discarded (backlog #28)
var innate: bool        # guaranteed in the opening hand of every fight (backlog #28)
var damage_per_x: int  # bonus damage per point of energy spent (backlog #29 — X-cost cards only)
var block_per_x: int   # bonus Block per point of energy spent (backlog #29 — X-cost cards only)
var frail: int          # Frail applied to the Titan: while it lasts, Block IT gains is cut (backlog #36)
var thorns: int         # Thorns gained by the player: an attack landed on them reflects this much at the Titan (backlog #36)

static func from_dict(d: Dictionary) -> Card:
	var c := Card.new()
	c.id = String(d.get("id", ""))
	c.name = String(d.get("name", ""))
	c.type = String(d.get("type", "skill"))
	c.rarity = String(d.get("rarity", "common"))
	c.cost = int(d.get("cost", 0))
	c.damage = int(d.get("damage", 0))
	c.block = int(d.get("block", 0))
	c.ally_block = int(d.get("ally_block", 0))
	c.ally_energy = int(d.get("ally_energy", 0))
	c.vulnerable = int(d.get("vulnerable", 0))
	c.taunt = bool(d.get("taunt", false))
	c.grip = int(d.get("grip", 0))
	c.targets_hold = bool(d.get("targets_hold", false))
	c.timed = bool(d.get("timed", false))
	c.timed_grip = int(d.get("timed_grip", 0))
	c.timed_damage = int(d.get("timed_damage", 0))
	c.timed_hits = int(d.get("timed_hits", 1))
	c.timed_block = int(d.get("timed_block", 0))
	c.timed_ally_block = int(d.get("timed_ally_block", 0))
	c.damage_per_rhythm = int(d.get("damage_per_rhythm", 0))
	c.grip_per_rhythm = int(d.get("grip_per_rhythm", 0))
	c.rhythm = int(d.get("rhythm", 0))
	c.ally_grip = int(d.get("ally_grip", 0))
	c.create = String(d.get("create", ""))
	c.pull_ally = int(d.get("pull_ally", 0))
	c.block_per_play = int(d.get("block_per_play", 0))
	c.damage_per_exhausted = int(d.get("damage_per_exhausted", 0))
	c.block_per_exhausted = int(d.get("block_per_exhausted", 0))
	c.prepare = String(d.get("prepare", ""))
	c.exhaust_pick = bool(d.get("exhaust_pick", false))
	c.cheapen_pick = bool(d.get("cheapen_pick", false))
	c.cheapen_amount = int(d.get("cheapen_amount", 1))
	c.sac_ally_grip = int(d.get("sac_ally_grip", 0))
	c.meld = bool(d.get("meld", false))
	c.damage_per_vulnerable = int(d.get("damage_per_vulnerable", 0))
	c.damage_per_foothold = int(d.get("damage_per_foothold", 0))
	c.damage_per_wound = int(d.get("damage_per_wound", 0))
	c.damage_per_ally_foothold = int(d.get("damage_per_ally_foothold", 0))
	c.strength = int(d.get("strength", 0))
	c.wound = int(d.get("wound", 0))
	c.hits = int(d.get("hits", 1))
	c.draw = int(d.get("draw", 0))
	c.target = String(d.get("target", "self"))
	c.icon = String(d.get("icon", ""))
	c.text = String(d.get("text", ""))
	c.upgraded = bool(d.get("upgraded", false))
	c.enchant = String(d.get("enchant", ""))
	c.status = bool(d.get("status", false))
	c.retain = bool(d.get("retain", false))
	c.innate = bool(d.get("innate", false))
	c.damage_per_x = int(d.get("damage_per_x", 0))
	c.block_per_x = int(d.get("block_per_x", 0))
	c.frail = int(d.get("frail", 0))
	c.thorns = int(d.get("thorns", 0))
	return c


## Every field, so a card can be copied or upgraded without losing anything.
func to_dict() -> Dictionary:
	return {
		"id": id, "name": name, "type": type, "rarity": rarity, "cost": cost, "damage": damage,
		"block": block, "block_per_play": block_per_play, "ally_block": ally_block,
		"damage_per_exhausted": damage_per_exhausted,
		"block_per_exhausted": block_per_exhausted,
		"ally_energy": ally_energy, "vulnerable": vulnerable, "taunt": taunt,
		"grip": grip, "targets_hold": targets_hold, "ally_grip": ally_grip, "pull_ally": pull_ally,
		"sac_ally_grip": sac_ally_grip, "exhaust_pick": exhaust_pick,
		"cheapen_pick": cheapen_pick, "cheapen_amount": cheapen_amount, "meld": meld,
		"prepare": prepare, "create": create,
		"timed": timed, "timed_hits": timed_hits, "timed_grip": timed_grip,
		"timed_damage": timed_damage, "timed_block": timed_block,
		"timed_ally_block": timed_ally_block,
		"damage_per_vulnerable": damage_per_vulnerable,
		"damage_per_foothold": damage_per_foothold,
		"damage_per_ally_foothold": damage_per_ally_foothold,
		"damage_per_rhythm": damage_per_rhythm, "grip_per_rhythm": grip_per_rhythm,
		"rhythm": rhythm,
		"damage_per_wound": damage_per_wound,
		"strength": strength, "wound": wound, "hits": hits, "draw": draw,
		"target": target, "icon": icon, "text": text, "upgraded": upgraded,
		"enchant": enchant, "status": status,
		"retain": retain, "innate": innate,
		"damage_per_x": damage_per_x, "block_per_x": block_per_x,
		"frail": frail, "thorns": thorns,
	}


## A sharpened copy (campfire). One generic rule so every card — including ones
## we invent later — can be upgraded without hand-authoring a second version:
## bump whatever numbers the card actually uses; if it has none, make it cheaper.
func upgraded_copy() -> Card:
	var d := to_dict()
	if upgraded:
		return Card.from_dict(d)  # already sharpened — no double-dipping
	var bumped := false
	for key in ["damage", "block", "ally_block", "timed_damage",
			"timed_block", "timed_ally_block"]:
		if int(d[key]) > 0:
			d[key] = int(d[key]) + 3
			bumped = true
	for key in ["grip", "ally_grip", "timed_grip", "vulnerable", "wound",
			"strength", "draw", "block_per_play", "ally_energy", "rhythm",
			"damage_per_vulnerable", "damage_per_foothold",
			"damage_per_ally_foothold", "damage_per_rhythm", "damage_per_wound",
			"damage_per_exhausted", "block_per_exhausted",
			"damage_per_x", "block_per_x", "frail", "thorns"]:
		if int(d[key]) > 0:
			d[key] = int(d[key]) + 1
			bumped = true
	if not bumped and int(d["cost"]) > 0:
		d["cost"] = int(d["cost"]) - 1  # nothing to scale — make it cheaper instead
	d["name"] = String(d["name"]) + "+"
	d["upgraded"] = true
	return Card.from_dict(d)


## The attached enchant as {id, name, text, effect, value}, or {} if none — one
## generic lookup so a reader keys off `effect` (e.g. "auto_nail") rather than
## special-casing enchant ids, the same shape Content.make_relic() already uses.
func enchant_data() -> Dictionary:
	if enchant == "":
		return {}
	return Content.make_enchant(enchant)


## An enchanted copy. The same generic trick upgraded_copy() uses — this works on
## ANY card without the caller (or the card) knowing what the enchant does — but
## attaches a named effect+value instead of bumping numbers. One enchant slot:
## enchanting an already-enchanted card REPLACES the old one rather than stacking.
func enchanted_copy(enchant_id: String) -> Card:
	var d := to_dict()
	d["enchant"] = enchant_id
	return Card.from_dict(d)
