## Co-op turn-based combat — the authoritative game rules (CLAUDE.md §6, §7,
## build step 3). Deterministic and unit-testable: NO rendering, input, or net.
## Supports N players (1 for the solo loop, 2 for co-op) vs a shared boss.
##
## Round structure (co-op):
##   Player phase: every player refreshes block/energy and draws a fresh hand,
##                 then plays cards and ends their turn independently. A player
##                 who has ended can't act, but the round continues until ALL
##                 players have ended.
##   Enemy phase:  the boss performs its telegraphed move against its telegraphed
##                 target, then advances its pattern.
##   Repeat until the boss dies (WIN) or ANY player dies (LOSE) — so keeping your
##   ally alive matters, which is what the ally-targeting cards are for (§6).
##
## Determinism: pass a non-zero seed for reproducible shuffles (tests do this).
class_name Combat
extends RefCounted

enum Result { ONGOING, WIN, LOSE }
enum Phase { PLAYERS, ENEMY, OVER }

const HAND_SIZE := 5
const BASE_ENERGY := 3
const VULN_BONUS := 4    # extra damage each "exposed" (vulnerable) stack adds to a hit
const SIGIL_BONUS := 5   # extra damage on a hit once a hunter has climbed to the sigil
## Cap on each hunter's climb (Height). Was 8, which the deeper climbs of
## 2026-08-16 would have clipped — the Sunken Warden's sigil is at 13.
const FOOTHOLD_MAX := 16
const ARMORED_DIVISOR := 4  # below the weak point the hide is armored: attacks chip 1/ARMORED_DIVISOR
# Grip (Shadow-of-the-Colossus climb tension): climbing between safe holds is a
# race against a real-time grip timer that lives on the CLIENT (like a timed
# card's throw). When it runs out mid-climb the client reports a fall; the core
# just needs to know what's SAFE (the base, a ledge, or the sigil) and how to drop
# a hunter. See is_secure(), next_safe_height(), fall(), and the sweep handling.
const FALL_DAMAGE := 3   # damage taken when grip runs out and a hunter falls to the base
const RIFT_PER_GAP := 2  # extra 'rift' damage per Height between the hunters — climb together
const SIGIL_FATIGUE_DAMAGE := 4  # a "sigil_fatigue" limiter's chip damage per round camped past its allowance

# Graded timing (backlog #33): a timed card's throw used to be a bare hit/miss
# bool. It's now a quality tier so a hit dead-centre pays more than a hit
# scraping the edge of the same green zone. TIMING_PERFECT reproduces exactly
# what a plain "hit" always paid (preview()/play_card() both default to it,
# so every untouched caller — every existing test, and the network command
# format — keeps behaving byte-identical to before this landed). Only a
# caller that explicitly threads a lower tier through (CardView's graded
# zone, see ui/card_view.gd) ever sees the new GOOD scaling.
const TIMING_MISS := 0
const TIMING_GOOD := 1
const TIMING_PERFECT := 2
const TIMING_GOOD_SCALE := 0.5  # a "good" (not dead-centre) hit pays half the timed bonus

var players: Array = []  # Array[PlayerState], index = player slot
var boss: Boss
var round_num: int = 1
var phase: int = Phase.PLAYERS
var log: Array = []

var _rng := RandomNumberGenerator.new()
var _forced_target: int = -1  # a "taunt" this round overrides the boss's target

# Team relic modifiers (from Run) — flat bonuses applied each fight.
var _energy_bonus: int = 0
var _attack_bonus: int = 0
var _round_block: int = 0
var _mods: Dictionary = {}  # rule-changing relic totals (see Run.relic_totals)

## decks[i] and combatants[i] belong to player i. The trailing bonuses come from
## the team's relics (see Run) — 0 in a plain fight.
func _init(decks: Array, combatants: Array, p_boss: Boss, seed_value: int = 0,
		energy_bonus: int = 0, attack_bonus: int = 0, round_block: int = 0,
		start_strength: int = 0, player_passives: Array = [],
		run_mods: Dictionary = {}) -> void:
	_mods = run_mods
	boss = p_boss
	_energy_bonus = energy_bonus
	_attack_bonus = attack_bonus
	_round_block = round_block
	if seed_value == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value
	for i in range(combatants.size()):
		var ps := PlayerState.new()
		ps.combatant = combatants[i]
		ps.strength = start_strength  # relic: begin the fight with Strength
		ps.foothold = mini(_mod("start_foothold"), FOOTHOLD_MAX)  # relic: start partway up
		if i < player_passives.size():
			_apply_passive(ps, player_passives[i])
		ps.draw_pile = (decks[i] as Array).duplicate()
		_shuffle(ps.draw_pile)
		players.append(ps)

## Set a hunter's character signature passive (constant for the run).
func _apply_passive(ps: PlayerState, passive: Dictionary) -> void:
	ps.character = String(passive.get("character", ""))
	var value := int(passive.get("value", 0))
	match String(passive.get("type", "")):
		"climb_bonus": ps.climb_bonus = value
		"attack_bonus": ps.char_attack_bonus = value
		"ally_climb": ps.ally_climb = value
		"poison_lift": ps.poison_lift = value

func start() -> void:
	_begin_round()

# --- Queries --------------------------------------------------------------

func player_count() -> int:
	return players.size()

## The ally a player's ally-targeting cards help. 2-player: the other player.
func ally_index(pi: int) -> int:
	return (pi + 1) % players.size()

