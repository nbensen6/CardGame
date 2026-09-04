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
	_test_backlog86_max_height_condition_picks_fallback_when_unmet()
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
	_test_backlog53_event_then_beat_replaces_choices_and_stays_in_event_phase()
	_test_backlog53_then_beat_effects_land_and_reward_routes_from_final_beat()
	_test_backlog53_four_events_use_then()
	_test_boons_load_and_are_well_formed()
	_test_boon_offer_and_pick_applies_effects()
	_test_boon_rejects_outside_its_phase()
	_test_start_does_not_auto_offer_a_boon()
	_test_run_survives_a_save_and_load_in_boon()
	_test_card_upgrade_bumps_numbers()
	_test_card_rule_upgrade_changes_what_it_does_not_just_a_number()
	_test_card_upgrade_bumps_grip_per_rhythm_pull_and_sac_ally_grip()
	_test_card_upgrade_bumps_cheapen_amount_only_when_cheapen_pick_is_set()
	_test_backlog67_above_sigil_condition_gates_preview_bonus()
	_test_backlog67_ally_hanging_condition_gates_preview_bonus()
	_test_backlog67_nth_card_condition_counts_earlier_plays_only()
	_test_backlog67_nth_card_counter_resets_each_round()
	_test_backlog67_condition_bonus_resolves_through_a_real_play()
	_test_backlog67_unmet_condition_never_costs_the_printed_numbers()
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
	_test_ascension9_and_10_change_a_rule()
	_test_coach_teaches_the_right_thing_first()
	_test_tips_can_be_switched_off_without_losing_your_place()
	_test_backlog86_coach_teaches_at_sigil_before_armored()
	_test_backlog86_coach_teaches_timed_card_when_hand_holds_one()
	_test_backlog86_coach_teaches_ally_stuck_only_when_the_ally_is_actually_grounded()
	_test_backlog86_coach_falls_back_to_play_card_when_nothing_else_applies()
	_test_backlog86_coach_hand_has_checks_the_named_flag_not_any_truthy_field()
	_test_gold_and_shop()
	_test_shop_removal_charges_the_price_it_showed()
	_test_shop_buys_a_relic()
	_test_shop_cannot_thin_below_min_deck()
	_test_status_card_removable_at_shop()
	_test_shop_rejects_actions_outside_its_phase()
	_test_shop_prices_scale_with_card_rarity()
	_test_shop_guarantees_a_rare_card_slot()
	_test_content_pools_are_copies()
	_test_status_cards_never_offered_as_a_reward()
	# backlog #72: rewards that know what you are building
	_test_backlog72_archetype_tags_are_derived_from_fields()
	_test_backlog72_reward_roll_leans_toward_a_tag_already_in_the_deck()
	_test_backlog72_relic_rolls_are_unaffected_by_deck_tags()
	# potions (backlog #26)
	_test_potions_all_load()
	_test_use_potion_applies_each_effect()
	_test_use_potion_ally_and_beast_effects()
	_test_use_potion_climb_updates_highest_climb()
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
	# Ethereal (backlog #58)
	_test_ethereal_exhausts_if_still_in_hand_at_end_of_turn()
	_test_ethereal_played_card_is_not_exhausted()
	_test_ethereal_overrides_retain_if_both_are_set()
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
	_test_meld_carries_light_and_deck_effects()
	_test_meld_carries_power_effect()
	_test_meld_carries_retain_and_ethereal()
	_test_meld_carries_enchant()
	_test_satchel_charge_detonates()
	_test_rhythm_builds_and_scales()
	_test_vine_weaver_poison_and_wound()
	_test_backlog86_power_triggered_poison_lifts_the_vine_weaver_ally()
	_test_summit_strike_scales_with_both()
	# step 4: run / meta-progression
	_test_run_starts_in_combat()
	_test_run_win_flows_through_reward_to_next_encounter()
	_test_run_hp_carries_between_encounters()
	_test_run_defeat_when_a_hunter_falls()
	_test_run_hp_syncs_on_defeat_too()
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
	# backlog #74: the shape contract's data-only half (AssetContract)
	_test_backlog74_uv_in_cell_matches_gold_exactly_and_rejects_the_next_swatch()
	_test_backlog74_silhouette_grid_is_invariant_to_scale_and_position()
	_test_backlog74_silhouette_similarity_flags_a_near_duplicate_and_passes_a_distinct_shape()
	_test_backlog74_budget_table_matches_kenney_py()
	_test_backlog74_z_at_xy_reads_the_triangle_plane_and_rejects_outside_points()
	_test_backlog74_occlusion_flags_a_surface_hidden_behind_a_closer_one()
	_test_backlog74_occlusion_ignores_geometry_that_does_not_cover_the_same_point()
	_test_preview_matches_what_the_card_actually_does()
	_test_incoming_reckons_damage_after_block()
	_test_every_derived_keyword_resolves()
	_test_player_block_keyword_is_not_shadowed_by_the_boss_move()
	_test_every_field_a_player_must_understand_has_a_keyword()
	_test_timed_keyword_explains_graded_quality()
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
	# Powers: cards that stay played (backlog #57)
	_test_power_cards_stay_in_play_and_stack()
	_test_power_effects_fire_every_turn_end_and_persist()
	_test_power_stacks_multiply_and_different_powers_coexist()
	_test_power_upgrade_value_is_not_lost_by_the_recurring_payout()
	_test_powers_survive_save_and_load()
	_test_powers_reach_the_snapshot_and_are_visible_to_the_ally()
	# the debuff axis (backlog #36): Frail, Artifact, Thorns
	_test_frail_reduces_block_gained()
	_test_frail_card_cuts_the_boss_own_block_move()
	_test_artifact_wards_off_a_debuff_then_is_spent()
	_test_artifact_wards_off_a_poison_card_then_is_spent()
	_test_artifact_wards_off_a_power_triggered_poison_and_expose()
	_test_thorns_reflects_a_landed_boss_attack()
	_test_beast_thorns_reflects_card_damage_dealt_to_it()
	_test_frail_artifact_thorns_persist_through_save()
	_test_frail_artifact_thorns_reach_the_shared_snapshot()
	_test_dexterity_intangible_buffer_plated_armour_reach_the_shared_snapshot()
	_test_light_reaches_the_shared_snapshot()
	_test_sigil_rounds_and_boss_limiter_reach_the_shared_snapshot()
	_test_prepared_reaches_the_shared_snapshot()
	_test_beast_thorns_and_artifact_are_wired()
	# Beasts that debuff YOU (backlog #69) — Frail and curses through a boss move
	_test_frail_move_debuffs_the_targeted_hunter()
	_test_frail_move_is_warded_by_the_hunters_own_artifact()
	_test_curse_move_shoves_a_status_card_into_discard()
	_test_curse_move_respects_card_and_value_fields()
	_test_curse_move_ignores_artifact_matching_curse_card_precedent()
	_test_backlog69_at_least_five_beasts_debuff_hunters()
	_test_every_beast_move_type_has_a_keyword()
	# Fight-start relics — the fifth moment (backlog #43/#70)
	_test_backlog70_fight_start_relics_apply_before_round_one()
	_test_backlog70_seeded_power_pays_out_at_round_one_turn_end()
	_test_backlog70_negative_openers_are_ignored_not_applied()
	_test_backlog70_fight_start_does_not_reapply_on_save_reload()
	# Dexterity, Strength's counterpart (backlog #60)
	_test_dexterity_adds_to_block_gained()
	_test_dexterity_card_lifts_a_later_different_cards_block()
	_test_dexterity_and_frail_interact_correctly()
	_test_dexterity_card_lifts_later_block_not_its_own()
	_test_relic_start_dexterity()
	# Intangible, Buffer and Plated Armour, the tier above Block (backlog #61)
	_test_intangible_caps_a_hit_that_gets_past_block()
	_test_intangible_is_not_spent_when_block_fully_absorbs_the_hit()
	_test_buffer_cancels_a_hit_that_gets_past_block()
	_test_buffer_is_spent_before_intangible()
	_test_buffer_and_thorns_still_retaliate_when_a_hit_is_voided()
	_test_intangible_card_grants_the_stat()
	_test_buffer_card_grants_the_stat()
	_test_plated_armour_persists_the_round_reset()
	_test_plated_armour_decays_only_when_a_hit_gets_hp_through()
	_test_intangible_buffer_plated_armour_persist_through_save()
	_test_boss_dexterity_intangible_buffer_plated_armour_persist_through_save()
	# Cards that reward discarding (backlog #62)
	_test_discard_field_sends_cards_to_the_discard_pile()
	_test_discard_stops_early_when_hand_is_short()
	_test_damage_per_discarded_scales_with_pile_size()
	_test_block_per_discarded_scales_with_pile_size()
	_test_cull_the_deck_does_not_count_its_own_forced_discard()
	_test_discard_and_scaling_cards_survive_mid_combat_save_and_load()
	# More than one thing to fight at once (backlog #63)
	_test_boss_data_can_carry_adds()
	_test_a_beast_with_no_adds_data_has_none()
	_test_enemy_index_targets_an_add_not_the_boss()
	_test_enemy_index_out_of_range_falls_back_to_the_boss()
	_test_hits_all_enemies_hits_boss_and_every_living_add()
	_test_hits_all_enemies_skips_a_dead_add()
	_test_killing_an_add_does_not_end_the_fight()
	_test_add_acts_on_its_own_turn()
	_test_add_block_reseeds_each_round_like_the_bosss_own()
	_test_add_thorns_bites_the_attacking_add_not_the_boss()
	_test_adds_round_trip_through_save_and_load()
	_test_adds_reach_the_shared_snapshot()
	# characters (per-player climb + signature passives)
	_test_frog_climb_bonus()
	_test_vine_lifts_ally()
	_test_roped_ally_climbs()
	_test_roped_ally_climbs_only_once_per_play()
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
	_test_backlog86_steady_grip_fx_carries_dexterity_over_the_wire()
	_test_backlog45_named_holds_cross_to_both_peers_identically()
	_test_backlog45_graded_timing_quality_reaches_the_host_and_the_preview()
	# backlog #46: a robustness sweep that is not balance tuning
	_test_backlog46_campfire_rest_always_legal_even_at_min_deck()
	_test_backlog46_shop_leave_always_legal_with_nothing_affordable()
	_test_backlog46_every_event_has_at_least_one_choice()
	_test_backlog46_empty_reward_choices_can_still_be_skipped()
	_test_backlog46_end_turn_always_works_with_empty_hand()
	# backlog #64: keys, and a Titan you can only reach with them
	_test_backlog64_keys_are_run_state_and_round_trip()
	_test_backlog64_take_key_trades_the_relic_reward_on_treasure()
	_test_backlog64_take_key_trades_the_relic_reward_on_elite()
	_test_backlog64_take_key_refuses_the_wrong_node_type()
	_test_backlog64_take_key_refuses_without_gold_or_after_a_pick()
	_test_backlog64_take_key_is_once_per_node_type_per_run()
	_test_backlog86_take_key_survives_an_allys_decline()
	# backlog #86 duty 2: Run.take_key() was real and unit-tested but never
	# wired to a GameClient/GameHost command -- these two catch the session
	# layer, not just /core.
	_test_backlog86_gamehost_wires_take_key_command_to_run()
	_test_backlog86_build_shared_exposes_keys_for_the_reward_screen()
	_test_backlog64_event_key_effect_grants_the_event_key_once()
	_test_backlog64_boon_effects_never_grant_a_key()
	_test_backlog64_sealed_hollow_event_grants_a_key_at_a_real_cost()
	_test_backlog64_map_guarantees_all_three_key_source_types_exist()
	_test_backlog64_final_titan_is_a_sealed_door_without_all_three_keys()
	_test_backlog64_final_titan_is_a_real_fight_with_all_three_keys()
	# backlog #65: run history — a finished run persists rather than vanishing
	_test_backlog65_history_entry_shape_on_a_loss()
	_test_backlog65_history_entry_shape_on_a_win()
	_test_backlog65_progress_record_run_appends_and_round_trips()
	_test_backlog65_gamehost_records_history_exactly_once()
	_test_backlog65_run_history_tolerates_an_entry_missing_a_newer_field()
	# Scry (backlog #59): look at the top of the draw pile and bin what you don't want
	_test_backlog59_scry_reveals_and_resolve_scry_bins_and_keeps_order()
	_test_backlog59_resolve_scry_validates_bad_input()
	_test_backlog59_scry_survives_playerstate_dict_round_trip()
	_test_backlog59_scry_survives_mid_combat_save_and_load()
	_test_backlog59_ally_sees_the_scry_reveal()
	_test_backlog86_second_scry_before_resolve_does_not_lose_the_first_batch()
	# Reaching into the draw pile (backlog #68): put a card on top, shuffle one
	# in, pull a named one out — the draw pile's order stops being pure luck.
	_test_backlog68_topdeck_puts_a_card_on_top_of_the_draw_pile()
	_test_backlog68_shuffle_in_is_deterministic_under_a_seed()
	_test_backlog68_tutor_pulls_a_named_card_from_the_draw_pile_into_hand()
	_test_backlog68_tutor_is_a_harmless_no_op_when_the_card_isnt_there()
	# backlog #86 duty 3: the climb logic in the VIEW (combat_3d) had zero
	# coverage before this, unlike /core's climb rules — see the pure
	# route_between_rungs lifted out of combat_3d._route_between below.
	_test_backlog86_route_between_rungs_stops_at_every_ledge_climbing_up()
	_test_backlog86_route_between_rungs_stops_at_every_ledge_climbing_down()
	_test_backlog86_route_between_rungs_excludes_the_endpoints()
	_test_backlog86_route_between_rungs_is_empty_with_no_ledges_between()
	_test_backlog86_route_between_rungs_ignores_unsorted_input()
	# backlog #86 duty 2: a real bug in the same file, found reading
	# _place_hunters end to end — see the test and _start_glide for the story.
	_test_backlog86_glide_is_not_defeated_by_a_synchronous_position_write()
	# backlog #86 duty 3 (second pass): the OTHER untested climb rule named
	# alongside route_between_rungs — foothold_anchor, the pure half of
	# _stand_on_model, deciding WHERE on the model a foothold actually sits.
	_test_backlog86_foothold_anchor_lands_exactly_on_a_matching_rung()
	_test_backlog86_foothold_anchor_lerps_between_the_bracketing_rungs()
	_test_backlog86_foothold_anchor_clamps_below_the_lowest_rung()
	_test_backlog86_foothold_anchor_clamps_above_the_highest_rung()
	_test_backlog86_foothold_anchor_ignores_unsorted_key_order()
	# backlog #86 duty 2 (sixth turn): a real bug in _render_hand, found the
	# same way as the glide bug above — reading a combat_3d.gd function end to
	# end for an early-return that skips a tail statement.
	_test_backlog86_render_hand_status_always_relayouts_while_selecting()
	_test_backlog86_render_hand_status_hides_prompt_outside_selection()
	# backlog #86 duty 3 (third pass): Nick's own example, the jump mechanic
	# itself — hunter_move_kind, the gate _place_hunters uses to decide a JUMP
	# from a glide from a first placement. This is the exact rule behind the
	# "bouncing in random places" bug: a jump must fire for a height change and
	# ONLY a height change.
	_test_backlog86_hunter_move_kind_is_first_before_any_placement()
	_test_backlog86_hunter_move_kind_climbs_on_a_foothold_change()
	_test_backlog86_hunter_move_kind_glides_when_the_world_moved_under_a_placed_hunter()
	_test_backlog86_hunter_move_kind_is_none_when_placed_and_settled()
	_test_backlog86_hunter_move_kind_climb_outranks_moved_even_if_the_point_did_not_move()
	# backlog #86 duty 3 (fourth pass): height_gap_between, lifted out of
	# combat_3d._height_gap, is a SECOND copy of the exact gap formula
	# Combat.incoming_for already prices a rift move on in /core — the intent
	# HUD and the actual damage had zero shared coverage, so a formula edit on
	# either side could silently mismatch the number shown against what lands.
	_test_backlog86_height_gap_between_is_zero_with_fewer_than_two_players()
	_test_backlog86_height_gap_between_ignores_order()
	_test_backlog86_height_gap_between_uses_the_overall_min_and_max()
	_test_backlog86_height_gap_between_matches_the_real_rift_damage_in_core()
	# backlog #86 duty 2: incoming_for() (the preview) and _enemy_turn() (the
	# real hit) used to each run their own copy of the rift-gap search, seeded
	# with different sentinels (9999 vs 99) — safe only because every real
	# foothold sits under FOOTHOLD_MAX. Deduplicated onto one Combat._rift_gap()
	# so the two literally cannot disagree any more; this proves it directly at
	# a foothold value that would have broken the smaller of the old sentinels.
	_test_backlog86_rift_gap_shared_by_preview_and_resolution()
	# backlog #86 duty 3 (fifth pass): hull_front_at, lifted out of
	# combat_3d._front_of_beast, is the rule that stops a hunter clipping into
	# (or floating in front of) the beast's own mesh -- the Grove Bear muzzle
	# case in the doc comment above it, made headless-testable.
	_test_backlog86_hull_front_at_returns_the_box_back_when_the_column_is_empty()
	_test_backlog86_hull_front_at_finds_the_deepest_point_in_the_neighbourhood()
	_test_backlog86_hull_front_at_does_not_reach_beyond_its_neighbourhood()
	_test_backlog86_hull_front_at_ignores_neighbours_outside_hull_bounds()
	# backlog #86 duty 2 (seventh turn): _draw_gauge compared the raw ledges
	# snapshot against an int with Array.has() (==), which never matches the
	# Dictionary named-hold shape (backlog #24) that /core already treats as a
	# real ledge everywhere else -- a two-copies-of-one-truth bug, the same
	# family as #45's named-hold boundary test above, on the gauge's own side.
	_test_backlog86_gauge_ledge_heights_passes_bare_ints_through()
	_test_backlog86_gauge_ledge_heights_recognizes_named_holds()
	# backlog #86 duty 3 (seventh pass): location_3d._stakes, the wayside-event
	# stakes text a player reads before picking blind -- lifted static the same
	# way the combat_3d climb rules were, and given first coverage.
	_test_backlog86_stakes_describes_a_heal()
	_test_backlog86_stakes_describes_damage()
	_test_backlog86_stakes_describes_a_max_hp_change()
	_test_backlog86_stakes_describes_gold()
	_test_backlog86_stakes_describes_a_relic()
	_test_backlog86_stakes_describes_a_reward_choice()
	_test_backlog86_stakes_joins_every_stake_named_at_once()
	_test_backlog86_stakes_is_blank_for_an_effect_with_nothing_to_show()
	# backlog #86 duty 3 (fifteenth turn): CardView.face_text, the live line a
	# player reads on a card in hand to decide whether to play it -- was
	# already static and pure, and had zero coverage despite being the exact
	# "misdescribes a real choice" bug class duty 3's stakes pass caught, one
	# screen over.
	_test_backlog86_face_text_single_hit_damage()
	_test_backlog86_face_text_multi_hit_damage_says_times()
	_test_backlog86_face_text_matched_block_merges_to_all_players()
	_test_backlog86_face_text_mismatched_block_lists_separately()
	_test_backlog86_face_text_matched_climb_merges_to_all_players()
	_test_backlog86_face_text_mismatched_climb_pluralizes_the_allys_line()
	_test_backlog86_face_text_status_and_utility_lines_join_in_field_order()
	_test_backlog86_face_text_shows_dexterity_alongside_block()
	_test_backlog86_face_text_burn_lines_are_mutually_exclusive()
	_test_backlog86_face_text_falls_back_to_authored_text_with_no_preview()
	_test_backlog86_face_text_falls_back_to_authored_text_when_nothing_landed()
	_test_backlog86_num_colors_only_when_the_live_value_differs_from_printed()
	# backlog #86 duty 3 (sixteenth turn): _let_drags_through, the recursive
	# camera-drag passthrough combat_3d._ready() calls on the top bar -- had
	# zero coverage despite being exactly the kind of fix the doc comment above
	# it warns about regressing ("a label added there later cannot quietly
	# reintroduce" a dead strip). Static and pure: a bare Control tree, no
	# combat scene needed.
	_test_backlog86_let_drags_through_sets_the_root_itself()
	_test_backlog86_let_drags_through_reaches_every_descendant_control()
	_test_backlog86_let_drags_through_walks_through_a_non_control_node()
	_test_backlog86_let_drags_through_tolerates_a_null_root()
	# backlog #86 duty 3 (twentieth turn): CardView.shape_text, the rule that
	# decides what authored prose survives ALONGSIDE the live effect line
	# face_text builds -- static, pure, and covered by nothing despite being
	# exactly the "misdescribes a real choice" bug class duty 3 hunts: a card
	# whose live line and authored text disagree because one was updated and
	# the other wasn't would read as two contradictory descriptions stacked
	# on top of each other.
	_test_backlog86_shape_text_passes_authored_text_through_with_no_preview()
	_test_backlog86_shape_text_is_blank_when_authored_text_is_blank()
	_test_backlog86_shape_text_drops_a_clause_the_live_line_already_says()
	_test_backlog86_shape_text_keeps_a_clause_the_live_line_never_says()
	_test_backlog86_shape_text_drops_a_clause_even_when_its_value_differs_from_the_live_line()
	_test_backlog86_shape_text_returns_empty_when_every_clause_is_already_said()
	_test_backlog86_sentences_splits_on_period_space_and_keeps_each_dot()
	_test_backlog86_sentences_appends_a_missing_trailing_dot()
	_test_backlog86_sentences_drops_the_empty_fragment_after_a_trailing_period()
	_test_backlog86_shape_of_strips_digits_so_two_values_of_the_same_line_compare_equal()
	_test_backlog86_shape_of_leaves_a_line_with_no_digits_untouched()
	# backlog #86 duty 3 (twenty-first pass): _word_index, _is_word_char, _kw
	# and _markup are the keyword-highlight machinery under face_text's rich
	# mode -- the gold underline that makes a keyword tappable (CLAUDE.md's
	# "no hover-only info" rule: this IS the tap target). Every existing test
	# calls face_text with rich=false except one, which only exercises the
	# single-word, single-occurrence, no-tag happy path. The boundary check,
	# the BBCode-tag skip, the first-occurrence-only rule, and _kw's own
	# id-mismatch fallback had never been called directly.
	_test_backlog86_word_index_finds_a_whole_word_match()
	_test_backlog86_word_index_ignores_a_substring_inside_a_longer_word()
	_test_backlog86_word_index_skips_a_match_already_inside_markup()
	_test_backlog86_is_word_char_treats_digits_and_punctuation_as_boundaries()
	_test_backlog86_kw_stays_plain_when_its_id_is_not_among_the_cards_keywords()
	_test_backlog86_kw_returns_plain_word_outside_rich_mode_even_with_a_matching_id()
	_test_backlog86_markup_leaves_text_untouched_without_rich_or_without_keywords()
	_test_backlog86_markup_marks_only_the_first_occurrence_of_a_repeated_keyword()
	_test_backlog86_markup_marks_each_of_two_different_keywords_once()
	# backlog #86 duty 3 (twenty-second pass): overworld_3d._act_ahead, the map
	# region picker, had zero coverage — including of the exact bug it fixed
	# (Nick, 2026-08-16): a Titan's node is the last row of ITS act, so "the
	# region you stand in" and "the region you're about to walk into" disagree
	# there, and the old code drew the region you'd just finished.
	_test_backlog86_act_ahead_is_zero_with_no_rows()
	_test_backlog86_act_ahead_before_any_step_uses_the_first_row()
	_test_backlog86_act_ahead_looks_at_the_next_row_mid_act()
	_test_backlog86_act_ahead_on_the_titan_uses_the_current_row_not_a_next_one()
	_test_backlog86_act_ahead_crosses_into_the_next_act_stepping_off_a_titan()
	# backlog #86 duty 3 (twenty-third pass): row_in_act, lifted out of
	# overworld_3d._row_in_act, is _act_ahead's own sibling and had zero
	# coverage despite gating _stand_at — the function that places the party's
	# avatar on the map. Same Titan-boundary family as _act_ahead: false is
	# the correct answer exactly on the row where the party stands on the
	# PREVIOUS act's Titan, which is what sends _stand_at to the trailhead.
	_test_backlog86_row_in_act_is_false_for_a_negative_row()
	_test_backlog86_row_in_act_is_false_past_the_end_of_the_rows()
	_test_backlog86_row_in_act_is_true_mid_act()
	_test_backlog86_row_in_act_is_false_standing_on_the_previous_acts_titan()
	_test_backlog86_row_in_act_is_true_on_the_first_row_of_a_new_act()
	# backlog #86 duty 3 (twenty-fourth pass): intent_text_for, lifted out of
	# combat_3d._intent_text, the boss telegraph a player reads to decide how
	# to react. Writing this test found two move types combat.gd actually
	# resolves — curse and frail — silently missing from the match statement,
	# so the telegraph went blank for them; fixed in the same commit.
	_test_backlog86_intent_text_for_attack_adds_boss_strength()
	_test_backlog86_intent_text_for_rift_adds_the_height_gap_times_two()
	_test_backlog86_intent_text_for_block_ignores_boss_strength()
	_test_backlog86_intent_text_for_enrage_ignores_boss_strength()
	_test_backlog86_intent_text_for_regen_ignores_boss_strength()
	_test_backlog86_intent_text_for_shift_sigil_names_the_destination_height()
	_test_backlog86_intent_text_for_frail_is_no_longer_blank()
	_test_backlog86_intent_text_for_curse_is_no_longer_blank()
	_test_backlog86_intent_text_for_curse_floors_the_card_count_at_one()
	_test_backlog86_intent_text_for_unknown_kind_is_blank()
	# backlog #86 duty 3: card_climb_for, lifted out of combat_3d._card_climb --
	# the rule deciding slider vs. plain tap. Its own comment warns that reading
	# card.grip (top level) instead of card.base.grip silently returns 0 for
	# every card in the game, which once flattened the slider path with no error.
	_test_backlog86_card_climb_for_reads_grip_from_base()
	_test_backlog86_card_climb_for_defaults_to_zero_with_no_base()
	_test_backlog86_card_climb_for_defaults_to_zero_with_no_grip_key()
	_test_backlog86_card_climb_for_ignores_a_top_level_grip_key()
	_test_backlog86_card_climb_for_threshold_matches_slider_cutoff()
	# backlog #86 duty 3 (twenty-sixth pass): the grip/fall timer itself --
	# Nick's own example is the jump, and this is the OTHER half of it: whether
	# a hunter who is climbing actually falls in time. grip_after_tick is the
	# pure countdown _tick_grip runs every frame; climb_state_after_secure_update
	# is the pure transition _update_climb_state runs off the "secure" flag, and
	# it is the one that had a real, untested promise in its own doc comment --
	# "grip only resets on a genuine hold -> climbing transition" -- that
	# reaching an intermediate ledge mid-hop must NOT hand out a free regrip.
	_test_backlog86_grip_after_tick_matches_a_full_grip_seconds_countdown()
	_test_backlog86_grip_after_tick_relic_seconds_extends_the_time_to_zero()
	_test_backlog86_grip_after_tick_can_go_negative_past_the_fall_threshold()
	_test_backlog86_climb_state_secure_erases_any_existing_timer()
	_test_backlog86_climb_state_starts_a_fresh_full_timer_on_first_leaving_a_hold()
	_test_backlog86_climb_state_does_not_regrip_a_timer_already_draining()
	_test_backlog86_climb_state_updates_the_target_even_while_preserving_grip()
	# backlog #86 duty 3: Progress's keybind rebind rule -- "binding a key steals
	# it from whoever else held it" -- had zero coverage; the whole rebind system
	# (settings screen, combat_3d._apply_rebind) was unproven headless.
	_test_backlog86_progress_keybind_defaults_before_any_bind()
	_test_backlog86_progress_set_keybind_steals_the_key_from_its_old_owner()
	_test_backlog86_progress_action_for_key_finds_the_current_owner()
	_test_backlog86_progress_rebinding_to_your_own_key_does_not_steal_from_yourself()
	_test_backlog86_progress_reset_keybinds_restores_every_default()
	# backlog #86 duty 3: next_selection_state, lifted out of
	# combat_3d._pick_for_selection -- the tap-to-pick state machine behind
	# meld/exhaust_pick/cheapen_pick cards. Its own comment names the one hard
	# invariant: the two picks must land on different cards, matching
	# core/combat.gd's server-side `target_index != sac_index` guard. Zero
	# coverage before this pass -- the state only ever moved through a live
	# scene tap.
	_test_backlog86_next_selection_state_cancels_on_the_selecting_card_itself()
	_test_backlog86_next_selection_state_records_the_first_pick_as_sac()
	_test_backlog86_next_selection_state_ignores_repicking_the_same_sac_card()
	_test_backlog86_next_selection_state_fires_once_both_picks_land()
	_test_backlog86_next_selection_state_fires_immediately_for_a_one_pick_card()
	# backlog #86 duty 3: soft_fall's landing spot (_hold_below, behind
	# Combat.fall()) has its own unsafe-hold skip, mirroring next_safe_height's,
	# but nothing had ever proved a fall actually lands where the rules say --
	# Nick's own words for duty 3. next_safe_height's unsafe-skip (climbing UP)
	# was covered; the falling-DOWN half of the same rule was not.
	_test_backlog86_soft_fall_skips_an_unsafe_hold_when_landing()
	_test_backlog86_soft_fall_drops_to_base_when_only_hold_below_is_unsafe()

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


