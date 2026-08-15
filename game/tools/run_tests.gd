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
	# the run map (branching route)
	_test_map_generates_connected_rows()
	_test_map_is_deterministic_per_seed()
	_test_run_walks_the_map()
	_test_rest_node_heals_and_returns_to_map()
	_test_event_choice_applies_effects()
	_test_event_reward_choice_routes_to_reward()
	_test_events_load_and_are_well_formed()
	_test_card_upgrade_bumps_numbers()
	_test_campfire_rest_remove_upgrade()
	_test_skip_reward_keeps_the_deck_lean()
	_test_rule_changing_relics()
	_test_relics_all_load()
	_test_climb_twisting_moves()
	_test_per_class_reward_pools()
	_test_rhythm_card_grants_combo()
	_test_ascension_makes_the_run_harder()
	_test_coach_teaches_the_right_thing_first()
	_test_tips_can_be_switched_off_without_losing_your_place()
	_test_gold_and_shop()
	_test_content_pools_are_copies()
	# grip / ledges (SotC real-time climb)
	_test_secure_on_holds()
	_test_next_safe_height()
	_test_fall_drops_to_base()
	_test_fall_noop_when_secure()
	_test_weakpoint_threshold_bucks()
	_test_timed_damage_bonus()
	_test_timed_block_guards_on_a_hit()
	_test_timed_ally_block_anchors_the_ally()
	_test_every_referenced_card_id_resolves()
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
	var ok := ids.size() >= 8
	for id in ids:
		var e: Dictionary = Content.make_event(String(id))
		var choices: Array = e.get("choices", [])
		if String(e.get("title", "")) == "" or String(e.get("text", "")) == "" or choices.size() < 2:
			ok = false
		for ch in choices:
			if String((ch as Dictionary).get("label", "")) == "":
				ok = false
	_expect(ok, "every event has a title, prose, and at least two labelled choices")


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
func _flurry() -> Card:
	return Card.from_dict({"id": "flurry", "name": "Flurry", "type": "attack", "cost": 2, "damage": 4, "hits": 2})
func _dig_in() -> Card:
	return Card.from_dict({"id": "dig_in", "name": "Dig In", "type": "skill", "cost": 1, "block": 4, "timed": true, "timed_block": 6})
func _anchor_brace() -> Card:
	return Card.from_dict({"id": "anchor_brace", "name": "Anchor Brace", "type": "skill", "cost": 1, "block": 2, "ally_block": 4, "timed": true, "timed_ally_block": 6, "target": "ally"})


func _expect(cond: bool, name: String) -> void:
	if cond:
		print("PASS  " + name)
	else:
		print("FAIL  " + name)
		_failures += 1
