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

enum Phase { MAP, COMBAT, EVENT, CAMPFIRE, SHOP, REWARD, WON, LOST, BOON }

const ENCOUNTERS := ["stone_warden", "gale_serpent", "drowned_colossus", "sunken_warden"]
const REST_HEAL := 9   # a campfire "rest" patches you up
const MIN_DECK := 5    # you may thin a deck, but not into nothing
# Gold is a SHARED purse — "do we buy your card or my relic?" is a co-op decision.
const GOLD_FIGHT := 25
const GOLD_ELITE := 55
const GOLD_BOSS := 80
const PRICE_CARD := 55
const PRICE_RELIC := 135
const PRICE_POTION := 45
const PRICE_REMOVE := 70   # rises each time it's used in a run
const POTION_SLOTS := 3    # per hunter, same shape StS's 2-3 slots (backlog #26)
const REWARD_CHOICES := 3
## The save-file shape this build writes and fully understands. RunSave reads
## this rather than keeping its own copy — a save's "version" key and the
## constant that gates loading it used to live in two different files, which
## meant bumping one without the other would silently break every save
## (backlog #35).
const SAVE_VERSION := 2
## How often each rarity is offered, relative to the others. Tune these before
## adding more cards — they move perceived variety far more than raw pool size.
const RARITY_WEIGHT := {"common": 55, "uncommon": 35, "rare": 10}
const HEAL_BETWEEN := 4  # hunters recover a little after each beast falls
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
var boon: Dictionary = {}        # the run-start choice being offered (BOON phase, #31)
var boon_result: String = ""     # flavour text for the boon just taken
var _seen_events: Array = []     # don't repeat an event while fresh ones remain
var campfire_done: Array = []    # per hunter: have they taken their campfire action?
var gold: int = 0                # the team's shared purse
var shop_stock: Array = []       # SHOP phase: [{kind, slot, id, name, text, price, sold}]
var removes_bought: int = 0      # each removal costs more than the last
var ascension: int = 0           # difficulty tier (0 = base); see data/ascension.json
var _asc: Dictionary = {}        # cumulative ascension modifiers
var _unlocked_wins: int = Content.UNLOCKED_ALL  # career gate on locked content (backlog #42)
var combat: Combat
var names: Array = []
var decks: Array = []            # Array[Array[Card]] per hunter — persists across encounters
var hp: Array = []               # carried current hp per hunter
var max_hp: Array = []
var team_relics: Array = []      # Array[Dictionary] — persistent team passives
var potions: Array = []          # Array[Array[Dictionary]] per hunter — held consumables (backlog #26)
var player_passives: Array = []  # per-hunter character signature passives
## A run summary the end screen can show (backlog #39) — accumulation only, no
## view code. sync() folds a fight's Combat totals in here exactly once, right
## when that fight ends (guarded the same way the WIN/LOSE branch below already
## is), so a save mid-fight can't double-count a partial fight's numbers.
var stats: Dictionary = {
	"damage_dealt": 0, "highest_climb": 0, "cards_played": 0,
	"turns_taken": 0, "beasts_felled": 0, "died_to": "",
}
var reward_kind: String = "card" # "card" | "relic" — what this REWARD offers
var reward_choices: Array = []   # per hunter: Array of card OR relic choices (by reward_kind)
var reward_picked: Array = []    # Array[bool]
# A node can owe TWO rewards (elites and Titans pay a card and then a relic).
# The second is held here and opened once everyone has taken the first.
var _queued_reward: String = ""

var _seed: int
var _rng := RandomNumberGenerator.new()

func _init(p_decks: Array, p_names: Array, seed_value: int = 0, p_passives: Array = [],
		p_ascension: int = 0, p_unlocked_wins: int = Content.UNLOCKED_ALL) -> void:
	_seed = seed_value
	player_passives = p_passives
	ascension = p_ascension
	_asc = Content.ascension_mods(ascension)
	_unlocked_wins = p_unlocked_wins
	if seed_value == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value
	for i in range(p_names.size()):
		decks.append((p_decks[i] as Array).duplicate())
		names.append(String(p_names[i]))
		var start_hp: int = maxi(10, PLAYER_HP - int(_asc.get("player_hp", 0)))
		max_hp.append(start_hp)
		hp.append(start_hp)
		potions.append([])
	map = RunMap.new(ENCOUNTERS.size(), _rng)

