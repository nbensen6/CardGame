## Persistent player progress (the only thing that survives a run).
##
## Small enough to be a ConfigFile at user://progress.cfg. Keeps the ascension
## ladder honest: you unlock the next tier by clearing the current one.
class_name Progress
extends RefCounted

const DEFAULT_PATH := "user://progress.cfg"

## Redirectable, exactly like RunSave.path and for exactly the same reason: a
## tool that opens the game must not edit the player's settings as a side effect.
## tools/screenshot.gd used to turn Nick's tips off every time it ran, and it
## would now flip his timing style too — a screenshot is meant to observe the
## game, not change it.
static var path := DEFAULT_PATH


## Point every read and write at a throwaway file. Tools call this first.
static func use_scratch_slot(name: String) -> void:
	path = "user://%s.cfg" % name
const SECTION := "run"

## Highest ascension the player may select (0 = base difficulty).
static func unlocked_ascension() -> int:
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
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
	cfg.load(path)
	cfg.set_value(SECTION, "seen_hints", seen)
	cfg.save(path)

## Tips off entirely (Nick, 2026-08-06). Deliberately separate from seen_hints:
## OFF silences everything including hints you've never been shown, while
## reset_hints only makes already-taught ones eligible again. Turning tips back on
## therefore returns you to exactly where you were, rather than re-teaching you
## the whole game.
static func hints_enabled() -> bool:
	var cfg := ConfigFile.new()
	# OFF by default (Nick, 2026-08-15) — the tips get in the way while the game is
	# still being built. Flip this back when onboarding is the thing being worked on.
	if cfg.load(path) != OK:
		return false
	return bool(cfg.get_value(SECTION, "hints_enabled", false))


static func set_hints_enabled(on: bool) -> void:
	var cfg := ConfigFile.new()
	cfg.load(path)
	cfg.set_value(SECTION, "hints_enabled", on)
	cfg.save(path)


## Music on/off. Stored beside the tips flag so both survive a run and a restart.
static func music_enabled() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return true
	return bool(cfg.get_value(SECTION, "music_enabled", true))


static func set_music_enabled(on: bool) -> void:
	var cfg := ConfigFile.new()
	cfg.load(path)
	cfg.set_value(SECTION, "music_enabled", on)
	cfg.save(path)


## Which face the timing window wears: the sweep bar under the card, or the
## osu-style approach circle out on the beast at the hold you are climbing to.
##
## A setting rather than a replacement because the two cannot be compared any
## way except by playing both, and the bar is the thing Nick already said felt
## good ("grip timing feels nice") — replacing it outright on a hunch would
## throw away the only part of the feel that is known to land (backlog #34).
const TIMING_BAR := "bar"
const TIMING_CIRCLE := "circle"

static func timing_style() -> String:
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return TIMING_CIRCLE
	var v := String(cfg.get_value(SECTION, "timing_style", TIMING_CIRCLE))
	return v if v in [TIMING_BAR, TIMING_CIRCLE] else TIMING_CIRCLE


static func set_timing_style(style: String) -> void:
	var cfg := ConfigFile.new()
	cfg.load(path)
	cfg.set_value(SECTION, "timing_style", style)
	cfg.save(path)


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
	cfg.load(path)
	cfg.set_value(SECTION, "keybinds", stored)
	cfg.save(path)


static func reset_keybinds() -> void:
	var cfg := ConfigFile.new()
	cfg.load(path)
	cfg.set_value(SECTION, "keybinds", {})
	cfg.save(path)


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
	if cfg.load(path) != OK:
		return {}
	return (cfg.get_value(SECTION, "keybinds", {}) as Dictionary).duplicate()


## Forget every hint — useful for testing, and offered on the menu.
static func reset_hints() -> void:
	var cfg := ConfigFile.new()
	cfg.load(path)
	cfg.set_value(SECTION, "seen_hints", [])
	cfg.save(path)

static func _seen_hints() -> Array:
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return []
	return (cfg.get_value(SECTION, "seen_hints", []) as Array).duplicate()


## Call on a win. Clearing tier N unlocks N+1 (capped at the last tier).
static func record_win(ascension: int) -> void:
	var top: int = mini(ascension + 1, Content.max_ascension())
	if top <= unlocked_ascension():
		return
	var cfg := ConfigFile.new()
	cfg.load(path)  # keep anything else already stored
	cfg.set_value(SECTION, "unlocked_ascension", top)
	cfg.save(path)
