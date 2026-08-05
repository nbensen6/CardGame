## A run — the roguelike unit of play (CLAUDE.md §6, build step 4 meta-progression).
## Sequences a party through several Titan encounters; between wins each hunter
## picks a card to add to their persistent deck. Pure /core: no rendering, input,
## or net — the host drives it and turns it into snapshots.
##
## Phases: MAP (choose where to go) -> COMBAT / rest / treasure -> REWARD ->
##         back to MAP -> ... -> WON (all Titans felled) or LOST (a hunter fell).
##
## The route is a RunMap: rows of branching nodes, a Titan capping each act. The
## run walks it one row at a time; the node you step on decides what happens.
class_name Run
extends RefCounted

enum Phase { MAP, COMBAT, EVENT, CAMPFIRE, REWARD, WON, LOST }

const ENCOUNTERS := ["stone_warden", "gale_serpent", "drowned_colossus", "sunken_warden"]
const REST_HEAL := 12  # a campfire "rest" patches you up
const MIN_DECK := 5    # you may thin a deck, but not into nothing
const REWARD_CHOICES := 3
const HEAL_BETWEEN := 6  # hunters recover a little after each Titan falls
const PLAYER_HP := 42

var phase: int = Phase.MAP
var encounter_index: int = 0     # which act/Titan we're on (display + seeding)
var map: RunMap
var map_row: int = -1            # -1 = at the trailhead, nothing stepped on yet
var map_col: int = 0
var node_type: String = ""       # the node we're currently resolving
var beast_id: String = ""        # the beast this combat is against
var event: Dictionary = {}       # the event being resolved (EVENT phase)
var event_result: String = ""    # flavour text for the choice just taken
var _seen_events: Array = []     # don't repeat an event while fresh ones remain
var campfire_done: Array = []    # per hunter: have they taken their campfire action?
var combat: Combat
var names: Array = []
var decks: Array = []            # Array[Array[Card]] per hunter — persists across encounters
var hp: Array = []               # carried current hp per hunter
var max_hp: Array = []
var team_relics: Array = []      # Array[Dictionary] — persistent team passives
var player_passives: Array = []  # per-hunter character signature passives
var reward_kind: String = "card" # "card" | "relic" — what this REWARD offers
var reward_choices: Array = []   # per hunter: Array of card OR relic choices (by reward_kind)
var reward_picked: Array = []    # Array[bool]

var _seed: int
var _rng := RandomNumberGenerator.new()

func _init(p_decks: Array, p_names: Array, seed_value: int = 0, p_passives: Array = []) -> void:
	_seed = seed_value
	player_passives = p_passives
	if seed_value == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value
	for i in range(p_names.size()):
		decks.append((p_decks[i] as Array).duplicate())
		names.append(String(p_names[i]))
		max_hp.append(PLAYER_HP)
		hp.append(PLAYER_HP)
	map = RunMap.new(ENCOUNTERS.size(), _rng)

func start() -> void:
	phase = Phase.MAP

func player_count() -> int:
	return names.size()

func total_encounters() -> int:
	return ENCOUNTERS.size()

func is_over() -> bool:
	return phase == Phase.WON or phase == Phase.LOST

## Columns the party may step to from where they stand.
func available_nodes() -> Array:
	return map.available(map_row, map_col) if map != null else []

## Step onto a node in the next row and resolve it. Any hunter may choose — the
## route is a shared decision.
func pick_node(col: int) -> bool:
	if phase != Phase.MAP or map == null:
		return false
	if not available_nodes().has(col):
		return false
	map_row += 1
	map_col = col
	var node: Dictionary = map.node_at(map_row, map_col)
	node_type = String(node.get("type", "fight"))
	encounter_index = int(node.get("act", 0))
	match node_type:
		"rest":
			_begin_campfire()
		"treasure":
			_begin_reward("relic")
		"event":
			_begin_event()
		_:  # fight / elite / boss
			_start_encounter()
	return true

## A campfire: each hunter chooses to patch up, thin their deck, or sharpen a
## card. Deck *transformation* is what makes a deckbuilder sharpen instead of
## just bloat, and the campfire is its natural home.
func _begin_campfire() -> void:
	phase = Phase.CAMPFIRE
	campfire_done = []
	for _i in range(names.size()):
		campfire_done.append(false)


## `action` is "rest" | "remove" | "upgrade". Removing or sharpening needs
## `card_index` into that hunter's own deck. Each hunter acts once.
func campfire_action(slot: int, action: String, card_index: int = -1) -> bool:
	if phase != Phase.CAMPFIRE:
		return false
	if slot < 0 or slot >= names.size() or bool(campfire_done[slot]):
		return false
	var deck: Array = decks[slot]
	match action:
		"rest":
			hp[slot] = mini(hp[slot] + REST_HEAL, max_hp[slot])
		"remove":
			if card_index < 0 or card_index >= deck.size() or deck.size() <= MIN_DECK:
				return false
			deck.remove_at(card_index)
		"upgrade":
			if card_index < 0 or card_index >= deck.size():
				return false
			var c: Card = deck[card_index]
			if c.upgraded:
				return false
			deck[card_index] = c.upgraded_copy()
		_:
			return false
	campfire_done[slot] = true
	for done in campfire_done:
		if not done:
			return true
	_after_node()
	return true


