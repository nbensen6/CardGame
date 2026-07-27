## Headless test runner for /core — proves game rules are deterministic and
## testable with NO rendering, input, or networking (CLAUDE.md §11).
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
	_test_combatant_block_absorbs_before_hp()
	_test_combatant_hp_never_negative()
	_test_boss_pattern_loops()
	_test_play_card_spends_energy_and_damages_boss()
	_test_cannot_overspend_energy()
	_test_block_resets_each_player_turn()
	_test_deterministic_shuffle_same_seed()
	_test_full_fight_reaches_terminal_state()
	_test_content_loads_from_data()

	# --- session / client-server split (build step 2) ---
	_test_session_join_delivers_snapshot()
	_test_session_snapshot_shape()
	_test_session_play_card_updates_client()
	_test_session_end_turn_advances()
	_test_session_private_view_is_isolated()

	print("")
	if _failures == 0:
		print("ALL TESTS PASSED")
		quit(0)
	else:
		print("%d TEST(S) FAILED" % _failures)
		quit(1)


# --- Combatant ------------------------------------------------------------

func _test_combatant_block_absorbs_before_hp() -> void:
	var c := Combatant.new("Test", 20)
	c.gain_block(5)
	c.take_damage(8)  # 5 absorbed, 3 to hp
	_expect(c.block == 0 and c.hp == 17, "block absorbs before hp")


func _test_combatant_hp_never_negative() -> void:
	var c := Combatant.new("Test", 10)
	c.take_damage(9999)
	_expect(c.hp == 0 and c.is_dead(), "hp never goes negative")


# --- Boss -----------------------------------------------------------------

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


# --- Combat ---------------------------------------------------------------

func _make_combat(seed_value: int = 1) -> Combat:
	var deck := _deck([_strike(), _strike(), _strike(), _strike(), _strike(),
		_defend(), _defend(), _defend(), _bash(), _focus()])
	var player := Combatant.new("You", 42)
	var boss := Boss.new("Dummy", 55)
	boss.moves = [{"type": "attack", "value": 7}]
	var combat := Combat.new(deck, player, boss, seed_value)
	combat.start()
	return combat


func _test_play_card_spends_energy_and_damages_boss() -> void:
	# Deck of only Strikes so the drawn hand is deterministic regardless of shuffle.
	var deck := _deck([_strike(), _strike(), _strike(), _strike(), _strike(),
		_strike(), _strike(), _strike(), _strike(), _strike()])
	var combat := Combat.new(deck, Combatant.new("You", 42), _dummy_boss(55), 1)
	combat.start()
	var boss_before: int = combat.boss.hp
	var energy_before: int = combat.energy
	var ok: bool = combat.play_card(0)
	_expect(ok and combat.boss.hp == boss_before - 6 and combat.energy == energy_before - 1,
		"play card spends energy and damages boss")


func _test_cannot_overspend_energy() -> void:
	# Two Bash (cost 2) = 4 energy; only 3 available, so the 2nd must fail.
	var deck := _deck([_bash(), _bash(), _bash(), _bash(), _bash()])
	var combat := Combat.new(deck, Combatant.new("You", 42), _dummy_boss(55), 1)
	combat.start()
	var a: bool = combat.play_card(0)  # cost 2 -> energy 1
	var b: bool = combat.play_card(0)  # cost 2 -> should fail (energy 1)
	_expect(a and not b and combat.energy == 1, "cannot overspend energy")


func _test_block_resets_each_player_turn() -> void:
	# Player gains block, ends turn (boss attacks 7), new turn must reset block to 0.
	var deck := _deck([_defend(), _defend(), _defend(), _defend(), _defend(),
		_defend(), _defend(), _defend(), _defend(), _defend()])
	var boss := _dummy_boss(200)
	boss.moves = [{"type": "attack", "value": 7}]
	var combat := Combat.new(deck, Combatant.new("You", 42), boss, 1)
	combat.start()
	combat.play_card(0)  # +5 block
	_expect(combat.player.block == 5, "block gained this turn")
	combat.end_turn()    # boss attacks 7: 5 blocked, 2 to hp; new player turn resets block
	_expect(combat.player.block == 0 and combat.player.hp == 40,
		"block resets each player turn")


func _test_deterministic_shuffle_same_seed() -> void:
	var order_a := _draw_order(_make_combat(1234))
	var order_b := _draw_order(_make_combat(1234))
	var order_c := _draw_order(_make_combat(9999))
	_expect(order_a == order_b and order_a != order_c,
		"same seed -> same shuffle; different seed -> different")


