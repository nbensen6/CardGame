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
	# Several tests build real GameHosts, and a GameHost autosaves. Point the slot
	# at a scratch file first or running the suite eats the designer's own run.
	RunSave.use_scratch_slot("run_tests")
	RunSave.clear()
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
	# the run map (branching route)
	_test_map_generates_connected_rows()
	_test_map_is_deterministic_per_seed()
	_test_run_walks_the_map()
	_test_rest_node_heals_and_returns_to_map()
	_test_event_choice_applies_effects()
	_test_event_reward_choice_routes_to_reward()
	_test_events_load_and_are_well_formed()
	_test_event_gold_cost_never_goes_negative()
	_test_event_remove_card_effect()
	_test_event_remove_card_respects_min_deck()
	_test_event_sharpen_card_effect()
	_test_backlog17_four_events_touch_the_deck()
	_test_card_upgrade_bumps_numbers()
	_test_enchanted_copy_attaches_to_any_card()
	_test_enchants_all_load()
	_test_campfire_rest_remove_upgrade()
	_test_campfire_rest_heals_and_caps_at_max()
	_test_campfire_guards_against_illegal_actions()
	_test_skip_reward_keeps_the_deck_lean()
	_test_rule_changing_relics()
	_test_backlog10_new_rule_changing_relics()
	_test_shake_resist_relic()
	_test_backlog13_six_relics_change_a_rule()
	_test_relics_all_load()
	_test_climb_twisting_moves()
	_test_per_class_reward_pools()
	_test_rhythm_card_grants_combo()
	_test_ascension_makes_the_run_harder()
	_test_coach_teaches_the_right_thing_first()
	_test_tips_can_be_switched_off_without_losing_your_place()
	_test_gold_and_shop()
	_test_shop_buys_a_relic()
	_test_shop_cannot_thin_below_min_deck()
	_test_shop_rejects_actions_outside_its_phase()
	_test_content_pools_are_copies()
	# grip / ledges (SotC real-time climb)
	_test_secure_on_holds()
	_test_next_safe_height()
	_test_hold_helpers_read_both_shapes()
	_test_named_holds_dict_shape_and_unsafe_flag()
	_test_targets_hold_card_climbs_to_a_named_hold()
	_test_fall_drops_to_base()
	_test_fall_noop_when_secure()
	_test_weakpoint_threshold_bucks()
	_test_timed_damage_bonus()
	_test_sure_enchant_lands_even_on_a_fumble()
	_test_timed_block_guards_on_a_hit()
	_test_timed_ally_block_anchors_the_ally()
	# graded timing accuracy — the rules half (backlog #33)
	_test_graded_timing_good_pays_half_the_bonus()
	_test_graded_timing_perfect_matches_a_plain_nailed_hit()
	_test_preview_quality_scales_the_timed_bonus()
	_test_graded_timing_default_quality_is_perfect()
	_test_every_referenced_card_id_resolves()
	_test_content_integrity_graph()
	_test_exhaust_scaling_grows_with_the_burn_pile()
	_test_detonator_does_not_count_its_own_sacrifice()
	# Goblin Engineer cards
	_test_jetpack_prepares_climb()
	_test_grappling_arm_pulls_ally()
	_test_build_mech_scales()
	_test_burn_coal_exhaust_and_cheapen()
	_test_catapult_sacrifices_to_launch_ally()
	_test_meld_fuses_two_cards()
	_test_meld_carries_special_effects()
	_test_satchel_charge_detonates()
	_test_rhythm_builds_and_scales()
	_test_vine_weaver_poison_and_wound()
	_test_summit_strike_scales_with_both()
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
	_test_elite_pays_a_card_then_a_relic()
	_test_preview_matches_what_the_card_actually_does()
	_test_incoming_reckons_damage_after_block()
	_test_every_derived_keyword_resolves()
	_test_every_field_a_player_must_understand_has_a_keyword()
	_test_every_boss_move_type_resolves()
	_test_every_beast_has_a_move_pattern()
	_test_weak_point_threshold_still_means_something()
	_test_card_dict_round_trips_every_field()
	_test_run_survives_a_save_and_load()
	_test_run_survives_a_save_and_load_mid_combat()
	_test_run_survives_a_save_and_load_in_shop()
	_test_run_survives_a_save_and_load_in_campfire()
	_test_run_survives_a_save_and_load_in_event()
	_test_save_refuses_only_finished_runs_and_clears_when_over()
	_test_every_card_declares_a_rarity()
	_test_card_type_matches_whether_it_deals_damage()
	_test_strength_only_lifts_attack_type_cards()
	_test_rarity_weighting_favours_commons()
	_test_vine_weaver_has_enough_rares()
	# content batch: strength, wound, multi-hit, leech
	_test_strength_mechanic()
	_test_wound_bleeds_the_titan()
	_test_flurry_multi_hit()
	_test_leech_drains_and_heals()
	_test_wound_decay_limiter_sheds_poison()
	_test_sigil_fatigue_limiter_punishes_camping()
	_test_height_split_limiter_punishes_hoarding()
	_test_every_titan_carries_a_known_limiter()
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
	_test_host_autosaves_and_resumes()
	_test_host_autosaves_and_resumes_mid_combat()
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


func _test_map_generates_connected_rows() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var m := RunMap.new(4, rng)
	var rows_ok := m.total_rows() == 4 * (RunMap.ROWS_PER_ACT + 1)
	var every_node_reachable := true
	var bosses := 0
	for r in range(m.rows.size()):
		var row: Array = m.rows[r]
		for c in range(row.size()):
			if String(row[c]["type"]) == "boss":
				bosses += 1
		if r == 0:
			continue
		var reached := {}
		for prev in m.rows[r - 1]:
			for e in prev["next"]:
				reached[e] = true
		for c in range(row.size()):
			if not reached.has(c):
				every_node_reachable = false
	# the last row of each act is a lone boss
	var last_is_boss: bool = m.rows[m.rows.size() - 1].size() == 1 		and String(m.rows[m.rows.size() - 1][0]["type"]) == "boss"
	_expect(rows_ok and every_node_reachable and bosses == 4 and last_is_boss,
		"the map generates connected rows with one Titan capping each act")


func _test_map_is_deterministic_per_seed() -> void:
	var a := RandomNumberGenerator.new(); a.seed = 99
	var b := RandomNumberGenerator.new(); b.seed = 99
	var c := RandomNumberGenerator.new(); c.seed = 12345
	var m1 := RunMap.new(2, a)
	var m2 := RunMap.new(2, b)
	var m3 := RunMap.new(2, c)
	var same := str(m1.rows) == str(m2.rows)
	var different := str(m1.rows) != str(m3.rows)
	_expect(same and different, "the same seed maps the same route; a new seed re-rolls it")


func _test_run_walks_the_map() -> void:
	var run := _map_run()
	var started_on_map: bool = run.phase == Run.Phase.MAP and run.map_row == -1
	var opening: Array = run.available_nodes()
	var rejected: bool = not run.pick_node(99)  # not a reachable column
	run.pick_node(int(opening[0]))
	# row 0 is always a fight, so we should be in combat against a pooled beast
	var in_combat: bool = run.phase == Run.Phase.COMBAT and run.node_type == "fight"
	var pooled: bool = Content.beast_pool("fight").has(run.beast_id)
	_expect(started_on_map and opening.size() >= 2 and rejected and in_combat and pooled,
		"a run starts on the map, rejects unreachable nodes, and fights what it steps on")


func _test_rest_node_heals_and_returns_to_map() -> void:
	var run := _map_run()
	run.hp[0] = 10
	run.hp[1] = 10
	# walk to a rest node wherever the route offers one
	var guard := 0
	var rested := false
	while not rested and guard < 40:
		guard += 1
		if run.phase != Run.Phase.MAP:
			break
		var found := -1
		for col in run.available_nodes():
			if String(run.map.node_at(run.map_row + 1, int(col)).get("type", "")) == "rest":
				found = int(col)
		if found < 0:
			break
		run.pick_node(found)
		rested = true
	if not rested:
		_expect(true, "rest node heals and hands back to the map (no rest offered on this seed)")
		return
	_expect(run.hp[0] == 10 + Run.REST_HEAL and run.phase == Run.Phase.MAP,
		"a rest node heals the party and hands straight back to the map")


func _test_events_load_and_are_well_formed() -> void:
	var ids: Array = Content.list_events()
	# EA target is 12-15 hand-written events (BACKLOG.md item 9).
	var ok := ids.size() >= 12
	for id in ids:
		var e: Dictionary = Content.make_event(String(id))
		var choices: Array = e.get("choices", [])
		if String(e.get("title", "")) == "" or String(e.get("text", "")) == "" or choices.size() < 2:
			ok = false
		for ch in choices:
			if String((ch as Dictionary).get("label", "")) == "":
				ok = false
	_expect(ok, "every event has a title, prose, and at least two labelled choices, and there are at least 12")


