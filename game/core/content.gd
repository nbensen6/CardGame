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

static var _cache: Dictionary = {}

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

## Build a hunter's starting deck from data.
static func build_starter_deck() -> Array:
	var deck: Array = []
	for id in _read_json(CARDS_PATH).get("starter_deck", []):
		deck.append(make_card(String(id)))
	return deck

## Card ids offered as rewards. A character draws from THEIR pool (their
## archetype cards plus neutrals) so a run can be drafted toward a build; the
## shared pool is the fallback.
static func reward_pool(character_id: String = "") -> Array:
	if character_id != "":
		var chars: Dictionary = _read_json(CHARACTERS_PATH).get("characters", {})
		var own: Array = (chars.get(character_id, {}) as Dictionary).get("reward_pool", [])
		if not own.is_empty():
			return own.duplicate()
	return (_read_json(CARDS_PATH).get("reward_pool", []) as Array).duplicate()

## Relic ids that can be offered as rewards. Returns a COPY — callers filter and
## erase from these lists, and mutating the cache would drain the pool globally.
static func relic_pool() -> Array:
	return (_read_json(RELICS_PATH).get("pool", []) as Array).duplicate()

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

## Beast ids for a map node type ("fight" | "elite" | "boss").
static func beast_pool(kind: String) -> Array:
	var pools: Dictionary = _read_json(BOSSES_PATH).get("pools", {})
	return (pools.get(kind, []) as Array).duplicate()

## Build a Titan by id from data.
static func build_boss(id: String) -> Boss:
	var bosses: Dictionary = _read_json(BOSSES_PATH).get("bosses", {})
	var bd: Dictionary = bosses.get(id, {})
	var b := Boss.new(String(bd.get("name", "Titan")), int(bd.get("max_hp", 1)))
	b.moves = bd.get("moves", [])
	b.weak_point_height = int(bd.get("weak_point_height", 0))
	b.ledges = bd.get("ledges", [])
	b.weak_point_threshold = int(bd.get("weak_point_threshold", 0))
	b.art = String(bd.get("art", ""))
	return b
