## Headless test runner for /core + /session — proves the co-op rules and the
## client/server split are deterministic and testable with NO rendering, input,
## or networking (CLAUDE.md §11).
##
## Run from the repo's /game dir (use the *_console.exe on Windows for stdout):
##   godot --headless --path game --script res://tools/run_tests.gd
## Exit code 0 = all passed, 1 = failure.
extends SceneTree

var _failures := 0
# Hosts must be retained: a signal connection does NOT keep a RefCounted target
# alive, so without a strong ref the host is freed and later commands hit nothing.
# (The real app keeps its host as a view member — this only bites the harness.)
var _kept: Array = []


func _init() -> void:
	# combatant / boss
	_test_combatant_block_absorbs_before_hp()
	_test_combatant_hp_never_negative()
	_test_boss_pattern_loops()
	# co-op combat rules
	_test_play_card_spends_energy_and_damages_boss()
	_test_cannot_overspend_energy()
	_test_self_block_resets_each_round()
	_test_assist_shields_ally_not_caster()
	_test_boss_targets_telegraphed_player_and_rotates()
	_test_any_player_death_is_a_loss()
	_test_boss_death_is_a_win()
	_test_boss_waits_for_all_players_to_end()
	_test_deterministic_shuffle_same_seed()
	_test_full_coop_fight_reaches_terminal_state()
	_test_content_loads_from_data()
	# step 4: new combo mechanics + titan moves
	_test_rally_gives_ally_energy()
	_test_expose_adds_bonus_damage()
	_test_taunt_redirects_the_boss()
	_test_attack_all_hits_both()
	_test_enrage_raises_attack()
	# phase 2: climb / weak-point loop
	_test_grip_builds_foothold()
	_test_sigil_bonus_requires_climb()
	_test_exposed_banks_until_climbed()
	_test_height0_titan_no_sigil_bonus()
	_test_attack_all_shakes_down_a_hold()
	_test_sunlight_blade_scales_with_exposed()
	_test_bowshot_deals_and_exposes()
	# grip / ledges (SotC real-time climb)
	_test_secure_on_holds()
	_test_next_safe_height()
	_test_fall_drops_to_base()
	_test_fall_noop_when_secure()
	_test_weakpoint_threshold_bucks()
	_test_timed_damage_bonus()
	# Goblin Engineer cards
	_test_jetpack_prepares_climb()
	_test_grappling_arm_pulls_ally()
	_test_build_mech_scales()
	_test_burn_coal_exhaust_and_cheapen()
	_test_catapult_sacrifices_to_launch_ally()
	_test_meld_fuses_two_cards()
	_test_satchel_charge_detonates()
	# step 4: run / meta-progression
	_test_run_starts_in_combat()
	_test_run_win_flows_through_reward_to_next_encounter()
	_test_run_hp_carries_between_encounters()
	_test_run_defeat_when_a_hunter_falls()
	_test_content_make_card_and_reward_pool()
	# phase 3: 3rd titan, relics, longer runs
	_test_regen_heals_titan()
	_test_relic_energy_bonus()
	_test_relic_attack_bonus()
	_test_relic_round_block()
	_test_run_is_four_titans()
	_test_run_relic_reward_and_full_clear()
	# content batch: strength, wound, multi-hit, leech
	_test_strength_mechanic()
	_test_wound_bleeds_the_titan()
	_test_flurry_multi_hit()
	_test_leech_drains_and_heals()
	_test_relic_start_strength()
	# characters (per-player climb + signature passives)
	_test_frog_climb_bonus()
	_test_vine_lifts_ally()
	_test_roped_ally_climbs()
	_test_character_attack_bonus()
	_test_build_creates_grapple()
	_test_belay_scales_with_height()
	_test_timed_grapple()
	_test_content_builds_character()
	# session / client-server split
	_test_session_both_players_join()
	_test_session_lobby_waits_for_second_player()
	_test_session_shared_board_syncs_across_players()
	_test_session_end_turn_needs_all_players()
	_test_session_private_view_is_isolated()
	_test_host_pauses_on_disconnect()
	_test_solo_controls_both_hunters()

	print("")
	if _failures == 0:
		print("ALL TESTS PASSED")
		quit(0)
	else:
		print("%d TEST(S) FAILED" % _failures)
		quit(1)


# --- Combatant / Boss -----------------------------------------------------

func _test_combatant_block_absorbs_before_hp() -> void:
	var c := Combatant.new("Test", 20)
	c.gain_block(5)
	c.take_damage(8)  # 5 absorbed, 3 to hp
	_expect(c.block == 0 and c.hp == 17, "block absorbs before hp")


func _test_combatant_hp_never_negative() -> void:
	var c := Combatant.new("Test", 10)
	c.take_damage(9999)
	_expect(c.hp == 0 and c.is_dead(), "hp never goes negative")


func _test_boss_pattern_loops() -> void:
	var b := Boss.new("B", 30)
	b.moves = [{"type": "attack", "value": 1}, {"type": "block", "value": 2}]
	var first: Dictionary = b.current_move()
	b.advance_move()
	var second: Dictionary = b.current_move()
	b.advance_move()
	var third: Dictionary = b.current_move()  # wraps to first
	_expect(first["value"] == 1 and second["value"] == 2 and third["value"] == 1,
		"boss pattern loops")


# --- Co-op combat rules ---------------------------------------------------

func _test_play_card_spends_energy_and_damages_boss() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 1, _dummy_boss(200))
	var boss_before: int = combat.boss.hp
	var ok: bool = combat.play_card(0, 0)
	_expect(ok and combat.boss.hp == boss_before - 6 and combat.players[0].energy == 2,
		"play_card spends that player's energy and damages the boss")


func _test_cannot_overspend_energy() -> void:
	var combat := _new_combat([_deck_of(_bash, 10), _deck_of(_bash, 10)], 1, _dummy_boss(200))
	var a: bool = combat.play_card(0, 0)  # cost 2 -> energy 1
	var b: bool = combat.play_card(0, 0)  # cost 2 -> must fail (energy 1)
	_expect(a and not b and combat.players[0].energy == 1, "cannot overspend energy")