## Roll an unseen event where possible, so a run doesn't repeat itself early.
func _begin_event() -> void:
	var ids: Array = Content.list_events()
	if ids.is_empty():
		_after_node()
		return
	var fresh: Array = []
	for id in ids:
		if not _seen_events.has(id):
			fresh.append(id)
	var pick_from: Array = fresh if not fresh.is_empty() else ids
	var id := String(pick_from[_rng.randi_range(0, pick_from.size() - 1)])
	_seen_events.append(id)
	event = Content.make_event(id)
	event_result = ""
	phase = Phase.EVENT


## Resolve an event choice. Like the route, it's a shared decision — either
## hunter may answer. Effects land immediately; a choice that offers a card or
## relic routes into the normal pick-1-of-3 screen.
func pick_event(choice: int) -> bool:
	if phase != Phase.EVENT:
		return false
	var choices: Array = event.get("choices", [])
	if choice < 0 or choice >= choices.size():
		return false
	var picked: Dictionary = choices[choice]
	var eff: Dictionary = picked.get("effects", {})
	event_result = String(picked.get("result", ""))
	var mh := int(eff.get("max_hp", 0))
	var h := int(eff.get("heal", 0))
	for i in range(names.size()):
		if mh != 0:
			max_hp[i] = maxi(1, max_hp[i] + mh)
		if h != 0:
			# Events bruise but never end a run — no death without a fight.
			hp[i] = clampi(hp[i] + h, 1, max_hp[i])
		hp[i] = mini(hp[i], max_hp[i])
	if bool(eff.get("relic", false)):
		var pool: Array = Content.relic_pool()
		if not pool.is_empty():
			team_relics.append(Content.make_relic(String(pool[_rng.randi_range(0, pool.size() - 1)])))
	var rw := String(eff.get("reward", ""))
	if rw != "":
		_begin_reward(rw)
	else:
		_after_node()
	return true


## The host calls this after every combat command to advance run state.
func sync() -> void:
	if phase != Phase.COMBAT or combat == null or not combat.is_over():
		return
	if combat.result() == Combat.Result.WIN:
		_bank_hp()
		# elites and Titans pay a relic; ordinary beasts pay a card
		_begin_reward("relic" if node_type in ["elite", "boss"] else "card")
	else:
		phase = Phase.LOST

## Where the run goes once a node is fully resolved: on to the map, or done.
func _after_node() -> void:
	if map != null and map.is_last_row(map_row):
		phase = Phase.WON
	else:
		phase = Phase.MAP

## Decline the reward. Keeping a deck lean is a real strategy, so skipping has
## to be a first-class option rather than a forced pick.
func skip_reward(slot: int) -> bool:
	if phase != Phase.REWARD:
		return false
	if slot < 0 or slot >= names.size() or bool(reward_picked[slot]):
		return false
	reward_picked[slot] = true
	if _all_picked():
		_after_node()
	return true

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
		_after_node()

# --- internals ------------------------------------------------------------

func _start_encounter() -> void:
	beast_id = _roll_beast()
	var combatants: Array = []
	for i in range(names.size()):
		var c := Combatant.new(names[i], max_hp[i])
		c.hp = hp[i]  # carry damage between encounters
		combatants.append(c)
	var boss := Content.build_boss(beast_id if beast_id != "" else ENCOUNTERS[encounter_index])
	var mods := relic_totals()
	# Distinct per-encounter seed so each fight shuffles differently but reproducibly.
	combat = Combat.new(decks, combatants, boss, _encounter_seed(),
		mods["energy"], mods["attack"], mods["block"], mods["strength"], player_passives)
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
	return _seed + (map_row + 1) * 101 + map_col

func _bank_hp() -> void:
	var heal: int = HEAL_BETWEEN + int(relic_totals()["heal"])
	for i in range(names.size()):
		hp[i] = mini(combat.players[i].combatant.hp + heal, max_hp[i])

## Pick the beast for this node: Titans follow the act order so the run still
## climaxes on a known ladder; fights and elites roll from their pool.
func _roll_beast() -> String:
	if node_type == "boss":
		return String(ENCOUNTERS[clampi(encounter_index, 0, ENCOUNTERS.size() - 1)])
	var pool := Content.beast_pool(node_type)
	if pool.is_empty():
		return String(ENCOUNTERS[0])
	return String(pool[_rng.randi_range(0, pool.size() - 1)])

func _begin_reward(kind: String) -> void:
	phase = Phase.REWARD
	reward_kind = kind
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
