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

# Named trigger moments (backlog #43): before this, a relic/passive that cared
# "when does this fire" was wired into its own call site — energy_handoff read
# straight out of end_turn(), block_carries out of _begin_round(), and every
# new one like them cost combat.gd another special-cased branch. These five
# names are the whole set of moments anything in a fight can care about; see
# _on()/_fire() below for how something subscribes to one.
const MOMENT_TURN_START := "turn_start"
const MOMENT_TURN_END := "turn_end"
const MOMENT_CARD_PLAYED := "card_played"
const MOMENT_DAMAGE_TAKEN := "damage_taken"
const MOMENT_HUNTER_CLIMBS := "hunter_climbs"
# backlog #70: fires once per hunter, before round 1's hand is drawn — the
# moment a relic (or a boon that granted one) or a power gets to already be
# "on" when the fight begins, instead of only Innate (#28) having an opening
# effect. Named separately from turn_start because it must fire exactly ONCE
# per fresh fight, never on a mid-fight save reload — see start() below.
const MOMENT_FIGHT_START := "fight_start"

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

# A card's optional `condition` (backlog #67) — a question about the board,
# asked in preview() so the printed card and the real play never disagree.
const COND_ABOVE_SIGIL := "above_sigil"    # this hunter's foothold >= the Titan's sigil height
const COND_ALLY_HANGING := "ally_hanging"  # the ally has climbed off the ground (foothold > 0)
const COND_NTH_CARD := "nth_card"          # this play is at least the Nth card this hunter has
                                            # played this round (value = N; counts EARLIER plays
                                            # only, same idiom play_counts already uses, so the
                                            # Nth card itself is the one that first meets it)

var players: Array = []  # Array[PlayerState], index = player slot
var boss: Boss
# backlog #63: secondary enemies alongside the boss — "adds" clinging to the
# beast (a parasite, a guardian on a hold). Real Boss instances (Boss extends
# Combatant, so take_damage/gain_block/thorns all work for free) built from
# the boss's own "adds" data (Content.build_boss_adds) — deliberately NOT
# separate bosses.json top-level entries, so they carry no art-coverage
# requirement (Content.boss_ids() only walks top-level keys) and no beast
# pool/move-pattern requirement either. Empty for every beast that doesn't
# define any, so every existing single-boss fight is unaffected.
var adds: Array = []  # Array[Boss]
var round_num: int = 1
var phase: int = Phase.PLAYERS
var log: Array = []

# Run-summary stats (backlog #39) — accumulated for THIS fight only; Run.sync()
# folds them into the run-wide totals once the fight ends, so a fight left
# mid-flight by a save isn't double-counted (see Combat's own to_dict below,
# which carries these so a reloaded fight keeps counting from the right spot).
var damage_dealt_total: int = 0
var cards_played_total: int = 0
var highest_climb: int = 0

var _rng := RandomNumberGenerator.new()
var _forced_target: int = -1  # a "taunt" this round overrides the boss's target

# Team relic modifiers (from Run) — flat bonuses applied each fight.
var _energy_bonus: int = 0
var _attack_bonus: int = 0
var _round_block: int = 0
var _mods: Dictionary = {}  # rule-changing relic totals (see Run.relic_totals)
var _hooks: Dictionary = {}  # moment name -> Array[Callable] (backlog #43)

## decks[i] and combatants[i] belong to player i. The trailing bonuses come from
## the team's relics (see Run) — 0 in a plain fight.
func _init(decks: Array, combatants: Array, p_boss: Boss, seed_value: int = 0,
		energy_bonus: int = 0, attack_bonus: int = 0, round_block: int = 0,
		start_strength: int = 0, player_passives: Array = [],
		run_mods: Dictionary = {}) -> void:
	_mods = run_mods
	# Registered unconditionally, not gated on _mod() here: from_dict() below
	# constructs with the default empty _mods and only overwrites it AFTER
	# _init returns, so a handler that checked _mod() at registration time
	# would silently stay unwired on a fight reloaded from a save. Each
	# handler reads _mod() live, at fire time, instead — same as every other
	# _mod() call in this file already does.
	_on(MOMENT_TURN_START, Callable(self, "_handle_block_carries"))
	_on(MOMENT_TURN_END, Callable(self, "_handle_energy_handoff"))
	_on(MOMENT_TURN_END, Callable(self, "_handle_power_effects"))
	_on(MOMENT_CARD_PLAYED, Callable(self, "_handle_timed_rhythm"))
	_on(MOMENT_FIGHT_START, Callable(self, "_handle_opening_relics"))
	boss = p_boss
	adds = Content.build_boss_adds(boss.id)  # backlog #63 — [] unless the beast's own data defines any
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
		ps.combatant.dexterity = _mod("start_dexterity")  # relic: begin the fight with Dexterity (#60)
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
	# Fires exactly once per fresh fight (from_dict, the mid-fight-save reload
	# path, bypasses start() entirely — see its own comment) so an opener never
	# re-applies itself every time a save is loaded.
	for ps in players:
		_fire(MOMENT_FIGHT_START, {"player": ps})
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
	if card.light_cost > ps.light:  # the Lightbearer's own currency — a second cost on top of energy (backlog #47)
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
		# An X-cost card (backlog #29, sentinel -1) melded with anything stays
		# X-cost — summing -1 into an ordinary cost would corrupt the sentinel
		# into a real (wrong) number instead of "all remaining energy".
		"cost": -1 if (a.cost == -1 or b.cost == -1) else maxi(0, a.cost + b.cost - 1),
		"damage_per_x": a.damage_per_x + b.damage_per_x,
		"block_per_x": a.block_per_x + b.block_per_x,
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
		"dexterity": a.dexterity + b.dexterity,
		"wound": a.wound + b.wound,
			"frail": a.frail + b.frail,
			"thorns": a.thorns + b.thorns,
			"intangible": a.intangible + b.intangible,
			"buffer": a.buffer + b.buffer,
			"plated_armour": a.plated_armour + b.plated_armour,
			"discard": a.discard + b.discard,
			"damage_per_discarded": a.damage_per_discarded + b.damage_per_discarded,
			"block_per_discarded": a.block_per_discarded + b.block_per_discarded,
		"hits": maxi(a.hits, b.hits),
		"draw": a.draw + b.draw,
		"hits_all_enemies": a.hits_all_enemies or b.hits_all_enemies,
		"icon": a.icon if a.icon != "" else b.icon,
		"target": "enemy",
		"text": "%s  +  %s" % [a.text, b.text],
	})