func _test_self_block_resets_each_round() -> void:
	var combat := _new_combat([_deck_of(_defend, 10), _deck_of(_defend, 10)], 42, _dummy_boss(200, 7))
	combat.play_card(0, _first_playable(combat, 0))  # +5 block to self
	_expect(combat.players[0].combatant.block == 5, "self block gained")
	combat.end_turn(0)
	combat.end_turn(1)  # both ended -> boss acts -> round 2 begins
	_expect(combat.players[0].combatant.block == 0, "self block resets at the start of the next round")


func _test_assist_shields_ally_not_caster() -> void:
	# Player 0's deck is all Assist; playing it must shield PLAYER 1, not player 0.
	var combat := _new_combat([_deck_of(_assist, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200))
	combat.play_card(0, _first_playable(combat, 0))
	_expect(combat.players[1].combatant.block == 6 and combat.players[0].combatant.block == 0,
		"assist shields the ally, not the caster (co-op combo)")


func _test_boss_targets_telegraphed_player_and_rotates() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(500, 8))
	_expect(combat.boss_target_index() == 0, "boss telegraphs player 1 in round 1")
	combat.end_turn(0)
	combat.end_turn(1)  # boss hits its target (player 0)
	_expect(combat.players[0].combatant.hp == 34 and combat.players[1].combatant.hp == 42,
		"boss hit its telegraphed target only")
	_expect(combat.boss_target_index() == 1, "boss target rotates to player 2 in round 2")


func _test_any_player_death_is_a_loss() -> void:
	var players := [Combatant.new("P1", 1), Combatant.new("P2", 42)]  # P1 is fragile
	var combat := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], players, _dummy_boss(500, 8), 42)
	combat.start()
	combat.end_turn(0)
	combat.end_turn(1)  # boss hits player 0 (1 hp) -> dead
	_expect(combat.is_over() and combat.result() == Combat.Result.LOSE,
		"any player's death ends the run in defeat")


func _test_boss_death_is_a_win() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(6, 8))
	combat.play_card(0, _first_playable(combat, 0))  # 6 damage kills a 6-hp boss
	_expect(combat.is_over() and combat.result() == Combat.Result.WIN, "killing the boss wins")


func _test_boss_waits_for_all_players_to_end() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(500, 8))
	combat.end_turn(0)  # only player 0 ends
	_expect(not combat.is_over() and combat.phase == Combat.Phase.PLAYERS
		and combat.round_num == 1 and combat.players[0].combatant.hp == 42,
		"boss waits until every player has ended")


func _test_deterministic_shuffle_same_seed() -> void:
	var a := _hand_names(_new_combat([_mixed_deck(), _mixed_deck()], 1234, _dummy_boss(200)), 0)
	var b := _hand_names(_new_combat([_mixed_deck(), _mixed_deck()], 1234, _dummy_boss(200)), 0)
	var c := _hand_names(_new_combat([_mixed_deck(), _mixed_deck()], 9999, _dummy_boss(200)), 0)
	_expect(a == b and a != c, "same seed -> same shuffle; different seed -> different")


func _test_full_coop_fight_reaches_terminal_state() -> void:
	var combat := _new_combat([_mixed_deck(), _mixed_deck()], 7, Content.build_boss("stone_warden"))
	var guard := 0
	while not combat.is_over() and guard < 2000:
		guard += 1
		for pi in range(combat.player_count()):
			var idx := _first_playable(combat, pi)
			if idx >= 0:
				combat.play_card(pi, idx)
			else:
				combat.end_turn(pi)
	_expect(combat.is_over() and combat.result() != Combat.Result.ONGOING,
		"a full 2-player fight reaches WIN or LOSE")


func _test_content_loads_from_data() -> void:
	var deck := Content.build_starter_deck()
	var boss := Content.build_boss("stone_warden")
	var has_cover := false
	for c in deck:
		if c.id == "cover":
			has_cover = true
	_expect(deck.size() == 10 and has_cover and boss.name == "The Stone Warden"
		and boss.max_hp > 0 and boss.moves.size() >= 1,
		"content loads the starter deck (with Cover) + Titan from /data")


# --- Step 4: new combo mechanics + titan moves ----------------------------

func _test_rally_gives_ally_energy() -> void:
	var combat := _new_combat([_deck_of(_rally, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200))
	var before: int = combat.players[1].energy
	combat.play_card(0, _first_playable(combat, 0))  # Rally: +1 energy to ally
	_expect(combat.players[1].energy == before + 1, "rally gives the ally +1 energy")


func _test_expose_adds_bonus_damage() -> void:
	var combat := _new_combat([_deck_of(_expose, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200))
	combat.play_card(0, _first_playable(combat, 0))  # Expose: +2 vulnerable
	_expect(combat.boss.vulnerable == 2, "expose adds vulnerable stacks")
	var before: int = combat.boss.hp
	combat.play_card(1, _first_playable(combat, 1))  # Slash 6 + VULN_BONUS 4 = 10
	_expect(combat.boss.hp == before - 10 and combat.boss.vulnerable == 1,
		"an exposed hit deals +4 and consumes one stack")


func _test_taunt_redirects_the_boss() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_taunt, 10)], 42, _dummy_boss(500, 8))
	_expect(combat.boss_target_index() == 0, "default target is hunter 1")
	combat.play_card(1, _first_playable(combat, 1))  # hunter 2 taunts (+6 block, becomes target)
	_expect(combat.boss_target_index() == 1, "taunt redirects the boss to the taunter")
	combat.end_turn(0)
	combat.end_turn(1)  # boss attacks hunter 2 (8 dmg, 6 blocked -> 2 to hp)
	_expect(combat.players[1].combatant.hp == 40 and combat.players[0].combatant.hp == 42,
		"boss hit the taunter (blocked), sparing the ally")