## True when hunter `pi` has climbed high enough to strike the beast's sigil.
func sigil_reached(pi: int) -> bool:
	if pi < 0 or pi >= players.size():
		return false
	return boss.weak_point_height > 0 and players[pi].foothold >= boss.weak_point_height

## A hunter is "secure" when resting on a safe hold — the base, a ledge, or the
## sigil. Between holds they're clinging, and the client's real-time grip timer is
## counting down. (A low-sigil Titan isn't climbed, so a hunter is always secure.)
func is_secure(pi: int) -> bool:
	if pi < 0 or pi >= players.size():
		return true
	if boss.weak_point_height <= 0:
		return true
	var fh: int = players[pi].foothold
	if fh <= 0 or fh >= boss.weak_point_height:
		return true
	for l in boss.ledges:
		if Boss.hold_height(l) == fh and Boss.hold_safe(l):
			return true
	return false

## The next safe hold strictly above a hunter — the ledge (or sigil) they're
## climbing toward. Returns their current height if there's nothing above (secure
## at the top). Drives the "reach Height N" prompt in the view. An unsafe named
## hold (#24) doesn't count as a valid rest stop, same as a bare gap in the wall.
func next_safe_height(pi: int) -> int:
	if pi < 0 or pi >= players.size() or boss.weak_point_height <= 0:
		return 0
	var fh: int = players[pi].foothold
	var best := boss.weak_point_height  # the sigil is the ultimate hold
	for l in boss.ledges:
		if not Boss.hold_safe(l):
			continue
		var lv := Boss.hold_height(l)
		if lv > fh and lv < best:
			best = lv
	return best if best > fh else fh

## True when `height` names an actual hold on this Titan — a ledge (any
## safety) or the sigil itself — rather than an arbitrary number.
func _is_named_hold(height: int) -> bool:
	if height > 0 and height == boss.weak_point_height:
		return true
	for l in boss.ledges:
		if Boss.hold_height(l) == height:
			return true
	return false

## Where a targets_hold card actually climbs to: the requested Height if it
## names a real hold above the hunter's current one, else the nearest safe
## hold above (the sensible default until item 25's drag UI supplies a
## deliberate choice — see Card.targets_hold).
func _resolve_hold_target(pi: int, requested_height: int) -> int:
	var ps: PlayerState = players[pi]
	if requested_height > ps.foothold and _is_named_hold(requested_height):
		return requested_height
	return next_safe_height(pi)

## The highest safe hold strictly below a Height (a ledge, or the base). Where a
## hunter lands when the beast shakes them down a hold.
func _hold_below(height: int) -> int:
	var best := 0
	for l in boss.ledges:
		if not Boss.hold_safe(l):
			continue
		var lv := Boss.hold_height(l)
		if lv < height and lv > best:
			best = lv
	return best

## The client reports a hunter lost their grip (its real-time timer emptied while
## they were between holds). Drop them to the base with a knock. Authoritative:
## if they've since reached a hold, this is a no-op (a stale/racing report).
func fall(pi: int) -> void:
	if pi < 0 or pi >= players.size() or is_secure(pi):
		return
	var ps: PlayerState = players[pi]
	var soft := _mod("soft_fall") > 0
	ps.foothold = _hold_below(ps.foothold) if soft else 0  # relic: land on the nearest hold, not the base
	ps.weak_point_damage = 0
	var fall_dmg: int = 0 if _mod("fall_safe") > 0 else FALL_DAMAGE
	if fall_dmg > 0:
		ps.combatant.take_damage(fall_dmg)
	_log("%s loses their grip and falls! (-%d, %s)" % [ps.combatant.name, fall_dmg,
		"catches a hold" if soft else "back to the base"])
	_check_end()

## The player the boss's next single-target attack will hit (telegraphed).
## A "taunt" this round overrides it; otherwise it rotates by round.
func boss_target_index() -> int:
	if _forced_target >= 0:
		return _forced_target
	return (round_num - 1) % players.size()

func can_play(pi: int, ci: int) -> bool:
	if phase != Phase.PLAYERS:
		return false
	if pi < 0 or pi >= players.size():
		return false
	var ps: PlayerState = players[pi]
	if ps.ended_turn:
		return false
	if ci < 0 or ci >= ps.hand.size():
		return false
	var card: Card = ps.hand[ci]
	if card.pull_ally > 0:  # a grapple must have someone to pull (Nick): ally below, within reach
		var gap: int = ps.foothold - int(players[ally_index(pi)].foothold)
		if gap <= 0 or gap > card.pull_ally:
			return false
	return effective_cost(pi, card) <= ps.energy