## A card's cost for a hunter, after any permanent Burn Coal reductions.
## `cost == -1` is the X-cost sentinel (backlog #29): it always costs exactly
## whatever energy the hunter currently has, so playing it always drains them
## to zero — permanent reductions don't apply to a cost that isn't a fixed
## number to begin with.
func effective_cost(pi: int, card: Card) -> int:
	if pi < 0 or pi >= players.size():
		return card.cost
	if card.cost == -1:
		return players[pi].energy
	var cost := maxi(0, card.cost - int(players[pi].cost_reductions.get(card.id, 0)))
	if String(card.enchant_data().get("effect", "")) == "cost_cut":  # "Cheap" (backlog #50)
		cost = maxi(0, cost - int(card.enchant_data().get("value", 0)))
	return cost

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
##
## `x_spent` (backlog #29) is how much energy an X-cost card drained — it feeds
## `damage_per_x`/`block_per_x`. Left at -1 (the default), it's read live off
## `ps.energy`, which is correct for a DISPLAY preview (called before the card
## is played, energy still full). `play_card` passes the captured amount
## explicitly instead, since by the time it previews the resolved play it has
## already spent that energy down to zero. Cards that aren't X-cost never set
## `damage_per_x`/`block_per_x`, so this is a no-op for them either way.
##
## The damage NUMBER never depends on which enemy it will land on (backlog
## #63 — same as Slay-the-Spire: a card doesn't do less to an add than to the
## boss). `damage_per_vulnerable`/`damage_per_wound` read the main boss's
## stacks regardless of target; adds don't carry their own in this pass. Who
## it actually lands on is decided at play time (see `enemy_index` on
## play_card()), not here.
func preview(pi: int, card: Card, nailed: bool = true, quality: int = TIMING_PERFECT,
		x_spent: int = -1) -> Dictionary:
	var ps: PlayerState = players[pi]
	var mate: PlayerState = players[ally_index(pi)]
	var hit := card.timed and nailed
	var scale := 0.0
	if hit:
		scale = 1.0 if quality >= TIMING_PERFECT else (TIMING_GOOD_SCALE if quality >= TIMING_GOOD else 0.0)
	var exhausted := ps.exhaust_pile.size()
	var discarded := ps.discard_pile.size()  # backlog #62 — read BEFORE this play's own
	# effects (including its own `discard`, resolved later in play_card) touch the pile,
	# same "counts only earlier plays" idiom damage_per_exhausted already uses.
	var prior := int(ps.play_counts.get(card.id, 0))
	var x := x_spent if x_spent >= 0 else (ps.energy if card.cost == -1 else 0)

	var dmg := card.damage + card.damage_per_vulnerable * boss.vulnerable \
		+ card.damage_per_foothold * ps.foothold + card.damage_per_rhythm * ps.rhythm \
		+ card.damage_per_wound * boss.wound \
		+ card.damage_per_ally_foothold * int(mate.foothold) \
		+ card.damage_per_exhausted * exhausted + card.damage_per_x * x \
		+ card.damage_per_light * ps.light + card.damage_per_discarded * discarded
	if hit:
		dmg += int(card.timed_damage * scale)
	if card.type == "attack":  # buffs lift real attacks, not incidental scaling
		dmg += _attack_bonus + ps.strength + ps.char_attack_bonus

	var blk := card.block + card.block_per_play * prior + card.block_per_exhausted * exhausted \
		+ card.block_per_x * x + card.block_per_discarded * discarded
	if hit:
		blk += int(card.timed_block * scale)
	var ally_blk := card.ally_block + (int(card.timed_ally_block * scale) if hit else 0)

	var climb := card.grip + (int(card.timed_grip * scale) if hit else 0)
	if climb > 0:  # the climb bonus rides an actual climb, not a zero
		climb += ps.climb_bonus + card.grip_per_rhythm * ps.rhythm

	# backlog #67: a card's optional `condition` gates `condition_bonus` — added
	# on top of everything above, never taken away, so the printed numbers stay
	# the floor and the condition is pure upside when it holds.
	if _condition_met(card.condition, ps, mate):
		dmg += int(card.condition_bonus.get("damage", 0))
		blk += int(card.condition_bonus.get("block", 0))
		ally_blk += int(card.condition_bonus.get("ally_block", 0))
		climb += int(card.condition_bonus.get("grip", 0))

	return {
		"damage": maxi(dmg, 0), "hits": maxi(card.hits, 1),
		"block": maxi(blk, 0), "ally_block": maxi(ally_blk, 0),
		"grip": maxi(climb, 0), "ally_grip": card.ally_grip,
	}