func _test_attack_all_hits_both() -> void:
	var boss := Boss.new("Sweeper", 500)
	boss.moves = [{"type": "attack_all", "value": 5}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.end_turn(0)
	combat.end_turn(1)
	_expect(combat.players[0].combatant.hp == 37 and combat.players[1].combatant.hp == 37,
		"attack_all sweeps both hunters")


func _test_enrage_raises_attack() -> void:
	var boss := Boss.new("Rager", 500)
	boss.moves = [{"type": "enrage", "value": 3}, {"type": "attack", "value": 5}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.end_turn(0)
	combat.end_turn(1)  # round 1: enrage (+3 strength)
	_expect(combat.boss.strength == 3, "enrage raises strength")
	combat.end_turn(0)
	combat.end_turn(1)  # round 2: attack 5 + 3 = 8, targets hunter 2
	_expect(combat.players[1].combatant.hp == 34, "an enraged attack hits harder")


# --- Phase 2: climb / weak-point loop -------------------------------------

func _test_grip_builds_foothold() -> void:
	var combat := _new_combat([_deck_of(_grip, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200))
	combat.play_card(0, _first_playable(combat, 0))  # Grip +2
	var after_one: int = combat.players[0].foothold
	combat.players[0].foothold = Combat.FOOTHOLD_MAX - 1
	combat.play_card(0, _first_playable(combat, 0))  # +2 -> capped
	_expect(after_one == 2 and combat.players[0].foothold == Combat.FOOTHOLD_MAX,
		"grip builds Foothold, capped at max")


func _test_sigil_bonus_requires_climb() -> void:
	var boss := _dummy_boss(300)
	boss.weak_point_height = 3
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var before := combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))  # armored: slash 6 -> chip 1
	_expect(combat.boss.hp == before - 1, "armored hide below the weak point: attacks barely chip")
	combat.players[0].foothold = 3  # reached the sigil
	var before2 := combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))  # reached: 6 + SIGIL_BONUS
	_expect(combat.boss.hp == before2 - (6 + Combat.SIGIL_BONUS),
		"striking the reached sigil deals full damage + bonus")


func _test_exposed_banks_until_climbed() -> void:
	var boss := _dummy_boss(300)
	boss.weak_point_height = 2
	boss.vulnerable = 2
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.play_card(0, _first_playable(combat, 0))  # armored: chips, Exposed NOT spent
	_expect(combat.boss.vulnerable == 2, "Exposed stacks bank while the hide is armored")
	combat.players[0].foothold = 2
	var before := combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))  # reached: 6 + VULN_BONUS + SIGIL_BONUS
	_expect(combat.boss.hp == before - (6 + Combat.VULN_BONUS + Combat.SIGIL_BONUS)
		and combat.boss.vulnerable == 1,
		"the banked Exposed pays off once you reach the weak point")


func _test_height0_titan_no_sigil_bonus() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200))
	combat.players[0].foothold = Combat.FOOTHOLD_MAX  # height 0 -> no high sigil to reach
	var before := combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))
	_expect(combat.boss.hp == before - 6, "a low-sigil Titan gives no climb bonus")


func _test_attack_all_shakes_down_a_hold() -> void:
	var boss := Boss.new("Shaker", 500)
	boss.moves = [{"type": "attack_all", "value": 5}]
	boss.weak_point_height = 6
	boss.ledges = [2, 4]
	var combat := _new_combat([_deck_of(_grip, 10), _deck_of(_grip, 10)], 42, boss)
	combat.players[0].foothold = 4  # upper ledge
	combat.players[1].foothold = 2  # lower ledge
	combat.end_turn(0)
	combat.end_turn(1)  # attack_all -> shake each down a hold
	_expect(combat.players[0].foothold == 2 and combat.players[1].foothold == 0,
		"a sweep shakes each hunter down to the ledge below")


func _climb_boss(height: int) -> Boss:
	# A benign titan (its move does nothing to the hunters) with a high weak point,
	# so grip-upkeep can be tested without the boss's attack skewing HP/foothold.
	var b := Boss.new("Climber", 500)
	b.moves = [{"type": "block", "value": 0}]
	b.weak_point_height = height
	return b


func _test_secure_on_holds() -> void:
	var boss := _climb_boss(6)
	boss.ledges = [2, 4]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	ps.foothold = 0
	var at_base := combat.is_secure(0)
	ps.foothold = 2
	var at_ledge := combat.is_secure(0)
	ps.foothold = 3
	var between := combat.is_secure(0)
	ps.foothold = 6
	var at_sigil := combat.is_secure(0)
	_expect(at_base and at_ledge and not between and at_sigil,
		"secure at base/ledge/sigil, exposed between holds")


func _test_next_safe_height() -> void:
	var boss := _climb_boss(6)
	boss.ledges = [2, 4]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	ps.foothold = 0
	var from_base := combat.next_safe_height(0)  # -> first ledge, 2
	ps.foothold = 3
	var from_mid := combat.next_safe_height(0)   # -> next ledge, 4
	ps.foothold = 5
	var near_top := combat.next_safe_height(0)   # -> the sigil, 6
	_expect(from_base == 2 and from_mid == 4 and near_top == 6,
		"the next safe hold is the ledge (or sigil) above you")


func _test_fall_drops_to_base() -> void:
	var boss := _climb_boss(6)
	boss.ledges = [2, 4]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	ps.foothold = 3  # between holds
	var hp0: int = ps.combatant.hp
	combat.fall(0)
	_expect(ps.foothold == 0 and ps.combatant.hp == hp0 - Combat.FALL_DAMAGE,
		"losing grip drops the hunter to the base with a knock")


func _test_fall_noop_when_secure() -> void:
	var boss := _climb_boss(6)
	boss.ledges = [2, 4]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	ps.foothold = 4  # on a ledge — safe
	var hp0: int = ps.combatant.hp
	combat.fall(0)
	_expect(ps.foothold == 4 and ps.combatant.hp == hp0,
		"a fall report is ignored when the hunter is on a safe hold")


