---
tags:
  - request
from: fixer
to: fixer
status: done
priority: normal
created: 2026-09-23
taken_by: fixer
---

# HitCircle's `note_hit` signal reports two conflicting verdicts for one slider note

## What

`ui/hit_circle.gd`'s `note_hit` signal is documented as "index is 0-based,
quality grades that note alone" — one verdict per note. A **slider** window
(`begin(..., true)`, used for a climb card whose window is one held note
rather than a series of taps) has exactly one note (`_hits_needed = 1`,
`_hits_done` never leaves `0`).

`_fire()`'s slider branch already emits `note_hit(0, press_quality)` the
instant a good press lands (`hit_circle.gd:254`, before this fix). But if the
hold is then dropped before `SLIDE_RESCUE` (0.72 of the path), the window
resolves through `_finish(Combat.TIMING_MISS)`, which **unconditionally**
also emitted `note_hit(_hits_done, Combat.TIMING_MISS)` — `_hits_done` is
still `0`, so that's a second, contradicting report for the exact same note
index: the listener sees index 0 graded `PERFECT`, then a moment later graded
`MISS`.

Found by reading `hit_circle.gd` (fixer.md order-of-work item 3 — it's one of
the files explicitly in scope). Not yet visible to a player: nothing in
`combat_3d.gd` connects `note_hit` today (only `resolved` is connected,
`combat_3d.gd:510`), so this is a live contract violation with no current
listener — but the signal exists specifically so a future per-note UI
reaction (the doc comment names "the camera-follow judgement pop") can be
wired off it, and this bug would corrupt that the day it is.

## How to see it

Not visible on screen (no listener exists yet) — proven from headless via a
unit reproduction:

    var hc := HitCircle.new()
    hc.begin(0.0, null, PackedVector3Array([Vector3.ZERO, Vector3.ONE]), true)
    hc._t = hc._approach          # dead on the beat -> PERFECT press
    var seen: Array = []
    hc.note_hit.connect(func(i, q): seen.append([i, q]))
    hc._fire()
    hc._slide = 0.3               # well short of SLIDE_RESCUE (0.72)
    var release := InputEventMouseButton.new()
    release.button_index = MOUSE_BUTTON_LEFT
    release.pressed = false
    hc._gui_input(release)
    # seen == [[0, TIMING_PERFECT], [0, TIMING_MISS]] on the unfixed tree

## Done when

`note_hit` fires exactly once for a slider's one note, whatever the outcome,
and `run_tests.gd` still passes.

## Result

**Reproduced first.** The repro above, turned into
`_test_hit_circle_slider_dropped_after_a_good_press_does_not_double_report_note_hit()`
in `run_tests.gd`, run against the unfixed tree (`git stash` on just
`hit_circle.gd`): failed exactly as predicted —
`got [[0, 2], [0, 0]]` (TIMING_PERFECT then TIMING_MISS for index 0).

**Fix.** `hit_circle.gd`: added `_slider_note_hit`, set `true` right after the
slider press's own `note_hit.emit(0, _worst)` in `_fire()`, reset `false` in
`begin()`. `_finish()`'s MISS branch now skips the `note_hit.emit(...)` call
when `_slider and _slider_note_hit` — the note already reported its real
verdict at press time, so a later drop must not re-report it as MISS. The
**visual** MISS burst (the "TOO EARLY"/"TOO LATE" pop, `_burst_note`/
`_burst_grade`/`_flash`) is left untouched and still plays on a dropped
slider — a player who blew the hold still needs to see why; only the signal
double-report was the bug.

**Proof.** Two new tests: the repro above (fails on unfixed, passes on
fixed), and a sibling `_test_hit_circle_slider_missed_press_still_reports_note_hit_once()`
proving the guard doesn't silence the *legitimate* single MISS report for a
slider whose press itself misses the window (never enters holding, so
`_finish()`'s MISS branch is the only place that note is ever reported).
Both pass on the fixed tree. `$GODOT --headless --path game --script
res://tools/run_tests.gd` → `ALL TESTS PASSED`. Re-ran `mode=hands` under
`xvfb-run` post-fix as a sanity check (pure logic fix, nothing rendered
changes): `PLAYTEST OK: 0 failing check(s)`, same known harness-only
`ObjectDB`/`AudioStreamOggVorbis` leak-at-exit noise as every prior clean
run. No frame to attach — this bug never reached a pixel; the before/after
test output above is the evidence, same convention the sealed-door
history-entry fix used.

Commit: see `design/agents/status/fixer.md`.
