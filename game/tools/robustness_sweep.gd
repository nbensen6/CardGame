## Robustness sweep (backlog #46) — plays many COMPLETE, seeded runs through the
## real /core (Run + Combat + Content) and asserts one thing only: nobody ever
## gets STUCK. No playable card and no energy, a climb that can't progress, a
## shop with nothing affordable, an event with no valid choice — every one of
## those has to have a legal way out, or a real player hits a wall we didn't.
##
## This is deliberately NOT balance_sim.gd. balance_sim measures how well a
## smart team plays and Nick's standing rule is not to tune against it. This
## tool measures nothing about skill — it reports crashes and dead ends only,
## never win rates, and a "coordinated" team winning less than a "random" one
## is not a finding here.
##
##   godot --headless --path game --script res://tools/robustness_sweep.gd
extends SceneTree

const ASCENSIONS := [0, 4, 8]      # low, mid, and the top of today's ladder
const SEEDS_PER_CONFIG := 6
const GUARD := 4000                 # phase-steps before a run is "never terminates"

var _rng := RandomNumberGenerator.new()
var _dead_ends: Array = []          # Array[String] — human-readable, one per failure
var _runs_swept := 0


func _init() -> void:
	var char_ids: Array = []
	for c in Content.list_characters():
		char_ids.append(String(c["id"]))
	var pairs: Array = []
	for i in range(char_ids.size()):
		for j in range(i + 1, char_ids.size()):
			pairs.append([char_ids[i], char_ids[j]])

	var total: int = pairs.size() * ASCENSIONS.size() * SEEDS_PER_CONFIG * 2
	print("Robustness sweep: %d char pairs x %d ascensions x %d seeds x 2 policies = %d runs\n" % [
		pairs.size(), ASCENSIONS.size(), SEEDS_PER_CONFIG, total])

	for pair in pairs:
		for asc in ASCENSIONS:
			for policy in ["random", "naive"]:
				for s in range(SEEDS_PER_CONFIG):
					# Seed derived from config, not Godot's global RNG, so a failing
					# seed is reproducible from this printout alone.
					var seed_value: int = 1000 * s + asc * 37 + char_ids.find(pair[0]) * 991 \
						+ char_ids.find(pair[1]) * 7919 + (1 if policy == "random" else 0)
					_sweep_run(pair, asc, policy, maxi(1, seed_value))

	print("")
	if _dead_ends.is_empty():
		print("%d runs swept, 0 dead ends, 0 crashes." % _runs_swept)
		print("ROBUSTNESS SWEEP CLEAN")
		quit(0)
	else:
		print("%d DEAD END(S) FOUND (of %d runs swept):" % [_dead_ends.size(), _runs_swept])
		for d in _dead_ends:
			print("  - %s" % d)
		quit(1)


func _sweep_run(pair: Array, asc: int, policy: String, seed_value: int) -> void:
	var decks := [Content.character_deck(pair[0]), Content.character_deck(pair[1])]
	var names := [Content.character_name(pair[0]), Content.character_name(pair[1])]
	var passives := [Content.character_passive(pair[0]), Content.character_passive(pair[1])]
	var run := Run.new(decks, names, seed_value, passives, asc)
	run.start()
	_rng.seed = seed_value * 104729 + asc
	var label := "%s+%s A%d seed=%d policy=%s" % [pair[0], pair[1], asc, seed_value, policy]

	var guard := 0
	while not run.is_over() and guard < GUARD:
		guard += 1
		match run.phase:
			Run.Phase.MAP:
				var open_cols: Array = run.available_nodes()
				if open_cols.is_empty():
					_dead_end(label, "MAP", "no available nodes at row %d" % run.map_row)
					return
				if not run.pick_node(_pick(open_cols, policy)):
					_dead_end(label, "MAP", "pick_node refused a column available() itself offered")
					return
			Run.Phase.EVENT:
				var choices: Array = run.event.get("choices", [])
				if choices.is_empty():
					_dead_end(label, "EVENT", "event '%s' has no choices" % run.event.get("id", ""))
					return
				var idx_range: Array = range(choices.size())
				if not run.pick_event(_pick(idx_range, policy)):
					_dead_end(label, "EVENT", "pick_event refused a valid index")
					return
			Run.Phase.CAMPFIRE:
				for slot in range(run.player_count()):
					if slot < run.campfire_done.size() and bool(run.campfire_done[slot]):
						continue
					if not _campfire(run, slot, policy):
						_dead_end(label, "CAMPFIRE",
							"hunter %d had no legal campfire action, including rest" % slot)
						return
			Run.Phase.SHOP:
				_shop(run, policy)
				if not run.leave_shop():
					_dead_end(label, "SHOP", "leave_shop refused — no exit from the shop")
					return
			Run.Phase.REWARD:
				for slot in range(run.player_count()):
					if bool(run.reward_picked[slot]):
						continue
					var choices2: Array = run.reward_choices[slot]
					if choices2.is_empty():
						if not run.skip_reward(slot):
							_dead_end(label, "REWARD",
								"hunter %d had no reward choices and could not skip" % slot)
							return
					else:
						run.pick_reward(slot, _pick(range(choices2.size()), policy))
			Run.Phase.BOON:
				var bchoices: Array = run.boon.get("choices", [])
				if bchoices.is_empty():
					_dead_end(label, "BOON", "boon offer has no choices")
					return
				if not run.pick_boon(_pick(range(bchoices.size()), policy)):
					_dead_end(label, "BOON", "pick_boon refused a valid index")
					return
			Run.Phase.COMBAT:
				var c: Combat = run.combat
				for pi in range(c.player_count()):
					if run.phase != Run.Phase.COMBAT:
						break
					if c.phase == Combat.Phase.PLAYERS and not c.players[pi].ended_turn:
						if not _take_turn(c, pi, policy, label):
							return  # dead end already recorded
						run.sync()
			_:
				pass

	if not run.is_over():
		_dead_end(label, "TIMEOUT", "did not reach WON/LOST within %d phase-steps" % GUARD)
		return
	_runs_swept += 1


