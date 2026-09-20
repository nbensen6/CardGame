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
## This particular COPY came out foil. Not a property of the card type — two
## Strikes in the same deck can differ, which is the whole appeal: it is a
## pull, not a variant. Purely cosmetic; nothing in combat reads it.
var foil: bool = false
## This COPY was printed borderless — full-bleed art, no moulding. Same idea as
## `foil` and rolled the same way, and the two are INDEPENDENT: a borderless
## foil is the double pull, which is the point of rolling them separately.
## Cosmetic only. The view ignores it on a card with no painting of its own,
## because a borderless card whose art is a shared icon is a black rectangle.
var borderless: bool = false
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
var ally_grip_per_rhythm: int  # bonus ALLY Height per Rhythm (Hopscotch: "All players ...
                        # per Rhythm" — grip_per_rhythm alone only ever scaled the CASTER's
                        # own climb; a card whose text explicitly shares the rhythm bonus
                        # with the ally needs its own field, because Ripple Leap proves the
                        # two can't be inferred from grip_per_rhythm+ally_grip alone: it also
                        # carries both, but its ally gets a flat climb, no rhythm scaling)
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
var dexterity: int     # Dexterity gained by the player (Block they gain is +Dexterity for the
                        # rest of the fight — Strength's defensive counterpart, backlog #60)
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
var ethereal: bool      # exhausts (instead of discarding) if still in hand at end of turn —
                        # Retain's opposite: lets a card be pushed above its cost because it
                        # punishes holding it (backlog #58)
var damage_per_x: int  # bonus damage per point of energy spent (backlog #29 — X-cost cards only)
var block_per_x: int   # bonus Block per point of energy spent (backlog #29 — X-cost cards only)
var frail: int          # Frail applied to the Titan: while it lasts, Block IT gains is cut (backlog #36)
var thorns: int         # Thorns gained by the player: an attack landed on them reflects this much at the Titan (backlog #36)
var light_gain: int     # Light banked outright — the Lightbearer's own resource (backlog #47)
var light_cost: int     # Light required AND SPENT to play this card (bank-and-spend, on top of energy)
var damage_per_light: int  # bonus damage per Light currently banked (scales without spending it)
var ally_heal: int      # HP healed on the ALLY, up to their max — the Lightbearer's mend
var power_effect: String  # a `type: "power"` card's recurring payoff (backlog #57) — e.g. "block",
                           # "strength"; resolved by Combat._handle_power_effects at each turn end
var power_value: int      # how much power_effect grants per stack, per turn end
var scry: int              # look at this many cards off the TOP of your draw pile and bin any of
                            # them (backlog #59) — the choice is a command (Combat.resolve_scry),
                            # not resolved here; kept cards return to the top in the same order
var intangible: int    # Intangible gained by the player: a hit that gets past Block is capped at
                        # 1 damage; spends one stack per hit rather than decaying by turn (backlog #61)
var buffer: int         # Buffer gained by the player: a hit that gets past Block is cancelled
                         # outright; spends one stack per hit, same idiom as Intangible (backlog #61)
var plated_armour: int  # Plated Armour gained by the player: persistent Block that survives the
                         # round reset instead of being wiped, decaying only when a hit still gets
                         # HP through despite it (backlog #61)
var discard: int        # discards this many random cards from your OWN hand as this card
                         # resolves — the discard pile stops being fed only by end-of-turn
                         # cleanup and becomes something a card can spend on purpose (backlog #62)
var damage_per_discarded: int  # bonus damage per card currently in your discard pile this
                                # fight — reads the pile size the way damage_per_exhausted
                                # reads the exhaust pile, so a filler/discard card feeds it for
                                # free without either field knowing about the other (backlog #62)
var block_per_discarded: int   # bonus Block per card currently in your discard pile this fight
                                # (backlog #62)
var hits_all_enemies: bool     # deals its damage to the Titan AND every one of its living
                                # "adds" at once instead of a single target (backlog #63,
                                # Cleave) — a fight with more than one thing in it needs a
                                # way to hit all of them without spending a card per target
var rule_upgrade: Dictionary   # field:value overrides applied by upgraded_copy() INSTEAD of
                                # the generic number bump (backlog #66) — how a card's
                                # campfire sharpening can change what it DOES (cost to zero,
                                # gain Retain, hit everything) rather than only its numbers.
                                # Spent the moment it is applied: the sharpened copy carries
                                # the new rule, not the recipe that produced it.
