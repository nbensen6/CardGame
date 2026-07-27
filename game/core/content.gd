## Loads game content from /data (cards, decks, bosses) into /core objects.
##
## Reading data files is a /core concern (rules live in data — CLAUDE.md §11);
## it does NOT couple /core to /views, /input, or /net. Combat itself takes
## already-built Card/Boss objects, so it stays testable without the filesystem.
class_name Content
extends RefCounted

const CARDS_PATH := "res://data/cards.json"
const BOSSES_PATH := "res://data/bosses.json"

static func _read_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("Content: could not read " + path)
		return {}
	var data: Variant = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Content: malformed JSON in " + path)
		return {}
	return data

## Build the player's starting deck from data.
static func build_starter_deck() -> Array:
	var db := _read_json(CARDS_PATH)
	var cards: Dictionary = db.get("cards", {})
	var deck: Array = []
	for id in db.get("starter_deck", []):
		if not cards.has(id):
			push_warning("Content: starter_deck references unknown card '%s'" % id)
			continue
		var cd: Dictionary = (cards[id] as Dictionary).duplicate()
		cd["id"] = id
		deck.append(Card.from_dict(cd))
	return deck

## Build a boss by id from data.
static func build_boss(id: String) -> Boss:
	var db := _read_json(BOSSES_PATH)
	var bosses: Dictionary = db.get("bosses", {})
	var bd: Dictionary = bosses.get(id, {})
	var b := Boss.new(String(bd.get("name", "Boss")), int(bd.get("max_hp", 1)))
	b.moves = bd.get("moves", [])
	return b