func start() -> void:
	phase = Phase.MAP

func player_count() -> int:
	return names.size()

func total_encounters() -> int:
	return ENCOUNTERS.size()

func is_over() -> bool:
	return phase == Phase.WON or phase == Phase.LOST

## The run's seed, readable so it can be shown and shared (backlog #38). 0
## means "rolled randomly at start" (see _init) rather than a real seed.
func seed_value() -> int:
	return _seed

## The career-wins gate this run was built with (backlog #42) — readable so a
## resumed run's host can carry it forward instead of losing it on reload.
func unlocked_wins() -> int:
	return _unlocked_wins


# --- saving ---------------------------------------------------------------
#
# A run is 24 nodes and the better part of an hour, so it has to survive putting
# the game down — mid-fight included (backlog #14): Combat has its own
# to_dict/from_dict, so an in-progress fight (hands, piles, footholds, block,
# the boss's move pattern) rides along inside this dict rather than being
# skipped. The one thing that's genuinely NOT saved is the live real-time grip
# timer — that's a client-side clock (see Combat's header), so a resumed climb
# between holds lands you back on the safe hold you started climbing from.
#
# The RNG's state travels too. Without it, quitting and resuming would reroll
# every future reward — a save/quit button that doubles as a reroll button.

func to_dict() -> Dictionary:
	var deck_dicts: Array = []
	for deck in decks:
		var one: Array = []
		for c in deck:
			one.append((c as Card).to_dict())
		deck_dicts.append(one)
	# Reward choices are Cards for a card reward and plain relic dicts otherwise.
	var choices: Array = []
	for per_player in reward_choices:
		var one2: Array = []
		for rc in per_player:
			one2.append((rc as Card).to_dict() if rc is Card else rc)
		choices.append(one2)
	return {
		"version": SAVE_VERSION,
		"phase": phase, "encounter_index": encounter_index,
		"map": map.to_dict() if map != null else {},
		"map_row": map_row, "map_col": map_col,
		"node_type": node_type, "beast_id": beast_id,
		"event": event, "event_result": event_result, "seen_events": _seen_events,
		"boon": boon, "boon_result": boon_result,
		"campfire_done": campfire_done, "gold": gold,
		"shop_stock": shop_stock, "removes_bought": removes_bought,
		"ascension": ascension, "unlocked_wins": _unlocked_wins,
		"names": names, "decks": deck_dicts,
		"hp": hp, "max_hp": max_hp,
		"team_relics": team_relics, "potions": potions, "player_passives": player_passives,
		"stats": stats,
		"reward_kind": reward_kind, "reward_choices": choices,
		"reward_picked": reward_picked, "queued_reward": _queued_reward,
		"seed": _seed, "rng_state": str(_rng.state),  # a uint64; JSON floats would round it
		"combat": combat.to_dict() if (phase == Phase.COMBAT and combat != null) else {},
	}