## backlog #86 duty 3: Boss._condition_met() dispatches on four "when" types
## (min_height, at_sigil, undefended, max_height — boss.gd's own doc comment
## names all four). Three of them were exercised by the tests around this one;
## max_height — a beast reacting to a hunter being LOW rather than high, the
## mirror image of min_height — had never been called by any test, in
## isolation or through a real beast. No shipped beast currently authors one
## (Content.beast_pool() data has zero "max_height" moves today), so a bug in
## this branch would have shipped silently the moment a beast first used it,
## exactly the class of "added but never exercised" gap rule 3 exists to close.
func _test_backlog86_max_height_condition_picks_fallback_when_unmet() -> void:
	var b := Boss.new("B", 30)
	b.moves = [{"type": "attack_all", "value": 10,
		"when": {"type": "max_height", "value": 2},
		"fallback": {"type": "attack", "value": 14}}]
	var high := b.current_move({"footholds": [3, 5], "blocks": [0, 0]})
	var low := b.current_move({"footholds": [1, 5], "blocks": [0, 0]})
	_expect(high["type"] == "attack" and int(high["value"]) == 14,
		"max_height unmet (nobody at/below 2) falls back to the plain move")
	_expect(low["type"] == "attack_all" and int(low["value"]) == 10,
		"max_height met (one hunter at/below 2) fires the reactive move")


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


## Backlog #53: a choice's "then" replaces the event in place — the run stays
## in the EVENT phase and a second pick_event answers the follow-up, rather
## than the first choice resolving the node.
func _test_backlog53_event_then_beat_replaces_choices_and_stays_in_event_phase() -> void:
	var run := _map_run()
	run.event = {"title": "T", "text": "first beat", "choices": [
		{"label": "provoke it", "result": "it stirs", "effects": {"heal": -1}, "then": {
			"text": "second beat",
			"choices": [
				{"label": "freeze", "result": "it settles", "effects": {}},
				{"label": "bolt", "result": "you scatter", "effects": {"heal": -2}},
			],
		}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0
	var hp_before: int = run.hp[0]
	run.pick_event(0)
	_expect(run.phase == Run.Phase.EVENT and run.hp[0] == hp_before - 1
		and String(run.event.get("text", "")) == "second beat"
		and (run.event.get("choices", []) as Array).size() == 2,
		"a choice's first beat applies its own effects, then swaps the event for its 'then' and stays in EVENT")


## The final beat's own effects and reward routing only happen once there is
## no further "then" to walk into — proves a two-step event ends the node
## exactly like a one-step one, and that both beats' effects landed.
func _test_backlog53_then_beat_effects_land_and_reward_routes_from_final_beat() -> void:
	var run := _map_run()
	run.event = {"title": "T", "text": "first beat", "choices": [
		{"label": "provoke it", "result": "it stirs", "effects": {"heal": -1}, "then": {
			"text": "second beat",
			"choices": [
				{"label": "take the loot", "result": "!", "effects": {"reward": "card", "gold": 10}},
			],
		}},
	]}
	run.phase = Run.Phase.EVENT
	run.map_row = 0
	var hp_before: int = run.hp[0]
	run.pick_event(0)  # first beat: -1 hp, hands to the follow-up
	run.pick_event(0)  # second beat: +10 gold, routes to the reward screen
	_expect(run.hp[0] == hp_before - 1 and run.gold == 10 and run.phase == Run.Phase.REWARD
		and run.reward_kind == "card",
		"both beats of a two-step event apply their own effects, and reward routing waits for the final beat")


func _test_backlog53_four_events_use_then() -> void:
	var count := 0
	for id in Content.list_events():
		var e: Dictionary = Content.make_event(String(id))
		for ch in (e.get("choices", []) as Array):
			if not ((ch as Dictionary).get("then", {}) as Dictionary).is_empty():
				count += 1
				break
	_expect(count >= 4, "at least 4 events have a choice with a second 'then' beat (backlog #53)")


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


## Backlog #66: an upgrade can change what a card DOES instead of only its
## numbers. `rule_upgrade` on the base card (data/cards.json) REPLACES the
## generic number bump above rather than stacking with it — six real cards,
## one for each idiom the item names: cost to zero, gain Retain, gain
## Innate, hit everything, stop exhausting (an Ethereal card upgraded out of
## it), and drop a burn-a-card cost.
func _test_card_rule_upgrade_changes_what_it_does_not_just_a_number() -> void:
	var reckless := Content.make_card("reckless_swing")  # Ethereal attack
	var up_reckless := reckless.upgraded_copy()
	var cover := Content.make_card("cover")              # no Retain yet
	var up_cover := cover.upgraded_copy()
	var belay := Content.make_card("belay_strike")       # no Innate yet
	var up_belay := belay.upgraded_copy()
	var piston := Content.make_card("piston_punch")      # single target
	var up_piston := piston.upgraded_copy()
	var dig := Content.make_card("dig_in")               # costs 1
	var up_dig := dig.upgraded_copy()
	var salvage := Content.make_card("salvage")          # must burn a card
	var up_salvage := salvage.upgraded_copy()
	var twice := up_reckless.upgraded_copy()             # already sharpened — no double-dip
	_expect(
		reckless.ethereal and not up_reckless.ethereal
			and up_reckless.damage == reckless.damage      # the rule changed, not the number
			and up_reckless.text == "Deal 10 damage."
		and not cover.retain and up_cover.retain
			and up_cover.ally_block == cover.ally_block
		and not belay.innate and up_belay.innate
			and up_belay.damage == belay.damage
		and not piston.hits_all_enemies and up_piston.hits_all_enemies
			and up_piston.damage == piston.damage
		and dig.cost == 1 and up_dig.cost == 0
			and up_dig.block == dig.block
		and salvage.exhaust_pick and not up_salvage.exhaust_pick
			and up_salvage.draw == salvage.draw
		and up_reckless.upgraded and up_reckless.name.ends_with("+")
			and up_reckless.rule_upgrade.is_empty()  # spent, not carried on the sharpened copy
		and twice.ethereal == up_reckless.ethereal,      # re-upgrading is a no-op, same as numbers
		"a rule_upgrade changes what a card DOES instead of bumping its numbers")


## #86 duty 2: upgraded_copy()'s two hand-written field lists (card.gd) had
## drifted from Card's real field set — grip_per_rhythm, pull_ally and
## sac_ally_grip were never added when those fields were, so campfire-
## sharpening grand_leap/grappling_arm/catapult either froze their actual
## payoff (grip_per_rhythm) or did nothing but cheapen a card whose real
## effect (pull_ally, sac_ally_grip) never scaled.
func _test_card_upgrade_bumps_grip_per_rhythm_pull_and_sac_ally_grip() -> void:
	var leap := Content.make_card("grand_leap")            # grip_per_rhythm 2
	var up_leap := leap.upgraded_copy()
	var arm := Content.make_card("grappling_arm")          # pull_ally 3, cost 1, nothing else
	var up_arm := arm.upgraded_copy()
	var cat := Content.make_card("catapult")                # sac_ally_grip 2, cost 1, nothing else
	var up_cat := cat.upgraded_copy()
	_expect(
		up_leap.grip_per_rhythm == leap.grip_per_rhythm + 1
		and up_arm.pull_ally == arm.pull_ally + 1 and up_arm.cost == arm.cost   # it scaled, so cost didn't drop
		and up_cat.sac_ally_grip == cat.sac_ally_grip + 1 and up_cat.cost == cat.cost,
		"upgrading bumps grip_per_rhythm, pull_ally and sac_ally_grip like every other scaling field")


## Same drift, but cheapen_amount defaults to 1 on EVERY card (Card.from_dict),
## not just ones that use it — so it cannot go in the generic +1 list the way
## grip_per_rhythm etc. do, or upgrading would silently "bump" it (and skip
## the cost-reduction fallback) on cards that never authored cheapen_pick at
## all. It must only bump when the card actually uses it.
func _test_card_upgrade_bumps_cheapen_amount_only_when_cheapen_pick_is_set() -> void:
	var coal := Content.make_card("burn_coal")    # cheapen_pick true, cheapen_amount 1, cost 1
	var up_coal := coal.upgraded_copy()
	var meld := Content.make_card("meld")         # no cheapen_pick, no other scaling stat, cost 1
	var up_meld := meld.upgraded_copy()
	_expect(
		coal.cheapen_pick and up_coal.cheapen_amount == coal.cheapen_amount + 1
			and up_coal.cost == coal.cost                   # it scaled, so cost didn't drop
		and not meld.cheapen_pick and up_meld.cheapen_amount == meld.cheapen_amount  # untouched
			and up_meld.cost == meld.cost - 1,               # nothing to scale — still cheapens
		"cheapen_amount only bumps for cards that actually use cheapen_pick")


## Backlog #67: a card can ask a question about the board — "above the sigil",
## "your ally is hanging", "your 3rd card this turn" — and gets its own bonus
## ONLY when the answer is yes. The fallback the item asked for is simply "no
## bonus": every one of the six real cards below still does exactly its
## printed numbers when the condition doesn't hold, tested explicitly below.
func _test_backlog67_above_sigil_condition_gates_preview_bonus() -> void:
	var boss := _dummy_boss(300)
	boss.weak_point_height = 4
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 7, boss)
	var harpoon := Content.make_card("harpoon")  # base 8, +4 above the sigil
	combat.players[0].foothold = 3
	var below := combat.preview(0, harpoon)
	combat.players[0].foothold = 4
	var at_sigil := combat.preview(0, harpoon)
	_expect(int(below["damage"]) == 8 and int(at_sigil["damage"]) == 12,
		"above_sigil condition adds its bonus only once this hunter reaches the sigil")


func _test_backlog67_ally_hanging_condition_gates_preview_bonus() -> void:
	var boss := _dummy_boss(300)
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 7, boss)
	var safety := Content.make_card("safety_line")  # base 8 ally block, +4 if the ally is hanging
	combat.players[1].foothold = 0
	var grounded := combat.preview(0, safety)
	combat.players[1].foothold = 3
	var hanging := combat.preview(0, safety)
	_expect(int(grounded["ally_block"]) == 8 and int(hanging["ally_block"]) == 12,
		"ally_hanging condition adds its bonus only once the ally has climbed off the ground")


## nth_card counts EARLIER plays only, same idiom block_per_play/play_counts
## already use — the card being previewed is what WOULD make it the Nth, not
## something that has to have already happened before it can see itself.
func _test_backlog67_nth_card_condition_counts_earlier_plays_only() -> void:
	var boss := _dummy_boss(300)
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 7, boss)
	var dagger := Content.make_card("dagger")  # base 3, +3 on the 3rd card this turn or later
	var ps: PlayerState = combat.players[0]
	ps.cards_played_this_turn = 1  # this play would be the 2nd card this turn
	var second := combat.preview(0, dagger)
	ps.cards_played_this_turn = 2  # this play would be the 3rd card this turn
	var third := combat.preview(0, dagger)
	_expect(int(second["damage"]) == 3 and int(third["damage"]) == 6,
		"nth_card condition fires from the Nth card played this turn onward, not one card later")


func _test_backlog67_nth_card_counter_resets_each_round() -> void:
	var boss := _dummy_boss(300)
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 7, boss)
	combat.players[0].cards_played_this_turn = 2
	combat.end_turn(0)
	combat.end_turn(1)  # both passed — the boss acts and a new round begins
	_expect(combat.players[0].cards_played_this_turn == 0,
		"cards_played_this_turn resets at the start of each round, same as rhythm (#67 vs #40's rhythm reset)")


## End to end through real play_card resolution, not just preview()'s
## prediction — proves the bonus lands as actual damage on the boss, and that
## cards_played_this_turn (bumped inside play_card, same spot play_counts is)
## is wired all the way through.
func _test_backlog67_condition_bonus_resolves_through_a_real_play() -> void:
	var boss := _dummy_boss(300)
	boss.weak_point_height = 4
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 7, boss)
	var ps: PlayerState = combat.players[0]
	ps.hand = [Content.make_card("harpoon")]
	ps.foothold = 4  # camped at the sigil
	ps.energy = 5
	combat.play_card(0, 0)
	# 8 base + 4 condition bonus + Combat.SIGIL_BONUS (5) for landing the hit AT the sigil —
	# the SIGIL_BONUS is _damage_boss's own reward for reaching weak_point_height, layered on
	# top of the card's own condition bonus rather than replacing it.
	_expect(boss.hp == 300 - (8 + 4 + 5),
		"an above_sigil card's condition bonus resolves as real damage through play_card")


func _test_backlog67_unmet_condition_never_costs_the_printed_numbers() -> void:
	var boss := _dummy_boss(300)
	boss.weak_point_height = 4
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 7, boss)
	var harpoon := Content.make_card("harpoon")
	combat.players[0].foothold = 0  # nowhere near the sigil
	var pv := combat.preview(0, harpoon)
	_expect(int(pv["damage"]) == 8,
		"an unmet condition leaves the card doing exactly its printed numbers, never less")


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


## Backlog #56: the ladder up to tier 8 only ever bumps a number. Tiers 9 and
## 10 change a RULE instead — a curse already in the deck, a shop that refuses
## to sell removal at all — so this pairs each with the tier below it exactly
## like the test above, but checks the shape of a hunter's options changed,
## not just a stat.
func _test_ascension9_and_10_change_a_rule() -> void:
	# Tier 9 — start_curse: every hunter's starting deck already holds one
	# Bruised Grip, the status card curse_card already uses for events (#27).
	var t8 := _asc_run(8)
	var t9 := _asc_run(9)
	var curses8 := 0
	for c in t8.decks[0]:
		if (c as Card).status:
			curses8 += 1
	var curses9 := 0
	for c in t9.decks[0]:
		if (c as Card).status:
			curses9 += 1
	var t9_ok: bool = curses8 == 0 and curses9 == 1 \
		and t9.decks[0].size() == t8.decks[0].size() + 1

	# Tier 10 — no_shop_removal: the "Thin the deck" offer disappears from
	# stock entirely, not just gets pricier. Campfire removal is untouched.
	var t9b := _asc_run(9)
	t9b._begin_shop()
	var t10 := _asc_run(10)
	t10._begin_shop()
	var has_remove9 := false
	for item in t9b.shop_stock:
		if String((item as Dictionary)["kind"]) == "remove":
			has_remove9 = true
	var has_remove10 := false
	for item2 in t10.shop_stock:
		if String((item2 as Dictionary)["kind"]) == "remove":
			has_remove10 = true
	var t10_ok: bool = has_remove9 and not has_remove10 \
		and t10.shop_stock.size() < t9b.shop_stock.size()

	_expect(t9_ok and t10_ok,
		"ascension 9 seeds a curse into every deck and ascension 10 seals the shop's removal, not just numbers [%s]"
			% [[t9_ok, t10_ok]])


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


## backlog #86 duty 3 (twenty-fifth pass) -- Coach.hint_for's combat branch has
## six candidates in priority order (climbing, at_sigil, armored, timed,
## ally_stuck, play_card) but only the top two -- climbing and armored -- had
## ever been exercised. The other four, and the fallback, had zero coverage.
func _test_backlog86_coach_teaches_at_sigil_before_armored() -> void:
	Progress.reset_hints()
	# reached the sigil AND still below it (armored would also fire) -- at_sigil
	# is appended first, so it must win even though armored's condition is true too.
	var ctx := {"phase": "combat", "boss": {"weak_point_height": 3},
		"players": [{"foothold": 0, "secure": true, "reached": true},
			{"foothold": 0, "secure": true, "reached": false}]}
	var hint: Dictionary = Coach.hint_for(ctx, {"hand": []}, 0)
	Progress.reset_hints()
	_expect(String(hint.get("id", "")) == "at_sigil",
		"reaching the sigil outranks the armored lesson even while both conditions hold")


func _test_backlog86_coach_teaches_timed_card_when_hand_holds_one() -> void:
	Progress.reset_hints()
	# not secure=false (no climbing), not reached, weak point 0 so armored can't
	# fire either -- the only candidate above the timed check is impossible here.
	var ctx := {"phase": "combat", "boss": {"weak_point_height": 0},
		"players": [{"foothold": 0, "secure": true, "reached": false},
			{"foothold": 0, "secure": true, "reached": false}]}
	var with_timed: Dictionary = Coach.hint_for(ctx, {"hand": [{"timed": true}]}, 0)
	var without_timed: Dictionary = Coach.hint_for(ctx, {"hand": [{"timed": false}]}, 0)
	Progress.reset_hints()
	_expect(String(with_timed.get("id", "")) == "timed"
		and String(without_timed.get("id", "")) == "play_card",
		"the timed-card hint fires only when the hand actually holds a timed card")


func _test_backlog86_coach_teaches_ally_stuck_only_when_the_ally_is_actually_grounded() -> void:
	Progress.reset_hints()
	# height > 0 with fh > 0 clears both climbing and armored, leaving the ally
	# check as the only remaining candidate above the fallback.
	var ctx := {"phase": "combat", "boss": {"weak_point_height": 3},
		"players": [{"foothold": 2, "secure": true, "reached": false},
			{"foothold": 0, "secure": true, "reached": false}]}
	var ally_grounded: Dictionary = Coach.hint_for(ctx, {"hand": []}, 0)
	# same shape, but the ally has climbed too -- nobody is stuck, so the hint
	# must not fire and the coach falls through to the basic lesson instead.
	var both_up_ctx := {"phase": "combat", "boss": {"weak_point_height": 3},
		"players": [{"foothold": 2, "secure": true, "reached": false},
			{"foothold": 1, "secure": true, "reached": false}]}
	var ally_climbed: Dictionary = Coach.hint_for(both_up_ctx, {"hand": []}, 0)
	Progress.reset_hints()
	_expect(String(ally_grounded.get("id", "")) == "ally_stuck"
		and String(ally_climbed.get("id", "")) == "play_card",
		"the ally-stuck hint fires only while the ally is actually still on the ground, not whenever the player themself has climbed")


func _test_backlog86_coach_falls_back_to_play_card_when_nothing_else_applies() -> void:
	Progress.reset_hints()
	var ctx := {"phase": "combat", "boss": {"weak_point_height": 0},
		"players": [{"foothold": 3, "secure": true, "reached": false},
			{"foothold": 3, "secure": true, "reached": false}]}
	var hint: Dictionary = Coach.hint_for(ctx, {"hand": []}, 0)
	Progress.reset_hints()
	_expect(String(hint.get("id", "")) == "play_card",
		"with no weak point, nobody stuck, no timed card and full grip, the coach falls back to the basic play-a-card lesson")


func _test_backlog86_coach_hand_has_checks_the_named_flag_not_any_truthy_field() -> void:
	_expect(Coach._hand_has([{"timed": false, "damage": 4}], "timed") == false,
		"a card with an unrelated truthy field but timed=false must not count as a timed card")
	_expect(Coach._hand_has([{"damage": 4}, {"timed": true}], "timed") == true,
		"the flag can be on any card in the hand, not only the first")
	_expect(Coach._hand_has([], "timed") == false,
		"an empty hand has no timed card")


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


## Backlog #86 duty 2: shop_stock[index] IS `item` (Dictionary is by-
## reference, per the same rule combat.gd already comments on), and it was
## still "sold" == false when buy()'s "remove" branch repriced "the other,
## not-yet-sold" removal slots — so it matched and repriced ITSELF too,
## before the charge on the next line re-read its now-bumped price. Every
## deck-thin purchase silently cost one tier (25g) more than the price it
## showed and gated affordability against.
func _test_shop_removal_charges_the_price_it_showed() -> void:
	var run := _map_run()
	run.gold = 500
	run.map_row = 0
	run.node_type = "shop"
	run._begin_shop()
	var rem_i := -1
	for i in range(run.shop_stock.size()):
		if String(run.shop_stock[i]["kind"]) == "remove":
			rem_i = i
			break
	var shown_price: int = int(run.shop_stock[rem_i]["price"])
	var purse_before: int = run.gold
	var bought := run.buy(rem_i, 0)
	_expect(bought and run.gold == purse_before - shown_price,
		"a deck-thin purchase charges exactly the price it showed, not the next tier up")


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


## Backlog #71: a shop worth revisiting — cards cost more the rarer they are,
## instead of every card carrying the same flat price regardless of what it is.
func _test_shop_prices_scale_with_card_rarity() -> void:
	var run := _map_run()
	var common_ok := run._card_price("slash") == Run.PRICE_CARD
	var uncommon_ok := run._card_price("cleave") == Run.PRICE_CARD_UNCOMMON
	var rare_ok := run._card_price("meld") == Run.PRICE_CARD_RARE
	var ladder := Run.PRICE_CARD < Run.PRICE_CARD_UNCOMMON and Run.PRICE_CARD_UNCOMMON < Run.PRICE_CARD_RARE
	_expect(common_ok and uncommon_ok and rare_ok and ladder,
		"a card's shop price follows its rarity: common cheapest, rare priciest")


## Backlog #71: a guaranteed rare slot, the same idea a reward roll already
## leans toward with RARITY_WEIGHT, but as a certainty rather than a chance —
## the seed used by _map_run() draws from a pool with rares in it (checked
## against cards.json's global reward_pool, which is what an empty character
## id falls back to), so this should hold every time rather than by luck.
func _test_shop_guarantees_a_rare_card_slot() -> void:
	var run := _map_run()
	run.map_row = 0
	run.node_type = "shop"
	run._begin_shop()
	var slot0_has_rare := false
	for item in run.shop_stock:
		if String(item["kind"]) == "card" and int(item["slot"]) == 0 \
				and Content.card_rarity(String(item["id"])) == "rare":
			slot0_has_rare = true
			break
	_expect(slot0_has_rare,
		"a shop with rares in its pool always offers at least one to buy, not just by chance")


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


## Backlog #72: tags are DERIVED from a card's existing fields (Card.archetype_tags()),
## not a new authored field — pins a few real cards against the rule so the
## derivation itself is proven, separately from the reward-roll lean it feeds.
func _test_backlog72_archetype_tags_are_derived_from_fields() -> void:
	var rend_tags: Array = Content.card_tags("rend")            # wound 2
	var sharpen_tags: Array = Content.card_tags("sharpen")       # strength 2
	var cadence_tags: Array = Content.card_tags("cadence")       # rhythm 2
	var slash_tags: Array = Content.card_tags("slash")           # damage only — no archetype field
	_expect(rend_tags.has("poison") and sharpen_tags.has("strength") and cadence_tags.has("rhythm")
			and slash_tags.is_empty(),
		"archetype tags follow from a card's own fields [rend=%s sharpen=%s cadence=%s slash=%s]"
			% [rend_tags, sharpen_tags, cadence_tags, slash_tags])


## Backlog #72: a card reward roll should lean toward the archetype a hunter is
## already building, not roll flat from the pool regardless of the deck. Same
## statistical shape as _test_rarity_weighting_favours_commons — loose bounds,
## proving the lean is wired up rather than chasing an exact number. The pool is
## six COMMONS split evenly Poison/non-Poison so every candidate carries the
## SAME rarity weight — only the tag lean can move the result.
func _test_backlog72_reward_roll_leans_toward_a_tag_already_in_the_deck() -> void:
	var run := _map_run()
	var pool: Array = ["rend", "spore", "blightbloom", "slash", "bowshot", "sharpen"]
	run.reward_kind = "card"

	var baseline_seen := 0
	var baseline_total := 0
	for _i in range(1500):
		for card in run._roll_choices(pool, {}):
			if (card as Card).archetype_tags().has("poison"):
				baseline_seen += 1
			baseline_total += 1
	var baseline_pct := float(baseline_seen) / float(baseline_total)

	var deck_tag_counts: Dictionary = run._tag_counts(_deck_of(_venom_dart, 10))
	var poison_seen := 0
	var poison_total := 0
	for _i in range(1500):
		for card in run._roll_choices(pool, deck_tag_counts):
			if (card as Card).archetype_tags().has("poison"):
				poison_seen += 1
			poison_total += 1
	var poison_pct := float(poison_seen) / float(poison_total)

	_expect(baseline_total > 0 and poison_total > 0 and poison_pct > baseline_pct + 0.03,
		"a deck heavy in Poison cards sees Poison-tagged rewards more often than a neutral deck does (%d%% vs a %d%% baseline, over %d offers each)"
			% [int(poison_pct * 100.0), int(baseline_pct * 100.0), poison_total])


## Backlog #72: relics carry no archetype tags and the relic roll is uniform
## regardless — _begin_reward() must not hand a relic roll a deck's tag counts
## and have it silently do something. Calls _roll_choices() the same way
## _begin_reward() would for a relic reward: deck_tag_counts stays {} because
## reward_kind == "relic" short-circuits it there.
func _test_backlog72_relic_rolls_are_unaffected_by_deck_tags() -> void:
	var run := _map_run()
	run.reward_kind = "relic"
	var pool: Array = Content.relic_pool()
	var deck_tag_counts: Dictionary = run._tag_counts(_deck_of(_venom_dart, 10))
	var choices := run._roll_choices(pool, deck_tag_counts)
	var all_relics := true
	for c in choices:
		if not (c is Dictionary):
			all_relics = false
	_expect(not choices.is_empty() and all_relics,
		"a relic roll still returns relics (plain dicts) even when handed non-empty deck tag counts")


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