## Fuse two cards into one: EVERY effect carries over (Nick's bug: goblin cards
## live on special fields — prepare/pull_ally/block_per_play/create/timed_hits —
## and the old fusion dropped them, so melds "didn't do both effects"). Numeric
## effects add; flags OR; one-of-a-kind effects (prepare/create) take whichever
## card has one. If either was timed the result is one timed card carrying both
## timed bonuses and the LONGER chain. Only `meld` itself doesn't carry (no
## recursive fuse-cards).
func _meld_cards(a: Card, b: Card) -> Card:
	return Card.from_dict({
		"id": "meld_%s_%s" % [a.id, b.id],
		"name": "%s + %s" % [a.name, b.name],
		"type": "attack" if (a.type == "attack" or b.type == "attack") else "skill",
		"cost": maxi(0, a.cost + b.cost - 1),
		"damage": a.damage + b.damage,
		"block": a.block + b.block,
		"block_per_play": a.block_per_play + b.block_per_play,
		"damage_per_exhausted": a.damage_per_exhausted + b.damage_per_exhausted,
		"block_per_exhausted": a.block_per_exhausted + b.block_per_exhausted,
		"ally_block": a.ally_block + b.ally_block,
		"ally_energy": a.ally_energy + b.ally_energy,
		"vulnerable": a.vulnerable + b.vulnerable,
		"taunt": a.taunt or b.taunt,
		"grip": a.grip + b.grip, "targets_hold": a.targets_hold or b.targets_hold,
		"ally_grip": a.ally_grip + b.ally_grip,
		"pull_ally": maxi(a.pull_ally, b.pull_ally),
		"sac_ally_grip": a.sac_ally_grip + b.sac_ally_grip,
		"exhaust_pick": a.exhaust_pick or b.exhaust_pick,
		"cheapen_pick": a.cheapen_pick or b.cheapen_pick,
		"cheapen_amount": maxi(a.cheapen_amount, b.cheapen_amount),
		"prepare": a.prepare if a.prepare != "" else b.prepare,
		"create": a.create if a.create != "" else b.create,
		"timed": a.timed or b.timed,
		"timed_hits": maxi(a.timed_hits, b.timed_hits),
		"timed_grip": a.timed_grip + b.timed_grip,
		"timed_damage": a.timed_damage + b.timed_damage,
		"timed_block": a.timed_block + b.timed_block,
		"timed_ally_block": a.timed_ally_block + b.timed_ally_block,
		"damage_per_vulnerable": a.damage_per_vulnerable + b.damage_per_vulnerable,
		"damage_per_foothold": a.damage_per_foothold + b.damage_per_foothold,
		"damage_per_ally_foothold": a.damage_per_ally_foothold + b.damage_per_ally_foothold,
		"damage_per_rhythm": a.damage_per_rhythm + b.damage_per_rhythm,
		"rhythm": a.rhythm + b.rhythm,
		"grip_per_rhythm": a.grip_per_rhythm + b.grip_per_rhythm,
		"damage_per_wound": a.damage_per_wound + b.damage_per_wound,
		"strength": a.strength + b.strength,
		"wound": a.wound + b.wound,
		"hits": maxi(a.hits, b.hits),
		"draw": a.draw + b.draw,
		"icon": a.icon if a.icon != "" else b.icon,
		"target": "enemy",
		"text": "%s  +  %s" % [a.text, b.text],
	})

## A card's cost for a hunter, after any permanent Burn Coal reductions.
func effective_cost(pi: int, card: Card) -> int:
	if pi < 0 or pi >= players.size():
		return card.cost
	return maxi(0, card.cost - int(players[pi].cost_reductions.get(card.id, 0)))

func result() -> int:
	if boss.is_dead():
		return Result.WIN
	for ps in players:
		if ps.combatant.is_dead():
			return Result.LOSE
	return Result.ONGOING

func is_over() -> bool:
	return phase == Phase.OVER

# --- Player actions -------------------------------------------------------

## Player pi plays the card at hand index ci. `timing_hit` is the result of a
## What a card will actually DO right now, for this hunter, in this board state.
##
## ONE formula with two callers: `play_card` resolves with it, and the host puts the
## same numbers on the card face so the player never does the arithmetic. That single
## source is the whole point — a second copy would drift the moment a scaling field is
## added, and the card would start lying about its own effect.
##
## `nailed` picks the timed branch: a timed card's bonus applies only on a hit, so the
## view can show both outcomes ("3 → 7"). Untimed cards ignore it.
##
## `quality` (backlog #33) grades HOW WELL a hit landed once `nailed` is true —
## TIMING_PERFECT (the default, so every caller that doesn't pass it explicitly
## behaves exactly as before this landed) pays the timed bonus in full;
## TIMING_GOOD pays TIMING_GOOD_SCALE of it. It's meaningless when `nailed` is
## false — there's no bonus to grade.
func preview(pi: int, card: Card, nailed: bool = true, quality: int = TIMING_PERFECT) -> Dictionary:
	var ps: PlayerState = players[pi]
	var mate: PlayerState = players[ally_index(pi)]
	var hit := card.timed and nailed
	var scale := 0.0
	if hit:
		scale = 1.0 if quality >= TIMING_PERFECT else (TIMING_GOOD_SCALE if quality >= TIMING_GOOD else 0.0)
	var exhausted := ps.exhaust_pile.size()
	var prior := int(ps.play_counts.get(card.id, 0))

	var dmg := card.damage + card.damage_per_vulnerable * boss.vulnerable \
		+ card.damage_per_foothold * ps.foothold + card.damage_per_rhythm * ps.rhythm \
		+ card.damage_per_wound * boss.wound \
		+ card.damage_per_ally_foothold * int(mate.foothold) \
		+ card.damage_per_exhausted * exhausted
	if hit:
		dmg += int(card.timed_damage * scale)
	if card.type == "attack":  # buffs lift real attacks, not incidental scaling
		dmg += _attack_bonus + ps.strength + ps.char_attack_bonus

	var blk := card.block + card.block_per_play * prior + card.block_per_exhausted * exhausted
	if hit:
		blk += int(card.timed_block * scale)
	var ally_blk := card.ally_block + (int(card.timed_ally_block * scale) if hit else 0)

	var climb := card.grip + (int(card.timed_grip * scale) if hit else 0)
	if climb > 0:  # the climb bonus rides an actual climb, not a zero
		climb += ps.climb_bonus + card.grip_per_rhythm * ps.rhythm

	return {
		"damage": maxi(dmg, 0), "hits": maxi(card.hits, 1),
		"block": maxi(blk, 0), "ally_block": maxi(ally_blk, 0),
		"grip": maxi(climb, 0), "ally_grip": card.ally_grip,
	}