static func from_dict(d: Dictionary) -> Run:
	# _init regenerates a map and burns RNG; both are overwritten straight after.
	var r := Run.new([], [], int(d.get("seed", 0)),
		d.get("player_passives", []) as Array, int(d.get("ascension", 0)),
		int(d.get("unlocked_wins", Content.UNLOCKED_ALL)))
	r.phase = int(d.get("phase", Phase.MAP))
	r.encounter_index = int(d.get("encounter_index", 0))
	r.map = RunMap.from_dict(d.get("map", {}))
	r.map_row = int(d.get("map_row", -1))
	r.map_col = int(d.get("map_col", 0))
	r.node_type = String(d.get("node_type", ""))
	r.beast_id = String(d.get("beast_id", ""))
	r.event = d.get("event", {})
	r.event_result = String(d.get("event_result", ""))
	r._seen_events = (d.get("seen_events", []) as Array).duplicate()
	r.boon = d.get("boon", {})
	r.boon_result = String(d.get("boon_result", ""))
	r.campfire_done = (d.get("campfire_done", []) as Array).duplicate()
	r.gold = int(d.get("gold", 0))
	r.shop_stock = (d.get("shop_stock", []) as Array).duplicate(true)
	r.removes_bought = int(d.get("removes_bought", 0))
	r.names = (d.get("names", []) as Array).duplicate()
	r.hp = (d.get("hp", []) as Array).duplicate()
	r.max_hp = (d.get("max_hp", []) as Array).duplicate()
	r.team_relics = (d.get("team_relics", []) as Array).duplicate(true)
	r.potions = (d.get("potions", []) as Array).duplicate(true)
	if r.potions.size() < r.names.size():  # old saves predate potions — backfill empty slots
		for _i in range(r.names.size() - r.potions.size()):
			r.potions.append([])
	# A save from before #39 (or one missing an individual stat added later)
	# just starts that stat at the default r._init() already gave it — same
	# additive-backfill shape the potions block above uses, no version bump needed.
	var loaded_stats: Dictionary = (d.get("stats", {}) as Dictionary).duplicate()
	for key in r.stats:
		if not loaded_stats.has(key):
			loaded_stats[key] = r.stats[key]
	r.stats = loaded_stats
	r.decks = []
	for one in d.get("decks", []):
		var deck: Array = []
		for cd in one:
			deck.append(Card.from_dict(cd))
		r.decks.append(deck)
	r.reward_kind = String(d.get("reward_kind", "card"))
	r.reward_choices = []
	for per_player in d.get("reward_choices", []):
		var one2: Array = []
		for rc in per_player:
			one2.append(Card.from_dict(rc) if r.reward_kind == "card" else rc)
		r.reward_choices.append(one2)
	r.reward_picked = (d.get("reward_picked", []) as Array).duplicate()
	r._queued_reward = String(d.get("queued_reward", ""))
	r._rng.state = int(String(d.get("rng_state", "0")))
	var combat_d: Dictionary = d.get("combat", {})
	if r.phase == Phase.COMBAT and not combat_d.is_empty():
		r.combat = Combat.from_dict(combat_d)
	elif r.phase == Phase.COMBAT:
		# Should never happen post-#14 (save always includes combat when the
		# phase is COMBAT) — a defensive fallback for an old or malformed save.
		r.phase = Phase.MAP
	return r

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
		"shop":
			_begin_shop()
		_:  # fight / elite / boss
			_start_encounter()
	return true

func _gold_for(kind: String) -> int:
	match kind:
		"elite": return GOLD_ELITE
		"boss": return GOLD_BOSS
		_: return GOLD_FIGHT


## Stock a shop: a couple of cards from each hunter's own pool, team relics, and
## the single most valuable service in a deckbuilder — removing a card.
func _begin_shop() -> void:
	phase = Phase.SHOP
	shop_stock = []
	for slot in range(names.size()):
		var pool: Array = Content.reward_pool(_character_of(slot), _unlocked_wins)
		for _n in range(2):
			if pool.is_empty():
				break
			var cid := String(pool[_rng.randi_range(0, pool.size() - 1)])
			pool.erase(cid)
			var card := Content.make_card(cid)
			shop_stock.append({"kind": "card", "slot": slot, "id": cid, "name": card.name,
				"text": card.text, "price": PRICE_CARD, "sold": false})
	var relics: Array = Content.relic_pool(_unlocked_wins)
	for _r in range(2):
		if relics.is_empty():
			break
		var rid := String(relics[_rng.randi_range(0, relics.size() - 1)])
		relics.erase(rid)
		var relic := Content.make_relic(rid)
		shop_stock.append({"kind": "relic", "slot": -1, "id": rid,
			"name": String(relic.get("name", rid)), "text": String(relic.get("text", "")),
			"price": PRICE_RELIC, "sold": false})
	var pots: Array = Content.potion_pool()
	for slot3 in range(names.size()):
		if pots.is_empty():
			break
		var pid := String(pots[_rng.randi_range(0, pots.size() - 1)])
		pots.erase(pid)
		var potion := Content.make_potion(pid)
		shop_stock.append({"kind": "potion", "slot": slot3, "id": pid,
			"name": String(potion.get("name", pid)), "text": String(potion.get("text", "")),
			"price": PRICE_POTION, "sold": false})
	for slot2 in range(names.size()):
		shop_stock.append({"kind": "remove", "slot": slot2, "id": "", "name": "Thin the deck",
			"text": "Remove a card from %s's deck for good." % names[slot2],
			"price": remove_price(), "sold": false})


