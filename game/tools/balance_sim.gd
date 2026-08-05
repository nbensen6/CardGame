## Automated playtest / balance simulator (build step 4 support). Plays many
## COMPLETE runs through the real /core (Run + Combat + Content) with AI hunters,
## then reports statistics. This measures balance instead of guessing it — it
## does NOT judge "fun" (that needs a human).
##
## Two policies are compared so we can see whether coordination actually matters:
##   naive       — dump the hand, no defense or combos
##   coordinated — cover the targeted ally, brace, Expose -> focus-fire, Rally
##
##   godot --headless --path game --script res://tools/balance_sim.gd
extends SceneTree

const RUNS := 300

func _init() -> void:
	print("Simulating %d runs per policy…\n" % RUNS)
	var naive := _run_many("naive")
	var coop := _run_many("coordinated")

	_report("NAIVE (no coordination)", naive)
	_report("COORDINATED (combos + defense)", coop)

	var lift: float = coop["wins"] * 100.0 / RUNS - naive["wins"] * 100.0 / RUNS
	print("\n=> Coordination changes win rate by %+.1f points (%.0f%% -> %.0f%%)." % [
		lift, naive.wins * 100.0 / RUNS, coop.wins * 100.0 / RUNS])
	quit(0)


func _run_many(policy: String) -> Dictionary:
	var agg := {
		"wins": 0, "lost_at": {}, "min_hp_sum": 0.0,
		"rounds": {}, "rounds_n": {},
		"combos": {"expose": 0.0, "cover": 0.0, "rally": 0.0, "taunt": 0.0},
	}
	for i in range(RUNS):
		var s := _play_run(i + 1, policy)
		if s["won"]:
			agg["wins"] += 1
		else:
			var at: int = s["lost_at"]
			agg["lost_at"][at] = int(agg["lost_at"].get(at, 0)) + 1
		agg["min_hp_sum"] += s["min_hp"]
		for enc in s["enc_rounds"]:
			agg["rounds"][enc] = float(agg["rounds"].get(enc, 0.0)) + s["enc_rounds"][enc]
			agg["rounds_n"][enc] = int(agg["rounds_n"].get(enc, 0)) + 1
		for k in s["combos"]:
			agg["combos"][k] += s["combos"][k]
	return agg


func _play_run(seed_value: int, policy: String) -> Dictionary:
	# A representative pairing: a fast climber + a height-scaling striker.
	var chars := ["frog", "mountain_climbers"]
	var decks := [Content.character_deck(chars[0]), Content.character_deck(chars[1])]
	var names := [Content.character_name(chars[0]), Content.character_name(chars[1])]
	var passives := [Content.character_passive(chars[0]), Content.character_passive(chars[1])]
	var run := Run.new(decks, names, seed_value, passives)
	run.start()
	var stats := {
		"won": false, "lost_at": -1, "min_hp": float(Run.PLAYER_HP), "enc_rounds": {},
		"combos": {"expose": 0, "cover": 0, "rally": 0, "taunt": 0},
	}
	var guard := 0
	while not run.is_over() and guard < 2000:
		guard += 1
		if run.phase == Run.Phase.COMBAT:
			var c: Combat = run.combat
			var enc: int = run.encounter_index
			for pi in range(c.player_count()):
				if run.phase != Run.Phase.COMBAT:
					break
				if c.phase == Combat.Phase.PLAYERS and not c.players[pi].ended_turn:
					_take_turn(c, pi, policy, stats)
					run.sync()
			if run.phase == Run.Phase.COMBAT:
				for ps in c.players:
					stats["min_hp"] = minf(stats["min_hp"], ps.combatant.hp)
			else:
				stats["enc_rounds"][enc] = c.round_num
		elif run.phase == Run.Phase.MAP:
			# Walk the route. The AI has no route strategy yet — it takes the first
			# open node, which is enough to keep the sim measuring card balance.
			var open_cols: Array = run.available_nodes()
			if open_cols.is_empty():
				break
			run.pick_node(int(open_cols[0]))
		elif run.phase == Run.Phase.EVENT:
			run.pick_event(0)  # no event strategy yet — take the first offer
		elif run.phase == Run.Phase.REWARD:
			for slot in range(run.player_count()):
				if not run.reward_picked[slot]:
					run.pick_reward(slot, _pick_reward(run, run.reward_choices[slot], policy))
	stats["won"] = run.phase == Run.Phase.WON
	if not stats["won"]:
		stats["lost_at"] = run.encounter_index + 1
	return stats


func _take_turn(c: Combat, pi: int, policy: String, stats: Dictionary) -> void:
	var safety := 0
	while safety < 20:
		safety += 1
		var idx := _choose(c, pi, policy)
		if idx < 0:
			break
		var card: Card = c.players[pi].hand[idx]
		_tally_combo(card, stats)
		if not c.play_card(pi, idx):
			break
		if c.is_over():
			return
	c.end_turn(pi)