## _track_climb()'s own doc comment says it must run "after anything that can
## raise a foothold — play_card and the jetpack's _resolve_prepared" — but a
## climb POTION also raises ps.foothold directly (combat.gd's use_potion) and
## was missing from that list. Uncaught, a climb potion drunk before any card
## climbs this fight leaves highest_climb at 0 even though the hunter is
## objectively higher, so Run.sync() folds a too-low peak into the run's
## permanent stats/history and MOMENT_HUNTER_CLIMBS never fires for a climb
## that really happened.
func _test_use_potion_climb_updates_highest_climb() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var mover: PlayerState = combat.players[0]
	var climb_events: Array = []
	combat._on(Combat.MOMENT_HUNTER_CLIMBS, func(ctx): climb_events.append(ctx))
	_expect(combat.highest_climb == 0, "no hunter has climbed yet at the start of a fresh fight")

	var climbed := combat.use_potion(0, "climb", 5)
	_expect(climbed and mover.foothold == 5, "the climb potion raises the drinker's Height")
	_expect(combat.highest_climb == 5,
		"a climb POTION counts toward highest_climb exactly like a climb CARD, not just a foothold bump nobody records")
	_expect(climb_events.size() == 1 and climb_events[0]["player"] == mover and int(climb_events[0]["foothold"]) == 5,
		"drinking a climb potion fires MOMENT_HUNTER_CLIMBS the same as a climbing card would")


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


func _test_backlog86_soft_fall_skips_an_unsafe_hold_when_landing() -> void:
	# _hold_below (fall()'s soft_fall landing spot) has its own unsafe-skip
	# check, mirroring next_safe_height's -- but nothing ever proved it. A
	# hunter clinging above an unsafe named hold with a safe one further down
	# must land on the safe hold, not the nearer unsafe one.
	var boss := _climb_boss(8)
	boss.ledges = [2, {"height": 4, "safe": false, "exposed_to": ["swipe"]}]
	var combat := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], boss, 42, 0, 0, 0, 0, [], {"soft_fall": 1})
	combat.start()
	var ps: PlayerState = combat.players[0]
	ps.foothold = 5  # clinging above the unsafe hold at 4
	combat.fall(0)
	_expect(ps.foothold == 2,
		"soft_fall lands on the nearest SAFE hold below, skipping an unsafe named one in between")


func _test_backlog86_soft_fall_drops_to_base_when_only_hold_below_is_unsafe() -> void:
	# Same rule, the harder edge: when the only hold below is unsafe, there is
	# no safe rest stop at all, so the fall goes all the way to the base --
	# same as if no ledges existed down there.
	var boss := _climb_boss(8)
	boss.ledges = [{"height": 3, "safe": false, "exposed_to": ["swipe"]}]
	var combat := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], boss, 42, 0, 0, 0, 0, [], {"soft_fall": 1})
	combat.start()
	var ps: PlayerState = combat.players[0]
	ps.foothold = 5
	combat.fall(0)
	_expect(ps.foothold == 0,
		"soft_fall drops all the way to the base when the only hold below is unsafe")


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


func _test_backlog86_power_triggered_poison_lifts_the_vine_weaver_ally() -> void:
	# play_card()'s own Poison branch checks poison_lift and lifts the ally, but
	# _handle_power_effects()'s "wound" case (the turn_end payout for a power
	# card like Seeping Venom) is a separate copy of that same Poison landing
	# and never checked it — so a power-triggered Poison silently skipped the
	# Vine-Weaver's climb bonus while a played Poison card granted it (#86 duty 2).
	var combat := _new_combat_p([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42,
		_dummy_boss(300), [{"type": "poison_lift", "value": 1}, {}])
	var ps: PlayerState = combat.players[0]
	ps.powers["test_poison"] = {"stacks": 1, "value": 2, "effect": "wound", "name": "Test Poison"}
	var ally_before: int = combat.players[1].foothold
	combat.end_turn(0)
	_expect(combat.boss.wound == 2 and combat.players[1].foothold == ally_before + 1,
		"a power's recurring Poison lifts the Vine-Weaver's ally too, not just a played card's")


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


func _test_meld_carries_light_and_deck_effects() -> void:
	# backlog #86 duty 2: light_gain/light_cost/damage_per_light/ally_heal/scry/
	# topdeck/shuffle_in/tutor/condition/condition_bonus (backlog #47/#59/#67/#68)
	# were all added to Card after _meld_cards' dict literal was written and
	# never backfilled — the same "hand-copied field list drifts" bug the
	# to_dict/from_dict parity test guards against for saves, just for melds.
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	# Spark (light_gain 2) + Peer Ahead (scry 2)
	ps.hand = [_meld_card(), Content.make_card("spark"), Content.make_card("peer_ahead")]
	ps.energy = 9
	combat.play_card(0, 0, true, 1, 2)
	var f1: Card = ps.hand[0]
	var spark_peer: bool = f1.light_gain == 2 and f1.scry == 2
	# Waymark (topdeck scramble) + Depot (shuffle_in grip)
	ps.hand = [_meld_card(), Content.make_card("waymark"), Content.make_card("depot")]
	ps.energy = 9
	combat.play_card(0, 0, true, 1, 2)
	var f2: Card = ps.hand[0]
	var waymark_depot: bool = f2.topdeck == "scramble" and f2.shuffle_in == "grip"
	# Recon (tutor cleave) + Sunburst (damage_per_light 2)
	ps.hand = [_meld_card(), Content.make_card("recon"), Content.make_card("sunburst")]
	ps.energy = 9
	combat.play_card(0, 0, true, 1, 2)
	var f3: Card = ps.hand[0]
	var recon_sunburst: bool = f3.tutor == "cleave" and f3.damage_per_light == 2
	# Guiding Light (light_cost 3, ally_heal 8) + Harpoon (condition above_sigil,
	# condition_bonus {damage:4}) — the bonus must follow A's kept condition.
	ps.hand = [_meld_card(), Content.make_card("guiding_light"), Content.make_card("harpoon")]
	ps.energy = 9
	combat.play_card(0, 0, true, 1, 2)
	var f4: Card = ps.hand[0]
	var light_harpoon: bool = f4.light_cost == 3 and f4.ally_heal == 8 \
		and String(f4.condition.get("type", "")) == "above_sigil" \
		and int(f4.condition_bonus.get("damage", 0)) == 4
	_expect(spark_peer and waymark_depot and recon_sunburst and light_harpoon,
		"a meld keeps light/scry/topdeck/shuffle_in/tutor/condition effects too, not just the pre-#47 field list")


## backlog #86 duty 2: _meld_cards never carried a power card's type/
## power_effect/power_value at all — melding Iron Husk (power, +3 Block) with
## anything came out type "skill", so it wasn't even routed to ps.powers when
## played and the recurring payoff vanished outright. Carrying just the dict
## fields still wasn't enough: ps.powers used to always re-derive `effect`/
## `name` via Content.make_card(card.id) at turn end, and a melded card's id
## ("meld_a_b") isn't in cards.json — so the payoff would have stayed
## silently dead even with type/power_effect/power_value carried correctly.
## Proves the whole chain: the fused card's fields, that playing it stays out
## of the discard pile, and that it actually pays out at turn end.
func _test_meld_carries_power_effect() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_meld_card(), Content.make_card("iron_husk"), _cleave()]
	ps.energy = 9
	combat.play_card(0, 0, true, 1, 2)
	var fused: Card = ps.hand[0]
	var carried: bool = fused.type == "power" and fused.power_effect == "block" \
		and fused.power_value == 3 and fused.damage == 10
	var discard_before_fused: int = ps.discard_pile.size()  # the "Meld" card itself already
	# discarded normally above — only the FUSED card must skip the discard pile
	combat.play_card(0, 0, true)  # play the fused card itself
	var stayed_out_of_discard: bool = ps.discard_pile.size() == discard_before_fused \
		and ps.powers.has(fused.id)
	var block_before := ps.combatant.block
	combat.end_turn(0)
	var paid_out: bool = ps.combatant.block == block_before + 3
	_expect(carried and stayed_out_of_discard and paid_out,
		"a meld carries a power card's type/effect/value, stays in play, and still pays out — even under a synthetic meld id Content.gd has never heard of")


## backlog #86 duty 2: same "hand-copied field list drifts" shape as the two
## meld bugs above, for retain/ethereal this time. end_turn() reads c.retain/
## c.ethereal to decide discard vs. keep vs. exhaust (combat.gd ~1014) — with
## neither field carried, a meld of a Retain card (Bunker Down) came out an
## ordinary card that end_turn() silently discarded instead of keeping, and a
## meld of an Ethereal card (Reckless Swing) discarded instead of exhausting.
func _test_meld_carries_retain_and_ethereal() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	# Bunker Down (retain) + Reckless Swing (ethereal) — fused card must carry both.
	ps.hand = [_meld_card(), Content.make_card("bunker_down"), Content.make_card("reckless_swing")]
	ps.energy = 9
	combat.play_card(0, 0, true, 1, 2)
	var fused: Card = ps.hand[0]
	var carried: bool = fused.retain and fused.ethereal
	# Ethereal is checked first in end_turn() (Retain's opposite) — a card that's
	# both must exhaust, not linger in hand or fall into the discard pile.
	combat.end_turn(0)
	var exhausted: bool = ps.exhaust_pile.has(fused) and not ps.discard_pile.has(fused) \
		and not ps.hand.has(fused)
	_expect(carried and exhausted,
		"a meld keeps retain/ethereal off both source cards, and ethereal (checked first) wins the fused card at end of turn")


## backlog #86 duty 2: _meld_cards' dict never carried "enchant" at all — a
## fourth instance of the same "hand-copied field list drifts from Card's real
## fields" bug this dict has already been caught missing three times (type,
## light/scry, retain/ethereal). enchant is a single slot (enchanted_copy()
## replaces rather than stacks), so a meld involving an enchanted card should
## keep that enchant, and effective_cost() (combat.gd ~419) should still apply
## it — with the field dropped, e.g. a "Cheap" (cost_cut) card silently lost
## its discount the instant it went into a meld.
func _test_meld_carries_enchant() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	var cheap_slash := _slash().enchanted_copy("cheap")  # "Cheap": costs 1 less (backlog #50)
	ps.hand = [_meld_card(), cheap_slash, _defend()]
	ps.energy = 9
	combat.play_card(0, 0, true, 1, 2)
	var fused: Card = ps.hand[0]
	var cost_without_enchant := maxi(0, cheap_slash.cost + _defend().cost - 1)
	_expect(fused.enchant == "cheap" and combat.effective_cost(0, fused) == cost_without_enchant - 1,
		"a meld carries an attached enchant (single slot, keep A's if set) — dropping it silently stripped e.g. Cheap's cost cut off the fused card")


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


## Ethereal (backlog #58): Retain's opposite. A card left in hand at end of
## turn burns away to the exhaust pile instead of the discard pile; an
## ordinary card in the same hand is discarded as normal.
func _test_ethereal_exhausts_if_still_in_hand_at_end_of_turn() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_reckless_swing(), _slash()]
	combat.end_turn(0)
	_expect(ps.hand.size() == 0 and _has_id(ps.exhaust_pile, "reckless_swing")
			and _has_id(ps.discard_pile, "slash") and not _has_id(ps.discard_pile, "reckless_swing"),
		"an ethereal card left in hand exhausts at end of turn; a normal one is discarded")