## Evaluate one card's `condition` (backlog #67) against the current board.
## {} (no condition) is never "met" — a card with no condition carries no
## bonus to gate, same as `card.condition_bonus.get(...)` defaulting to 0.
func _condition_met(cond: Dictionary, ps: PlayerState, mate: PlayerState) -> bool:
	if cond.is_empty():
		return false
	match String(cond.get("type", "")):
		COND_ABOVE_SIGIL:
			return boss.weak_point_height > 0 and ps.foothold >= boss.weak_point_height
		COND_ALLY_HANGING:
			return mate.foothold > 0
		COND_NTH_CARD:
			return ps.cards_played_this_turn + 1 >= int(cond.get("value", 1))
		_:
			return false


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
	var move := boss.current_move(boss_context())
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
## `enemy_index` (backlog #63) picks a target among `adds` for the card's
## damage instead of the boss — -1 (every existing caller) keeps hitting the
## boss exactly as before this param existed. Ignored by a card whose
## `hits_all_enemies` is set, which always hits the boss AND every living add.
## This is engine-only: no card face lets a player choose one yet (the picker
## is a needs-a-screen follow-up, same split item #25 drew for hold-targeting).
func play_card(pi: int, ci: int, timing_hit: bool = true, sac_index: int = -1, target_index: int = -1,
		hold_target: int = -1, timing_quality: int = TIMING_PERFECT, enemy_index: int = -1) -> bool:
	if not can_play(pi, ci):
		return false
	var ps: PlayerState = players[pi]
	var card: Card = ps.hand[ci]
	var enchant_effect := String(card.enchant_data().get("effect", ""))  # read once (backlog #50)
	# Capture selection targets by reference BEFORE any removal (indices are into the
	# current hand, and must not point at the card being played).
	var sac_card: Card = null
	if (card.exhaust_pick or card.meld) and sac_index >= 0 and sac_index < ps.hand.size() and sac_index != ci:
		sac_card = ps.hand[sac_index]
	var cheapen_card: Card = null
	if (card.cheapen_pick or card.meld) and target_index >= 0 and target_index < ps.hand.size() \
			and target_index != ci and target_index != sac_index:
		cheapen_card = ps.hand[target_index]
	# Captured BEFORE the subtraction below — an X-cost card (backlog #29)
	# drains `ps.energy` to zero here, so `preview()` further down can't
	# read it live the way a display-only preview call does.
	var pay := effective_cost(pi, card)
	var x_spent := pay if card.cost == -1 else 0
	ps.energy -= pay
	ps.light -= card.light_cost  # the Lightbearer's own currency — spent alongside energy, win or fumble (backlog #47)
	ps.hand.remove_at(ci)
	# A fumbled timed card slips away — removed with no effect (not even discarded)
	# — unless the "sure" enchant is attached, which always lands (backlog #12).
	if card.timed and not timing_hit and enchant_effect != "auto_nail":
		_log("%s fumbles %s — it slips away." % [ps.combatant.name, card.name])
		_check_end()
		return true
	if enchant_effect == "self_exhaust":  # "Spent" (backlog #50) — leaves the fight instead
		ps.exhaust_pile.append(card)
	elif card.type == "power":  # backlog #57 — never discarded; stays in play, stacking
		# {stacks, value}: `value` sums the PLAYED card's own power_value rather
		# than re-deriving it later from Content.make_card(id) — a campfire
		# upgrade only lifts the copy actually played (upgraded_copy() bumps
		# power_value but keeps the same id), so if a base and an upgraded copy
		# both land here, each contributes what it actually carries instead of
		# the ongoing payout silently forgetting the upgrade.
		var entry: Dictionary = ps.powers.get(card.id, {"stacks": 0, "value": 0})
		entry["stacks"] = int(entry.get("stacks", 0)) + 1
		entry["value"] = int(entry.get("value", 0)) + card.power_value
		ps.powers[card.id] = entry
		_log("%s plays %s — it stays in play." % [ps.combatant.name, card.name])
	else:
		ps.discard_pile.append(card)
	cards_played_total += 1
	var who: String = ps.combatant.name

	# "True Eye" (backlog #50): a good hit reads as a perfect one for this card,
	# ahead of the preview so the bonus it scales actually pays out perfect.
	if card.timed and timing_hit and timing_quality == TIMING_GOOD and enchant_effect == "quality_up":
		timing_quality = TIMING_PERFECT

	# Everything numeric this card does, from the one formula the card face also
	# shows. Only well-timed plays reach here (fumbles slipped away above), so the
	# preview is taken as nailed, scaled by how well it landed (backlog #33).
	# Damage resolves first, so a card that also Exposes doesn't consume its own
	# stacks. _damage_boss gates on whether THIS hunter reached the sigil.
	#
	# Taken BEFORE play_counts is bumped and before this card's own exhaust_pick
	# fires, so Build Mech counts only EARLIER plays and Detonator doesn't secretly
	# count its own sacrifice.
	var pv := preview(pi, card, true, timing_quality, x_spent)
	ps.play_counts[card.id] = int(ps.play_counts.get(card.id, 0)) + 1
	ps.cards_played_this_turn += 1  # backlog #67 — bumped AFTER the preview this
	# card itself resolved with, same "counts only earlier plays" idiom as play_counts above
	var base_damage: int = int(pv["damage"])
	if base_damage > 0:
		var hit_count := maxi(card.hits, 1)
		var dealt := 0
		# backlog #63: hits_all_enemies (Cleave) always hits the boss AND every
		# living add, ignoring enemy_index entirely — it's not a choice. A plain
		# enemy_index in range redirects the hit to that add instead of the
		# boss; out of range (including the default -1) hits the boss, exactly
		# as every card behaved before adds existed.
		var valid_add := enemy_index >= 0 and enemy_index < adds.size() \
			and not (adds[enemy_index] as Boss).is_dead()
		for _h in hit_count:
			if card.hits_all_enemies:
				dealt += _damage_boss(base_damage, pi)
				for ai in range(adds.size()):
					dealt += _damage_add(ai, base_damage, pi)
			elif valid_add:
				dealt += _damage_add(enemy_index, base_damage, pi)
			else:
				dealt += _damage_boss(base_damage, pi)
		var times := "" if hit_count == 1 else " x%d" % hit_count
		# The weak-point flavour only ever describes the BOSS's own sigil — a
		# hit that (also) lands on an add would otherwise print a misleading
		# "armored" line about a target the add doesn't have.
		var flavour := ""
		if boss.weak_point_height > 0 and not valid_add:
			flavour = "  (weak point!)" if sigil_reached(pi) else "  (ARMORED — climb to the weak point!)"
		_log("%s plays %s — %d damage%s%s." % [who, card.name, dealt, times, flavour])
	if card.strength > 0:
		ps.strength += card.strength
		_log("%s plays %s — +%d Strength." % [who, card.name, card.strength])
	if card.wound > 0:
		# Artifact (backlog #36) wards the boss against a debuff before it lands —
		# same gate Expose gets below, so a warded Titan shrugs off Poison too.
		if boss.try_block_debuff():
			_log("%s plays %s — %s's Artifact wards off the Poison." % [who, card.name, boss.name])
		else:
			boss.wound += card.wound
			_log("%s plays %s — Poison %d on %s." % [who, card.name, boss.wound, boss.name])
			if ps.poison_lift > 0:  # Vine-Weaver: the vines feed on the poison and lift the ally
				var fed_ally: PlayerState = players[ally_index(pi)]
				fed_ally.foothold = mini(fed_ally.foothold + ps.poison_lift, FOOTHOLD_MAX)
				_log("%s's vines surge — %s climbs +%d." % [who, fed_ally.combatant.name, ps.poison_lift])
	if card.frail > 0:  # Frail on the Titan — reduces the Block it gains (backlog #36)
		_apply_frail(boss, card.frail)
	if card.thorns > 0:  # Thorns on the player — reflects a landed boss attack (backlog #36)
		ps.combatant.thorns += card.thorns
		_log("%s plays %s — +%d Thorns." % [who, card.name, card.thorns])
	if card.intangible > 0:  # backlog #61 — spends a stack per hit rather than decaying by turn
		ps.combatant.intangible += card.intangible
		_log("%s plays %s — +%d Intangible." % [who, card.name, card.intangible])
	if card.buffer > 0:  # backlog #61 — cancels the next hit(s) past Block outright
		ps.combatant.buffer += card.buffer
		_log("%s plays %s — +%d Buffer." % [who, card.name, card.buffer])
	if card.plated_armour > 0:  # backlog #61 — banked here for the round reset AND gained as
		# ordinary Block right now via gain_block() (so it's subject to this play's own
		# Dexterity/Frail like any other Block gain), same split #60's Dexterity uses.
		ps.combatant.plated_armour += card.plated_armour
		ps.combatant.gain_block(card.plated_armour)
		_log("%s plays %s — +%d Plated Armour." % [who, card.name, card.plated_armour])
	# "Roped together" (ally_climb) fires once per PLAY, not once per way this card
	# raised Height. A card carrying both targets_hold AND grip (only reachable
	# today via Meld, which ORs targets_hold and sums grip from its two melded
	# halves) used to hit both branches below and lift the ally twice for a single
	# play. Sampled before either branch runs so it catches a rise from either one,
	# or both, without double-counting.
	var foothold_before_climb := ps.foothold
	if card.targets_hold:  # climbs straight TO a named hold instead of adding grip (#24)
		var dest := _resolve_hold_target(pi, hold_target)
		if dest > ps.foothold:
			ps.foothold = mini(dest, FOOTHOLD_MAX)
			_log("%s plays %s — climbs to the hold at Height %d." % [who, card.name, ps.foothold])
		else:
			_log("%s plays %s — no hold left to reach from here." % [who, card.name])
	var climbed: int = int(pv["grip"])
	if climbed > 0:
		ps.foothold = mini(ps.foothold + climbed, FOOTHOLD_MAX)
		var flair := "  (nailed it!)" if card.timed else ""
		_log("%s plays %s — climbs (+%d Height, now %d)%s." % [who, card.name, climbed, ps.foothold, flair])
	if ps.foothold > foothold_before_climb and ps.ally_climb > 0:  # roped together — the ally climbs with you
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
		if enchant_effect == "echo_block":  # "Bonded" (backlog #50) — the ally feels it too
			var bonded: PlayerState = players[ally_index(pi)]
			bonded.combatant.gain_block(blk)
			_log("%s's Bonded card echoes +%d block to %s." % [who, blk, bonded.combatant.name])
	var ally_blk: int = int(pv["ally_block"])
	if ally_blk > 0:
		var ally: PlayerState = players[ally_index(pi)]
		ally.combatant.gain_block(ally_blk)
		var anchored := "  (nailed it!)" if card.timed and card.timed_ally_block > 0 else ""
		_log("%s plays %s — +%d block to %s%s." % [who, card.name, ally_blk, ally.combatant.name, anchored])
	if card.dexterity > 0:  # backlog #60 — lifts Block gained for the REST of the
		# fight, same as Strength lifts damage; applied after this card's own Block
		# above so a card carrying both fields doesn't inflate its own printed number.
		ps.combatant.dexterity += card.dexterity
		_log("%s plays %s — +%d Dexterity." % [who, card.name, card.dexterity])
	if card.ally_energy > 0:
		var ally_e: PlayerState = players[ally_index(pi)]
		ally_e.energy += card.ally_energy
		_log("%s plays %s — +%d energy to %s." % [who, card.name, card.ally_energy, ally_e.combatant.name])
	if enchant_effect == "ally_energy_gift":  # "Generous" (backlog #50)
		var gifted: PlayerState = players[ally_index(pi)]
		var gift: int = int(card.enchant_data().get("value", 0))
		gifted.energy += gift
		_log("%s's Generous card gives %s +%d energy." % [who, gifted.combatant.name, gift])
	if card.light_gain > 0:  # the Lightbearer's own currency — banks across turns (backlog #47)
		ps.light += card.light_gain
		_log("%s plays %s — +%d Light (now %d)." % [who, card.name, card.light_gain, ps.light])
	if card.ally_heal > 0:  # the Lightbearer's mend — direct HP to the ally, up to their max
		var mended: PlayerState = players[ally_index(pi)]
		var mended_amount := mini(card.ally_heal, mended.combatant.max_hp - mended.combatant.hp)
		mended.combatant.hp += maxi(mended_amount, 0)
		_log("%s plays %s — mends %s for %d." % [who, card.name, mended.combatant.name, maxi(mended_amount, 0)])
	if card.vulnerable > 0:
		if boss.try_block_debuff():  # Artifact (backlog #36) shrugs off the Expose
			_log("%s plays %s — %s's Artifact wards off the Expose." % [who, card.name, boss.name])
		else:
			boss.vulnerable += card.vulnerable
			_log("%s plays %s — %s exposed (%d)." % [who, card.name, boss.name, boss.vulnerable])
	if card.taunt:
		_forced_target = pi
		_log("%s plays %s — draws %s's aggro." % [who, card.name, boss.name])
	if card.discard > 0:  # backlog #62 — random (no picker: this is engine-only, cloud-safe
		# work with no screen to build a hand-picker on; a targeted version is a needs-a-screen
		# follow-up the same way exhaust_pick's face waited on one). Resolved BEFORE `draw`
		# below so a card that both discards and draws (Quick Purge) doesn't risk tossing the
		# very card it just drew — discard from what you're already holding, then refill.
		var tossed := _discard_random(ps, card.discard)
		if tossed > 0:
			_log("%s plays %s — discards %d card(s)." % [who, card.name, tossed])
	if card.draw > 0:
		_draw(ps, card.draw)
		_log("%s plays %s — draw %d." % [who, card.name, card.draw])
	if enchant_effect == "bonus_draw":  # "Keen" (backlog #50)
		var keen_draw: int = int(card.enchant_data().get("value", 0))
		_draw(ps, keen_draw)
		_log("%s's Keen card draws %d more." % [who, keen_draw])
	if card.scry > 0:  # backlog #59 — reveal, then resolve_scry() decides what stays
		ps.scry_pending = _peek_top(ps, card.scry)
		if not ps.scry_pending.is_empty():
			_log("%s plays %s — scries the top %d." % [who, card.name, ps.scry_pending.size()])
	if card.topdeck != "":  # backlog #68 — put a card on TOP of the draw pile: the end of
		# the array, the same end _draw()/_peek_top() pop from.
		var topped := Content.make_card(card.topdeck)
		ps.draw_pile.append(topped)
		_log("%s plays %s — puts %s on top of the draw pile." % [who, card.name, topped.name])
	if card.shuffle_in != "":  # backlog #68 — through _rng so it stays deterministic under a seed
		var shuffled := Content.make_card(card.shuffle_in)
		ps.draw_pile.insert(_rng.randi_range(0, ps.draw_pile.size()), shuffled)
		_log("%s plays %s — shuffles %s into the draw pile." % [who, card.name, shuffled.name])
	if card.tutor != "":  # backlog #68 — pull a specific card straight out of the draw pile
		# into hand; a harmless no-op if it isn't there, same fallback idiom pull_ally uses
		var found := -1
		for i in range(ps.draw_pile.size()):
			if (ps.draw_pile[i] as Card).id == card.tutor:
				found = i
				break
		if found >= 0:
			var pulled: Card = ps.draw_pile[found]
			ps.draw_pile.remove_at(found)
			ps.hand.append(pulled)
			_log("%s plays %s — pulls %s from the draw pile." % [who, card.name, pulled.name])
		else:
			_log("%s plays %s — but no %s is in the draw pile." % [who, card.name, card.tutor])
	if card.rhythm > 0:
		ps.rhythm += card.rhythm
		_log("%s plays %s — +%d Rhythm." % [who, card.name, card.rhythm])
	_fire(MOMENT_CARD_PLAYED, {"player": ps, "card": card})  # e.g. a timed hit builds Rhythm (Frog combo payoff)
	_check_weakpoint_buck(pi)
	_track_climb()
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