var condition: Dictionary      # {type, value} — a question about the board, asked when the
                                # card is played or previewed (backlog #67): "above_sigil" (this
                                # hunter is at or above the Titan's weak_point_height),
                                # "ally_hanging" (the ally has climbed off the ground),
                                # "nth_card" (this is at least the Nth card played this turn,
                                # value = N). {} = none — the FALLBACK the item asked for is
                                # simply "no bonus", not a second card. Evaluated in
                                # Combat.preview() so the face and the real play never disagree.
var condition_bonus: Dictionary # field:value ADDED to Combat.preview()'s result — damage,
                                 # block, ally_block, grip only — when `condition` holds. Same
                                 # dictionary-override idiom rule_upgrade (#66) and enchants use,
                                 # but additive rather than replacing: the card's printed numbers
                                 # are always the floor, never something the condition takes away.
var topdeck: String    # card id built and put on TOP of your OWN draw pile — the very next
                        # card you draw (backlog #68). "" = none.
var shuffle_in: String  # card id built and shuffled into your OWN draw pile at a random
                        # position, through Combat._rng so it stays deterministic under a seed
                        # (backlog #68). "" = none.
var tutor: String       # card id searched for in your OWN draw pile and pulled straight into
                        # your hand if it's there — a harmless no-op if it isn't (backlog #68).
                        # "" = none.

static func from_dict(d: Dictionary) -> Card:
	var c := Card.new()
	c.id = String(d.get("id", ""))
	c.name = String(d.get("name", ""))
	c.type = String(d.get("type", "skill"))
	c.rarity = String(d.get("rarity", "common"))
	c.foil = bool(d.get("foil", false))
	c.borderless = bool(d.get("borderless", false))
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
	c.ally_grip_per_rhythm = int(d.get("ally_grip_per_rhythm", 0))
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
	c.dexterity = int(d.get("dexterity", 0))
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
	c.ethereal = bool(d.get("ethereal", false))
	c.damage_per_x = int(d.get("damage_per_x", 0))
	c.block_per_x = int(d.get("block_per_x", 0))
	c.frail = int(d.get("frail", 0))
	c.thorns = int(d.get("thorns", 0))
	c.light_gain = int(d.get("light_gain", 0))
	c.light_cost = int(d.get("light_cost", 0))
	c.damage_per_light = int(d.get("damage_per_light", 0))
	c.ally_heal = int(d.get("ally_heal", 0))
	c.power_effect = String(d.get("power_effect", ""))
	c.power_value = int(d.get("power_value", 0))
	c.scry = int(d.get("scry", 0))
	c.intangible = int(d.get("intangible", 0))
	c.buffer = int(d.get("buffer", 0))
	c.plated_armour = int(d.get("plated_armour", 0))
	c.discard = int(d.get("discard", 0))
	c.damage_per_discarded = int(d.get("damage_per_discarded", 0))
	c.block_per_discarded = int(d.get("block_per_discarded", 0))
	c.hits_all_enemies = bool(d.get("hits_all_enemies", false))
	c.rule_upgrade = (d.get("rule_upgrade", {}) as Dictionary).duplicate(true)
	c.condition = (d.get("condition", {}) as Dictionary).duplicate(true)
	c.condition_bonus = (d.get("condition_bonus", {}) as Dictionary).duplicate(true)
	c.topdeck = String(d.get("topdeck", ""))
	c.shuffle_in = String(d.get("shuffle_in", ""))
	c.tutor = String(d.get("tutor", ""))
	return c


