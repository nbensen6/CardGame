## Persistent player progress (the only thing that survives a run).
##
## Small enough to be a ConfigFile at user://progress.cfg. Keeps the ascension
## ladder honest: you unlock the next tier by clearing the current one.
class_name Progress
extends RefCounted

const PATH := "user://progress.cfg"
const SECTION := "run"

## Highest ascension the player may select (0 = base difficulty).
static func unlocked_ascension() -> int:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return 0
	return int(cfg.get_value(SECTION, "unlocked_ascension", 0))

## Coach hints already shown to this player. Each fires once, ever — a returning
## player should never be re-taught.
static func hint_seen(id: String) -> bool:
	return id in _seen_hints()

static func mark_hint_seen(id: String) -> void:
	var seen: Array = _seen_hints()
	if id in seen:
		return
	seen.append(id)
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	cfg.set_value(SECTION, "seen_hints", seen)
	cfg.save(PATH)

## Forget every hint — useful for testing, and offered on the menu.
static func reset_hints() -> void:
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	cfg.set_value(SECTION, "seen_hints", [])
	cfg.save(PATH)

static func _seen_hints() -> Array:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return []
	return (cfg.get_value(SECTION, "seen_hints", []) as Array).duplicate()


## Call on a win. Clearing tier N unlocks N+1 (capped at the last tier).
static func record_win(ascension: int) -> void:
	var top: int = mini(ascension + 1, Content.max_ascension())
	if top <= unlocked_ascension():
		return
	var cfg := ConfigFile.new()
	cfg.load(PATH)  # keep anything else already stored
	cfg.set_value(SECTION, "unlocked_ascension", top)
	cfg.save(PATH)