## Frail (backlog #36) — the debuff that touches BLOCK: while it's stacked, the
## carrier's Block GAINED is cut (Combatant.gain_block does the actual cut, so
## every source of Block — cards, relics, potions — feels it for free without
## each of them knowing Frail exists). Routed through here so Artifact
## (Combatant.try_block_debuff(), a ward that spends a stack to shrug off the
## next debuff) gets first say, the same gate the vulnerable/wound applications
## in play_card() already use.
func _apply_frail(target: Combatant, amount: int) -> void:
	if amount <= 0:
		return
	if target.try_block_debuff():
		_log("%s's Artifact wards off a debuff." % target.name)
		return
	target.frail += amount
	_log("%s is Frail (%d) — Block gained is reduced." % [target.name, target.frail])

## Deal card damage to the Titan, consuming one "exposed" stack for bonus.
## Returns the actual damage dealt (so the log can flag the bonus).
func _damage_boss(amount: int, pi: int) -> int:
	var dealt := 0
	# Below the weak point, the beast's hide is armored — attacks barely chip it,
	# and Exposed stacks are NOT spent (they bank until a hunter reaches the sigil).
	# You have to CLIMB to deal real damage. This is what makes it a climb, not a fight.
	if boss.weak_point_height > 0 and not sigil_reached(pi):
		var divisor: int = maxi(2, ARMORED_DIVISOR - _mod("chip"))
		dealt = maxi(1, amount / divisor)
		boss.take_damage(dealt)
	else:
		# At the weak point (or a beast with no high sigil): full strike + bonuses.
		var total := amount
		if boss.vulnerable > 0:
			total += VULN_BONUS + _mod("vuln_bonus")
			boss.vulnerable -= 1
		if boss.weak_point_height > 0:
			total += SIGIL_BONUS + _mod("sigil_bonus")
			players[pi].weak_point_damage += total  # counts toward the buck-off threshold
		boss.take_damage(total)
		dealt = total
	if boss.thorns > 0:  # Thorns (backlog #36): touching a spined beast costs you
		players[pi].combatant.take_damage(boss.thorns)
		_log("%s's thorns bite back — %s takes %d." % [boss.name, players[pi].combatant.name, boss.thorns])
	damage_dealt_total += dealt
	_fire(MOMENT_DAMAGE_TAKEN, {"target": boss, "amount": dealt, "player_index": pi})
	return dealt