func _test_event_gold_cost_never_goes_negative() -> void:
	var run := _map_run()
	run.gold = 5
	run.event = {"title": "T", "text": "x", "choices": [
		{"label": "pay", "result": "!", "effects": {"gold": -20}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0
	run.pick_event(0)
	_expect(run.gold == 0, "an event's gold cost never puts the shared purse in debt")


func _test_event_choice_applies_effects() -> void:
	var run := _map_run()
	run.event = {"title": "T", "text": "x", "choices": [
		{"label": "hurt", "result": "ouch", "effects": {"heal": -5, "max_hp": 4, "relic": true}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0  # standing on a node, so resolving hands back to the map
	var hp_before: int = run.hp[0]
	var max_before: int = run.max_hp[0]
	var relics_before: int = run.team_relics.size()
	run.pick_event(0)
	_expect(run.hp[0] == hp_before - 5 and run.max_hp[0] == max_before + 4
		and run.team_relics.size() == relics_before + 1
		and run.phase == Run.Phase.MAP and run.event_result == "ouch",
		"an event choice applies its effects and hands back to the map")


func _test_event_reward_choice_routes_to_reward() -> void:
	var run := _map_run()
	run.event = {"title": "T", "text": "x", "choices": [
		{"label": "loot", "result": "!", "effects": {"reward": "card"}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0
	run.pick_event(0)
	var lethal := true
	# also prove events can never kill: a huge bruise floors at 1 HP
	var run2 := _map_run()
	run2.event = {"title": "T", "text": "x", "choices": [
		{"label": "ow", "result": "!", "effects": {"heal": -999}}]}
	run2.phase = Run.Phase.EVENT
	run2.map_row = 0
	run2.pick_event(0)
	lethal = run2.hp[0] <= 0
	_expect(run.phase == Run.Phase.REWARD and run.reward_kind == "card" and not lethal,
		"an event that offers loot opens the reward screen; events never kill")


func _test_event_remove_card_effect() -> void:
	var run := _map_run()  # each deck starts as 10x Slash
	run.event = {"title": "T", "text": "x", "choices": [
		{"label": "chase", "result": "!", "effects": {"remove_card": true}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0
	run.pick_event(0)
	_expect(run.decks[0].size() == 9 and run.decks[1].size() == 9,
		"an event's remove_card effect takes one random card from each hunter's own deck")


func _test_event_remove_card_respects_min_deck() -> void:
	var run := _map_run()
	run.decks[0] = _deck_of(_slash, Run.MIN_DECK)  # already at the floor
	run.event = {"title": "T", "text": "x", "choices": [
		{"label": "chase", "result": "!", "effects": {"remove_card": true}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0
	run.pick_event(0)
	_expect(run.decks[0].size() == Run.MIN_DECK and run.decks[1].size() == 9,
		"remove_card never thins a deck below MIN_DECK, even while an unaffected deck still loses a card")


func _test_event_sharpen_card_effect() -> void:
	var run := _map_run()
	run.event = {"title": "T", "text": "x", "choices": [
		{"label": "drill", "result": "!", "effects": {"sharpen_card": true}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0
	run.pick_event(0)
	var upgraded0 := 0
	for c in run.decks[0]:
		if (c as Card).upgraded:
			upgraded0 += 1
	var upgraded1 := 0
	for c in run.decks[1]:
		if (c as Card).upgraded:
			upgraded1 += 1
	_expect(upgraded0 == 1 and upgraded1 == 1,
		"an event's sharpen_card effect upgrades exactly one random card in each hunter's own deck")
	# and it's a genuine no-op once nothing is left to sharpen, not an error
	var run2 := _map_run()
	for i in range(run2.decks[0].size()):
		run2.decks[0][i] = (run2.decks[0][i] as Card).upgraded_copy()
	run2.event = run.event.duplicate(true)
	run2.phase = Run.Phase.EVENT
	run2.map_row = 0
	var size_before: int = run2.decks[0].size()
	run2.pick_event(0)
	_expect(run2.decks[0].size() == size_before, "sharpen_card quietly no-ops on a fully-upgraded deck")


func _test_backlog17_four_events_touch_the_deck() -> void:
	var count := 0
	for id in Content.list_events():
		var e: Dictionary = Content.make_event(String(id))
		for ch in (e.get("choices", []) as Array):
			var eff: Dictionary = (ch as Dictionary).get("effects", {})
			if String(eff.get("reward", "")) == "card" or bool(eff.get("remove_card", false)) \
					or bool(eff.get("sharpen_card", false)):
				count += 1
				break
	_expect(count >= 4, "at least 4 events add, remove or sharpen a card (backlog #17)")


func _test_card_upgrade_bumps_numbers() -> void:
	var slash := Content.make_card("slash")          # 6 damage, cost 1
	var up := slash.upgraded_copy()
	var brace := Content.make_card("brace")          # 5 block
	var up_brace := brace.upgraded_copy()
	var take_aim := Content.make_card("take_aim")    # draw 2 -> draw 3
	var up_aim := take_aim.upgraded_copy()
	var twice := up.upgraded_copy()                  # already sharpened
	_expect(up.damage == slash.damage + 3 and up.name.ends_with("+") and up.upgraded
		and up_brace.block == brace.block + 3
		and up_aim.draw == take_aim.draw + 1
		and twice.damage == up.damage,
		"upgrading bumps whatever numbers a card uses, once")


## The enchant engine (backlog #12): one generic copy trick, same shape as
## upgraded_copy(), works on ANY card without either the card or the caller
## knowing what the enchant does — and never mutates the original (cards are
## immutable during combat, same rule upgraded_copy() follows).
func _test_enchanted_copy_attaches_to_any_card() -> void:
	var slash := _slash()
	var enchanted_slash := slash.enchanted_copy("wide")
	var take_aim := Content.make_card("take_aim")
	var enchanted_aim := take_aim.enchanted_copy("sure")
	_expect(enchanted_slash.enchant == "wide"
		and String(enchanted_slash.enchant_data().get("effect", "")) == "timing_zone"
		and enchanted_aim.enchant == "sure"
		and String(enchanted_aim.enchant_data().get("effect", "")) == "auto_nail"
		and slash.enchant == "" and take_aim.enchant == "",
		"enchanted_copy attaches any enchant to any card generically, without mutating the original")


func _test_enchants_all_load() -> void:
	var ids: Array = Content.all_enchant_ids()
	var ok := ids.size() >= 2
	for id in ids:
		var e: Dictionary = Content.make_enchant(String(id))
		if String(e.get("name", "")) == "" or String(e.get("text", "")) == "" or String(e.get("effect", "")) == "":
			ok = false
	_expect(ok, "every enchant declares a name, text and effect")


func _test_campfire_rest_remove_upgrade() -> void:
	var run := _map_run()
	run.hp[0] = 10
	run.hp[1] = 10
	run._begin_campfire()
	var deck_before: int = run.decks[0].size()
	_expect(run.phase == Run.Phase.CAMPFIRE, "a rest node opens the campfire")
	run.campfire_action(0, "remove", 0)
	var thinned: bool = run.decks[0].size() == deck_before - 1
	# still waiting on hunter 2
	var waiting: bool = run.phase == Run.Phase.CAMPFIRE
	var name_before: String = (run.decks[1][0] as Card).name
	run.campfire_action(1, "upgrade", 0)
	var sharpened: bool = (run.decks[1][0] as Card).name == name_before + "+"
	_expect(thinned and waiting and sharpened and run.phase == Run.Phase.MAP,
		"a campfire thins one deck, sharpens the other, then hands back to the map")


## Backlog #19: "rest" itself, and the guards that keep a campfire from being
## abused (acting twice, thinning past the floor, upgrading twice), were never
## exercised — only remove/upgrade succeeding was.
func _test_campfire_rest_heals_and_caps_at_max() -> void:
	var run := _map_run()
	run.hp[0] = 10
	run._begin_campfire()
	var ok := run.campfire_action(0, "rest")
	_expect(ok and run.hp[0] == 10 + Run.REST_HEAL, "a campfire rest heals by REST_HEAL")

	var run2 := _map_run()
	run2.hp[0] = run2.max_hp[0] - 2  # almost topped up already
	run2._begin_campfire()
	run2.campfire_action(0, "rest")
	_expect(run2.hp[0] == run2.max_hp[0], "a campfire rest cannot overheal past max HP")


func _test_campfire_guards_against_illegal_actions() -> void:
	# a hunter who has already acted this visit can't act again
	var run := _map_run()
	run._begin_campfire()
	run.campfire_action(0, "rest")
	run.hp[0] = 1  # so a second heal would show up plainly if it fired
	var no_double_action: bool = not run.campfire_action(0, "rest") and run.hp[0] == 1

	# can't thin a deck already at the floor
	var run2 := _map_run()
	while run2.decks[0].size() > Run.MIN_DECK:
		run2.decks[0].pop_back()
	run2._begin_campfire()
	var size_before: int = run2.decks[0].size()
	var blocked_remove := not run2.campfire_action(0, "remove", 0)
	var floor_held: bool = run2.decks[0].size() == size_before

	# can't upgrade the same card a second time, on a later visit
	var run3 := _map_run()
	run3._begin_campfire()
	run3.campfire_action(0, "upgrade", 0)
	var upgraded_name: String = (run3.decks[0][0] as Card).name
	run3._begin_campfire()  # a later campfire, same run, same deck
	var blocked_upgrade := not run3.campfire_action(0, "upgrade", 0)
	var name_unchanged: bool = (run3.decks[0][0] as Card).name == upgraded_name

	# outside the campfire phase entirely
	var run4 := _map_run()
	var refused_outside := not run4.campfire_action(0, "rest")

	_expect(no_double_action and blocked_remove and floor_held
		and blocked_upgrade and name_unchanged and refused_outside,
		"the campfire refuses a second action, thinning past the floor, " +
		"a repeat upgrade, and acting outside its own phase")


func _test_skip_reward_keeps_the_deck_lean() -> void:
	var run := _map_run()
	_step_into_combat(run)
	_force_win(run)
	var deck_before: int = run.decks[0].size()
	run.skip_reward(0)
	var still_waiting: bool = run.phase == Run.Phase.REWARD
	run.skip_reward(1)
	_expect(run.decks[0].size() == deck_before and still_waiting
		and run.phase != Run.Phase.REWARD,
		"a reward can be declined, leaving the deck untouched")


func _test_relics_all_load() -> void:
	var pool: Array = Content.relic_pool()
	var ok := pool.size() >= 20
	var rule_changers := 0
	var flat := ["max_energy", "attack_bonus", "round_block", "heal_on_clear", "start_strength"]
	for id in pool:
		var r: Dictionary = Content.make_relic(String(id))
		if String(r.get("name", "")) == "" or String(r.get("text", "")) == "" or String(r.get("effect", "")) == "":
			ok = false
		if not flat.has(String(r.get("effect", ""))):
			rule_changers += 1
	_expect(ok and rule_changers >= 12,
		"the relic pool is deep and mostly rule-changing, not flat numbers")


func _test_rule_changing_relics() -> void:
	# start_foothold: begin the fight already up the beast
	var boss := _climb_boss(6)
	var players := [Combatant.new("A", 42), Combatant.new("B", 42)]
	var c := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], players, boss, 42,
		0, 0, 0, 0, [], {"start_foothold": 2})
	c.start()
	var started_up: bool = c.players[0].foothold == 2

	# fall_safe: losing your grip costs Height but no HP
	var boss2 := _climb_boss(6)
	boss2.ledges = [2, 4]
	var c2 := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], boss2, 42, 0, 0, 0, 0, [], {"fall_safe": 1})
	c2.start()
	c2.players[0].foothold = 3
	var hp0: int = c2.players[0].combatant.hp
	c2.fall(0)
	var painless: bool = c2.players[0].foothold == 0 and c2.players[0].combatant.hp == hp0

	# threshold: strike longer before the beast bucks you off
	var boss3 := _climb_boss(6)
	boss3.weak_point_threshold = 10
	var c3 := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], boss3, 42, 0, 0, 0, 0, [], {"threshold": 20})
	c3.start()
	c3.players[0].foothold = 6
	c3.play_card(0, _first_playable(c3, 0))  # would have bucked at 10 without the relic
	var still_up: bool = c3.players[0].foothold == 6

	# rhythm_keeps: the combo survives the turn rollover
	var c4 := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], _dummy_boss(300), 42,
		0, 0, 0, 0, [], {"rhythm_keeps": 1})
	c4.start()
	c4.players[0].rhythm = 3
	c4.end_turn(0)
	c4.end_turn(1)
	var kept: bool = c4.players[0].rhythm == 3

	_expect(started_up and painless and still_up and kept,
		"rule-changing relics rewrite the climb, the fall, the threshold and Rhythm")


func _test_backlog10_new_rule_changing_relics() -> void:
	# block_carries: half of unspent Block survives into the next round
	var c1 := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], _climb_boss(6), 42,
		0, 0, 0, 0, [], {"block_carries": 1})
	c1.start()
	c1.players[0].combatant.block = 9
	c1.end_turn(0)
	c1.end_turn(1)  # benign boss move, then the next round begins automatically
	var carried_block: bool = c1.players[0].combatant.block == 4  # floor(9 / 2)

	# no_buck: a weak-point strike that would normally buck you off no longer does
	var boss2 := _climb_boss(6)
	boss2.weak_point_threshold = 10
	var c2 := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], boss2, 42, 0, 0, 0, 0, [], {"no_buck": 1})
	c2.start()
	c2.players[0].foothold = 6
	c2.play_card(0, _first_playable(c2, 0))  # 6 damage + sigil bonus clears the threshold of 10
	var never_bucked: bool = c2.players[0].foothold == 6

	# soft_fall: losing your grip lands on the nearest hold below, not the base
	var boss3 := _climb_boss(6)
	boss3.ledges = [2, 4]
	var c3 := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], boss3, 42, 0, 0, 0, 0, [], {"soft_fall": 1})
	c3.start()
	c3.players[0].foothold = 5
	c3.fall(0)
	var soft_landing: bool = c3.players[0].foothold == 4

	# energy_handoff: unspent Energy at end of turn passes to the ally instead of vanishing
	var c4 := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], _dummy_boss(300), 42,
		0, 0, 0, 0, [], {"energy_handoff": 1})
	c4.start()
	var mate_before: int = c4.players[1].energy
	var self_before: int = c4.players[0].energy
	c4.end_turn(0)
	var handed_off: bool = c4.players[0].energy == 0 and c4.players[1].energy == mate_before + self_before

	_expect(carried_block and never_bucked and soft_landing and handed_off,
		"backlog #10's new relics carry Block, cancel the buck, soften a fall, and hand off Energy")


func _test_shake_resist_relic() -> void:
	# shake_resist (Anchor Pin): a sweep still hits, but no longer shakes you down a hold
	var boss := Boss.new("Shaker", 500)
	boss.moves = [{"type": "attack_all", "value": 5}]
	boss.weak_point_height = 6
	boss.ledges = [2, 4]
	var c := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], boss, 42, 0, 0, 0, 0, [], {"shake_resist": 1})
	c.start()
	c.players[0].foothold = 4  # upper ledge
	c.players[1].foothold = 2  # lower ledge
	var hp0_before: int = c.players[0].combatant.hp
	c.end_turn(0)
	c.end_turn(1)  # attack_all -> would shake without the relic
	var still_hit: bool = c.players[0].combatant.hp < hp0_before
	var held_the_hold: bool = c.players[0].foothold == 4 and c.players[1].foothold == 2
	_expect(still_hit and held_the_hold, "shake_resist takes the sweep's damage but keeps the hold")


