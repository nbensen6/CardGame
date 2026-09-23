---
tags:
  - request
from: playtester
to: fixer
status: open
priority: high
created: 2026-09-23
taken_by:
---

# End Turn crashes the fight: `_apply_orbit` uses `_cam` after it is no longer in the tree, tearing down the whole game view

## What

A real, if intermittent, engine-level crash — checklist item 5 ("nothing
errors") at its most serious: this doesn't just print a warning, it kills the
live game view mid-fight. Hit once in three full `mode=play steps=80` runs
today, all on the same code, same seed, no gameplay changes between runs
(only the artist's frog-model passes landed since the last playtester run) —
the other two went clean. That pattern (same setup, only one run trips it)
points at a timing/race condition, not a deterministic logic bug, which is
exactly the kind of thing this sandbox's slow software renderer is good at
surfacing (stretches windows that a fast machine would never widen enough to
hit — same shape as the earlier hop-sampling issues, but this one is a crash,
not a false check-fail).

Full two-line error, straight from the log:

    node_3d.cpp:1253 Condition "!is_inside_tree()" is true. Node not inside tree. Use look_at_from_position() instead.
      <- combat_3d.gd:2208 _apply_orbit < combat_3d.gd:1062 _focus_camera < combat_3d.gd:900 _apply_solo_turn_flip < combat_3d.gd:879 _end_turn
    playtest.gd:543 Invalid type in function '_wait_and_poll' in base 'SceneTree (playtest.gd)'. The Object-derived class of argument 1 (previously freed) is not a subclass of the expected argument class.
      <- playtest.gd:543 _play < playtest.gd:124 _frames

The second line is this bot's own harness reacting to the first crash (the
view node it was still polling had gone away) — the real bug is the first
line. `_end_turn()` (combat_3d.gd:873) calls `_apply_solo_turn_flip()`
unconditionally; that calls `_focus_camera()` (combat_3d.gd:900), which only
null-checks `_cam` (`if _hunters.is_empty() or _cam == null: return`,
line 1043) before eventually reaching `_apply_orbit()` (line 2192), which
calls `_cam.look_at(_pivot, Vector3.UP)` (line 2208) with no
`is_inside_tree()` guard. `_cam` was non-null but no longer in the tree at
that moment — something upstream freed or re-parented it (or the whole
Combat3D subtree) between when `_end_turn` started and when `_apply_orbit`
actually ran, without `_focus_camera`'s guard catching it. I didn't chase
which upstream event does the freeing — that's the fixer's half; this bot
only has the render-thread symptom, not the game-state cause.

This run's `mode=play` harness always runs **solo** (one client picks both
`frog` and `goblin_mech` and switches between them, see `playtest.gd`'s
`_initialize`), so `_is_solo()` is true and `_apply_solo_turn_flip`'s real
body runs on every single End Turn, not a rare branch — worth knowing the
crash sits on a hot path, not an edge case nobody exercises.

State right before the crash (frame `step_063.png`, the last one this bot
managed to save): both hunters already **at the sigil**, Frog's turn already
`done`, Goblin Engineer mid a timed "Grappling Arm" resolve (hit-circle still
open) on the Goblin's own turn. The crash itself happens on the End Turn a
couple of actions later (step 64), stack trace above — I don't know whether
"both at the sigil" is load-bearing or just where this run happened to be
when the race won; the frame is what I have, not a claim about the cause.

![[frames/playtester/2026-09-23-end-turn-crash-step063-before-crash.png]]

## How to see it

    xvfb-run -a Godot_v4.7.1-stable_linux.x86_64 --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=80 out=/tmp/pt

Didn't reproduce on the first or third attempt today (both clean 80-step
runs, one 0 fails, one only the already-known foothold-4 residual) — only
the second hit it, at step 64. Report/log land in `out=`; a crash truncates
`report.md`'s own step count (it says "65 steps" instead of the requested
80) and ends the run with two `script-error` FAILs instead of a normal
finish, which is itself a reliable tell that this hit, even without a repro
that fires every time.

## Done when

`mode=play steps=80` runs clean of `script-error` across several repeated
runs (this bot cannot promise a single deterministic repro step given the
timing-dependent pattern above — "ran N times clean" is the honest bar for
a race, not "ran once clean"). If the root cause turns out to be a specific
game-state trigger (e.g. something tied to both hunters reaching the sigil,
or a timed-card resolve still open across an End Turn) rather than pure
render timing, a unit test on that trigger would be the stronger proof; note
which one this turned out to be in the `## Result`.

## Result

(filled in by whoever takes it: what changed, which commit, how verified)