## Deal card damage to one of the boss's adds (backlog #63). Deliberately
## flat — no weak point, no armored-hide chip, no Vulnerable bonus: adds are
## small secondary threats, not a second climb, so they don't carry the
## boss's own sigil mechanics. Returns the actual damage dealt (0 if the
## index is out of range or the add is already down, so a caller doesn't
## have to check first).
func _damage_add(idx: int, amount: int, pi: int) -> int:
	if idx < 0 or idx >= adds.size():
		return 0
	var add: Boss = adds[idx]
	if add.is_dead():
		return 0
	add.take_damage(amount)
	damage_dealt_total += amount
	_fire(MOMENT_DAMAGE_TAKEN, {"target": add, "amount": amount, "player_index": pi})
	if add.is_dead():
		_log("%s falls." % add.name)
	return amount

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
	_fire(MOMENT_TURN_END, {"player": ps, "index": pi})  # relic: unspent Energy can pass to the ally
	var kept: Array = []  # Retain (backlog #28): stays in hand instead of the discard pile
	while not ps.hand.is_empty():
		var c: Card = ps.hand.pop_back()
		if c.ethereal:  # Retain's opposite (backlog #58) — checked first, so a card
			ps.exhaust_pile.append(c)  # can never be both and linger in hand forever
		elif c.retain:
			kept.append(c)
		else:
			ps.discard_pile.append(c)
	ps.hand = kept
	_log("%s ends their turn." % ps.combatant.name)
	if _all_ended():
		_enemy_turn()


## Use a held potion (backlog #26): a free action outside the card economy —
## no cost, no card play — so a bad hand still has an out. Reads the same
## effect vocabulary a relic already uses (heal/block/strength/energy/draw)
## plus the co-op and beast-facing effects backlog #52 added: an `_ally`
## variant of each of those five (the same ally_index() hand-off ally_block/
## ally_energy/ally_heal cards already use, so a potion can back the ally's
## turn instead of your own — a real choice against the plain self version,
## not just a bigger number), `climb` (Height with no card and no energy —
## the thing a potion can do that a card economy cannot) and `strip_ward`
## (spends the TITAN's own Artifact directly, no debuff card required — see
## the Frost Sentinel's seeded artifact:2 in bosses.json). Run owns the
## inventory and removes the potion from its slot on success.
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
		"heal_ally":
			var ally_h: PlayerState = players[ally_index(pi)]
			var healed := mini(maxi(value, 0), ally_h.combatant.max_hp - ally_h.combatant.hp)
			ally_h.combatant.hp += maxi(healed, 0)
		"block_ally":
			var ally_b: PlayerState = players[ally_index(pi)]
			ally_b.combatant.gain_block(value)
		"energy_ally":
			var ally_e: PlayerState = players[ally_index(pi)]
			ally_e.energy += value
		"strength_ally":
			var ally_s: PlayerState = players[ally_index(pi)]
			ally_s.strength += value
		"draw_ally":
			_draw(players[ally_index(pi)], value)
		"climb":
			ps.foothold = mini(ps.foothold + value, FOOTHOLD_MAX)
		"strip_ward":
			boss.artifact = maxi(boss.artifact - value, 0)
		_:
			return false
	_log("%s drinks a potion." % ps.combatant.name)
	return true