## Every field, so a card can be copied or upgraded without losing anything.
func to_dict() -> Dictionary:
	return {
		"id": id, "name": name, "type": type, "rarity": rarity, "foil": foil,
		"borderless": borderless,
		"cost": cost, "damage": damage,
		"block": block, "block_per_play": block_per_play, "ally_block": ally_block,
		"damage_per_exhausted": damage_per_exhausted,
		"block_per_exhausted": block_per_exhausted,
		"ally_energy": ally_energy, "vulnerable": vulnerable, "taunt": taunt,
		"grip": grip, "targets_hold": targets_hold, "ally_grip": ally_grip,
		"ally_grip_per_rhythm": ally_grip_per_rhythm, "pull_ally": pull_ally,
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
		"strength": strength, "dexterity": dexterity, "wound": wound, "hits": hits, "draw": draw,
		"target": target, "icon": icon, "text": text, "upgraded": upgraded,
		"enchant": enchant, "status": status,
		"retain": retain, "innate": innate, "ethereal": ethereal,
		"damage_per_x": damage_per_x, "block_per_x": block_per_x,
		"frail": frail, "thorns": thorns,
		"light_gain": light_gain, "light_cost": light_cost,
		"damage_per_light": damage_per_light, "ally_heal": ally_heal,
		"power_effect": power_effect, "power_value": power_value,
		"scry": scry,
		"intangible": intangible, "buffer": buffer, "plated_armour": plated_armour,
		"discard": discard, "damage_per_discarded": damage_per_discarded,
		"block_per_discarded": block_per_discarded,
		"hits_all_enemies": hits_all_enemies,
		"rule_upgrade": rule_upgrade,
		"condition": condition, "condition_bonus": condition_bonus,
		"topdeck": topdeck, "shuffle_in": shuffle_in, "tutor": tutor,
	}


## A sharpened copy (campfire). One generic rule so every card — including ones
## we invent later — can be upgraded without hand-authoring a second version:
## bump whatever numbers the card actually uses; if it has none, make it
## cheaper; if it's already free too, let it stay in hand instead.
func upgraded_copy() -> Card:
	var d := to_dict()
	if upgraded:
		return Card.from_dict(d)  # already sharpened — no double-dipping
	# condition_bonus (backlog #67) is the same payoff as its matching
	# top-level field, just gated behind `condition` -- brace/dagger/harpoon/
	# sunlight_blade/safety_line/draw_aggro all carry one. Computed here, ahead
	# of the rule_upgrade branch below (backlog #86 duty 2), because a meld can
	# carry rule_upgrade from ONE source card and condition_bonus from the
	# OTHER (each its own independent "keep A's if set, else B's" slot in
	# _meld_cards()) — reckless_swing (rule_upgrade) fused with dagger
	# (condition_bonus) is one ordinary meld away. The rule_upgrade branch
	# returns immediately, so bumping condition_bonus only after it (as this
	# used to) meant a fused card that took that branch never got its
	# condition_bonus scaled at all: the payoff stayed frozen at its printed
	# value through every campfire sharpen for the rest of the run.
	# to_dict() hands back condition_bonus by reference (Dictionary is a
	# reference type in GDScript) — duplicate before mutating, or bumping it
	# here would also silently rewrite the original card's own dict, breaking
	# the immutability this class's own doc comment promises.
	var cb: Dictionary = (d.get("condition_bonus", {}) as Dictionary).duplicate()
	var cb_bumped := false
	if not cb.is_empty():
		for key in ["damage", "block", "ally_block"]:
			if int(cb.get(key, 0)) > 0:
				cb[key] = int(cb[key]) + 3
				cb_bumped = true
		if int(cb.get("grip", 0)) > 0:
			cb["grip"] = int(cb["grip"]) + 1
			cb_bumped = true
		d["condition_bonus"] = cb
	if not rule_upgrade.is_empty():
		# A rule change (backlog #66) — REPLACES the generic number bump rather
		# than stacking with it, the same way an authored card is either "bigger
		# numbers" or "does something new", never both. condition_bonus (just
		# above) is the one exception: it's an orthogonal mechanic, not part of
		# "the generic number bump", so it still applies here — unless
		# rule_upgrade itself names condition_bonus explicitly, which the loop
		# below then correctly overrides with.
		for key in rule_upgrade.keys():
			d[key] = rule_upgrade[key]
		d["rule_upgrade"] = {}
		d["name"] = String(d["name"]) + "+"
		d["upgraded"] = true
		return Card.from_dict(d)
	var bumped := cb_bumped
	for key in ["damage", "block", "ally_block", "timed_damage",
			"timed_block", "timed_ally_block"]:
		if int(d[key]) > 0:
			d[key] = int(d[key]) + 3
			bumped = true
	for key in ["grip", "ally_grip", "timed_grip", "vulnerable", "wound",
			"strength", "dexterity", "draw", "block_per_play", "ally_energy", "rhythm",
			"damage_per_vulnerable", "damage_per_foothold",
			"damage_per_ally_foothold", "damage_per_rhythm", "damage_per_wound",
			"damage_per_exhausted", "block_per_exhausted",
			"damage_per_x", "block_per_x", "frail", "thorns",
			"light_gain", "damage_per_light", "ally_heal", "power_value", "scry",
			"intangible", "buffer", "plated_armour",
			"damage_per_discarded", "block_per_discarded",
			"grip_per_rhythm", "ally_grip_per_rhythm", "pull_ally", "sac_ally_grip"]:
		if int(d[key]) > 0:
			d[key] = int(d[key]) + 1
			bumped = true
	# cheapen_amount can't join the list above: Card.from_dict defaults it to
	# 1 on every card, used or not, so it would falsely read as "bumped" (and
	# skip the cost-reduction fallback) on cards that never authored
	# cheapen_pick at all. Only bump it for cards that actually use it.
	if bool(d.get("cheapen_pick", false)) and int(d["cheapen_amount"]) > 0:
		d["cheapen_amount"] = int(d["cheapen_amount"]) + 1
		bumped = true
	# backlog #86 duty 2: a 0-cost card with nothing bumpable (Build Grapple,
	# Build Bomb, Build Winch, Waymark — a bare `create`/`topdeck` at cost 0,
	# no numeric field, no rule_upgrade) fell through BOTH branches: `bumped`
	# stayed false, and the cost-discount fallback's own `cost > 0` guard also
	# refused to fire since there was nothing left to discount. The card came
	# back byte-for-byte identical (same create/topdeck, same cost) except for
	# the "+" and `upgraded = true` — which then permanently blocks the real
	# fix, since an already-`upgraded` card can never be offered for sharpening
	# again (Run.campfire_action) or re-rolled by a sharpen_card event. A
	# player (or a "free" event sharpen) spent one of their two campfire
	# actions on a card that came back doing exactly what it did before.
	if not bumped:
		if int(d["cost"]) > 0:
			d["cost"] = int(d["cost"]) - 1  # nothing to scale — make it cheaper instead
		elif not bool(d.get("retain", false)):
			d["retain"] = true  # already as cheap as it gets — keep it in hand instead
	d["name"] = String(d["name"]) + "+"
	d["upgraded"] = true
	return Card.from_dict(d)