## What the beast's telegraphed move will actually cost this hunter, after Block.
##
## The intent icon already says WHAT is coming; this says whether you survive it.
## Without it every turn ends with the player doing the same subtraction in their
## head — and for the two swipes, working out whether being ON the beast saves them
## or dooms them.
##
## Returns {raw, through}: damage aimed at this hunter, and what lands past Block.
func incoming_for(pi: int) -> Dictionary:
	var ps: PlayerState = players[pi]
	var move := boss.current_move()
	var value := int(move.get("value", 0)) + boss.strength
	var raw := 0
	match String(move.get("type", "")):
		"attack", "leech":
			if boss_target_index() == pi:
				raw = value
		"attack_all":
			raw = value
		"swipe_high":  # only catches hunters off the ground
			raw = value if ps.foothold > 0 else 0
		"swipe_low":   # only catches hunters still on the ground
			raw = value if ps.foothold <= 0 else 0
		"rift":        # hits BOTH, and harder the further apart they are
			# Missing here until 2026-08-16, so the one move whose damage the
			# player controls was the one move the HUD showed nothing for.
			var lo := 9999
			var hi := 0
			for other in players:
				lo = mini(lo, other.foothold)
				hi = maxi(hi, other.foothold)
			raw = value + maxi(0, hi - lo) * RIFT_PER_GAP
	return {"raw": raw, "through": maxi(raw - ps.combatant.block, 0)}