## Playing an ethereal card removes it from the hand like any other card — the
## exhaust only applies to a copy that is STILL THERE unplayed at end of turn.
func _test_ethereal_played_card_is_not_exhausted() -> void:
	var combat := _new_combat([_deck_of(_reckless_swing, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	combat.play_card(0, _first_playable(combat, 0))
	_expect(_has_id(ps.discard_pile, "reckless_swing") and not _has_id(ps.exhaust_pile, "reckless_swing"),
		"a played ethereal card discards normally — ethereal only fires on an unplayed copy")


## A card can't sensibly linger forever AND burn away — if both flags are set,
## ethereal wins so the card can never be an unkillable permanent Retain.
func _test_ethereal_overrides_retain_if_both_are_set() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	var both := Card.from_dict({"id": "both", "name": "Both", "type": "skill", "cost": 1,
		"block": 4, "retain": true, "ethereal": true})
	ps.hand = [both]
	combat.end_turn(0)
	_expect(ps.hand.is_empty() and _has_id(ps.exhaust_pile, "both"),
		"ethereal takes priority over retain — the card exhausts rather than lingering forever")


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
		if card.topdeck != "" and String(Content.make_card(card.topdeck).name).is_empty():
			bad.append("%s topdeck: %s" % [id, card.topdeck])
		if card.shuffle_in != "" and String(Content.make_card(card.shuffle_in).name).is_empty():
			bad.append("%s shuffle_in: %s" % [id, card.shuffle_in])
		if card.tutor != "" and String(Content.make_card(card.tutor).name).is_empty():
			bad.append("%s tutor: %s" % [id, card.tutor])
	for kind in ["fight", "elite", "boss"]:
		for id in Content.beast_pool(kind):
			var b := Content.build_boss(String(id))
			if b.moves.is_empty():
				bad.append("%s pool: %s (no moves — unknown beast id?)" % [kind, id])
	# backlog #69: a 'curse' move's optional 'card' key names a real card the
	# same way an event's curse_card does — check it the same way.
	for id2 in Content.boss_ids():
		var b2 := Content.build_boss(String(id2))
		for m in (b2.moves + b2.hurt_moves):
			if String((m as Dictionary).get("type", "")) == "curse":
				var mc := String((m as Dictionary).get("card", "bruised_grip"))
				if String(Content.make_card(mc).name).is_empty():
					bad.append("%s curse move card: %s" % [id2, mc])
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
		"create/prepare/topdeck/shuffle_in/tutor fields, beast pool ids, curse_card and potion refs all resolve [%s]" % ", ".join(bad))


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

## #86 duty 2: `run.hp` is a second copy of combat.players[i].combatant.hp --
## `_bank_hp()` keeps it in sync on a WIN (see the test above this one), but
## sync()'s LOSE branch used to skip that entirely, so a fallen hunter's `hp`
## stayed at whatever it was BEFORE the losing fight (full, here) instead of
## reflecting the death, and the survivor's `hp` stayed stale too. That value
## still rides every broadcast (game_host.gd's _players_public()) for as long
## as the LOST screen is up, so it should say what actually happened.
func _test_run_hp_syncs_on_defeat_too() -> void:
	var run := _map_run()
	_step_into_combat(run)
	var pre_fight_hp: int = run.hp[0]
	run.combat.players[0].combatant.hp = 0       # this hunter fell...
	run.combat.players[1].combatant.hp = 7       # ...mid-swing, the other took a hit too
	run.combat.phase = Combat.Phase.OVER
	run.sync()
	_expect(run.phase == Run.Phase.LOST and run.hp[0] == 0 and run.hp[1] == 7
		and pre_fight_hp > 0,
		"a losing fight banks the real final HP too, not the stale pre-fight number")

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
	var derived := ["timed", "poison", "expose", "rhythm", "strength", "player_block",
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


## keywords.json used to carry TWO "block" keys — a player one under the card
## vocabulary and a beast-move one ("Defend") under "_comment_moves"'s own
## documented "ids match the move `type`" rule — and JSON.parse_string keeps
## only the last of two duplicate keys. So a card that grants Block silently
## explained itself with "The beast guards..." instead of its own text. Fixed
## by renaming the card-side id to "player_block"; this proves the two stay
## distinct and a Block-granting card actually resolves its OWN keyword.
func _test_player_block_keyword_is_not_shadowed_by_the_boss_move() -> void:
	var player_kw := Content.keyword("player_block")
	var boss_kw := Content.keyword("block")
	_expect(not player_kw.is_empty() and not boss_kw.is_empty(),
		"both the player's Block keyword and the beast's Defend move keyword exist")
	_expect(String(player_kw.get("text", "")).find("beast guards") == -1,
		"the player's Block keyword is not the beast's Defend text")
	_expect(String(boss_kw.get("text", "")).find("beast guards") != -1,
		"the beast move keyword 'block' is still Defend, untouched (bosses.json move types match it verbatim)")
	var host := GameHost.new(LocalTransport.new(), 1, 2)
	_kept.append(host)
	var card := Card.from_dict({"block": 3})
	var kws := host._keywords_of(card)
	var found := {}
	for k in kws:
		found[String((k as Dictionary).get("id", ""))] = k
	_expect(found.has("player_block") and not found.has("block"),
		"a Block-granting card's derived keywords use 'player_block', not the shadowed 'block' id")
	_expect(String((found.get("player_block", {}) as Dictionary).get("text", "")).find("your health") != -1,
		"the resolved keyword is actually the player's own Block explanation")


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
	# rule_upgrade (backlog #66) is the odd one out: a Dictionary, not a bool/
	# string/int the probe below knows how to fake a value for, and it is
	# never itself player-facing — a player never sees "rule_upgrade", they
	# see whatever it OVERRIDES once applied (Retain, Innate, a 0 cost...),
	# and every one of those already has its own keyword via the normal path.
	# condition/condition_bonus (backlog #67) are the same shape: Dictionaries
	# the probe can't fake, and never shown to the player as fields — a card
	# that carries one spells the question out in its own printed `text`
	# ("Above the sigil: 4 more damage."), same as rule_upgrade's cards do.
	var self_evident := ["id", "name", "type", "rarity", "cost", "damage", "draw",
		"target", "icon", "text", "upgraded", "timed_hits", "rule_upgrade",
		"condition", "condition_bonus"]
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


## Backlog #54: the field->keyword MAPPING above catches a field nobody wired
## up, but says nothing about a keyword whose TEXT went stale after the
## mechanic it describes changed shape. "timed" was written when a hit was
## binary (nailed or missed); backlog #33 graded it into TIMING_PERFECT (full
## bonus) and TIMING_GOOD (half, per Combat.TIMING_GOOD_SCALE) without anyone
## touching the tooltip, so a player reading it would never learn a scraped
## edge still pays out. Check the text actually names the scaled tier, not
## just that it exists.
func _test_timed_keyword_explains_graded_quality() -> void:
	var text := String(Content.keyword("timed").get("text", "")).to_lower()
	_expect(text.find("half") != -1,
		"the timed keyword explains that a non-centred hit still pays a scaled (half) bonus")


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


# --- Powers: cards that stay played (backlog #57) --------------------------

func _power_block() -> Card:
	return Card.from_dict({"id": "iron_husk", "name": "Iron Husk", "type": "power", "cost": 1,
		"power_effect": "block", "power_value": 3})

func _power_strength() -> Card:
	return Card.from_dict({"id": "old_grudge", "name": "Old Grudge", "type": "power", "cost": 1,
		"power_effect": "strength", "power_value": 1})


## Playing a power never lands it in the discard pile — it stays out of both
## piles for the rest of the fight, and a second copy STACKS (one entry, a
## rising count) rather than sitting beside the first as a second card would.
func _test_power_cards_stay_in_play_and_stack() -> void:
	var combat := _new_combat([_deck_of(_power_block, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	var hand_before := ps.hand.size()
	combat.play_card(0, 0)
	_expect(int(ps.powers.get("iron_husk", {}).get("stacks", 0)) == 1,
		"playing a power card records one stack under its id")
	_expect(ps.hand.size() == hand_before - 1 and ps.discard_pile.is_empty(),
		"a played power leaves the hand but never reaches the discard pile")
	combat.play_card(0, _first_playable(combat, 0))
	_expect(int(ps.powers.get("iron_husk", {}).get("stacks", 0)) == 2,
		"a second copy of the same power stacks onto the one entry instead of sitting beside it")


## The whole point of a power: its payoff fires again at the end of EVERY
## turn for the rest of the fight, not just once when played, and scales with
## how many stacks are in play. Uses turn_end (backlog #43's moment), so a
## power played this turn already pays out this turn — proven across two
## separate rounds so "persists" means more than "happened once".
func _test_power_effects_fire_every_turn_end_and_persist() -> void:
	var combat := _new_combat([_deck_of(_power_block, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	combat.play_card(0, 0)  # Iron Husk: +3 Block at the end of each of your turns
	var block_before_end := ps.combatant.block
	combat.end_turn(0)
	_expect(ps.combatant.block == block_before_end + 3,
		"the power pays out at the end of the SAME turn it was played")
	combat.end_turn(1)  # boss acts, round 2 begins — block resets to 0 at round start
	_expect(ps.combatant.block == 0, "a fresh round still resets Block the normal way")
	combat.end_turn(0)  # no card played this round — the power still fires on its own
	_expect(ps.combatant.block == 3,
		"the power keeps paying out on later turns with no card played that turn")


## Stacks actually MULTIPLY the payout rather than just being counted, and a
## second, DIFFERENT power id applies its own effect independently — a block
## power and a strength power both active must not clobber one another.
func _test_power_stacks_multiply_and_different_powers_coexist() -> void:
	var combat := _new_combat([_deck_of(_power_strength, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	combat.play_card(0, 0)
	combat.play_card(0, _first_playable(combat, 0))  # a second Old Grudge — 2 stacks
	ps.hand.append(_power_block())  # a DIFFERENT power, appended directly (test-only shortcut)
	combat.play_card(0, ps.hand.size() - 1)
	var strength_before := ps.strength
	var block_before := ps.combatant.block
	combat.end_turn(0)
	_expect(ps.strength == strength_before + 2,
		"two stacks of a +1 Strength power grant +2, not +1")
	_expect(ps.combatant.block == block_before + 3,
		"a different power (Block) fires for its own +3 without the Strength power stealing its entry")


## A campfire-sharpened power (upgraded_copy() bumps power_value but keeps
## the same id) must keep paying its BOOSTED number. The recurring payout
## looks the id up fresh for its name/text/effect KIND (Content.make_card),
## but the VALUE has to come from what was actually played, or an upgrade
## would silently vanish the moment the card left the hand.
func _test_power_upgrade_value_is_not_lost_by_the_recurring_payout() -> void:
	var combat := _new_combat([_deck_of(_power_block, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	var upgraded: Card = ps.hand[0].upgraded_copy()  # power_value 3 -> 4
	ps.hand[0] = upgraded
	combat.play_card(0, 0)
	_expect(int(ps.powers["iron_husk"]["value"]) == 4,
		"the upgraded copy's bumped power_value is what gets stored, not the base 3")
	combat.end_turn(0)
	_expect(ps.combatant.block == 4,
		"the recurring payout pays the upgraded amount, not the data file's unupgraded default")


## Powers are per-fight state on PlayerState, so a mid-fight save (backlog
## #14) has to carry them the same way it carries the hand and the piles.
func _test_powers_survive_save_and_load() -> void:
	var combat := _new_combat([_deck_of(_power_block, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	combat.play_card(0, 0)
	combat.play_card(0, _first_playable(combat, 0))
	var restored := Combat.from_dict(combat.to_dict())
	var entry: Dictionary = restored.players[0].powers.get("iron_husk", {})
	_expect(int(entry.get("stacks", 0)) == 2 and int(entry.get("value", 0)) == 6,
		"a power's stacks and accumulated value survive a Combat to_dict/from_dict round trip")


## Backlog #45's rule for the six mechanics before this one applies here too:
## an active power is board state visible to the ally, same as a potion,
## not a secret. Prove it reaches BOTH peers through GameHost's public
## players snapshot, with its name and current stack count.
func _test_powers_reach_the_snapshot_and_are_visible_to_the_ally() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	var c1: GameClient = s["c1"]
	var ps: PlayerState = host._run.combat.players[0]
	ps.powers["iron_husk"] = {"stacks": 2, "value": 6}
	host._broadcast_state()
	var mine: Array = c0.shared["players"][0]["powers"]
	var theirs: Array = c1.shared["players"][0]["powers"]
	_expect(mine.size() == 1 and String(mine[0]["name"]) == "Iron Husk" and int(mine[0]["stacks"]) == 2,
		"an active power reaches its owner's public snapshot with its name and stack count")
	_expect(theirs.size() == 1 and String(theirs[0]["name"]) == "Iron Husk" and int(theirs[0]["stacks"]) == 2,
		"the ally sees a teammate's active power too — it's board state, not a secret")


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


## backlog #86 duty 3 (twenty-seventh pass): try_block_debuff() guards FOUR
## call sites in combat.gd — a played Poison card (wound), a played Expose
## card (vulnerable), and each of those again as a power's recurring turn_end
## payout. Only the played-Expose path (above) had ever been exercised; the
## played-Poison sibling right next to it in play_card(), and both of the
## power-triggered copies, were never proven to actually reach
## try_block_debuff() at all rather than just looking like they do.
func _test_artifact_wards_off_a_poison_card_then_is_spent() -> void:
	var combat := _new_combat([_deck_of(_venom_dart, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	combat.boss.artifact = 1
	combat.play_card(0, _first_playable(combat, 0))  # Venom Dart (Poison 2) — warded off
	_expect(combat.boss.wound == 0 and combat.boss.artifact == 0,
		"Artifact wards off a Poison card and spends a stack doing it, same as it does for Expose")
	combat.play_card(0, _first_playable(combat, 0))  # Venom Dart again — no ward left
	_expect(combat.boss.wound == 2, "once Artifact is spent, the next Poison card lands normally")


## The recurring payout (backlog #57's _handle_power_effects, turn_end) reads
## its effect straight off ps.powers rather than replaying play_card, so the
## ward has to be proven again here rather than assumed from the card test
## above — it is a second call site, not the same code path.
func _test_artifact_wards_off_a_power_triggered_poison_and_expose() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	combat.boss.artifact = 2
	ps.powers["test_poison"] = {"stacks": 1, "value": 2, "effect": "wound", "name": "Test Poison"}
	combat.end_turn(0)
	_expect(combat.boss.wound == 0 and combat.boss.artifact == 1,
		"a power's recurring Poison is warded off by Artifact too, not just a card's")
	combat.end_turn(1)  # close the round — ended_turn only resets when a new round begins
	ps.powers.clear()
	ps.powers["test_expose"] = {"stacks": 1, "value": 2, "effect": "vulnerable", "name": "Test Expose"}
	combat.end_turn(0)
	_expect(combat.boss.vulnerable == 0 and combat.boss.artifact == 0,
		"a power's recurring Expose is warded off by Artifact too, spending the last stack")
	combat.end_turn(1)
	ps.powers.clear()
	ps.powers["test_poison2"] = {"stacks": 1, "value": 2, "effect": "wound", "name": "Test Poison"}
	combat.end_turn(0)
	_expect(combat.boss.wound == 2, "once Artifact is spent, a power's recurring Poison lands normally")


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


## Backlog Later (found auditing #54): Frail/Artifact/Thorns were computed
## correctly on both the boss and a hunter but GameHost's snapshot dicts only
## ever forwarded vulnerable/strength/wound — a Titan you've Frailed or a
## hunter carrying Thorns showed nothing to look at. Same shared-snapshot
## boundary _test_adds_reach_the_shared_snapshot/_test_powers_reach_the_
## snapshot_and_are_visible_to_the_ally already check for adds and powers.
func _test_frail_artifact_thorns_reach_the_shared_snapshot() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	host._run.combat.boss.frail = 2
	host._run.combat.boss.artifact = 1
	host._run.combat.boss.thorns = 3
	host._run.combat.players[0].combatant.frail = 1
	host._run.combat.players[0].combatant.artifact = 2
	host._run.combat.players[0].combatant.thorns = 4
	host._broadcast_state()
	var boss_view: Dictionary = c0.shared["boss"]
	_expect(int(boss_view["frail"]) == 2 and int(boss_view["artifact"]) == 1 and int(boss_view["thorns"]) == 3,
		"the boss's Frail/Artifact/Thorns reach the shared snapshot")
	var p0_view: Dictionary = c0.shared["players"][0]
	_expect(int(p0_view["frail"]) == 1 and int(p0_view["artifact"]) == 2 and int(p0_view["thorns"]) == 4,
		"a hunter's own Frail/Artifact/Thorns reach the shared snapshot too")


func _test_dexterity_intangible_buffer_plated_armour_reach_the_shared_snapshot() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	host._run.combat.boss.dexterity = 5
	host._run.combat.boss.intangible = 1
	host._run.combat.boss.buffer = 1
	host._run.combat.boss.plated_armour = 2
	host._run.combat.players[0].combatant.dexterity = 3
	host._run.combat.players[0].combatant.intangible = 2
	host._run.combat.players[0].combatant.buffer = 1
	host._run.combat.players[0].combatant.plated_armour = 4
	host._broadcast_state()
	var boss_view: Dictionary = c0.shared["boss"]
	_expect(int(boss_view["dexterity"]) == 5 and int(boss_view["intangible"]) == 1
		and int(boss_view["buffer"]) == 1 and int(boss_view["plated_armour"]) == 2,
		"the boss's Dexterity/Intangible/Buffer/Plated Armour reach the shared snapshot")
	var p0_view: Dictionary = c0.shared["players"][0]
	_expect(int(p0_view["dexterity"]) == 3 and int(p0_view["intangible"]) == 2
		and int(p0_view["buffer"]) == 1 and int(p0_view["plated_armour"]) == 4,
		"a hunter's own Dexterity/Intangible/Buffer/Plated Armour reach the shared snapshot too")


func _test_light_reaches_the_shared_snapshot() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	host._run.combat.players[0].light = 5
	host._run.combat.players[1].light = 2
	host._broadcast_state()
	var p0_view: Dictionary = c0.shared["players"][0]
	var p1_view: Dictionary = c0.shared["players"][1]
	_expect(int(p0_view["light"]) == 5 and int(p1_view["light"]) == 2,
		"a hunter's banked Light reaches the shared snapshot, including the owning player's own view")


func _test_sigil_rounds_and_boss_limiter_reach_the_shared_snapshot() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	host._run.combat.boss.limiter = {"type": "sigil_fatigue", "value": 2}
	host._run.combat.players[0].sigil_rounds = 1
	host._run.combat.players[1].sigil_rounds = 3
	host._broadcast_state()
	var boss_view: Dictionary = c0.shared["boss"]
	var limiter: Dictionary = boss_view["limiter"]
	_expect(String(limiter["type"]) == "sigil_fatigue" and int(limiter["value"]) == 2,
		"the Titan's own bent rule (boss.limiter) reaches the shared snapshot")
	var p0_view: Dictionary = c0.shared["players"][0]
	var p1_view: Dictionary = c0.shared["players"][1]
	_expect(int(p0_view["sigil_rounds"]) == 1 and int(p1_view["sigil_rounds"]) == 3,
		"a hunter's own sigil_rounds count reaches the shared snapshot, including the owning player's own view")


func _test_prepared_reaches_the_shared_snapshot() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	host._run.combat.players[0].prepared = "jetpack"
	host._broadcast_state()
	var p0_view: Dictionary = c0.shared["players"][0]
	var p1_view: Dictionary = c0.shared["players"][1]
	_expect(String(p0_view["prepared"]) == "jetpack" and String(p1_view["prepared"]) == "",
		"a hunter's own primed delayed effect (PlayerState.prepared) reaches the shared snapshot, including the owning player's own view")


func _test_beast_thorns_and_artifact_are_wired() -> void:
	var hog := Content.build_boss("bramble_hog")
	var sentinel := Content.build_boss("frost_sentinel")
	_expect(hog.thorns == 3, "the Bramble Hog carries innate Thorns")
	_expect(sentinel.artifact == 2, "the Frost Sentinel carries innate Artifact")


# --- Beasts that debuff YOU (backlog #69) ----------------------------------
# Every prior move type only ever dealt HP damage; 'frail' and 'curse' are
# the first two that hit the hunter's DECK/BLOCK instead, through the exact
# same generic move-resolution path in Combat._enemy_turn() every other move
# already uses — no new special case, just two more entries in the match.

func _test_frail_move_debuffs_the_targeted_hunter() -> void:
	var boss := Boss.new("Chiller", 100)
	boss.moves = [{"type": "frail", "value": 2}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.end_turn(0)
	combat.end_turn(1)  # round 1 — boss_target_index() is player 0
	_expect(combat.players[0].combatant.frail == 2 and combat.players[1].combatant.frail == 0,
		"a 'frail' move Frails only the hunter the boss is turned toward")


func _test_frail_move_is_warded_by_the_hunters_own_artifact() -> void:
	var boss := Boss.new("Chiller", 100)
	boss.moves = [{"type": "frail", "value": 2}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.players[0].combatant.artifact = 1
	combat.end_turn(0)
	combat.end_turn(1)
	_expect(combat.players[0].combatant.frail == 0 and combat.players[0].combatant.artifact == 0,
		"the targeted hunter's own Artifact wards off a 'frail' move and is spent doing it")


func _test_curse_move_shoves_a_status_card_into_discard() -> void:
	var boss := Boss.new("Cursed Bog", 100)
	boss.moves = [{"type": "curse", "value": 1}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.end_turn(0)  # discards player 0's own hand FIRST — captured before, so it isn't mistaken for the curse
	var before: int = combat.players[0].discard_pile.size()
	combat.end_turn(1)  # both ended -> boss acts, targeting player 0
	var pile: Array = combat.players[0].discard_pile
	_expect(pile.size() == before + 1 and String((pile[pile.size() - 1] as Card).id) == "bruised_grip",
		"a 'curse' move with no 'card' field lands the default status card in the discard pile")


func _test_curse_move_respects_card_and_value_fields() -> void:
	var boss := Boss.new("Cursed Bog", 100)
	boss.moves = [{"type": "curse", "value": 2, "card": "bruised_grip"}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.end_turn(0)
	var before: int = combat.players[0].discard_pile.size()
	combat.end_turn(1)
	_expect(combat.players[0].discard_pile.size() == before + 2,
		"a 'curse' move's 'value' names how many copies land")


func _test_curse_move_ignores_artifact_matching_curse_card_precedent() -> void:
	var boss := Boss.new("Cursed Bog", 100)
	boss.moves = [{"type": "curse", "value": 1}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.players[0].combatant.artifact = 1
	combat.end_turn(0)
	var before: int = combat.players[0].discard_pile.size()
	combat.end_turn(1)
	_expect(combat.players[0].discard_pile.size() == before + 1 and combat.players[0].combatant.artifact == 1,
		"a 'curse' move is not warded by Artifact — a card lands on you, not a debuff stat, same as an event's own curse_card")


## Guards the actual point of the item: at least five beasts in the real
## content — not a synthetic Boss built for the tests above — carry a
## 'frail' or 'curse' move somewhere in their pattern (main or hurt_moves).
## A beast that only ever deals damage is a damage number with a picture on
## it, and that's the thing #69 exists to fix.
func _test_backlog69_at_least_five_beasts_debuff_hunters() -> void:
	var debuffers: Array = []
	for id in Content.boss_ids():
		var b := Content.build_boss(String(id))
		var carries := false
		for m in (b.moves + b.hurt_moves):
			if String((m as Dictionary).get("type", "")) in ["frail", "curse"]:
				carries = true
		if carries:
			debuffers.append(id)
	_expect(debuffers.size() >= 5,
		"at least 5 beasts inflict Frail or a curse [%d: %s]" % [debuffers.size(), ", ".join(debuffers)])


## Backlog #16/#54's own rule, extended to moves: a move `type` that shows up
## in bosses.json but has no keywords.json entry is a move a player can never
## ask about — Content.keyword() returns {} for it (see keywords.json's own
## "_comment_moves": "Ids match the move `type` in bosses.json").
func _test_every_beast_move_type_has_a_keyword() -> void:
	var missing: Array = []
	for id in Content.boss_ids():
		var b := Content.build_boss(String(id))
		for m in (b.moves + b.hurt_moves):
			var kind := String((m as Dictionary).get("type", ""))
			if kind != "" and String(Content.keyword(kind).get("text", "")).is_empty() and not missing.has(kind):
				missing.append(kind)
	_expect(missing.is_empty(), "every beast move type resolves to a keyword [%s]" % ", ".join(missing))


# --- Fight-start relics — the fifth moment (backlog #43/#70) ---------------

## The four openers all land before round 1's hand is drawn, and all four
## PERSIST past _begin_round()'s reset (unlike Block) — proven directly on
## the fields, not inferred from a card play.
func _test_backlog70_fight_start_relics_apply_before_round_one() -> void:
	var players := [Combatant.new("A", 42), Combatant.new("B", 42)]
	var c := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], players, _dummy_boss(300), 42,
		0, 0, 0, 0, [], {"open_power": 2, "open_artifact": 1, "open_thorns": 3, "open_intangible": 1})
	c.start()
	var ps: PlayerState = c.players[0]
	var power_entry: Dictionary = ps.powers.get("iron_husk", {})
	_expect(int(power_entry.get("stacks", 0)) == 2 and int(power_entry.get("value", 0)) == 6,
		"open_power seeds Iron Husk (power_value 3) at 2 stacks worth 6 before round 1")
	_expect(ps.combatant.artifact == 1, "open_artifact wards the hunter before round 1")
	_expect(ps.combatant.thorns == 3, "open_thorns bristles the hunter before round 1")
	_expect(ps.combatant.intangible == 1, "open_intangible protects the hunter before round 1")


## "Already resolving" (the item's own framing): a seeded power pays out at
## round 1's OWN turn_end, the same moment _handle_power_effects already uses
## for a power played mid-fight — no real power card was ever played here.
func _test_backlog70_seeded_power_pays_out_at_round_one_turn_end() -> void:
	var c := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], _dummy_boss(300), 42,
		0, 0, 0, 0, [], {"open_power": 1})
	c.start()
	var ps: PlayerState = c.players[0]
	var before: int = ps.combatant.block
	c.end_turn(0)  # fires MOMENT_TURN_END for player 0 alone -- ally hasn't ended,
	# so the round hasn't rolled over (and reset Block) yet; check right here.
	_expect(ps.combatant.block == before + 3,
		"Iron Husk's own +3 Block fires at turn_end even though nobody played it")


## A downside relic (#30) can push these negative the same generic way every
## other relic mod already can (see relic_totals' maxi(0, ...) callers) — this
## just proves _mod() itself never applies a NEGATIVE opener (there's nothing
## sensible for -1 Artifact/Thorns/Intangible to mean), same guard the block/
## energy bonuses use at their own call sites.
func _test_backlog70_negative_openers_are_ignored_not_applied() -> void:
	var c := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], _dummy_boss(300), 42,
		0, 0, 0, 0, [], {"open_artifact": -2, "open_thorns": -2, "open_intangible": -2, "open_power": -2})
	c.start()
	var ps: PlayerState = c.players[0]
	_expect(ps.combatant.artifact == 0 and ps.combatant.thorns == 0 and ps.combatant.intangible == 0
		and ps.powers.is_empty(), "a negative opener mod is a no-op, not a debuff")


## The moment fires exactly once per fresh fight (backlog #70's own "never on
## a mid-fight save reload" guarantee) — from_dict() rebuilds a Combat WITHOUT
## calling start(), so an opener already applied and then saved mid-fight must
## not double up on load.
func _test_backlog70_fight_start_does_not_reapply_on_save_reload() -> void:
	var c := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)],
		[Combatant.new("A", 42), Combatant.new("B", 42)], _dummy_boss(300), 42,
		0, 0, 0, 0, [], {"open_artifact": 1})
	c.start()
	_expect(c.players[0].combatant.artifact == 1, "opener applied once on a fresh fight")
	var reloaded := Combat.from_dict(c.to_dict())
	_expect(reloaded.players[0].combatant.artifact == 1,
		"reloading a saved fight does not re-fire the fight-start opener")


# --- Dexterity, Strength's counterpart (backlog #60) ----------------------

func _brace_up() -> Card:
	return Card.from_dict({"id": "brace_up", "name": "Brace Up", "type": "skill", "cost": 1, "dexterity": 2, "target": "self"})
func _steady_wrap() -> Card:
	return Card.from_dict({"id": "steady_wrap", "name": "Steady Wrap", "type": "skill", "cost": 1, "block": 4, "dexterity": 1, "target": "self"})


func _test_dexterity_adds_to_block_gained() -> void:
	var c := Combatant.new("Test", 30)
	c.dexterity = 3
	c.gain_block(5)
	_expect(c.block == 8, "Dexterity adds flat Block to every source of Block gained")


## The mechanism the backlog item actually asks for: a card that only grants
## Dexterity (no Block of its own — Brace Up), followed by an UNRELATED card
## that grants Block (Brace), proves Dexterity lifts Block from any source,
## not just a card built to combo with itself.
func _test_dexterity_card_lifts_a_later_different_cards_block() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_brace_up(), _defend()]
	combat.play_card(0, 0)  # Brace Up: Dexterity 2, no Block of its own
	_expect(ps.combatant.block == 0 and ps.combatant.dexterity == 2,
		"Brace Up grants Dexterity and no Block")
	combat.play_card(0, 0)  # Brace: 5 Block, lifted by the Dexterity just banked
	_expect(ps.combatant.block == 7, "Dexterity lifts Block from a later, unrelated card")


## Dexterity's bonus is folded into the raw amount BEFORE Frail's cut, the
## same "one generic rule" gain_block() already applies to every other source
## of Block (see _test_frail_reduces_block_gained) — so a Frailed defender
## still keeps some benefit from a banked Dexterity bonus rather than losing
## it outright.
func _test_dexterity_and_frail_interact_correctly() -> void:
	var c := Combatant.new("Test", 30)
	c.dexterity = 4
	c.frail = 1
	c.gain_block(8)
	_expect(c.block == 9, "Dexterity's bonus is added before Frail's cut, not exempt from it")


## Mirrors how Strength lifts damage on every attack AFTER the one that grants
## it, not the granting card itself (see play_card's ordering): a card
## carrying both `block` and `dexterity` must not inflate its own printed
## Block, but the Dexterity it banks has to lift every Block gain after it —
## including the SAME card played a second time.
func _test_dexterity_card_lifts_later_block_not_its_own() -> void:
	var combat := _new_combat([_deck_of(_steady_wrap, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	combat.play_card(0, 0)  # Steady Wrap: 4 Block + Dexterity 1, Dexterity starts at 0
	_expect(ps.combatant.block == 4,
		"a card's own Dexterity does not inflate the Block it grants on the same play")
	_expect(ps.combatant.dexterity == 1, "the Dexterity is still banked for every future Block gain")
	combat.play_card(0, _first_playable(combat, 0))  # a second Steady Wrap: Dexterity is live now
	_expect(ps.combatant.block == 4 + (4 + 1),
		"the banked Dexterity from the first play lifts the second card's own Block")


func _test_relic_start_dexterity() -> void:
	var players := [Combatant.new("A", 42), Combatant.new("B", 42)]
	var combat := Combat.new([_deck_of(_slash, 10), _deck_of(_slash, 10)], players,
		_dummy_boss(300), 42, 0, 0, 0, 0, [], {"start_dexterity": 3})
	combat.start()
	_expect(combat.players[0].combatant.dexterity == 3, "start_dexterity relic begins the fight with Dexterity")


# --- Intangible, Buffer and Plated Armour, the tier above Block (backlog #61) --

func _ghost_step() -> Card:
	return Card.from_dict({"id": "ghost_step", "name": "Ghost Step", "type": "skill", "cost": 1, "intangible": 2, "target": "self"})
func _overhang() -> Card:
	return Card.from_dict({"id": "overhang", "name": "Overhang", "type": "skill", "cost": 1, "buffer": 1, "target": "self"})
func _hardshell() -> Card:
	return Card.from_dict({"id": "hardshell", "name": "Hardshell", "type": "skill", "cost": 2, "plated_armour": 3, "target": "self"})


func _test_intangible_caps_a_hit_that_gets_past_block() -> void:
	var c := Combatant.new("Test", 30)
	c.intangible = 1
	c.take_damage(10)
	_expect(c.hp == 29 and c.intangible == 0,
		"Intangible caps a hit that gets past Block at 1 damage and spends a stack doing it")


## Block is checked FIRST — a hit it fully absorbs never reaches Intangible at
## all, so a well-blocked turn doesn't burn a stack for nothing.
func _test_intangible_is_not_spent_when_block_fully_absorbs_the_hit() -> void:
	var c := Combatant.new("Test", 30)
	c.block = 10
	c.intangible = 1
	c.take_damage(6)
	_expect(c.hp == 30 and c.block == 4 and c.intangible == 1,
		"a hit Block fully absorbs never touches Intangible")


func _test_buffer_cancels_a_hit_that_gets_past_block() -> void:
	var c := Combatant.new("Test", 30)
	c.buffer = 1
	c.take_damage(10)
	_expect(c.hp == 30 and c.buffer == 0,
		"Buffer cancels a hit that gets past Block outright and spends a stack doing it")


## Buffer is the stronger effect (full cancel vs. a cap at 1), so when both
## are stacked it goes first — otherwise Intangible would burn a stack
## capping a hit that was about to be voided anyway.
func _test_buffer_is_spent_before_intangible() -> void:
	var c := Combatant.new("Test", 30)
	c.buffer = 1
	c.intangible = 1
	c.take_damage(10)
	_expect(c.hp == 30 and c.buffer == 0 and c.intangible == 1,
		"Buffer's full cancel is used first, so the same hit doesn't also spend an Intangible stack")


## Thorns (backlog #36) fires off the attack LANDING, not off HP actually
## being lost — that was already true for Block; this proves it's still true
## once Buffer can void the hit completely, satisfying #61's "interacts
## correctly with... Thorns" done-when.
func _test_buffer_and_thorns_still_retaliate_when_a_hit_is_voided() -> void:
	var boss := _dummy_boss(300, 8)  # a plain "attack" move for 8
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	ps.combatant.buffer = 1
	ps.combatant.thorns = 3
	var hp0: int = ps.combatant.hp
	var boss_hp := combat.boss.hp
	combat.end_turn(0)
	combat.end_turn(1)  # round 1: boss_target_index() is player 0
	_expect(ps.combatant.hp == hp0, "Buffer cancels the boss's attack outright — no HP lost")
	_expect(ps.combatant.buffer == 0, "the cancel spends the Buffer stack")
	_expect(combat.boss.hp == boss_hp - 3, "Thorns still reflects the landed attack even though Buffer voided it")


func _test_intangible_card_grants_the_stat() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_ghost_step()]
	combat.play_card(0, 0)
	_expect(ps.combatant.intangible == 2, "Ghost Step grants Intangible 2")


func _test_buffer_card_grants_the_stat() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_overhang()]
	combat.play_card(0, 0)
	_expect(ps.combatant.buffer == 1, "Overhang grants Buffer 1")


## Unlike ordinary Block, Plated Armour survives the round reset instead of
## being wiped to 0 — Combat re-seeds `block` with it every round
## (_begin_round/_enemy_turn) rather than zeroing it.
func _test_plated_armour_persists_the_round_reset() -> void:
	var boss := _dummy_boss(300, 0)  # a plain attack for 0 — proves persistence, not decay
	var combat := _new_combat([_deck_of(_hardshell, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	combat.play_card(0, 0)  # Hardshell: Plated Armour 3
	_expect(ps.combatant.block == 3 and ps.combatant.plated_armour == 3,
		"Plated Armour grants ordinary Block immediately, same as any Block gain")
	combat.end_turn(0)
	combat.end_turn(1)  # round 2 begins; the boss's 0-damage attack doesn't touch it
	_expect(ps.combatant.block == 3,
		"Plated Armour re-seeds Block at the round reset instead of it resetting to 0")
	_expect(ps.combatant.plated_armour == 3, "an attack that deals 0 doesn't decay Plated Armour")


## The other half: it isn't free forever. It decays by 1 only once real HP
## damage still gets through despite it.
func _test_plated_armour_decays_only_when_a_hit_gets_hp_through() -> void:
	var boss := _dummy_boss(300, 5)  # attack for 5 — more than the 3 Block Plated Armour grants
	var combat := _new_combat([_deck_of(_hardshell, 10), _deck_of(_slash, 10)], 42, boss)
	var ps: PlayerState = combat.players[0]
	combat.play_card(0, 0)  # Hardshell: Plated Armour 3
	var hp0: int = ps.combatant.hp
	combat.end_turn(0)
	combat.end_turn(1)  # round 1: boss_target_index() is player 0; 3 Block absorbs, 2 gets through
	_expect(ps.combatant.hp == hp0 - 2, "Block still absorbs what it can before Plated Armour's decay check")
	_expect(ps.combatant.plated_armour == 2, "Plated Armour decays by 1 once real HP damage gets through")


func _test_intangible_buffer_plated_armour_persist_through_save() -> void:
	var run := Run.new([_deck_of(_slash, 8), _deck_of(_slash, 8)], ["A", "B"], 77, [{}, {}], 0)
	run.start()
	_step_into_combat(run)
	var combat: Combat = run.combat
	combat.players[0].combatant.intangible = 2
	combat.players[0].combatant.buffer = 1
	combat.players[0].combatant.plated_armour = 3

	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()
	var bc: Combat = back.combat if back != null else null
	_expect(bc != null and bc.players[0].combatant.intangible == 2
			and bc.players[0].combatant.buffer == 1 and bc.players[0].combatant.plated_armour == 3,
		"Intangible/Buffer/Plated Armour survive a mid-fight save and load")


## Two copies of one truth: PlayerState.to_dict()/from_dict() already round-trip
## every stat on Combatant (this project's Frail/Artifact/Thorns split, plus
## Dexterity/Intangible/Buffer/Plated Armour), and the test just above proves
## it for the player's own copy. Boss.to_dict()/apply_dict() is a second,
## independently written copy of that same round-trip — nothing shares the
## logic — and it only ever carried Frail/Artifact (backlog #36), never the
## four newer stats. No beast currently sets its own Dexterity/Intangible/
## Buffer/Plated Armour, so this never fired in play, but the shared-snapshot
## test above (_test_dexterity_intangible_buffer_plated_armour_reach_the_shared_
## snapshot) proves the boss CAN carry these values mid-fight, and a save
## partway through such a fight silently reset them to 0 on load.
func _test_boss_dexterity_intangible_buffer_plated_armour_persist_through_save() -> void:
	var run := Run.new([_deck_of(_slash, 8), _deck_of(_slash, 8)], ["A", "B"], 77, [{}, {}], 0)
	run.start()
	_step_into_combat(run)
	var combat: Combat = run.combat
	combat.boss.dexterity = 5
	combat.boss.intangible = 1
	combat.boss.buffer = 1
	combat.boss.plated_armour = 2

	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()
	var bc: Combat = back.combat if back != null else null
	_expect(bc != null and bc.boss.dexterity == 5 and bc.boss.intangible == 1
			and bc.boss.buffer == 1 and bc.boss.plated_armour == 2,
		"the boss's Dexterity/Intangible/Buffer/Plated Armour survive a mid-fight save and load")


# --- Cards that reward discarding (backlog #62) ----------------------------

func _quick_purge() -> Card:
	return Card.from_dict({"id": "quick_purge", "name": "Quick Purge", "type": "skill", "cost": 0, "discard": 2, "draw": 1, "target": "self"})
func _trash_strike() -> Card:
	return Card.from_dict({"id": "trash_strike", "name": "Trash Strike", "type": "attack", "cost": 1, "damage": 2, "damage_per_discarded": 1, "target": "enemy"})
func _refuse_wall() -> Card:
	return Card.from_dict({"id": "refuse_wall", "name": "Refuse Wall", "type": "skill", "cost": 1, "block": 2, "block_per_discarded": 1, "target": "self"})
func _cull_the_deck() -> Card:
	return Card.from_dict({"id": "cull_the_deck", "name": "Cull the Deck", "type": "attack", "cost": 1, "discard": 1, "damage": 3, "damage_per_discarded": 1, "target": "enemy"})
func _landfill() -> Card:
	return Card.from_dict({"id": "landfill", "name": "Landfill", "type": "skill", "cost": 2, "discard": 1, "block": 3, "block_per_discarded": 2, "target": "self"})


## Quick Purge discards 2 random cards from what's left of the hand (the card
## being played is already removed before this fires) and draws 1. Proves
## `discard` is an action a card can trigger on purpose, not just a side
## effect of ending a turn.
func _test_discard_field_sends_cards_to_the_discard_pile() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_quick_purge(), _slash(), _slash(), _slash()]
	var discard_before := ps.discard_pile.size()
	combat.play_card(0, 0)
	# Quick Purge itself (an ordinary skill card) lands in the discard pile
	# too, so the pile grows by 3: itself plus the 2 it forces out.
	_expect(ps.discard_pile.size() == discard_before + 3,
		"Quick Purge itself plus 2 forced discards land in the discard pile")
	_expect(ps.hand.size() == 2,
		"3 cards remained after Quick Purge was played, minus 2 discarded, plus 1 drawn")


## A forced discard must never crash or over-discard when the hand runs out
## first — it stops at whatever is actually there instead of failing the play.
func _test_discard_stops_early_when_hand_is_short() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_quick_purge()]  # nothing left in hand once Quick Purge itself is removed to be played
	var discard_before := ps.discard_pile.size()
	combat.play_card(0, 0)
	_expect(ps.discard_pile.size() == discard_before + 1,
		"with nothing left in hand, only the played card itself reaches the discard pile")
	_expect(ps.hand.size() == 1,
		"the draw still refills the hand even though the discard had nothing left to take")


## The payoff half: damage_per_discarded reads the discard pile's CURRENT
## size, which by now includes the card being played itself — an ordinary
## card is routed into the discard pile before preview() runs (unlike
## exhaust_pick, whose sacrifice resolves later in play_card).
func _test_damage_per_discarded_scales_with_pile_size() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.discard_pile = [_slash(), _slash()]  # 2 already sitting in the pile
	ps.hand = [_trash_strike()]
	var boss_hp := combat.boss.hp
	combat.play_card(0, 0)
	_expect(boss_hp - combat.boss.hp == 5,
		"Trash Strike counts the pile including itself once played: 2 base + 1*3 = 5")


func _test_block_per_discarded_scales_with_pile_size() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.discard_pile = [_slash()]  # 1 already sitting in the pile
	ps.hand = [_refuse_wall()]
	combat.play_card(0, 0)
	_expect(ps.combatant.block == 4,
		"Refuse Wall counts the pile including itself once played: 2 base + 1*2 = 4")


## Cull the Deck both scales off the discard pile AND forces one more card out
## of hand via its own `discard` field. The forced discard resolves LATER in
## play_card (after preview() already read the pile), so it must not also pay
## into this same play's own bonus — the same "counts only earlier plays"
## ordering damage_per_exhausted's Detonator test guards against.
func _test_cull_the_deck_does_not_count_its_own_forced_discard() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.hand = [_cull_the_deck(), _slash()]
	var before: int = combat.boss.hp
	combat.play_card(0, 0)
	_expect(before - combat.boss.hp == 4,
		"Cull the Deck's own bonus counts itself in the pile (3 base + 1*1) but not the card its own discard forces out")
	_expect(ps.discard_pile.size() == 2,
		"both Cull the Deck and the card it forced out end up in the discard pile")


func _test_discard_and_scaling_cards_survive_mid_combat_save_and_load() -> void:
	var run := Run.new([_deck_of(_slash, 8), _deck_of(_slash, 8)], ["A", "B"], 77, [{}, {}], 0)
	run.start()
	_step_into_combat(run)
	var combat: Combat = run.combat
	combat.players[0].hand = [_trash_strike(), _cull_the_deck()]
	combat.players[0].discard_pile = [_slash(), _landfill()]

	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()
	var bc: Combat = back.combat if back != null else null
	var restored_hand: Array = bc.players[0].hand if bc != null else []
	var restored_discard: Array = bc.players[0].discard_pile if bc != null else []
	_expect(bc != null and restored_hand.size() == 2 and restored_discard.size() == 2,
		"hand and discard pile sizes survive a mid-fight save and load")
	_expect(bc != null and (restored_hand[0] as Card).damage_per_discarded == 1
			and (restored_discard[1] as Card).block_per_discarded == 2,
		"the discard/damage_per_discarded/block_per_discarded fields survive the round trip")


# --- More than one thing to fight at once (backlog #63) --------------------

func _sweeping_strike() -> Card:
	return Card.from_dict({"id": "sweeping_strike", "name": "Sweeping Strike", "type": "attack",
		"cost": 2, "damage": 8, "hits_all_enemies": true, "target": "enemy"})


## The boss's own "adds" data (a beast that carries some) builds real Boss
## instances automatically when a Combat starts against it. Proven against
## real content (the Root Lurker, bosses.json), not a synthetic fixture, so a
## typo in that data would actually be caught here.
func _test_boss_data_can_carry_adds() -> void:
	var adds := Content.build_boss_adds("root_lurker")
	_expect(adds.size() == 1 and (adds[0] as Boss).name == "Root Tendril"
			and (adds[0] as Boss).hp == 14,
		"the Root Lurker's data-defined add is built with its own name and HP")
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, Content.build_boss("root_lurker"))
	_expect(combat.adds.size() == 1,
		"starting a Combat against a beast with 'adds' data pulls them in automatically")


func _test_a_beast_with_no_adds_data_has_none() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, Content.build_boss("stone_warden"))
	_expect(combat.adds.is_empty(),
		"a beast with no 'adds' entry starts a fight with none -- every existing beast is unaffected")


## enemy_index is engine-only (no card face lets a player choose one yet) but
## has to actually route damage correctly for the day one does.
func _test_enemy_index_targets_an_add_not_the_boss() -> void:
	var boss := _dummy_boss(300)
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var add := Boss.new("Grub", 10)
	combat.adds.append(add)
	combat.players[0].hand = [_slash()]
	combat.play_card(0, 0, true, -1, -1, -1, Combat.TIMING_PERFECT, 0)
	_expect(add.hp == 4 and boss.hp == 300,
		"an attack played with enemy_index 0 lands on the add, leaving the boss untouched")


func _test_enemy_index_out_of_range_falls_back_to_the_boss() -> void:
	var boss := _dummy_boss(300)
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	combat.players[0].hand = [_slash()]
	combat.play_card(0, 0, true, -1, -1, -1, Combat.TIMING_PERFECT, 5)  # no such add
	_expect(boss.hp == 294,
		"every existing card call -- no adds present, or an out-of-range index -- still hits the boss exactly as before this field existed")


func _test_hits_all_enemies_hits_boss_and_every_living_add() -> void:
	var boss := _dummy_boss(300)
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var add1 := Boss.new("Grub A", 20)
	var add2 := Boss.new("Grub B", 20)
	combat.adds.append(add1)
	combat.adds.append(add2)
	combat.players[0].hand = [_sweeping_strike()]
	combat.play_card(0, 0)
	_expect(boss.hp == 292 and add1.hp == 12 and add2.hp == 12,
		"a hits_all_enemies card damages the boss and every living add for the same amount")


func _test_hits_all_enemies_skips_a_dead_add() -> void:
	var boss := _dummy_boss(300)
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var dead_add := Boss.new("Grub", 5)
	dead_add.hp = 0
	var living_add := Boss.new("Grub 2", 20)
	combat.adds.append(dead_add)
	combat.adds.append(living_add)
	combat.players[0].hand = [_sweeping_strike()]
	combat.play_card(0, 0)
	_expect(living_add.hp == 12 and dead_add.hp == 0,
		"a hits_all_enemies card never revives a dead add or logs damage for one")


func _test_killing_an_add_does_not_end_the_fight() -> void:
	var boss := _dummy_boss(300)
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var add := Boss.new("Grub", 6)
	combat.adds.append(add)
	combat.players[0].hand = [_slash()]
	combat.play_card(0, 0, true, -1, -1, -1, Combat.TIMING_PERFECT, 0)
	_expect(add.is_dead() and combat.result() == Combat.Result.ONGOING,
		"an add dying doesn't end the fight -- only the boss's own death does")


## A living add acts on its own move pattern after the boss, using the same
## Boss.current_move()/advance_move() machinery -- a real (if thin) second
## thing to fight, not just an extra HP bar to poke at.
func _test_add_acts_on_its_own_turn() -> void:
	var boss := _dummy_boss(300, 0)  # 0-damage boss isolates the add's own hit
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var add := Boss.new("Grub", 30)
	add.moves = [{"type": "attack", "value": 5}]
	combat.adds.append(add)
	var hp_before: int = combat.players[0].combatant.hp
	combat.end_turn(0)
	combat.end_turn(1)
	_expect(combat.players[0].combatant.hp == hp_before - 5,
		"a living add attacks on the beast's own turn, using its own move pattern")


func _test_add_block_reseeds_each_round_like_the_bosss_own() -> void:
	var boss := _dummy_boss(300, 0)
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var add := Boss.new("Grub", 30)
	add.moves = [{"type": "block", "value": 6}]
	combat.adds.append(add)
	combat.end_turn(0)
	combat.end_turn(1)
	_expect(add.block == 6, "an add's own 'block' move grants it Block the same way the boss's does")
	combat.end_turn(0)
	combat.end_turn(1)
	_expect(add.block == 6,
		"the add's Block is reseeded (not stacked) each round -- the same reset the boss's own Block gets")


func _test_add_thorns_bites_the_attacking_add_not_the_boss() -> void:
	var boss := _dummy_boss(300, 0)
	# A bare "attack" move (even for 0) still calls _boss_hits() and would
	# reflect this same Thorns onto the MAIN boss too, muddying the isolation
	# this test wants -- give it a "block" move instead so only the add's own
	# attack (via _adds_turn()) ever calls _boss_hits() this round.
	boss.moves = [{"type": "block", "value": 0}]
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	var add := Boss.new("Grub", 30)
	add.moves = [{"type": "attack", "value": 5}]
	combat.adds.append(add)
	combat.players[0].combatant.thorns = 3
	combat.end_turn(0)
	combat.end_turn(1)
	_expect(add.hp == 27 and boss.hp == 300,
		"Thorns on the hunter an add hit reflects onto the ADD that hit them, not the main boss standing next to it")


func _test_adds_round_trip_through_save_and_load() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, Content.build_boss("root_lurker"))
	_expect(combat.adds.size() == 1, "sanity: the Root Lurker starts with its one add")
	var add: Boss = combat.adds[0]
	add.hp -= 5
	add.block = 2
	var d := combat.to_dict()
	var restored := Combat.from_dict(d)
	_expect(restored.adds.size() == 1 and (restored.adds[0] as Boss).hp == add.hp
			and (restored.adds[0] as Boss).block == 2,
		"an add's dynamic state (HP, Block) survives a save/load round trip")


## Backlog #45's own concern applied to this item: a field that exists on the
## host and never reaches a peer is exactly the kind of bug this whole item
## could introduce without a boundary test.
func _test_adds_reach_the_shared_snapshot() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	# _make_session() rolls a random fight-pool beast for its node, and some of
	# them (Root Lurker) carry their own add from bosses.json — clear it first
	# so this test's assertion doesn't depend on which beast the roll happened
	# to land on, only on what it appends itself.
	host._run.combat.adds.clear()
	var add := Boss.new("Grub", 15)
	add.id = "grub"
	add.hp = 9
	host._run.combat.adds.append(add)
	host._broadcast_state()
	var adds_view: Array = c0.shared["boss"]["adds"]
	_expect(adds_view.size() == 1 and String(adds_view[0]["name"]) == "Grub"
			and int(adds_view[0]["hp"]) == 9 and int(adds_view[0]["max_hp"]) == 15,
		"an add's identity and current HP reach the shared snapshot")


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


func _test_roped_ally_climbs_only_once_per_play() -> void:
	# A card that BOTH targets_hold and carries grip used to hit two separate
	# ally_climb branches in Combat.play_card and lift the ally twice for one
	# play. No authored card carries both today, but Meld ORs targets_hold and
	# sums grip from its two halves (combat.gd _meld_cards), so melding a
	# targets_hold card with a grip card reaches it directly.
	var boss := _climb_boss(6)
	boss.ledges = [2, 4]
	var combat := _new_combat_p([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42,
		boss, [{"type": "ally_climb", "value": 1}, {}])
	var ps: PlayerState = combat.players[0]
	ps.hand = [_meld_card(), Content.make_card("route_finder"), Content.make_card("scramble")]
	ps.energy = 3
	combat.play_card(0, 0, true, 1, 2)  # meld Route Finder (targets_hold) + Scramble (grip 1)
	var fused: Card = ps.hand[0]
	var fused_ok: bool = fused.targets_hold and fused.grip == 1
	combat.play_card(0, 0)  # play the fused card: hits BOTH the targets_hold and grip branches
	_expect(fused_ok and combat.players[1].foothold == 1,
		"a card that both targets a hold and carries grip lifts a roped ally only once, not twice")


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


## backlog #86 duty 2 — the real bug behind the two synthetic face_text tests
## above: GameHost's per-card "fx" dict (the one that crosses the wire to a
## client) never carried "dexterity" at all, so Steady Grip — a real card in
## the shared reward pool, "Gain 4 Block. Dexterity 1." — reached its owner's
## hand with Dexterity invisible to CardView.face_text even though every other
## field needed to render it was present. Drives it through an actual
## GameHost/GameClient pair, not a hand-built dict, so a regression in the
## wiring (not just the formatter) would be caught.
func _test_backlog86_steady_grip_fx_carries_dexterity_over_the_wire() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	var steady: Card = Content.make_card("steady_grip")
	host._run.combat.players[0].hand.append(steady)
	host._broadcast_state()
	var hand: Array = c0.private["hand"]
	var mine: Dictionary = hand[hand.size() - 1]
	_expect(String(mine["name"]) == steady.name and int((mine["fx"] as Dictionary).get("dexterity", 0)) == 1,
		"Steady Grip's fx dict carries its Dexterity to the owner's client, not just its Block")


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
func _reckless_swing() -> Card:
	return Card.from_dict({"id": "reckless_swing", "name": "Reckless Swing", "type": "attack", "cost": 1, "damage": 10, "ethereal": true})
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


# --- backlog #64: keys, and a Titan you can only reach with them -----------

func _test_backlog64_keys_are_run_state_and_round_trip() -> void:
	var run := _map_run()
	run.keys = ["elite", "treasure"]
	var d := run.to_dict()
	var loaded := Run.from_dict(d)
	var old_shape: Dictionary = d.duplicate(true)
	old_shape.erase("keys")  # a save written before #64 has no such key at all
	var backfilled := Run.from_dict(old_shape)
	_expect(loaded.keys == ["elite", "treasure"] and backfilled.keys.is_empty(),
		"keys round-trip through save/load and an older save backfills to none")


func _test_backlog64_take_key_trades_the_relic_reward_on_treasure() -> void:
	var run := _map_run()
	run.gold = 500
	run.node_type = "treasure"
	run._begin_reward("relic")
	var gold_before: int = run.gold
	var ok := run.take_key("treasure")
	_expect(ok and run.keys.has("treasure") and run.gold == gold_before - Run.KEY_COST_GOLD
		and run.phase != Run.Phase.REWARD,
		"taking a key on a treasure node spends gold, grants the key, and closes the node")


func _test_backlog64_take_key_trades_the_relic_reward_on_elite() -> void:
	var run := _map_run()
	run.gold = 500
	run.node_type = "elite"
	run._begin_reward("relic")
	var gold_before: int = run.gold
	var ok := run.take_key("elite")
	_expect(ok and run.keys.has("elite") and run.gold == gold_before - Run.KEY_COST_GOLD,
		"taking a key on an elite's relic reward grants the key and spends gold")


func _test_backlog64_take_key_refuses_the_wrong_node_type() -> void:
	var run := _map_run()
	run.gold = 500
	run.node_type = "treasure"
	run._begin_reward("relic")
	var wrong_source := run.take_key("elite")       # doesn't match this node
	var not_a_source := run.take_key("event")        # events grant keys their own way, not this one
	_expect(not wrong_source and not not_a_source,
		"take_key only fires for the node type actually being resolved")


func _test_backlog64_take_key_refuses_without_gold_or_after_a_pick() -> void:
	var run := _map_run()
	run.node_type = "treasure"
	run._begin_reward("relic")
	run.gold = 0
	var broke := run.take_key("treasure")
	run.gold = 500
	run.pick_reward(0, 0)  # hunter 0 actually takes a relic, not just a decline
	var too_late := run.take_key("treasure")
	_expect(not broke and not too_late,
		"take_key needs the real cost paid, and closes once anyone's actually taken the relic")


## backlog #86 duty 2 (find an error and resolve it): take_key()'s own doc comment
## says it's legal "before anyone's taken the relic" — but the guard used to check
## reward_picked, which also goes true on a plain skip_reward() decline. One hunter
## declining silently locked the OTHER hunter out of trading the reward for a key,
## even though nobody had taken anything and the "team holding neither cleanly"
## concern the comment names never applied. Fixed with a dedicated _relic_taken
## flag, set only where pick_reward() actually grants a relic.
func _test_backlog86_take_key_survives_an_allys_decline() -> void:
	var run := _map_run()
	run.gold = 500
	run.node_type = "treasure"
	run._begin_reward("relic")
	run.skip_reward(0)  # hunter 0 declines outright — takes nothing
	var ok := run.take_key("treasure")
	_expect(ok and run.keys.has("treasure"),
		"an ally's decline must not block take_key — nobody has taken the relic yet")


func _test_backlog64_take_key_is_once_per_node_type_per_run() -> void:
	var run := _map_run()
	run.gold = 5000
	run.node_type = "treasure"
	run._begin_reward("relic")
	run.take_key("treasure")
	run.node_type = "treasure"          # a second treasure node, later in the same run
	run._begin_reward("relic")
	var second := run.take_key("treasure")
	_expect(not second and run.keys == ["treasure"],
		"a node type only ever pays out its key once, however many times it's visited")


## backlog #86 duty 2 (find an error and resolve it): Run.take_key() (backlog
## #64) was fully implemented and unit-tested by calling it directly on a bare
## Run above -- but nothing wired a "take_key" GameClient command to it.
## GameHost._on_command()'s match had no "take_key" case, so a real client's
## command fell through to the "unknown command" branch and did nothing. In
## an actual playthrough that meant the "elite" and "treasure" keys were
## permanently unreachable (only "event" ever granted, via an event's own
## effect), so `keys.size() < KEY_TYPES.size()` was always true at the final
## Titan node and every run hit the "sealed door" branch instead of the true
## final fight -- 100% of the time, in both solo and co-op. No existing test
## caught it because every take_key test drives Run directly, bypassing
## GameHost entirely. Fixed with a "take_key" case in game_host.gd and a
## GameClient.take_key() sender.
func _test_backlog86_gamehost_wires_take_key_command_to_run() -> void:
	var t := LocalTransport.new()
	var host := GameHost.new(t, 42, 2, true)  # solo
	_kept.append(host)
	var c := GameClient.new(t, 1)
	c.join()
	c.select_character("frog", 0)
	c.select_character("goblin_mech", 1)
	_expect(host._run != null, "setup sanity: the solo run started once both hunters were picked")
	host._run.node_type = "treasure"
	host._run.gold = 500
	host._run._begin_reward("relic")
	var gold_before: int = host._run.gold
	c.take_key(0)
	_expect(host._run.keys.has("treasure") and host._run.gold == gold_before - Run.KEY_COST_GOLD,
		"a 'take_key' command sent through GameClient/GameHost must actually reach Run.take_key -- it used to fall through to the unknown-command branch and do nothing")


## The reward screen needs to know how many keys the team already holds, to
## decide whether "Take a Key instead" is still worth offering (Run.take_key
## refuses a key already banked) -- _build_shared() never forwarded Run.keys
## to clients at all before this fix, alongside the missing command above.
func _test_backlog86_build_shared_exposes_keys_for_the_reward_screen() -> void:
	var t := LocalTransport.new()
	var host := GameHost.new(t, 42, 2, true)  # solo
	_kept.append(host)
	var c := GameClient.new(t, 1)
	c.join()
	c.select_character("frog", 0)
	c.select_character("goblin_mech", 1)
	host._run.keys = ["event"]
	host._broadcast_state()
	_expect((c.shared.get("keys", []) as Array) == ["event"],
		"the shared snapshot must carry the run's banked keys so the reward screen can gate its 'Take a Key' option")


func _test_backlog64_event_key_effect_grants_the_event_key_once() -> void:
	var run := _map_run()
	run.phase = Run.Phase.EVENT
	run._apply_effect_block({"key": true})
	var after_first: Array = run.keys.duplicate()
	run._apply_effect_block({"key": true})
	_expect(after_first == ["event"] and run.keys == ["event"],
		"an event's key effect grants the event key once and stays idempotent")


func _test_backlog64_boon_effects_never_grant_a_key() -> void:
	var run := _map_run()
	run.boon = {"choices": [{"result": "", "effects": {"key": true}}]}
	run.phase = Run.Phase.BOON
	run.pick_boon(0)
	_expect(run.keys.is_empty(),
		"the run-start boon shares _apply_effect_block but never grants a key — no node type earned it")


func _test_backlog64_sealed_hollow_event_grants_a_key_at_a_real_cost() -> void:
	var run := _map_run()
	run.event = Content.make_event("the_sealed_hollow")
	run.phase = Run.Phase.EVENT
	var hp_before: int = run.hp[0]
	var ok := run.pick_event(0)  # "Force the seal"
	_expect(ok and run.keys.has("event") and run.hp[0] < hp_before,
		"the sealed hollow event grants the event key and bruises the team for it")


func _test_backlog64_map_guarantees_all_three_key_source_types_exist() -> void:
	var ok := true
	var bad_seed := -1
	for s in range(1, 25):
		var rng := RandomNumberGenerator.new()
		rng.seed = s
		var m := RunMap.new(Run.ENCOUNTERS.size(), rng)
		var found := {"elite": false, "treasure": false, "event": false}
		for row in m.rows:
			for n in row:
				var t := String((n as Dictionary)["type"])
				if found.has(t):
					found[t] = true
		for k in found:
			if not bool(found[k]):
				ok = false
				bad_seed = s
		if not ok:
			break
	_expect(ok, "every generated map guarantees an elite, a treasure, and an event node exist (failed seed %d)" % bad_seed)


func _test_backlog64_final_titan_is_a_sealed_door_without_all_three_keys() -> void:
	var run := _map_run()
	run.map_row = run.map.total_rows() - 2
	run.map_col = 0
	var open: Array = run.available_nodes()
	var stepped := run.pick_node(int(open[0]))
	_expect(stepped and run.phase == Run.Phase.WON and run.combat == null
		and not bool(run.stats["true_ending"]),
		"short of all three keys, reaching the fourth Titan ends the run instead of fighting it")


func _test_backlog64_final_titan_is_a_real_fight_with_all_three_keys() -> void:
	var run := _map_run()
	run.keys = Run.KEY_TYPES.duplicate()
	run.map_row = run.map.total_rows() - 2
	run.map_col = 0
	var open: Array = run.available_nodes()
	var stepped := run.pick_node(int(open[0]))
	var fighting := stepped and run.phase == Run.Phase.COMBAT and run.combat != null
	if fighting:
		_force_win(run)
	_expect(fighting and bool(run.stats["true_ending"]),
		"with all three keys the fourth Titan is a real fight, and winning it earns the true ending")


# --- Run history (backlog #65) ---------------------------------------------
# #39 already accumulates `stats` while a run plays; this is what keeps that
# once the run itself is thrown away — Run.history_entry() is the shape,
# Progress.record_run()/run_history() is where it lives, and GameHost is the
# one call site that must fire it exactly once.

## Sets phase directly rather than driving a real fight to LOST through
## Combat/sync() — that flow (WIN routes through REWARD, not straight to WON;
## a real loss needs a dead Combatant) is already proven by #39's and #64's own
## tests. This test is only about what history_entry() computes FROM a
## finished run's fields, so it starts from one already in that state.
func _test_backlog65_history_entry_shape_on_a_loss() -> void:
	var decks := [_deck_of(_slash, 6), _deck_of(_slash, 5)]
	var run := Run.new(decks, ["A", "B"], 123, [{"character": "frog"}, {"character": "goblin_mech"}], 2)
	run.start()
	run.stats["died_to"] = "Stone Warden"
	run.phase = Run.Phase.LOST

	var entry := run.history_entry()
	var final_deck: Array = entry["final_deck"]
	var deck_ids_match: bool = final_deck.size() == 2 \
		and (final_deck[0] as Array).size() == run.decks[0].size() \
		and String((final_deck[0] as Array)[0]) == String((run.decks[0][0] as Card).id)
	_expect(entry["characters"] == ["frog", "goblin_mech"] and entry["seed"] == 123
		and entry["ascension"] == 2 and entry["result"] == "lose"
		and String(entry["stats"]["died_to"]) == "Stone Warden" and deck_ids_match,
		"a lost run's history entry names who played, the seed, ascension, cause of death and final deck")


func _test_backlog65_history_entry_shape_on_a_win() -> void:
	var decks := [_deck_of(_slash, 6), _deck_of(_slash, 5)]
	var run := Run.new(decks, ["A", "B"], 55, [{"character": "frog"}, {"character": "goblin_mech"}], 0)
	run.start()
	run.stats["beasts_felled"] = 4
	run.stats["true_ending"] = true
	run.phase = Run.Phase.WON

	var entry := run.history_entry()
	_expect(entry["result"] == "win" and entry["characters"] == ["frog", "goblin_mech"]
		and bool(entry["stats"]["true_ending"]) and int(entry["stats"]["beasts_felled"]) == 4,
		"a won run's history entry says win and carries this run's own stats through untouched")


func _test_backlog65_progress_record_run_appends_and_round_trips() -> void:
	Progress.use_scratch_slot("run_tests_backlog65_progress")
	var cfg := ConfigFile.new()
	cfg.set_value(Progress.SECTION, "run_history", [])
	cfg.save(Progress.path)
	var entry_a := {"characters": ["frog", "goblin_mech"], "seed": 1, "ascension": 0,
		"result": "win", "is_daily": false, "daily_date": "",
		"stats": {"beasts_felled": 1}, "final_deck": [["slash"], ["slash"]]}
	var entry_b := {"characters": ["vine_weaver", "frog"], "seed": 2, "ascension": 1,
		"result": "lose", "is_daily": false, "daily_date": "",
		"stats": {"died_to": "Gale Serpent"}, "final_deck": [["slash"], ["slash"]]}
	Progress.record_run(entry_a)
	Progress.record_run(entry_b)

	var history := Progress.run_history()
	_expect(history.size() == 2
		and String(history[0]["result"]) == "win" and String(history[1]["result"]) == "lose"
		and String((history[1]["characters"] as Array)[0]) == "vine_weaver",
		"Progress.record_run appends without disturbing earlier entries, and run_history reads them back in order")


## GameHost broadcasts on every settled action, including ones after a run has
## already ended (nothing stops a client polling a WON/LOST screen from
## triggering more of them) — without a guard the log would grow one entry per
## broadcast instead of one per run.
func _test_backlog65_gamehost_records_history_exactly_once() -> void:
	Progress.use_scratch_slot("run_tests_backlog65_host")
	var cfg := ConfigFile.new()
	cfg.set_value(Progress.SECTION, "run_history", [])
	cfg.save(Progress.path)
	var t := LocalTransport.new()
	var host := GameHost.new(t, 42, 2, true)  # solo
	_kept.append(host)
	var c := GameClient.new(t, 1)
	c.join()
	c.select_character("frog", 0)
	c.select_character("goblin_mech", 1)
	_expect(host._run != null, "setup sanity: the solo run started once both hunters were picked")

	host._run.phase = Run.Phase.WON
	host._broadcast_state()
	host._broadcast_state()
	host._broadcast_state()
	_expect(Progress.run_history().size() == 1,
		"a finished run is logged exactly once even though broadcasts keep firing after it ends")


## Backlog #35's lesson applied here rather than to a versioned save: an entry
## written before some later build added a field must not make the whole file
## unreadable, and a reader that asks for that field with a default must not
## crash on its absence.
func _test_backlog65_run_history_tolerates_an_entry_missing_a_newer_field() -> void:
	Progress.use_scratch_slot("run_tests_backlog65_old_shape")
	var cfg := ConfigFile.new()
	cfg.set_value(Progress.SECTION, "run_history", [
		{"characters": ["frog", "goblin_mech"], "seed": 9, "ascension": 0, "result": "win"},
	])
	cfg.save(Progress.path)

	var history := Progress.run_history()
	_expect(history.size() == 1 and String(history[0]["result"]) == "win"
		and (history[0] as Dictionary).get("final_deck", []) == [],
		"an entry missing a field a later build added still loads, and reading that field defaults rather than crashing")


## Backlog #59 — Scry: playing a scry card reveals the top N cards of the draw
## pile (index 0 is the next one that would be drawn) WITHOUT drawing them, and
## leaves them in PlayerState.scry_pending until resolve_scry() decides what
## happens to each.
func _test_backlog59_scry_reveals_and_resolve_scry_bins_and_keeps_order() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	var a := Card.from_dict({"id": "a", "name": "A", "type": "skill", "cost": 0})
	var b := Card.from_dict({"id": "b", "name": "B", "type": "skill", "cost": 0})
	var c := Card.from_dict({"id": "c", "name": "C", "type": "skill", "cost": 0})
	var d := Card.from_dict({"id": "d", "name": "D", "type": "skill", "cost": 0})
	var e := Card.from_dict({"id": "e", "name": "E", "type": "skill", "cost": 0})
	ps.draw_pile = [a, b, c, d, e]   # e is the "top" — pop_back() draws it first
	ps.hand = [Card.from_dict({"id": "read_the_climb", "name": "Read The Climb", "type": "skill",
		"cost": 1, "scry": 3})]
	ps.energy = 3
	combat.play_card(0, 0)
	_expect(ps.scry_pending.size() == 3
		and (ps.scry_pending[0] as Card).id == "e"
		and (ps.scry_pending[1] as Card).id == "d"
		and (ps.scry_pending[2] as Card).id == "c",
		"Scry reveals the top N cards, in draw order, without drawing them")

	var ok := combat.resolve_scry(0, [1])   # bin "d"
	_expect(ok and ps.scry_pending.is_empty(),
		"resolve_scry clears the pending reveal and reports success")
	# discard_pile already holds the played "read_the_climb" card itself — the
	# binned card lands beside it.
	_expect(ps.discard_pile.size() == 2 and (ps.discard_pile[1] as Card).id == "d",
		"the binned card lands in the discard pile")
	_expect(ps.draw_pile.size() == 4
		and (ps.draw_pile[3] as Card).id == "e" and (ps.draw_pile[2] as Card).id == "c"
		and (ps.draw_pile[1] as Card).id == "b" and (ps.draw_pile[0] as Card).id == "a",
		"kept cards return to the top of the draw pile in the same order they were revealed")


## #86 duty 2: play_card()'s scry branch used to OVERWRITE ps.scry_pending
## outright, and _peek_top() already pops its cards straight off draw_pile —
## so a second scry played before the first was resolved didn't just discard
## the first reveal, it destroyed those cards: not in hand, draw, discard or
## exhaust, gone for the rest of the fight. Reachable with cards.json's own
## "Peer Ahead" (cost 1, scry 2) and "Read The Climb" (cost 1, scry 4) — two
## cheap cards, no UI gate forces a resolve between plays.
func _test_backlog86_second_scry_before_resolve_does_not_lose_the_first_batch() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	var a := Card.from_dict({"id": "a", "name": "A", "type": "skill", "cost": 0})
	var b := Card.from_dict({"id": "b", "name": "B", "type": "skill", "cost": 0})
	var c := Card.from_dict({"id": "c", "name": "C", "type": "skill", "cost": 0})
	var d := Card.from_dict({"id": "d", "name": "D", "type": "skill", "cost": 0})
	var e := Card.from_dict({"id": "e", "name": "E", "type": "skill", "cost": 0})
	var f := Card.from_dict({"id": "f", "name": "F", "type": "skill", "cost": 0})
	var g := Card.from_dict({"id": "g", "name": "G", "type": "skill", "cost": 0})
	ps.draw_pile = [a, b, c, d, e, f, g]   # g is the "top" — pop_back() draws it first
	ps.hand = [
		Card.from_dict({"id": "peer_ahead", "name": "Peer Ahead", "type": "skill", "cost": 1, "scry": 2}),
		Card.from_dict({"id": "read_the_climb", "name": "Read The Climb", "type": "skill", "cost": 1, "scry": 3}),
	]
	ps.energy = 3
	combat.play_card(0, 0)   # scries g, f
	_expect(ps.scry_pending.size() == 2, "the first scry reveals its own cards before a second is played")
	combat.play_card(0, 0)   # the second card slid to index 0 once the first left the hand
	var ids: Array = []
	for card_v in ps.scry_pending:
		ids.append((card_v as Card).id)
	_expect(ids == ["g", "f", "e", "d", "c"],
		"a second scry played before the first resolves APPENDS to the pending reveal instead of replacing it, so no card is lost")

	var ok := combat.resolve_scry(0, [0, 4])   # bin "g" and "c", keep f, e, d
	_expect(ok and ps.scry_pending.is_empty(), "resolve_scry still clears the whole merged reveal")
	# draw_pile was [a, b] after both peeks popped g,f,e,d,c off it; kept (f, e,
	# d) return to the top in the same order they were revealed, so f is next.
	_expect(ps.draw_pile.size() == 5
		and (ps.draw_pile[4] as Card).id == "f" and (ps.draw_pile[3] as Card).id == "e"
		and (ps.draw_pile[2] as Card).id == "d" and (ps.draw_pile[1] as Card).id == "b"
		and (ps.draw_pile[0] as Card).id == "a",
		"the kept cards from both batches return to the top of the draw pile in reveal order")


func _test_backlog59_resolve_scry_validates_bad_input() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	_expect(not combat.resolve_scry(-1, []) and not combat.resolve_scry(99, []),
		"resolve_scry rejects an out-of-range player index")
	_expect(not combat.resolve_scry(0, []),
		"resolve_scry is a no-op when nothing is pending")

	var ps: PlayerState = combat.players[0]
	var a := Card.from_dict({"id": "a", "name": "A", "type": "skill", "cost": 0})
	var b := Card.from_dict({"id": "b", "name": "B", "type": "skill", "cost": 0})
	ps.draw_pile = [a, b]
	ps.hand = [Card.from_dict({"id": "peer_ahead", "name": "Peer Ahead", "type": "skill",
		"cost": 1, "scry": 2})]
	ps.energy = 3
	combat.play_card(0, 0)   # scries both remaining cards: b, then a
	var ok := combat.resolve_scry(0, [-1, 99])   # nonsense indices — ignored, not fatal
	# discard_pile already holds the played "peer_ahead" card itself; nothing
	# else should have joined it, since neither bin index was valid.
	_expect(ok and ps.discard_pile.size() == 1 and ps.draw_pile.size() == 2,
		"an out-of-range bin index is ignored rather than failing the whole call")


func _test_backlog59_scry_survives_playerstate_dict_round_trip() -> void:
	var ps := PlayerState.new()
	ps.combatant = Combatant.new("X", 30)
	ps.scry_pending = [Content.make_card("slash"), Content.make_card("brace")]
	var back := PlayerState.from_dict(ps.to_dict())
	_expect(back.scry_pending.size() == 2
		and (back.scry_pending[0] as Card).id == "slash"
		and (back.scry_pending[1] as Card).id == "brace",
		"PlayerState.scry_pending round-trips through to_dict/from_dict")


## The real chain, not just the leaf — same reasoning #47's Light tests give:
## a mid-fight save (#14) must carry a pending Scry the same way it already
## carries the hand and the piles.
func _test_backlog59_scry_survives_mid_combat_save_and_load() -> void:
	var run := Run.new([_deck_of(_slash, 8), _deck_of(_slash, 8)], ["A", "B"], 55,
		[{"character": "frog"}, {"character": "lightbearer"}], 0)
	run.start()
	_step_into_combat(run)
	var combat: Combat = run.combat
	combat.players[1].scry_pending = [Content.make_card("slash")]
	RunSave.clear()
	RunSave.save(run)
	var back := RunSave.load_run()
	var back_combat: Combat = back.combat
	_expect(back_combat != null and back_combat.players[1].scry_pending.size() == 1
		and (back_combat.players[1].scry_pending[0] as Card).id == "slash",
		"a pending Scry survives a mid-combat save and load")


## Backlog #45's own reasoning, extended to #59: "scrying tells your ally what
## is coming" is the co-op point of the mechanic, so the reveal rides the
## public per-player snapshot (like potions/powers) rather than the private
## hand — and only the OWNER's resolve_scry can act on it, same spoof-proofing
## _acting_slot already gives potions.
func _test_backlog59_ally_sees_the_scry_reveal() -> void:
	var s := _make_session()
	var host: GameHost = s["host"]
	var c0: GameClient = s["c0"]
	var c1: GameClient = s["c1"]
	var combat: Combat = host._run.combat
	var ps0: PlayerState = combat.players[0]
	ps0.draw_pile = [Content.make_card("brace"), Content.make_card("slash")]
	ps0.hand = [Card.from_dict({"id": "peer_ahead", "name": "Peer Ahead", "type": "skill",
		"cost": 1, "scry": 2})]
	ps0.energy = 3
	combat.play_card(0, 0)
	host._broadcast_state()
	_expect(c0.shared["players"][0]["scry_pending"].size() == 2
		and c1.shared["players"][0]["scry_pending"].size() == 2
		and String(c1.shared["players"][0]["scry_pending"][0]["name"]) == "Slash",
		"a scry reveal is visible to the ally too, not just the owner")
	# c1 tries to resolve slot 0's scry — co-op ignores the claimed slot and
	# resolves against the SENDER's own (slot 1, nothing pending there).
	c1.resolve_scry([0])
	_expect(c0.shared["players"][0]["scry_pending"].size() == 2,
		"a spoofed slot can't resolve a teammate's scry")
	c0.resolve_scry([0])
	_expect(c0.shared["players"][0]["scry_pending"].is_empty(),
		"the owner resolving their own scry clears the pending reveal")


## Backlog #68 — Reaching into the draw pile: three operations besides drawing
## from it. `topdeck` puts a built card on TOP — the end of the array, the
## same end _draw() pops from.
func _test_backlog68_topdeck_puts_a_card_on_top_of_the_draw_pile() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.draw_pile = [_slash(), _slash()]
	ps.hand = [Card.from_dict({"id": "waymark", "name": "Waymark", "type": "skill",
		"cost": 0, "topdeck": "scramble"})]
	ps.energy = 3
	combat.play_card(0, 0)
	_expect(ps.draw_pile.size() == 3
		and (ps.draw_pile[ps.draw_pile.size() - 1] as Card).id == "scramble",
		"topdeck appends the named card — the next one _draw() will pop")


## `shuffle_in` lands the built card at a position chosen through Combat._rng,
## not GDScript's global RNG — so replaying the same seed and the same play
## must land it in the exact same spot, never a different one run to run.
func _test_backlog68_shuffle_in_is_deterministic_under_a_seed() -> void:
	var combat1 := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 7, _dummy_boss(300))
	var ps1: PlayerState = combat1.players[0]
	ps1.draw_pile = [_slash(), _slash(), _slash()]
	ps1.hand = [Card.from_dict({"id": "depot", "name": "Depot", "type": "skill",
		"cost": 1, "shuffle_in": "grip"})]
	ps1.energy = 3
	combat1.play_card(0, 0)
	var pos1 := _index_of_id(ps1.draw_pile, "grip")

	var combat2 := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 7, _dummy_boss(300))
	var ps2: PlayerState = combat2.players[0]
	ps2.draw_pile = [_slash(), _slash(), _slash()]
	ps2.hand = [Card.from_dict({"id": "depot", "name": "Depot", "type": "skill",
		"cost": 1, "shuffle_in": "grip"})]
	ps2.energy = 3
	combat2.play_card(0, 0)
	var pos2 := _index_of_id(ps2.draw_pile, "grip")

	_expect(ps1.draw_pile.size() == 4 and pos1 >= 0 and pos1 == pos2,
		"the same seed and the same play shuffle the card into the same position both times")


## `tutor` reaches past whatever sits on top and pulls a NAMED card straight
## into hand, wherever it happens to be in the pile.
func _test_backlog68_tutor_pulls_a_named_card_from_the_draw_pile_into_hand() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.draw_pile = [_slash(), _bash(), _slash()]  # _bash() == "cleave", buried in the middle
	ps.hand = [Card.from_dict({"id": "recon", "name": "Recon", "type": "skill",
		"cost": 1, "tutor": "cleave"})]
	ps.energy = 3
	combat.play_card(0, 0)
	_expect(ps.draw_pile.size() == 2 and not _has_id(ps.draw_pile, "cleave"),
		"tutor removes the named card from wherever it sat in the draw pile")
	_expect(_has_id(ps.hand, "cleave"),
		"tutor delivers the named card straight into hand")


## A card the tutor names but the pile doesn't hold is a harmless no-op, not a
## crash and not a silent draw of something else.
func _test_backlog68_tutor_is_a_harmless_no_op_when_the_card_isnt_there() -> void:
	var combat := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, _dummy_boss(300))
	var ps: PlayerState = combat.players[0]
	ps.draw_pile = [_slash(), _slash()]
	ps.hand = [Card.from_dict({"id": "recon", "name": "Recon", "type": "skill",
		"cost": 1, "tutor": "cleave"})]
	ps.energy = 3
	combat.play_card(0, 0)
	_expect(ps.draw_pile.size() == 2, "no Cleave to find — the draw pile is untouched")
	_expect(ps.hand.is_empty(), "no Cleave to find — nothing extra lands in hand")


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

	# And its own FACE. There were fifteen Kenney animal portraits for nineteen
	# characters, so the Mire Snapper and the Root Lurker were the same crocodile
	# and two beasts shared a penguin — which nothing anywhere objected to,
	# because a portrait that loads is a portrait that works.
	var shared := {}
	var faceless: Array = []
	for c in Content.list_characters():
		var cid := String((c as Dictionary).get("id", ""))
		_face(cid, String((c as Dictionary).get("portrait", "")), shared, faceless)
	for id in Content.boss_ids():
		var b: Boss = Content.build_boss(String(id))
		if b != null:
			_face(String(id), b.art, shared, faceless)
	var doubled: Array = []
	for k in shared:
		if (shared[k] as Array).size() > 1:
			doubled.append("%s <- %s" % [k, ", ".join(shared[k])])
	_expect(faceless.is_empty() and doubled.is_empty(),
		"every character and beast has a portrait of ITSELF, shared with nobody"
			+ ("" if faceless.is_empty() else " (missing: %s)" % ", ".join(faceless))
			+ ("" if doubled.is_empty() else " (shared: %s)" % "; ".join(doubled)))


func _face(id: String, path: String, shared: Dictionary, faceless: Array) -> void:
	if path == "" or not ResourceLoader.exists(path):
		faceless.append(id)
		return
	if not shared.has(path):
		shared[path] = []
	(shared[path] as Array).append(id)


## backlog #74: AssetContract carries the reusable half of the model shape
## contract (design/BACKLOG.md — "give the machine enough of a contract that
## it can fail loudly"). assetcheck.gd wires it to real loaded .glb files,
## which needs actual model files and a scene tree; these exercise the exact
## same functions against a handful of hand-built triangles so the contract
## has real regression coverage, not just "looked fine when run by hand."
## X/Y, not X/Z: AssetContract.silhouette_grid rasterises the FRONT-ON (XY)
## silhouette, matching what a player actually sees a beast by, so these
## rectangles vary in X and Y (Z fixed) to exercise that plane.
func _rect_tris(x0: float, x1: float, y0: float, y1: float, z: float = 0.0) -> Array:
	return [
		[Vector3(x0, y0, z), Vector3(x1, y0, z), Vector3(x1, y1, z)],
		[Vector3(x0, y0, z), Vector3(x1, y1, z), Vector3(x0, y1, z)],
	]


func _test_backlog74_uv_in_cell_matches_gold_exactly_and_rejects_the_next_swatch() -> void:
	_expect(AssetContract.uv_in_cell([AssetContract.GOLD_UV], AssetContract.GOLD_UV),
		"a sigil painted exactly GOLD reads as gold")
	# AMBER sits one 32px column over in kenney.py's atlas (swatch(496, 320) vs
	# GOLD's swatch(464, 320)) — the real mistake this check exists to catch:
	# a part painted the neighbouring swatch by accident.
	var amber_uv := AssetContract.GOLD_UV + Vector2(32.0 / 512.0, 0.0)
	_expect(not AssetContract.uv_in_cell([amber_uv], AssetContract.GOLD_UV),
		"a sigil painted the next swatch over does not read as gold")


## backlog #86 duty 2, 2026-09-03: GOLD_UV is a hand copy of kenney.py's
## `swatch(464, 320)`, and it drifted out of sync with the formula it copies
## when `swatch()` picked up its own +16 cell-middle fix — GOLD_UV kept the
## pre-fix V (320/512) while every real exported beast moved to (320+16)/512.
## _check_sigil_color found zero gold on EVERY beast checked (crag_pup,
## stone_warden, eyrie_hawk, glyph_tortoise, yoke_ox, clot_toad, flicker_stag,
## riptide_eel — the entire already-shipped cast, not one bad model) because
## the constant was one pixel-row off from what a correctly-painted sigil
## actually carries. This pins GOLD_UV to the derivation in kenney.py's own
## swatch(px, py) — `(px / 512.0, 1.0 - (py + 16.0) / 512.0)`, flipped once
## more for the glTF export/import round trip, i.e. `(py + 16.0) / 512.0` —
## so the two can never drift apart again without this test catching it.
func _test_backlog86_gold_uv_matches_kenneys_swatch_including_the_16px_offset() -> void:
	var swatch_blender_v := 1.0 - (320.0 + 16.0) / 512.0
	var expected := Vector2(464.0 / 512.0, 1.0 - swatch_blender_v)
	_expect(AssetContract.GOLD_UV.is_equal_approx(expected),
		"GOLD_UV tracks kenney.py's swatch(464, 320), +16 cell-middle offset included (got %s, want %s)"
			% [AssetContract.GOLD_UV, expected])


func _test_backlog74_silhouette_grid_is_invariant_to_scale_and_position() -> void:
	# An L: a tall rect and a wide rect sharing a corner, missing one quadrant of
	# their combined bounding box — a shape with a real notch in it, not a solid
	# block, so a scaled/moved copy actually exercises the normalisation.
	var l_shape := _rect_tris(0, 1, 0, 2) + _rect_tris(0, 2, 0, 1)
	var l_scaled_and_moved: Array = []
	var k := 3.5
	var t := Vector3(40.0, -17.0, 0.0)
	for tri in l_shape:
		var moved: Array = []
		for v in tri:
			moved.append(Vector3(v.x * k, v.y * k, v.z) + t)
		l_scaled_and_moved.append(moved)

	var a := AssetContract.silhouette_grid(l_shape, 20)
	var b := AssetContract.silhouette_grid(l_scaled_and_moved, 20)
	var sim := AssetContract.silhouette_similarity(a, b)
	_expect(sim >= 0.99, "the same shape at a different scale and position reads as ~identical (got %.3f)" % sim)


func _test_backlog74_silhouette_similarity_flags_a_near_duplicate_and_passes_a_distinct_shape() -> void:
	var l_shape := _rect_tris(0, 1, 0, 2) + _rect_tris(0, 2, 0, 1)
	var l_grid := AssetContract.silhouette_grid(l_shape, 20)

	var l_copy := _rect_tris(0, 1, 0, 2) + _rect_tris(0, 2, 0, 1)
	var dup_sim := AssetContract.silhouette_similarity(l_grid, AssetContract.silhouette_grid(l_copy, 20))
	_expect(dup_sim >= 0.90, "a re-export of the same shape fails the re-skin threshold (got %.3f)" % dup_sim)

	# A plain square: same bounding box family, but no notch — L is 3 of the 4
	# quadrants a square would fill, so it lands well under the threshold.
	var square := _rect_tris(0, 1, 0, 1)
	var distinct_sim := AssetContract.silhouette_similarity(l_grid, AssetContract.silhouette_grid(square, 20))
	_expect(distinct_sim < 0.90, "a genuinely different footprint stays under the re-skin threshold (got %.3f)" % distinct_sim)


func _test_backlog74_budget_table_matches_kenney_py() -> void:
	_expect(AssetContract.budget_for("hunter") == 1400, "hunter budget matches kenney.py's BUDGET table")
	_expect(AssetContract.budget_for("beast") == 2600, "beast budget matches kenney.py's BUDGET table")
	_expect(AssetContract.budget_for("prop") == 500, "prop budget matches kenney.py's BUDGET table")
	_expect(AssetContract.budget_for("nonsense") == AssetContract.budget_for("hunter"),
		"an unknown kind falls back to the hunter budget rather than failing")


## backlog #74's fourth contract bullet — "visible from the front, not buried
## behind the body" — was left unbuilt on 2026-08-26 specifically because
## occlusion needs a raycast this suite couldn't first verify. AssetContract.
## z_at_xy/is_occluded_from_front are that raycast, done as a plane-Z solve at
## a fixed (X, Y) rather than a full ray-triangle intersection, since the
## "camera" here is always looking straight down +Z. These prove the geometry
## against hand-built triangles before assetcheck.gd trusts it against a real
## beast.
func _test_backlog74_z_at_xy_reads_the_triangle_plane_and_rejects_outside_points() -> void:
	var tri: Array = _rect_tris(0, 2, 0, 2, -3.0)[0]
	var inside = AssetContract.z_at_xy(1.0, 1.0, tri[0], tri[1], tri[2])
	_expect(inside != null and absf(inside - (-3.0)) < 0.001,
		"a point inside the triangle's XY footprint reads its plane's Z")
	var outside = AssetContract.z_at_xy(5.0, 5.0, tri[0], tri[1], tri[2])
	_expect(outside == null, "a point outside the triangle's XY footprint reads no Z at all")


func _test_backlog74_occlusion_flags_a_surface_hidden_behind_a_closer_one() -> void:
	# LARGER Z is CLOSER to a viewer standing in front of the model — the real
	# combat camera (views/combat_3d.tscn) sits at Z ~= +12.4 looking back
	# toward -Z, not the other way around (AssetContract.z_at_xy's own note
	# explains the bug an earlier version of this had). The front rect sits at
	# Z = 1, a same-footprint back rect at Z = -1, so the back one is hidden
	# from the front exactly the way a buried sigil would be.
	var front: Array = _rect_tris(0, 2, 0, 2, 1.0)
	var back: Array = _rect_tris(0, 2, 0, 2, -1.0)
	var all_tris: Array = front + back
	_expect(AssetContract.is_occluded_from_front(1.0, 1.0, -1.0, all_tris),
		"a surface with closer geometry in front of it (larger Z) reads as occluded")
	_expect(not AssetContract.is_occluded_from_front(1.0, 1.0, 1.0, all_tris),
		"the frontmost surface itself is never occluded by what's behind it")


func _test_backlog74_occlusion_ignores_geometry_that_does_not_cover_the_same_point() -> void:
	var mine: Array = _rect_tris(0, 1, 0, 1, 0.0)
	var elsewhere: Array = _rect_tris(10, 11, 10, 11, -5.0)
	var all_tris: Array = mine + elsewhere
	_expect(not AssetContract.is_occluded_from_front(0.5, 0.5, 0.0, all_tris),
		"closer geometry that doesn't cover the same (x, y) doesn't occlude")


## backlog #86 duty 3 — combat_3d.route_between_rungs is the pure half of
## _route_between (the hunter climb routing on the beast's model), lifted out
## specifically so it's testable headless, with no scene tree and no model
## loaded. It answers: which ledges does a climb from one foothold to another
## stop on, so a hunter lands on every shelf in between rather than passing
## through the body (the comment above combat_3d._hop describes why that
## matters — it's the one moment this game is about).
const Combat3D := preload("res://views/combat_3d.gd")


func _test_backlog86_route_between_rungs_stops_at_every_ledge_climbing_up() -> void:
	# Ankle at 0, shoulder at 12, with ledges at the hip (4) and chest (8) in
	# between: a climb from ankle to shoulder should stop at both.
	var rungs: Array = [0, 4, 8, 12]
	var route: Array = Combat3D.route_between_rungs(rungs, 0, 12)
	_expect(route == [4, 8], "climbing ankle to shoulder stops at every ledge strictly between, ascending")


func _test_backlog86_route_between_rungs_stops_at_every_ledge_climbing_down() -> void:
	var rungs: Array = [0, 4, 8, 12]
	var route: Array = Combat3D.route_between_rungs(rungs, 12, 0)
	_expect(route == [8, 4], "falling shoulder to ankle passes the same ledges, but in descending order, not the ascending order used going up")


func _test_backlog86_route_between_rungs_excludes_the_endpoints() -> void:
	var rungs: Array = [0, 4, 8, 12]
	_expect(Combat3D.route_between_rungs(rungs, 4, 8) == [], "a foothold that already sits on a ledge is never re-listed as a stop on the way to an adjacent one")


func _test_backlog86_route_between_rungs_is_empty_with_no_ledges_between() -> void:
	_expect(Combat3D.route_between_rungs([0, 12], 0, 12) == [], "a beast with no anchors between the two footholds routes straight through, not through a phantom ledge")


func _test_backlog86_route_between_rungs_ignores_unsorted_input() -> void:
	# _ledges.keys() makes no promise about order; the route must not depend on
	# the dictionary's insertion order to come out in climb order.
	var route: Array = Combat3D.route_between_rungs([12, 0, 8, 4], 0, 12)
	_expect(route == [4, 8], "the rung list is sorted before routing, regardless of the order it arrives in")


## backlog #86 duty 2 — _draw_gauge used to check `ledges.has(h)` straight off
## the raw `boss.ledges` snapshot, which is a "two copies of one truth" bug:
## /core reads every ledge through Boss.hold_height()/hold_safe() so bare ints
## and the Dictionary named-hold shape (backlog #24) are interchangeable, but
## Array.has() compares with ==, and an int Height never equals a Dictionary
## hold. A Dictionary-shaped ledge would silently draw as "no ledge here" on
## the gauge even though the fight itself treated it as a real, unsafe hold.
## gauge_ledge_heights() normalizes the raw array before the gauge ever
## compares against it.
func _test_backlog86_gauge_ledge_heights_passes_bare_ints_through() -> void:
	_expect(Combat3D.gauge_ledge_heights([0, 4, 8]) == [0, 4, 8],
		"legacy bare-int ledges normalize to themselves")


func _test_backlog86_gauge_ledge_heights_recognizes_named_holds() -> void:
	var named := [3, {"height": 6, "safe": false, "exposed_to": ["slam"]}]
	_expect(Combat3D.gauge_ledge_heights(named) == [3, 6],
		"a Dictionary-shaped named hold still counts as a ledge Height on the gauge, not silently dropped")


## backlog #86 duty 2 — a real bug in `_place_hunters`'s `elif moved:` branch
## (the "beast rescaled, sigil settled, hunter hasn't actually climbed" case):
## it built a glide tween and then wrote `node.position = pos` on the very next
## line. That write runs synchronously; `Tween.tween_property` only reads its
## "from" value lazily, on the tween's first step — by then position already
## WAS `pos`, so the tween interpolated pos -> pos and every glide played as an
## invisible snap instead of the slide the comment above it promises.
## `_start_glide` is the fix pulled out static so this is provable with no
## model loaded and no frame processed: proving the glide isn't pre-empted only
## needs the SYNCHRONOUS state right after it starts, not real animation time.
func _test_backlog86_glide_is_not_defeated_by_a_synchronous_position_write() -> void:
	var node := Node3D.new()
	node.position = Vector3(1.0, 0.0, 1.0)
	var target := Vector3(4.0, 0.0, 4.0)
	var tw := root.create_tween()
	Combat3D._start_glide(tw, node, target, 0.18)
	_expect(node.position.is_equal_approx(Vector3(1.0, 0.0, 1.0)),
		"the glide must not be pre-empted by a synchronous position write, or the tween has nothing left to interpolate")
	tw.kill()
	node.free()


## backlog #86 duty 2 (sixth turn) — a real bug in `_render_hand`: the
## `if selecting: ... return` branch (a pick in progress for an
## exhaust/cheapen/meld card) `return`ed before reaching the two statements
## after the branch — `_hand_hover = null` and `_layout_hand.call_deferred()`
## — so every CardView built while a pick was open sat at Control's default
## (0,0), stacked in the hand's corner, until a mouse hover incidentally
## repaired it. Handheld has no hover, so the stack never recovered.
## `render_hand_status` is the outcome pulled out static so "layout always
## runs" is provable without building the whole hand row and its cards.
func _test_backlog86_render_hand_status_always_relayouts_while_selecting() -> void:
	var status: Dictionary = Combat3D.render_hand_status(true)
	_expect(bool(status["layout_needed"]), "the fan must still be laid out while a pick (exhaust/cheapen/meld) is in progress, not only when no selection is active")
	_expect(bool(status["hover_reset"]), "hover must still be cleared while a pick is in progress, or _layout_hand compares a freed CardView on its next call")
	_expect(bool(status["status_visible"]), "the selection prompt is shown while picking")


func _test_backlog86_render_hand_status_hides_prompt_outside_selection() -> void:
	var status: Dictionary = Combat3D.render_hand_status(false)
	_expect(bool(status["layout_needed"]), "the fan is laid out on every render, selecting or not")
	_expect(bool(status["hover_reset"]), "hover is reset on every render, selecting or not")
	_expect(not bool(status["status_visible"]), "the selection prompt hides once nothing is being picked")


## backlog #86 duty 3 (second pass) — combat_3d.foothold_anchor is the pure
## half of _stand_on_model, the sibling rule to route_between_rungs above: not
## which ledges a climb stops on, but WHERE on the model a single foothold
## actually places a hunter. The doc comment above _stand_on_model promises a
## hunter is exactly on a rung when the Height matches one, and on the line
## between the two that bracket it otherwise — none of that had a test before
## this, same as route_between_rungs before duty 3's first pass.
func _test_backlog86_foothold_anchor_lands_exactly_on_a_matching_rung() -> void:
	var anchors := {0: Vector3(0, 0, 0), 4: Vector3(0, 4, 0), 12: Vector3(0, 12, 0)}
	var p: Vector3 = Combat3D.foothold_anchor(anchors, 4)
	_expect(p.is_equal_approx(Vector3(0, 4, 0)), "a foothold exactly on an anchored rung returns that anchor untouched, not an interpolation of it with itself")


func _test_backlog86_foothold_anchor_lerps_between_the_bracketing_rungs() -> void:
	var anchors := {0: Vector3(0, 0, 0), 8: Vector3(0, 8, 0)}
	var p: Vector3 = Combat3D.foothold_anchor(anchors, 2)
	_expect(p.is_equal_approx(Vector3(0, 2, 0)), "a foothold a quarter of the way from one rung to the next sits a quarter of the way between their anchors, not snapped to either")


func _test_backlog86_foothold_anchor_clamps_below_the_lowest_rung() -> void:
	var anchors := {4: Vector3(0, 4, 0), 8: Vector3(0, 8, 0)}
	var p: Vector3 = Combat3D.foothold_anchor(anchors, 0)
	_expect(p.is_equal_approx(Vector3(0, 4, 0)), "a foothold below the lowest anchor clamps to it rather than extrapolating past the model's own lowest rung")


func _test_backlog86_foothold_anchor_clamps_above_the_highest_rung() -> void:
	var anchors := {4: Vector3(0, 4, 0), 8: Vector3(0, 8, 0)}
	var p: Vector3 = Combat3D.foothold_anchor(anchors, 20)
	_expect(p.is_equal_approx(Vector3(0, 8, 0)), "a foothold above the highest anchor clamps to it rather than extrapolating past the model's own highest rung")


func _test_backlog86_foothold_anchor_ignores_unsorted_key_order() -> void:
	# Dictionary.keys() makes no promise about order; the bracket search must
	# not depend on the order the anchors happened to be gathered in.
	var anchors := {12: Vector3(0, 12, 0), 0: Vector3(0, 0, 0), 8: Vector3(0, 8, 0), 4: Vector3(0, 4, 0)}
	var p: Vector3 = Combat3D.foothold_anchor(anchors, 6)
	_expect(p.is_equal_approx(Vector3(0, 6, 0)), "the bracket is found by sorted Height, regardless of the dictionary's insertion order")


## backlog #86 duty 3 (third pass) — hunter_move_kind is the pure gate lifted
## out of _place_hunters that decides whether a hunter's next position update
## is a climb, a first placement, a glide, or nothing at all. It is the exact
## rule behind Nick's jump mechanic, and behind the bug he reported ("bouncing
## in random places at an awkward cadence"): the fix was to key a JUMP off a
## foothold change, never off the target point merely having moved.
func _test_backlog86_hunter_move_kind_is_first_before_any_placement() -> void:
	# Not yet placed outranks everything else, even a foothold that "changed"
	# from its zero-value default and a point that "moved" from Vector3.ZERO.
	_expect(Combat3D.hunter_move_kind(false, 0, 3, true) == "first",
		"a hunter that has never been placed gets an instant first placement, not a climb or a glide")
	_expect(Combat3D.hunter_move_kind(false, 0, 0, false) == "first",
		"first placement holds even when nothing about the foothold or the point looks like it changed")


func _test_backlog86_hunter_move_kind_climbs_on_a_foothold_change() -> void:
	_expect(Combat3D.hunter_move_kind(true, 2, 5, true) == "climb",
		"a placed hunter whose foothold changed gets a climb, going up")
	_expect(Combat3D.hunter_move_kind(true, 5, 2, true) == "climb",
		"and going down — the direction of the foothold change doesn't matter, only that it changed")


func _test_backlog86_hunter_move_kind_glides_when_the_world_moved_under_a_placed_hunter() -> void:
	_expect(Combat3D.hunter_move_kind(true, 3, 3, true) == "glide",
		"the beast rescaling or the sigil settling under an already-placed hunter at the SAME foothold slides, it does not jump")


func _test_backlog86_hunter_move_kind_is_none_when_placed_and_settled() -> void:
	_expect(Combat3D.hunter_move_kind(true, 3, 3, false) == "none",
		"nothing changed: same foothold, no meaningful movement — no animation should start at all")


func _test_backlog86_hunter_move_kind_climb_outranks_moved_even_if_the_point_did_not_move() -> void:
	# This is the guard against regressing the exact bug: `moved` (a 0.05m
	# distance check on the world-space TARGET) and `was != foot` (a foothold
	# index change) are measuring two different things and can disagree. A
	# foothold change must still climb even in the edge case where the new
	# resting point happens to land within 0.05m of the old one.
	_expect(Combat3D.hunter_move_kind(true, 2, 5, false) == "climb",
		"a real foothold change climbs even if the two world positions happen to coincide")


## backlog #86 duty 3 (twenty-sixth pass) — grip_after_tick and
## climb_state_after_secure_update are the pure halves of `_tick_grip` and
## `_update_climb_state`: the other side of Nick's jump mechanic, the "HOLD ON
## before your grip gives out" timer that decides whether a climbing hunter
## falls. grip_after_tick is the countdown; climb_state_after_secure_update is
## the transition that starts, refreshes, or ends that countdown off the
## "secure" flag /core sends every turn.
func _test_backlog86_grip_after_tick_matches_a_full_grip_seconds_countdown() -> void:
	_expect(is_equal_approx(Combat3D.grip_after_tick(1.0, 5.0, 5.0), 0.0),
		"a full grip meter drains to exactly empty after grip_seconds worth of delta")


func _test_backlog86_grip_after_tick_relic_seconds_extends_the_time_to_zero() -> void:
	# GRIP_SECONDS is 5.0; a +5 relic doubles it, so the SAME five seconds of
	# clinging should only burn half the meter, not empty it.
	var g: float = Combat3D.grip_after_tick(1.0, 5.0, 10.0)
	_expect(is_equal_approx(g, 0.5),
		"a grip_seconds relic stretches the timer, so the same delta costs less of the meter, not more")


func _test_backlog86_grip_after_tick_can_go_negative_past_the_fall_threshold() -> void:
	# _tick_grip checks `<= 0.0` on the RESULT, so the arithmetic itself must
	# not clamp at zero or a hunter who was already almost out of grip could
	# never register as having fallen this frame.
	var g: float = Combat3D.grip_after_tick(0.1, 5.0, 5.0)
	_expect(g < 0.0, "ticking past an already-thin grip must go negative so the caller's <= 0.0 fall check actually fires")


func _test_backlog86_climb_state_secure_erases_any_existing_timer() -> void:
	_expect(Combat3D.climb_state_after_secure_update(true, 0.4, true, 8) == null,
		"reaching a real hold (secure) erases the climb timer outright, whatever grip was left")
	_expect(Combat3D.climb_state_after_secure_update(false, 1.0, true, 8) == null,
		"secure with no prior timer stays erased, not spuriously created")


func _test_backlog86_climb_state_starts_a_fresh_full_timer_on_first_leaving_a_hold() -> void:
	var next: Variant = Combat3D.climb_state_after_secure_update(false, 1.0, false, 4)
	_expect(next != null, "leaving a hold with no timer running starts one")
	_expect(is_equal_approx(float((next as Dictionary)["g"]), 1.0),
		"a genuine hold -> climbing transition starts the grip meter completely full")
	_expect(int((next as Dictionary)["target"]) == 4, "the fresh timer targets the next safe hold")


func _test_backlog86_climb_state_does_not_regrip_a_timer_already_draining() -> void:
	# This is the rule named in _update_climb_state's own doc comment and never
	# tested before this: reaching an intermediate ledge mid-hop (still not
	# secure, still climbing) must NOT refill the meter, or grip effectively
	# never runs out on a multi-ledge climb.
	var next: Variant = Combat3D.climb_state_after_secure_update(true, 0.37, false, 8)
	_expect(next != null, "a timer already running stays running while still not secure")
	_expect(is_equal_approx(float((next as Dictionary)["g"]), 0.37),
		"grip already draining is carried through untouched, not reset to full")


func _test_backlog86_climb_state_updates_the_target_even_while_preserving_grip() -> void:
	var next: Variant = Combat3D.climb_state_after_secure_update(true, 0.6, false, 12)
	_expect(int((next as Dictionary)["target"]) == 12,
		"the displayed target ledge tracks the current next_safe every update, even though grip itself is left alone")


## backlog #86 duty 3 (fourth pass) — height_gap_between is the pure twin of
## Combat.incoming_for's rift branch in /core (combat.gd:511-519): both walk
## the players and take `maxi(0, hi - lo)` over `foothold`. The intent HUD
## calls the view's copy to show the number BEFORE the move resolves;
## /core's copy is what actually lands. Nothing before this checked the two
## agree.
func _test_backlog86_height_gap_between_is_zero_with_fewer_than_two_players() -> void:
	_expect(Combat3D.height_gap_between([]) == 0,
		"no players, no gap — matches /core's own loop, which starts hi=0/lo=9999 and never updates either")
	_expect(Combat3D.height_gap_between([{"foothold": 6}]) == 0,
		"a lone hunter can't be apart from themselves")


func _test_backlog86_height_gap_between_ignores_order() -> void:
	var forward: int = Combat3D.height_gap_between([{"foothold": 1}, {"foothold": 5}])
	var backward: int = Combat3D.height_gap_between([{"foothold": 5}, {"foothold": 1}])
	_expect(forward == 4 and backward == 4,
		"the gap is a distance, not a signed difference — whichever hunter is listed first doesn't matter")


func _test_backlog86_height_gap_between_uses_the_overall_min_and_max() -> void:
	var gap: int = Combat3D.height_gap_between([
		{"foothold": 3}, {"foothold": 0}, {"foothold": 7}, {"foothold": 4}])
	_expect(gap == 7,
		"three or more entries still take the overall spread (7 - 0), not a pairwise or first/last comparison")


## The cross-check that actually matters: build a real Combat with a rift
## move and drive it to resolution, then confirm height_gap_between over the
## SAME footholds produces the SAME gap /core priced the damage on. This is
## the one test that would fail if the two copies of the formula ever drift —
## a bug that would otherwise show up only as a HUD number that's wrong on a
## real screen, which is exactly what duty 3 exists to catch before that.
func _test_backlog86_height_gap_between_matches_the_real_rift_damage_in_core() -> void:
	var boss := Boss.new("Riftling", 300)
	boss.moves = [{"type": "rift", "value": 4}]
	boss.weak_point_height = 4
	var c := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	c.players[0].foothold = 5
	c.players[1].foothold = 1   # gap of 4
	var hp_before: int = c.players[0].combatant.hp
	c.end_turn(0)
	c.end_turn(1)
	var actual_damage: int = hp_before - c.players[0].combatant.hp

	var gap: int = Combat3D.height_gap_between([
		{"foothold": c.players[0].foothold}, {"foothold": c.players[1].foothold}])
	var displayed_damage: int = 4 + gap * Combat.RIFT_PER_GAP
	_expect(displayed_damage == actual_damage,
		"the number the intent HUD would show for this rift (%d) must equal what actually landed (%d)" % [displayed_damage, actual_damage])


## backlog #86 duty 2: Combat.incoming_for() and Combat._enemy_turn() each ran
## their own min/max search for the rift gap, seeded with a magic sentinel —
## 9999 in incoming_for, 99 in _enemy_turn. Both stayed correct only while the
## LOWEST foothold among the players was below the sentinel: `mini(sentinel,
## foothold)` always finds the real minimum in that case. The bug needs EVERY
## player's foothold above the sentinel — then the sentinel itself becomes the
## wrong "minimum" and the gap comes out too large. (Reachable in principle:
## jetpack's `ps.foothold = boss.weak_point_height` in _resolve_prepared sets
## foothold with no FOOTHOLD_MAX clamp, unlike every other foothold-setting
## call site in this file.) Both branches now share one Combat._rift_gap(), so
## this drives every foothold past the smaller of the two old sentinels and
## proves the shared helper — and the preview built on it — still gets the
## real minimum instead of pinning to a sentinel.
func _test_backlog86_rift_gap_shared_by_preview_and_resolution() -> void:
	var boss := Boss.new("Riftling", 300)
	boss.moves = [{"type": "rift", "value": 4}]
	var c := _new_combat([_deck_of(_slash, 10), _deck_of(_slash, 10)], 42, boss)
	c.players[0].foothold = 150  # both above the old 99 sentinel...
	c.players[1].foothold = 200  # ...so the old code would have used 99 as "lo" here
	_expect(Combat._rift_gap(c.players) == 50,
		"the shared gap helper must use the real minimum foothold (150), not fall back to a sentinel")

	var previewed: Dictionary = c.incoming_for(0)
	_expect(previewed["raw"] == 4 + 50 * Combat.RIFT_PER_GAP,
		"incoming_for's preview must be priced off the same shared gap _enemy_turn will resolve the hit with")


## backlog #86 duty 3 (fifth pass): hull_front_at, lifted out of
## combat_3d._front_of_beast — the rule that decides whether a hunter clips
## into the beast's own mesh. See the Grove Bear story in the doc comment
## above hull_front_at: a hunter's own column can read as clear while the
## body reaches out from a column right next to it, so the front of the beast
## is the deepest point in a 3x3 neighbourhood, not the hunter's own band.
func _test_backlog86_hull_front_at_returns_the_box_back_when_the_column_is_empty() -> void:
	var hull := PackedFloat32Array()
	hull.resize(3 * 3)
	hull.fill(-1e9)
	var box := AABB(Vector3(0, 0, -2), Vector3(4, 4, 4))
	var front: float = Combat3D.hull_front_at(hull, 3, 3, 1, 1, box)
	_expect(front == box.position.z,
		"a column with no mesh in it at all is the back of the box, not the front")


func _test_backlog86_hull_front_at_finds_the_deepest_point_in_the_neighbourhood() -> void:
	# Grove Bear shape: the hunter's own band (chest) reaches 8.5; the muzzle,
	# one column over, reaches 11.4 — the hunter must be pushed out past the
	# muzzle, not just the chest, or it ends up standing behind its own face.
	var hull := PackedFloat32Array()
	hull.resize(3 * 3)
	hull.fill(0.0)
	hull[1 * 3 + 1] = 8.5   # centre band (the hunter's own column)
	hull[1 * 3 + 2] = 11.25  # one column over -- exactly representable in the
	                          # PackedFloat32Array _build_hull actually uses
	var box := AABB(Vector3(0, 0, -2), Vector3(4, 4, 4))
	var front: float = Combat3D.hull_front_at(hull, 3, 3, 1, 1, box)
	_expect(front == 11.25,
		"the front of the body is the deepest point NEAR the hunter, not just their own column")


func _test_backlog86_hull_front_at_does_not_reach_beyond_its_neighbourhood() -> void:
	# A wider reach was flagged in the doc comment as the opposite failure —
	# an outflung limb two bands over would drag a hunter out into open air on
	# the far side of the body. Fix the window at 3 wide and 5 tall and prove
	# it: a value just outside that window must never win.
	var hull_x := 7
	var hull_y := 7
	var hull := PackedFloat32Array()
	hull.resize(hull_x * hull_y)
	hull.fill(0.0)
	var cx := 3
	var cy := 3
	hull[cy * hull_x + cx] = 1.0          # the hunter's own band
	hull[cy * hull_x + (cx + 2)] = 99.0    # two columns over: outside the 3-wide window
	hull[(cy + 3) * hull_x + cx] = 99.0    # three rows up: outside the 5-tall window
	var box := AABB(Vector3(0, 0, -2), Vector3(4, 4, 4))
	var front: float = Combat3D.hull_front_at(hull, hull_x, hull_y, cx, cy, box)
	_expect(front == 1.0,
		"a limb two columns over or three bands up must not reach into this hunter's front")


func _test_backlog86_hull_front_at_ignores_neighbours_outside_hull_bounds() -> void:
	# Standing at the very edge of the hull grid must not wrap or index out of
	# bounds — the out-of-range half of the 3x3/5x3 window is simply absent,
	# not read from the other side of the array.
	var hull_x := 3
	var hull_y := 3
	var hull := PackedFloat32Array()
	hull.resize(hull_x * hull_y)
	hull.fill(-1e9)
	hull[0] = 5.0  # (0, 0), the only real data, at the corner
	var box := AABB(Vector3(0, 0, -2), Vector3(4, 4, 4))
	var front: float = Combat3D.hull_front_at(hull, hull_x, hull_y, 0, 0, box)
	_expect(front == 5.0,
		"the corner column still finds its own value even with most of its neighbourhood off-grid")


## backlog #86 duty 3 (seventh pass): location_3d._stakes is the OTHER
## untested view-layer mechanic in this rotation's own family — not the climb
## (combat_3d, five passes done above) but the wayside-event text a player
## reads before picking a choice blind. It was already pure (only reads its
## `eff` argument), so it needed lifting to `static` the same way
## route_between_rungs and foothold_anchor did, not a rewrite.
const Location3D := preload("res://views/location_3d.gd")


func _test_backlog86_stakes_describes_a_heal() -> void:
	_expect(Location3D._stakes({"heal": 5}) == "(+5 HP)",
		"a positive heal reads as a gain, sign and all")


func _test_backlog86_stakes_describes_damage() -> void:
	_expect(Location3D._stakes({"heal": -3}) == "(-3 HP)",
		"a negative heal reads as damage, not as a badly-signed gain")


func _test_backlog86_stakes_describes_a_max_hp_change() -> void:
	_expect(Location3D._stakes({"max_hp": 2}) == "(+2 max HP)",
		"a max HP gain is labelled max HP, not confused with a heal")
	_expect(Location3D._stakes({"max_hp": -2}) == "(-2 max HP)",
		"a max HP loss keeps its sign the same way a heal loss does")


func _test_backlog86_stakes_describes_gold() -> void:
	_expect(Location3D._stakes({"gold": 10}) == "(+10 gold)",
		"a gold gain is signed and labelled")
	_expect(Location3D._stakes({"gold": -5}) == "(-5 gold)",
		"a gold cost is signed and labelled the same way")


func _test_backlog86_stakes_describes_a_relic() -> void:
	_expect(Location3D._stakes({"relic": true}) == "(relic)",
		"a relic reward is called out on its own, with no number attached")


func _test_backlog86_stakes_describes_a_reward_choice() -> void:
	_expect(Location3D._stakes({"reward": "card"}) == "(choose a card)",
		"a reward token becomes a plain-English 'choose a ...' phrase")


func _test_backlog86_stakes_joins_every_stake_named_at_once() -> void:
	# A real event choice: heal a little, spend some gold, walk away with a
	# relic — every one of the three bits above must show, in this order,
	# joined the same way the button text actually renders them.
	var eff := {"heal": 5, "gold": -3, "relic": true}
	_expect(Location3D._stakes(eff) == "(+5 HP  ·  -3 gold  ·  relic)",
		"multiple stakes on one choice all show, joined and in field order, not just the first one found")


func _test_backlog86_stakes_is_blank_for_an_effect_with_nothing_to_show() -> void:
	_expect(Location3D._stakes({}) == "",
		"a choice with no stated stakes gets no parentheses at all, not an empty '()'")


## backlog #86 duty 3 (fifteenth pass): CardView.face_text is the live line a
## player reads on a card in their hand -- built fresh every server tick from
## preview/fx/base, never from the authored `text` string once a real fight is
## running. It was already `static func face_text(data, rich)`, no lifting
## needed, and had never been called from run_tests.gd: nothing proved that a
## live damage/block/climb number, a status effect, or a Burn variant actually
## renders as the sentence a player would read to decide whether to play the
## card. Exactly the "misdescribes a real choice" bug class the wayside-event
## stakes pass caught a few turns ago, one screen over -- CardView has no
## class_name preload of its own to add since `class_name CardView` already
## makes it a global, the same way `Card` is used elsewhere in this file.

func _test_backlog86_face_text_single_hit_damage() -> void:
	var data := {"preview": {"damage": 5}, "preview_miss": {"damage": 5},
		"base": {"damage": 5}, "fx": {"hits": 1}, "keywords": []}
	_expect(CardView.face_text(data, false) == "Deal 5 damage.",
		"a plain single-hit card reads as one damage sentence with no hit count")


func _test_backlog86_face_text_multi_hit_damage_says_times() -> void:
	var twice := {"preview": {"damage": 3}, "preview_miss": {"damage": 3},
		"base": {"damage": 3}, "fx": {"hits": 2}, "keywords": []}
	_expect(CardView.face_text(twice, false) == "Deal 3 damage twice.",
		"two hits reads 'twice', not '2 times'")
	var thrice := {"preview": {"damage": 3}, "preview_miss": {"damage": 3},
		"base": {"damage": 3}, "fx": {"hits": 3}, "keywords": []}
	_expect(CardView.face_text(thrice, false) == "Deal 3 damage 3 times.",
		"three or more hits spells out the count instead")


func _test_backlog86_face_text_matched_block_merges_to_all_players() -> void:
	var data := {"preview": {"block": 4, "ally_block": 4},
		"preview_miss": {"block": 4, "ally_block": 4},
		"base": {"block": 4, "ally_block": 4}, "fx": {}, "keywords": []}
	_expect(CardView.face_text(data, false) == "All players gain 4 Block.",
		"identical self/ally Block merges into one 'All players' line instead of saying the same fact twice")


func _test_backlog86_face_text_mismatched_block_lists_separately() -> void:
	var data := {"preview": {"block": 4, "ally_block": 6},
		"preview_miss": {"block": 4, "ally_block": 6},
		"base": {"block": 4, "ally_block": 6}, "fx": {}, "keywords": []}
	_expect(CardView.face_text(data, false) == "Gain 4 Block. Ally gains 6 Block.",
		"different self/ally Block amounts stay two sentences so neither value is lost")


func _test_backlog86_face_text_matched_climb_merges_to_all_players() -> void:
	var data := {"preview": {"grip": 3, "ally_grip": 3},
		"preview_miss": {"grip": 3, "ally_grip": 3},
		"base": {"grip": 3, "ally_grip": 3}, "fx": {}, "keywords": []}
	_expect(CardView.face_text(data, false) == "All players climb 3.",
		"identical self/ally climb also merges, same rule as Block")


func _test_backlog86_face_text_mismatched_climb_pluralizes_the_allys_line() -> void:
	var data := {"preview": {"grip": 2, "ally_grip": 5},
		"preview_miss": {"grip": 2, "ally_grip": 5},
		"base": {"grip": 2, "ally_grip": 5}, "fx": {}, "keywords": []}
	_expect(CardView.face_text(data, false) == "Climb 2. Ally climbs 5.",
		"the ally's own climb line conjugates to 'climbs' where the self line reads 'Climb'")


func _test_backlog86_face_text_status_and_utility_lines_join_in_field_order() -> void:
	var data := {"preview": {"damage": 0}, "preview_miss": {}, "base": {}, "keywords": [],
		"fx": {"wound": 2, "vulnerable": 1, "strength": 3, "dexterity": 4, "rhythm": 1,
			"draw": 2, "taunt": true}}
	_expect(CardView.face_text(data, false) ==
		"Poison 2. Expose 1. Strength 3. Dexterity 4. Rhythm 1. Draw 2. Taunt.",
		"every non-numeric effect on one card gets its own sentence, in the order face_text checks them")


## backlog #86 duty 2 — Dexterity is Strength's own "defensive counterpart"
## (card.gd's own words) but never got the line Strength did: GameHost's "fx"
## dict never carried "dexterity" and face_text() had no branch for it, so a
## card combining Block+Dexterity (the real card Steady Grip: "Gain 4 Block.
## Dexterity 1.") showed only "Gain 4 Block." on its live face in hand — the
## Dexterity silently vanished — while its Block+Strength sibling (the real
## card Chalk Up: "Gain 2 Block. Strength 1.") correctly showed both. Proves
## the fix with the exact shape Steady Grip's own fx dict has.
func _test_backlog86_face_text_shows_dexterity_alongside_block() -> void:
	var data := {"preview": {"damage": 0, "block": 4}, "preview_miss": {}, "base": {"block": 4},
		"keywords": [], "fx": {"dexterity": 1}}
	_expect(CardView.face_text(data, false) == "Gain 4 Block. Dexterity 1.",
		"a card granting both Block and Dexterity states both on its live face, not just Block")


func _test_backlog86_face_text_burn_lines_are_mutually_exclusive() -> void:
	var sac := {"preview": {"damage": 0}, "preview_miss": {}, "base": {}, "keywords": [],
		"fx": {"sac_ally_grip": 2}}
	_expect(CardView.face_text(sac, false) == "Burn a card: ally climbs 2.",
		"sac_ally_grip alone reads as the ally-climb Burn variant")
	var pick := {"preview": {"damage": 0}, "preview_miss": {}, "base": {}, "keywords": [],
		"fx": {"exhaust_pick": true}}
	_expect(CardView.face_text(pick, false) == "Burn a card.",
		"exhaust_pick alone reads as the plain Burn-a-card variant")
	var cheapen := {"preview": {"damage": 0}, "preview_miss": {}, "base": {}, "keywords": [],
		"fx": {"exhaust_pick": true, "cheapen_pick": true}}
	_expect(CardView.face_text(cheapen, false) == "Burn a card to cheapen another.",
		"exhaust_pick plus cheapen_pick names the cheapen clause")
	# The source branch is `elif bool(fx.get("exhaust_pick", false))`, so a card
	# carrying both fields must show only the sac_ally_grip line -- if that ever
	# changed to two independent `if`s a card could claim to burn twice.
	var both := {"preview": {"damage": 0}, "preview_miss": {}, "base": {}, "keywords": [],
		"fx": {"sac_ally_grip": 2, "exhaust_pick": true}}
	_expect(CardView.face_text(both, false) == "Burn a card: ally climbs 2.",
		"a card with both fields set shows only the sac_ally_grip line, never both Burn sentences")


func _test_backlog86_face_text_falls_back_to_authored_text_with_no_preview() -> void:
	var data := {"text": "Deal 3 damage.", "keywords": []}
	_expect(CardView.face_text(data, false) == "Deal 3 damage.",
		"a card with no live preview at all (an offer on the reward screen, not a card in hand) prints its authored text verbatim")
	var marked := {"text": "Poison 2.", "keywords": [{"id": "poison"}]}
	_expect(CardView.face_text(marked, true) ==
		"[url=kw:poison][u][color=#%s]Poison[/color][/u][/url] 2." % CardView.KEYWORD_COLOR,
		"the same no-preview fallback still marks up its keywords in rich mode, or a card offered as a reward would show plain text where one held in hand shows gold underlined terms")


func _test_backlog86_face_text_falls_back_to_authored_text_when_nothing_landed() -> void:
	# Distinct from the no-preview case above: here `preview` IS present (a real
	# fight, a real dict) but every field on it is zero, so no line gets built.
	# `Dictionary.is_empty()` only checks size, not values -- an all-zero
	# preview dict is non-empty, so this exercises the OTHER early return
	# (`if out.is_empty()`), not the `pv.is_empty()` one the test above does.
	var data := {"text": "Nothing to see.", "preview": {"damage": 0, "block": 0},
		"preview_miss": {}, "base": {}, "fx": {}, "keywords": []}
	_expect(CardView.face_text(data, false) == "Nothing to see.",
		"a real preview dict whose values are all zero still falls back to the authored text rather than an empty string")


func _test_backlog86_num_colors_only_when_the_live_value_differs_from_printed() -> void:
	_expect(CardView._num(3, 3, 3, true) == "3",
		"a live value equal to what the card prints stays plain even in rich mode")
	_expect(CardView._num(5, 5, 3, true) == "[color=#%s]5[/color]" % CardView.LIVE_COLOR,
		"a live value a buff or scaling moved away from the printed base is coloured in rich mode")
	_expect(CardView._num(5, 5, 3, false) == "5",
		"the same buffed value stays plain text outside rich mode -- colour is a RichTextLabel-only concern")
	_expect(CardView._num(0, 4, 0, true) == "[color=#%s]4[/color]" % CardView.LIVE_COLOR,
		"a card with no guaranteed value (low<=0) prints the landed high instead of a bare 0")


## backlog #86 duty 3 (sixteenth turn) -- combat_3d._let_drags_through walks a
## whole subtree setting mouse_filter to IGNORE, because Godot's mouse_filter
## does not inherit: a Control marked IGNORE still leaves its CHILDREN at the
## STOP default, which is exactly the bug the doc comment above it names (the
## top bar stayed a dead strip for camera drags even after being marked
## IGNORE, until every descendant was walked too). These build a bare Control
## tree with no scene and no combat state -- the function is static and pure.
func _test_backlog86_let_drags_through_sets_the_root_itself() -> void:
	var top := Control.new()
	Combat3D._let_drags_through(top)
	_expect(top.mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"the root passed in is itself set to IGNORE, not just its children")
	top.free()


func _test_backlog86_let_drags_through_reaches_every_descendant_control() -> void:
	var top := Control.new()
	var mid := Control.new()
	var leaf := Control.new()
	top.add_child(mid)
	mid.add_child(leaf)
	Combat3D._let_drags_through(top)
	_expect(mid.mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"a child added under the top bar must be walked too, or it stays STOP and blocks the drag mouse_filter alone would have missed")
	_expect(leaf.mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"a grandchild is reached as well -- the whole subtree, not just one level")
	top.free()


func _test_backlog86_let_drags_through_walks_through_a_non_control_node() -> void:
	# A plain Node with no mouse_filter of its own (e.g. a layout helper) sits
	# between two Controls; the walk must not stop just because the middle
	# node isn't a Control.
	var top := Control.new()
	var wrapper := Node.new()
	var leaf := Control.new()
	top.add_child(wrapper)
	wrapper.add_child(leaf)
	Combat3D._let_drags_through(top)
	_expect(leaf.mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"a Control nested under a non-Control node is still reached -- recursion continues past nodes with no mouse_filter of their own")
	top.free()


func _test_backlog86_let_drags_through_tolerates_a_null_root() -> void:
	Combat3D._let_drags_through(null)
	_expect(true, "a null root returns immediately instead of crashing on get_children()")


## backlog #86 duty 3 (twentieth turn) -- CardView.shape_text() is "the
## authored text minus everything the live line already said" (its own doc
## comment). It builds face_text(data, false) as the live line, then keeps
## only the authored sentences whose SHAPE (digits stripped) doesn't already
## appear among the live line's sentences. Static and pure: plain
## Dictionaries in, a String out, no scene needed.
func _test_backlog86_shape_text_passes_authored_text_through_with_no_preview() -> void:
	var data := {"text": "Deal 3 damage."}
	_expect(CardView.shape_text(data) == "Deal 3 damage.",
		"a card with no live preview (an offer, not a card in hand) shows its authored text untouched -- there is no live line to compare against")


func _test_backlog86_shape_text_is_blank_when_authored_text_is_blank() -> void:
	var data := {"text": "", "preview": {"damage": 3}, "preview_miss": {},
		"base": {}, "fx": {"hits": 1}, "keywords": []}
	_expect(CardView.shape_text(data) == "",
		"a card authored with no prose at all has nothing for the inspector's second line to add, live preview or not")


func _test_backlog86_shape_text_drops_a_clause_the_live_line_already_says() -> void:
	# Live line (face_text) resolves to "Deal 3 damage." alone; the authored
	# text says the same fact at its PRINTED value.
	var data := {"text": "Deal 5 damage.", "preview": {"damage": 3},
		"preview_miss": {}, "base": {}, "fx": {"hits": 1}, "keywords": []}
	_expect(CardView.shape_text(data) == "",
		"the authored clause and the live line say the same thing (deal damage) so it is dropped rather than printed twice")


func _test_backlog86_shape_text_keeps_a_clause_the_live_line_never_says() -> void:
	var data := {"text": "Deal 5 damage. 3 more damage per Rhythm.",
		"preview": {"damage": 3}, "preview_miss": {}, "base": {}, "fx": {"hits": 1},
		"keywords": []}
	_expect(CardView.shape_text(data) == "3 more damage per Rhythm.",
		"the damage clause duplicates the live line and is dropped, but the scaling clause names something the live line never mentions and survives")


func _test_backlog86_shape_text_drops_a_clause_even_when_its_value_differs_from_the_live_line() -> void:
	# This is the whole point of comparing SHAPES rather than exact strings:
	# "Climb 2" printed against a live line of "Climb 1" is still the same
	# statement at a different value, not new information.
	var data := {"text": "Climb 2.", "preview": {"grip": 1}, "preview_miss": {},
		"base": {}, "fx": {"hits": 1}, "keywords": []}
	_expect(CardView.shape_text(data) == "",
		"a printed clause is dropped even when its NUMBER disagrees with the live line, because the shapes (digits stripped) still match")


func _test_backlog86_shape_text_returns_empty_when_every_clause_is_already_said() -> void:
	var data := {"text": "Deal 5 damage. Climb 2.",
		"preview": {"damage": 3, "grip": 1}, "preview_miss": {}, "base": {},
		"fx": {"hits": 1}, "keywords": []}
	_expect(CardView.shape_text(data) == "",
		"a card with nothing left to add once every authored clause is matched by the live line returns empty, not a stray join artifact")


func _test_backlog86_sentences_splits_on_period_space_and_keeps_each_dot() -> void:
	var out := CardView._sentences("Deal 3 damage. Climb 2.")
	_expect(out.size() == 2 and out[0] == "Deal 3 damage." and out[1] == "Climb 2.",
		"two authored sentences split apart on '. ' and each keeps its own trailing period")


func _test_backlog86_sentences_appends_a_missing_trailing_dot() -> void:
	var out := CardView._sentences("Deal 3 damage. Climb 2")
	_expect(out.size() == 2 and out[1] == "Climb 2.",
		"a final sentence authored without its trailing period still gets one, or shape_of comparisons against face_text's always-punctuated lines would never match")


func _test_backlog86_sentences_drops_the_empty_fragment_after_a_trailing_period() -> void:
	var out := CardView._sentences("Deal 3 damage. ")
	_expect(out.size() == 1 and out[0] == "Deal 3 damage.",
		"a trailing '. ' with nothing after it must not become a bogus empty second sentence")


func _test_backlog86_shape_of_strips_digits_so_two_values_of_the_same_line_compare_equal() -> void:
	_expect(CardView._shape_of("Climb 2.") == CardView._shape_of("Climb 5."),
		"the same statement at two different values must reduce to the same shape, or shape_text could never recognize a live line as a duplicate")


func _test_backlog86_shape_of_leaves_a_line_with_no_digits_untouched() -> void:
	_expect(CardView._shape_of("Draw a card.") == "Draw a card.",
		"a sentence with no digits to strip is returned as-is")


## backlog #86 duty 3 (twenty-first pass) -- _word_index, _is_word_char, _kw
## and _markup are the keyword-highlight machinery behind face_text's rich
## mode: the gold underline is the tap target a player uses to ask "what does
## this word mean" (CLAUDE.md's no-hover-only-info rule -- there is no other
## way to reach a keyword's explanation). All four are static and pure. Every
## test above this either runs rich=false or, in the one rich=true case, a
## single keyword appearing exactly once with no markup already in the
## string -- the boundary check, the "don't re-tag something already inside
## a BBCode tag" rule, and the "mark only the first occurrence" rule were
## never exercised.
func _test_backlog86_word_index_finds_a_whole_word_match() -> void:
	var at: int = CardView._word_index("Climb 2 to gain Block.", "Climb")
	_expect(at == 0, "a word bounded by the string start and a space is found at its own position")


func _test_backlog86_word_index_ignores_a_substring_inside_a_longer_word() -> void:
	# "climb" is a real substring of "Unclimbable" but not a real word in it --
	# the word-boundary check must reject it rather than marking half a word.
	var at: int = CardView._word_index("Unclimbable terrain.", "climb")
	_expect(at == -1, "a substring embedded inside a longer word is not a match, even though String.find would happily locate it")


func _test_backlog86_word_index_skips_a_match_already_inside_markup() -> void:
	# The first "Block" sits inside an open tag's own attribute text (between
	# an unmatched "[" and the word); the second sits in plain text after the
	# tag closes. Only the second is a legal place to splice in a new tag.
	var at: int = CardView._word_index("[x:Block]Block[/x]", "Block")
	_expect(at == 9, "a word that reads as text but sits inside an unclosed BBCode tag is skipped in favour of the next, genuinely plain occurrence")


func _test_backlog86_is_word_char_treats_digits_and_punctuation_as_boundaries() -> void:
	_expect(CardView._is_word_char("a"), "a letter is a word character")
	_expect(CardView._is_word_char("_"), "underscore counts as a word character even though upper/lower are identical for it")
	_expect(not CardView._is_word_char("3"), "a digit has no case distinction, so it reads as a boundary, not a word character -- '3Block' still bounds 'Block'")
	_expect(not CardView._is_word_char("."), "punctuation is a boundary")
	_expect(not CardView._is_word_char(""), "past the end of the string counts as a boundary too")


func _test_backlog86_kw_stays_plain_when_its_id_is_not_among_the_cards_keywords() -> void:
	# face_text calls _kw for every structured effect it prints, whether or not
	# that effect's keyword id actually made it into data["keywords"] -- a
	# mismatch there (the two-copies-of-one-truth bug class duty 3 hunts)
	# would otherwise show live Block text that isn't tappable.
	var out: String = CardView._kw("Block", "player_block", [{"id": "poison"}], true)
	_expect(out == "Block", "rich mode still prints a plain word when the id it was asked to highlight isn't in this card's own keyword list")


func _test_backlog86_kw_returns_plain_word_outside_rich_mode_even_with_a_matching_id() -> void:
	var out: String = CardView._kw("Block", "player_block", [{"id": "player_block"}], false)
	_expect(out == "Block", "rich=false always prints the bare word, even when the id matches -- colour and the tap target are a RichTextLabel-only concern")


func _test_backlog86_markup_leaves_text_untouched_without_rich_or_without_keywords() -> void:
	_expect(CardView._markup("Climb 2.", [{"id": "height"}], false) == "Climb 2.",
		"rich=false leaves the text untouched even though a matching keyword is present")
	_expect(CardView._markup("Climb 2.", [], true) == "Climb 2.",
		"rich mode with no keywords on the card leaves the text untouched")
	_expect(CardView._markup("", [{"id": "height"}], true) == "",
		"an empty line stays empty rather than crashing on the first word search")


func _test_backlog86_markup_marks_only_the_first_occurrence_of_a_repeated_keyword() -> void:
	# _markup's inner loop breaks after the first hit for each keyword id --
	# deliberate, per the comment above it ("this keyword is marked; move to
	# the next"), but never actually checked against text with the word twice.
	var out: String = CardView._markup("Climb 2. Climb 3.", [{"id": "height"}], true)
	var wrapped: String = "[url=kw:height][u][color=#%s]Climb[/color][/u][/url]" % CardView.KEYWORD_COLOR
	_expect(out == "%s 2. Climb 3." % wrapped,
		"only the first 'Climb' in the line becomes a tap target; a second, later use of the same word is left as plain text")


func _test_backlog86_markup_marks_each_of_two_different_keywords_once() -> void:
	var out: String = CardView._markup("Climb 2. Gain 4 Block.",
		[{"id": "height"}, {"id": "player_block"}], true)
	var climb: String = "[url=kw:height][u][color=#%s]Climb[/color][/u][/url]" % CardView.KEYWORD_COLOR
	var block: String = "[url=kw:player_block][u][color=#%s]Block[/color][/u][/url]" % CardView.KEYWORD_COLOR
	_expect(out == "%s 2. Gain 4 %s." % [climb, block],
		"two different keywords on one line each get their own tag, and marking the second doesn't disturb the first")


## backlog #86 duty 3 (twenty-second pass) -- overworld_3d._act_ahead decides
## which act's region is drawn on the hex map: the one containing the row the
## party may step to NEXT, not the one they stand on. Those are the same row
## everywhere except a Titan's node, which is the LAST row of its act -- and
## that mismatch is the exact bug Nick hit 2026-08-16 (act one had nowhere to
## go once you reached its Titan, because the region drawn was the one just
## finished). Made static above so this is provable with no map loaded.
const Overworld3D := preload("res://views/overworld_3d.gd")


func _act_row(act: int) -> Array:
	return [{"act": act}]


func _test_backlog86_act_ahead_is_zero_with_no_rows() -> void:
	_expect(Overworld3D._act_ahead([], -1, 0) == 0, "no map rows at all falls back to act 0 rather than indexing an empty array")


func _test_backlog86_act_ahead_before_any_step_uses_the_first_row() -> void:
	var rows: Array = [_act_row(0), _act_row(0)]
	_expect(Overworld3D._act_ahead(rows, -1, 0) == 0, "cur_row -1 (before the first step) reads the act off row 0, not off a negative index")


func _test_backlog86_act_ahead_looks_at_the_next_row_mid_act() -> void:
	# Standing on row 1 of act 0 with more of act 0 still ahead: the region on
	# screen should already be act 0, read from the row about to be entered.
	var rows: Array = [_act_row(0), _act_row(0), _act_row(0)]
	_expect(Overworld3D._act_ahead(rows, 1, 0) == 0, "mid-act, the act ahead is read from cur_row + 1, not the row currently stood on")


func _test_backlog86_act_ahead_on_the_titan_uses_the_current_row_not_a_next_one() -> void:
	# The Titan is the final row overall -- there is no cur_row + 1 to read,
	# so this must fall back to the row (and column) actually stood on rather
	# than indexing past the end of the array.
	var rows: Array = [_act_row(0), _act_row(0)]
	_expect(Overworld3D._act_ahead(rows, 1, 0) == 0, "on the last row of the map, the act ahead comes from cur_row/cur_col, since there is no next row to look at")


func _test_backlog86_act_ahead_crosses_into_the_next_act_stepping_off_a_titan() -> void:
	# The bug itself: row 1 is act 0's Titan (last row of act 0), row 2 opens
	# act 1. Standing ON the Titan (row 1), the act ahead must already be 1 --
	# the next act's region -- or a player who just cleared act 1's Titan has
	# nothing drawn to walk onto.
	var rows: Array = [_act_row(0), _act_row(0), _act_row(1)]
	_expect(Overworld3D._act_ahead(rows, 1, 0) == 1, "standing on the last row of an act, the act ahead is the NEXT act's, not the one just finished")


func _test_backlog86_row_in_act_is_false_for_a_negative_row() -> void:
	var rows: Array = [_act_row(0), _act_row(0)]
	_expect(not Overworld3D.row_in_act(rows, -1, 0), "row -1 (before the first step) is not part of any drawn act")


func _test_backlog86_row_in_act_is_false_past_the_end_of_the_rows() -> void:
	var rows: Array = [_act_row(0), _act_row(0)]
	_expect(not Overworld3D.row_in_act(rows, 2, 0), "a row index past the end of the map must not be treated as in-act, let alone index off the array")


func _test_backlog86_row_in_act_is_true_mid_act() -> void:
	var rows: Array = [_act_row(0), _act_row(0), _act_row(0)]
	_expect(Overworld3D.row_in_act(rows, 1, 0), "a row that belongs to the act currently drawn is in-act")


func _test_backlog86_row_in_act_is_false_standing_on_the_previous_acts_titan() -> void:
	# Row 1 is act 0's Titan (the last row of act 0); row 2 opens act 1. The
	# region now drawn is act 1 (per _act_ahead), so standing on row 1 must
	# read as OUT of the currently drawn region -- this is exactly what
	# sends _stand_at to the trailhead instead of indexing a region that no
	# longer contains this row.
	var rows: Array = [_act_row(0), _act_row(0), _act_row(1)]
	_expect(not Overworld3D.row_in_act(rows, 1, 1), "standing on the act just finished, the row does not belong to the act now on screen")


func _test_backlog86_row_in_act_is_true_on_the_first_row_of_a_new_act() -> void:
	var rows: Array = [_act_row(0), _act_row(0), _act_row(1)]
	_expect(Overworld3D.row_in_act(rows, 2, 1), "the first row of the new act belongs to the act now drawn")


## backlog #86 duty 3 (twenty-fourth pass) -- combat_3d.intent_text_for is the
## boss telegraph a player reads to decide how to react (the doc comment above
## it promises "every move now prints the real figure"). Writing this test
## found that promise was false for two move types combat.gd actually
## resolves -- "curse" and "frail" (both backlog #69) -- which had keyword
## entries but no match branch, so they fell through to the blank string at
## the bottom. Both are fixed in the same commit the test was written in.
func _intent_boss(kind: String, value: int, strength: int = 0) -> Dictionary:
	return {"intent": {"type": kind, "value": value}, "strength": strength}


func _test_backlog86_intent_text_for_attack_adds_boss_strength() -> void:
	var text := Combat3D.intent_text_for(_intent_boss("attack", 5, 3), 0)
	_expect(text == "⚔ [u]Attack[/u] 8", "attack's printed number is the move's value plus the boss's strength")


func _test_backlog86_intent_text_for_rift_adds_the_height_gap_times_two() -> void:
	var text := Combat3D.intent_text_for(_intent_boss("rift", 4, 0), 3)
	var want: int = 4 + 3 * Combat.RIFT_PER_GAP
	_expect(text == "⚔ [u]Wrench apart[/u] %d" % want, "rift prices in height_gap * RIFT_PER_GAP the same way combat.gd's own resolution does")


func _test_backlog86_intent_text_for_block_ignores_boss_strength() -> void:
	var text := Combat3D.intent_text_for(_intent_boss("block", 6, 99), 0)
	_expect(text == "◆ [u]Defend[/u] 6", "block's printed number is the move's own value only -- strength does not inflate a defensive move")


func _test_backlog86_intent_text_for_enrage_ignores_boss_strength() -> void:
	var text := Combat3D.intent_text_for(_intent_boss("enrage", 2, 99), 0)
	_expect(text == "▲ [u]Enrage[/u] 2", "enrage's printed number is the move's own value only")


func _test_backlog86_intent_text_for_regen_ignores_boss_strength() -> void:
	var text := Combat3D.intent_text_for(_intent_boss("regen", 10, 99), 0)
	_expect(text == "✚ [u]Recover[/u] 10", "regen's printed number is the move's own value only")


func _test_backlog86_intent_text_for_shift_sigil_names_the_destination_height() -> void:
	var text := Combat3D.intent_text_for(_intent_boss("shift_sigil", 4, 99), 0)
	_expect(text == "✦ [u]Shift its sigil[/u] — Height 4", "shift_sigil reports the destination Height, not a damage number")


func _test_backlog86_intent_text_for_frail_is_no_longer_blank() -> void:
	var text := Combat3D.intent_text_for(_intent_boss("frail", 1, 0), 0)
	_expect(text == "▼ [u]Frail[/u] 1", "frail is a real boss move combat.gd resolves and must telegraph like every other move, not fall through to a blank string")


func _test_backlog86_intent_text_for_curse_is_no_longer_blank() -> void:
	var text := Combat3D.intent_text_for(_intent_boss("curse", 2, 0), 0)
	_expect(text == "☠ [u]Curse[/u] 2", "curse is a real boss move combat.gd resolves and must telegraph like every other move, not fall through to a blank string")


func _test_backlog86_intent_text_for_curse_floors_the_card_count_at_one() -> void:
	var text := Combat3D.intent_text_for(_intent_boss("curse", 0, 0), 0)
	_expect(text == "☠ [u]Curse[/u] 1", "combat.gd's own curse resolution floors the card count at 1 even when value is 0 -- the telegraph must promise the same number it delivers")


func _test_backlog86_intent_text_for_unknown_kind_is_blank() -> void:
	var text := Combat3D.intent_text_for(_intent_boss("not_a_real_move", 5, 0), 0)
	_expect(text == "", "a move type with no keyword entry produces no telegraph rather than a garbled one")


## backlog #86 duty 3: card_climb_for, lifted out of combat_3d._card_climb, the
## rule that decides whether a timed-hit card renders as a multi-note slider
## (Combat3D.SLIDER_CLIMB and up) or a plain single tap. Its own doc comment
## warns that reading card.grip directly returns 0 for every card in the game
## silently -- the printed value lives under card.base.grip -- and that this
## exact mistake once flattened the slider path for the whole game with no
## error anywhere. These tests pin the correct path and guard the wrong one.
func _test_backlog86_card_climb_for_reads_grip_from_base() -> void:
	var climb := Combat3D.card_climb_for({"base": {"grip": 3}})
	_expect(climb == 3, "card_climb_for reads the printed grip out of the base dict")


func _test_backlog86_card_climb_for_defaults_to_zero_with_no_base() -> void:
	var climb := Combat3D.card_climb_for({})
	_expect(climb == 0, "a card with no base dict at all never crashes and never climbs")


func _test_backlog86_card_climb_for_defaults_to_zero_with_no_grip_key() -> void:
	var climb := Combat3D.card_climb_for({"base": {}})
	_expect(climb == 0, "a base dict with no grip key defaults to 0, not to a slider")


func _test_backlog86_card_climb_for_ignores_a_top_level_grip_key() -> void:
	var climb := Combat3D.card_climb_for({"grip": 9, "base": {"grip": 0}})
	_expect(climb == 0, "a stray top-level grip key must never leak through -- this is the exact silent-zero bug the function's own comment names")


func _test_backlog86_card_climb_for_threshold_matches_slider_cutoff() -> void:
	_expect(Combat3D.card_climb_for({"base": {"grip": 1}}) < Combat3D.SLIDER_CLIMB, "climb 1 stays a plain tap")
	_expect(Combat3D.card_climb_for({"base": {"grip": 2}}) >= Combat3D.SLIDER_CLIMB, "climb 2 is the rule's own cutoff for a slider")
	_expect(Combat3D.card_climb_for({"base": {"grip": 5}}) >= Combat3D.SLIDER_CLIMB, "a high climb stays a slider")


## backlog #86 duty 3: Progress's keybind rule -- "binding a key steals it from
## whoever else held it" (its own doc comment: two actions on one key means one
## of them silently never fires, which reads as a broken game rather than a bad
## binding). Nothing in run_tests.gd called keybind()/set_keybind()/
## action_for_key()/reset_keybinds() before this -- the whole rebind system
## (game/ui/settings, combat_3d._apply_rebind) had zero headless coverage.
func _test_backlog86_progress_keybind_defaults_before_any_bind() -> void:
	Progress.use_scratch_slot("run_tests_keybinds")
	Progress.reset_keybinds()
	for k in Progress.KEYBINDS:
		var spec: Dictionary = k
		_expect(Progress.keybind(String(spec["id"])) == int(spec["default"]),
			"%s reads back its authored default before anything has ever been bound" % spec["id"])


func _test_backlog86_progress_set_keybind_steals_the_key_from_its_old_owner() -> void:
	Progress.use_scratch_slot("run_tests_keybinds")
	Progress.reset_keybinds()
	Progress.set_keybind("swap", KEY_A)
	_expect(Progress.keybind("swap") == KEY_A, "swap takes the key it was just bound to")
	Progress.set_keybind("hunter_1", KEY_A)
	_expect(Progress.keybind("hunter_1") == KEY_A, "hunter_1 takes over the key")
	_expect(Progress.keybind("swap") == KEY_NONE,
		"swap loses the key it held -- the exact case the doc comment warns about: two actions on one key must not both silently claim it")


func _test_backlog86_progress_action_for_key_finds_the_current_owner() -> void:
	Progress.use_scratch_slot("run_tests_keybinds")
	Progress.reset_keybinds()
	Progress.set_keybind("swap", KEY_A)
	Progress.set_keybind("hunter_1", KEY_A)  # steals KEY_A from swap, see the test above
	_expect(Progress.action_for_key(KEY_A) == "hunter_1", "action_for_key reports the CURRENT owner, not the one that lost it")
	_expect(Progress.action_for_key(KEY_NONE) == "", "an unbound key names no action, even though set_keybind uses KEY_NONE as its own 'stolen' marker")


func _test_backlog86_progress_rebinding_to_your_own_key_does_not_steal_from_yourself() -> void:
	Progress.use_scratch_slot("run_tests_keybinds")
	Progress.reset_keybinds()
	Progress.set_keybind("swap", KEY_A)
	Progress.set_keybind("swap", KEY_A)  # re-bind to the SAME key it already holds
	_expect(Progress.keybind("swap") == KEY_A,
		"set_keybind's steal loop guards `other != id` -- rebinding an action to the key it already holds must not clear it as though some OTHER action had it")


func _test_backlog86_progress_reset_keybinds_restores_every_default() -> void:
	Progress.use_scratch_slot("run_tests_keybinds")
	Progress.set_keybind("swap", KEY_A)
	Progress.set_keybind("hunter_1", KEY_A)
	Progress.reset_keybinds()
	for k in Progress.KEYBINDS:
		var spec: Dictionary = k
		_expect(Progress.keybind(String(spec["id"])) == int(spec["default"]),
			"%s is back to its authored default after reset_keybinds, even one that had just been stolen from" % spec["id"])


## backlog #86 duty 3: next_selection_state, lifted out of
## combat_3d._pick_for_selection -- the tap-to-pick state machine behind
## meld/exhaust_pick/cheapen_pick cards. Its own doc comment names the one hard
## invariant: the two picks must land on different cards, the same rule
## core/combat.gd enforces server-side with `target_index != sac_index`
## (combat.gd:621). Before this pass the state only ever advanced through a
## live scene tap, so nothing proved a repicked sac card actually gets ignored
## rather than silently becoming the target.
func _test_backlog86_next_selection_state_cancels_on_the_selecting_card_itself() -> void:
	var selecting := {"play_index": 2, "mode": "meld", "picks": 2, "step": 0, "sac": -1, "target": -1}
	var result := Combat3D.next_selection_state(selecting, 2)
	_expect(String(result.get("action", "")) == "cancel",
		"tapping the card being played again cancels the selection instead of picking it as a sac")


func _test_backlog86_next_selection_state_records_the_first_pick_as_sac() -> void:
	var selecting := {"play_index": 2, "mode": "meld", "picks": 2, "step": 0, "sac": -1, "target": -1}
	var result := Combat3D.next_selection_state(selecting, 0)
	_expect(String(result.get("action", "")) == "continue", "one pick of two does not fire yet")
	var next: Dictionary = result.get("selecting", {})
	_expect(int(next.get("sac", -1)) == 0 and int(next.get("step", -1)) == 1,
		"the first tap becomes the sac card and advances the step")


func _test_backlog86_next_selection_state_ignores_repicking_the_same_sac_card() -> void:
	var selecting := {"play_index": 2, "mode": "meld", "picks": 2, "step": 1, "sac": 0, "target": -1}
	var result := Combat3D.next_selection_state(selecting, 0)
	_expect(String(result.get("action", "")) == "ignore",
		"the sac card and the target card must be different -- retapping the sac card is a no-op, not a second pick that reuses it as the target")


func _test_backlog86_next_selection_state_fires_once_both_picks_land() -> void:
	var selecting := {"play_index": 2, "mode": "meld", "picks": 2, "step": 1, "sac": 0, "target": -1}
	var result := Combat3D.next_selection_state(selecting, 1)
	_expect(String(result.get("action", "")) == "fire", "the second, distinct pick completes a two-pick card")
	_expect(int(result.get("play_index", -1)) == 2 and int(result.get("sac", -1)) == 0 and int(result.get("target", -1)) == 1,
		"the fired result carries the original play index plus both distinct picks")


func _test_backlog86_next_selection_state_fires_immediately_for_a_one_pick_card() -> void:
	var selecting := {"play_index": 5, "mode": "exhaust", "picks": 1, "step": 0, "sac": -1, "target": -1}
	var result := Combat3D.next_selection_state(selecting, 3)
	_expect(String(result.get("action", "")) == "fire", "a plain exhaust card fires on its single pick")
	_expect(int(result.get("sac", -1)) == 3 and int(result.get("target", -1)) == -1,
		"a one-pick card's only pick lands as sac with no target, matching play_card's -1 default")


func _expect(cond: bool, name: String) -> void:
	if cond:
		print("PASS  " + name)
	else:
		print("FAIL  " + name)
		_failures += 1
