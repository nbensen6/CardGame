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
const FOOTHOLD_MAX := 8  # cap on each hunter's climb (Height)
const ARMORED_DIVISOR := 4  # below the weak point the hide is armored: attacks chip 1/ARMORED_DIVISOR
# Grip (Shadow-of-the-Colossus climb tension): climbing between safe holds is a
# race against a real-time grip timer that lives on the CLIENT (like a timed
# card's throw). When it runs out mid-climb the client reports a fall; the core
# just needs to know what's SAFE (the base, a ledge, or the sigil) and how to drop
# a hunter. See is_secure(), next_safe_height(), fall(), and the sweep handling.
const FALL_DAMAGE := 3   # damage taken when grip runs out and a hunter falls to the base

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

## decks[i] and combatants[i] belong to player i. The trailing bonuses come from
## the team's relics (see Run) — 0 in a plain fight.
func _init(decks: Array, combatants: Array, p_boss: Boss, seed_value: int = 0,
		energy_bonus: int = 0, attack_bonus: int = 0, round_block: int = 0,
		start_strength: int = 0, player_passives: Array = []) -> void:
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
	return fh <= 0 or fh >= boss.weak_point_height or fh in boss.ledges

## The next safe hold strictly above a hunter — the ledge (or sigil) they're
## climbing toward. Returns their current height if there's nothing above (secure
## at the top). Drives the "reach Height N" prompt in the view.
func next_safe_height(pi: int) -> int:
	if pi < 0 or pi >= players.size() or boss.weak_point_height <= 0:
		return 0
	var fh: int = players[pi].foothold
	var best := boss.weak_point_height  # the sigil is the ultimate hold
	for l in boss.ledges:
		var lv := int(l)
		if lv > fh and lv < best:
			best = lv
	return best if best > fh else fh

## The highest safe hold strictly below a Height (a ledge, or the base). Where a
## hunter lands when the beast shakes them down a hold.
func _hold_below(height: int) -> int:
	var best := 0
	for l in boss.ledges:
		var lv := int(l)
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
	ps.foothold = 0
	ps.weak_point_damage = 0
	ps.combatant.take_damage(FALL_DAMAGE)
	_log("%s loses their grip and falls! (-%d, back to the base)" % [ps.combatant.name, FALL_DAMAGE])
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
	return effective_cost(pi, ps.hand[ci]) <= ps.energy

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
## timed card's throw (client skill) — true grants the card's timed bonus.
## `sac_index` / `target_index` name cards in the caster's hand for selection cards
## (Burn Coal: burn one, cheapen another; Catapult: burn one). They're chosen on the
## client and validated here. -1 = none.
func play_card(pi: int, ci: int, timing_hit: bool = true, sac_index: int = -1, target_index: int = -1) -> bool:
	if not can_play(pi, ci):
		return false
	var ps: PlayerState = players[pi]
	var card: Card = ps.hand[ci]
	# Capture selection targets by reference BEFORE any removal (indices are into the
	# current hand, and must not point at the card being played).
	var sac_card: Card = null
	if card.exhaust_pick and sac_index >= 0 and sac_index < ps.hand.size() and sac_index != ci:
		sac_card = ps.hand[sac_index]
	var cheapen_card: Card = null
	if card.cheapen_pick and target_index >= 0 and target_index < ps.hand.size() \
			and target_index != ci and target_index != sac_index:
		cheapen_card = ps.hand[target_index]
	ps.energy -= effective_cost(pi, card)
	ps.hand.remove_at(ci)
	# A fumbled timed card slips away — removed with no effect (not even discarded).
	if card.timed and not timing_hit:
		_log("%s fumbles %s — it slips away." % [ps.combatant.name, card.name])
		_check_end()
		return true
	ps.discard_pile.append(card)
	var who: String = ps.combatant.name
	var prior_plays := int(ps.play_counts.get(card.id, 0))  # how many times BEFORE this play
	ps.play_counts[card.id] = prior_plays + 1

	# Damage first (so a card that also Exposes doesn't consume its own stacks).
	# Base scales with Exposed stacks (Sunlight Blade) and this hunter's own Height
	# (Belay Strike). _damage_boss gates on whether THIS hunter reached the sigil.
	var base_damage := card.damage + card.damage_per_vulnerable * boss.vulnerable \
		+ card.damage_per_foothold * ps.foothold
	if card.timed:  # only well-timed hits reach here — a clean strike bites deeper
		base_damage += card.timed_damage
	if card.damage > 0:
		base_damage += _attack_bonus + ps.strength + ps.char_attack_bonus
	if base_damage > 0:
		var hit_count := maxi(card.hits, 1)
		var dealt := 0
		for _h in hit_count:
			dealt += _damage_boss(base_damage, pi)
		var flavour := "" if dealt <= base_damage * hit_count else " (weak point!)"
		var times := "" if hit_count == 1 else " x%d" % hit_count
		_log("%s plays %s — %d damage%s%s." % [who, card.name, dealt, times, flavour])
	if card.strength > 0:
		ps.strength += card.strength
		_log("%s plays %s — +%d Strength." % [who, card.name, card.strength])
	if card.wound > 0:
		boss.wound += card.wound
		_log("%s plays %s — Poison %d on %s." % [who, card.name, boss.wound, boss.name])
	var grip_amount := card.grip
	if card.timed:  # only hits reach here (fumbles slipped away above)
		grip_amount += card.timed_grip
	if grip_amount > 0:
		var climbed := grip_amount + ps.climb_bonus
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
	if card.block > 0 or card.block_per_play > 0:
		var blk := card.block + card.block_per_play * prior_plays  # Build Mech grows each play
		if blk > 0:
			ps.combatant.gain_block(blk)
			_log("%s plays %s — +%d block." % [who, card.name, blk])
	if card.ally_block > 0:
		var ally: PlayerState = players[ally_index(pi)]
		ally.combatant.gain_block(card.ally_block)
		_log("%s plays %s — +%d block to %s." % [who, card.name, card.ally_block, ally.combatant.name])
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

	_check_weakpoint_buck(pi)
	_check_end()
	return true


