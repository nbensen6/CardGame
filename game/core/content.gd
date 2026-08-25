## Loads game content from /data (cards, decks, bosses) into /core objects.
##
## Reading data files is a /core concern (rules live in data — CLAUDE.md §11);
## it does NOT couple /core to /views, /input, or /net. Combat and Run take
## already-built Card/Boss objects, so they stay testable without the filesystem.
class_name Content
extends RefCounted

const CARDS_PATH := "res://data/cards.json"
const BOSSES_PATH := "res://data/bosses.json"
const EVENTS_PATH := "res://data/events.json"
const RELICS_PATH := "res://data/relics.json"
const CHARACTERS_PATH := "res://data/characters.json"
const ASCENSION_PATH := "res://data/ascension.json"
const KEYWORDS_PATH := "res://data/keywords.json"
const ENCHANTS_PATH := "res://data/enchants.json"
const POTIONS_PATH := "res://data/potions.json"
const BOONS_PATH := "res://data/boons.json"

static var _cache: Dictionary = {}

## Sentinel `wins` value for relic_pool()/reward_pool(): every existing caller
## (menus, tests, the ~150 other content calls that predate backlog #42) omits
## `wins` and gets the whole pool, same as before this gate existed.
const UNLOCKED_ALL := 999999

static func _read_json(path: String) -> Dictionary:
	if _cache.has(path):
		return _cache[path]
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("Content: could not read " + path)
		return {}
	var data: Variant = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Content: malformed JSON in " + path)
		return {}
	_cache[path] = data
	return data

## Build one card by id from data (fresh instance).
static func make_card(id: String) -> Card:
	var cards: Dictionary = _read_json(CARDS_PATH).get("cards", {})
	if not cards.has(id):
		push_warning("Content: unknown card '%s'" % id)
		return Card.new()
	var cd: Dictionary = (cards[id] as Dictionary).duplicate()
	cd["id"] = id
	return Card.from_dict(cd)

## One keyword as {id, name, text}, for the card inspector. Empty if unknown.
static func keyword(id: String) -> Dictionary:
	var all: Dictionary = _read_json(KEYWORDS_PATH).get("keywords", {})
	if not all.has(id):
		return {}
	var k: Dictionary = (all[id] as Dictionary).duplicate()
	k["id"] = id
	return k


## Every keyword id — used by tests to prove nothing references a missing one.
## Underscore keys are editorial notes in the data file, not vocabulary.
static func keyword_ids() -> Array:
	var out: Array = []
	for id in (_read_json(KEYWORDS_PATH).get("keywords", {}) as Dictionary).keys():
		if not String(id).begins_with("_"):
			out.append(id)
	return out


## Every card id in cards.json, reachable or not — content-integrity checks
## walk the whole set rather than just what a reward pool happens to offer.
static func all_card_ids() -> Array:
	return (_read_json(CARDS_PATH).get("cards", {}) as Dictionary).keys()

## A card's rarity without building the whole Card — reward rolls ask for this
## once per candidate, so it stays a plain dictionary lookup.
static func card_rarity(id: String) -> String:
	var cards: Dictionary = _read_json(CARDS_PATH).get("cards", {})
	return String((cards.get(id, {}) as Dictionary).get("rarity", "common"))


## Build a hunter's starting deck from data.
static func build_starter_deck() -> Array:
	var deck: Array = []
	for id in _read_json(CARDS_PATH).get("starter_deck", []):
		deck.append(make_card(String(id)))
	return deck

## Card ids offered as rewards. A character draws from THEIR pool (their
## archetype cards plus neutrals) so a run can be drafted toward a build; the
## shared pool is the fallback. `wins` gates a card carrying an `unlock_wins`
## field (backlog #42) — a career total below that bar is filtered out. Always
## a fresh Array (safe for callers to filter/erase from without touching the cache).
static func reward_pool(character_id: String = "", wins: int = UNLOCKED_ALL) -> Array:
	var raw: Array
	if character_id != "":
		var chars: Dictionary = _read_json(CHARACTERS_PATH).get("characters", {})
		var own: Array = (chars.get(character_id, {}) as Dictionary).get("reward_pool", [])
		raw = own if not own.is_empty() else (_read_json(CARDS_PATH).get("reward_pool", []) as Array)
	else:
		raw = _read_json(CARDS_PATH).get("reward_pool", []) as Array
	var cards: Dictionary = _read_json(CARDS_PATH).get("cards", {})
	var out: Array = []
	for id_v in raw:
		var id := String(id_v)
		if int((cards.get(id, {}) as Dictionary).get("unlock_wins", 0)) <= wins:
			out.append(id)
	return out