## One hunter's combat turn. Plays legal cards until none remain worth playing,
## then ends the turn — which must ALWAYS be possible, hand empty or not.
func _take_turn(c: Combat, pi: int, policy: String, label: String) -> bool:
	var safety := 0
	while safety < 30:
		safety += 1
		var idx := _choose_card(c, pi, policy)
		if idx < 0:
			break
		var card: Card = c.players[pi].hand[idx]
		# A timed card's real accuracy is a display concern; here we just need
		# both outcomes (fumble and landed) exercised across the sweep.
		var landed: bool = (not card.timed) or _rng.randf() < 0.7
		if not c.play_card(pi, idx, landed):
			_dead_end(label, "COMBAT",
				"can_play(%d) said yes but play_card refused it" % pi)
			return false
		if c.is_over():
			return true
	if not c.is_secure(pi) and _rng.randf() < 0.3:
		c.fall(pi)
	# If this is the last player to end their turn, end_turn() runs the enemy
	# turn synchronously and — if the fight goes on — starts a new round right
	# here, which resets ended_turn back to false for everyone. So "did it
	# work" isn't "is ended_turn still true", it's "did SOMETHING move": the
	# flag stuck, the round advanced, or the fight ended outright.
	var round_before := c.round_num
	c.end_turn(pi)
	var advanced: bool = c.players[pi].ended_turn or c.round_num != round_before or c.is_over()
	if not advanced:
		_dead_end(label, "COMBAT", "end_turn(%d) did not end the turn — hunter is stuck" % pi)
		return false
	return true


func _choose_card(c: Combat, pi: int, policy: String) -> int:
	var ps: PlayerState = c.players[pi]
	var legal: Array = []
	for i in range(ps.hand.size()):
		if c.can_play(pi, i):
			legal.append(i)
	if legal.is_empty():
		return -1
	return int(_pick(legal, policy))


## Rest is the guaranteed escape hatch every campfire visit must have — try a
## deck-changing action first (for coverage), fall back to rest.
func _campfire(run: Run, slot: int, policy: String) -> bool:
	if policy == "random" and _rng.randf() < 0.5:
		var deck: Array = run.decks[slot]
		if not deck.is_empty():
			if deck.size() > Run.MIN_DECK and _rng.randf() < 0.5:
				if run.campfire_action(slot, "remove", _rng.randi_range(0, deck.size() - 1)):
					return true
			elif run.campfire_action(slot, "upgrade", _rng.randi_range(0, deck.size() - 1)):
				return true
	return run.campfire_action(slot, "rest")


## Spend down what's affordable, skipping anything that would fail for a
## reason other than price (deck at MIN_DECK, potion slots full) so the loop
## can't stall retrying the same refusal.
func _shop(run: Run, policy: String) -> void:
	var guard := 0
	while guard < 20:
		guard += 1
		var buyable: Array = []
		for i in range(run.shop_stock.size()):
			var item: Dictionary = run.shop_stock[i]
			if bool(item["sold"]) or run.gold < int(item["price"]):
				continue
			var slot: int = int(item["slot"])
			if String(item["kind"]) == "remove" and run.decks[slot].size() <= Run.MIN_DECK:
				continue
			if String(item["kind"]) == "potion" and run.potions[slot].size() >= Run.POTION_SLOTS:
				continue
			buyable.append(i)
		if buyable.is_empty():
			break
		var idx: int = int(_pick(buyable, policy))
		var item2: Dictionary = run.shop_stock[idx]
		var card_index := -1
		if String(item2["kind"]) == "remove":
			var deck: Array = run.decks[int(item2["slot"])]
			card_index = _rng.randi_range(0, deck.size() - 1)
		run.buy(idx, card_index)


## "naive" always takes the first legal option (deterministic, cheapest to
## reason about); "random" samples uniformly (best odds of finding an edge a
## fixed order never visits).
func _pick(items: Array, policy: String) -> Variant:
	if policy == "random" and items.size() > 1:
		return items[_rng.randi_range(0, items.size() - 1)]
	return items[0]


func _dead_end(label: String, phase: String, detail: String) -> void:
	_dead_ends.append("[%s] %s: %s" % [phase, label, detail])