## Once a hunter has dealt the sigil's damage threshold this visit, the beast
## bucks them down a hold — you can't camp the weak point. This is what makes the
## loop climb -> strike for a chunk -> get thrown -> climb again -> strike.
func _check_weakpoint_buck(pi: int) -> void:
	if boss.weak_point_threshold <= 0 or not sigil_reached(pi):
		return
	var ps: PlayerState = players[pi]
	if ps.weak_point_damage >= boss.weak_point_threshold:
		ps.foothold = _hold_below(ps.foothold)
		ps.weak_point_damage = 0
		_log("The Titan bucks %s off the weak point — climb back up!" % ps.combatant.name)


## Deal card damage to the Titan, consuming one "exposed" stack for bonus.
## Returns the actual damage dealt (so the log can flag the bonus).
func _damage_boss(amount: int, pi: int) -> int:
	# Below the weak point, the beast's hide is armored — attacks barely chip it,
	# and Exposed stacks are NOT spent (they bank until a hunter reaches the sigil).
	# You have to CLIMB to deal real damage. This is what makes it a climb, not a fight.
	if boss.weak_point_height > 0 and not sigil_reached(pi):
		var chip := maxi(1, amount / ARMORED_DIVISOR)
		boss.take_damage(chip)
		return chip
	# At the weak point (or a beast with no high sigil): full strike + bonuses.
	var total := amount
	if boss.vulnerable > 0:
		total += VULN_BONUS
		boss.vulnerable -= 1
	if boss.weak_point_height > 0:
		total += SIGIL_BONUS
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
	while not ps.hand.is_empty():
		ps.discard_pile.append(ps.hand.pop_back())
	_log("%s ends their turn." % ps.combatant.name)
	if _all_ended():
		_enemy_turn()

# --- Internals ------------------------------------------------------------

func _begin_round() -> void:
	phase = Phase.PLAYERS
	_forced_target = -1  # taunts last only their own round
	for ps in players:
		ps.combatant.block = _round_block  # relic: start each round with block
		ps.energy = BASE_ENERGY + _energy_bonus  # relic: extra energy
		ps.ended_turn = false
		_resolve_prepared(ps)
		_draw(ps, HAND_SIZE)
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
				ps.foothold = _hold_below(ps.foothold)  # bucked down to the ledge below
				ps.weak_point_damage = 0
			_log("%s sweeps both hunters for %d and shakes them down a hold." % [boss.name, dmg_all])
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

func _log(msg: String) -> void:
	log.append(msg)