func _test_weakpoint_threshold_bucks() -> void:
	var boss := _climb_boss(6)
	boss.ledges = [2, 4]
	boss.weak_point_threshold = 10
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	ps.foothold = 6  # at the sigil; slash lands 6 + SIGIL_BONUS = 11 >= threshold 10
	combat.play_card(0, _first_playable(combat, 0))
	_expect(ps.foothold == 4 and ps.weak_point_damage == 0,
		"dealing the sigil threshold bucks the hunter down a hold")


func _test_jetpack_prepares_climb() -> void:
	var boss := Boss.new("Jet", 500)
	boss.moves = [{"type": "block", "value": 0}]  # benign enemy turn
	boss.weak_point_height = 4
	var combat := _new_combat([_deck_of(_jetpack, 10), _deck_of(_slash, 10)], 42, boss)
	combat.play_card(0, _first_playable(combat, 0))  # prime the jetpack (not immediate)
	var armed: bool = combat.players[0].prepared == "jetpack" and combat.players[0].foothold == 0
	combat.end_turn(0)
	combat.end_turn(1)  # round turns over -> jetpack fires at next turn's start
	_expect(armed and combat.players[0].foothold == 4 and combat.players[0].prepared == "",
		"Goblin Jetpack arms now and rockets to the weak point next turn")


func _test_grappling_arm_pulls_ally() -> void:
	var combat := _new_combat([_deck_of(_grapple_arm, 10), _deck_of(_slash, 10)], 42, _climb_boss(8))
	combat.players[0].foothold = 4
	combat.players[1].foothold = 2  # gap 2, within reach 3
	combat.play_card(0, _first_playable(combat, 0))
	var pulled: bool = combat.players[1].foothold == 4
	combat.players[0].foothold = 6
	combat.players[1].foothold = 1  # gap 5, out of reach
	combat.play_card(0, _first_playable(combat, 0))
	_expect(pulled and combat.players[1].foothold == 1,
		"Grappling Arm pulls an ally within reach up to you, not one too far below")


func _test_build_mech_scales() -> void:
	var combat := _new_combat([_deck_of(_build_mech, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	combat.play_card(0, _first_playable(combat, 0))  # +2 (base)
	var b1: int = combat.players[0].combatant.block
	combat.play_card(0, _first_playable(combat, 0))  # +4 (grows) -> 6 total
	_expect(b1 == 2 and combat.players[0].combatant.block == 6,
		"Build Mech's Block grows each time it's played this fight")


func _test_burn_coal_exhaust_and_cheapen() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_burn_coal(), _cleave(), _slash()]  # play 0, sacrifice 2, cheapen 1
	ps.energy = 3
	var cleave_before: int = combat.effective_cost(0, ps.hand[1])
	var ok: bool = combat.play_card(0, 0, true, 2, 1)
	_expect(ok and ps.exhaust_pile.size() == 1 and String(ps.exhaust_pile[0].id) == "slash"
		and ps.hand.size() == 1 and String(ps.hand[0].id) == "cleave"
		and combat.effective_cost(0, ps.hand[0]) == cleave_before - 1,
		"Burn Coal exhausts the sacrificed card and permanently cheapens the chosen one")


func _test_catapult_sacrifices_to_launch_ally() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _climb_boss(8))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_catapult(), _slash()]  # play 0, sacrifice 1
	ps.energy = 3
	var ally_before: int = combat.players[1].foothold
	var ok: bool = combat.play_card(0, 0, true, 1, -1)
	_expect(ok and ps.exhaust_pile.size() == 1 and ps.hand.size() == 0
		and combat.players[1].foothold == ally_before + 2,
		"Catapult sacrifices a card to launch the ally up +2 Height")


func _test_satchel_charge_detonates() -> void:
	# The 3-window chain is client-side; core sees one hit/miss. A clean chain (hit)
	# detonates for base + timed_damage; a fizzle (miss) slips away for nothing.
	var combat := _new_combat([_deck_of(_satchel, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var before: int = combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0), true)   # chain landed
	var after_hit: int = combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0), false)  # fizzled
	_expect(before - after_hit == 26 and combat.boss.hp == after_hit,
		"Satchel Charge detonates for 26 on a clean chain; a fizzle does nothing")


func _test_meld_fuses_two_cards() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_meld_card(), _cleave(), _grapple()]  # meld Cleave (1) + Grapple (2)
	ps.energy = 3
	var ok: bool = combat.play_card(0, 0, true, 1, 2)
	var one_card: bool = ps.hand.size() == 1
	var fused: Card = ps.hand[0]
	_expect(ok and one_card and fused.damage == 10 and fused.grip == 1
		and fused.timed and fused.timed_grip == 2 and fused.cost == 1,
		"Meld fuses two cards into one that does both, at cost sum -1")


func _test_timed_damage_bonus() -> void:
	var combat := _new_combat([_deck_of(_pounce, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var before: int = combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0), true)  # timed HIT: 4 + 5 timed_damage
	var hit_hp: int = combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0), false)  # fumble: slips away, no damage
	_expect(before - hit_hp == 9 and combat.boss.hp == hit_hp,
		"a well-timed strike adds timed_damage; a fumble deals nothing")