func _choose(c: Combat, pi: int, policy: String) -> int:
	if policy == "naive":
		var atk := _find(c, pi, func(card: Card) -> bool: return card.damage > 0)
		if atk >= 0:
			return atk
		return _find(c, pi, func(_card: Card) -> bool: return true)

	# coordinated
	var ps: PlayerState = c.players[pi]
	var ally_idx := c.ally_index(pi)
	var ally: PlayerState = c.players[ally_idx]

	# 1. shield a threatened ally
	if _threatened(c, ally_idx) > ally.combatant.block:
		var cov := _find(c, pi, func(card: Card) -> bool: return card.ally_block > 0)
		if cov >= 0:
			return cov
	# 2. brace myself if threatened
	if _threatened(c, pi) > ps.combatant.block:
		var brc := _find(c, pi, func(card: Card) -> bool: return card.block > 0 and not card.taunt)
		if brc >= 0:
			return brc
	# 3. climb toward the weak point if we haven't reached it (armored below it)
	if c.boss.weak_point_height > 0 and not c.sigil_reached(pi):
		var climb := _find(c, pi, func(card: Card) -> bool: return card.grip > 0)
		if climb >= 0:
			return climb
	# 4. expose to set up focus-fire
	if c.boss.vulnerable < 2:
		var exp := _find(c, pi, func(card: Card) -> bool: return card.vulnerable > 0 and card.damage == 0)
		if exp >= 0:
			return exp
	# 4. hit hardest
	var atk2 := _find_best_damage(c, pi)
	if atk2 >= 0:
		return atk2
	# 5. draw if hand is thin
	if ps.hand.size() <= 2:
		var aim := _find(c, pi, func(card: Card) -> bool: return card.draw > 0)
		if aim >= 0:
			return aim
	# 6. rally the ally if they can still act
	if not ally.ended_turn:
		var ral := _find(c, pi, func(card: Card) -> bool: return card.ally_energy > 0)
		if ral >= 0:
			return ral
	return -1


func _pick_reward(run: Run, choices: Array, policy: String) -> int:
	if choices.is_empty():
		return 0
	if run.reward_kind == "relic":
		if policy == "naive":
			return 0
		# Prefer offensive/utility relics; else first.
		for i in range(choices.size()):
			if String(choices[i].get("effect", "")) in ["attack_bonus", "max_energy"]:
				return i
		return 0
	# card reward
	if policy == "naive":
		return 0
	# Prefer cards that deepen coordination; else the biggest attack.
	for i in range(choices.size()):
		var card: Card = choices[i]
		if card.vulnerable > 0 or card.ally_block > 0 or card.ally_energy > 0 or card.taunt:
			return i
	var best := 0
	var best_d := -1
	for i in range(choices.size()):
		if choices[i].damage > best_d:
			best_d = choices[i].damage
			best = i
	return best


# --- helpers --------------------------------------------------------------

func _threatened(c: Combat, pidx: int) -> int:
	var m := c.boss.current_move()
	var v := int(m.get("value", 0)) + c.boss.strength
	match String(m.get("type", "")):
		"attack", "leech":
			return v if c.boss_target_index() == pidx else 0
		"attack_all":
			return v
		_:
			return 0


func _find(c: Combat, pi: int, pred: Callable) -> int:
	var ps: PlayerState = c.players[pi]
	for i in range(ps.hand.size()):
		if c.can_play(pi, i) and pred.call(ps.hand[i]):
			return i
	return -1


func _find_best_damage(c: Combat, pi: int) -> int:
	var ps: PlayerState = c.players[pi]
	var best := -1
	var best_d := 0
	for i in range(ps.hand.size()):
		if c.can_play(pi, i) and ps.hand[i].damage > best_d:
			best_d = ps.hand[i].damage
			best = i
	return best


func _tally_combo(card: Card, stats: Dictionary) -> void:
	if card.vulnerable > 0:
		stats["combos"]["expose"] += 1
	if card.ally_block > 0:
		stats["combos"]["cover"] += 1
	if card.ally_energy > 0:
		stats["combos"]["rally"] += 1
	if card.taunt:
		stats["combos"]["taunt"] += 1


func _report(title: String, agg: Dictionary) -> void:
	print("── %s ──" % title)
	print("  win rate:        %.0f%%  (%d / %d)" % [agg["wins"] * 100.0 / RUNS, agg["wins"], RUNS])
	var loss_parts: Array = []
	for e in range(Run.ENCOUNTERS.size()):
		loss_parts.append("T%d: %d" % [e + 1, int(agg["lost_at"].get(e + 1, 0))])
	print("  losses:          " + "   ".join(loss_parts))
	for enc in range(Run.ENCOUNTERS.size()):
		if agg["rounds_n"].has(enc):
			var avg: float = agg["rounds"][enc] / float(agg["rounds_n"][enc])
			print("  avg rounds — Titan %d: %.1f  (over %d clears)" % [enc + 1, avg, agg["rounds_n"][enc]])
	print("  avg lowest HP:   %.0f / %d" % [agg["min_hp_sum"] / RUNS, Run.PLAYER_HP])
	print("  combos/run:      expose %.1f  cover %.1f  rally %.1f  taunt %.1f" % [
		agg["combos"]["expose"] / RUNS, agg["combos"]["cover"] / RUNS,
		agg["combos"]["rally"] / RUNS, agg["combos"]["taunt"] / RUNS])
	print("")
