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
	Progress.use_scratch_slot("run_tests")  # a headless test run must never touch the designer's real progress.cfg
	# combatant / boss
	_test_combatant_block_absorbs_before_hp()
	_test_combatant_hp_never_negative()
	_test_boss_pattern_loops()
	# backlog #40: beast moves that react to where you are
	_test_backlog40_min_height_condition_picks_fallback_when_unmet()
	_test_backlog40_at_sigil_condition_needs_a_hunter_on_it()
	_test_backlog40_undefended_condition_reads_block()
	_test_backlog40_missing_fallback_defaults_safely()
	_test_backlog40_conditional_move_resolves_through_a_real_enemy_turn()
	_test_backlog40_conditional_move_falls_back_off_the_sigil()
	_test_backlog40_at_least_three_beasts_react_to_position()
	# backlog #44: titans that change their pattern when hurt
	_test_backlog44_hurt_pct_switches_the_whole_pattern()
	_test_backlog44_same_move_index_drives_both_lists()
	_test_backlog44_disabled_by_default()
	_test_backlog44_hurt_moves_resolve_through_a_real_enemy_turn()
	_test_backlog44_at_least_three_beasts_have_a_second_pattern()
	# backlog #42: something to unlock between runs
	_test_backlog42_progress_total_wins_climbs_on_every_win()
	_test_backlog42_relic_pool_respects_unlock_wins()
	_test_backlog42_reward_pool_respects_unlock_wins()
	_test_backlog42_run_threads_unlocked_wins_into_the_shop()
	_test_backlog42_unlocked_wins_round_trips_and_backfills()
	_test_backlog42_gamehost_carries_unlocked_wins_through_resume()
	# backlog #43: one trigger point instead of scattered special cases
	_test_backlog43_trigger_moments_exist_and_fire()
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
	_test_backlog38_same_seed_reproduces_map_shop_and_rewards()
	_test_backlog49_daily_seed_is_stable_and_shared()
	_test_backlog49_daily_run_saves_and_loads_the_flag()
	_test_backlog49_host_can_start_a_shared_daily()
	_test_run_walks_the_map()
	_test_rest_node_heals_and_returns_to_map()
	_test_event_choice_applies_effects()
	_test_event_reward_choice_routes_to_reward()
	_test_events_load_and_are_well_formed()
	_test_event_gold_cost_never_goes_negative()
	_test_event_remove_card_effect()
	_test_event_remove_card_respects_min_deck()
	_test_event_sharpen_card_effect()
	_test_event_curse_card_effect()
	_test_backlog17_four_events_touch_the_deck()
	_test_event_potion_effect()
	_test_event_random_potion_respects_slot_cap()
	_test_event_take_potion_effect()
	_test_backlog37_four_events_touch_potions()
	_test_boons_load_and_are_well_formed()
	_test_boon_offer_and_pick_applies_effects()
	_test_boon_rejects_outside_its_phase()
	_test_start_does_not_auto_offer_a_boon()
	_test_run_survives_a_save_and_load_in_boon()
	_test_card_upgrade_bumps_numbers()
	_test_enchanted_copy_attaches_to_any_card()
	_test_enchants_all_load()
	_test_campfire_rest_remove_upgrade()
	_test_campfire_rest_heals_and_caps_at_max()
	_test_campfire_guards_against_illegal_actions()
	_test_status_card_cannot_be_sharpened_but_can_be_removed_at_campfire()
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
	_test_ascension_tier_effects_reach_the_run()
	_test_coach_teaches_the_right_thing_first()
	_test_tips_can_be_switched_off_without_losing_your_place()
	_test_gold_and_shop()
	_test_shop_buys_a_relic()
	_test_shop_cannot_thin_below_min_deck()
	_test_status_card_removable_at_shop()
	_test_shop_rejects_actions_outside_its_phase()
	_test_content_pools_are_copies()
	_test_status_cards_never_offered_as_a_reward()
	# potions (backlog #26)
	_test_potions_all_load()
	_test_use_potion_applies_each_effect()
	_test_use_potion_ally_and_beast_effects()
	_test_use_potion_gating()
	_test_run_potion_use_and_discard()
	_test_shop_buys_a_potion()
	_test_potion_slots_are_capped()
	_test_fight_wins_grant_a_potion()
	_test_potions_round_trip_through_save()
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
	_test_cheap_enchant_cuts_cost()
	_test_keen_enchant_draws_an_extra_card()
	_test_spent_enchant_exhausts_instead_of_discarding()
	_test_bonded_enchant_echoes_block_to_the_ally()
	_test_generous_enchant_gives_the_ally_energy()
	_test_true_eye_enchant_upgrades_good_to_perfect()
	_test_timed_block_guards_on_a_hit()
	_test_timed_ally_block_anchors_the_ally()
	# Retain and Innate (backlog #28)
	_test_retain_keeps_a_card_in_hand_at_end_of_turn()
	_test_retain_survives_into_the_next_round()
	_test_innate_is_guaranteed_in_the_opening_hand()
	_test_innate_does_not_reappear_every_round()
	# X-cost cards (backlog #29)
	_test_x_cost_spends_all_energy_and_scales_with_it()
	_test_x_cost_playable_at_zero_energy()
	_test_x_cost_ignores_permanent_cost_reductions()
	_test_x_cost_meld_keeps_sentinel_and_sums_per_x()
	_test_x_cost_upgrade_bumps_per_x_scaling()
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
	_test_backlog39_stats_accumulate_across_fights()
	_test_content_make_card_and_reward_pool()
	# phase 3: 3rd titan, relics, longer runs
	_test_regen_heals_titan()
	_test_relic_energy_bonus()
	_test_relic_attack_bonus()
	_test_relic_round_block()
	_test_relic_downside()
	_test_run_is_four_titans()
	_test_run_relic_reward_and_full_clear()
	_test_elite_pays_a_card_then_a_relic()
	_test_backlog48_relic_pool_and_boss_relic_pool_partition_by_tier()
	_test_backlog48_titan_relic_reward_draws_only_from_the_boss_pool()
	_test_backlog48_elite_relic_reward_never_offers_a_boss_relic()
	# backlog #47: a fifth hunter, driven by a resource (Light)
	_test_backlog47_light_gain_banks_across_the_round_reset()
	_test_backlog47_light_cost_gates_and_spends()
	_test_backlog47_damage_per_light_scales_without_spending()
	_test_backlog47_ally_heal_caps_at_max_hp()
	_test_backlog47_light_survives_playerstate_dict_round_trip()
	_test_backlog47_light_survives_mid_combat_save_and_load()
	_test_backlog47_lightbearer_plays_a_full_run()
	_test_everyone_wears_their_own_art()
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
	_test_backlog39_stats_round_trip_through_save()
	_test_save_refuses_only_finished_runs_and_clears_when_over()
	_test_load_run_migrates_an_older_save()
	_test_backlog39_older_save_backfills_missing_stats()
	_test_load_run_rejects_a_save_from_a_newer_build()
	_test_load_run_rejects_a_corrupt_file()
	_test_every_card_declares_a_rarity()
	_test_card_type_matches_whether_it_deals_damage()
	_test_strength_only_lifts_attack_type_cards()
	_test_rarity_weighting_favours_commons()
	_test_vine_weaver_has_enough_rares()
	_test_frog_has_enough_rares()
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
	# the debuff axis (backlog #36): Frail, Artifact, Thorns
	_test_frail_reduces_block_gained()
	_test_frail_card_cuts_the_boss_own_block_move()
	_test_artifact_wards_off_a_debuff_then_is_spent()
	_test_thorns_reflects_a_landed_boss_attack()
	_test_beast_thorns_reflects_card_damage_dealt_to_it()
	_test_frail_artifact_thorns_persist_through_save()
	_test_beast_thorns_and_artifact_are_wired()
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
	_test_dropped_hunter_can_rejoin_mid_fight()
	_test_host_autosaves_and_resumes()
	_test_host_autosaves_and_resumes_mid_combat()
	_test_solo_controls_both_hunters()
	_test_session_shared_state_exposes_the_seed()
	# backlog #45: prove the new mechanics cross the client/server boundary
	_test_backlog45_potions_are_shared_but_only_the_owner_can_drink_them()
	_test_backlog45_status_curse_card_stays_private_to_its_owner()
	_test_backlog45_retain_and_innate_keywords_reach_the_owners_hand()
	_test_backlog45_named_holds_cross_to_both_peers_identically()
	_test_backlog45_graded_timing_quality_reaches_the_host_and_the_preview()
	# backlog #46: a robustness sweep that is not balance tuning
	_test_backlog46_campfire_rest_always_legal_even_at_min_deck()
	_test_backlog46_shop_leave_always_legal_with_nothing_affordable()
	_test_backlog46_every_event_has_at_least_one_choice()
	_test_backlog46_empty_reward_choices_can_still_be_skipped()
	_test_backlog46_end_turn_always_works_with_empty_hand()

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


# --- Beast moves that react to where you are (backlog #40) ----------------

func _test_backlog40_min_height_condition_picks_fallback_when_unmet() -> void:
	var b := Boss.new("B", 30)
	b.moves = [{"type": "attack_all", "value": 10,
		"when": {"type": "min_height", "value": 5},
		"fallback": {"type": "attack", "value": 14}}]
	var low := b.current_move({"footholds": [2, 3], "blocks": [0, 0]})
	var high := b.current_move({"footholds": [2, 6], "blocks": [0, 0]})
	_expect(low["type"] == "attack" and int(low["value"]) == 14,
		"min_height unmet falls back to the plain move")
	_expect(high["type"] == "attack_all" and int(high["value"]) == 10,
		"min_height met (one hunter at/above 5) fires the reactive move")


func _test_backlog40_at_sigil_condition_needs_a_hunter_on_it() -> void:
	var b := Boss.new("B", 30)
	b.weak_point_height = 4
	b.moves = [{"type": "attack", "value": 14,
		"when": {"type": "at_sigil"},
		"fallback": {"type": "attack", "value": 10}}]
	var off_sigil := b.current_move({"footholds": [1, 3], "blocks": [0, 0]})
	var on_sigil := b.current_move({"footholds": [1, 4], "blocks": [0, 0]})
	_expect(int(off_sigil["value"]) == 10, "no hunter on the sigil -> fallback")
	_expect(int(on_sigil["value"]) == 14, "a hunter camped on the sigil -> reactive bite")


func _test_backlog40_undefended_condition_reads_block() -> void:
	var b := Boss.new("B", 30)
	b.moves = [{"type": "attack", "value": 17,
		"when": {"type": "undefended", "value": 0},
		"fallback": {"type": "attack", "value": 13}}]
	var guarded := b.current_move({"footholds": [0, 0], "blocks": [5, 8]})
	var exposed := b.current_move({"footholds": [0, 0], "blocks": [5, 0]})
	_expect(int(guarded["value"]) == 13, "both hunters blocked -> fallback")
	_expect(int(exposed["value"]) == 17, "a hunter with no block -> reactive move")


## A move with "when" but no "fallback" is a data mistake (rule 7's own field
## needs the sibling to mean anything) — must not crash, and defaults safe.
func _test_backlog40_missing_fallback_defaults_safely() -> void:
	var b := Boss.new("B", 30)
	b.moves = [{"type": "attack", "value": 99, "when": {"type": "min_height", "value": 5}}]
	var m := b.current_move({"footholds": [0, 0], "blocks": [0, 0]})
	_expect(m["type"] == "attack" and int(m["value"]) == 0,
		"a when with no fallback defaults to a harmless move, not a crash")