## Removal gets pricier each time — you can't just delete your whole deck.
func remove_price() -> int:
	return PRICE_REMOVE + removes_bought * 25


## Buy stock item `index`. A removal also names a card in that hunter's deck.
func buy(index: int, card_index: int = -1) -> bool:
	if phase != Phase.SHOP or index < 0 or index >= shop_stock.size():
		return false
	var item: Dictionary = shop_stock[index]
	if bool(item["sold"]) or gold < int(item["price"]):
		return false
	var slot := int(item["slot"])
	match String(item["kind"]):
		"card":
			decks[slot].append(Content.make_card(String(item["id"])))
		"relic":
			team_relics.append(Content.make_relic(String(item["id"])))
		"potion":
			if potions[slot].size() >= POTION_SLOTS:
				return false
			potions[slot].append(Content.make_potion(String(item["id"])))
		"remove":
			var deck: Array = decks[slot]
			if card_index < 0 or card_index >= deck.size() or deck.size() <= MIN_DECK:
				return false
			deck.remove_at(card_index)
			removes_bought += 1
			# the next removal in this shop reprices immediately
			for other in shop_stock:
				if String(other["kind"]) == "remove" and not bool(other["sold"]):
					other["price"] = remove_price()
		_:
			return false
	gold -= int(item["price"])
	item["sold"] = true
	return true


## Walk away from the shop and carry on up the route.
func leave_shop() -> bool:
	if phase != Phase.SHOP:
		return false
	_after_node()
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
			hp[slot] = mini(hp[slot] + maxi(1, REST_HEAL - int(_asc.get("rest_heal", 0))), max_hp[slot])
		"remove":
			if card_index < 0 or card_index >= deck.size() or deck.size() <= MIN_DECK:
				return false
			deck.remove_at(card_index)
		"upgrade":
			if card_index < 0 or card_index >= deck.size():
				return false
			var c: Card = deck[card_index]
			if c.upgraded or c.status:  # a curse has nothing to sharpen — only remove it
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
	_apply_effect_block(eff)
	var rw := String(eff.get("reward", ""))
	if rw != "":
		_begin_reward(rw)
	else:
		_after_node()
	return true