## Relic ids that can be offered as rewards, gated by `wins` the same way
## reward_pool() gates cards (backlog #42). Excludes `tier: "boss"` relics —
## those are withheld from every normal offer (shop, treasure, elite reward,
## event grant) and only reachable through boss_relic_pool() below (backlog
## #48). Returns a fresh Array — callers filter and erase from these lists,
## and mutating the cache would drain the pool globally.
static func relic_pool(wins: int = UNLOCKED_ALL) -> Array:
	var relics: Dictionary = _read_json(RELICS_PATH).get("relics", {})
	var out: Array = []
	for id_v in (_read_json(RELICS_PATH).get("pool", []) as Array):
		var id := String(id_v)
		var rd: Dictionary = relics.get(id, {})
		if String(rd.get("tier", "common")) == "boss":
			continue
		if int(rd.get("unlock_wins", 0)) <= wins:
			out.append(id)
	return out

## The relic pool a Titan itself pays out — `tier: "boss"` only. Same
## unlock_wins gate as relic_pool(); a fresh Array for the same reason.
static func boss_relic_pool(wins: int = UNLOCKED_ALL) -> Array:
	var relics: Dictionary = _read_json(RELICS_PATH).get("relics", {})
	var out: Array = []
	for id_v in (_read_json(RELICS_PATH).get("pool", []) as Array):
		var id := String(id_v)
		var rd: Dictionary = relics.get(id, {})
		if String(rd.get("tier", "common")) != "boss":
			continue
		if int(rd.get("unlock_wins", 0)) <= wins:
			out.append(id)
	return out

## Every relic id in relics.json, reachable or not — content-integrity checks
## walk the whole set rather than just what the reward pool happens to offer.
static func all_relic_ids() -> Array:
	return (_read_json(RELICS_PATH).get("relics", {}) as Dictionary).keys()

## A relic as a plain dict {id, name, effect, value, text} (relics are passive
## data, not behaviour — Run/Combat read the effect+value).
static func make_relic(id: String) -> Dictionary:
	var relics: Dictionary = _read_json(RELICS_PATH).get("relics", {})
	if not relics.has(id):
		push_warning("Content: unknown relic '%s'" % id)
		return {}
	var rd: Dictionary = (relics[id] as Dictionary).duplicate()
	rd["id"] = id
	return rd

## An enchant as a plain dict {id, name, text, effect, value} (enchants are
## passive data, not behaviour — Card/Combat read effect+value, same shape
## make_relic() already uses).
static func make_enchant(id: String) -> Dictionary:
	var enchants: Dictionary = _read_json(ENCHANTS_PATH).get("enchants", {})
	if not enchants.has(id):
		push_warning("Content: unknown enchant '%s'" % id)
		return {}
	var ed: Dictionary = (enchants[id] as Dictionary).duplicate()
	ed["id"] = id
	return ed

## Every enchant id in data — content-integrity checks walk the whole set.
static func all_enchant_ids() -> Array:
	return (_read_json(ENCHANTS_PATH).get("enchants", {}) as Dictionary).keys()

## A potion as a plain dict {id, name, effect, value, text} — held per-hunter,
## same shape make_relic()/make_enchant() already use (backlog #26).
static func make_potion(id: String) -> Dictionary:
	var potions: Dictionary = _read_json(POTIONS_PATH).get("potions", {})
	if not potions.has(id):
		push_warning("Content: unknown potion '%s'" % id)
		return {}
	var pd: Dictionary = (potions[id] as Dictionary).duplicate()
	pd["id"] = id
	return pd

## Potion ids that can be found from fights or bought in a shop. Returns a COPY
## (see relic_pool()'s comment — callers erase from these while rolling).
static func potion_pool() -> Array:
	return (_read_json(POTIONS_PATH).get("pool", []) as Array).duplicate()

## Every potion id in potions.json, reachable or not — content-integrity checks
## walk the whole set rather than just what the pool happens to offer.
static func all_potion_ids() -> Array:
	return (_read_json(POTIONS_PATH).get("potions", {}) as Dictionary).keys()

## Characters, in menu order: [{id, name, desc}, ...].
static func list_characters() -> Array:
	var db := _read_json(CHARACTERS_PATH)
	var chars: Dictionary = db.get("characters", {})
	var out: Array = []
	for id in db.get("order", chars.keys()):
		if chars.has(id):
			var c: Dictionary = chars[id]
			out.append({"id": id, "name": String(c.get("name", id)), "desc": String(c.get("desc", "")),
				"portrait": String(c.get("portrait", ""))})
	return out

## Build a character's starter deck.
static func character_deck(id: String) -> Array:
	var chars: Dictionary = _read_json(CHARACTERS_PATH).get("characters", {})
	var deck: Array = []
	if chars.has(id):
		for cid in (chars[id] as Dictionary).get("starter_deck", []):
			deck.append(make_card(String(cid)))
	return deck