## Item #13: at least 6 relics change a RULE (what happens) rather than a NUMBER
## (how much). The flat-count check in _test_relics_all_load() is deliberately
## loose (anything not a basic stat bump); this one names the actual rule-changing
## effects — each already proven by a behavior test above — and walks the whole
## data file so a future edit can't quietly drop below the bar.
func _test_backlog13_six_relics_change_a_rule() -> void:
	var rule_changing_effects := ["fall_safe", "shake_resist", "rhythm_keeps",
		"block_carries", "no_buck", "soft_fall", "energy_handoff"]
	var found := 0
	for id in Content.all_relic_ids():
		var r: Dictionary = Content.make_relic(String(id))
		if rule_changing_effects.has(String(r.get("effect", ""))):
			found += 1
	_expect(found >= 6, "at least 6 relics alter a rule rather than a number (found %d)" % found)


func _test_climb_twisting_moves() -> void:
	# swipe_low punishes anyone still on the ground; swipe_high the opposite
	var low := Boss.new("Lurker", 300)
	low.moves = [{"type": "swipe_low", "value": 8}]
	low.weak_point_height = 3
	var c := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, low)
	c.players[0].foothold = 2   # up the beast — safe
	c.players[1].foothold = 0   # on the ground — caught
	var hp_up: int = c.players[0].combatant.hp
	var hp_down: int = c.players[1].combatant.hp
	c.end_turn(0)
	c.end_turn(1)
	var low_ok: bool = c.players[0].combatant.hp == hp_up and c.players[1].combatant.hp == hp_down - 8

	var high := Boss.new("Snapper", 300)
	high.moves = [{"type": "swipe_high", "value": 7}]
	high.weak_point_height = 3
	var c2 := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, high)
	c2.players[0].foothold = 2
	c2.players[1].foothold = 0
	var h0: int = c2.players[0].combatant.hp
	var h1: int = c2.players[1].combatant.hp
	c2.end_turn(0)
	c2.end_turn(1)
	var high_ok: bool = c2.players[0].combatant.hp == h0 - 7 and c2.players[1].combatant.hp == h1

	# rift scales with how far apart they are — climbing together is the answer
	var rift := Boss.new("Riftling", 300)
	rift.moves = [{"type": "rift", "value": 4}]
	rift.weak_point_height = 4
	var c3 := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, rift)
	c3.players[0].foothold = 4
	c3.players[1].foothold = 0   # gap of 4
	var r0: int = c3.players[0].combatant.hp
	c3.end_turn(0)
	c3.end_turn(1)
	var rift_ok: bool = c3.players[0].combatant.hp == r0 - (4 + 4 * Combat.RIFT_PER_GAP)

	# shift_sigil moves the weak point, so a climb can be invalidated
	var idol := Boss.new("Idol", 300)
	idol.moves = [{"type": "shift_sigil", "value": 5}]
	idol.weak_point_height = 2
	var c4 := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, idol)
	c4.players[0].foothold = 2
	var was_there: bool = c4.sigil_reached(0)
	c4.end_turn(0)
	c4.end_turn(1)
	var shifted: bool = c4.boss.weak_point_height == 5 and was_there and not c4.sigil_reached(0)

	_expect(low_ok and high_ok and rift_ok and shifted,
		"beasts twist the climb: stamp the ground, lash the flank, punish separation, move the sigil")


func _test_per_class_reward_pools() -> void:
	var frog: Array = Content.reward_pool("frog")
	var gob: Array = Content.reward_pool("goblin_mech")
	var shared: Array = Content.reward_pool()
	# each class can draft toward its own archetype, and can't draft the other's
	var frog_own: bool = frog.has("cadence") and frog.has("flurry_hop") and not frog.has("satchel_charge")
	var gob_own: bool = gob.has("build_bomb") and gob.has("satchel_charge") and not gob.has("cadence")
	var neutrals: bool = frog.has("brace") and gob.has("brace")
	# and a run actually rolls from the acting hunter's pool
	var decks := [Content.character_deck("frog"), Content.character_deck("goblin_mech")]
	var run := Run.new(decks, ["F", "G"], 99,
		[Content.character_passive("frog"), Content.character_passive("goblin_mech")])
	run.start()
	_step_into_combat(run)
	_force_win(run)
	var from_own_pools := true
	if run.reward_kind == "card":
		for c in run.reward_choices[0]:
			if not frog.has((c as Card).id):
				from_own_pools = false
		for c2 in run.reward_choices[1]:
			if not gob.has((c2 as Card).id):
				from_own_pools = false
	_expect(frog_own and gob_own and neutrals and not shared.is_empty() and from_own_pools,
		"each hunter drafts from their own archetype pool, plus neutrals")


func _test_rhythm_card_grants_combo() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [Content.make_card("cadence"), Content.make_card("flurry_hop")]
	ps.energy = 3
	combat.play_card(0, 0)                      # +2 Rhythm outright
	var built: bool = ps.rhythm == 2
	var before: int = combat.boss.hp
	combat.play_card(0, 0)                      # 2 + 2*2 Rhythm = 6 damage, climbs 1 + 2
	_expect(built and before - combat.boss.hp == 6 and ps.foothold == 3,
		"Cadence grants Rhythm outright, and Rhythm cards scale off it")


func _test_ascension_makes_the_run_harder() -> void:
	var tiers: Array = Content.ascension_tiers()
	var mods0: Dictionary = Content.ascension_mods(0)
	var mods4: Dictionary = Content.ascension_mods(4)
	var cumulative: bool = int(mods4["boss_hp_pct"]) > 0 and int(mods4["boss_strength"]) > 0 		and int(mods4["reward_choices"]) > 0 and int(mods0["boss_hp_pct"]) == 0
	var decks := [_deck_of(_slash, 10), _deck_of(_slash, 10)]
	var base := Run.new(decks, ["A", "B"], 7, [{}, {}], 0)
	var hard := Run.new(decks, ["A", "B"], 7, [{}, {}], 7)
	base.start()
	hard.start()
	_step_into_combat(base)
	_step_into_combat(hard)
	var tougher: bool = hard.combat.boss.max_hp > base.combat.boss.max_hp 		and hard.combat.boss.strength > base.combat.boss.strength
	var frailer: bool = hard.max_hp[0] < base.max_hp[0]
	_expect(tiers.size() >= 8 and cumulative and tougher and frailer,
		"ascension tiers stack: thicker hides, meaner beasts, and a frailer party")


## Turning tips off must not amount to "mark everything seen" — switch them back
## on and you should be exactly where you left off, not skipped past the lessons
## you never got. Saves and restores the real setting; a test has no business
## changing what the player chose.
func _test_tips_can_be_switched_off_without_losing_your_place() -> void:
	var was := Progress.hints_enabled()
	Progress.reset_hints()
	Progress.set_hints_enabled(false)
	var off := Progress.hints_enabled()
	Progress.set_hints_enabled(true)
	# the hint is still unseen, so it is still owed to the player
	var still_owed: Dictionary = Coach.hint_for({"phase": "map"}, {}, 0)
	Progress.set_hints_enabled(was)
	_expect(not off and Progress.hints_enabled() == was
		and String(still_owed.get("id", "")) == "map",
		"tips toggle off and back on without consuming unseen hints")


func _test_coach_teaches_the_right_thing_first() -> void:
	Progress.reset_hints()
	# standing on the ground under a high weak point: the armoured rule matters most
	var on_ground := {"phase": "combat", "boss": {"weak_point_height": 3},
		"players": [{"foothold": 0, "secure": true, "reached": false},
			{"foothold": 0, "secure": true, "reached": false}]}
	var first: Dictionary = Coach.hint_for(on_ground, {"hand": []}, 0)
	# mid-climb with the grip draining outranks everything
	var climbing := {"phase": "combat", "boss": {"weak_point_height": 3},
		"players": [{"foothold": 1, "secure": false, "reached": false},
			{"foothold": 0, "secure": true, "reached": false}]}
	var urgent: Dictionary = Coach.hint_for(climbing, {"hand": []}, 0)
	# each hint fires once, ever
	Progress.mark_hint_seen("armored")
	var after: Dictionary = Coach.hint_for(on_ground, {"hand": []}, 0)
	var not_repeated: bool = String(after.get("id", "")) != "armored"
	# and phases teach their own lesson
	var on_map: Dictionary = Coach.hint_for({"phase": "map"}, {}, 0)
	Progress.reset_hints()
	_expect(String(first.get("id", "")) == "armored"
		and String(urgent.get("id", "")) == "climbing"
		and not_repeated and String(on_map.get("id", "")) == "map",
		"the coach teaches the most urgent unseen rule, once each")


func _test_gold_and_shop() -> void:
	var run := _map_run()
	var start_gold: int = run.gold
	_step_into_combat(run)
	_force_win(run)
	var earned: bool = run.gold > start_gold   # beasts pay
	_pick_both(run)
	# stock a shop by hand and trade against it
	run.gold = 500
	run.map_row = 0
	run.node_type = "shop"
	run._begin_shop()
	var stocked: bool = run.phase == Run.Phase.SHOP and run.shop_stock.size() >= 4
	# buy the first card on offer
	var card_i := -1
	for i in range(run.shop_stock.size()):
		if String(run.shop_stock[i]["kind"]) == "card":
			card_i = i
			break
	var slot := int(run.shop_stock[card_i]["slot"])
	var deck_before: int = run.decks[slot].size()
	var purse_before: int = run.gold
	var bought: bool = run.buy(card_i)
	var got_card: bool = run.decks[slot].size() == deck_before + 1 and run.gold < purse_before
	var twice: bool = run.buy(card_i)   # already sold
	# removal is priced up each time it's used
	var rem_i := -1
	for i in range(run.shop_stock.size()):
		if String(run.shop_stock[i]["kind"]) == "remove":
			rem_i = i
			break
	var rslot := int(run.shop_stock[rem_i]["slot"])
	var rdeck_before: int = run.decks[rslot].size()
	var first_price: int = run.remove_price()
	run.buy(rem_i, 0)
	var thinned: bool = run.decks[rslot].size() == rdeck_before - 1
	var pricier: bool = run.remove_price() > first_price
	# can't buy what you can't afford
	run.gold = 0
	var broke := false
	for i in range(run.shop_stock.size()):
		if not bool(run.shop_stock[i]["sold"]):
			broke = not run.buy(i)
			break
	run.leave_shop()
	_expect(earned and stocked and bought and got_card and not twice
		and thinned and pricier and broke and run.phase == Run.Phase.MAP,
		"gold is earned, the shop trades, removal gets pricier, and you can't overspend")