## Backlog #86 duty 3 (turned duty 2 mid-hunt: this is a real gap, not just an
## untested-but-correct mechanic): upgraded_copy()'s own fallback chain — bump
## a number, else cheapen, else grant retain — has one dead end it never
## covered: a card that is ALREADY cost 0, ALREADY retain, and has nothing
## bumpable (no shipped card today, but a future card or a meld result could
## trivially land here the same way build_grapple/waymark did before the
## duty-2 fix right above this one). upgraded_copy() still returns a Card in
## that case — just one identical to the original but for the "+" and
## `upgraded = true` — so this compares the two rather than duplicating
## upgraded_copy()'s own bump logic a second time (the exact "two copies of
## one truth" shape this rotation's own duty 2 hunts for). Callers use this to
## refuse the sharpen instead of quietly burning a campfire action or an
## event's "free" sharpen on a card that comes back unchanged.
func would_upgrade_change_anything() -> bool:
	if upgraded:
		return false  # already sharpened -- campfire_action's own guard, mirrored here
	var before := to_dict()
	var after := upgraded_copy().to_dict()
	# rule_upgrade itself is consumed bookkeeping -- upgraded_copy()'s
	# rule_upgrade branch always clears it to {} once its recipe is applied,
	# even when every field the recipe set was already at that value (backlog
	# #86 duty 2). Diffing the cleared dict against the original recipe made
	# a true no-op rule_upgrade (e.g. {"cost": 0} on a card already at cost 0)
	# register as "changed" on rule_upgrade alone while every player-visible
	# field stayed identical. Any REAL change the recipe makes still shows up
	# on the field it touched directly, so erasing rule_upgrade here only
	# filters the bookkeeping artifact, not a genuine difference.
	before.erase("name")
	before.erase("upgraded")
	before.erase("rule_upgrade")
	after.erase("name")
	after.erase("upgraded")
	after.erase("rule_upgrade")
	return before != after


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


