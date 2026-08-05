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

## Call on a win. Clearing tier N unlocks N+1 (capped at the last tier).
static func record_win(ascension: int) -> void:
	var top: int = mini(ascension + 1, Content.max_ascension())
	if top <= unlocked_ascension():
		return
	var cfg := ConfigFile.new()
	cfg.load(PATH)  # keep anything else already stored
	cfg.set_value(SECTION, "unlocked_ascension", top)
	cfg.save(PATH)
