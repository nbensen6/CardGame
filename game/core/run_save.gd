## The saved run — one slot, at user://run.json.
##
## A run is 24 nodes and the better part of an hour. Without this, putting the
## game down means throwing the run away, which is the single thing that stops a
## roguelike of this length from being shippable.
##
## SOLO ONLY, deliberately. Resuming a co-op run needs both hunters back at the
## same moment and a rendezvous to get them there; that's a networking feature,
## not a save feature, and pretending otherwise would write saves that can never
## be loaded.
##
## Pure /core: no rendering, no input, no net (CLAUDE.md §2).
class_name RunSave
extends RefCounted

const DEFAULT_PATH := "user://run.json"

## Where the slot lives. A var, not a const, because the test suite and the
## screenshot harness both spin up real GameHosts — and a GameHost autosaves.
## Left alone, running the tests or taking a screenshot would silently overwrite
## the designer's actual run, which is exactly how the tips flag got clobbered
## before (see tools/screenshot.gd).
static var path := DEFAULT_PATH


## Point the slot somewhere harmless. Tools call this before touching a host.
static func use_scratch_slot(name: String) -> void:
	path = "user://%s.json" % name


## Write the run, mid-fight included (backlog #14 — Combat has its own
## to_dict/from_dict now, see Run.to_dict). Refuses only a finished run: a
## WON or LOST run has nothing left to resume into.
static func save(run: Run) -> bool:
	if run == null or run.is_over():
		return false
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(run.to_dict()))
	f.close()
	return true


static func has_save() -> bool:
	return FileAccess.file_exists(path)


## The saved run, or null if there is none, it is genuinely unreadable, or it
## was written by a build NEWER than this one (a version we don't know how to
## read forward from). An OLDER save is upgraded field-by-field through
## `_migrate` rather than discarded — see backlog #35: every field a routine
## adds is a change to the save's shape, and rejecting on a version mismatch
## used to mean the day someone bumped `Run.SAVE_VERSION`, every run already
## in progress would vanish with no warning.
static func load_run() -> Run:
	if not has_save():
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var raw := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if not (parsed is Dictionary):
		return null
	var d: Dictionary = parsed
	var from_version := int(d.get("version", 0))
	# 0: no version at all, e.g. non-JSON-object garbage under a real key — not
	# a save this or any past build could have written. Above SAVE_VERSION: a
	# later build wrote a shape this code has never seen; reading it forward
	# would mean guessing, which is exactly the "corrupt" case rejection is for.
	if from_version <= 0 or from_version > Run.SAVE_VERSION:
		return null
	if not d.has("decks") or not d.has("map"):
		return null
	d = _migrate(d, from_version)
	return Run.from_dict(_whole_numbers(d) as Dictionary)


## Walk a save forward one version at a time to the shape `Run.from_dict`
## expects today. Most fields need no entry here at all — they're additive,
## and `from_dict`'s own `.get(key, default)` calls already treat "missing"
## as "didn't exist yet" for free. A step only needs to exist where an old
## save's ABSENCE of a field means something more specific than a bare
## default would assume.
static func _migrate(d: Dictionary, from_version: int) -> Dictionary:
	var v := from_version
	while v < Run.SAVE_VERSION:
		match v:
			1:
				# v1 predates potions (backlog #26) entirely. There, "no
				# potions key" means "this hunter has never held one", i.e. an
				# empty slot array per hunter — not whatever a bare .get()
				# default would leave it as.
				if not d.has("potions"):
					var backfilled: Array = []
					for _i in range((d.get("names", []) as Array).size()):
						backfilled.append([])
					d["potions"] = backfilled
			_:
				pass
		v += 1
	d["version"] = Run.SAVE_VERSION
	return d


## JSON has one number type, so every int in the file comes back as a float:
## a saved hp of [17, 29] reloads as [17.0, 29.0] and the HUD starts printing
## "HP 17.0/42.0" while the damage maths quietly goes floating point. This walks
## the parsed data and puts integral floats back to int.
##
## Only INTEGRAL ones — a relic's 0.06 timing-zone bonus is a genuine float and
## has to stay one, so the test is "does it survive a round trip through int".
static func _whole_numbers(v: Variant) -> Variant:
	if v is float:
		var f: float = v
		return int(f) if f == floor(f) and absf(f) < 9.0e15 else f
	if v is Array:
		var out: Array = []
		for item in (v as Array):
			out.append(_whole_numbers(item))
		return out
	if v is Dictionary:
		var out2: Dictionary = {}
		for k in (v as Dictionary):
			out2[k] = _whole_numbers((v as Dictionary)[k])
		return out2
	return v


static func clear() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


## A one-line description for the menu's Continue button, so you know what you'd
## be walking back into rather than guessing. "" when there's nothing to resume.
static func summary() -> String:
	var run := load_run()
	if run == null:
		return ""
	var who: Array = []
	for n in run.names:
		who.append(String(n))
	var act := run.encounter_index + 1
	return "Act %d  ·  %s" % [act, " & ".join(who)] if not who.is_empty() else "Act %d" % act