## The generic effect-application rule shared by an event choice and a run-start
## boon (#31) — a boon IS an event choice, just offered before the map rather
## than found on it, so it reads the exact same keys (see events.json's
## _comment): max_hp, heal, gold, relic, remove_card, sharpen_card, curse_card.
func _apply_effect_block(eff: Dictionary) -> void:
	var mh := int(eff.get("max_hp", 0))
	var h := int(eff.get("heal", 0))
	for i in range(names.size()):
		if mh != 0:
			max_hp[i] = maxi(1, max_hp[i] + mh)
		if h != 0:
			# Events bruise but never end a run — no death without a fight.
			hp[i] = clampi(hp[i] + h, 1, max_hp[i])
		hp[i] = mini(hp[i], max_hp[i])
	# Events can ask a price, but never put the purse in debt.
	gold = maxi(0, gold + int(eff.get("gold", 0)))
	if bool(eff.get("relic", false)):
		var pool: Array = Content.relic_pool(_unlocked_wins)
		if not pool.is_empty():
			team_relics.append(Content.make_relic(String(pool[_rng.randi_range(0, pool.size() - 1)])))
	# Deck-touching effects (backlog #17): a random card per hunter, same "whole
	# team" shape heal/max_hp already use above. Never below MIN_DECK, and
	# sharpening quietly no-ops for a deck that's already fully upgraded.
	if bool(eff.get("remove_card", false)):
		for i in range(names.size()):
			var deck: Array = decks[i]
			if deck.size() > MIN_DECK:
				deck.remove_at(_rng.randi_range(0, deck.size() - 1))
	if bool(eff.get("sharpen_card", false)):
		for i in range(names.size()):
			var deck2: Array = decks[i]
			var candidates: Array = []
			for j in range(deck2.size()):
				if not (deck2[j] as Card).upgraded:
					candidates.append(j)
			if not candidates.is_empty():
				var idx := int(candidates[_rng.randi_range(0, candidates.size() - 1)])
				deck2[idx] = (deck2[idx] as Card).upgraded_copy()
	# curse_card (backlog #27): names a status card id and shuffles one copy into
	# EACH hunter's own deck, same "whole team" shape remove_card/sharpen_card
	# above already use. Unlike a reward, this is not a choice — the whole point
	# of a status card is that you don't get to pick whether you're clogged.
	var cc := String(eff.get("curse_card", ""))
	if cc != "":
		for i in range(names.size()):
			decks[i].append(Content.make_card(cc))
	# Potions (backlog #37): an event can trade in whatever's in your pack too,
	# same "whole team" shape as the effects above. "potion" names a specific id
	# (a guaranteed find, same shape curse_card names a specific card); "random_potion"
	# pulls one from the pool at random (same shape "relic" already does for
	# relics); "take_potion" is the gamble — one random HELD potion per hunter is
	# lost, a clean no-op for a hunter carrying none. All three respect the
	# POTION_SLOTS cap the way _grant_potions() does: a full inventory just
	# doesn't grow.
	var pid := String(eff.get("potion", ""))
	if pid != "":
		for i in range(names.size()):
			if potions[i].size() < POTION_SLOTS:
				potions[i].append(Content.make_potion(pid))
	if bool(eff.get("random_potion", false)):
		var ppool: Array = Content.potion_pool()
		if not ppool.is_empty():
			for i in range(names.size()):
				if potions[i].size() < POTION_SLOTS:
					potions[i].append(Content.make_potion(String(ppool[_rng.randi_range(0, ppool.size() - 1)])))
	if bool(eff.get("take_potion", false)):
		for i in range(names.size()):
			if not potions[i].is_empty():
				potions[i].remove_at(_rng.randi_range(0, potions[i].size() - 1))


## A free choice of 3-4 offered once, before the first map step — same idiom as
## Neow in Slay the Spire (backlog #31). Returns false (a no-op) if boons.json
## is empty.
##
## Deliberately NOT called from start() yet. game_3d.gd's phase router has no
## 3D scene for "boon" — its own doc comment calls an unhandled phase "a bug...
## it holds the current screen and shouts, rather than swapping to something
## arbitrary mid-run" — and GameHost.start_new_run() calls Run.start() for
## every real co-op game. Wiring this in before that screen exists would
## soft-lock every new run at the moment it begins, not just ship an invisible
## feature. This method is the tested, ready-to-call engine half; hooking it
## into start() belongs with the screen that can show it (needs a screen).
func offer_run_start_boon() -> bool:
	var ids: Array = Content.list_boons()
	if ids.is_empty():
		return false
	var pool: Array = ids.duplicate()
	var n: int = mini(4, pool.size())
	var choices: Array = []
	for _i in range(n):
		var idx := _rng.randi_range(0, pool.size() - 1)
		var bid := String(pool[idx])
		pool.remove_at(idx)
		choices.append(Content.make_boon(bid))
	boon = {"choices": choices}
	boon_result = ""
	phase = Phase.BOON
	return true


## Resolve the run-start boon. Like an event, it's a shared decision — either
## hunter may answer — and applies immediately rather than opening a reward
## screen, so it needs none of pick_event's "reward" routing.
func pick_boon(choice: int) -> bool:
	if phase != Phase.BOON:
		return false
	var choices: Array = boon.get("choices", [])
	if choice < 0 or choice >= choices.size():
		return false
	var picked: Dictionary = choices[choice]
	var eff: Dictionary = picked.get("effects", {})
	boon_result = String(picked.get("result", ""))
	_apply_effect_block(eff)
	phase = Phase.MAP
	return true