## timed card's throw (client skill) — true grants the card's timed bonus.
## `sac_index` / `target_index` name cards in the caster's hand for selection cards
## (Burn Coal: burn one, cheapen another; Catapult: burn one). They're chosen on the
## client and validated here. -1 = none.
## `timing_quality` (backlog #33) grades a landed hit — TIMING_PERFECT (the
## default) pays the timed bonus in full, same as every caller that predates
## grading; only a caller that threads CardView's graded result through (see
## ui/card_view.gd) can land at TIMING_GOOD for a scaled-down bonus. It has no
## effect on the fumble check below — `timing_hit` alone still decides that.
func play_card(pi: int, ci: int, timing_hit: bool = true, sac_index: int = -1, target_index: int = -1,
		hold_target: int = -1, timing_quality: int = TIMING_PERFECT) -> bool:
	if not can_play(pi, ci):
		return false
	var ps: PlayerState = players[pi]
	var card: Card = ps.hand[ci]
	# Capture selection targets by reference BEFORE any removal (indices are into the
	# current hand, and must not point at the card being played).
	var sac_card: Card = null
	if (card.exhaust_pick or card.meld) and sac_index >= 0 and sac_index < ps.hand.size() and sac_index != ci:
		sac_card = ps.hand[sac_index]
	var cheapen_card: Card = null
	if (card.cheapen_pick or card.meld) and target_index >= 0 and target_index < ps.hand.size() \
			and target_index != ci and target_index != sac_index:
		cheapen_card = ps.hand[target_index]
	ps.energy -= effective_cost(pi, card)
	ps.hand.remove_at(ci)
	# A fumbled timed card slips away — removed with no effect (not even discarded)
	# — unless the "sure" enchant is attached, which always lands (backlog #12).
	if card.timed and not timing_hit and String(card.enchant_data().get("effect", "")) != "auto_nail":
		_log("%s fumbles %s — it slips away." % [ps.combatant.name, card.name])
		_check_end()
		return true
	ps.discard_pile.append(card)
	var who: String = ps.combatant.name

	# Everything numeric this card does, from the one formula the card face also
	# shows. Only well-timed plays reach here (fumbles slipped away above), so the
	# preview is taken as nailed, scaled by how well it landed (backlog #33).
	# Damage resolves first, so a card that also Exposes doesn't consume its own
	# stacks. _damage_boss gates on whether THIS hunter reached the sigil.
	#
	# Taken BEFORE play_counts is bumped and before this card's own exhaust_pick
	# fires, so Build Mech counts only EARLIER plays and Detonator doesn't secretly
	# count its own sacrifice.
	var pv := preview(pi, card, true, timing_quality)
	ps.play_counts[card.id] = int(ps.play_counts.get(card.id, 0)) + 1
	var base_damage: int = int(pv["damage"])
	if base_damage > 0:
		var hit_count := maxi(card.hits, 1)
		var dealt := 0
		for _h in hit_count:
			dealt += _damage_boss(base_damage, pi)
		var times := "" if hit_count == 1 else " x%d" % hit_count
		var flavour := ""
		if boss.weak_point_height > 0:
			flavour = "  (weak point!)" if sigil_reached(pi) else "  (ARMORED — climb to the weak point!)"
		_log("%s plays %s — %d damage%s%s." % [who, card.name, dealt, times, flavour])
	if card.strength > 0:
		ps.strength += card.strength
		_log("%s plays %s — +%d Strength." % [who, card.name, card.strength])
	if card.wound > 0:
		boss.wound += card.wound
		_log("%s plays %s — Poison %d on %s." % [who, card.name, boss.wound, boss.name])
		if ps.poison_lift > 0:  # Vine-Weaver: the vines feed on the poison and lift the ally
			var fed_ally: PlayerState = players[ally_index(pi)]
			fed_ally.foothold = mini(fed_ally.foothold + ps.poison_lift, FOOTHOLD_MAX)
			_log("%s's vines surge — %s climbs +%d." % [who, fed_ally.combatant.name, ps.poison_lift])
	if card.targets_hold:  # climbs straight TO a named hold instead of adding grip (#24)
		var dest := _resolve_hold_target(pi, hold_target)
		if dest > ps.foothold:
			ps.foothold = mini(dest, FOOTHOLD_MAX)
			_log("%s plays %s — climbs to the hold at Height %d." % [who, card.name, ps.foothold])
			if ps.ally_climb > 0:  # roped together — the ally climbs with you
				var roped_h: PlayerState = players[ally_index(pi)]
				roped_h.foothold = mini(roped_h.foothold + ps.ally_climb, FOOTHOLD_MAX)
				_log("%s is roped — %s climbs +%d." % [who, roped_h.combatant.name, ps.ally_climb])
		else:
			_log("%s plays %s — no hold left to reach from here." % [who, card.name])
	var climbed: int = int(pv["grip"])
	if climbed > 0:
		ps.foothold = mini(ps.foothold + climbed, FOOTHOLD_MAX)
		var flair := "  (nailed it!)" if card.timed else ""
		_log("%s plays %s — climbs (+%d Height, now %d)%s." % [who, card.name, climbed, ps.foothold, flair])
		if ps.ally_climb > 0:  # roped together — the ally climbs with you
			var roped: PlayerState = players[ally_index(pi)]
			roped.foothold = mini(roped.foothold + ps.ally_climb, FOOTHOLD_MAX)
			_log("%s is roped — %s climbs +%d." % [who, roped.combatant.name, ps.ally_climb])
	if card.ally_grip > 0:  # vines/ropes that lift the ally up the beast
		var lifted: PlayerState = players[ally_index(pi)]
		lifted.foothold = mini(lifted.foothold + card.ally_grip, FOOTHOLD_MAX)
		_log("%s plays %s — lifts %s (+%d Height, now %d)." % [who, card.name, lifted.combatant.name, card.ally_grip, lifted.foothold])
	if card.create != "":
		var built := Content.make_card(card.create)
		ps.hand.append(built)
		_log("%s plays %s — builds %s." % [who, card.name, built.name])
	if card.exhaust_pick:  # Burn Coal / Catapult — sacrifice a chosen card
		if sac_card != null:
			ps.hand.erase(sac_card)
			ps.exhaust_pile.append(sac_card)
			_log("%s sacrifices %s." % [who, sac_card.name])
			if cheapen_card != null:  # Burn Coal: permanently cheapen another card
				var cid := cheapen_card.id
				ps.cost_reductions[cid] = int(ps.cost_reductions.get(cid, 0)) + card.cheapen_amount
				_log("%s makes %s cost %d less this fight." % [who, cheapen_card.name, card.cheapen_amount])
			if card.sac_ally_grip > 0:  # Catapult: launch the ally up
				var launched: PlayerState = players[ally_index(pi)]
				launched.foothold = mini(launched.foothold + card.sac_ally_grip, FOOTHOLD_MAX)
				_log("%s catapults %s up (+%d Height, now %d)." % [who, launched.combatant.name, card.sac_ally_grip, launched.foothold])
		else:
			_log("%s plays %s — but sacrifices nothing." % [who, card.name])
	if card.meld:  # fuse two chosen cards into one combined card
		if sac_card != null and cheapen_card != null:
			ps.hand.erase(sac_card)
			ps.hand.erase(cheapen_card)
			var fused := _meld_cards(sac_card, cheapen_card)
			ps.hand.append(fused)
			_log("%s melds %s + %s into %s (cost %d)." % [who, sac_card.name, cheapen_card.name, fused.name, fused.cost])
		else:
			_log("%s plays %s — needs two cards to meld." % [who, card.name])
	if card.pull_ally > 0:  # grapple the ally UP to your Height, if they're within reach
		var yanked: PlayerState = players[ally_index(pi)]
		var gap := ps.foothold - yanked.foothold
		if gap > 0 and gap <= card.pull_ally:
			yanked.foothold = ps.foothold
			_log("%s grapples %s up to Height %d." % [who, yanked.combatant.name, ps.foothold])
		else:
			_log("%s plays %s — no ally in grapple range." % [who, card.name])
	if card.prepare != "":  # arm a delayed effect (resolves at the start of your next turn)
		ps.prepared = card.prepare
		_log("%s plays %s — armed for next turn." % [who, card.name])
	# A braced guard can be timed too: nail the window as the beast swings and the
	# guard holds. Only hits reach here — a fumbled brace slipped away above, so
	# mistiming a defensive card means eating the blow bare.
	var blk: int = int(pv["block"])
	if blk > 0:
		ps.combatant.gain_block(blk)
		var guard := "  (nailed it!)" if card.timed and card.timed_block > 0 else ""
		_log("%s plays %s — +%d block%s." % [who, card.name, blk, guard])
	var ally_blk: int = int(pv["ally_block"])
	if ally_blk > 0:
		var ally: PlayerState = players[ally_index(pi)]
		ally.combatant.gain_block(ally_blk)
		var anchored := "  (nailed it!)" if card.timed and card.timed_ally_block > 0 else ""
		_log("%s plays %s — +%d block to %s%s." % [who, card.name, ally_blk, ally.combatant.name, anchored])
	if card.ally_energy > 0:
		var ally_e: PlayerState = players[ally_index(pi)]
		ally_e.energy += card.ally_energy
		_log("%s plays %s — +%d energy to %s." % [who, card.name, card.ally_energy, ally_e.combatant.name])
	if card.vulnerable > 0:
		boss.vulnerable += card.vulnerable
		_log("%s plays %s — %s exposed (%d)." % [who, card.name, boss.name, boss.vulnerable])
	if card.taunt:
		_forced_target = pi
		_log("%s plays %s — draws %s's aggro." % [who, card.name, boss.name])
	if card.draw > 0:
		_draw(ps, card.draw)
		_log("%s plays %s — draw %d." % [who, card.name, card.draw])

	if card.rhythm > 0:
		ps.rhythm += card.rhythm
		_log("%s plays %s — +%d Rhythm." % [who, card.name, card.rhythm])
	if card.timed:  # landing a timed card builds Rhythm this turn (Frog combo payoff)
		ps.rhythm += 1
	_check_weakpoint_buck(pi)
	_check_end()
	return true