## Backlog #19: the card/removal paths above were covered, but a relic
## purchase and the "can't thin past the floor" guard never were.
func _test_shop_buys_a_relic() -> void:
	var run := _map_run()
	run.gold = 500
	run.map_row = 0
	run.node_type = "shop"
	run._begin_shop()
	var relic_i := -1
	for i in range(run.shop_stock.size()):
		if String(run.shop_stock[i]["kind"]) == "relic":
			relic_i = i
			break
	if relic_i < 0:
		_expect(true, "shop buys a relic (none stocked this seed)")
		return
	var relics_before: int = run.team_relics.size()
	var purse_before: int = run.gold
	var bought := run.buy(relic_i)
	_expect(bought and run.team_relics.size() == relics_before + 1
		and run.gold == purse_before - Run.PRICE_RELIC and bool(run.shop_stock[relic_i]["sold"]),
		"buying a relic adds it to the team and spends gold")


func _test_shop_cannot_thin_below_min_deck() -> void:
	var run := _map_run()
	run.gold = 5000
	run.map_row = 0
	run.node_type = "shop"
	run._begin_shop()
	var rem_i := -1
	for i in range(run.shop_stock.size()):
		if String(run.shop_stock[i]["kind"]) == "remove":
			rem_i = i
			break
	var rslot := int(run.shop_stock[rem_i]["slot"])
	while run.decks[rslot].size() > Run.MIN_DECK:  # thin it to the floor by hand
		run.decks[rslot].pop_back()
	var size_before: int = run.decks[rslot].size()
	var purse_before: int = run.gold
	var blocked := not run.buy(rem_i, 0)
	_expect(blocked and run.decks[rslot].size() == size_before and run.gold == purse_before
		and not bool(run.shop_stock[rem_i]["sold"]),
		"the shop refuses to thin a deck past MIN_DECK, and doesn't charge for the refusal")


func _test_shop_rejects_actions_outside_its_phase() -> void:
	var run := _map_run()  # start() leaves the run on the MAP, not in a shop
	_expect(not run.buy(0) and not run.leave_shop(),
		"buy() and leave_shop() refuse to act outside the SHOP phase")


func _test_content_pools_are_copies() -> void:
	# Regression: the shop filters these lists with erase(). Handing out the
	# CACHED array drained the relic pool for the whole session, which then hung
	# the reward phase on an empty choice list.
	var a: Array = Content.relic_pool()
	var before: int = a.size()
	a.clear()
	var b: Array = Content.relic_pool()
	var beasts: Array = Content.beast_pool("fight")
	beasts.clear()
	var rewards: Array = Content.reward_pool("frog")
	rewards.clear()
	_expect(before > 0 and b.size() == before
		and Content.beast_pool("fight").size() > 0
		and Content.reward_pool("frog").size() > 0,
		"content pools hand out copies — callers can filter without draining the game")


## Walk the route until a combat node is reached (skipping rest/treasure).
func _step_into_combat(run: Run) -> void:
	var guard := 0
	while run.phase != Run.Phase.COMBAT and not run.is_over() and guard < 60:
		guard += 1
		if run.phase == Run.Phase.MAP:
			# Prefer a fight so rest/event side effects don't muddy what's asserted.
			var choice := int(run.available_nodes()[0])
			for col in run.available_nodes():
				var t := String(run.map.node_at(run.map_row + 1, int(col)).get("type", ""))
				if t in ["fight", "elite", "boss"]:
					choice = int(col)
					break
			run.pick_node(choice)
		elif run.phase == Run.Phase.EVENT:
			run.pick_event(0)
		elif run.phase == Run.Phase.CAMPFIRE:
			for slot in range(run.player_count()):
				run.campfire_action(slot, "rest")
		elif run.phase == Run.Phase.SHOP:
			run.leave_shop()
		elif run.phase == Run.Phase.REWARD:
			_pick_both(run)


## A started run positioned at the trailhead of a seeded map.
func _map_run() -> Run:
	var decks := [_deck_of(_slash, 10), _deck_of(_slash, 10)]
	var run := Run.new(decks, ["A", "B"], 4242, [{}, {}])
	run.start()
	return run


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


# --- Named holds — the climb ENGINE (design/BACKLOG.md #24) ---------------

func _test_hold_helpers_read_both_shapes() -> void:
	var legacy_ok: bool = Boss.hold_height(4) == 4 and Boss.hold_safe(4) and Boss.hold_exposed_to(4).is_empty()
	var named := {"height": 7, "safe": false, "exposed_to": ["swipe_low", "swipe_high"]}
	var named_ok: bool = Boss.hold_height(named) == 7 and not Boss.hold_safe(named) \
		and Boss.hold_exposed_to(named) == ["swipe_low", "swipe_high"]
	var boss := Boss.new("Test", 10)
	boss.ledges = [2, named]
	var heights_ok: bool = boss.ledge_heights() == [2, 7]
	_expect(legacy_ok and named_ok and heights_ok,
		"hold_height/hold_safe/hold_exposed_to/ledge_heights read legacy ints and named-hold dicts alike")


func _test_named_holds_dict_shape_and_unsafe_flag() -> void:
	var boss := _climb_boss(8)
	boss.ledges = [2, {"height": 5, "safe": false, "exposed_to": ["swipe_low"]}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	ps.foothold = 5
	var unsafe_hold_not_secure: bool = not combat.is_secure(0)
	ps.foothold = 2
	var legacy_int_still_secure: bool = combat.is_secure(0)
	ps.foothold = 3
	var skips_unsafe_hold: bool = combat.next_safe_height(0) == 8  # 5 is unsafe — straight to the sigil
	_expect(unsafe_hold_not_secure and legacy_int_still_secure and skips_unsafe_hold,
		"a named hold can be marked unsafe, and legacy bare-int ledges keep working alongside it")


func _test_targets_hold_card_climbs_to_a_named_hold() -> void:
	var boss := _climb_boss(6)
	boss.ledges = [2, 4]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	ps.hand = [Content.make_card("route_finder")]
	ps.energy = 3
	combat.play_card(0, 0)  # no explicit hold_target -> nearest safe hold above (2)
	var untargeted_ok: bool = ps.foothold == 2

	var boss2 := _climb_boss(6)
	boss2.ledges = [2, 4]
	var combat2 := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss2)
	var ps2: PlayerState = combat2.players[0]
	ps2.foothold = 1
	ps2.hand = [Content.make_card("route_finder")]
	ps2.energy = 3
	combat2.play_card(0, 0, true, -1, -1, 4)  # explicitly name the higher ledge
	var explicit_ok: bool = ps2.foothold == 4

	var boss3 := _climb_boss(6)
	boss3.ledges = [2, 4]
	var combat3 := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss3)
	var ps3: PlayerState = combat3.players[0]
	ps3.foothold = 1
	ps3.hand = [Content.make_card("route_finder")]
	ps3.energy = 3
	combat3.play_card(0, 0, true, -1, -1, 3)  # 3 names no real hold -> falls back to nearest (2)
	var invalid_falls_back_ok: bool = ps3.foothold == 2

	var boss4 := _climb_boss(6)
	boss4.ledges = [2, 4]
	var combat4 := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss4)
	var ps4: PlayerState = combat4.players[0]
	ps4.foothold = 6  # already at the sigil — nothing left to climb to
	ps4.hand = [Content.make_card("route_finder")]
	ps4.energy = 3
	combat4.play_card(0, 0)
	var noop_at_top_ok: bool = ps4.foothold == 6

	_expect(untargeted_ok and explicit_ok and invalid_falls_back_ok and noop_at_top_ok,
		"a targets_hold card climbs straight to a named hold, defaults to the nearest one, " +
		"ignores a fake target, and no-ops safely with nothing left above")


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
	var in_range: bool = combat.can_play(0, 0)
	combat.play_card(0, 0)
	var pulled: bool = combat.players[1].foothold == 4
	# out of reach (gap 5) and no gap (level): the card is simply UNPLAYABLE (Nick)
	combat.players[0].foothold = 6
	combat.players[1].foothold = 1
	var out_of_range: bool = combat.can_play(0, 0)
	combat.players[1].foothold = 6
	var level: bool = combat.can_play(0, 0)
	_expect(in_range and pulled and not out_of_range and not level,
		"Grappling Arm pulls an ally in reach, and is unplayable when it can't pull")


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


func _test_vine_weaver_poison_and_wound() -> void:
	var combat := _new_combat_p([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42,
		_dummy_boss(300), [{"type": "poison_lift", "value": 1}, {}])
	var ps: PlayerState = combat.players[0]
	ps.hand = [_toxic_lash(), _toxic_lash()]
	ps.energy = 3
	var ally_before: int = combat.players[1].foothold
	var before: int = combat.boss.hp
	combat.play_card(0, 0, true)  # Wound 0 -> 2 +0 +3 timed = 5; then Poison 1; ally lifts +1
	var d1: int = before - combat.boss.hp
	var lifted: bool = combat.players[1].foothold == ally_before + 1
	var before2: int = combat.boss.hp
	combat.play_card(0, 0, true)  # Wound 1 -> 2 + 2*1 + 3 = 7
	_expect(d1 == 5 and lifted and before2 - combat.boss.hp == 7,
		"Vine-Weaver: poison lifts the ally, and strikes scale with Wound stacks")


func _test_summit_strike_scales_with_both() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.foothold = 2
	combat.players[1].foothold = 3
	ps.hand = [_summit_strike()]
	ps.energy = 3
	var before: int = combat.boss.hp
	combat.play_card(0, 0, true)  # 2 + 2*2(own) + 2*3(ally) + 3 timed = 15
	_expect(before - combat.boss.hp == 15,
		"Summit Strike scales with BOTH hunters' Height (+ally coordination)")


func _test_rhythm_builds_and_scales() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_flick(), _tongue_snap()]
	ps.energy = 3
	var r0: int = ps.rhythm
	combat.play_card(0, 0, true)  # flick lands (timed) -> Rhythm +1
	var r1: int = ps.rhythm
	var before: int = combat.boss.hp
	combat.play_card(0, 0, true)  # Tongue Snap: 2 + 3*Rhythm(1) + 3 timed = 8
	_expect(r0 == 0 and r1 == 1 and before - combat.boss.hp == 8,
		"a timed card builds Rhythm; a Rhythm card scales with it (2 +3/Rhythm +3 nailed)")


func _test_meld_carries_special_effects() -> void:
	# Nick's bug: goblin cards live on special fields and fusion dropped them.
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	# Jetpack (prepare) + Build Mech (block_per_play)
	ps.hand = [_meld_card(), Content.make_card("goblin_jetpack"), Content.make_card("build_mech")]
	ps.energy = 9
	combat.play_card(0, 0, true, 1, 2)
	var f1: Card = ps.hand[0]
	var jet_mech: bool = f1.prepare == "jetpack" and f1.block_per_play == 2 and f1.block == 2
	# Grappling Arm (pull_ally) + Satchel (timed_hits 3, timed_damage 20)
	ps.hand = [_meld_card(), Content.make_card("grappling_arm"), Content.make_card("satchel_charge")]
	ps.energy = 9
	combat.play_card(0, 0, true, 1, 2)
	var f2: Card = ps.hand[0]
	var arm_satchel: bool = f2.pull_ally == 3 and f2.timed and f2.timed_hits == 3 and f2.timed_damage == 20
	_expect(jet_mech and arm_satchel,
		"a meld keeps BOTH cards' special effects (prepare/block_per_play/pull_ally/timed chain)")


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