## The host calls this after every combat command to advance run state.
func sync() -> void:
	if phase != Phase.COMBAT or combat == null or not combat.is_over():
		return
	# Backlog #39: fold this fight's totals in exactly once — the guard above
	# already stops sync() from re-entering once phase has moved off COMBAT.
	stats["damage_dealt"] = int(stats["damage_dealt"]) + combat.damage_dealt_total
	stats["cards_played"] = int(stats["cards_played"]) + combat.cards_played_total
	stats["highest_climb"] = maxi(int(stats["highest_climb"]), combat.highest_climb)
	stats["turns_taken"] = int(stats["turns_taken"]) + combat.round_num
	if combat.result() == Combat.Result.WIN:
		stats["beasts_felled"] = int(stats["beasts_felled"]) + 1
		_bank_hp()
		gold += _gold_for(node_type)
		_grant_potions()
		# EVERY beast pays a card — a hard fight that pays nothing you wanted reads
		# as unfair, and card rewards are the run's main deckbuilding decision.
		# Elites and Titans pay a relic on top, taken after the card.
		_queued_reward = "relic" if node_type in ["elite", "boss"] else ""
		_begin_reward("card")
	else:
		stats["died_to"] = combat.boss.name
		phase = Phase.LOST

## One reward is settled. If this node still owes another (an elite's or Titan's
## relic, after its card), open that instead of releasing the run to the map.
func _finish_reward() -> void:
	if _queued_reward != "":
		var next_kind := _queued_reward
		_queued_reward = ""
		_begin_reward(next_kind)
	else:
		_after_node()


## Where the run goes once a node is fully resolved: on to the map, or done.
func _after_node() -> void:
	if map != null and map.is_last_row(map_row):
		phase = Phase.WON
	else:
		phase = Phase.MAP

## Use a held potion mid-fight — applies its effect via Combat and empties the
## slot. Potion effects (heal/block/strength/energy/draw) only mean something
## while a fight is live, so this is COMBAT-only, unlike discard_potion below.
func use_potion(slot: int, index: int) -> bool:
	if phase != Phase.COMBAT or combat == null:
		return false
	if slot < 0 or slot >= potions.size() or index < 0 or index >= potions[slot].size():
		return false
	var p: Dictionary = potions[slot][index]
	if not combat.use_potion(slot, String(p.get("effect", "")), int(p.get("value", 0))):
		return false
	potions[slot].remove_at(index)
	return true

## Throw a potion away unused, freeing the slot — legal any time you're
## carrying one, not just mid-fight, since a bad potion clogging your one open
## slot before a fight shouldn't have to wait for one.
func discard_potion(slot: int, index: int) -> bool:
	if slot < 0 or slot >= potions.size() or index < 0 or index >= potions[slot].size():
		return false
	potions[slot].remove_at(index)
	return true

## Every beast a hunter fells pays a potion too, if their slots aren't full —
## same "found from fights" the item asked for, guaranteed rather than a coin
## flip so it stays simple to test and to reason about.
func _grant_potions() -> void:
	var pool: Array = Content.potion_pool()
	if pool.is_empty():
		return
	for i in range(names.size()):
		if potions[i].size() >= POTION_SLOTS:
			continue
		var pid := String(pool[_rng.randi_range(0, pool.size() - 1)])
		potions[i].append(Content.make_potion(pid))

## Decline the reward. Keeping a deck lean is a real strategy, so skipping has
## to be a first-class option rather than a forced pick.
func skip_reward(slot: int) -> bool:
	if phase != Phase.REWARD:
		return false
	if slot < 0 or slot >= names.size() or bool(reward_picked[slot]):
		return false
	reward_picked[slot] = true
	if _all_picked():
		_finish_reward()
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
		_finish_reward()

# --- internals ------------------------------------------------------------

func _start_encounter() -> void:
	beast_id = _roll_beast()
	var combatants: Array = []
	for i in range(names.size()):
		var c := Combatant.new(names[i], max_hp[i])
		c.hp = hp[i]  # carry damage between encounters
		combatants.append(c)
	var boss := Content.build_boss(beast_id if beast_id != "" else ENCOUNTERS[encounter_index])
	var hp_pct := int(_asc.get("boss_hp_pct", 0))
	if hp_pct > 0:  # ascension: thicker hides
		boss.max_hp = int(boss.max_hp * (100 + hp_pct) / 100.0)
		boss.hp = boss.max_hp
	boss.strength += int(_asc.get("boss_strength", 0))  # ascension: meaner beasts
	var mods := relic_totals()
	# Distinct per-encounter seed so each fight shuffles differently but reproducibly.
	combat = Combat.new(decks, combatants, boss, _encounter_seed(),
		mods["energy"], mods["attack"], mods["block"], mods["strength"], player_passives, mods)
	combat.start()
	phase = Phase.COMBAT