## Archetype tags, DERIVED from the fields this card already has rather than a
## new field to author (CLAUDE.md §11 — one generic rule beats hand-tagging 155
## cards, and it can never drift out of sync with what a card actually does).
## Used by Run's reward roll to lean a card draft toward the archetype a hunter
## is already building (backlog #72). Not stored, not part of to_dict()/
## from_dict() — nothing here is a new piece of data, so it needs no keywords.json
## entry and no save-format change.
func archetype_tags() -> Array:
	var tags: Array = []
	if grip > 0 or targets_hold or ally_grip > 0 or damage_per_foothold > 0 \
			or damage_per_ally_foothold > 0 or pull_ally > 0 or sac_ally_grip > 0 or timed_grip > 0 \
			or ally_grip_per_rhythm > 0 or grip_per_rhythm > 0:
		tags.append("climb")
	if rhythm > 0 or damage_per_rhythm > 0 or grip_per_rhythm > 0 or ally_grip_per_rhythm > 0:
		tags.append("rhythm")
	if wound > 0 or damage_per_wound > 0 or power_effect == "wound":
		tags.append("poison")
	if block > 0 or ally_block > 0 or timed_block > 0 or timed_ally_block > 0 \
			or plated_armour > 0 or buffer > 0 or intangible > 0 \
			or block_per_play > 0 or block_per_x > 0 \
			or block_per_exhausted > 0 or block_per_discarded > 0 or power_effect == "block":
		tags.append("block")
	if strength > 0 or power_effect == "strength":
		tags.append("strength")
	if dexterity > 0:
		tags.append("dexterity")
	if ally_block > 0 or ally_energy > 0 or ally_grip > 0 or pull_ally > 0 \
			or sac_ally_grip > 0 or ally_heal > 0 or ally_grip_per_rhythm > 0 \
			or damage_per_ally_foothold > 0 or timed_ally_block > 0:
		tags.append("ally")
	if exhaust_pick or damage_per_exhausted > 0 or block_per_exhausted > 0:
		tags.append("burn")
	if light_gain > 0 or light_cost > 0 or damage_per_light > 0:
		tags.append("light")
	if discard > 0 or damage_per_discarded > 0 or block_per_discarded > 0:
		tags.append("discard")
	if vulnerable > 0 or damage_per_vulnerable > 0 or power_effect == "vulnerable":
		tags.append("vulnerable")
	if thorns > 0 or power_effect == "thorns":
		tags.append("thorns")
	if frail > 0 or power_effect == "frail":
		tags.append("frail")
	# backlog #86 duty 2: power_effect == "heal" was the only path to the "heal"
	# tag -- no shipped card uses that power_effect, so it never masked the gap.
	# ally_heal (backlog #47's Lightbearer mend mechanic) is a completely
	# separate healing field and never grew a matching branch here, even though
	# it already feeds the "ally" tag just above. warm_glow (ally_heal 4,
	# light_gain 1) and guiding_light (light_cost 3, ally_heal 8) are two real,
	# shipped cards that get "ally"/"light" leans but never a "heal" lean
	# (backlog #72) toward each other, unlike every power_effect heal card would.
	if power_effect == "heal" or ally_heal > 0:
		tags.append("heal")
	# backlog #86 duty 2: topdeck/shuffle_in/tutor (backlog #68) reach straight
	# into your own draw pile -- exactly the mechanic GameHost._keywords_of()
	# already groups under one keyword, "reach" (keywords.json), for the
	# tap-to-inspect panel. archetype_tags() never grew a matching branch, so
	# waymark (topdeck), depot (shuffle_in) and recon (tutor) -- three real,
	# shipped cards -- rolled through reward_pool() with NO archetype tag at
	# all: a hunter who'd drafted any of them got no reward-lean (backlog #72)
	# toward drawing another, unlike every other mechanical family in the game.
	if topdeck != "" or shuffle_in != "" or tutor != "":
		tags.append("reach")
	# backlog #86 duty 2: same "hand-copied field list drifts" gap the topdeck/
	# shuffle_in/tutor fix just above closed for their own mechanic (backlog
	# #68) -- scry (backlog #59) is the identical shape of gap, just missed
	# when that fix landed: peer_ahead and read_the_climb are two real,
	# shipped cards whose ONLY mechanical field is `scry`, so both rolled
	# through reward_pool() with an empty tag array. A hunter who'd drafted
	# either got no reward-lean (backlog #72) toward drawing the other, unlike
	# every other mechanical family in the game -- including the very sibling
	# fix (topdeck/shuffle_in/tutor) that this comment sits next to.
	if scry > 0:
		tags.append("scry")
	# backlog #86 duty 2: the same "no tag for this mechanical family at all"
	# gap the topdeck/shuffle_in/tutor ("reach") and scry fixes above closed —
	# draw (extra cards drawn) was never given a branch here either. Take Aim
	# (cards.json: draw 2, nothing else) and Fading Insight (draw 2, ethereal)
	# are two real, shipped cards that rolled through reward_pool() with an
	# empty tag array and no reward-lean (backlog #72) toward each other.
	if draw > 0:
		tags.append("draw")
	# backlog #86 duty 2: the same "no tag for this mechanical family at all"
	# gap the topdeck/shuffle_in/tutor ("reach"), scry and draw fixes above
	# closed — create (the Goblin Engineer's whole build-a-tool archetype) was
	# never given a branch here either, even though GameHost._keywords_of()
	# already groups it under one keyword, "build" (keywords.json), for the
	# tap-to-inspect panel — exactly the mirror this file's own reach fix
	# points at. build_grapple, build_bomb, build_winch, build_turret,
	# build_drone and deploy_bulwark are six real, shipped cards whose ONLY
	# mechanical field is `create`, so all six rolled through reward_pool()
	# with an empty tag array: a hunter who'd drafted any of them got no
	# reward-lean (backlog #72) toward drawing another, unlike every other
	# mechanical family in the game.
	if create != "":
		tags.append("build")
	# backlog #86 duty 2: the same "no tag for this mechanical family at all"
	# gap the reach/scry/draw/build fixes above closed — hits_all_enemies
	# (Cleave, backlog: sweeping_strike's base kit and piston_punch's
	# campfire rule_upgrade) was never given a branch here either, even
	# though GameHost._keywords_of() already groups it under one keyword,
	# "cleave" (game_host.gd), for the tap-to-inspect panel. Sweeping Strike
	# (cards.json: damage 8, hits_all_enemies, nothing else archetype-tagged)
	# rolled through reward_pool() with an empty tag array: a hunter who'd
	# drafted it got no reward-lean (backlog #72) toward drawing a
	# campfire-sharpened Piston Punch, or vice versa, unlike every other
	# mechanical family in the game.
	if hits_all_enemies:
		tags.append("cleave")
	# backlog #86 duty 3: the same "no tag for this mechanical family at all"
	# gap the reach/scry/draw/build/cleave fixes above closed — taunt was
	# never given a branch here either, even though GameHost already groups
	# it under its own "taunt" keyword id (game_host.gd:_keywords_of()/
	# _card_icon()). Masked on both shipped taunt cards (draw_aggro, last_
	# stand) by their own block/ally_block fields, so neither ever rolled
	# through reward_pool() with a visibly empty tag array — but a hunter
	# building a Taunt-tanking deck still got zero reward-lean (backlog #72)
	# toward the other taunt card, unlike every other mechanical family.
	if taunt:
		tags.append("taunt")
	# backlog #86 duty 2: the same "no tag for this mechanical family at all"
	# gap the reach/scry/draw/build/cleave/taunt fixes above closed — timed
	# (a well-timed play grants a bonus, GameHost._keywords_of()'s own
	# "timed" keyword) was never given a branch here either. Every shipped
	# timed card with a climb, block or ally payoff already picks up a tag
	# from its OWN timed_grip/timed_block/timed_ally_block field via the
	# climb/block OR-lists above, which hid the gap the same way flat block
	# hid block_per_x/block_per_discarded before their own duty-2 fix — but
	# flick, wrecking_ball and the base (pre-campfire) piston_punch are real,
	# shipped cards whose only mechanical fields are `timed`/`timed_damage`,
	# so all three rolled through reward_pool() with an empty tag array: a
	# hunter who'd drafted any of them got no reward-lean (backlog #72)
	# toward drawing another timed-payoff card.
	if timed or timed_damage > 0:
		tags.append("timed")
	# backlog #86 duty 2: same gap again — hits (multi-strike) was never given
	# a branch either, even though GameHost._keywords_of() already groups
	# `hits > 1` under its own "multistrike" keyword for the tap-to-inspect
	# panel, the same mirror the reach/build fixes above point at. flurry and
	# turret are real, shipped cards whose only mechanical field is `hits`,
	# so both rolled through reward_pool() with an empty tag array: a hunter
	# who'd drafted either got no reward-lean (backlog #72) toward the other,
	# unlike every other mechanical family in the game.
	if hits > 1:
		tags.append("multistrike")
	# backlog #86 duty 2: the same "no tag for this mechanical family at all"
	# gap the reach/scry/draw/build/cleave/taunt/timed/multistrike fixes above
	# closed — prepare (the Goblin Jetpack's prime-this-turn-fire-next-turn
	# mechanic) was never given a branch either, even though
	# GameHost._keywords_of() already groups `prepare != ""` under its own
	# "prime" keyword id for the tap-to-inspect panel. goblin_jetpack
	# (cards.json: prepare "jetpack", nothing else archetype-tagged) is the
	# only shipped card carrying `prepare`, so it rolled through
	# reward_pool() with an empty tag array: a hunter who'd drafted it got no
	# reward-lean (backlog #72) toward drawing it again, unlike every other
	# mechanical family in the game.
	if prepare != "":
		tags.append("prime")
	# backlog #86 duty 2: the same "no tag for this mechanical family at all"
	# gap the reach/scry/draw/build/cleave/taunt/timed/multistrike/prime fixes
	# above closed — retain, innate, ethereal, cheapen_pick and meld were never
	# given a branch here either, even though GameHost._keywords_of() already
	# tags all five ("retain", "innate", "ethereal", "cheapen", "meld") for the
	# tap-to-inspect panel. first_strike (innate, nothing else archetype-tagged),
	# reckless_swing (ethereal only) and the Meld card itself (meld only) are
	# three real, shipped cards that rolled through reward_pool() with a
	# completely EMPTY tag array; bunker_down/steady_flame (retain),
	# guarded_instant/fading_insight (ethereal) and burn_coal (cheapen_pick) are
	# real, shipped cards whose tag array had no branch for the field that is
	# half their identity. A hunter who'd drafted any of them got no reward-lean
	# (backlog #72) toward drawing another, unlike every other mechanical
	# family in the game.
	if retain:
		tags.append("retain")
	if innate:
		tags.append("innate")
	if ethereal:
		tags.append("ethereal")
	if cheapen_pick:
		tags.append("cheapen")
	if meld:
		tags.append("meld")
	# backlog #86 duty 2: the same "no tag for this mechanical family at all"
	# gap the reach/scry/draw/build/cleave/taunt/timed/multistrike/prime/
	# retain-innate-ethereal-cheapen-meld fixes above closed — X-cost cards
	# (backlog #29: cost == -1, paying whatever energy is left, scaled by
	# damage_per_x/block_per_x) were never given a branch here either, even
	# though GameHost._keywords_of() already groups them under their own
	# "x_cost" keyword id for the tap-to-inspect panel. No shipped card uses
	# damage_per_x or block_per_x yet (X Strike/X Brace exist only as
	# run_tests.gd fixtures, `_x_strike()`/`_x_brace()`), so this had zero
	# live impact today — same shape as the "heal" gap two duty-2 rounds ago —
	# but the comment promising coverage that was never wired in is exactly
	# the drift this duty exists to catch, and the day an X-cost card ships
	# it would roll through reward_pool() with no reward-lean (backlog #72)
	# toward drawing another, unlike every other mechanical family in the game.
	if cost == -1 or damage_per_x > 0 or block_per_x > 0:
		tags.append("x_cost")
	# backlog #86 duty 2: the same "no tag for this mechanical family at all"
	# gap the reach/scry/draw/build/cleave/taunt/timed/multistrike/prime/
	# retain-innate-ethereal-cheapen-meld/x_cost fixes above closed —
	# condition/condition_bonus (backlog #67, the nth_card/ally_hanging/
	# above_sigil conditional-payoff mechanic Combat.preview() resolves) was
	# never given a branch here either, even though GameHost._keywords_of()
	# has no need for a matching branch here to already exist — this file's
	# own doc comment on archetype_tags() (above) promises tags are derived
	# from every field a card carries. Dagger (cards.json: damage 3, condition
	# nth_card, nothing else archetype-tagged) rolled through reward_pool()
	# with a completely EMPTY tag array; Brace/Draw Aggro/Harpoon/Sunlight
	# Blade/Safety Line all carry the field too but it was invisible even on
	# them, masked by their own block/vulnerable/ally_block fields the same
	# way taunt was masked before its own duty-3 fix. A hunter who'd drafted
	# any of these six got no reward-lean (backlog #72) toward drawing
	# another conditional-payoff card, unlike every other mechanical family.
	if not condition.is_empty():
		tags.append("condition")
	return tags
