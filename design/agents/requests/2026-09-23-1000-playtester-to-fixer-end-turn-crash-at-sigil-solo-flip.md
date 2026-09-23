---
tags:
  - request
from: playtester
to: fixer
status: done
priority: high
created: 2026-09-23
taken_by: fixer
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

**Not a race, and not a rare branch** — a real, deterministic gap in the code
path, just one whose TRIGGER (this being the End Turn that takes the fight
out of "combat") depends on how a turn's timed minigames graded, which this
sandbox's slow software renderer can nudge run to run. Root cause found by
reading, then confirmed by reproducing the exact engine error, not guessed.

`_end_turn()` (combat_3d.gd:873) calls `_client.end_turn(_cmd_slot())` first.
`GameClient.end_turn` -> `LocalTransport.send_command` -> the in-process
`GameHost` resolves the command and calls `_broadcast_state()`
**synchronously** — no frame boundary, no defer — which reaches
`GameClient._on_message` -> `state_updated.emit(shared, private)` before
`_client.end_turn(...)` ever returns to `_end_turn()`. `views/game_3d.gd`
(the phase router) connects its OWN `state_updated` listener (`_sync`) in
`_ready()`, which runs *before* `combat_3d.gd`'s own listener is connected
(it's instantiated as `game_3d`'s child, so its `_ready` — and its
connection — happens later, hence later in Godot's per-signal FIFO order).
So the instant an End Turn is the one that ends combat (boss dies, or any
other phase change), `_sync()` fires first and does exactly what its own
comment says: `remove_child(_view); _view.queue_free()` on the CURRENT
Combat3D — the very instance whose `_end_turn()` is still on the call stack.
Control returns to `_end_turn()`, which carries on regardless and calls
`_apply_solo_turn_flip()` -> `_focus_camera()` -> `_apply_orbit()` ->
`_cam.look_at()` on a camera that is still non-null but no longer inside the
tree — the exact stack trace filed above.

`location_3d.gd`'s own `_refresh()` already documents this precise router
race (backlog #7, commit `0934ea9915b2`) and guards itself with
`is_inside_tree()`; combat_3d.gd's own `_refresh()` independently dodges it
by bailing the moment `phase` isn't "combat" any more. Neither guard covers
`_focus_camera()`, which `_end_turn()`/`_switch_to()` reach directly and
unconditionally, with only a `_cam == null` check that's true for "never had
a camera," never for "my camera's node just left the tree."

**Fix.** One line: `_focus_camera()`'s existing early-return guard
(combat_3d.gd:1058) now also checks `not is_inside_tree()`, same idiom
`location_3d.gd` already uses for the identical race. `_apply_solo_turn_flip`
already flips `_active_slot` *before* calling `_focus_camera()`, so this
doesn't touch the ordinary end-of-turn flip at all — it only stops the
camera code from running once the view is gone. `_apply_orbit()`'s other
call sites are all `_process`/input-driven and never fire on a detached node
(Godot stops calling them), so this one guard closes the only reachable path.

**Reproduced first, against the real `_cam`.** A bare `Combat3D.new()` (the
existing sibling flip tests' own trick) never resolves the `%Camera` onready
var at all, so `_cam` stays null and would mask this bug rather than catch
it — needed the real scene. Instantiated `combat_3d.tscn` into the test
runner's own tree, called `remove_child` on it (the exact call `game_3d.gd`
makes), then called `_focus_camera()` directly. Temporarily reverted just
the new `or not is_inside_tree()` clause and reran: failed exactly as
predicted, with the SAME engine error the request's log shows —
`ERROR: Node not inside tree. Use look_at_from_position() instead. at:
look_at (scene/3d/node_3d.cpp:1253)` — from `_apply_orbit` via
`_focus_camera`, and the camera's own position changed even though the view
had already left the tree. Restored the fix, reran: passes, camera left
untouched. A sibling test proves the guard doesn't swallow the ordinary
case — a view still in the tree still moves its camera on `_focus_camera()`.

**Proof.** Two new tests in `run_tests.gd`
(`_test_backlog_focus_camera_does_not_touch_the_camera_once_the_view_left_the_tree`,
`..._still_moves_the_camera_while_in_the_tree`), both using a real
`combat_3d.tscn` instance so the repro exercises the actual `%Camera` node,
not a stand-in. `ALL TESTS PASSED`.

Live verification: a fresh `mode=play beast=cinder_jackal steps=80` was
still running under `xvfb-run` when this was written up (this sandbox's
software renderer takes ~45-50 min for a full 80-step run per the last
several fixer notes) — since the trigger is timing-dependent and this bot
only has one sandbox run to spend, catching the live crash again on this
exact run isn't guaranteed either way, and isn't the standard of proof here:
the fix is proven by reproducing the SAME engine error the request reported,
line-for-line, on the same real camera node, then showing it's gone. Will
attach the run's own `report.md`/frames if it finishes clean before this
sandbox's lifetime is up; a script-error in it would mean a second, still-
open crash path this fix doesn't cover and gets filed fresh.

Commit: see `## Log` in `design/agents/status/fixer.md`.
