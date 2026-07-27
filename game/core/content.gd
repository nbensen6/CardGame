## Loads game content from /data (cards, decks, bosses) into /core objects.
##
## Reading data files is a /core concern (rules live in data — CLAUDE.md §11);
## it does NOT couple /core to /views, /input, or /net. Combat and Run take
## already-built Card/Boss objects, so they stay testable without the filesystem.
class_name Content
extends RefCounted

const CARDS_PATH := "res://data/cards.json"
const BOSSES_PATH := "res://data/bosses.json"

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

## Card ids offered as between-encounter rewards (build step 4).
static func reward_pool() -> Array:
	return _read_json(CARDS_PATH).get("reward_pool", [])

## Build a Titan by id from data.
static func build_boss(id: String) -> Boss:
	var bosses: Dictionary = _read_json(BOSSES_PATH).get("bosses", {})
	var bd: Dictionary = bosses.get(id, {})
	var b := Boss.new(String(bd.get("name", "Titan")), int(bd.get("max_hp", 1)))
	b.moves = bd.get("moves", [])
	return b
