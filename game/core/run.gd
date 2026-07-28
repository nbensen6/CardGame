## A run — the roguelike unit of play (CLAUDE.md §6, build step 4 meta-progression).
## Sequences a party through several Titan encounters; between wins each hunter
## picks a card to add to their persistent deck. Pure /core: no rendering, input,
## or net — the host drives it and turns it into snapshots.
##
## Phases: COMBAT (fighting a Titan) -> REWARD (each hunter picks a card) ->
##         next COMBAT -> ... -> WON (all Titans felled) or LOST (a hunter fell).
class_name Run
extends RefCounted

enum Phase { COMBAT, REWARD, WON, LOST }

const ENCOUNTERS := ["stone_warden", "gale_serpent", "drowned_colossus", "sunken_warden"]
const REWARD_CHOICES := 3
const HEAL_BETWEEN := 6  # hunters recover a little after each Titan falls
const PLAYER_HP := 42

var phase: int = Phase.COMBAT
var encounter_index: int = 0
var combat: Combat
var names: Array = []
var decks: Array = []            # Array[Array[Card]] per hunter — persists across encounters
var hp: Array = []               # carried current hp per hunter
var max_hp: Array = []
var team_relics: Array = []      # Array[Dictionary] — persistent team passives
var reward_kind: String = "card" # "card" | "relic" — what this REWARD offers
var reward_choices: Array = []   # per hunter: Array of card OR relic choices (by reward_kind)
var reward_picked: Array = []    # Array[bool]

var _seed: int
var _rng := RandomNumberGenerator.new()

func _init(p_decks: Array, p_names: Array, seed_value: int = 0) -> void:
	_seed = seed_value
	if seed_value == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value
	for i in range(p_names.size()):
		decks.append((p_decks[i] as Array).duplicate())
		names.append(String(p_names[i]))
		max_hp.append(PLAYER_HP)
		hp.append(PLAYER_HP)

func start() -> void:
	_start_encounter()

func player_count() -> int:
	return names.size()

func total_encounters() -> int:
	return ENCOUNTERS.size()

func is_over() -> bool:
	return phase == Phase.WON or phase == Phase.LOST

## The host calls this after every combat command to advance run state.
func sync() -> void:
	if phase != Phase.COMBAT or combat == null or not combat.is_over():
		return
	if combat.result() == Combat.Result.WIN:
		_bank_hp()
		if encounter_index + 1 >= ENCOUNTERS.size():
			phase = Phase.WON
		else:
			_begin_reward()
	else:
		phase = Phase.LOST

## Hunter `slot` picks reward option `choice`. When all have picked, the next
## encounter begins.
func pick_reward(slot: int, choice: int) -> void:
	if phase != Phase.REWARD:
		return
	if slot < 0 or slot >= names.size() or reward_picked[slot]:
		return
	var choices: Array = reward_choices[slot]
	if choice < 0 or choice >= choices.size():
		return
	if reward_kind == "relic":
		team_relics.append(choices[choice])  # relics are team-wide
	else:
		decks[slot].append(choices[choice])  # cards go to that hunter's deck
	reward_picked[slot] = true
	if _all_picked():
		encounter_index += 1
		_start_encounter()

# --- internals ------------------------------------------------------------

func _start_encounter() -> void:
	var combatants: Array = []
	for i in range(names.size()):
		var c := Combatant.new(names[i], max_hp[i])
		c.hp = hp[i]  # carry damage between encounters
		combatants.append(c)
	var boss := Content.build_boss(ENCOUNTERS[encounter_index])
	var mods := relic_totals()
	# Distinct per-encounter seed so each fight shuffles differently but reproducibly.
	combat = Combat.new(decks, combatants, boss, _encounter_seed(),
		mods["energy"], mods["attack"], mods["block"], mods["strength"])
	combat.start()
	phase = Phase.COMBAT

## Sum the team's relic effects into flat modifiers.
func relic_totals() -> Dictionary:
	var t := {"energy": 0, "attack": 0, "block": 0, "heal": 0, "strength": 0}
	for r in team_relics:
		match String(r.get("effect", "")):
			"max_energy": t["energy"] += int(r.get("value", 0))
			"attack_bonus": t["attack"] += int(r.get("value", 0))
			"round_block": t["block"] += int(r.get("value", 0))
			"heal_on_clear": t["heal"] += int(r.get("value", 0))
			"start_strength": t["strength"] += int(r.get("value", 0))
	return t

func _encounter_seed() -> int:
	if _seed == 0:
		return 0  # keep it random
	return _seed + (encounter_index + 1) * 101

func _bank_hp() -> void:
	var heal: int = HEAL_BETWEEN + int(relic_totals()["heal"])
	for i in range(names.size()):
		hp[i] = mini(combat.players[i].combatant.hp + heal, max_hp[i])

func _begin_reward() -> void:
	phase = Phase.REWARD
	# Alternate: a card reward after odd Titans, a relic after even ones.
	reward_kind = "relic" if encounter_index % 2 == 1 else "card"
	reward_choices = []
	reward_picked = []
	var pool: Array = Content.relic_pool() if reward_kind == "relic" else Content.reward_pool()
	for _i in range(names.size()):
		reward_choices.append(_roll_choices(pool))
		reward_picked.append(false)

func _roll_choices(pool: Array) -> Array:
	var ids: Array = pool.duplicate()
	var out: Array = []
	var n: int = mini(REWARD_CHOICES, ids.size())
	for _k in range(n):
		var idx := _rng.randi_range(0, ids.size() - 1)
		var id := String(ids[idx])
		out.append(Content.make_relic(id) if reward_kind == "relic" else Content.make_card(id))
		ids.remove_at(idx)
	return out

func _all_picked() -> bool:
	for picked in reward_picked:
		if not picked:
			return false
	return true
