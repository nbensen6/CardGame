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

## Tips off entirely (Nick, 2026-08-06). Deliberately separate from seen_hints:
## OFF silences everything including hints you've never been shown, while
## reset_hints only makes already-taught ones eligible again. Turning tips back on
## therefore returns you to exactly where you were, rather than re-teaching you
## the whole game.
static func hints_enabled() -> bool:
	var cfg := ConfigFile.new()
	# OFF by default (Nick, 2026-08-15) — the tips get in the way while the game is
	# still being built. Flip this back when onboarding is the thing being worked on.
	if cfg.load(PATH) != OK:
		return false
	return bool(cfg.get_value(SECTION, "hints_enabled", false))


static func set_hints_enabled(on: bool) -> void:
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	cfg.set_value(SECTION, "hints_enabled", on)
	cfg.save(PATH)


## Music on/off. Stored beside the tips flag so both survive a run and a restart.
static func music_enabled() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return true
	return bool(cfg.get_value(SECTION, "music_enabled", true))


static func set_music_enabled(on: bool) -> void:
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	cfg.set_value(SECTION, "music_enabled", on)
	cfg.save(PATH)


## Keyboard accelerators, remappable from the settings menu.
##
## This array is both the defaults and the order the settings menu lists them in.
## Every action here also has a button on the HUD — CLAUDE.md §5, the keyboard is
## an accelerator and never the only path — so a key bound to something silly can
## never lock a player out of an action, and the mobile target loses nothing.
const KEYBINDS := [
	{"id": "end_turn", "name": "End turn", "default": KEY_SPACE},
	{"id": "swap", "name": "Swap hunter", "default": KEY_TAB},
	{"id": "hunter_1", "name": "Hunter 1", "default": KEY_1},
	{"id": "hunter_2", "name": "Hunter 2", "default": KEY_2},
]


static func keybind(id: String) -> int:
	var stored: Dictionary = _keybinds()
	if stored.has(id):
		return int(stored[id])
	for k in KEYBINDS:
		if String((k as Dictionary)["id"]) == id:
			return int((k as Dictionary)["default"])
	return KEY_NONE


## Bind a key, taking it off whatever else held it. Two actions on one key means
## one of them silently never fires, which reads as a broken game rather than a
## bad binding.
static func set_keybind(id: String, keycode: int) -> void:
	var stored: Dictionary = _keybinds()
	for k in KEYBINDS:
		var other := String((k as Dictionary)["id"])
		if other != id and keybind(other) == keycode:
			stored[other] = KEY_NONE
	stored[id] = keycode
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	cfg.set_value(SECTION, "keybinds", stored)
	cfg.save(PATH)


static func reset_keybinds() -> void:
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	cfg.set_value(SECTION, "keybinds", {})
	cfg.save(PATH)


## Which action a key press triggers, or "" for a key that isn't bound.
static func action_for_key(keycode: int) -> String:
	if keycode == KEY_NONE:
		return ""
	for k in KEYBINDS:
		var id := String((k as Dictionary)["id"])
		if keybind(id) == keycode:
			return id
	return ""


static func _keybinds() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return {}
	return (cfg.get_value(SECTION, "keybinds", {}) as Dictionary).duplicate()


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