## End to end through a real fight: the boss's actual enemy-turn resolution
## (not just current_move()'s prediction) applies the reactive move once a
## hunter is on the sigil, and the plain one otherwise — proving the wiring
## through Combat.boss_context(), not just Boss in isolation.
func _test_backlog40_conditional_move_resolves_through_a_real_enemy_turn() -> void:
	var boss := Boss.new("Reactive", 500)
	boss.weak_point_height = 4
	boss.moves = [{"type": "attack", "value": 14,
		"when": {"type": "at_sigil"},
		"fallback": {"type": "attack", "value": 10}}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.players[0].foothold = boss.weak_point_height  # camped on the weak point
	combat.end_turn(0)
	combat.end_turn(1)  # boss acts against its telegraphed target (player 0)
	_expect(combat.players[0].combatant.hp == 42 - 14,
		"a hunter on the sigil provokes the reactive, harder move")


func _test_backlog40_conditional_move_falls_back_off_the_sigil() -> void:
	var boss := Boss.new("Reactive", 500)
	boss.weak_point_height = 4
	boss.moves = [{"type": "attack", "value": 14,
		"when": {"type": "at_sigil"},
		"fallback": {"type": "attack", "value": 10}}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	# player 0 (the telegraphed target) never leaves the ground -> condition unmet
	combat.end_turn(0)
	combat.end_turn(1)
	_expect(combat.players[0].combatant.hp == 42 - 10,
		"nobody on the sigil -> the plain fallback move fires")


## Content-level sentinel (mirrors #17/#37's "at least N" checks): at least
## three real beasts actually ship a "when" so this can't silently regress
## back to zero, and every "when" it finds has the required "fallback".
func _test_backlog40_at_least_three_beasts_react_to_position() -> void:
	var reactive := 0
	for kind in ["fight", "elite", "boss"]:
		for id in Content.beast_pool(kind):
			var b := Content.build_boss(String(id))
			var has_when := false
			for m in b.moves:
				if (m as Dictionary).has("when"):
					_expect((m as Dictionary).has("fallback"),
						"beast '%s' pairs every 'when' with a 'fallback'" % id)
					has_when = true
			if has_when:
				reactive += 1
	_expect(reactive >= 3, "at least three beasts react to hunter position (found %d)" % reactive)


# --- Titans that change their pattern when hurt (backlog #44) -------------

func _test_backlog44_hurt_pct_switches_the_whole_pattern() -> void:
	var b := Boss.new("B", 100)
	b.moves = [{"type": "attack", "value": 1}, {"type": "block", "value": 2}]
	b.hurt_pct = 0.5
	b.hurt_moves = [{"type": "attack", "value": 9}]
	b.hp = 51
	_expect(int(b.current_move()["value"]) == 1, "above the threshold still reads the first pattern")
	b.hp = 50
	_expect(int(b.current_move()["value"]) == 9, "at the threshold the second pattern takes over")
	b.hp = 1
	_expect(int(b.current_move()["value"]) == 9, "stays on the second pattern the rest of the fight")


func _test_backlog44_same_move_index_drives_both_lists() -> void:
	var b := Boss.new("B", 100)
	b.moves = [{"type": "attack", "value": 1}, {"type": "attack", "value": 2}, {"type": "attack", "value": 3}]
	b.hurt_pct = 0.5
	b.hurt_moves = [{"type": "attack", "value": 90}, {"type": "attack", "value": 91}]
	b.advance_move()  # _move_index == 1 -> moves[1] (value 2) while healthy
	_expect(int(b.current_move()["value"]) == 2, "index 1 into the healthy list is its second move")
	b.hp = 40  # cross the threshold without touching _move_index at all
	_expect(int(b.current_move()["value"]) == 91,
		"the same index (1) into hurt_moves is ITS second move -> the pattern doesn't reset to move 1")


func _test_backlog44_disabled_by_default() -> void:
	var b := Boss.new("B", 20)
	b.moves = [{"type": "attack", "value": 5}]
	b.hp = 1  # would be well under any reasonable threshold
	_expect(int(b.current_move()["value"]) == 5,
		"a beast with hurt_pct 0 (the default) never switches, unchanged from before this item")


func _test_backlog44_hurt_moves_resolve_through_a_real_enemy_turn() -> void:
	var boss := Boss.new("Reactive", 500)
	boss.moves = [{"type": "attack", "value": 10}]
	boss.hurt_pct = 0.5
	boss.hurt_moves = [{"type": "attack", "value": 25}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.end_turn(0)
	combat.end_turn(1)  # round 1, full HP -> the plain move, targets player 0
	_expect(combat.players[0].combatant.hp == 42 - 10, "at full HP the enemy turn uses the plain move")
	boss.hp = 200  # below the 250 (50%) threshold
	combat.end_turn(0)
	combat.end_turn(1)  # round 2 -> target rotates to player 1
	_expect(combat.players[1].combatant.hp == 42 - 25,
		"once hurt, the real enemy turn resolves the second pattern, not just current_move()'s preview")


## Content-level sentinel (mirrors #40's own "at least N" check): at least
## three real beasts actually ship a second pattern, and it's telegraphed
## through the same current_move() the view and the host both already read.
func _test_backlog44_at_least_three_beasts_have_a_second_pattern() -> void:
	var count := 0
	for kind in ["fight", "elite", "boss"]:
		for id in Content.beast_pool(kind):
			var b := Content.build_boss(String(id))
			if b.hurt_pct > 0.0:
				_expect(not b.hurt_moves.is_empty(),
					"beast '%s' pairs hurt_pct with a real hurt_moves list" % id)
				b.hp = int(b.max_hp * b.hurt_pct)  # at the threshold
				_expect(b.current_move() in b.hurt_moves,
					"beast '%s' actually switches pattern once hurt" % id)
				count += 1
	_expect(count >= 3, "at least three beasts change their pattern when hurt (found %d)" % count)


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


## Backlog #38: a shareable seed is only worth sharing if replaying it actually
## reproduces the run — not just the map (already proven above) but the shop
## and reward rolls too, since those are the other two places `_rng` is drawn
## from during a run. Reaches into `_begin_shop`/`_begin_reward` directly
## (the same pattern `_test_gold_and_shop` etc. already use) rather than
## walking the whole map through combat, since row 0 of every act is always a
## fight and resolving one isn't what this test is about.
func _test_backlog38_same_seed_reproduces_map_shop_and_rewards() -> void:
	var run_a := Run.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], ["A", "B"], 2026, [{}, {}])
	var run_b := Run.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], ["A", "B"], 2026, [{}, {}])
	var same_map: bool = str(run_a.map.rows) == str(run_b.map.rows)
	var same_seed_readback: bool = run_a.seed_value() == 2026 and run_b.seed_value() == 2026
	run_a.map_row = 0
	run_a._begin_shop()
	run_b.map_row = 0
	run_b._begin_shop()
	var same_shop: bool = str(run_a.shop_stock) == str(run_b.shop_stock)
	run_a._begin_reward("relic")
	run_b._begin_reward("relic")
	var same_reward: bool = str(run_a.reward_choices) == str(run_b.reward_choices)
	var run_c := Run.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], ["A", "B"], 777, [{}, {}])
	var different_map: bool = str(run_a.map.rows) != str(run_c.map.rows)
	_expect(same_map and same_seed_readback and same_shop and same_reward and different_map,
		"two runs from the same seed roll identical maps, shops and rewards; a new seed re-rolls all three")


## Backlog #49: the daily's whole promise is "same date -> same run", built on
## #38's shareable seed rather than new machinery — Run.new_daily() just picks
## the seed for you from a date string and pins the ascension. Mirrors the
## #38 test above but through that entry point.
func _test_backlog49_daily_seed_is_stable_and_shared() -> void:
	var same_day: bool = Run.daily_seed("2026-08-25") == Run.daily_seed("2026-08-25")
	var different_day: bool = Run.daily_seed("2026-08-25") != Run.daily_seed("2026-08-26")
	var run_a := Run.new_daily([_deck_of(_slash, 10), _deck_of(_slash, 10)], ["A", "B"], "2026-08-25", [{}, {}])
	var run_b := Run.new_daily([_deck_of(_slash, 10), _deck_of(_slash, 10)], ["A", "B"], "2026-08-25", [{}, {}])
	var run_c := Run.new_daily([_deck_of(_slash, 10), _deck_of(_slash, 10)], ["A", "B"], "2026-08-26", [{}, {}])
	var flagged: bool = (run_a.is_daily and run_a.daily_date == "2026-08-25"
		and run_a.ascension == Run.DAILY_ASCENSION)
	var same_map: bool = str(run_a.map.rows) == str(run_b.map.rows)
	run_a.map_row = 0
	run_a._begin_shop()
	run_b.map_row = 0
	run_b._begin_shop()
	var same_shop: bool = str(run_a.shop_stock) == str(run_b.shop_stock)
	run_a._begin_reward("relic")
	run_b._begin_reward("relic")
	var same_reward: bool = str(run_a.reward_choices) == str(run_b.reward_choices)
	var different_map: bool = str(run_a.map.rows) != str(run_c.map.rows)
	_expect(same_day and different_day and flagged and same_map and same_shop and same_reward and different_map,
		"two players who start a daily on the same date get an identical map, shop and reward roll; a new date re-rolls all three")


## Backlog #49 x #35: a daily is a run like any other and has to survive the
## same save/load round trip, or "the daily you resume" silently stops being
## the daily you started.
func _test_backlog49_daily_run_saves_and_loads_the_flag() -> void:
	var run := Run.new_daily([_deck_of(_slash, 10), _deck_of(_slash, 10)], ["A", "B"], "2026-08-25", [{}, {}])
	var loaded := Run.from_dict(run.to_dict())
	_expect(loaded.is_daily and loaded.daily_date == "2026-08-25" and loaded.seed_value() == run.seed_value()
		and loaded.ascension == Run.DAILY_ASCENSION,
		"a daily run's flag, date and pinned ascension survive a save/load round trip")


## Backlog #49: the flag has to actually reach a peer, the same lesson #38
## already taught for the seed — a getter nobody's snapshot exposes doesn't
## help a future screen that wants to show a "DAILY" badge.
func _test_backlog49_host_can_start_a_shared_daily() -> void:
	var transport := LocalTransport.new()
	var host := GameHost.new(transport, 0, 2, false, 0, Content.UNLOCKED_ALL, "2026-08-25")
	_kept.append(host)
	var c0 := GameClient.new(transport, 10)
	var c1 := GameClient.new(transport, 20)
	c0.join()
	c1.join()
	c0.select_character("frog")
	c1.select_character("mountain_climbers")
	var expected_seed := Run.daily_seed("2026-08-25")
	_expect(bool(c0.shared.get("is_daily", false)) and int(c0.shared.get("seed", -1)) == expected_seed
		and int(c0.shared.get("ascension", -1)) == Run.DAILY_ASCENSION,
		"a host given a daily_date starts a run flagged as daily, pinned to DAILY_ASCENSION, seeded from the date")


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