## Sum the team's relic effects. The flat five feed Combat's old parameters; the
## rest are rule changes Combat and the client read from `mods`.
func relic_totals() -> Dictionary:
	var t := {"energy": 0, "attack": 0, "block": 0, "heal": 0, "strength": 0}
	for key in ["start_foothold", "fall_safe", "rhythm_keeps", "threshold", "chip",
			"sigil_bonus", "vuln_bonus", "draw", "shake_resist",
			"grip_seconds", "timing_zone",
			"block_carries", "no_buck", "soft_fall", "energy_handoff"]:
		t[key] = 0
	for r in team_relics:
		_apply_relic_effect(t, String(r.get("effect", "")), int(r.get("value", 0)))
		# A downside (#30) is just a second {effect, value} pair on the same
		# relic, folded in by the identical generic rule — no special case.
		if r.has("downside_effect"):
			_apply_relic_effect(t, String(r.get("downside_effect", "")), int(r.get("downside_value", 0)))
	return t

func _apply_relic_effect(t: Dictionary, e: String, v: int) -> void:
	match e:
		"max_energy": t["energy"] += v
		"attack_bonus": t["attack"] += v
		"round_block": t["block"] += v
		"heal_on_clear": t["heal"] += v
		"start_strength": t["strength"] += v
		_:
			if t.has(e):
				t[e] += v

func _encounter_seed() -> int:
	if _seed == 0:
		return 0  # keep it random
	return _seed + (map_row + 1) * 101 + map_col

func _bank_hp() -> void:
	var heal: int = maxi(0, HEAL_BETWEEN - int(_asc.get("heal_between", 0))) + int(relic_totals()["heal"])
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
	for i in range(names.size()):
		# Cards come from that hunter's own pool, so each can draft their archetype.
		var pool: Array = Content.relic_pool(_unlocked_wins) if reward_kind == "relic" else Content.reward_pool(_character_of(i), _unlocked_wins)
		reward_choices.append(_roll_choices(pool))
		reward_picked.append(false)

## The character id a hunter is playing (from their signature passive).
func _character_of(slot: int) -> String:
	if slot < 0 or slot >= player_passives.size():
		return ""
	return String((player_passives[slot] as Dictionary).get("character", ""))

func _roll_choices(pool: Array) -> Array:
	var ids: Array = pool.duplicate()
	var out: Array = []
	var n: int = mini(maxi(1, REWARD_CHOICES - int(_asc.get("reward_choices", 0))), ids.size())
	for _k in range(n):
		var idx := _weighted_index(ids)
		var id := String(ids[idx])
		out.append(Content.make_relic(id) if reward_kind == "relic" else Content.make_card(id))
		ids.remove_at(idx)
	return out


## Pick an index from `ids`, weighted by rarity, so commons carry the drafting and
## a rare feels like a find rather than another option. Without this, a 40-card
## pool offers its best payoff as often as its filler.
##
## With the current catalog (61 common / 61 uncommon / 20 rare) these weights land
## at roughly 59% / 37% / 4% of cards actually offered.
func _weighted_index(ids: Array) -> int:
	if ids.size() <= 1:
		return 0
	if reward_kind == "relic":
		return _rng.randi_range(0, ids.size() - 1)  # relics have no rarity — stay uniform
	var weights: Array = []
	var total := 0
	for id in ids:
		var w: int = int(RARITY_WEIGHT.get(Content.card_rarity(String(id)), RARITY_WEIGHT["common"]))
		weights.append(w)
		total += w
	if total <= 0:
		return _rng.randi_range(0, ids.size() - 1)
	var roll := _rng.randi_range(0, total - 1)
	for i in range(weights.size()):
		roll -= int(weights[i])
		if roll < 0:
			return i
	return weights.size() - 1

func _all_picked() -> bool:
	for picked in reward_picked:
		if not picked:
			return false
	return true