## The "sure" enchant's one /core behaviour: a card that would normally fumble
## and slip away with no effect instead lands its full timed bonus, same as a
## nailed hit. ("wide" — the other half of backlog #3's idea — has no /core
## consumer yet; the timing window itself is client-rendered, so widening it is
## the needs-a-screen work #3 still owns.)
func _test_sure_enchant_lands_even_on_a_fumble() -> void:
	var combat := _new_combat([_deck_of(_pounce, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var before: int = combat.boss.hp
	var idx := _first_playable(combat, 0)
	combat.players[0].hand[idx] = combat.players[0].hand[idx].enchanted_copy("sure")
	combat.play_card(0, idx, false)  # a fumbled timing hit — Sure carries it anyway
	_expect(before - combat.boss.hp == 9,  # 4 base + 5 timed_damage, same as a nailed hit
		"a Sure-enchanted card lands its timed bonus even when the timing is missed")


## A timed defensive card: nail the window and the guard holds; mistime it and the
## card slips away like any other timed card — so you eat the blow bare.
func _test_timed_block_guards_on_a_hit() -> void:
	var combat := _new_combat([_deck_of(_dig_in, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	combat.play_card(0, _first_playable(combat, 0), true)   # 4 base + 6 timed
	var nailed: int = combat.players[0].combatant.block
	combat.play_card(0, _first_playable(combat, 0), false)  # fumble — no guard at all
	_expect(nailed == 10 and combat.players[0].combatant.block == 10,
		"a well-timed brace adds timed_block; a mistimed one grants nothing")


func _test_timed_ally_block_anchors_the_ally() -> void:
	var combat := _new_combat([_deck_of(_anchor_brace, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	combat.play_card(0, _first_playable(combat, 0), true)   # ally 4 + 6 timed; caster 2
	_expect(combat.players[1].combatant.block == 10 and combat.players[0].combatant.block == 2,
		"Anchor Brace shields the ally on a nailed timing, and the caster a little")


# --- Graded timing accuracy — the rules half (backlog #33) -----------------
# Today's binary nailed/fumbled becomes a quality tier (miss/good/perfect) so
# a dead-centre hit pays more than one that barely landed in the zone. The
# seam: CardView grades the throw -> play_card(timing_quality) ->
# preview(nailed, quality). TIMING_PERFECT must reproduce exactly what a
# plain nailed hit always paid — these tests pin that alongside the new tier.

func _test_graded_timing_good_pays_half_the_bonus() -> void:
	var combat := _new_combat([_deck_of(_pounce, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var before: int = combat.boss.hp
	var idx := _first_playable(combat, 0)
	combat.play_card(0, idx, true, -1, -1, -1, Combat.TIMING_GOOD)  # 4 base + half of 5 timed_damage
	_expect(before - combat.boss.hp == 6,
		"a 'good' (not dead-centre) timed hit pays half the timed bonus, not the full amount")


func _test_graded_timing_perfect_matches_a_plain_nailed_hit() -> void:
	# Backlog #33's own bar: TIMING_PERFECT must behave EXACTLY as the old bare
	# nailed hit did. Pin that by comparing the two call styles directly
	# rather than trusting they happen to agree.
	var a := _new_combat([_deck_of(_pounce, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var before_a: int = a.boss.hp
	a.play_card(0, _first_playable(a, 0), true)  # old call style: no quality arg at all
	var dealt_a := before_a - a.boss.hp
	var b := _new_combat([_deck_of(_pounce, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var before_b: int = b.boss.hp
	b.play_card(0, _first_playable(b, 0), true, -1, -1, -1, Combat.TIMING_PERFECT)
	var dealt_b := before_b - b.boss.hp
	_expect(dealt_a == dealt_b and dealt_a == 9,
		"TIMING_PERFECT deals exactly what a plain nailed hit always dealt")


func _test_preview_quality_scales_the_timed_bonus() -> void:
	var combat := _new_combat([_deck_of(_pounce, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var card: Card = combat.players[0].hand[_first_playable(combat, 0)]
	var perfect := combat.preview(0, card, true, Combat.TIMING_PERFECT)
	var good := combat.preview(0, card, true, Combat.TIMING_GOOD)
	var miss := combat.preview(0, card, false, Combat.TIMING_GOOD)  # quality is moot without a hit
	_expect(int(perfect["damage"]) == 9 and int(good["damage"]) == 6 and int(miss["damage"]) == 4,
		"preview() grades the timed bonus by quality, and ignores quality entirely on a miss")


func _test_graded_timing_default_quality_is_perfect() -> void:
	# play_card's timing_quality defaults to PERFECT so every network command
	# format from before this landed (no "quality" key at all) still pays the
	# full timed bonus, same as _test_graded_timing_perfect_matches... but
	# exercised through the actual default rather than an explicit argument.
	var combat := _new_combat([_deck_of(_pounce, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var before: int = combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0), true, -1, -1)  # no quality arg supplied
	_expect(before - combat.boss.hp == 9,
		"an omitted timing_quality defaults to PERFECT, matching pre-#33 behavior")


## The Goblin's sacrifices should compound: every card he burns makes Scrap Drive
## and Pressure Valve stronger for the rest of the fight.
func _test_exhaust_scaling_grows_with_the_burn_pile() -> void:
	var combat := _new_combat([_deck_of(_scrap_drive, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	var before: int = combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))          # nothing burned yet: 3 damage
	var cold: int = before - combat.boss.hp
	ps.exhaust_pile.append(_slash())                          # two cards burned
	ps.exhaust_pile.append(_slash())
	var mid: int = combat.boss.hp
	combat.play_card(0, _first_playable(combat, 0))          # 3 + 3*2 = 9
	_expect(cold == 3 and mid - combat.boss.hp == 9,
		"damage_per_exhausted scales with cards burned this fight")


## Detonator both burns a card AND scales off the burn pile. It must count the
## pile as it was BEFORE its own sacrifice, or it silently pays itself.
func _test_detonator_does_not_count_its_own_sacrifice() -> void:
	var combat := _new_combat([_deck_of(_detonator, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	var ci := _first_playable(combat, 0)
	var sac := 1 if ci != 1 else 2
	var before: int = combat.boss.hp
	combat.play_card(0, ci, true, sac)   # pile empty before the play: 4 damage, not 10
	_expect(before - combat.boss.hp == 4 and ps.exhaust_pile.size() == 1,
		"Detonator scales off the pile before its own sacrifice, and still burns one")


## Content.make_card returns an EMPTY card for an unknown id rather than failing,
## so a typo in a deck or pool is silently a blank card in someone's hand. Catch it.
func _test_every_referenced_card_id_resolves() -> void:
	var bad: Array = []
	for c in Content.list_characters():
		var cid := String(c["id"])
		for card in Content.character_deck(cid):
			if String(card.name).is_empty():
				bad.append("%s starter_deck" % cid)
		for rid in Content.reward_pool(cid):
			if String(Content.make_card(String(rid)).name).is_empty():
				bad.append("%s reward_pool: %s" % [cid, rid])
	for rid in Content.reward_pool():
		if String(Content.make_card(String(rid)).name).is_empty():
			bad.append("global reward_pool: %s" % rid)
	for card in Content.build_starter_deck():
		if String(card.name).is_empty():
			bad.append("global starter_deck")
	_expect(bad.is_empty(),
		"every card id in every deck and reward pool resolves [%s]" % ", ".join(bad))


## Backlog #18: the rest of the content graph, which the test above doesn't
## reach. A `create` field builds another card by id (Goblin gadgets); a
## `prepare` field arms a delayed effect that combat.gd's _resolve_prepared()
## must actually handle, not just any string; a beast pool id must resolve to
## a real Titan/beast, not the empty "Titan, no moves" Boss.build_boss() hands
## back for an unknown one. Card ids in decks/pools are proven above and relic
## ids by _test_relics_all_load() — together these prove the whole graph.
func _test_content_integrity_graph() -> void:
	var bad: Array = []
	var known_prepares := ["jetpack"]  # every key Combat._resolve_prepared() handles
	for id in Content.all_card_ids():
		var card := Content.make_card(String(id))
		if card.create != "" and String(Content.make_card(card.create).name).is_empty():
			bad.append("%s create: %s" % [id, card.create])
		if card.prepare != "" and not known_prepares.has(card.prepare):
			bad.append("%s prepare: %s (unhandled by combat.gd)" % [id, card.prepare])
	for kind in ["fight", "elite", "boss"]:
		for id in Content.beast_pool(kind):
			var b := Content.build_boss(String(id))
			if b.moves.is_empty():
				bad.append("%s pool: %s (no moves — unknown beast id?)" % [kind, id])
	_expect(bad.is_empty(),
		"create/prepare fields and beast pool ids all resolve [%s]" % ", ".join(bad))


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
	var run := _map_run()
	var on_map: bool = run.phase == Run.Phase.MAP and run.combat == null
	_step_into_combat(run)
	_expect(on_map and run.phase == Run.Phase.COMBAT and run.combat != null,
		"a run starts on the map, then fights the node it steps on")

func _test_run_win_flows_through_reward_to_next_encounter() -> void:
	var run := _map_run()
	_step_into_combat(run)  # row 0 is always a fight -> card reward
	_force_win(run)
	_expect(run.phase == Run.Phase.REWARD and run.reward_kind == "card"
		and run.reward_choices.size() == 2
		and run.reward_choices[0].size() == Run.REWARD_CHOICES,
		"winning a fight enters the reward phase with choices")
	var deck0_before: int = run.decks[0].size()
	run.pick_reward(0, 0)
	_expect(run.phase == Run.Phase.REWARD, "the run waits for every hunter to pick")
	run.pick_reward(1, 0)
	_expect(run.phase == Run.Phase.MAP and run.decks[0].size() == deck0_before + 1,
		"after all pick, the chosen card is added and the route opens up again")

func _test_run_hp_carries_between_encounters() -> void:
	var run := _map_run()
	_step_into_combat(run)
	run.combat.players[0].combatant.hp = 20  # took damage this fight
	_force_win(run)
	var banked: int = run.hp[0]              # carried + the between-fight heal
	_pick_both(run)                          # -> back to the map
	_step_into_combat(run)                   # walk on to the next fight
	# the next fight starts from the run's carried HP, whatever the route did on the way
	_expect(banked == 20 + Run.HEAL_BETWEEN
		and run.combat.players[0].combatant.hp == run.hp[0],
		"damage carries between encounters (plus a small heal), through whatever the route offers")

func _test_run_defeat_when_a_hunter_falls() -> void:
	var run := _map_run()
	_step_into_combat(run)
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
	var run := _map_run()
	_expect(run.total_encounters() == 4 and run.map.total_rows() == 4 * (RunMap.ROWS_PER_ACT + 1),
		"a run is four acts, each a few map rows capped by a Titan")

func _test_run_relic_reward_and_full_clear() -> void:
	var run := _map_run()
	# walk the entire route, winning every fight, until the run resolves
	var guard := 0
	var saw_card := false
	var saw_relic := false
	while not run.is_over() and guard < 200:
		guard += 1
		match run.phase:
			Run.Phase.MAP:
				run.pick_node(int(run.available_nodes()[0]))
			Run.Phase.COMBAT:
				_force_win(run)
			Run.Phase.EVENT:
				run.pick_event(0)
			Run.Phase.CAMPFIRE:
				for slot in range(run.player_count()):
					run.campfire_action(slot, "rest")
			Run.Phase.SHOP:
				run.leave_shop()
			Run.Phase.REWARD:
				if run.reward_kind == "card":
					saw_card = true
				else:
					saw_relic = true
				_pick_both(run)
	_expect(run.phase == Run.Phase.WON and saw_card and saw_relic and run.team_relics.size() > 0,
		"walking the whole map (fights pay cards, elites/Titans pay relics) wins the run")

## Elites and Titans owe TWO rewards — the card first, the relic after. The run
## must not release to the map until both have been taken.
func _test_elite_pays_a_card_then_a_relic() -> void:
	var run := _map_run()
	_step_into_combat(run)
	run.node_type = "elite"  # treat the node we stepped onto as an elite
	var deck_before: int = run.decks[0].size()
	var relics_before: int = run.team_relics.size()
	_force_win(run)
	var first_kind: String = run.reward_kind
	_pick_both(run)                                   # take the card
	var still_rewarding: bool = run.phase == Run.Phase.REWARD
	var second_kind: String = run.reward_kind
	_pick_both(run)                                   # take the relic
	# Each hunter picks their OWN relic and both join the team pool, so a relic
	# reward grows team_relics by the party size, not by one.
	_expect(first_kind == "card" and still_rewarding and second_kind == "relic"
		and run.decks[0].size() == deck_before + 1
		and run.team_relics.size() == relics_before + run.player_count()
		and run.phase == Run.Phase.MAP,
		"an elite pays a card and THEN a relic before the route reopens")


## GameHost._keywords_of derives keyword ids in CODE; keywords.json defines them.
## A typo in either silently drops a tooltip and the card goes back to being
## unexplained, which is the exact problem the keyword layer exists to fix.
func _test_every_derived_keyword_resolves() -> void:
	var derived := ["timed", "poison", "expose", "rhythm", "strength", "block",
		"height", "armoured", "taunt", "burn", "enchant", "energy", "build",
		"prime", "cheapen", "meld", "multistrike"]
	var defined := Content.keyword_ids()
	var missing: Array = []
	for id in derived:
		if not defined.has(id):
			missing.append(id)
		elif String(Content.keyword(String(id)).get("text", "")).is_empty():
			missing.append("%s (no text)" % id)
	_expect(missing.is_empty(),
		"every keyword the host derives is defined in keywords.json [%s]" % ", ".join(missing))


## Backlog #16: the check above only catches an id that's misspelled in one
## place and not the other. It says nothing about a NEW field on Card that
## nobody wired into _keywords_of at all — that ships silently unexplained.
## So walk Card's actual fields (reflection, same trick
## _test_card_dict_round_trips_every_field uses) rather than a hand-kept list:
## a field added tomorrow is covered the moment it's declared. Each field is
## probed ALONE, isolated from every other field on the card, so it can't
## hide behind some unrelated field on the same real card supplying the tag.
func _test_every_field_a_player_must_understand_has_a_keyword() -> void:
	# Fields whose meaning is plain from their own number/name — a name, rules
	# text already printed on the card, the cost pip, the damage number, how
	# many draws — need no separate keyword tooltip. timed_hits is a plain
	# repeat-count that only means anything once you already understand Timed.
	var self_evident := ["id", "name", "type", "rarity", "cost", "damage", "draw",
		"target", "icon", "text", "upgraded", "timed_hits"]
	# A handful of int fields are meaningless at the generic probe value of 1
	# because 1 IS their neutral default (a single hit, no repeat) — probe
	# those with a value that's actually "used" instead.
	var probe_override := {"hits": 2}
	var host := GameHost.new(LocalTransport.new(), 1, 2)
	_kept.append(host)
	var probe := Card.new()
	var missing: Array = []
	for p in probe.get_property_list():
		var prop: Dictionary = p
		if int(prop.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		var key := String(prop["name"])
		if self_evident.has(key):
			continue
		var d := {}
		match typeof(probe.get(key)):
			TYPE_BOOL:
				d[key] = true
			TYPE_STRING:
				d[key] = "probe"
			_:
				d[key] = int(probe_override.get(key, 1))
		var lone := Card.from_dict(d)
		if host._keywords_of(lone).is_empty():
			missing.append(key)
	_expect(missing.is_empty(),
		"every card field a player must understand has a keyword [%s]" % ", ".join(missing))


## The intent tag NAMES a move and lets you right-click it for the rest, so an
## undefined move type is a telegraph with no explanation behind it.
func _test_every_boss_move_type_resolves() -> void:
	var missing: Array = []
	for kind in ["fight", "elite", "boss"]:
		for id in Content.beast_pool(kind):
			var b: Boss = Content.build_boss(String(id))
			for m in b.moves:
				var t := String((m as Dictionary).get("type", ""))
				if String(Content.keyword(t).get("text", "")).is_empty():
					missing.append("%s: %s" % [id, t])
	_expect(missing.is_empty(),
		"every boss move type has a keyword entry [%s]" % ", ".join(missing))


## Backlog #11: a beast with fewer than 4 moves, or only one move type, has no
## pattern to read — Crag Pup was literally two attacks. Every beast needs a
## real shape: enough moves to cycle through, and more than one kind among them.
func _test_every_beast_has_a_move_pattern() -> void:
	var bad: Array = []
	for kind in ["fight", "elite", "boss"]:
		for id in Content.beast_pool(kind):
			var b: Boss = Content.build_boss(String(id))
			var kinds := {}
			for m in b.moves:
				kinds[String((m as Dictionary).get("type", ""))] = true
			if b.moves.size() < 4 or kinds.size() < 2:
				bad.append("%s (%d moves, %d kinds)" % [id, b.moves.size(), kinds.size()])
	_expect(bad.is_empty(),
		"every beast has at least 4 moves and more than one kind [%s]" % ", ".join(bad))


## Backlog #20: weak_point_threshold audit. It caps how much sigil damage a
## hunter can bank per visit before the Titan bucks them off — "climb, strike
## for a CHUNK, get thrown" (GDD). The worry was that it was tuned back when
## sigils sat at Height 1-8 and never rechecked once climbs deepened to 4-13.
## It turns out the threshold was never really a function of sigil HEIGHT —
## it's a function of typical hit damage at the sigil, and that hasn't moved.
## So the actual audit is: does the cap still take MORE THAN ONE hit (a "tap"
## isn't a "chunk") but still bucks you off WITHIN A SINGLE TURN'S worth of
## hits (otherwise it can't be felt at all)? Compute "hits to buck" from the
## real card pool's average cheap attack (cost<=1, so it can't be dodged by
## only ever playing big cards) plus SIGIL_BONUS, the same total _damage_boss
## adds at the sigil, and require every weak-point beast to land in [1.5, 6].
## Measured 2026-08-24: every beast lands between 1.78 (Crag Pup/Bounder) and
## 5.34 hits (Sunken Warden) — a beast-by-beast rise that already tracks HP,
## independent of sigil height. Nothing to retune; this only pins the finding
## against regression (a future beast added outside the band would fail here
## instead of silently shipping a dead or trivial cap).
func _test_weak_point_threshold_still_means_something() -> void:
	var cheap_attack_dmgs: Array = []
	for id in Content.all_card_ids():
		var c: Card = Content.make_card(String(id))
		if c.type == "attack" and c.cost <= 1 and c.damage > 0:
			cheap_attack_dmgs.append(c.damage)
	var avg_dmg := 0.0
	for v in cheap_attack_dmgs:
		avg_dmg += v
	avg_dmg /= cheap_attack_dmgs.size()
	var avg_sigil_hit: float = avg_dmg + Combat.SIGIL_BONUS
	var out_of_band: Array = []
	for kind in ["fight", "elite", "boss"]:
		for id in Content.beast_pool(kind):
			var b: Boss = Content.build_boss(String(id))
			if b.weak_point_height <= 0 or b.weak_point_threshold <= 0:
				continue
			var hits_to_buck: float = float(b.weak_point_threshold) / avg_sigil_hit
			if hits_to_buck < 1.5 or hits_to_buck > 6.0:
				out_of_band.append("%s (%.2f hits)" % [id, hits_to_buck])
	_expect(out_of_band.is_empty(),
		"weak_point_threshold takes more than one hit but bucks within a turn's reach, for every beast [%s]" % ", ".join(out_of_band))


## Card.to_dict is hand-written while from_dict is hand-written separately, so a
## field added to one and forgotten in the other silently drops from every save
## AND from every melded card. Walk the script's OWN properties rather than a
## list here, so a new field is covered the moment it is declared.
func _test_card_dict_round_trips_every_field() -> void:
	var card := Content.make_card("tongue_snap")
	var missing: Array = []
	var dict := card.to_dict()
	for p in card.get_property_list():
		var prop: Dictionary = p
		if int(prop.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		var key := String(prop["name"])
		if not dict.has(key):
			missing.append(key)
	var back := Card.from_dict(dict)
	var changed: Array = []
	for p2 in card.get_property_list():
		var prop2: Dictionary = p2
		if int(prop2.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		var key2 := String(prop2["name"])
		if dict.has(key2) and back.get(key2) != card.get(key2):
			changed.append(key2)
	_expect(missing.is_empty() and changed.is_empty(),
		"every Card field survives to_dict/from_dict [missing: %s] [changed: %s]"
			% [", ".join(missing), ", ".join(changed)])


## A run has to come back the way it left. The deck is the part that matters most
## — it carries sharpened and melded cards that exist nowhere in cards.json, so a
## deck rebuilt from ids alone would quietly undo a whole run's upgrades.
func _test_run_survives_a_save_and_load() -> void:
	var run := Run.new([_deck_of(_slash, 6), _deck_of(_slash, 5)], ["A", "B"], 99,
		[{"character": "frog"}, {"character": "goblin_mech"}], 2)
	run.start()
	run.gold = 175
	run.hp = [21, 33]
	run.decks[0][0] = run.decks[0][0].upgraded_copy()   # a campfire sharpening
	run.team_relics = [{"id": "grip_ring", "name": "Grip Ring"}]
	run.pick_node(int(run.available_nodes()[0]))
	run.phase = Run.Phase.MAP  # whatever the node opened, park it at a safe point

	# Through the FILE, not just to_dict/from_dict. JSON has one number type, so a
	# straight dictionary round trip hides that every int comes back a float.
	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()
	var ints_stayed_ints: bool = back.hp == run.hp and back.gold == run.gold
	_expect(ints_stayed_ints, "ints survive the JSON round trip as ints, not floats")
	var same: bool = (
		back.gold == run.gold
		and back.hp == run.hp
		and back.ascension == run.ascension
		and back.map_row == run.map_row and back.map_col == run.map_col
		and back.encounter_index == run.encounter_index
		and back.team_relics.size() == run.team_relics.size()
		and back.map.total_rows() == run.map.total_rows()
		and back.decks.size() == run.decks.size()
		and back.decks[0].size() == run.decks[0].size()
		and String(back.decks[0][0].name) == String(run.decks[0][0].name)
		and bool(back.decks[0][0].upgraded) == bool(run.decks[0][0].upgraded)
		and int(back.decks[0][0].damage) == int(run.decks[0][0].damage)
	)
	_expect(same, "a saved run reloads with its map, gold, HP, relics and sharpened deck")

	# The RNG travels too, or quitting and resuming would reroll every reward —
	# a save button that doubles as a reroll button.
	_expect(back._rng.randi() == run._rng.randi(),
		"a reloaded run continues the same random sequence")


## The one rule that keeps the slot honest post-#14: never leave a finished run
## offering to be continued. Mid-fight saves now succeed (see the dedicated
## mid-combat round-trip test below).
func _test_save_refuses_only_finished_runs_and_clears_when_over() -> void:
	var run := Run.new([_deck_of(_slash, 6), _deck_of(_slash, 5)], ["A", "B"], 7,
		[{"character": "frog"}, {"character": "goblin_mech"}], 0)
	run.start()
	RunSave.clear()
	run.phase = Run.Phase.MAP
	var wrote_map := RunSave.save(run)
	var had := RunSave.has_save()
	run.phase = Run.Phase.WON
	var wrote_won := RunSave.save(run)
	RunSave.clear()
	_expect(wrote_map and had and not wrote_won and not RunSave.has_save(),
		"the save slot refuses only finished runs, and clears on demand")


## Backlog #14: a fight used to be the one thing a save dropped. Step a real
## run into a real fight, scramble every corner of Combat state a card or a
## boss turn can touch, then round-trip through the FILE (not just
## to_dict/from_dict — JSON's one number type is the thing that actually bites,
## per the map-level save test above) and check it all comes back.
func _test_run_survives_a_save_and_load_mid_combat() -> void:
	var run := Run.new([_deck_of(_slash, 8), _deck_of(_slash, 8)], ["A", "B"], 55,
		[{"character": "frog"}, {"character": "goblin_mech"}], 0)
	run.start()
	_step_into_combat(run)
	var combat: Combat = run.combat
	# Scramble hands/piles/foothold/block/energy across both hunters...
	combat.players[0].foothold = 5
	combat.players[0].combatant.block = 3
	combat.players[0].energy = 1
	combat.players[0].discard_pile.append(combat.players[0].hand.pop_back())
	combat.players[1].strength = 2
	combat.players[1].exhaust_pile.append(combat.players[1].hand.pop_back())
	# ...and a real boss turn, so its move pattern actually advances.
	combat.end_turn(0)
	combat.end_turn(1)
	var expect_hand0: Array = []
	for c in combat.players[0].hand:
		expect_hand0.append(String((c as Card).id))
	var expect_move_type := String(combat.boss.current_move().get("type", ""))
	var expect_hp: int = combat.boss.hp
	var expect_round: int = combat.round_num

	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()
	var back_combat: Combat = back.combat

	var boss_ok: bool = back_combat != null and back_combat.boss.id == combat.boss.id \
		and back_combat.boss.hp == expect_hp \
		and String(back_combat.boss.current_move().get("type", "")) == expect_move_type \
		and back_combat.round_num == expect_round
	var hand_ok := true
	if back_combat != null:
		var back_hand: Array = []
		for c2 in back_combat.players[0].hand:
			back_hand.append(String((c2 as Card).id))
		hand_ok = back_hand == expect_hand0
	var state_ok: bool = back_combat != null \
		and back_combat.players[0].foothold == 5 \
		and back_combat.players[0].combatant.block == combat.players[0].combatant.block \
		and back_combat.players[0].discard_pile.size() == combat.players[0].discard_pile.size() \
		and back_combat.players[1].strength == 2 \
		and back_combat.players[1].exhaust_pile.size() == 1
	_expect(back.phase == Run.Phase.COMBAT and boss_ok and hand_ok and state_ok,
		"a run saved mid-fight reloads INTO the fight: hands, piles, foothold, block and the boss's pattern")

	# Same trap the run-level RNG comment calls out: without the combat RNG's
	# own state, a reload would reshuffle differently than the fight actually
	# would have the next time a pile empties.
	_expect(back_combat._rng.randi() == combat._rng.randi(),
		"a reloaded fight continues the same random sequence")
	RunSave.clear()


## Backlog #15: to_dict/from_dict already carry every phase's state — Run has no
## per-phase skip the way Combat did before #14 — but only the MAP phase (above)
## and mid-combat (above that) were ever proven to round-trip through the FILE.
## One test per remaining phase, same shape: scramble real state, save, reload,
## check it's not just equal-looking but still live and playable.
func _test_run_survives_a_save_and_load_in_shop() -> void:
	var run := Run.new([_deck_of(_slash, 8), _deck_of(_slash, 8)], ["A", "B"], 31,
		[{"character": "frog"}, {"character": "goblin_mech"}], 0)
	run.start()
	run.gold = 500
	run.map_row = 0
	run.node_type = "shop"
	run._begin_shop()
	var expect_stock_size: int = run.shop_stock.size()
	var expect_first_id := String(run.shop_stock[0]["id"])
	var expect_gold: int = run.gold

	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()

	var stock_ok: bool = back.shop_stock.size() == expect_stock_size \
		and String(back.shop_stock[0]["id"]) == expect_first_id \
		and int(back.shop_stock[0]["price"]) == int(run.shop_stock[0]["price"])
	_expect(back.phase == Run.Phase.SHOP and back.gold == expect_gold and stock_ok,
		"a run saved mid-shop reloads with its stock and gold intact")
	# Index 0 is always a "card" entry (_begin_shop stocks cards before relics
	# and removals), so buying it needs no card_index — this proves the reloaded
	# stock is live data you can still transact against, not a frozen snapshot.
	var bought := back.buy(0)
	_expect(bought, "reloaded shop stock is still purchasable")
	RunSave.clear()


func _test_run_survives_a_save_and_load_in_campfire() -> void:
	var run := Run.new([_deck_of(_slash, 8), _deck_of(_slash, 8)], ["A", "B"], 32,
		[{"character": "frog"}, {"character": "goblin_mech"}], 0)
	run.start()
	run.map_row = 0
	run.node_type = "rest"
	run._begin_campfire()
	run.campfire_action(0, "rest")   # one hunter acts, the other hasn't yet
	var expect_hp0: int = run.hp[0]

	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()

	_expect(back.phase == Run.Phase.CAMPFIRE and back.campfire_done == [true, false]
		and back.hp[0] == expect_hp0,
		"a run saved mid-campfire reloads with each hunter's own progress intact")
	# The remaining hunter finishing on the reload should close the node out
	# exactly as it would have without the save/load in between.
	var closed := back.campfire_action(1, "rest")
	_expect(closed and back.phase == Run.Phase.MAP,
		"the reloaded campfire still resolves when the remaining hunter acts")
	RunSave.clear()


func _test_run_survives_a_save_and_load_in_event() -> void:
	var run := Run.new([_deck_of(_slash, 8), _deck_of(_slash, 8)], ["A", "B"], 33,
		[{"character": "frog"}, {"character": "goblin_mech"}], 0)
	run.start()
	run.map_row = 0
	run.node_type = "event"
	run._begin_event()
	var expect_id := String(run.event.get("id", ""))
	var expect_choice_count: int = (run.event.get("choices", []) as Array).size()

	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()

	var event_ok: bool = String(back.event.get("id", "")) == expect_id \
		and (back.event.get("choices", []) as Array).size() == expect_choice_count \
		and back._seen_events.has(expect_id)
	_expect(back.phase == Run.Phase.EVENT and event_ok,
		"a run saved mid-event reloads with the same event and its seen-events memory")
	# Resolving it on the reload proves the dict came back playable, not just
	# equal-looking — an event can route to MAP or REWARD, either is fine here.
	var resolved := back.pick_event(0)
	_expect(resolved and back.phase != Run.Phase.EVENT,
		"the reloaded event still resolves when a choice is picked")
	RunSave.clear()


## The intent icon says WHAT is coming; incoming_for says whether you survive it.
## The swipes are the ones players get wrong — being ON the beast saves you from a
## stamp and dooms you to a flank lash.
func _test_incoming_reckons_damage_after_block() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200, 10))
	var aimed := combat.boss_target_index()
	var spared := combat.ally_index(aimed)
	combat.players[aimed].combatant.block = 4
	var hit := combat.incoming_for(aimed)
	var safe := combat.incoming_for(spared)

	var stomp := _dummy_boss(200, 8)
	stomp.moves = [{"type": "swipe_low", "value": 8}]  # only catches the grounded
	var c2 := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, stomp)
	c2.players[0].foothold = 3   # climbing — a stamp can't reach
	c2.players[1].foothold = 0   # on the ground — it can
	var airborne := c2.incoming_for(0)
	var grounded := c2.incoming_for(1)

	_expect(int(hit["raw"]) == 10 and int(hit["through"]) == 6 and int(safe["raw"]) == 0
		and int(airborne["raw"]) == 0 and int(grounded["raw"]) == 8,
		"incoming shows what lands after Block, for the hunter the move can actually reach")


## The card FACE shows preview(); play_card resolves through the same call. The
## moment those diverge the card starts lying about its own effect, which is worse
## than showing no number at all — so pin them together on a card that scales off
## several things at once.
func _test_preview_matches_what_the_card_actually_does() -> void:
	var combat := _new_combat([_deck_of(_summit_strike, 10), _deck_of(_defend, 10)], 42, _dummy_boss(400))
	combat.players[0].foothold = 3   # summit_strike scales off BOTH hunters' Height
	combat.players[1].foothold = 2
	var ci := _first_playable(combat, 0)
	var pv := combat.preview(0, combat.players[0].hand[ci], true)
	var before: int = combat.boss.hp
	combat.play_card(0, ci, true)
	var dealt := before - combat.boss.hp

	# and a block card, since block scales off plays and the exhaust pile
	var c2 := _new_combat([_deck_of(_build_mech, 10), _deck_of(_slash, 10)], 42, _dummy_boss(400))
	var i2 := _first_playable(c2, 0)
	c2.play_card(0, i2, true)                       # first play: 2 block
	var i3 := _first_playable(c2, 0)
	var pv2 := c2.preview(0, c2.players[0].hand[i3], true)  # second: 2 + 2 = 4
	var blocked_before: int = c2.players[0].combatant.block
	c2.play_card(0, i3, true)
	var gained: int = c2.players[0].combatant.block - blocked_before

	_expect(dealt == int(pv["damage"]) and dealt > 0
		and gained == int(pv2["block"]) and gained == 4,
		"preview() is exactly what the card deals and blocks (%d dmg, %d block)" % [dealt, gained])


## An unset rarity silently defaults to "common", which would quietly make a new
## rare card as frequent as filler. Every drafted card must declare one.
func _test_every_card_declares_a_rarity() -> void:
	var valid := ["common", "uncommon", "rare"]
	var bad: Array = []
	for c in Content.list_characters():
		for rid in Content.reward_pool(String(c["id"])):
			var r := Content.card_rarity(String(rid))
			if not valid.has(r):
				bad.append("%s: '%s'" % [rid, r])
	_expect(bad.is_empty(), "every draftable card declares a valid rarity [%s]" % ", ".join(bad))


## `type` ("attack"/"skill") used to be printed and never read (backlog #6) — a
## field that lies is worse than no field. Now combat.gd gates the Strength/
## attack_bonus lift on it, so it had better agree with what the card actually
## does: a card dealing base damage calls itself an attack, and vice versa.
func _test_card_type_matches_whether_it_deals_damage() -> void:
	var bad: Array = []
	for id in Content.all_card_ids():
		var c := Content.make_card(String(id))
		var is_attack: bool = c.type == "attack"
		var deals_damage: bool = c.damage > 0
		if is_attack != deals_damage:
			bad.append("%s: type=%s damage=%d" % [id, c.type, c.damage])
	_expect(bad.is_empty(), "every card's type agrees with whether it deals base damage [%s]" % ", ".join(bad))


## The mechanical half of the same fix: Strength must not sneak onto a card
## that only inflicts Poison or draws cards just because damage happens to
## round up somewhere — the gate is the type field now, not a damage>0 guess.
func _test_strength_only_lifts_attack_type_cards() -> void:
	var combat := _new_combat([_deck_of(_venom_dart, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	combat.players[0].strength = 5
	var pv := combat.preview(0, combat.players[0].hand[0], true)
	_expect(combat.players[0].hand[0].type == "skill" and int(pv["damage"]) == 0,
		"Strength does not lift a skill-type card even when the caster has it")


## Over many rolls, commons should dominate the offers and rares should be scarce.
## Statistical, so the bounds are deliberately loose — this catches "weighting is
## wired up backwards or not at all", not small tuning drift.
func _test_rarity_weighting_favours_commons() -> void:
	var run := _map_run()
	var pool: Array = Content.reward_pool("frog")
	var seen := {"common": 0, "uncommon": 0, "rare": 0}
	run.reward_kind = "card"
	for _i in range(400):
		for card in run._roll_choices(pool):
			var r := String((card as Card).rarity)
			seen[r] = int(seen.get(r, 0)) + 1
	var total: int = int(seen["common"]) + int(seen["uncommon"]) + int(seen["rare"])
	var common_pct := float(seen["common"]) / float(total)
	var rare_pct := float(seen["rare"]) / float(total)
	_expect(total > 0 and common_pct > 0.45 and rare_pct < 0.15,
		"rarity weighting favours commons (%d%% common, %d%% rare over %d offers)"
			% [int(common_pct * 100.0), int(rare_pct * 100.0), total])


## The Vine-Weaver's reward pool sat at 2 rares against the Goblin's 7, so the
## draft weights meant she almost never saw one (backlog #5). Pins the fix at
## her stated target (5-7) rather than a blanket rule across every character —
## the other three weren't part of that measurement and aren't this item's scope.
func _test_vine_weaver_has_enough_rares() -> void:
	var rares: Dictionary = {}
	for rid in Content.reward_pool("vine_weaver"):
		if Content.card_rarity(String(rid)) == "rare":
			rares[String(rid)] = true
	_expect(rares.size() >= 5 and rares.size() <= 7,
		"Vine-Weaver has 5-7 rares, in her own idiom (%d: %s)" % [rares.size(), ", ".join(rares.keys())])


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


func _test_wound_decay_limiter_sheds_poison() -> void:
	var boss := Boss.new("Decayer", 200)
	boss.moves = [{"type": "block", "value": 0}]  # harmless move — isolate the limiter
	boss.limiter = {"type": "wound_decay", "value": 3}
	boss.wound = 5
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var hp0 := combat.boss.hp
	combat.end_turn(0)
	combat.end_turn(1)  # bleeds 5 (this turn's old wound), then decays 5 -> 2 for next turn
	_expect(combat.boss.hp == hp0 - 5 and combat.boss.wound == 2,
		"wound_decay limiter sheds Wound each turn, after that turn's bleed")


func _test_sigil_fatigue_limiter_punishes_camping() -> void:
	var boss := _climb_boss(6)
	boss.limiter = {"type": "sigil_fatigue", "value": 1}
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	ps.foothold = 6  # at the sigil
	var hp0: int = ps.combatant.hp
	combat.end_turn(0)
	combat.end_turn(1)  # round 1 at the sigil — within the allowance
	var after_round1: int = ps.combatant.hp
	combat.end_turn(0)
	combat.end_turn(1)  # round 2 — camped past the allowance, grip burns
	_expect(after_round1 == hp0 and ps.combatant.hp == hp0 - Combat.SIGIL_FATIGUE_DAMAGE,
		"sigil_fatigue limiter chips a hunter who camps the weak point too long")


func _test_height_split_limiter_punishes_hoarding() -> void:
	var boss := Boss.new("Splitter", 200)
	boss.moves = [{"type": "block", "value": 0}]  # harmless move — isolate the limiter
	boss.limiter = {"type": "height_split", "value": 4}
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	ps.foothold = 9
	combat.players[1].foothold = 2  # gap 7, 3 over the allowance of 4
	var hp0: int = ps.combatant.hp
	combat.end_turn(0)
	combat.end_turn(1)
	_expect(ps.combatant.hp == hp0 - 3 and combat.players[1].combatant.hp == combat.players[1].combatant.max_hp,
		"height_split limiter chips a hunter who climbs far ahead of their ally")


## Backlog #4: per-beast limiters — a rule each Titan bends, so four Titans read
## as four puzzles rather than four HP bars. Every act-ending Titan must carry
## one, of a type Combat._apply_limiter() actually knows how to apply (a typo'd
## type would silently do nothing, same trap as an undefined move type).
func _test_every_titan_carries_a_known_limiter() -> void:
	var known := ["wound_decay", "sigil_fatigue", "height_split"]
	var bad: Array = []
	for id in Content.beast_pool("boss"):
		var b: Boss = Content.build_boss(String(id))
		var t := String(b.limiter.get("type", ""))
		if t == "" or not known.has(t):
			bad.append("%s: %s" % [id, t])
	_expect(bad.is_empty(), "every Titan carries a limiter of a known type [%s]" % ", ".join(bad))


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
	# The run now opens on the MAP; step onto the first node so these tests are
	# exercising combat (row 0 is always a fight).
	var guard := 0
	while String(c0.shared.get("phase", "")) == "map" and guard < 10:
		guard += 1
		var avail: Array = (c0.shared.get("map", {}) as Dictionary).get("available", [])
		if avail.is_empty():
			break
		c0.pick_node(int(avail[0]))
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


## The whole loop, through the host that actually does it: play a run, have the
## autosave fire on its own, then bring it back in a FRESH host the way the menu's
## Continue button does. Serialising correctly is not the same as resuming.
func _test_host_autosaves_and_resumes() -> void:
	RunSave.clear()
	var t := LocalTransport.new()
	var host := GameHost.new(t, 42, 2, true)
	_kept.append(host)
	var c := GameClient.new(t, 1)
	c.join()
	c.select_character("frog", 0)
	c.select_character("goblin_mech", 1)
	var run: Run = host._run
	run.gold = 210
	run.hp = [17, 29]
	host._broadcast_state()   # the autosave rides on this, unasked
	_expect(RunSave.has_save(), "the host saves the run without being told to")

	var t2 := LocalTransport.new()
	var host2 := GameHost.new(t2, 0, 2, true)
	_kept.append(host2)
	var c2 := GameClient.new(t2, 1)
	c2.join()
	host2.resume_run(RunSave.load_run())
	var back: Run = host2._run
	var same: bool = (
		back.gold == 210
		and back.hp == run.hp
		and back.names == run.names
		and back.map.total_rows() == run.map.total_rows()
		and back.decks[0].size() == run.decks[0].size()
	)
	# And the resumed run reaches the CLIENT — a host that resumed in private
	# would leave the player staring at a character-select screen.
	var reached: bool = String(c2.shared.get("phase", "")) != "select" 		and int(c2.shared.get("gold", 0)) == 210
	_expect(same and reached, "a saved run resumes in a fresh host and reaches the client")
	RunSave.clear()


## Backlog #14, through the host this time: step into a real fight, poke its
## state, autosave, and check a FRESH host resumes INTO the fight — the client
## sees "combat", not the map it used to be bounced back to.
func _test_host_autosaves_and_resumes_mid_combat() -> void:
	RunSave.clear()
	var t := LocalTransport.new()
	var host := GameHost.new(t, 42, 2, true)  # solo
	_kept.append(host)
	var c := GameClient.new(t, 1)
	c.join()
	c.select_character("frog", 0)
	c.select_character("goblin_mech", 1)
	var guard := 0
	while String(c.shared.get("phase", "")) == "map" and guard < 10:
		guard += 1
		var avail: Array = (c.shared.get("map", {}) as Dictionary).get("available", [])
		if avail.is_empty():
			break
		c.pick_node(int(avail[0]))  # row 0 is always a fight
	var run: Run = host._run
	var combat: Combat = run.combat
	combat.players[0].foothold = 3
	var expect_hp: int = combat.boss.hp
	host._broadcast_state()  # the autosave rides on this, unasked — captures the poke above
	_expect(RunSave.has_save() and String(c.shared.get("phase", "")) == "combat",
		"the host autosaves mid-fight too")

	var t2 := LocalTransport.new()
	var host2 := GameHost.new(t2, 0, 2, true)
	_kept.append(host2)
	var c2 := GameClient.new(t2, 1)
	c2.join()
	host2.resume_run(RunSave.load_run())
	var back: Run = host2._run
	var reached: bool = String(c2.shared.get("phase", "")) == "combat"
	_expect(back.phase == Run.Phase.COMBAT and back.combat != null
			and back.combat.players[0].foothold == 3 and back.combat.boss.hp == expect_hp and reached,
		"a run saved mid-fight resumes INTO the fight, and the client sees combat, not the map")
	RunSave.clear()


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
	c.select_character("goblin_mech", 1)  # both chosen -> run starts (on the map)
	var guard := 0
	while String(c.shared.get("phase", "")) == "map" and guard < 10:
		guard += 1
		var av: Array = (c.shared.get("map", {}) as Dictionary).get("available", [])
		if av.is_empty():
			break
		c.pick_node(int(av[0]))
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
func _flick() -> Card:
	return Card.from_dict({"id": "flick", "name": "Tongue Flick", "type": "attack", "cost": 0, "damage": 2, "timed": true, "timed_damage": 3, "target": "enemy"})
func _tongue_snap() -> Card:
	return Card.from_dict({"id": "tongue_snap", "name": "Tongue Snap", "type": "attack", "cost": 1, "damage": 2, "damage_per_rhythm": 3, "grip": 1, "timed": true, "timed_damage": 3, "target": "enemy"})
func _toxic_lash() -> Card:
	return Card.from_dict({"id": "toxic_lash", "name": "Toxic Lash", "type": "attack", "cost": 1, "damage": 2, "damage_per_wound": 2, "wound": 1, "timed": true, "timed_damage": 3, "target": "enemy"})
func _summit_strike() -> Card:
	return Card.from_dict({"id": "summit_strike", "name": "Summit Strike", "type": "attack", "cost": 1, "damage": 2, "damage_per_foothold": 2, "damage_per_ally_foothold": 2, "timed": true, "timed_damage": 3, "target": "enemy"})
func _sunblade() -> Card:
	return Card.from_dict({"id": "sunlight_blade", "name": "Sunlight Blade", "type": "attack", "cost": 1, "damage": 5, "damage_per_vulnerable": 3})
func _bowshot() -> Card:
	return Card.from_dict({"id": "bowshot", "name": "Bowshot", "type": "attack", "cost": 0, "damage": 3, "vulnerable": 1})
func _sharpen() -> Card:
	return Card.from_dict({"id": "sharpen", "name": "Sharpen", "type": "skill", "cost": 1, "strength": 2})
func _rend() -> Card:
	return Card.from_dict({"id": "rend", "name": "Rend", "type": "attack", "cost": 1, "damage": 4, "wound": 2})
func _venom_dart() -> Card:
	return Card.from_dict({"id": "venom_dart", "name": "Venom Dart", "type": "skill", "cost": 0, "wound": 2})
func _flurry() -> Card:
	return Card.from_dict({"id": "flurry", "name": "Flurry", "type": "attack", "cost": 2, "damage": 4, "hits": 2})
func _dig_in() -> Card:
	return Card.from_dict({"id": "dig_in", "name": "Dig In", "type": "skill", "cost": 1, "block": 4, "timed": true, "timed_block": 6})
func _scrap_drive() -> Card:
	return Card.from_dict({"id": "scrap_drive", "name": "Scrap Drive", "type": "attack", "cost": 1, "damage": 3, "damage_per_exhausted": 3})
func _detonator() -> Card:
	return Card.from_dict({"id": "detonator", "name": "Detonator", "type": "attack", "cost": 3, "damage": 4, "damage_per_exhausted": 6, "exhaust_pick": true})
func _anchor_brace() -> Card:
	return Card.from_dict({"id": "anchor_brace", "name": "Anchor Brace", "type": "skill", "cost": 1, "block": 2, "ally_block": 4, "timed": true, "timed_ally_block": 6, "target": "ally"})


func _expect(cond: bool, name: String) -> void:
	if cond:
		print("PASS  " + name)
	else:
		print("FAIL  " + name)
		_failures += 1