func _test_sunlight_blade_scales_with_exposed() -> void:
	var combat := _new_combat([_deck_of(_sunblade, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	combat.boss.vulnerable = 2
	var before := combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))  # 5 + 3*2 = 11, +4 exposed = 15
	_expect(combat.boss.hp == before - 15 and combat.boss.vulnerable == 1,
		"Sunlight Blade scales with Exposed and consumes a stack")


func _test_bowshot_deals_and_exposes() -> void:
	var combat := _new_combat([_deck_of(_bowshot, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var before := combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))  # 3 damage, then +1 Exposed
	_expect(combat.boss.hp == before - 3 and combat.boss.vulnerable == 1,
		"Bowshot deals damage and Exposes the Titan")


# --- Step 4: run / meta-progression ---------------------------------------

func _test_run_starts_in_combat() -> void:
	var run := Run.new([_mixed_deck(), _mixed_deck()], ["A", "B"], 5)
	run.start()
	_expect(run.phase == Run.Phase.COMBAT and run.encounter_index == 0
		and run.combat != null, "a run starts fighting the first Titan")


func _test_run_win_flows_through_reward_to_next_encounter() -> void:
	var run := Run.new([_mixed_deck(), _mixed_deck()], ["A", "B"], 5)
	run.start()
	_force_win(run)
	_expect(run.phase == Run.Phase.REWARD
		and run.reward_choices.size() == 2
		and run.reward_choices[0].size() == Run.REWARD_CHOICES,
		"winning a non-final Titan enters the reward phase with choices")
	var deck0_before: int = run.decks[0].size()
	run.pick_reward(0, 0)
	_expect(run.phase == Run.Phase.REWARD, "the run waits for every hunter to pick")
	run.pick_reward(1, 0)
	_expect(run.phase == Run.Phase.COMBAT and run.encounter_index == 1
		and run.decks[0].size() == deck0_before + 1,
		"after all pick, the next encounter starts with the chosen card added")


func _test_run_hp_carries_between_encounters() -> void:
	var run := Run.new([_mixed_deck(), _mixed_deck()], ["A", "B"], 5)
	run.start()
	run.combat.players[0].combatant.hp = 20  # took damage this fight
	_force_win(run)
	run.pick_reward(0, 0)
	run.pick_reward(1, 0)  # -> next encounter starts
	_expect(run.combat.players[0].combatant.hp == 20 + Run.HEAL_BETWEEN,
		"damage carries to the next encounter (plus a small heal)")


func _test_run_defeat_when_a_hunter_falls() -> void:
	var run := Run.new([_mixed_deck(), _mixed_deck()], ["A", "B"], 5)
	run.start()
	run.combat.players[0].combatant.hp = 0
	run.combat.phase = Combat.Phase.OVER
	run.sync()
	_expect(run.phase == Run.Phase.LOST, "a hunter falling loses the whole run")


func _test_content_make_card_and_reward_pool() -> void:
	var card := Content.make_card("rally")
	var pool := Content.reward_pool()
	_expect(card.name == "Rally" and card.ally_energy == 1 and pool.size() >= 3,
		"content builds a card by id and exposes the reward pool")


# --- Phase 3: 3rd titan, relics, longer runs ------------------------------

func _test_regen_heals_titan() -> void:
	var boss := Boss.new("Healer", 100)
	boss.hp = 90
	boss.moves = [{"type": "regen", "value": 30}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.end_turn(0)
	combat.end_turn(1)  # regen 30 -> capped at max 100
	_expect(combat.boss.hp == 100, "regen heals the Titan, capped at max HP")


func _test_relic_energy_bonus() -> void:
	var combat := _relic_combat(1, 0, 0)
	_expect(combat.players[0].energy == Combat.BASE_ENERGY + 1,
		"max_energy relic grants extra energy each round")


func _test_relic_attack_bonus() -> void:
	var combat := _relic_combat(0, 3, 0)
	var before := combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))  # Slash 6 + 3
	_expect(combat.boss.hp == before - 9, "attack_bonus relic adds damage to attacks")


func _test_relic_round_block() -> void:
	var combat := _relic_combat(0, 0, 3)
	_expect(combat.players[0].combatant.block == 3, "round_block relic grants block each round")


func _test_run_is_four_titans() -> void:
	var run := Run.new([_mixed_deck(), _mixed_deck()], ["A", "B"], 5)
	_expect(run.total_encounters() == 4, "a run is four Titans")


func _test_run_relic_reward_and_full_clear() -> void:
	var run := Run.new([_mixed_deck(), _mixed_deck()], ["A", "B"], 5)
	run.start()
	_force_win(run)  # Titan 1 -> card reward
	_expect(run.reward_kind == "card", "first reward is a card")
	_pick_both(run)  # -> Titan 2
	_force_win(run)  # Titan 2 -> relic reward
	_expect(run.reward_kind == "relic" and not run.reward_choices[0].is_empty(),
		"second reward is a relic")
	_pick_both(run)  # 2 team relics -> Titan 3
	_expect(run.team_relics.size() == 2 and run.encounter_index == 2,
		"relics added team-wide; run advances to Titan 3")
	_force_win(run)  # Titan 3 -> card reward
	_pick_both(run)  # -> Titan 4
	_force_win(run)  # Titan 4 -> run won
	_expect(run.phase == Run.Phase.WON, "felling all four Titans wins the run")


func _pick_both(run: Run) -> void:
	run.pick_reward(0, 0)
	run.pick_reward(1, 0)


# --- content batch: strength, wound, multi-hit, leech ---------------------

func _test_strength_mechanic() -> void:
	var combat := _new_combat([_deck_of(_sharpen, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	combat.play_card(0, _first_playable(combat, 0))  # Sharpen +2 Strength
	_expect(combat.players[0].strength == 2, "Sharpen grants Strength")
	combat.players[1].strength = 3
	var before := combat.boss.hp
	combat.play_card(1, _first_playable(combat, 1))  # Slash 6 + 3 Strength
	_expect(combat.boss.hp == before - 9, "Strength adds to attack damage")


func _test_wound_bleeds_the_titan() -> void:
	var boss := Boss.new("Bleeder", 100)
	boss.moves = [{"type": "block", "value": 0}]  # harmless move
	var combat := _new_combat([_deck_of(_rend, 10), _deck_of(_slash, 10)], 42, boss)
	combat.play_card(0, _first_playable(combat, 0))  # Rend: 4 damage + Wound 2
	_expect(combat.boss.wound == 2 and combat.boss.hp == 96, "Rend deals damage and applies Wound")
	combat.end_turn(0)
	combat.end_turn(1)  # enemy turn: bleed 2
	_expect(combat.boss.hp == 94, "Wound bleeds at the start of the Titan's turn")


func _test_flurry_multi_hit() -> void:
	var combat := _new_combat([_deck_of(_flurry, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var before := combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))  # 4 x2 = 8
	_expect(combat.boss.hp == before - 8, "Flurry deals its damage twice")
	var c2 := _new_combat([_deck_of(_flurry, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	c2.boss.vulnerable = 2
	var b2 := c2.boss.hp
	c2.play_card(0, _first_playable(c2, 0))  # (4+4)+(4+4) = 16, vulnerable 2->0
	_expect(c2.boss.hp == b2 - 16 and c2.boss.vulnerable == 0,
		"each Flurry hit can strike an Exposed weak point")


func _test_leech_drains_and_heals() -> void:
	var boss := Boss.new("Leech", 100)
	boss.hp = 50
	boss.moves = [{"type": "leech", "value": 12}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.end_turn(0)
	combat.end_turn(1)  # leech hits hunter 1 for 12, Titan heals 12
	_expect(combat.players[0].combatant.hp == 30 and combat.boss.hp == 62,
		"leech drains a hunter and heals the Titan")


func _test_relic_start_strength() -> void:
	var players := [Combatant.new("A", 42), Combatant.new("B", 42)]
	var combat := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], players,
		_dummy_boss(300), 42, 0, 0, 0, 2)  # start_strength = 2
	combat.start()
	_expect(combat.players[0].strength == 2, "start_strength relic begins the fight with Strength")


# --- Characters (per-player climb + signature passives) -------------------

func _new_combat_p(decks: Array, seed_value: int, boss: Boss, passives: Array) -> Combat:
	var players := [Combatant.new("P1", 42), Combatant.new("P2", 42)]
	var c := Combat.new(decks, players, boss, seed_value, 0, 0, 0, 0, passives)
	c.start()
	return c


func _test_frog_climb_bonus() -> void:
	var combat := _new_combat_p([_deck_of(_scramble, 10), _deck_of(_slash, 10)], 42,
		_dummy_boss(200), [{"type": "climb_bonus", "value": 1}, {}])
	combat.play_card(0, _first_playable(combat, 0))  # Scramble grip 1 + climb_bonus 1
	_expect(combat.players[0].foothold == 2, "Frog's climb_bonus adds Height to each climb")


func _test_vine_lifts_ally() -> void:
	var combat := _new_combat_p([_deck_of(_vine, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200), [{}, {}])
	combat.play_card(0, _first_playable(combat, 0))  # Vine: self +1, ally +2
	_expect(combat.players[0].foothold == 1 and combat.players[1].foothold == 2,
		"Vine climbs the caster and lifts the ally")


func _test_roped_ally_climbs() -> void:
	var combat := _new_combat_p([_deck_of(_scramble, 10), _deck_of(_slash, 10)], 42,
		_dummy_boss(200), [{"type": "ally_climb", "value": 1}, {}])
	combat.play_card(0, _first_playable(combat, 0))  # Scramble +1; roped -> ally +1
	_expect(combat.players[0].foothold == 1 and combat.players[1].foothold == 1,
		"roped: when a Mountain Climber climbs, the ally climbs too")


func _test_character_attack_bonus() -> void:
	var combat := _new_combat_p([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42,
		_dummy_boss(200), [{"type": "attack_bonus", "value": 2}, {}])
	var before := combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))  # Slash 6 + 2
	_expect(combat.boss.hp == before - 8, "Goblin Mech's attack_bonus adds to attacks")


func _test_build_creates_grapple() -> void:
	var combat := _new_combat_p([_deck_of(_build, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200), [{}, {}])
	combat.play_card(0, _first_playable(combat, 0))  # Build Grapple -> adds a Grappling Hook
	var has_grapple := false
	for c in combat.players[0].hand:
		if c.id == "grapple":
			has_grapple = true
	_expect(has_grapple, "Build creates a Grappling Hook in hand")


func _test_belay_scales_with_height() -> void:
	var combat := _new_combat_p([_deck_of(_belay, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200), [{}, {}])
	combat.players[0].foothold = 3
	var before := combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))  # Belay 3 + 2*3 = 9 (height-0 boss, full)
	_expect(combat.boss.hp == before - 9, "Belay Strike scales with the hunter's Height")


func _test_timed_grapple() -> void:
	var hit := _new_combat([_deck_of(_grapple, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200))
	hit.play_card(0, _first_playable(hit, 0), true)  # nailed the timing
	_expect(hit.players[0].foothold == 3, "a well-timed grapple climbs +3")
	var miss := _new_combat([_deck_of(_grapple, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200))
	var hand_before: int = miss.players[0].hand.size()
	var discard_before: int = miss.players[0].discard_pile.size()
	miss.play_card(0, _first_playable(miss, 0), false)  # fumbled -> slips away
	_expect(miss.players[0].foothold == 0
		and miss.players[0].hand.size() == hand_before - 1
		and miss.players[0].discard_pile.size() == discard_before,
		"a fumbled grapple gives nothing and vanishes (not even discarded)")


func _test_content_builds_character() -> void:
	var deck := Content.character_deck("frog")
	var passive := Content.character_passive("frog")
	_expect(deck.size() == 10 and String(passive["type"]) == "climb_bonus"
		and int(passive["value"]) == 1 and String(passive["character"]) == "frog",
		"content builds a character's deck + signature passive")


# --- Session / client-server split ----------------------------------------

# Loopback is synchronous: after each client call the client snapshots are
# already up to date (command -> host -> broadcast -> clients, in one frame).
func _make_session(seed_value: int = 42) -> Dictionary:
	var transport := LocalTransport.new()
	var host := GameHost.new(transport, seed_value, 2)
	var c0 := GameClient.new(transport, 10)
	var c1 := GameClient.new(transport, 20)
	_kept.append(host)
	c0.join()  # slot 0
	c1.join()  # slot 1 — both joined, now in character select
	c0.select_character("frog")
	c1.select_character("mountain_climbers")  # both chosen -> host starts the run
	return {"transport": transport, "host": host, "c0": c0, "c1": c1}


func _test_session_both_players_join() -> void:
	var s := _make_session()
	var c0: GameClient = s["c0"]
	var c1: GameClient = s["c1"]
	_expect(not bool(c0.shared.get("waiting", true))
		and c0.you == 0 and c1.you == 1
		and c0.shared["players"].size() == 2
		and c0.private["hand"].size() == Combat.HAND_SIZE
		and c1.private["hand"].size() == Combat.HAND_SIZE,
		"both players join: own slot, shared board of 2, own 5-card hand")


func _test_session_lobby_waits_for_second_player() -> void:
	var transport := LocalTransport.new()
	var host := GameHost.new(transport, 42, 2)
	_kept.append(host)
	var c0 := GameClient.new(transport, 10)
	c0.join()
	_expect(bool(c0.shared.get("waiting", false))
		and int(c0.shared.get("joined", 0)) == 1
		and int(c0.shared.get("required", 0)) == 2
		and c0.private.get("hand", []).is_empty(),
		"lobby waits for the second player before combat starts")


func _test_session_shared_board_syncs_across_players() -> void:
	var s := _make_session()
	var c0: GameClient = s["c0"]
	var c1: GameClient = s["c1"]
	c1.play_card(_first_playable_client(c1))
	# c0 and c1 share one board: player 2's spent energy shows on player 1's view.
	_expect(int(c0.shared["players"][1]["energy"]) < Combat.BASE_ENERGY,
		"player 2's action is reflected on player 1's shared board")


func _test_session_end_turn_needs_all_players() -> void:
	var s := _make_session()
	var c0: GameClient = s["c0"]
	var c1: GameClient = s["c1"]
	c0.end_turn()
	_expect(bool(c0.shared["players"][0]["ended"])
		and not bool(c0.shared["players"][1]["ended"])
		and int(c0.shared["round"]) == 1,
		"one player ending does not advance the round")
	c1.end_turn()
	_expect(bool(c1.shared["over"]) or int(c1.shared["round"]) == 2,
		"both players ending advances the round (boss acts)")


func _test_session_private_view_is_isolated() -> void:
	var s := _make_session()
	var eavesdropper := GameClient.new(s["transport"], 999)  # never joins (lobby full)
	(s["c0"] as GameClient).play_card(_first_playable_client(s["c0"]))
	_expect(eavesdropper.shared.is_empty() and eavesdropper.private.is_empty(),
		"a non-joined peer receives no shared or private state")


func _test_solo_controls_both_hunters() -> void:
	var t := LocalTransport.new()
	var host := GameHost.new(t, 42, 2, true)  # solo
	_kept.append(host)
	var c := GameClient.new(t, 1)
	c.join()  # enters the solo character-select lobby
	_expect(bool(c.shared.get("solo", false)) and int(c.shared.get("current_slot", -1)) == 0,
		"solo lobby asks for hunter 1 first")
	c.select_character("frog", 0)
	_expect(int(c.shared.get("current_slot", -1)) == 1, "after hunter 1, solo asks for hunter 2")
	c.select_character("goblin_mech", 1)  # both chosen -> run starts
	var slots: Array = c.private.get("slots", [])
	_expect(bool(c.private.get("solo", false)) and slots.size() == 2
		and slots[0]["hand"].size() == Combat.HAND_SIZE
		and slots[1]["hand"].size() == Combat.HAND_SIZE,
		"solo: the one client receives BOTH hunters' hands")
	var energy_before: int = c.shared["players"][1]["energy"]
	var idx := -1
	for card in slots[1]["hand"]:
		if bool(card["playable"]) and int(card.get("cost", 0)) > 0:  # one that spends energy
			idx = int(card["index"])
			break
	c.play_card(idx, true, 1)  # act as hunter 2
	_expect(int(c.shared["players"][1]["energy"]) < energy_before,
		"solo: a command with slot=1 acts on hunter 2")


func _test_host_pauses_on_disconnect() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	var transport: LocalTransport = s["transport"]
	_expect(not host.paused, "run is not paused initially")
	transport.emit_signal("peer_left", 20)  # hunter 2 (peer 20) drops
	_expect(host.paused and bool(c0.shared.get("paused", false)),
		"host pauses and broadcasts when a hunter drops")
	var energy_before: int = c0.shared["players"][0]["energy"]
	c0.play_card(_first_playable_client(c0))
	_expect(int(c0.shared["players"][0]["energy"]) == energy_before,
		"commands are ignored while paused")


# --- helpers --------------------------------------------------------------

func _new_combat(decks: Array, seed_value: int, boss: Boss) -> Combat:
	var players := [Combatant.new("P1", 42), Combatant.new("P2", 42)]
	var c := Combat.new(decks, players, boss, seed_value)
	c.start()
	return c


func _dummy_boss(hp: int, value: int = 8) -> Boss:
	var b := Boss.new("Dummy", hp)
	b.moves = [{"type": "attack", "value": value}]
	return b


## A started 2-player Combat with the given relic modifiers applied.
func _relic_combat(energy_bonus: int, attack_bonus: int, round_block: int) -> Combat:
	var players := [Combatant.new("A", 42), Combatant.new("B", 42)]
	var combat := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], players,
		_dummy_boss(300), 42, energy_bonus, attack_bonus, round_block)
	combat.start()
	return combat


## Force the current encounter to a WIN and advance run state.
func _force_win(run: Run) -> void:
	run.combat.boss.hp = 0
	run.combat.phase = Combat.Phase.OVER
	run.sync()


func _first_playable(combat: Combat, pi: int) -> int:
	var ps: PlayerState = combat.players[pi]
	for i in range(ps.hand.size()):
		if combat.can_play(pi, i):
			return i
	return -1


func _first_playable_client(client: GameClient) -> int:
	for c in client.private.get("hand", []):
		if bool(c["playable"]):
			return int(c["index"])
	return -1


func _hand_names(combat: Combat, pi: int) -> Array:
	var names: Array = []
	for c in combat.players[pi].hand:
		names.append(c.name)
	return names


func _deck_of(maker: Callable, n: int) -> Array:
	var d: Array = []
	for _i in n:
		d.append(maker.call())
	return d


func _mixed_deck() -> Array:
	return [_slash(), _slash(), _slash(), _slash(),
		_defend(), _defend(), _defend(), _focus(), _bash(), _assist()]


func _slash() -> Card:
	return Card.from_dict({"id": "slash", "name": "Slash", "type": "attack", "cost": 1, "damage": 6})
func _defend() -> Card:
	return Card.from_dict({"id": "brace", "name": "Brace", "type": "skill", "cost": 1, "block": 5})
func _bash() -> Card:
	return Card.from_dict({"id": "cleave", "name": "Cleave", "type": "attack", "cost": 2, "damage": 10})
func _focus() -> Card:
	return Card.from_dict({"id": "take_aim", "name": "Take Aim", "type": "skill", "cost": 1, "draw": 2})
func _assist() -> Card:
	return Card.from_dict({"id": "cover", "name": "Cover", "type": "skill", "cost": 1, "ally_block": 6, "target": "ally"})
func _rally() -> Card:
	return Card.from_dict({"id": "rally", "name": "Rally", "type": "skill", "cost": 1, "ally_energy": 1, "target": "ally"})
func _expose() -> Card:
	return Card.from_dict({"id": "expose", "name": "Expose", "type": "skill", "cost": 1, "vulnerable": 2, "target": "enemy"})
func _taunt() -> Card:
	return Card.from_dict({"id": "draw_aggro", "name": "Draw Aggro", "type": "skill", "cost": 1, "taunt": true, "block": 6})
func _grip() -> Card:
	return Card.from_dict({"id": "grip", "name": "Grip", "type": "skill", "cost": 1, "grip": 2, "target": "enemy"})
func _scramble() -> Card:
	return Card.from_dict({"id": "scramble", "name": "Scramble", "type": "skill", "cost": 0, "grip": 1, "target": "enemy"})
func _vine() -> Card:
	return Card.from_dict({"id": "vine", "name": "Vine", "type": "skill", "cost": 1, "grip": 1, "ally_grip": 2, "target": "ally"})
func _build() -> Card:
	return Card.from_dict({"id": "build_grapple", "name": "Build Grapple", "type": "skill", "cost": 0, "create": "grapple"})
func _belay() -> Card:
	return Card.from_dict({"id": "belay_strike", "name": "Belay Strike", "type": "attack", "cost": 1, "damage": 3, "damage_per_foothold": 2})
func _grapple() -> Card:
	return Card.from_dict({"id": "grapple", "name": "Grappling Hook", "type": "skill", "cost": 0, "grip": 1, "timed": true, "timed_grip": 2, "target": "enemy"})
func _pounce() -> Card:
	return Card.from_dict({"id": "pounce", "name": "Pounce", "type": "attack", "cost": 1, "damage": 4, "grip": 1, "timed": true, "timed_damage": 5, "target": "enemy"})
func _jetpack() -> Card:
	return Card.from_dict({"id": "goblin_jetpack", "name": "Goblin Jetpack", "type": "skill", "cost": 2, "prepare": "jetpack", "target": "enemy"})
func _grapple_arm() -> Card:
	return Card.from_dict({"id": "grappling_arm", "name": "Grappling Arm", "type": "skill", "cost": 1, "pull_ally": 3, "target": "ally"})
func _build_mech() -> Card:
	return Card.from_dict({"id": "build_mech", "name": "Build Mech", "type": "skill", "cost": 1, "block": 2, "block_per_play": 2})
func _cleave() -> Card:
	return Card.from_dict({"id": "cleave", "name": "Cleave", "type": "attack", "cost": 2, "damage": 10})
func _burn_coal() -> Card:
	return Card.from_dict({"id": "burn_coal", "name": "Burn Coal", "type": "skill", "cost": 1, "exhaust_pick": true, "cheapen_pick": true, "cheapen_amount": 1})
func _catapult() -> Card:
	return Card.from_dict({"id": "catapult", "name": "Catapult", "type": "skill", "cost": 1, "exhaust_pick": true, "sac_ally_grip": 2, "target": "ally"})
func _meld_card() -> Card:
	return Card.from_dict({"id": "meld", "name": "Meld", "type": "skill", "cost": 1, "meld": true})
func _satchel() -> Card:
	return Card.from_dict({"id": "satchel_charge", "name": "Satchel Charge", "type": "attack", "cost": 2, "damage": 6, "timed": true, "timed_hits": 3, "timed_damage": 20, "target": "enemy"})
func _sunblade() -> Card:
	return Card.from_dict({"id": "sunlight_blade", "name": "Sunlight Blade", "type": "attack", "cost": 1, "damage": 5, "damage_per_vulnerable": 3})
func _bowshot() -> Card:
	return Card.from_dict({"id": "bowshot", "name": "Bowshot", "type": "attack", "cost": 0, "damage": 3, "vulnerable": 1})
func _sharpen() -> Card:
	return Card.from_dict({"id": "sharpen", "name": "Sharpen", "type": "skill", "cost": 1, "strength": 2})
func _rend() -> Card:
	return Card.from_dict({"id": "rend", "name": "Rend", "type": "attack", "cost": 1, "damage": 4, "wound": 2})
func _flurry() -> Card:
	return Card.from_dict({"id": "flurry", "name": "Flurry", "type": "attack", "cost": 2, "damage": 4, "hits": 2})


func _expect(cond: bool, name: String) -> void:
	if cond:
		print("PASS  " + name)
	else:
		print("FAIL  " + name)
		_failures += 1