# --- Internals ------------------------------------------------------------

func _begin_round() -> void:
	phase = Phase.PLAYERS
	_forced_target = -1  # taunts last only their own round
	for ps in players:
		var start_ctx := {"player": ps, "carried_block": 0}
		_fire(MOMENT_TURN_START, start_ctx)
		# maxi(0, ...): a downside relic (#30) can push either bonus negative;
		# neither block nor energy is meaningful below zero (see combatant.gd's
		# take_damage, which assumes block never goes negative).
		# + plated_armour (backlog #61): re-seeded every round instead of being
		# wiped like ordinary Block — it only decays from take_damage's own cut.
		ps.combatant.block = maxi(0, _round_block + int(start_ctx["carried_block"])) + ps.combatant.plated_armour  # relic: start each round with block (+ retained Block)
		ps.energy = maxi(0, BASE_ENERGY + _energy_bonus)  # relic: extra energy
		ps.ended_turn = false
		if _mod("rhythm_keeps") <= 0:
			ps.rhythm = 0  # combo resets each turn (a relic can keep it)
		ps.cards_played_this_turn = 0  # backlog #67 — a card's "nth_card" question is per-round
		_resolve_prepared(ps)
		# Innate (backlog #28): guaranteed in the opening hand of the fight —
		# only round 1, before the normal draw, so it never displaces a card
		# that would otherwise have been drawn this round.
		var innate_drawn := 0
		if round_num == 1:
			innate_drawn = _draw_innate(ps)
		_draw(ps, maxi(0, HAND_SIZE + _mod("draw") - innate_drawn))
	_track_climb()  # a jetpack (_resolve_prepared) can raise a foothold before any card is played this round
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

## The peak Height either hunter has reached this fight (backlog #39). Called
## after anything that can raise a foothold — play_card and the jetpack's
## _resolve_prepared above — rather than duplicated at each call site.
func _track_climb() -> void:
	for ps in players:
		if ps.foothold > highest_climb:
			_fire(MOMENT_HUNTER_CLIMBS, {"player": ps, "foothold": ps.foothold})
		highest_climb = maxi(highest_climb, ps.foothold)

## The board state a boss move's "when" condition (backlog #40) reads — one
## foothold and one Block entry per hunter, in `players` order. Public: the
## telegraphed intent shown to a client (game_host.gd) must resolve a
## conditional move the same way _enemy_turn() will actually resolve it, or
## the intent icon would lie about what's coming.
func boss_context() -> Dictionary:
	var footholds: Array = []
	var blocks: Array = []
	for ps in players:
		footholds.append(ps.foothold)
		blocks.append(ps.combatant.block)
	return {"footholds": footholds, "blocks": blocks}

## The boss's own telegraphed attack lands on a hunter, then Thorns
## (backlog #36) on that hunter reflects back — the debuff axis that punishes
## the act of ATTACKING, not just being hit. Deliberately only wraps the
## boss's real attack moves in _enemy_turn() below — not fall()'s knockdown,
## not the sigil-fatigue/height-split limiter chip — since those are the hunter
## hurting themselves, not the beast striking them, and Thorns has nothing to
## answer there.
## `attacker` (backlog #63) is who Thorns bites back at — null (every existing
## caller) means the boss itself, exactly as before this param existed; an add's
## own attack (see _adds_turn()) passes itself so Thorns reflects onto the add
## that actually landed the hit, not the main boss standing next to it.
func _boss_hits(ps: PlayerState, dmg: int, attacker: Combatant = null) -> void:
	var atk: Combatant = attacker if attacker != null else boss
	ps.combatant.take_damage(dmg)
	_fire(MOMENT_DAMAGE_TAKEN, {"target": ps, "amount": dmg, "from_boss": true})
	if ps.combatant.thorns > 0:
		atk.take_damage(ps.combatant.thorns)
		_log("%s's thorns bite back — %s takes %d." % [ps.combatant.name, atk.name, ps.combatant.thorns])

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
	boss.block = boss.plated_armour  # backlog #61 — re-seeded rather than wiped, same as the players' reset
	var move := boss.current_move(boss_context())
	var value := int(move.get("value", 0))
	match String(move.get("type", "")):
		"attack":
			var dmg := value + boss.strength
			var target: PlayerState = players[boss_target_index()]
			_boss_hits(target, dmg)
			_log("%s attacks %s for %d." % [boss.name, target.combatant.name, dmg])
		"leech":
			var ldmg := value + boss.strength
			var lt: PlayerState = players[boss_target_index()]
			_boss_hits(lt, ldmg)
			var healed := mini(ldmg, boss.max_hp - boss.hp)
			boss.hp += healed
			_log("%s drains %s for %d and recovers %d." % [boss.name, lt.combatant.name, ldmg, healed])
		"attack_all":
			var dmg_all := value + boss.strength
			for ps in players:
				_boss_hits(ps, dmg_all)
				if _mod("shake_resist") <= 0:  # a relic can anchor you against sweeps
						ps.foothold = _hold_below(ps.foothold)
						ps.weak_point_damage = 0
			_log("%s sweeps both hunters for %d and shakes them down a hold." % [boss.name, dmg_all])
		"swipe_high":  # a lash along the flank — only hunters off the ground are hit
			var dh := value + boss.strength
			var caught_high: Array = []
			for i in range(players.size()):
				if players[i].foothold > 0:
					_boss_hits(players[i], dh)
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
					_boss_hits(players[i], dl)
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
				_boss_hits(ps3, dr)
			_log("%s wrenches the hunters apart for %d (gap of %d)." % [boss.name, dr, gap])
		"shift_sigil":  # the weak point moves — whatever you climbed is now wrong
			var moved: int = clampi(value, 1, FOOTHOLD_MAX)
			boss.weak_point_height = moved
			for ps4 in players:
				ps4.weak_point_damage = 0
			_log("%s's sigil shifts to Height %d." % [boss.name, moved])
		"frail":  # backlog #69 — a debuff move: chips Block gained rather than HP
			var ft: PlayerState = players[boss_target_index()]
			_log("%s claws at %s, sapping their guard." % [boss.name, ft.combatant.name])
			_apply_frail(ft.combatant, value)  # same generic path a card uses on the Titan — Artifact wards it
		"curse":  # backlog #69 — hands the targeted hunter a status card, same idiom as an event's curse_card
			var ct: PlayerState = players[boss_target_index()]
			var curse_id := String(move.get("card", "bruised_grip"))
			var cname := String(Content.make_card(curse_id).name)
			var n := maxi(value, 1)
			for i in range(n):
				ct.discard_pile.append(Content.make_card(curse_id))
			_log("%s curses %s — %d %s%s land in their discard pile." % [boss.name, ct.combatant.name, n, cname, "s" if n > 1 else ""])
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
	_adds_turn()
	boss.advance_move()
	if _check_end():
		return
	round_num += 1
	_begin_round()