## A character's signature passive as {type, value, character:id}.
static func character_passive(id: String) -> Dictionary:
	var chars: Dictionary = _read_json(CHARACTERS_PATH).get("characters", {})
	var p: Dictionary = (chars.get(id, {}) as Dictionary).get("passive", {"type": "none", "value": 0})
	var out: Dictionary = p.duplicate()
	out["character"] = id
	return out

static func character_name(id: String) -> String:
	var chars: Dictionary = _read_json(CHARACTERS_PATH).get("characters", {})
	return String((chars.get(id, {}) as Dictionary).get("name", id))

static func character_portrait(id: String) -> String:
	var chars: Dictionary = _read_json(CHARACTERS_PATH).get("characters", {})
	return String((chars.get(id, {}) as Dictionary).get("portrait", ""))

## Every ascension tier, in order.
static func ascension_tiers() -> Array:
	return (_read_json(ASCENSION_PATH).get("tiers", []) as Array).duplicate()

static func max_ascension() -> int:
	return ascension_tiers().size()

## Cumulative difficulty modifiers for a level (tiers 1..level all apply).
static func ascension_mods(level: int) -> Dictionary:
	var m := {"boss_hp_pct": 0, "boss_strength": 0, "heal_between": 0,
		"rest_heal": 0, "reward_choices": 0, "player_hp": 0}
	for t in ascension_tiers():
		var tier: Dictionary = t
		if int(tier.get("level", 99)) > level:
			continue
		var e := String(tier.get("effect", ""))
		if m.has(e):
			m[e] += int(tier.get("value", 0))
	return m

## Every event id (map EVENT nodes).
static func list_events() -> Array:
	return (_read_json(EVENTS_PATH).get("events", {}) as Dictionary).keys()

## One event as a display-ready Dictionary: {id, title, text, choices:[{label,result,effects}]}.
static func make_event(id: String) -> Dictionary:
	var events: Dictionary = _read_json(EVENTS_PATH).get("events", {})
	if not events.has(id):
		push_warning("Content: unknown event '%s'" % id)
		return {}
	var e: Dictionary = (events[id] as Dictionary).duplicate(true)
	e["id"] = id
	return e

## Every boon id (backlog #31 — the free run-start choice, offered before the
## first map step).
static func list_boons() -> Array:
	return (_read_json(BOONS_PATH).get("boons", {}) as Dictionary).keys()

## One boon as a display-ready Dictionary: {id, label, result, effects}. Same
## effect keys as an event choice (see events.json's _comment) — a boon IS an
## event choice, just offered before the map rather than found on it.
static func make_boon(id: String) -> Dictionary:
	var boons: Dictionary = _read_json(BOONS_PATH).get("boons", {})
	if not boons.has(id):
		push_warning("Content: unknown boon '%s'" % id)
		return {}
	var b: Dictionary = (boons[id] as Dictionary).duplicate(true)
	b["id"] = id
	return b

## Beast ids for a map node type ("fight" | "elite" | "boss").
static func beast_pool(kind: String) -> Array:
	var pools: Dictionary = _read_json(BOSSES_PATH).get("pools", {})
	return (pools.get(kind, []) as Array).duplicate()

## Build a Titan by id from data.
## Every beast id there is. Used by the art-coverage test, which is the only
## thing that notices a beast added to the data with no body built for it.
static func boss_ids() -> Array:
	var out: Array = []
	for id in _read_json(BOSSES_PATH).get("bosses", {}).keys():
		out.append(String(id))
	out.sort()
	return out


static func build_boss(id: String) -> Boss:
	var bosses: Dictionary = _read_json(BOSSES_PATH).get("bosses", {})
	var bd: Dictionary = bosses.get(id, {})
	var b := Boss.new(String(bd.get("name", "Titan")), int(bd.get("max_hp", 1)))
	b.id = id
	b.moves = bd.get("moves", [])
	b.hurt_pct = float(bd.get("hurt_pct", 0.0))     # backlog #44: second pattern below this HP fraction
	b.hurt_moves = bd.get("hurt_moves", [])
	b.weak_point_height = int(bd.get("weak_point_height", 0))
	b.ledges = bd.get("ledges", [])
	b.weak_point_threshold = int(bd.get("weak_point_threshold", 0))
	b.limiter = bd.get("limiter", {})
	b.thorns = int(bd.get("thorns", 0))      # backlog #36: a spined beast that bites back
	b.artifact = int(bd.get("artifact", 0))  # backlog #36: a warded beast that resists Expose/Poison/Frail
	b.art = String(bd.get("art", ""))
	return b

## Rebuild a Boss for a resumed fight: static data from `id` (as build_boss),
## dynamic per-fight state (hp, block, strength...) overlaid from the save.
static func boss_from_dict(d: Dictionary) -> Boss:
	var b := build_boss(String(d.get("id", "")))
	b.apply_dict(d)
	return b