## Once a hunter has dealt the sigil's damage threshold this visit, the beast
## bucks them down a hold — you can't camp the weak point. This is what makes the
## loop climb -> strike for a chunk -> get thrown -> climb again -> strike.
func _check_weakpoint_buck(pi: int) -> void:
	if boss.weak_point_threshold <= 0 or not sigil_reached(pi) or _mod("no_buck") > 0:
		return
	var ps: PlayerState = players[pi]
	if ps.weak_point_damage >= boss.weak_point_threshold + _mod("threshold"):
		ps.foothold = _hold_below(ps.foothold)
		ps.weak_point_damage = 0
		_log("The Titan bucks %s off the weak point — climb back up!" % ps.combatant.name)


## Each Titan bends one rule against a specific strategy — a wound-stacker, a
## sigil-camper, a hunter who hoards all the Height — so four Titans read as four
## puzzles rather than four HP bars (design/sts2-comparison.md §3.4). One generic
## dispatch on boss.limiter (data), same pattern as the move-type match in
## _enemy_turn(). Runs once at the start of the Titan's turn, before its move.
func _apply_limiter() -> void:
	if boss.limiter.is_empty():
		return
	var value: int = int(boss.limiter.get("value", 0))
	match String(boss.limiter.get("type", "")):
		"wound_decay":  # sheds Poison/Wound each turn — a stack-and-wait strategy decays away
			if boss.wound > 0:
				boss.wound = maxi(boss.wound - value, 0)
		"sigil_fatigue":  # can't camp the weak point turn after turn — grip burns out
			for i in range(players.size()):
				var ps: PlayerState = players[i]
				if sigil_reached(i):
					ps.sigil_rounds += 1
					if ps.sigil_rounds > value:
						ps.combatant.take_damage(SIGIL_FATIGUE_DAMAGE)
						_log("%s's grip burns from clinging too long — takes %d." % [ps.combatant.name, SIGIL_FATIGUE_DAMAGE])
				else:
					ps.sigil_rounds = 0
		"height_split":  # one hunter far above the other strains alone — split the climb
			for i in range(players.size()):
				var ps2: PlayerState = players[i]
				var mate: PlayerState = players[ally_index(i)]
				var excess: int = ps2.foothold - mate.foothold - value
				if excess > 0:
					ps2.combatant.take_damage(excess)
					_log("%s strains alone at Height %d, unsupported — takes %d." % [ps2.combatant.name, ps2.foothold, excess])


## Deal card damage to the Titan, consuming one "exposed" stack for bonus.
## Returns the actual damage dealt (so the log can flag the bonus).
func _damage_boss(amount: int, pi: int) -> int:
	# Below the weak point, the beast's hide is armored — attacks barely chip it,
	# and Exposed stacks are NOT spent (they bank until a hunter reaches the sigil).
	# You have to CLIMB to deal real damage. This is what makes it a climb, not a fight.
	if boss.weak_point_height > 0 and not sigil_reached(pi):
		var divisor: int = maxi(2, ARMORED_DIVISOR - _mod("chip"))
		var chip := maxi(1, amount / divisor)
		boss.take_damage(chip)
		return chip
	# At the weak point (or a beast with no high sigil): full strike + bonuses.
	var total := amount
	if boss.vulnerable > 0:
		total += VULN_BONUS + _mod("vuln_bonus")
		boss.vulnerable -= 1
	if boss.weak_point_height > 0:
		total += SIGIL_BONUS + _mod("sigil_bonus")
		players[pi].weak_point_damage += total  # counts toward the buck-off threshold
	boss.take_damage(total)
	return total