## backlog #63: each living add acts after the boss, on its own move pattern
## (a real Boss, so current_move()/advance_move() already work). Deliberately
## thin — only "attack" (at the same hunter the boss is currently targeting)
## and "block" are handled; an add is a small secondary threat, not a second
## full beast with the whole move vocabulary.
func _adds_turn() -> void:
	for add_v in adds:
		var add: Boss = add_v
		if add.is_dead():
			continue
		add.block = add.plated_armour  # reseeded each round, same as the boss's own reset above
		var move := add.current_move()
		var value := int(move.get("value", 0))
		match String(move.get("type", "")):
			"attack":
				var target: PlayerState = players[boss_target_index()]
				_boss_hits(target, value, add)
				_log("%s attacks %s for %d." % [add.name, target.combatant.name, value])
			"block":
				add.gain_block(value)
				_log("%s defends (+%d block)." % [add.name, value])
			_:
				pass
		add.advance_move()

func _draw(ps: PlayerState, n: int) -> void:
	for _i in n:
		if ps.draw_pile.is_empty():
			if ps.discard_pile.is_empty():
				return
			ps.draw_pile = ps.discard_pile.duplicate()
			ps.discard_pile.clear()
			_shuffle(ps.draw_pile)
		ps.hand.append(ps.draw_pile.pop_back())

## Backlog #62 (discard as a cost): throw `n` random cards from hand into the
## discard pile — through `_rng` so it stays deterministic under a seed the
## same as `_shuffle`, since a card-picker UI is a needs-a-screen follow-up
## this engine-only pass can't build. Stops early if the hand runs out rather
## than failing the whole play. Returns how many actually went, for the log.
func _discard_random(ps: PlayerState, n: int) -> int:
	var tossed := 0
	for _i in n:
		if ps.hand.is_empty():
			break
		var idx := _rng.randi_range(0, ps.hand.size() - 1)
		ps.discard_pile.append(ps.hand[idx])
		ps.hand.remove_at(idx)
		tossed += 1
	return tossed

## Backlog #59 (Scry): lift up to `n` cards off the TOP of the draw pile (same
## end the deck draws from, reshuffling the discard pile in exactly like _draw
## does if it runs out) WITHOUT drawing them — the caller holds them until
## resolve_scry() puts each one back or bins it. Index 0 is the next card that
## would be drawn, same order _draw() would have taken them in.
func _peek_top(ps: PlayerState, n: int) -> Array:
	var out: Array = []
	for _i in n:
		if ps.draw_pile.is_empty():
			if ps.discard_pile.is_empty():
				break
			ps.draw_pile = ps.discard_pile.duplicate()
			ps.discard_pile.clear()
			_shuffle(ps.draw_pile)
		out.append(ps.draw_pile.pop_back())
	return out

## Backlog #59: the player's decision after a Scry reveal — bin any of the
## revealed cards (indices into scry_pending) to the discard pile; everything
## else returns to the TOP of the draw pile in the same order it was revealed,
## so a card a player chooses to keep is still the next one they'd draw.
## The command the host validates: an out-of-range index is just ignored
## rather than failing the whole call, and calling this with nothing pending
## is a harmless no-op that reports false.
func resolve_scry(pi: int, bin_indices: Array) -> bool:
	if pi < 0 or pi >= players.size():
		return false
	var ps: PlayerState = players[pi]
	if ps.scry_pending.is_empty():
		return false
	var binned := {}
	for idx_v in bin_indices:
		var idx := int(idx_v)
		if idx >= 0 and idx < ps.scry_pending.size():
			binned[idx] = true
	var kept: Array = []
	var bin_count := 0
	for i in range(ps.scry_pending.size()):
		var c: Card = ps.scry_pending[i]
		if binned.has(i):
			ps.discard_pile.append(c)
			bin_count += 1
		else:
			kept.append(c)
	# kept[0] must be the next card popped, so push the pile in reverse: the
	# LAST append is the one pop_back() sees first.
	for i in range(kept.size() - 1, -1, -1):
		ps.draw_pile.append(kept[i])
	ps.scry_pending = []
	_log("%s bins %d card(s) from the scry." % [ps.combatant.name, bin_count])
	return true

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

# --- Trigger moments (backlog #43) -----------------------------------------
#
# A small, named set of points in a round anything can subscribe to instead
# of being wired into its own call site. `ctx` is a plain Dictionary the
# subscriber can both read AND write — GDScript passes Dictionaries by
# reference, so a handler that wants to change what the caller does next
# (block_carries deciding how much Block survives the reset, below) mutates
# a key on it rather than needing its own return-value protocol.

## Subscribe `handler` to run every time `moment` fires, in registration order.
func _on(moment: String, handler: Callable) -> void:
	if not _hooks.has(moment):
		_hooks[moment] = []
	_hooks[moment].append(handler)

## Fire every handler subscribed to `moment`.
func _fire(moment: String, ctx: Dictionary = {}) -> void:
	for h in _hooks.get(moment, []):
		(h as Callable).call(ctx)

## block_carries relic (turn_start): half of last round's unspent Block
## survives the reset instead of draining to zero. Reads `ps.combatant.block`
## BEFORE _begin_round() overwrites it — the caller fires this while the old
## value still stands, then applies whatever `carried_block` ends up holding.
func _handle_block_carries(ctx: Dictionary) -> void:
	if _mod("block_carries") <= 0:
		return
	var ps: PlayerState = ctx["player"]
	ctx["carried_block"] = ps.combatant.block / 2

## energy_handoff relic (turn_end): a hunter's unspent Energy passes to their
## ally instead of vanishing, if the ally hasn't ended their turn yet.
func _handle_energy_handoff(ctx: Dictionary) -> void:
	if _mod("energy_handoff") <= 0:
		return
	var ps: PlayerState = ctx["player"]
	var pi: int = ctx["index"]
	if ps.energy <= 0:
		return
	var mate: PlayerState = players[ally_index(pi)]
	if mate.ended_turn:
		return
	mate.energy += ps.energy
	_log("%s hands off %d unspent Energy to %s." % [ps.combatant.name, ps.energy, mate.combatant.name])
	ps.energy = 0