func _test_full_fight_reaches_terminal_state() -> void:
	# Auto-play: each turn play the first playable card until none, then end turn.
	var combat := _make_combat(7)
	var guard := 0
	while not combat.is_over() and guard < 1000:
		guard += 1
		var played := false
		for i in range(combat.hand.size()):
			if combat.can_play(i):
				combat.play_card(i)
				played = true
				break
		if combat.is_over():
			break
		if not played:
			combat.end_turn()
	_expect(combat.is_over() and combat.result() != Combat.Result.ONGOING,
		"a full fight reaches WIN or LOSE")


func _test_content_loads_from_data() -> void:
	var deck := Content.build_starter_deck()
	var boss := Content.build_boss("gatekeeper")
	_expect(deck.size() == 10 and boss.name == "The Gatekeeper" and boss.max_hp == 55
		and boss.moves.size() == 4, "content loads deck + boss from /data")


# --- session / client-server split ---------------------------------------

# Loopback is synchronous: after each client call, the client's snapshot is
# already up to date (command -> host -> broadcast -> client, all in one frame).
func _make_session(seed_value: int = 42) -> GameClient:
	var transport := LocalTransport.new()
	var host := GameHost.new(transport, seed_value)
	var client := GameClient.new(transport, 1)
	_kept.append(host)  # retain host past this function (see _kept note above)
	client.join()
	return client


func _test_session_join_delivers_snapshot() -> void:
	var client := _make_session()
	var shared := client.shared
	_expect(not shared.is_empty()
		and shared["boss"]["hp"] == 55
		and client.private["hand"].size() == Combat.HAND_SIZE,
		"join delivers shared board + private hand")


func _test_session_snapshot_shape() -> void:
	var client := _make_session()
	var s := client.shared
	var has_shared := s.has("boss") and s.has("player") and s.has("energy") \
		and s.has("turn") and s.has("log") and s.has("over") and s.has("result")
	var has_private := client.private.has("hand")
	_expect(has_shared and has_private, "snapshot has the expected shared/private shape")


func _test_session_play_card_updates_client() -> void:
	var client := _make_session()
	var energy_before: int = client.shared["energy"]
	var idx := _first_playable(client)
	_expect(idx >= 0, "there is a playable card at start")
	client.play_card(idx)
	# Every starter card costs >= 1, so energy must drop after a valid play.
	_expect(client.shared["energy"] < energy_before,
		"play_card command flows host->client and spends energy")


func _test_session_end_turn_advances() -> void:
	var client := _make_session()
	var turn_before: int = client.shared["turn"]
	client.end_turn()
	# After the boss acts, either the fight ended or the turn advanced by one.
	_expect(bool(client.shared["over"]) or client.shared["turn"] == turn_before + 1,
		"end_turn advances the turn via the host")


func _test_session_private_view_is_isolated() -> void:
	# A peer that never joined must receive nothing — proves per-peer routing so
	# a player's private hand is never leaked to others.
	var transport := LocalTransport.new()
	var host := GameHost.new(transport, 42)
	var joined := GameClient.new(transport, 1)
	var eavesdropper := GameClient.new(transport, 2)  # never calls join()
	joined.join()
	joined.play_card(_first_playable(joined))
	_expect(eavesdropper.shared.is_empty() and eavesdropper.private.is_empty(),
		"a non-joined peer receives no private state")


func _first_playable(client: GameClient) -> int:
	for c in client.private.get("hand", []):
		if bool(c["playable"]):
			return int(c["index"])
	return -1


# --- helpers --------------------------------------------------------------

func _draw_order(combat: Combat) -> Array:
	var names: Array = []
	for c in combat.hand:
		names.append(c.name)
	return names

func _dummy_boss(hp: int) -> Boss:
	var b := Boss.new("Dummy", hp)
	b.moves = [{"type": "attack", "value": 7}]
	return b

func _deck(cards: Array) -> Array:
	return cards

func _strike() -> Card:
	return Card.from_dict({"id": "strike", "name": "Strike", "type": "attack", "cost": 1, "damage": 6})
func _defend() -> Card:
	return Card.from_dict({"id": "defend", "name": "Defend", "type": "skill", "cost": 1, "block": 5})
func _bash() -> Card:
	return Card.from_dict({"id": "bash", "name": "Bash", "type": "attack", "cost": 2, "damage": 10})
func _focus() -> Card:
	return Card.from_dict({"id": "focus", "name": "Focus", "type": "skill", "cost": 1, "draw": 2})

func _expect(cond: bool, name: String) -> void:
	if cond:
		print("PASS  " + name)
	else:
		print("FAIL  " + name)
		_failures += 1