## Player pi ends their turn. When every player has ended, the boss acts.
func end_turn(pi: int) -> void:
	if phase != Phase.PLAYERS:
		return
	if pi < 0 or pi >= players.size():
		return
	var ps: PlayerState = players[pi]
	if ps.ended_turn:
		return
	ps.ended_turn = true
	if _mod("energy_handoff") > 0 and ps.energy > 0:  # relic: unspent Energy passes to the ally
		var mate: PlayerState = players[ally_index(pi)]
		if not mate.ended_turn:
			mate.energy += ps.energy
			_log("%s hands off %d unspent Energy to %s." % [ps.combatant.name, ps.energy, mate.combatant.name])
			ps.energy = 0
	var kept: Array = []  # Retain (backlog #28): stays in hand instead of the discard pile
	while not ps.hand.is_empty():
		var c: Card = ps.hand.pop_back()
		if c.retain:
			kept.append(c)
		else:
			ps.discard_pile.append(c)
	ps.hand = kept
	_log("%s ends their turn." % ps.combatant.name)
	if _all_ended():
		_enemy_turn()


## Use a held potion (backlog #26): a free action outside the card economy —
## no cost, no card play — so a bad hand still has an out. Reads the same
## effect vocabulary a relic already uses (heal/block/strength/energy/draw);
## Run owns the inventory and removes the potion from its slot on success.
func use_potion(pi: int, effect: String, value: int) -> bool:
	if phase != Phase.PLAYERS:
		return false
	if pi < 0 or pi >= players.size():
		return false
	var ps: PlayerState = players[pi]
	if ps.ended_turn:
		return false
	match effect:
		"heal":
			ps.combatant.hp = mini(ps.combatant.hp + maxi(value, 0), ps.combatant.max_hp)
		"block":
			ps.combatant.gain_block(value)
		"strength":
			ps.strength += value
		"energy":
			ps.energy += value
		"draw":
			_draw(ps, value)
		_:
			return false
	_log("%s drinks a potion." % ps.combatant.name)
	return true

# --- Internals ------------------------------------------------------------

func _begin_round() -> void:
	phase = Phase.PLAYERS
	_forced_target = -1  # taunts last only their own round
	for ps in players:
		var carried: int = ps.combatant.block / 2 if _mod("block_carries") > 0 else 0
		ps.combatant.block = _round_block + carried  # relic: start each round with block (+ retained Block)
		ps.energy = BASE_ENERGY + _energy_bonus  # relic: extra energy
		ps.ended_turn = false
		if _mod("rhythm_keeps") <= 0:
			ps.rhythm = 0  # combo resets each turn (a relic can keep it)
		_resolve_prepared(ps)
		# Innate (backlog #28): guaranteed in the opening hand of the fight —
		# only round 1, before the normal draw, so it never displaces a card
		# that would otherwise have been drawn this round.
		var innate_drawn := 0
		if round_num == 1:
			innate_drawn = _draw_innate(ps)
		_draw(ps, maxi(0, HAND_SIZE + _mod("draw") - innate_drawn))
	_log("— Round %d —" % round_num)


## Fire any delayed effect a hunter armed last turn (Goblin Jetpack, etc.).
func _resolve_prepared(ps: PlayerState) -> void:
	match ps.prepared:
		"jetpack":  # rockets you straight to the weak point — the Engineer's climb answer
			ps.prepared = ""
			if boss.weak_point_height > 0:
				ps.foothold = boss.weak_point_height
				_log("%s's jetpack fires — rocketed to the weak point!" % ps.combatant.name)

func _all_ended() -> bool:
	for ps in players:
		if not ps.ended_turn:
			return false
	return true

func _enemy_turn() -> void:
	phase = Phase.ENEMY
	if _check_end():
		return
	if boss.wound > 0:  # bleed ignores the Titan's block
		boss.hp = maxi(boss.hp - boss.wound, 0)
		_log("%s bleeds for %d." % [boss.name, boss.wound])
		if _check_end():
			return
	_apply_limiter()
	if _check_end():
		return
	boss.block = 0
	var move := boss.current_move()
	var value := int(move.get("value", 0))
	match String(move.get("type", "")):
		"attack":
			var dmg := value + boss.strength
			var target: PlayerState = players[boss_target_index()]
			target.combatant.take_damage(dmg)
			_log("%s attacks %s for %d." % [boss.name, target.combatant.name, dmg])
		"leech":
			var ldmg := value + boss.strength
			var lt: PlayerState = players[boss_target_index()]
			lt.combatant.take_damage(ldmg)
			var healed := mini(ldmg, boss.max_hp - boss.hp)
			boss.hp += healed
			_log("%s drains %s for %d and recovers %d." % [boss.name, lt.combatant.name, ldmg, healed])
		"attack_all":
			var dmg_all := value + boss.strength
			for ps in players:
				ps.combatant.take_damage(dmg_all)
				if _mod("shake_resist") <= 0:  # a relic can anchor you against sweeps
						ps.foothold = _hold_below(ps.foothold)
						ps.weak_point_damage = 0
			_log("%s sweeps both hunters for %d and shakes them down a hold." % [boss.name, dmg_all])
		"swipe_high":  # a lash along the flank — only hunters off the ground are hit
			var dh := value + boss.strength
			var caught_high: Array = []
			for i in range(players.size()):
				if players[i].foothold > 0:
					players[i].combatant.take_damage(dh)
					caught_high.append(players[i].combatant.name)
			if caught_high.is_empty():
				_log("%s lashes along its flank — nobody is clinging to it." % boss.name)
			else:
				_log("%s lashes its flank for %d — %s caught on it." % [boss.name, dh, ", ".join(caught_high)])
		"swipe_low":  # it stamps the ground — safe only if you're ON the beast
			var dl := value + boss.strength
			var caught_low: Array = []
			for i in range(players.size()):
				if players[i].foothold <= 0:
					players[i].combatant.take_damage(dl)
					caught_low.append(players[i].combatant.name)
			if caught_low.is_empty():
				_log("%s stamps the ground — both hunters are above it." % boss.name)
			else:
				_log("%s stamps for %d — %s still on the ground." % [boss.name, dl, ", ".join(caught_low)])
		"rift":  # the further apart the hunters are, the worse it hurts — climb together
			var lo := 99
			var hi := 0
			for ps2 in players:
				lo = mini(lo, ps2.foothold)
				hi = maxi(hi, ps2.foothold)
			var gap: int = maxi(0, hi - lo)
			var dr: int = value + boss.strength + gap * RIFT_PER_GAP
			for ps3 in players:
				ps3.combatant.take_damage(dr)
			_log("%s wrenches the hunters apart for %d (gap of %d)." % [boss.name, dr, gap])
		"shift_sigil":  # the weak point moves — whatever you climbed is now wrong
			var moved: int = clampi(value, 1, FOOTHOLD_MAX)
			boss.weak_point_height = moved
			for ps4 in players:
				ps4.weak_point_damage = 0
			_log("%s's sigil shifts to Height %d." % [boss.name, moved])
		"enrage":
			boss.strength += value
			_log("%s enrages (+%d strength, now +%d)." % [boss.name, value, boss.strength])
		"regen":
			boss.hp = mini(boss.hp + value, boss.max_hp)
			_log("%s recovers %d HP." % [boss.name, value])
		"block":
			boss.gain_block(value)
			_log("%s defends (+%d block)." % [boss.name, value])
		_:
			_log("%s hesitates." % boss.name)
	boss.advance_move()
	if _check_end():
		return
	round_num += 1
	_begin_round()

