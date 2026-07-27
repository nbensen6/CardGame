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
	# session / client-server split
	_test_session_both_players_join()
	_test_session_lobby_waits_for_second_player()
	_test_session_shared_board_syncs_across_players()
	_test_session_end_turn_needs_all_players()
	_test_session_private_view_is_isolated()

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
	var combat := _new_combat([_deck_of(_strike, 10), _deck_of(_strike, 10)], 1, _dummy_boss(200))
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
	var combat := _new_combat([_deck_of(_assist, 10), _deck_of(_strike, 10)], 42, _dummy_boss(200))
	combat.play_card(0, _first_playable(combat, 0))
	_expect(combat.players[1].combatant.block == 6 and combat.players[0].combatant.block == 0,
		"assist shields the ally, not the caster (co-op combo)")


func _test_boss_targets_telegraphed_player_and_rotates() -> void:
	var combat := _new_combat([_deck_of(_strike, 10), _deck_of(_strike, 10)], 42, _dummy_boss(500, 8))
	_expect(combat.boss_target_index() == 0, "boss telegraphs player 1 in round 1")
	combat.end_turn(0)
	combat.end_turn(1)  # boss hits its target (player 0)
	_expect(combat.players[0].combatant.hp == 34 and combat.players[1].combatant.hp == 42,
		"boss hit its telegraphed target only")
	_expect(combat.boss_target_index() == 1, "boss target rotates to player 2 in round 2")


func _test_any_player_death_is_a_loss() -> void:
	var players := [Combatant.new("P1", 1), Combatant.new("P2", 42)]  # P1 is fragile
	var combat := Combat.new([_deck_of(_strike, 10), _deck_of(_strike, 10)], players, _dummy_boss(500, 8), 42)
	combat.start()
	combat.end_turn(0)
	combat.end_turn(1)  # boss hits player 0 (1 hp) -> dead
	_expect(combat.is_over() and combat.result() == Combat.Result.LOSE,
		"any player's death ends the run in defeat")


func _test_boss_death_is_a_win() -> void:
	var combat := _new_combat([_deck_of(_strike, 10), _deck_of(_strike, 10)], 42, _dummy_boss(6, 8))
	combat.play_card(0, _first_playable(combat, 0))  # 6 damage kills a 6-hp boss
	_expect(combat.is_over() and combat.result() == Combat.Result.WIN, "killing the boss wins")


func _test_boss_waits_for_all_players_to_end() -> void:
	var combat := _new_combat([_deck_of(_strike, 10), _deck_of(_strike, 10)], 42, _dummy_boss(500, 8))
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
	var combat := _new_combat([_mixed_deck(), _mixed_deck()], 7, Content.build_boss("gatekeeper"))
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
	var boss := Content.build_boss("gatekeeper")
	var has_assist := false
	for c in deck:
		if c.id == "assist":
			has_assist = true
	_expect(deck.size() == 10 and has_assist and boss.name == "The Gatekeeper"
		and boss.max_hp == 90 and boss.moves.size() == 4,
		"content loads the 2-player deck (with Assist) + boss from /data")


# --- Session / client-server split ----------------------------------------

# Loopback is synchronous: after each client call the client snapshots are
# already up to date (command -> host -> broadcast -> clients, in one frame).
func _make_session(seed_value: int = 42) -> Dictionary:
	var transport := LocalTransport.new()
	var host := GameHost.new(transport, seed_value, 2)
	var c0 := GameClient.new(transport, 10)
	var c1 := GameClient.new(transport, 20)
	_kept.append(host)
	c0.join()  # slot 0 — combat not yet started (needs 2)
	c1.join()  # slot 1 — host starts combat and broadcasts
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
	return [_strike(), _strike(), _strike(), _strike(),
		_defend(), _defend(), _defend(), _focus(), _bash(), _assist()]


func _strike() -> Card:
	return Card.from_dict({"id": "strike", "name": "Strike", "type": "attack", "cost": 1, "damage": 6})
func _defend() -> Card:
	return Card.from_dict({"id": "defend", "name": "Defend", "type": "skill", "cost": 1, "block": 5})
func _bash() -> Card:
	return Card.from_dict({"id": "bash", "name": "Bash", "type": "attack", "cost": 2, "damage": 10})
func _focus() -> Card:
	return Card.from_dict({"id": "focus", "name": "Focus", "type": "skill", "cost": 1, "draw": 2})
func _assist() -> Card:
	return Card.from_dict({"id": "assist", "name": "Assist", "type": "skill", "cost": 1, "ally_block": 6, "target": "ally"})


func _expect(cond: bool, name: String) -> void:
	if cond:
		print("PASS  " + name)
	else:
		print("FAIL  " + name)
		_failures += 1
