class_name Feel
extends RefCounted

## Every number that decides how the fight FEELS, in one place.
##
## Nick, 2026-10-12: "focus on making the fight fun" — and tuning should be
## editing values, not hunting through 4000 lines of `combat_3d.gd`. These are
## the knobs for the double timing the fight is built around: the grip bar the
## party hangs on, and the sweep window a timed card opens.
##
## They are `static var`, not `const`, deliberately. A const is baked at
## compile time; a static var can be changed in the RUNNING game, so a value
## can be tried and felt without a relaunch:
##
##     godot_exec: Feel.SWEEP_SPEED = 1.4
##
## Nothing caches them — every reader asks `Feel.X` each time — so a change
## takes effect on the next frame. Edit the numbers here to make one stick.
##
## What does NOT belong here: anything a test pins as a rule (TIMING_MISS and
## friends are an enum, not a feel knob), layout, art, or balance numbers.
## Balance is not the job yet (see DECISIONS).


# --- the grip bar: how long the party can hang before they fall -------------

## Seconds of grip, before relics. Lower = the climb is a scramble; higher =
## it is a plan. 5.0 is where it has sat since the real-time grip landed.
static var GRIP_SECONDS := 5.0


# --- the sweep: the window a timed card opens -------------------------------

## Sweeps per second. Nick: "quick; timing should demand focus." This is the
## single biggest feel knob in the fight — it sets how much of a turn is
## reaction and how much is planning.
static var SWEEP_SPEED := 1.9

## How long a window stays open before the card fizzles.
static var WINDOW_SECONDS := 2.5

## The success band, as a fraction of the sweep (0..1). Wider = kinder.
static var ZONE_MIN := 0.40
static var ZONE_MAX := 0.60

## The bullseye inside the band: land here for the FULL timed bonus.
static var CORE_MIN := 0.47
static var CORE_MAX := 0.53

## What a "good" hit (inside the band, outside the core) pays, as a share of
## the timed bonus. 1.0 would make the core pointless; 0.0 would make every
## near miss feel like a whiff.
static var TIMING_GOOD_SCALE := 0.5


## The knobs as data, for the runtime digest and for printing a tuning pass.
static func snapshot() -> Dictionary:
	return {
		"grip_seconds": GRIP_SECONDS,
		"sweep_speed": SWEEP_SPEED,
		"window_seconds": WINDOW_SECONDS,
		"zone": [ZONE_MIN, ZONE_MAX],
		"core": [CORE_MIN, CORE_MAX],
		"good_scale": TIMING_GOOD_SCALE,
	}