func _draw(ps: PlayerState, n: int) -> void:
	for _i in n:
		if ps.draw_pile.is_empty():
			if ps.discard_pile.is_empty():
				return
			ps.draw_pile = ps.discard_pile.duplicate()
			ps.discard_pile.clear()
			_shuffle(ps.draw_pile)
		ps.hand.append(ps.draw_pile.pop_back())

## Innate (backlog #28): pull every innate card straight out of the (already
## shuffled) draw pile into the opening hand, in whatever order they fell —
## no need to reshuffle what's left, since removing entries doesn't bias it.
## Returns how many were pulled, so the normal draw can make room for them.
func _draw_innate(ps: PlayerState) -> int:
	var kept: Array = []
	var pulled := 0
	for c in ps.draw_pile:
		if c.innate:
			ps.hand.append(c)
			pulled += 1
		else:
			kept.append(c)
	ps.draw_pile = kept
	return pulled

func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp

func _check_end() -> bool:
	if boss.is_dead():
		phase = Phase.OVER
		_log("%s is defeated. Victory!" % boss.name)
		return true
	for ps in players:
		if ps.combatant.is_dead():
			phase = Phase.OVER
			_log("%s has fallen. Defeat." % ps.combatant.name)
			return true
	return false

## A rule-changing relic total (0 when the team has none of that relic).
func _mod(key: String) -> int:
	return int(_mods.get(key, 0))

func _log(msg: String) -> void:
	log.append(msg)

# --- saving -----------------------------------------------------------------
#
# Backlog #14: a fight used to be the one thing Run.to_dict() skipped, so
# quitting mid-combat replayed it from scratch. Everything a save needs to put
# the fight back exactly where it was: both hunters' full state (PlayerState
# does its own to_dict/from_dict, piles included), the boss's dynamic state
# (Boss.to_dict — static data comes back from its id), the round/phase/log,
# and the combat RNG's own state — without that last one, reloading would
# reshuffle differently than the fight actually would have, same trap
# Run.to_dict's own comment already calls out for the run-level RNG.

func to_dict() -> Dictionary:
	var player_dicts: Array = []
	for ps in players:
		player_dicts.append((ps as PlayerState).to_dict())
	return {
		"players": player_dicts, "boss": boss.to_dict(),
		"round_num": round_num, "phase": phase, "log": log,
		"forced_target": _forced_target,
		"energy_bonus": _energy_bonus, "attack_bonus": _attack_bonus,
		"round_block": _round_block, "mods": _mods,
		"rng_state": str(_rng.state),  # a uint64; JSON floats would round it
	}

## Rebuild an in-progress Combat. _init is bypassed (empty decks/combatants —
## real state is overlaid right after) the same way Run.from_dict sidesteps
## its own _init.
static func from_dict(d: Dictionary) -> Combat:
	var c := Combat.new([], [], Content.boss_from_dict(d.get("boss", {})))
	c.players = []
	for pd in d.get("players", []):
		c.players.append(PlayerState.from_dict(pd))
	c.round_num = int(d.get("round_num", 1))
	c.phase = int(d.get("phase", Phase.PLAYERS))
	c.log = (d.get("log", []) as Array).duplicate()
	c._forced_target = int(d.get("forced_target", -1))
	c._energy_bonus = int(d.get("energy_bonus", 0))
	c._attack_bonus = int(d.get("attack_bonus", 0))
	c._round_block = int(d.get("round_block", 0))
	c._mods = (d.get("mods", {}) as Dictionary).duplicate()
	c._rng.state = int(String(d.get("rng_state", "0")))
	return c