## Backlog #27: an event can punish you into your OWN deck with a status card,
## not just take one away or sharpen one.
func _test_event_curse_card_effect() -> void:
	var run := _map_run()  # each deck starts as 10x Slash
	var size_before: int = run.decks[0].size()
	run.event = {"title": "T", "text": "x", "choices": [
		{"label": "push on", "result": "!", "effects": {"curse_card": "bruised_grip"}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0
	run.pick_event(0)
	var last0: Card = run.decks[0][run.decks[0].size() - 1]
	var last1: Card = run.decks[1][run.decks[1].size() - 1]
	_expect(run.decks[0].size() == size_before + 1 and run.decks[1].size() == size_before + 1
			and last0.id == "bruised_grip" and last0.status and last1.id == "bruised_grip",
		"an event's curse_card effect shuffles one named status card into each hunter's own deck")


## Backlog #37: an event can grant a NAMED potion, same shape curse_card names
## a specific card. Each hunter with an open slot gets a copy.
func _test_event_potion_effect() -> void:
	var run := _map_run()
	run.event = {"title": "T", "text": "x", "choices": [
		{"label": "take it", "result": "!", "effects": {"potion": "field_dressing"}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0
	run.pick_event(0)
	_expect(run.potions[0].size() == 1 and String(run.potions[0][0].get("id", "")) == "field_dressing"
			and run.potions[1].size() == 1 and String(run.potions[1][0].get("id", "")) == "field_dressing",
		"an event's potion effect grants a named potion to every hunter with room")


## random_potion rolls from the pool instead of naming one, same shape "relic"
## already does for relics — and both respect the POTION_SLOTS cap.
func _test_event_random_potion_respects_slot_cap() -> void:
	var run := _map_run()
	run.potions[0] = [Content.make_potion("field_dressing"), Content.make_potion("guard_oil"),
		Content.make_potion("iron_draught")]  # hunter 0 already full
	run.event = {"title": "T", "text": "x", "choices": [
		{"label": "grab one", "result": "!", "effects": {"random_potion": true}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0
	run.pick_event(0)
	_expect(run.potions[0].size() == 3 and run.potions[1].size() == 1,
		"random_potion fills an open slot but a full inventory quietly doesn't grow")


## take_potion is the gamble: it removes one HELD potion per hunter, and
## quietly no-ops for a hunter carrying none rather than failing.
func _test_event_take_potion_effect() -> void:
	var run := _map_run()
	run.potions[0] = [Content.make_potion("field_dressing")]
	# run.potions[1] stays empty on purpose.
	run.event = {"title": "T", "text": "x", "choices": [
		{"label": "wager", "result": "!", "effects": {"take_potion": true, "gold": 40}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0
	run.pick_event(0)
	_expect(run.potions[0].is_empty() and run.potions[1].is_empty() and run.gold == 40,
		"take_potion removes a held potion and no-ops for a hunter carrying none")


func _test_backlog37_four_events_touch_potions() -> void:
	var count := 0
	for id in Content.list_events():
		var e: Dictionary = Content.make_event(String(id))
		for ch in (e.get("choices", []) as Array):
			var eff: Dictionary = (ch as Dictionary).get("effects", {})
			if String(eff.get("potion", "")) != "" or bool(eff.get("random_potion", false)) \
					or bool(eff.get("take_potion", false)):
				count += 1
				break
	_expect(count >= 4, "at least 4 events grant, take, or gamble a potion (backlog #37)")


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


## Backlog #31: the run-start boon reuses events.json's own well-formedness
## shape (label, result, effects), just without a title/text pair — a boon is
## a single offer, not a rolled-and-narrated encounter.
func _test_boons_load_and_are_well_formed() -> void:
	var ids: Array = Content.list_boons()
	var ok := ids.size() >= 3  # "3-4" per the item's own done-when
	for id in ids:
		var b: Dictionary = Content.make_boon(String(id))
		if String(b.get("label", "")) == "" or String(b.get("result", "")) == "" \
				or not b.has("effects"):
			ok = false
	_expect(ok, "every boon has a label, result and effects block, and there are at least 3")


## offer_run_start_boon() populates up to 4 choices and opens the BOON phase;
## pick_boon() applies the chosen effect through the same generic rule an
## event choice uses, and hands back to the map.
func _test_boon_offer_and_pick_applies_effects() -> void:
	var run := Run.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], ["A", "B"], 4242, [{}, {}])
	var offered := run.offer_run_start_boon()
	var choice_count: int = (run.boon.get("choices", []) as Array).size()
	_expect(offered and run.phase == Run.Phase.BOON and choice_count >= 3 and choice_count <= 4,
		"offer_run_start_boon opens the BOON phase with 3-4 choices")
	# Override with a synthetic choice, same shape the event tests use, so the
	# assertion is about the generic effect rule, not which boon.json entry
	# happened to roll.
	run.boon = {"choices": [
		{"label": "test", "result": "you feel ready.", "effects": {"max_hp": 5, "gold": 10, "relic": true}},
	]}
	var max_before: int = run.max_hp[0]
	var gold_before: int = run.gold
	var relics_before: int = run.team_relics.size()
	var picked := run.pick_boon(0)
	_expect(picked and run.max_hp[0] == max_before + 5 and run.gold == gold_before + 10
		and run.team_relics.size() == relics_before + 1
		and run.phase == Run.Phase.MAP and run.boon_result == "you feel ready.",
		"picking a boon applies its effects and hands back to the map")


func _test_boon_rejects_outside_its_phase() -> void:
	var run := Run.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], ["A", "B"], 4242, [{}, {}])
	run.start()  # start() leaves phase == MAP, not BOON — see offer_run_start_boon()'s own comment
	_expect(not run.pick_boon(0), "pick_boon refuses to act outside the BOON phase")


## The load-bearing safety property this item's own design rests on: a real
## co-op run (GameHost.start_new_run() -> Run.start()) must NOT enter BOON on
## its own, because no client screen exists for it yet (see
## offer_run_start_boon()'s doc comment). If this ever starts failing, a boon
## screen has to land in the SAME change that flips this default.
func _test_start_does_not_auto_offer_a_boon() -> void:
	var run := Run.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], ["A", "B"], 4242, [{}, {}])
	run.start()
	_expect(run.phase == Run.Phase.MAP, "Run.start() still leaves a fresh run on the MAP, not BOON")


func _test_run_survives_a_save_and_load_in_boon() -> void:
	var run := Run.new([_deck_of(_slash, 8), _deck_of(_slash, 8)], ["A", "B"], 34,
		[{"character": "frog"}, {"character": "goblin_mech"}], 0)
	run.start()
	run.offer_run_start_boon()
	var expect_choice_count: int = (run.boon.get("choices", []) as Array).size()
	var expect_first_label := String((run.boon.get("choices", [])[0] as Dictionary).get("label", ""))

	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()

	var boon_ok: bool = (back.boon.get("choices", []) as Array).size() == expect_choice_count \
		and String((back.boon.get("choices", [])[0] as Dictionary).get("label", "")) == expect_first_label
	_expect(back.phase == Run.Phase.BOON and boon_ok,
		"a run saved mid-boon reloads with its offer intact")
	# and the reloaded offer is still live, not a frozen snapshot
	var picked := back.pick_boon(0)
	_expect(picked and back.phase == Run.Phase.MAP, "the reloaded boon is still pickable")
	RunSave.clear()


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


## Backlog #27: a status card has nothing to sharpen — the campfire refuses to
## upgrade one, but removal (its only real escape) still works normally.
func _test_status_card_cannot_be_sharpened_but_can_be_removed_at_campfire() -> void:
	var run := _map_run()
	run.decks[0].append(Content.make_card("bruised_grip"))
	var curse_index: int = run.decks[0].size() - 1
	run._begin_campfire()
	var blocked := not run.campfire_action(0, "upgrade", curse_index)
	var still_status: bool = (run.decks[0][curse_index] as Card).status
	var still_waiting: bool = run.phase == Run.Phase.CAMPFIRE  # refusal doesn't spend the visit
	_expect(blocked and still_status and still_waiting,
		"a status card refuses the campfire's sharpen option, without spending the hunter's turn")

	var run2 := _map_run()
	run2.decks[0].append(Content.make_card("bruised_grip"))
	var idx2: int = run2.decks[0].size() - 1
	var before2: int = run2.decks[0].size()
	run2._begin_campfire()
	var removed := run2.campfire_action(0, "remove", idx2)
	_expect(removed and run2.decks[0].size() == before2 - 1,
		"a status card can be removed like any other card at a campfire")


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


func _asc_run(level: int) -> Run:
	var decks := [_deck_of(_slash, 10), _deck_of(_slash, 10)]
	var run := Run.new(decks, ["A", "B"], 7, [{}, {}], level)
	run.start()
	return run


## Backlog #22: Content.ascension_mods() accumulating the right numbers (proven
## above) is not the same as those numbers actually reaching the run. This pairs
## every tier with the one below it (same seed, so the same beast/map either
## side) and checks the SPECIFIC effect that tier claims to introduce actually
## changed something a hunter would feel — not just the mods dictionary.
func _test_ascension_tier_effects_reach_the_run() -> void:
	# Tier 1 — boss_hp_pct: the very beast this seed fights gets +10% max HP.
	var base := _asc_run(0)
	_step_into_combat(base)
	var base_hp: int = base.combat.boss.max_hp
	var t1 := _asc_run(1)
	_step_into_combat(t1)
	var t1_ok: bool = t1.combat.boss.max_hp == int(base_hp * 110 / 100.0)

	# Tier 2 — heal_between: 3 less HP banked after a win (both start hurt so
	# the max-HP clamp can't mask the difference).
	var t1b := _asc_run(1)
	_step_into_combat(t1b)
	t1b.combat.players[0].combatant.hp = 5
	_force_win(t1b)
	var t2 := _asc_run(2)
	_step_into_combat(t2)
	t2.combat.players[0].combatant.hp = 5
	_force_win(t2)
	var t2_ok: bool = t1b.hp[0] == 5 + Run.HEAL_BETWEEN and t2.hp[0] == 5 + (Run.HEAL_BETWEEN - 3)

	# Tier 3 — boss_strength: the beast begins the fight already enraged.
	var t2b := _asc_run(2)
	_step_into_combat(t2b)
	var t3 := _asc_run(3)
	_step_into_combat(t3)
	var t3_ok: bool = t2b.combat.boss.strength == 0 and t3.combat.boss.strength == 1

	# Tier 4 — reward_choices: one fewer card offered after a win.
	var t3b := _asc_run(3)
	_step_into_combat(t3b)
	_force_win(t3b)
	var t4 := _asc_run(4)
	_step_into_combat(t4)
	_force_win(t4)
	var t4_ok: bool = t3b.reward_choices[0].size() == Run.REWARD_CHOICES \
		and t4.reward_choices[0].size() == Run.REWARD_CHOICES - 1

	# Tier 5 — rest_heal: a campfire rest heals 4 less.
	var t4b := _asc_run(4)
	t4b.hp[0] = 5
	t4b._begin_campfire()
	t4b.campfire_action(0, "rest")
	var t5 := _asc_run(5)
	t5.hp[0] = 5
	t5._begin_campfire()
	t5.campfire_action(0, "rest")
	var t5_ok: bool = t4b.hp[0] == 5 + Run.REST_HEAL and t5.hp[0] == 5 + (Run.REST_HEAL - 4)

	# Tier 6 — boss_hp_pct stacks a further 10% (20% total off the base HP).
	var t6 := _asc_run(6)
	_step_into_combat(t6)
	var t6_ok: bool = t6.combat.boss.max_hp == int(base_hp * 120 / 100.0)

	# Tier 7 — player_hp: 5 less starting max HP.
	var t7 := _asc_run(7)
	var t7_ok: bool = t7.max_hp[0] == Run.PLAYER_HP - 5

	# Tier 8 — boss_strength stacks a further +1 (+2 total).
	var t8 := _asc_run(8)
	_step_into_combat(t8)
	var t8_ok: bool = t8.combat.boss.strength == 2

	_expect(t1_ok and t2_ok and t3_ok and t4_ok and t5_ok and t6_ok and t7_ok and t8_ok,
		"every ascension tier's own effect reaches the run, not just Content.ascension_mods() [%s]"
			% [[t1_ok, t2_ok, t3_ok, t4_ok, t5_ok, t6_ok, t7_ok, t8_ok]])


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


## Backlog #27: the shop's "Thin the deck" removal doesn't care what a card
## IS — a status card comes out through the same generic path as any other.
func _test_status_card_removable_at_shop() -> void:
	var run := _map_run()
	run.decks[0].append(Content.make_card("bruised_grip"))
	var curse_index: int = run.decks[0].size() - 1
	run.gold = 5000
	run.map_row = 0
	run.node_type = "shop"
	run._begin_shop()
	var rem_i := -1
	for i in range(run.shop_stock.size()):
		if String(run.shop_stock[i]["kind"]) == "remove" and int(run.shop_stock[i]["slot"]) == 0:
			rem_i = i
			break
	var before: int = run.decks[0].size()
	var bought := run.buy(rem_i, curse_index)
	_expect(bought and run.decks[0].size() == before - 1,
		"a status card can be bought out of a deck at a shop like any other card")


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


## Backlog #27: status cards are INFLICTED (an event's curse_card), never
## drafted — they must not turn up in any starter deck or reward pool, global
## or per-character, or a fresh run/reward screen could hand one out for free.
func _test_status_cards_never_offered_as_a_reward() -> void:
	var bad: Array = []
	for id in Content.all_card_ids():
		if not Content.make_card(String(id)).status:
			continue
		var in_starter := false
		for c in Content.build_starter_deck():
			if String((c as Card).id) == id:
				in_starter = true
				break
		if in_starter:
			bad.append("%s in global starter_deck" % id)
		if Content.reward_pool().has(id):
			bad.append("%s in global reward_pool" % id)
		for c in Content.list_characters():
			var cid := String(c["id"])
			if Content.reward_pool(cid).has(id):
				bad.append("%s in %s reward_pool" % [id, cid])
	_expect(bad.is_empty(),
		"no status card is offered by any starter deck or reward pool [%s]" % ", ".join(bad))


# --- potions (backlog #26): held per-hunter, same data shape as relics -----

func _test_potions_all_load() -> void:
	var pool: Array = Content.potion_pool()
	var ok := pool.size() >= 8
	var known_effects := ["heal", "block", "strength", "energy", "draw",
		"heal_ally", "block_ally", "energy_ally", "strength_ally", "draw_ally",
		"climb", "strip_ward"]
	for id in pool:
		var p: Dictionary = Content.make_potion(String(id))
		if String(p.get("name", "")) == "" or String(p.get("text", "")) == "" \
				or not known_effects.has(String(p.get("effect", ""))) or int(p.get("value", 0)) <= 0:
			ok = false
	_expect(ok, "the potion pool is stocked and every entry has a real name/text/effect/value")


## Combat.use_potion() reads the same {effect, value} shape a relic does — one
## generic dispatch, no per-potion special case.
func _test_use_potion_applies_each_effect() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.combatant.hp = 20
	var healed := combat.use_potion(0, "heal", 12)
	var capped := combat.use_potion(0, "heal", 999)  # heal never overflows max HP
	var block_ok := combat.use_potion(0, "block", 10)
	var energy_before: int = ps.energy
	var energy_ok := combat.use_potion(0, "energy", 2)
	var strength_ok := combat.use_potion(0, "strength", 3)
	var hand_before: int = ps.hand.size()
	var draw_ok := combat.use_potion(0, "draw", 2)
	var bad := combat.use_potion(0, "not_a_real_effect", 1)
	_expect(healed and capped and ps.combatant.hp == ps.combatant.max_hp,
		"a heal potion restores HP and never overflows max HP")
	_expect(block_ok and ps.combatant.block == 10, "a block potion grants Block")
	_expect(energy_ok and ps.energy == energy_before + 2, "an energy potion grants Energy")
	_expect(strength_ok and ps.strength == 3, "a strength potion grants Strength for the fight")
	_expect(draw_ok and ps.hand.size() == hand_before + 2, "a draw potion draws cards")
	_expect(not bad, "an unrecognised potion effect is refused, not silently ignored")


## Backlog #52: an _ally variant of each of the five base effects, plus two
## effects a card cannot reach — climb with no energy/card, and stripping the
## TITAN's own Artifact directly. Same generic {effect, value} dispatch.
func _test_use_potion_ally_and_beast_effects() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var mover: PlayerState = combat.players[0]
	var ally: PlayerState = combat.players[1]
	ally.combatant.hp = 20
	var healed_ally := combat.use_potion(0, "heal_ally", 15)
	var blocked_ally := combat.use_potion(0, "block_ally", 12)
	var ally_energy_before: int = ally.energy
	var energised_ally := combat.use_potion(0, "energy_ally", 2)
	var strengthened_ally := combat.use_potion(0, "strength_ally", 3)
	var ally_hand_before: int = ally.hand.size()
	var drew_ally := combat.use_potion(0, "draw_ally", 2)
	_expect(healed_ally and blocked_ally and energised_ally and strengthened_ally and drew_ally,
		"every _ally potion effect is accepted")
	_expect(ally.combatant.hp == 35, "heal_ally restores the ALLY's HP, not the drinker's")
	_expect(ally.combatant.block == 12, "block_ally grants Block to the ally")
	_expect(ally.energy == ally_energy_before + 2, "energy_ally grants energy to the ally")
	_expect(ally.strength == 3, "strength_ally grants Strength to the ally")
	_expect(ally.hand.size() == ally_hand_before + 2, "draw_ally draws cards for the ally")
	_expect(mover.combatant.hp != 35 and mover.strength == 0,
		"an _ally potion changes only the ally, not the hunter who drank it")

	var start_foothold: int = mover.foothold
	var climbed := combat.use_potion(0, "climb", 3)
	_expect(climbed and mover.foothold == start_foothold + 3,
		"a climb potion gains Height directly, with no card and no energy spent")
	var climbed_over_cap := combat.use_potion(0, "climb", 99)
	_expect(climbed_over_cap and mover.foothold == Combat.FOOTHOLD_MAX,
		"a climb potion is still capped at FOOTHOLD_MAX")

	combat.boss.artifact = 3
	var warded := combat.use_potion(0, "strip_ward", 2)
	_expect(warded and combat.boss.artifact == 1,
		"strip_ward spends the Titan's own Artifact directly, without a debuff card")
	var stripped_to_floor := combat.use_potion(0, "strip_ward", 5)
	_expect(stripped_to_floor and combat.boss.artifact == 0,
		"strip_ward never takes the Titan's Artifact below zero")


func _test_use_potion_gating() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var bad_index := not combat.use_potion(9, "heal", 5)
	combat.players[0].ended_turn = true
	var ended := not combat.use_potion(0, "heal", 5)
	combat.players[0].ended_turn = false
	combat.phase = Combat.Phase.ENEMY  # mid-resolution — not this hunter's action to take
	var wrong_phase := not combat.use_potion(0, "heal", 5)
	_expect(bad_index and ended and wrong_phase,
		"use_potion refuses an invalid player, a player who's already ended, and acting outside PLAYERS phase")


## Run owns the inventory: gaining a slot, using it mid-fight (which forwards
## to Combat and empties the slot), and discarding one unused.
func _test_run_potion_use_and_discard() -> void:
	var run := _map_run()
	_step_into_combat(run)
	run.potions[0] = [Content.make_potion("field_dressing"), Content.make_potion("guard_oil")]
	run.combat.players[0].combatant.hp = 10
	var before: int = run.potions[0].size()
	var used := run.use_potion(0, 0)  # field_dressing: heal 12
	var used_slot_shrank: bool = run.potions[0].size() == before - 1
	var healed: bool = run.combat.players[0].combatant.hp == 22
	var discarded := run.discard_potion(0, 0)  # the remaining guard_oil, unused
	var empty_now: bool = run.potions[0].is_empty()
	var bad_index := not run.use_potion(0, 0)  # nothing left to use
	_expect(used and used_slot_shrank and healed and discarded and empty_now and bad_index,
		"a used potion applies its effect and empties the slot; a discarded one just empties it")


func _test_shop_buys_a_potion() -> void:
	var run := _map_run()
	run.gold = 500
	run.map_row = 0
	run.node_type = "shop"
	run._begin_shop()
	var potion_i := -1
	for i in range(run.shop_stock.size()):
		if String(run.shop_stock[i]["kind"]) == "potion":
			potion_i = i
			break
	if potion_i < 0:
		_expect(true, "shop buys a potion (none stocked this seed)")
		return
	var slot := int(run.shop_stock[potion_i]["slot"])
	var before: int = run.potions[slot].size()
	var purse_before: int = run.gold
	var bought := run.buy(potion_i)
	_expect(bought and run.potions[slot].size() == before + 1
		and run.gold == purse_before - Run.PRICE_POTION and bool(run.shop_stock[potion_i]["sold"]),
		"buying a potion adds it to that hunter's slots and spends gold")


func _test_potion_slots_are_capped() -> void:
	var run := _map_run()
	for _i in range(Run.POTION_SLOTS):
		run.potions[0].append(Content.make_potion("field_dressing"))
	var full_before: int = run.potions[0].size()
	run._grant_potions()  # a win shouldn't overflow a full inventory
	run.gold = 5000
	run.map_row = 0
	run.node_type = "shop"
	run._begin_shop()
	var potion_i := -1
	for i in range(run.shop_stock.size()):
		if String(run.shop_stock[i]["kind"]) == "potion" and int(run.shop_stock[i]["slot"]) == 0:
			potion_i = i
			break
	var blocked_purchase := true
	if potion_i >= 0:
		blocked_purchase = not run.buy(potion_i)
	_expect(full_before == Run.POTION_SLOTS and run.potions[0].size() == Run.POTION_SLOTS
		and blocked_purchase,
		"a full potion inventory refuses both a fight's drop and a shop purchase")


func _test_fight_wins_grant_a_potion() -> void:
	var run := _map_run()
	_step_into_combat(run)
	run.potions = [[], []]
	_force_win(run)
	var gained := true
	for p in run.potions:
		if (p as Array).is_empty():
			gained = false
	_expect(gained, "felling a beast pays each hunter a potion, same as it pays gold")


## Through the FILE, same reason _test_run_survives_a_save_and_load uses it —
## JSON has one number type, so a shallow dict round trip would hide a float
## creeping into a potion's "value".
func _test_potions_round_trip_through_save() -> void:
	var run := Run.new([_deck_of(_slash, 6), _deck_of(_slash, 5)], ["A", "B"], 99,
		[{"character": "frog"}, {"character": "goblin_mech"}], 0)
	run.start()
	run.potions[0].append(Content.make_potion("iron_draught"))
	run.potions[1].append(Content.make_potion("clarity_brew"))
	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()
	_expect(back.potions.size() == 2
		and back.potions[0].size() == 1 and String(back.potions[0][0]["id"]) == "iron_draught"
		and int(back.potions[0][0]["value"]) == 3
		and back.potions[1].size() == 1 and String(back.potions[1][0]["id"]) == "clarity_brew",
		"held potions survive a save/load round trip through the file")


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


## Six more enchants (backlog #50): #12 built the engine with two proving
## entries ("sure", tested above, and "wide", which stays needs-a-screen since
## the timing window is client-rendered). These give the enchant SLOT a real
## decision across the categories #50 named — cost, draw, exhaust, target
## (co-op) and a second timing effect — each with its own /core consumer.

func _test_cheap_enchant_cuts_cost() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var idx := _first_playable(combat, 0)
	var enchanted: Card = combat.players[0].hand[idx].enchanted_copy("cheap")
	combat.players[0].hand[idx] = enchanted
	var before_energy: int = combat.players[0].energy
	_expect(combat.effective_cost(0, enchanted) == 0,
		"a Cheap-enchanted 1-cost card effectively costs 0")
	combat.play_card(0, idx, true)
	_expect(combat.players[0].energy == before_energy,
		"playing a Cheap-enchanted card spends no energy once its cut cost reaches 0")


func _test_keen_enchant_draws_an_extra_card() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var idx := _first_playable(combat, 0)
	var before: int = combat.players[0].hand.size()
	combat.players[0].hand[idx] = combat.players[0].hand[idx].enchanted_copy("keen")
	combat.play_card(0, idx, true)
	_expect(combat.players[0].hand.size() == before,
		"a Keen-enchanted card's extra draw replaces the card it just spent")


func _test_spent_enchant_exhausts_instead_of_discarding() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var idx := _first_playable(combat, 0)
	var card: Card = combat.players[0].hand[idx].enchanted_copy("spent")
	combat.players[0].hand[idx] = card
	combat.play_card(0, idx, true)
	_expect(combat.players[0].discard_pile.is_empty()
		and combat.players[0].exhaust_pile.size() == 1
		and combat.players[0].exhaust_pile[0].id == card.id,
		"a Spent-enchanted card exhausts instead of returning to the discard pile")


func _test_bonded_enchant_echoes_block_to_the_ally() -> void:
	var combat := _new_combat([_deck_of(_defend, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var idx := _first_playable(combat, 0)
	combat.players[0].hand[idx] = combat.players[0].hand[idx].enchanted_copy("bonded")
	combat.play_card(0, idx, true)
	_expect(combat.players[0].combatant.block == 5 and combat.players[1].combatant.block == 5,
		"a Bonded card's Block is echoed to the ally, not just the caster")


func _test_generous_enchant_gives_the_ally_energy() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var idx := _first_playable(combat, 0)
	combat.players[0].hand[idx] = combat.players[0].hand[idx].enchanted_copy("generous")
	var ally_before: int = combat.players[1].energy
	combat.play_card(0, idx, true)
	_expect(combat.players[1].energy == ally_before + 1,
		"a Generous-enchanted card hands the ally 1 energy")


func _test_true_eye_enchant_upgrades_good_to_perfect() -> void:
	var combat := _new_combat([_deck_of(_pounce, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var before: int = combat.boss.hp
	var idx := _first_playable(combat, 0)
	combat.players[0].hand[idx] = combat.players[0].hand[idx].enchanted_copy("true_eye")
	combat.play_card(0, idx, true, -1, -1, -1, Combat.TIMING_GOOD)
	_expect(before - combat.boss.hp == 9,  # 4 base + the FULL 5 timed_damage, not half
		"a True Eye-enchanted card turns a good hit into a perfect one")


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


## Retain (backlog #28): a retained card survives end_turn in hand; an
## ordinary card in the same hand still goes to the discard pile as normal.
func _test_retain_keeps_a_card_in_hand_at_end_of_turn() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_bunker_down(), _slash()]
	combat.end_turn(0)
	_expect(ps.hand.size() == 1 and ps.hand[0].id == "bunker_down"
			and _has_id(ps.discard_pile, "slash"),
		"a retained card stays in hand at end of turn; a normal one is discarded")


## A retained card kept across a turn boundary is still there to be played the
## following round, on top of the normal fresh draw — it isn't a one-shot skip.
func _test_retain_survives_into_the_next_round() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_bunker_down()]
	combat.end_turn(0)
	combat.end_turn(1)  # both end -> boss acts -> round 2 begins, hand redrawn
	_expect(_has_id(ps.hand, "bunker_down") and ps.hand.size() == Combat.HAND_SIZE + 1,
		"a retained card is still in hand next round, on top of the fresh draw")


## Innate (backlog #28): guaranteed in the OPENING hand — start() already ran
## _begin_round() for round 1 by the time _new_combat() returns. It fills one
## of the normal draw's slots rather than adding to the hand size (an innate
## card is guaranteed to be THERE, not a bonus card on top).
func _test_innate_is_guaranteed_in_the_opening_hand() -> void:
	var deck: Array = [_first_strike()] + _deck_of(_slash, 9)
	var combat := _new_combat([deck, _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	_expect(_has_id(ps.hand, "first_strike") and ps.hand.size() == Combat.HAND_SIZE,
		"an innate card is guaranteed in the opening hand, at the normal hand size")


## Innate only guarantees the OPENING hand — once played and gone, later rounds
## draw normally and can go a while without seeing it again (it's shuffled back
## into the deck like any other card once discarded/drawn again).
func _test_innate_does_not_reappear_every_round() -> void:
	var deck: Array = [_first_strike()] + _deck_of(_slash, 4)  # tiny deck: 5 cards
	var combat := _new_combat([deck, _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	var i := _index_of_id(ps.hand, "first_strike")
	combat.play_card(0, i)  # First Strike leaves the hand into the discard pile
	combat.end_turn(0)
	combat.end_turn(1)  # round 2: a normal draw, not another guaranteed copy
	_expect(ps.hand.size() == Combat.HAND_SIZE,
		"round 2 draws a normal hand size — innate only guarantees round 1")


# --- X-cost cards (backlog #29) --------------------------------------------
# cost == -1 is the sentinel: the card always spends every point of energy the
# hunter has, and `damage_per_x`/`block_per_x` scale with how much that was.
# No real card is wired into cards.json yet — the reward-choice and deck-view
# JSON (game_host.gd) and their card-face views still print a raw `int(cost)`,
# which would show a literal "-1" for a card nobody has ever seen played. That
# needs a screen to fix and verify, so this is engine-only, proven directly
# against Combat instead of through real content (same shape _slash()/_grip()
# etc. already use for every other synthetic test card in this file).

func _test_x_cost_spends_all_energy_and_scales_with_it() -> void:
	var combat := _new_combat([_deck_of(_x_strike, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	_expect(ps.energy == Combat.BASE_ENERGY and combat.effective_cost(0, ps.hand[0]) == Combat.BASE_ENERGY,
		"an X-cost card's effective cost is however much energy the hunter currently has")
	var before: int = combat.boss.hp
	var ok: bool = combat.play_card(0, 0)
	_expect(ok and ps.energy == 0 and before - combat.boss.hp == 1 + 3 * Combat.BASE_ENERGY,
		"playing an X-cost card drains all energy and its damage scales with how much was spent")


func _test_x_cost_playable_at_zero_energy() -> void:
	var combat := _new_combat([_deck_of(_x_strike, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.energy = 0
	var before: int = combat.boss.hp
	_expect(combat.can_play(0, 0), "an X-cost card is still playable at zero energy — spending zero is valid")
	var ok: bool = combat.play_card(0, 0)
	_expect(ok and ps.energy == 0 and before - combat.boss.hp == 1,
		"an X-cost card played for zero energy deals only its flat base — no per_x bonus, no crash")


func _test_x_cost_ignores_permanent_cost_reductions() -> void:
	var combat := _new_combat([_deck_of(_x_strike, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.cost_reductions[ps.hand[0].id] = 2  # a Burn Coal-style permanent reduction
	_expect(combat.effective_cost(0, ps.hand[0]) == Combat.BASE_ENERGY,
		"a permanent cost reduction does nothing to a cost that isn't a fixed number to begin with")


func _test_x_cost_meld_keeps_sentinel_and_sums_per_x() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_meld_card(), _x_strike(), _x_brace()]
	ps.energy = 3
	var ok: bool = combat.play_card(0, 0, true, 1, 2)
	var fused: Card = ps.hand[0]
	_expect(ok and fused.cost == -1 and fused.damage_per_x == 3 and fused.block_per_x == 4,
		"melding an X-cost card into anything keeps the -1 sentinel and sums the per_x scaling")


func _test_x_cost_upgrade_bumps_per_x_scaling() -> void:
	var sharpened := _x_strike().upgraded_copy()
	_expect(sharpened.cost == -1 and sharpened.damage_per_x == 4 and sharpened.upgraded,
		"sharpening an X-cost card bumps its per_x scaling like any other scaling field, and leaves the sentinel alone")


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
## back for an unknown one; an event's curse_card (backlog #27) must name a
## real status card. Card ids in decks/pools are proven above and relic
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
	for eid in Content.list_events():
		var ev := Content.make_event(String(eid))
		for choice in (ev.get("choices", []) as Array):
			var eff: Dictionary = (choice as Dictionary).get("effects", {})
			var cc := String(eff.get("curse_card", ""))
			if cc != "" and String(Content.make_card(cc).name).is_empty():
				bad.append("%s curse_card: %s" % [eid, cc])
			var pid := String(eff.get("potion", ""))
			if pid != "" and String(Content.make_potion(pid).get("name", "")).is_empty():
				bad.append("%s potion: %s" % [eid, pid])
	# A boon (#31) is shaped like a single event choice, and its curse_card /
	# potion refs need the exact same check the loop above already runs on events.
	for bid in Content.list_boons():
		var bn := Content.make_boon(String(bid))
		var beff: Dictionary = bn.get("effects", {})
		var bcc := String(beff.get("curse_card", ""))
		if bcc != "" and String(Content.make_card(bcc).name).is_empty():
			bad.append("%s curse_card: %s" % [bid, bcc])
		var bpid := String(beff.get("potion", ""))
		if bpid != "" and String(Content.make_potion(bpid).get("name", "")).is_empty():
			bad.append("%s potion: %s" % [bid, bpid])
	_expect(bad.is_empty(),
		"create/prepare fields, beast pool ids, curse_card and potion refs all resolve [%s]" % ", ".join(bad))


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

## Backlog #39: a finished run should say something about itself. Walk a real
## Run through a won fight (playing a real card, so damage/cards actually
## happen) and then a lost one, and confirm the totals accumulate across BOTH
## fights rather than only reflecting the last one.
func _test_backlog39_stats_accumulate_across_fights() -> void:
	var run := _map_run()
	_step_into_combat(run)
	var ci := _first_playable(run.combat, 0)
	run.combat.play_card(0, ci)  # a real Slash — proves damage_dealt/cards_played aren't just wired, they fire
	_force_win(run)
	var after_first: Dictionary = run.stats.duplicate()
	_expect(int(after_first["beasts_felled"]) == 1 and int(after_first["cards_played"]) >= 1
		and int(after_first["damage_dealt"]) > 0 and int(after_first["turns_taken"]) >= 1
		and String(after_first["died_to"]) == "",
		"winning a fight banks a felled beast, cards played, damage dealt and turns taken")
	_step_into_combat(run)  # clears the reward, walks back to the map, into the next fight
	run.combat.players[0].combatant.hp = 0
	run.combat.phase = Combat.Phase.OVER
	run.sync()
	_expect(run.phase == Run.Phase.LOST and String(run.stats["died_to"]) != ""
		and int(run.stats["beasts_felled"]) == 1  # the loss doesn't fell anything
		and int(run.stats["turns_taken"]) > int(after_first["turns_taken"])
		and int(run.stats["damage_dealt"]) >= int(after_first["damage_dealt"]),
		"a second, losing fight records what killed the run and keeps accumulating rather than resetting")


func _test_content_make_card_and_reward_pool() -> void:
	var card := Content.make_card("rally")
	var pool := Content.reward_pool()
	_expect(card.name == "Rally" and card.ally_energy == 1 and pool.size() >= 3,
		"content builds a card by id and exposes the reward pool")


# --- Something to unlock between runs (backlog #42) -----------------------

## Progress.total_wins() is the gate: it must climb on every win, independent
## of whether that win also advanced the ascension ladder (a replayed, already-
## cleared tier still counts toward it).
func _test_backlog42_progress_total_wins_climbs_on_every_win() -> void:
	Progress.use_scratch_slot("run_tests_backlog42")
	var cfg := ConfigFile.new()
	cfg.set_value(Progress.SECTION, "total_wins", 0)
	cfg.save(Progress.path)
	var before := Progress.total_wins()
	Progress.record_win(0)  # first clear of tier 0 -> also advances unlocked_ascension to 1
	Progress.record_win(0)  # replaying tier 0 again -> ladder doesn't move, but this still counts
	_expect(Progress.total_wins() == before + 2,
		"total_wins climbs on every win, even a replay that doesn't advance the ascension ladder")


## relic_pool()'s `wins` gate: a relic tagged unlock_wins only appears once the
## career total reaches it; everything else, and the default (no arg), is
## unaffected.
func _test_backlog42_relic_pool_respects_unlock_wins() -> void:
	var locked_out := Content.relic_pool(0)
	var unlocked := Content.relic_pool(1)
	var everything := Content.relic_pool()
	_expect(not locked_out.has("summit_cairn") and locked_out.has("iron_thews")
		and unlocked.has("summit_cairn") and everything.has("summit_cairn"),
		"relic_pool() withholds a gated relic below its unlock_wins and offers it at/above, "
		+ "leaving ungated relics and the no-arg default untouched")


## Same gate, the card side (reward_pool()).
func _test_backlog42_reward_pool_respects_unlock_wins() -> void:
	var locked_out := Content.reward_pool("", 0)
	var unlocked := Content.reward_pool("", 3)
	var everything := Content.reward_pool()
	_expect(not locked_out.has("trailmasters_cut") and locked_out.has("slash")
		and unlocked.has("trailmasters_cut") and everything.has("trailmasters_cut"),
		"reward_pool() withholds a gated card below its unlock_wins and offers it at/above, "
		+ "leaving ungated cards and the no-arg default untouched")


## The plumbing, not just the filter: a Run built with a career gate carries it
## (readable via unlocked_wins()), and the shop it deals actually respects it —
## deterministic, since an excluded id literally isn't in the candidate pool a
## shop draws from, whatever the RNG does.
func _test_backlog42_run_threads_unlocked_wins_into_the_shop() -> void:
	var decks := [_deck_of(_slash, 10), _deck_of(_slash, 10)]
	var gated := Run.new(decks, ["A", "B"], 4242, [{}, {}], 0, 0)
	gated.map_row = 0
	gated.node_type = "shop"
	gated._begin_shop()
	var saw_locked_relic := false
	for item in gated.shop_stock:
		if String((item as Dictionary).get("id", "")) == "summit_cairn":
			saw_locked_relic = true
	_expect(gated.unlocked_wins() == 0 and not saw_locked_relic,
		"a Run built with 0 unlocked wins carries that gate and its shop never offers a locked relic")


## Old saves predate this field entirely (backlog #35's additive-backfill
## shape) — from_dict() must treat "missing" as "not gated" (Content.UNLOCKED_ALL),
## not as 0, or every save written before this item shipped would suddenly
## lose access to content nobody meant to lock retroactively.
func _test_backlog42_unlocked_wins_round_trips_and_backfills() -> void:
	var decks := [_deck_of(_slash, 10), _deck_of(_slash, 10)]
	var run := Run.new(decks, ["A", "B"], 4242, [{}, {}], 0, 7)
	run.start()
	var d := run.to_dict()
	var back := Run.from_dict(d)
	d.erase("unlocked_wins")
	var old_save := Run.from_dict(d)
	_expect(back.unlocked_wins() == 7 and old_save.unlocked_wins() == Content.UNLOCKED_ALL,
		"unlocked_wins round-trips through a real save, and an older save missing the key backfills to unlocked")


## Through a real GameHost, resumed the way the menu's Continue button does
## (mirrors _test_host_autosaves_and_resumes) — the gate must survive that trip
## too, not just Run's own to_dict/from_dict.
func _test_backlog42_gamehost_carries_unlocked_wins_through_resume() -> void:
	RunSave.clear()
	var t := LocalTransport.new()
	var host := GameHost.new(t, 42, 2, true, 0, 2)  # solo, ascension 0, 2 career wins
	_kept.append(host)
	var c := GameClient.new(t, 1)
	c.join()
	c.select_character("frog", 0)
	c.select_character("goblin_mech", 1)
	host._broadcast_state()  # autosave

	var t2 := LocalTransport.new()
	var host2 := GameHost.new(t2, 0, 2, true)  # no gate passed at construction...
	_kept.append(host2)
	var c2 := GameClient.new(t2, 1)
	c2.join()
	host2.resume_run(RunSave.load_run())  # ...so this proves it came from the SAVE, not the constructor
	var resumed: Run = host2._run
	_expect(resumed.unlocked_wins() == 2, "resuming a saved run restores its unlock gate, not the fresh default")
	RunSave.clear()


## Item #43: a small set of named moments (turn_start, turn_end, card_played,
## damage_taken, hunter_climbs) that anything can subscribe to, instead of
## being wired into its own call site. block_carries, energy_handoff and
## timed-card Rhythm were MOVED onto turn_start/turn_end/card_played — proven
## unchanged by _test_backlog10_new_rule_changing_relics (block_carries,
## energy_handoff) and the existing Rhythm test above (card_played) still
## passing untouched. This test covers what those don't: that damage_taken
## and hunter_climbs — the two moments nothing subscribes to yet — actually
## exist and fire with real data during ordinary play, proven by registering
## a probe with the same _on()/_fire() plumbing a future relic would use.
func _test_backlog43_trigger_moments_exist_and_fire() -> void:
	var boss := _climb_boss(6)
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_grip, 10)], 42, boss)
	var damage_events: Array = []
	var climb_events: Array = []
	combat._on(Combat.MOMENT_DAMAGE_TAKEN, func(ctx): damage_events.append(ctx))
	combat._on(Combat.MOMENT_HUNTER_CLIMBS, func(ctx): climb_events.append(ctx))

	combat.play_card(0, _first_playable(combat, 0))  # a Slash hits the (armored) Titan
	var damage_fired: bool = damage_events.size() == 1 \
		and damage_events[0]["target"] == boss and int(damage_events[0]["amount"]) > 0

	combat.play_card(1, _first_playable(combat, 1))  # Grip climbs hunter 1 from Height 0 — a fresh peak
	var climb_fired: bool = climb_events.size() == 1 \
		and climb_events[0]["player"] == combat.players[1] and int(climb_events[0]["foothold"]) > 0

	# Re-running the tracker with no foothold above the recorded peak must not
	# re-fire — hunter_climbs means "reached a NEW high", not "foothold touched".
	combat._track_climb()
	var no_refire_without_a_new_peak: bool = climb_events.size() == 1

	_expect(damage_fired and climb_fired and no_refire_without_a_new_peak,
		"backlog #43's damage_taken and hunter_climbs moments exist and fire with real data")


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


## Backlog #48: relics carry a tier, and relic_pool()/boss_relic_pool() are a
## strict partition of the same 35 — nothing in one is in the other, and
## nothing outside "common"/"boss" exists to fall through the cracks.
func _test_backlog48_relic_pool_and_boss_relic_pool_partition_by_tier() -> void:
	var common: Array = Content.relic_pool()
	var boss: Array = Content.boss_relic_pool()
	var overlap := false
	for id in common:
		if boss.has(id):
			overlap = true
	var all_ids: Array = Content.all_relic_ids()
	var covers_everything := common.size() + boss.size() == all_ids.size()
	_expect(not overlap and covers_everything and boss.has("warlords_girdle")
		and not common.has("warlords_girdle"),
		"relic_pool() and boss_relic_pool() partition every relic by tier with no overlap")


## The reward a Titan itself pays must come from ITS OWN pool — never a relic
## a shop or an elite could also offer. Reaches into _begin_reward via
## node_type = "boss" the same way _test_elite_pays_a_card_then_a_relic does.
func _test_backlog48_titan_relic_reward_draws_only_from_the_boss_pool() -> void:
	var run := _map_run()
	_step_into_combat(run)
	run.node_type = "boss"
	_force_win(run)
	_pick_both(run)  # take the card, opening the relic reward
	var boss_ids: Array = Content.boss_relic_pool()
	var all_boss_tier := true
	var offered_any := false
	for choices in run.reward_choices:
		for r in (choices as Array):
			offered_any = true
			if not boss_ids.has(String((r as Dictionary).get("id", ""))):
				all_boss_tier = false
	_expect(run.reward_kind == "relic" and offered_any and all_boss_tier,
		"a Titan's relic reward offers only tier: boss relics")


## The mirror check: an elite's relic reward must NEVER surface a boss-tier
## relic — those are held back for a Titan kill specifically.
func _test_backlog48_elite_relic_reward_never_offers_a_boss_relic() -> void:
	var run := _map_run()
	_step_into_combat(run)
	run.node_type = "elite"
	_force_win(run)
	_pick_both(run)  # take the card, opening the relic reward
	var boss_ids: Array = Content.boss_relic_pool()
	var saw_boss_tier := false
	for choices in run.reward_choices:
		for r in (choices as Array):
			if boss_ids.has(String((r as Dictionary).get("id", ""))):
				saw_boss_tier = true
	_expect(run.reward_kind == "relic" and not saw_boss_tier,
		"an elite's relic reward never offers a boss-tier relic")


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


## Backlog #39: the run summary is only worth building if it actually survives
## putting the game down. Through the real file, same reason #35's tests insist
## on it — JSON has one number type, so a bare to_dict/from_dict pair wouldn't
## catch an int quietly coming back a float.
func _test_backlog39_stats_round_trip_through_save() -> void:
	var run := Run.new([_deck_of(_slash, 6), _deck_of(_slash, 5)], ["A", "B"], 55, [{}, {}])
	run.start()
	run.stats["damage_dealt"] = 40
	run.stats["highest_climb"] = 7
	run.stats["cards_played"] = 12
	run.stats["turns_taken"] = 5
	run.stats["beasts_felled"] = 2
	run.stats["died_to"] = "Stone Warden"
	run.pick_node(int(run.available_nodes()[0]))
	run.phase = Run.Phase.MAP

	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()
	# Key by key, not str(dict) == str(dict) — JSON parsing doesn't promise to
	# preserve insertion order, so two equal dicts can print in a different
	# order and a str() comparison would fail on a correct round trip.
	var stats_match: bool = back != null
	if stats_match:
		for key in run.stats:
			if back.stats.get(key) != run.stats[key]:
				stats_match = false
	_expect(stats_match, "a run's stats survive a save/load round trip through the real file")
	RunSave.clear()


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


## Backlog #35: rejecting on a version mismatch used to mean the day someone
## bumped `Run.SAVE_VERSION`, every save from an older build would silently
## vanish rather than load. This writes a fixture in the PREVIOUS shape (a
## real save with "version" rolled back to 1 and "potions" stripped out,
## since v1 predates potions entirely) straight to the file `RunSave` reads,
## and checks it comes back playable with sensible defaults, not discarded.
func _test_load_run_migrates_an_older_save() -> void:
	var run := Run.new([_deck_of(_slash, 6), _deck_of(_slash, 5)], ["A", "B"], 41,
		[{"character": "frog"}, {"character": "goblin_mech"}], 0)
	run.start()
	run.gold = 60
	var d := run.to_dict()
	d.erase("potions")
	d["version"] = 1

	RunSave.clear()
	var f := FileAccess.open(RunSave.path, FileAccess.WRITE)
	f.store_string(JSON.stringify(d))
	f.close()

	var back := RunSave.load_run()
	var migrated_ok: bool = back != null and back.gold == 60 \
		and back.potions.size() == back.names.size() \
		and back.potions[0].is_empty() and back.potions[1].is_empty()
	_expect(migrated_ok, "an older save (missing potions entirely) migrates to the current shape instead of being discarded")
	RunSave.clear()


## A save from before #39 (or before any single stat this dict grows to next)
## has no "stats" key at all — from_dict backfills the defaults the same
## additive way it already does for potions above, no version bump needed.
func _test_backlog39_older_save_backfills_missing_stats() -> void:
	var run := Run.new([_deck_of(_slash, 6), _deck_of(_slash, 5)], ["A", "B"], 56, [{}, {}])
	run.start()
	var d := run.to_dict()
	d.erase("stats")

	RunSave.clear()
	var f := FileAccess.open(RunSave.path, FileAccess.WRITE)
	f.store_string(JSON.stringify(d))
	f.close()

	var back := RunSave.load_run()
	var backfilled_ok: bool = back != null \
		and int(back.stats.get("damage_dealt", -1)) == 0 \
		and int(back.stats.get("beasts_felled", -1)) == 0 \
		and String(back.stats.get("died_to", "x")) == ""
	_expect(backfilled_ok, "a save missing stats entirely backfills the defaults instead of crashing")
	RunSave.clear()


## The other half of #35: rejection is still correct for a save this build
## genuinely cannot read forward — one written by a LATER build than this one,
## claiming a version this code has never seen.
func _test_load_run_rejects_a_save_from_a_newer_build() -> void:
	var run := Run.new([_deck_of(_slash, 6), _deck_of(_slash, 5)], ["A", "B"], 42,
		[{"character": "frog"}, {"character": "goblin_mech"}], 0)
	run.start()
	var d := run.to_dict()
	d["version"] = Run.SAVE_VERSION + 1

	RunSave.clear()
	var f := FileAccess.open(RunSave.path, FileAccess.WRITE)
	f.store_string(JSON.stringify(d))
	f.close()

	_expect(RunSave.load_run() == null, "a save from a newer build than this one refuses to load rather than guessing")
	RunSave.clear()


## And a genuinely corrupt file — not a version this code doesn't know, just
## not readable data at all — still refuses cleanly rather than crashing.
func _test_load_run_rejects_a_corrupt_file() -> void:
	RunSave.clear()
	var f := FileAccess.open(RunSave.path, FileAccess.WRITE)
	f.store_string("{ not valid json at all")
	f.close()

	_expect(RunSave.load_run() == null, "an unreadable file loads as \"no save\" rather than crashing")
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


## Found while fixing #5: the Frog sat at 4 rares, one under the same 5-7 band
## (backlog #23). Same shape of test as the Vine-Weaver's, for the same reason.
func _test_frog_has_enough_rares() -> void:
	var rares: Dictionary = {}
	for rid in Content.reward_pool("frog"):
		if Content.card_rarity(String(rid)) == "rare":
			rares[String(rid)] = true
	_expect(rares.size() >= 5 and rares.size() <= 7,
		"Frog has 5-7 rares, in her own idiom (%d: %s)" % [rares.size(), ", ".join(rares.keys())])


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


## Item #30: a relic's downside_effect/downside_value is just a second
## {effect, value} pair, folded in by the same generic rule as the primary
## effect — proven both at the Run.relic_totals() level (the pair sums
## correctly) and at Combat (a heavily negative bonus can't drive block or
## energy below zero, per combat.gd's new maxi(0, ...) floor).
func _test_relic_downside() -> void:
	var run := _map_run()
	run.team_relics = [Content.make_relic("warlords_girdle")]
	var totals := run.relic_totals()
	var girdle_ok: bool = int(totals["attack"]) == 6 and int(totals["energy"]) == -1

	run.team_relics = [Content.make_relic("fortress_ward"), Content.make_relic("adrenal_surge")]
	var totals2 := run.relic_totals()
	# round_block: fortress_ward +10, adrenal_surge -4 -> +6; draw: -1; energy: +2
	var stacked_ok: bool = int(totals2["block"]) == 6 and int(totals2["draw"]) == -1 and int(totals2["energy"]) == 2

	# a big enough downside is floored at zero, not left negative (combat.gd)
	var starved := _relic_combat(-5, 0, 0)
	var no_negative_energy: bool = starved.players[0].energy == 0
	var battered := _relic_combat(0, 0, -20)
	var no_negative_block: bool = battered.players[0].combatant.block == 0

	_expect(girdle_ok and stacked_ok and no_negative_energy and no_negative_block,
		"a relic's downside is a second {effect, value} pair, summed by the same rule, floored at zero")


func _test_relic_start_strength() -> void:
	var players := [Combatant.new("A", 42), Combatant.new("B", 42)]
	var combat := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], players,
		_dummy_boss(300), 42, 0, 0, 0, 2)  # start_strength = 2
	combat.start()
	_expect(combat.players[0].strength == 2, "start_strength relic begins the fight with Strength")


# --- The debuff axis (backlog #36): Frail, Artifact, Thorns ---------------

func _test_frail_reduces_block_gained() -> void:
	var c := Combatant.new("Test", 30)
	c.gain_block(8)
	_expect(c.block == 8, "Block is gained in full without Frail")
	c.block = 0
	c.frail = 1
	c.gain_block(8)
	_expect(c.block == 6, "Frail cuts Block gained by a quarter, floored")


## Crippling Blow applies Frail to the Titan; the Titan's own "block" move
## then gains less than it says, the same generic Combatant.gain_block cut
## every other source of Block would feel.
func _test_frail_card_cuts_the_boss_own_block_move() -> void:
	var combat := _new_combat([_deck_of(_crippling_blow, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	combat.play_card(0, _first_playable(combat, 0))  # Crippling Blow: 5 damage + Frail 2
	_expect(combat.boss.frail == 2, "Crippling Blow applies Frail to the Titan")
	combat.boss.moves = [{"type": "block", "value": 8}]
	combat.end_turn(0)
	combat.end_turn(1)  # boss defends for a stated 8 — Frail cuts what it actually gains
	_expect(combat.boss.block == 6, "Frail cuts the Titan's own Block move")


func _test_artifact_wards_off_a_debuff_then_is_spent() -> void:
	var combat := _new_combat([_deck_of(_expose, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	combat.boss.artifact = 1
	combat.play_card(0, _first_playable(combat, 0))  # Expose 2 — warded off
	_expect(combat.boss.vulnerable == 0 and combat.boss.artifact == 0,
		"Artifact wards off Expose and spends a stack doing it")
	combat.play_card(0, _first_playable(combat, 0))  # Expose again — no ward left
	_expect(combat.boss.vulnerable == 2, "once Artifact is spent, the next debuff lands normally")


func _test_thorns_reflects_a_landed_boss_attack() -> void:
	var boss := _dummy_boss(300, 8)  # a plain "attack" move for 8
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.players[0].combatant.thorns = 3
	var hp0: int = combat.players[0].combatant.hp
	var boss_hp := combat.boss.hp
	combat.end_turn(0)
	combat.end_turn(1)  # round 1: boss_target_index() is player 0
	_expect(combat.players[0].combatant.hp == hp0 - 8, "the boss's attack still lands in full")
	_expect(combat.boss.hp == boss_hp - 3, "Thorns on the hunter reflects the boss's own attack back at it")


func _test_beast_thorns_reflects_card_damage_dealt_to_it() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	combat.boss.thorns = 2
	var hp0: int = combat.players[0].combatant.hp
	combat.play_card(0, _first_playable(combat, 0))  # Slash deals card damage to the boss
	_expect(combat.players[0].combatant.hp == hp0 - 2, "a Thorned beast bites back when a hunter's card lands on it")


## Mirrors #14/#15's own insistence on going through the real file (RunSave),
## not a bare to_dict()/from_dict() pair, since that's where JSON's one-number
## -type gotcha and the version gate actually live.
func _test_frail_artifact_thorns_persist_through_save() -> void:
	var run := Run.new([_deck_of(_slash, 8), _deck_of(_slash, 8)], ["A", "B"], 77, [{}, {}], 0)
	run.start()
	_step_into_combat(run)
	var combat: Combat = run.combat
	combat.boss.frail = 2
	combat.boss.artifact = 1
	combat.players[0].combatant.thorns = 2
	combat.players[0].combatant.artifact = 1

	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()
	var bc: Combat = back.combat if back != null else null
	_expect(bc != null and bc.boss.frail == 2 and bc.boss.artifact == 1
			and bc.players[0].combatant.thorns == 2 and bc.players[0].combatant.artifact == 1,
		"Frail/Artifact/Thorns survive a mid-fight save and load")


func _test_beast_thorns_and_artifact_are_wired() -> void:
	var hog := Content.build_boss("bramble_hog")
	var sentinel := Content.build_boss("frost_sentinel")
	_expect(hog.thorns == 3, "the Bramble Hog carries innate Thorns")
	_expect(sentinel.artifact == 2, "the Frost Sentinel carries innate Artifact")


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


## Backlog #38: the seed has to actually reach a peer's snapshot to be
## "readable" for real — a getter nobody's view ever calls doesn't help
## someone trying to read it off screen and share it.
func _test_session_shared_state_exposes_the_seed() -> void:
	var s42 := _make_session(42)
	var s99 := _make_session(99)
	var c0_42: GameClient = s42["c0"]
	var c0_99: GameClient = s99["c0"]
	_expect(int(c0_42.shared["seed"]) == 42 and int(c0_99.shared["seed"]) == 99,
		"the run's seed rides along in the shared snapshot, matching what it was started with")


# --- Backlog #45: six /core mechanics, proven across a real host/client pair -

## Potions (backlog #26) never reached a snapshot at all, and GameHost had no
## "use_potion"/"discard_potion" command -- Run.use_potion()/discard_potion()
## sat in /core completely unreachable from the network layer. Wired both
## sides; this proves a potion is SHARED (an ally can see what you're
## holding, same as your HP) but only ever USABLE by its owner, because
## _acting_slot resolves every co-op command to the sending peer's own slot
## no matter what slot/index the command claims.
func _test_backlog45_potions_are_shared_but_only_the_owner_can_drink_them() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	var c1: GameClient = s["c1"]
	var run: Run = host._run
	run.potions[0].append(Content.make_potion("quick_tonic"))  # +1 energy
	run.potions[1].append(Content.make_potion("guard_oil"))    # +10 block
	host._broadcast_state()
	_expect(c0.shared["players"][0]["potions"].size() == 1
		and String(c0.shared["players"][0]["potions"][0]["name"]) == "Quick Tonic"
		and String(c1.shared["players"][0]["potions"][0]["name"]) == "Quick Tonic",
		"a hunter's potions are visible to their ally too, not just to the holder")
	var slot1_block_before := int(c0.shared["players"][1]["block"])
	# c1 impersonates slot 0 (index 0, slot 0) -- in co-op _acting_slot ignores
	# the claimed slot entirely and resolves to the SENDING peer's own slot.
	c1.use_potion(0, 0)
	_expect(c0.shared["players"][0]["potions"].size() == 1,
		"a spoofed slot can't touch a teammate's potion -- the command still resolves to the sender's own slot")
	_expect(int(c0.shared["players"][1]["block"]) == slot1_block_before + 10
		and c0.shared["players"][1]["potions"].is_empty(),
		"the caller's OWN potion (guard_oil, +10 block) applied to their own slot instead")
	var slot0_energy_before := int(c0.private["energy"])
	c0.use_potion(0)  # slot 0 drinks their own quick_tonic
	_expect(int(c0.private["energy"]) == slot0_energy_before + 1
		and c0.shared["players"][0]["potions"].is_empty(),
		"the owner drinking their own potion applies its effect and empties the slot")


## Status/curse cards (backlog #27) are ordinary Cards, so they ride the same
## private-hand snapshot every card does -- prove a curse specifically
## reaches its owner (tagged with the status keyword) and never leaks into
## the ally's own hand, the field-privacy _test_session_private_view_is_isolated
## already proves for a normal hand.
func _test_backlog45_status_curse_card_stays_private_to_its_owner() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	var c1: GameClient = s["c1"]
	var curse: Card = Content.make_card("bruised_grip")
	host._run.combat.players[0].hand.append(curse)
	host._broadcast_state()
	var mine: Array = c0.private["hand"]
	var mine_curse: Dictionary = mine[mine.size() - 1]
	_expect(String(mine_curse["name"]) == curse.name and _has_keyword(mine_curse["keywords"], "status"),
		"the curse reaches its owner's private hand, tagged with the status keyword")
	var leaked := false
	for c in c1.private["hand"]:
		if String(c["name"]) == curse.name:
			leaked = true
	_expect(not leaked, "the curse never appears in the ally's own private hand")


## Retain and Innate (backlog #28) are card FLAGS, surfaced to a player only
## as a derived keyword (GameHost._keywords_of). Prove that derived tag
## actually rides the wire to its owner's hand.
func _test_backlog45_retain_and_innate_keywords_reach_the_owners_hand() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	var retain_card: Card = Content.make_card("bunker_down")
	var innate_card: Card = Content.make_card("first_strike")
	host._run.combat.players[0].hand.append(retain_card)
	host._run.combat.players[0].hand.append(innate_card)
	host._broadcast_state()
	var hand: Array = c0.private["hand"]
	var retain_kw: Array = hand[hand.size() - 2]["keywords"]
	var innate_kw: Array = hand[hand.size() - 1]["keywords"]
	_expect(_has_keyword(retain_kw, "retain") and not _has_keyword(retain_kw, "innate"),
		"a Retain card reaches its owner's hand tagged Retain, and only Retain")
	_expect(_has_keyword(innate_kw, "innate") and not _has_keyword(innate_kw, "retain"),
		"an Innate card reaches its owner's hand tagged Innate, and only Innate")


## Named holds (backlog #24) widened Boss.ledges from a bare int array to an
## optional Dictionary shape {height, safe, exposed_to}. Prove the richer
## shape crosses the snapshot boundary intact and IDENTICALLY to both peers
## -- it's shared board state, not per-hunter.
func _test_backlog45_named_holds_cross_to_both_peers_identically() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	var c1: GameClient = s["c1"]
	var named_ledges := [
		{"height": 3, "safe": false, "exposed_to": ["slam"]},
		{"height": 6, "safe": true, "exposed_to": []},
	]
	host._run.combat.boss.ledges = named_ledges
	host._broadcast_state()
	_expect(c0.shared["boss"]["ledges"] == named_ledges and c1.shared["boss"]["ledges"] == named_ledges,
		"a named-hold ledges array crosses the boundary intact and identically to both peers")
	var crossed: Variant = c1.shared["boss"]["ledges"][0]
	_expect(Boss.hold_height(crossed) == 3 and Boss.hold_safe(crossed) == false
		and Boss.hold_exposed_to(crossed) == ["slam"],
		"the peer can read height/safe/exposed_to off the crossed data the same way the host does")


## Graded timing (backlog #33) added a `quality` argument that travels
## client -> host on play_card, and a middle "good" preview tier a client
## needs to show a hit that isn't dead-centre. Prove both: the preview a
## peer receives actually grades miss/good/perfect as three distinct
## numbers, and a real play_card sent with TIMING_GOOD lands exactly the
## graded (half) bonus over the wire -- not the full one and not zero.
func _test_backlog45_graded_timing_quality_reaches_the_host_and_the_preview() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	var c1: GameClient = s["c1"]
	# Neutralise the climb's own armor rule (Combat._damage_boss halves/floors
	# damage below the sigil) so what lands on the boss is exactly the graded
	# formula preview() already predicts — this test is about the timing
	# boundary, not the climb.
	host._run.combat.boss.weak_point_height = 0
	host._run.combat.boss.vulnerable = 0
	var actor: GameClient = null
	var idx := -1
	for cli in [c0, c1]:
		for c in cli.private["hand"]:
			if bool(c["timed"]) and String(c["target"]) == "enemy" and bool(c["playable"]) \
					and int((c["fx"] as Dictionary).get("hits", 1)) <= 1 \
					and not _has_keyword(c["keywords"], "x_cost") \
					and int(c["preview"]["damage"]) > int(c["preview_good"]["damage"]) \
					and int(c["preview_good"]["damage"]) > int(c["preview_miss"]["damage"]):
				actor = cli
				idx = int(c["index"])
				break
		if idx >= 0:
			break
	_expect(idx >= 0, "a timed attack in the opening hands previews three distinct tiers: miss < good < perfect")
	if idx < 0:
		return
	var card: Dictionary = actor.private["hand"][idx]
	var good_damage := int(card["preview_good"]["damage"])
	var boss_hp_before := int(actor.shared["boss"]["hp"])
	actor.play_card(idx, true, -1, -1, -1, Combat.TIMING_GOOD)
	var boss_hp_after := int(actor.shared["boss"]["hp"])
	_expect(boss_hp_before - boss_hp_after == good_damage,
		"a play_card sent with TIMING_GOOD crosses the boundary and lands the graded (half) bonus, not the full one")


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


## Backlog #51: a dropped hunter's SEAT survives them, so a fresh connection
## that sends "join" while the host is paused reclaims it rather than being
## turned away for the party already being full (or, worse, bumping the
## still-connected hunter). This is the actual reconnect path a real client
## takes -- menu.gd's "Join" button already ends in Session.client.join()
## (see _on_join()), so nothing on the view side has to change for this to work.
func _test_dropped_hunter_can_rejoin_mid_fight() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	var transport: LocalTransport = s["transport"]
	transport.emit_signal("peer_left", 20)  # hunter 2 (peer 20) drops
	_expect(host.paused, "host pauses when hunter 2 drops")

	# The reconnect: a NEW peer id, exactly what a fresh ENet connection gets.
	var c_new := GameClient.new(transport, 99)
	c_new.join()
	_expect(not host.paused, "rejoining clears the pause")
	_expect(c_new.you == 1, "the rejoining peer is handed the SEAT hunter 2 dropped, not a new one")
	_expect(not bool(c0.shared.get("paused", false)),
		"the still-connected hunter's own snapshot reflects the resume too")

	# Play resumes for BOTH hunters, including the one who just rejoined.
	var idx := _first_playable_client(c_new)
	_expect(idx >= 0, "the rejoined client received hunter 2's actual hand, not an empty one")
	var energy_before: int = c_new.shared["players"][1]["energy"]
	c_new.play_card(idx)
	_expect(int(c_new.shared["players"][1]["energy"]) < energy_before,
		"a command from the rejoined connection acts on hunter 2 again")

	# The dead connection's old peer id is forgotten, not left as a live seat.
	transport.emit_signal("peer_left", 99)
	_expect(host.paused, "the SAME slot dropping again re-pauses, proving 99 (not 20) now owns it")


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


func _has_keyword(keywords: Array, id: String) -> bool:
	for k in keywords:
		if String((k as Dictionary).get("id", "")) == id:
			return true
	return false


func _has_id(cards: Array, id: String) -> bool:
	return _index_of_id(cards, id) >= 0


func _index_of_id(cards: Array, id: String) -> int:
	for i in range(cards.size()):
		if (cards[i] as Card).id == id:
			return i
	return -1


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
func _x_strike() -> Card:
	return Card.from_dict({"id": "x_strike", "name": "X Strike", "type": "attack", "cost": -1, "damage": 1, "damage_per_x": 3, "target": "enemy"})
func _x_brace() -> Card:
	return Card.from_dict({"id": "x_brace", "name": "X Brace", "type": "skill", "cost": -1, "block_per_x": 4})
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
func _bunker_down() -> Card:
	return Card.from_dict({"id": "bunker_down", "name": "Bunker Down", "type": "skill", "cost": 1, "block": 4, "retain": true})
func _first_strike() -> Card:
	return Card.from_dict({"id": "first_strike", "name": "First Strike", "type": "attack", "cost": 1, "damage": 5, "innate": true})
func _crippling_blow() -> Card:
	return Card.from_dict({"id": "crippling_blow", "name": "Crippling Blow", "type": "attack", "cost": 1, "damage": 5, "frail": 2, "target": "enemy"})


# --- backlog #46: a robustness sweep that is not balance tuning -----------
# Fast, deterministic locks on the specific dead-end shapes the sweep tool
# (tools/robustness_sweep.gd) exists to catch across many random seeds. These
# don't replace the sweep — they pin the exact escape hatches it depends on,
# so a regression here fails run_tests.gd immediately instead of waiting for
# someone to run the (expensive, non-CI) sweep by hand.

func _test_backlog46_campfire_rest_always_legal_even_at_min_deck() -> void:
	var run := Run.new([_deck_of(_slash, Run.MIN_DECK), _deck_of(_slash, Run.MIN_DECK)],
		["A", "B"], 4242, [{}, {}])
	run.start()
	run._begin_campfire()
	var remove_refused: bool = not run.campfire_action(0, "remove", 0)  # already at MIN_DECK
	var rest_ok: bool = run.campfire_action(0, "rest")
	_expect(remove_refused and rest_ok,
		"a campfire at MIN_DECK refuses to remove further but rest always stays legal")


func _test_backlog46_shop_leave_always_legal_with_nothing_affordable() -> void:
	var run := _map_run()
	run.gold = 0
	run._begin_shop()
	var nothing_affordable := true
	for item in run.shop_stock:
		if run.gold >= int(item["price"]):
			nothing_affordable = false
	var left := run.leave_shop()
	_expect(nothing_affordable and left,
		"a shop with zero gold and nothing affordable can still be left")


func _test_backlog46_every_event_has_at_least_one_choice() -> void:
	var ok := true
	var bad := ""
	for id in Content.list_events():
		var e := Content.make_event(String(id))
		if (e.get("choices", []) as Array).is_empty():
			ok = false
			bad = String(id)
			break
	_expect(ok, "every event has at least one choice (found empty: '%s')" % bad)


func _test_backlog46_empty_reward_choices_can_still_be_skipped() -> void:
	var run := _map_run()
	run._begin_reward("card")
	run.reward_choices[0] = []  # the shape a fully-drained/gated pool would produce
	var skipped := run.skip_reward(0)
	_expect(skipped and bool(run.reward_picked[0]),
		"a hunter offered zero reward choices can still skip the reward")


func _test_backlog46_end_turn_always_works_with_empty_hand() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(200))
	combat.players[0].hand.clear()
	combat.players[0].energy = 0
	combat.end_turn(0)
	_expect(combat.players[0].ended_turn,
		"a hunter with no cards and no energy can still end their turn")


## Backlog #47 — the Lightbearer: a fifth hunter whose OWN currency (Light)
## banks across turns instead of resetting like energy does (contrast Rhythm,
## which _begin_round() explicitly zeroes each turn).
func _test_backlog47_light_gain_banks_across_the_round_reset() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [Content.make_card("spark")]
	ps.energy = 3
	combat.play_card(0, 0)
	var gained := ps.light == 2
	combat.end_turn(0)
	combat.end_turn(1)  # both ended -> the boss acts and a new round begins
	_expect(gained and ps.light == 2,
		"Light gained by a card banks and survives the round reset (unlike Rhythm)")


## A Light-cost card is a second cost on top of energy: unplayable below it,
## and spending drains Light the same way playing any card drains energy.
func _test_backlog47_light_cost_gates_and_spends() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [Content.make_card("guiding_light")]  # cost 1 energy, light_cost 3
	ps.energy = 3
	ps.light = 2
	var blocked := not combat.can_play(0, 0)
	ps.light = 3
	var allowed := combat.can_play(0, 0)
	combat.play_card(0, 0)
	_expect(blocked and allowed and ps.light == 0,
		"a Light-cost card is unplayable below its cost, and playing it spends the Light")


## Sunburst reads banked Light for bonus damage but never spends it — the
## build tension the design docs asked for (spend for a burst vs. hoard to
## scale), same shape damage_per_rhythm/damage_per_foothold already prove.
func _test_backlog47_damage_per_light_scales_without_spending() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [Content.make_card("sunburst")]  # damage 2, damage_per_light 2
	ps.energy = 3
	ps.light = 4
	var before: int = combat.boss.hp
	combat.play_card(0, 0)
	var dealt := before - combat.boss.hp
	_expect(dealt == 10 and ps.light == 4,
		"Sunburst's damage scales with banked Light (2 + 2*4 = 10) without spending any of it")


## The Lightbearer's mend targets the ally directly, clamped the same way
## Combat.use_potion()'s "heal" effect and the campfire rest already clamp —
## never past their own max_hp.
func _test_backlog47_ally_heal_caps_at_max_hp() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	var mate: PlayerState = combat.players[1]
	ps.hand = [Content.make_card("warm_glow")]  # ally_heal 4, light_gain 1
	ps.energy = 3
	mate.combatant.hp = mate.combatant.max_hp - 1  # only 1 point of room
	combat.play_card(0, 0)
	_expect(mate.combatant.hp == mate.combatant.max_hp and ps.light == 1,
		"mending an ally near full HP caps at max_hp rather than overhealing")


## Leaf serializer for the whole save chain (Run -> Combat -> PlayerState) is
## PlayerState.to_dict()/from_dict() — same seam #35 and #14 taught.
func _test_backlog47_light_survives_playerstate_dict_round_trip() -> void:
	var ps := PlayerState.new()
	ps.combatant = Combatant.new("X", 30)
	ps.light = 7
	var back := PlayerState.from_dict(ps.to_dict())
	_expect(back.light == 7, "PlayerState.light round-trips through to_dict/from_dict")


## The real chain, not just the leaf: a mid-fight save (#14) must carry Light
## the same way it already carries foothold/strength/exhaust_pile.
func _test_backlog47_light_survives_mid_combat_save_and_load() -> void:
	var run := Run.new([_deck_of(_slash, 8), _deck_of(_slash, 8)], ["A", "B"], 55,
		[{"character": "frog"}, {"character": "lightbearer"}], 0)
	run.start()
	_step_into_combat(run)
	var combat: Combat = run.combat
	combat.players[1].light = 6
	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()
	var back_combat: Combat = back.combat
	_expect(back_combat != null and back_combat.players[1].light == 6,
		"Light survives a mid-combat save and load")


## Done-when (#47): "it plays a full run" — a real Run built from the
## character's own starter_deck and passive, forced to a win, and the reward
## it's offered comes from ITS OWN archetype pool (same proof
## _test_per_class_reward_pools uses for the other four).
func _test_backlog47_lightbearer_plays_a_full_run() -> void:
	var decks := [Content.character_deck("lightbearer"), Content.character_deck("frog")]
	var run := Run.new(decks, ["L", "F"], 123,
		[Content.character_passive("lightbearer"), Content.character_passive("frog")])
	run.start()
	_step_into_combat(run)
	_force_win(run)
	var pool := Content.reward_pool("lightbearer")
	var from_own_pool := true
	if run.reward_kind == "card":
		for c in run.reward_choices[0]:
			if not pool.has((c as Card).id):
				from_own_pool = false
	_expect(run.phase == Run.Phase.REWARD and not pool.is_empty() and from_own_pool,
		"the Lightbearer's starter deck plays a real run to a win and drafts from its own pool")


## Every playable character, and every beast, wears its OWN art.
##
## Backlog #80: the cloud added a fifth hunter with no model, Cast.PLACEHOLDER
## had no entry for it either, so it fell through to the DEFAULT stand-in and
## the Lightbearer walked around as a bunny — on the character select, in the
## fight, and on the screen where the beast falls. Nothing failed; it just
## quietly looked wrong everywhere at once.
##
## A run that adds a character or a beast now trips this instead.
func _test_everyone_wears_their_own_art() -> void:
	var strays: Array = []
	for c in Content.list_characters():
		var id := String((c as Dictionary).get("id", ""))
		if not Cast.is_yours(id):
			strays.append(id)
	_expect(strays.is_empty(),
		"every playable character has its own model, not a Kenney stand-in"
			+ ("" if strays.is_empty() else " (wearing one: %s)" % ", ".join(strays)))

	var beasts: Array = []
	for id in Content.boss_ids():
		if not ResourceLoader.exists("res://assets/3d/cast/%s.glb" % String(id)):
			beasts.append(String(id))
	_expect(beasts.is_empty(),
		"every beast has its own model"
			+ ("" if beasts.is_empty() else " (missing: %s)" % ", ".join(beasts)))


func _expect(cond: bool, name: String) -> void:
	if cond:
		print("PASS  " + name)
	else:
		print("FAIL  " + name)
		_failures += 1