## fight_start relics (backlog #70): each reads its own _mod() key so a fresh
## opener is just one more line here, the same shape block_carries/
## energy_handoff already use for their own single _mod(). All four land
## effects that PERSIST past round 1's reset (Artifact/Thorns/Intangible are
## spent-on-use, not decayed by round — see combatant.gd — and a seeded power
## just joins the same ps.powers dict _handle_power_effects already pays out
## every turn_end), so firing this once before the first round is enough.
func _handle_opening_relics(ctx: Dictionary) -> void:
	var ps: PlayerState = ctx["player"]
	var power_stacks := _mod("open_power")
	if power_stacks > 0:
		var entry: Dictionary = ps.powers.get("iron_husk", {"stacks": 0, "value": 0})
		entry["stacks"] = int(entry.get("stacks", 0)) + power_stacks
		entry["value"] = int(entry.get("value", 0)) + power_stacks * Content.make_card("iron_husk").power_value
		ps.powers["iron_husk"] = entry
		_log("%s's relic ignites Iron Husk before the fight begins." % ps.combatant.name)
	var artifact_amt := _mod("open_artifact")
	if artifact_amt > 0:
		ps.combatant.artifact += artifact_amt
		_log("%s starts the fight warded (Artifact %d)." % [ps.combatant.name, ps.combatant.artifact])
	var thorns_amt := _mod("open_thorns")
	if thorns_amt > 0:
		ps.combatant.thorns += thorns_amt
		_log("%s starts the fight bristling (Thorns %d)." % [ps.combatant.name, ps.combatant.thorns])
	var intangible_amt := _mod("open_intangible")
	if intangible_amt > 0:
		ps.combatant.intangible += intangible_amt
		_log("%s starts the fight barely-there (Intangible %d)." % [ps.combatant.name, ps.combatant.intangible])

## Not a relic — a fixed core rule (backlog #57, Powers): a `type: "power"`
## card never returns to your hand once played (see the "power" branch in
## play_card's discard routing above), so its payoff has to fire on its own
## from somewhere. turn_end is the moment, same as StS's Metallicize: a power
## played THIS turn already pays out at the end of THIS turn, and every turn
## after, for as long as the fight lasts. `entry.value` is the SUM of what
## every played copy actually carried (see play_card's power branch) so a
## campfire-upgraded copy keeps its bumped number instead of the payout
## re-deriving a flat per-stack amount off the unupgraded data-file card.
## Only the effect KIND (never touched by upgraded_copy()) and the name/text
## for the log line come from Content.make_card(id) — that part is safe to
## look up fresh, the same "look it up rather than cache it" trick
## block_carries/energy_handoff don't need because they aren't per-card.
## Vocabulary matches use_potion()'s self-only effects (heal/block/strength/
## vulnerable/wound/frail/thorns) so a future power can pick from the same
## list without new code, the same "one generic rule" idiom relics/potions
## already use for their own {effect, value} pair.
func _handle_power_effects(ctx: Dictionary) -> void:
	var ps: PlayerState = ctx["player"]
	for id in ps.powers.keys():
		var entry: Dictionary = ps.powers[id]
		var amount: int = int(entry.get("value", 0))
		if amount == 0:
			continue
		var pc := Content.make_card(String(id))
		if pc.power_effect == "":
			continue
		match pc.power_effect:
			"block":
				ps.combatant.gain_block(amount)
				_log("%s's %s triggers — +%d Block." % [ps.combatant.name, pc.name, amount])
			"strength":
				ps.strength += amount
				_log("%s's %s triggers — +%d Strength." % [ps.combatant.name, pc.name, amount])
			"thorns":
				ps.combatant.thorns += amount
				_log("%s's %s triggers — +%d Thorns." % [ps.combatant.name, pc.name, amount])
			"heal":
				ps.combatant.hp = mini(ps.combatant.hp + amount, ps.combatant.max_hp)
				_log("%s's %s triggers — heals %d." % [ps.combatant.name, pc.name, amount])
			"wound":
				if boss.try_block_debuff():
					_log("%s's Artifact wards off %s's Poison." % [boss.name, ps.combatant.name])
				else:
					boss.wound += amount
					_log("%s's %s triggers — Poison %d on %s." % [ps.combatant.name, pc.name, boss.wound, boss.name])
			"vulnerable":
				if boss.try_block_debuff():
					_log("%s's Artifact wards off %s's Expose." % [boss.name, ps.combatant.name])
				else:
					boss.vulnerable += amount
					_log("%s's %s triggers — %s exposed (%d)." % [ps.combatant.name, pc.name, boss.name, boss.vulnerable])
			"frail":
				_apply_frail(boss, amount)

## Not a relic — a fixed core rule (landing a timed card builds Rhythm) moved
## onto the same moment as the third proof effect, since it fires from
## exactly the same place a relic-driven card_played handler would.
func _handle_timed_rhythm(ctx: Dictionary) -> void:
	var card: Card = ctx["card"]
	if not card.timed:
		return
	var ps: PlayerState = ctx["player"]
	ps.rhythm += 1

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
	var add_dicts: Array = []
	for a in adds:
		add_dicts.append((a as Boss).to_dict())
	return {
		"players": player_dicts, "boss": boss.to_dict(), "adds": add_dicts,
		"round_num": round_num, "phase": phase, "log": log,
		"forced_target": _forced_target,
		"energy_bonus": _energy_bonus, "attack_bonus": _attack_bonus,
		"round_block": _round_block, "mods": _mods,
		"rng_state": str(_rng.state),  # a uint64; JSON floats would round it
		"damage_dealt_total": damage_dealt_total, "cards_played_total": cards_played_total,
		"highest_climb": highest_climb,
	}

## Rebuild an in-progress Combat. _init is bypassed (empty decks/combatants —
## real state is overlaid right after) the same way Run.from_dict sidesteps
## its own _init.
static func from_dict(d: Dictionary) -> Combat:
	var c := Combat.new([], [], Content.boss_from_dict(d.get("boss", {})))
	# c.adds was already rebuilt fresh (full HP) inside _init above, from the
	# same immutable data the boss's own id points at — overlay only the
	# DYNAMIC per-fight state saved below, same split Boss.apply_dict() uses.
	var add_dicts: Array = d.get("adds", [])
	for i in range(mini(c.adds.size(), add_dicts.size())):
		(c.adds[i] as Boss).apply_dict(add_dicts[i])
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
	c.damage_dealt_total = int(d.get("damage_dealt_total", 0))
	c.cards_played_total = int(d.get("cards_played_total", 0))
	c.highest_climb = int(d.get("highest_climb", 0))
	return c
