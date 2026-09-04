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

# The debuff axis (backlog #36) — everything so far pointed at the damage
# number (Strength, Wound, Vulnerable); these three change what a TURN is
# worth instead of how big it is. Shared by players and the boss alike
# (Boss extends Combatant), so a card can Frail the Titan, a Titan can carry
# innate Thorns, and either side can be warded with Artifact.
var frail: int = 0     # Block GAINED while this is stacked is cut by 1/FRAIL_BLOCK_DIVISOR
var artifact: int = 0  # a ward: spends one stack to shrug off the next debuff — see try_block_debuff()
var thorns: int = 0    # a direct attack landed on this combatant reflects this much back at the attacker

# Strength's counterpart (backlog #60): Strength lives on PlayerState/Boss and
# lifts the damage number; Dexterity lives HERE, on the shared Combatant axis
# next to Frail, because it applies wherever Block is gained — self, ally, or
# (via Boss extends Combatant) the Titan's own "block" move — with no extra
# wiring at any of those call sites. See gain_block() below for the interaction
# with Frail: Dexterity's bonus is added to the raw amount BEFORE Frail's cut,
# so a Frailed defender still keeps some benefit from banked Dexterity rather
# than losing it outright.
var dexterity: int = 0

# The tier above Block (backlog #61): Block is all-or-nothing and resets every
# round, these three change the SHAPE of taking a hit instead. Both are spent
# a stack per HIT rather than decaying by turn count, the same idiom Artifact
# already uses (try_block_debuff()) — simpler than tracking a duration, and it
# composes cleanly with everything above: both only ever look at what's left
# AFTER Block has already done its job, so a well-blocked hit never burns one.
var intangible: int = 0  # a hit that gets past Block is capped at 1 damage; spends one stack
var buffer: int = 0      # a hit that gets past Block is cancelled outright; spends one stack
# Persistent Block (backlog #61): unlike ordinary Block, does NOT reset with
# the round — Combat re-seeds `block` with this at every round/turn reset
# (`_begin_round`, `_enemy_turn`) instead of zeroing it — but it decays by 1
# whenever a hit still gets HP through despite it, so it isn't free armour
# forever. See take_damage() below for the decay and Combat.play_card() for
# how a card both banks it here AND calls gain_block() for the immediate hit.
var plated_armour: int = 0

const FRAIL_BLOCK_DIVISOR := 4  # Frail cuts Block gained by 1/4 (StS's classic 25%), floored

func _init(p_name: String = "", p_max_hp: int = 1) -> void:
	name = p_name
	max_hp = maxi(p_max_hp, 1)
	hp = max_hp

## Damage hits block first, then HP. HP never goes below 0.
##
## Buffer and Intangible (backlog #61) only ever look at what's left AFTER
## Block — a hit Block fully absorbs never touches either, so blocking well
## is still strictly better than banking a stack. When both are stacked,
## Buffer's full cancel goes first (it's the stronger effect and would waste
## an Intangible stack capping a hit that's about to be zeroed anyway);
## Intangible only spends a stack when it's the one actually doing something.
## Plated Armour decays last, and only when real HP damage still lands —
## a hit Buffer or Intangible fully neutralised costs it nothing.
func take_damage(amount: int) -> void:
	var remaining := maxi(amount, 0)
	var absorbed := mini(block, remaining)
	block -= absorbed
	remaining -= absorbed
	if remaining > 0 and buffer > 0:
		buffer -= 1
		remaining = 0
	elif remaining > 0 and intangible > 0:
		intangible -= 1
		remaining = mini(remaining, 1)
	if remaining > 0 and plated_armour > 0:
		plated_armour -= 1
	hp = maxi(hp - remaining, 0)

## Pure preview of what take_damage(amount) would do to HP, with no mutation —
## spends no Block, Buffer or Intangible stack. Combat.incoming_for() (the
## "survivability at a glance" HUD number) is built on this so it prices a hit
## the same way take_damage() actually will (backlog #86 duty 2). Before this,
## incoming_for()'s "through" field only ever subtracted Block, so a hunter
## holding a Buffer or Intangible stack (#61, added after incoming_for was
## written) saw the HUD claim a bigger hit than would actually land — the
## exact moment those two newer mitigations make a hunter safest is when the
## number told them the least truth about it.
func predicted_damage(amount: int) -> int:
	var remaining := maxi(amount, 0)
	remaining -= mini(block, remaining)
	if remaining > 0 and buffer > 0:
		return 0
	if remaining > 0 and intangible > 0:
		return mini(remaining, 1)
	return remaining

## Frail (backlog #36) cuts what actually lands here — a source that grants
## 4 Block still says it grants 4 (the card face never lies about a number it
## doesn't control), but only 3 show up on the sheet while Frail holds.
## Dexterity (backlog #60) adds flat Block to every source BEFORE that cut, so
## Frail and Dexterity interact the way two real modifiers on the same total
## should: Dexterity's bonus is diminished by Frail like everything else, but
## never zeroed out by it.
func gain_block(amount: int) -> void:
	var gained := maxi(amount, 0)
	if gained > 0:
		gained += dexterity
	if frail > 0 and gained > 0:
		gained -= gained / FRAIL_BLOCK_DIVISOR
	block += gained

## Artifact (backlog #36): a ward against debuffs. One stack blocks one
## debuff application and is spent doing it — the caller applying a debuff
## (see Combat._apply_frail and the vulnerable/wound gates in play_card)
## checks this FIRST and skips applying anything if it returns true.
func try_block_debuff() -> bool:
	if artifact > 0:
		artifact -= 1
		return true
	return false

func is_dead() -> bool:
	return hp <= 0
