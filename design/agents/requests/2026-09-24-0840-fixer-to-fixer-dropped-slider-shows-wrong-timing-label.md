---
tags:
  - request
from: fixer
to: fixer
status: done
priority: normal
created: 2026-09-24T08:40
taken_by: fixer
ask:
waiting: false
---

# A dropped slider hold shows "TOO EARLY"/"TOO LATE", which is never the real reason it missed

## What I need

- `hit_circle.gd`'s `_burst()` derives its MISS label purely from
  `_offset() < 0.0` (early vs late). For a slider (`_live and _holding`),
  `_process()` stops updating `_t`/`_approach` the instant the press is
  accepted (line 175's early `return`), so `_offset()` freezes at the
  press's own small, already-correct timing residual for the rest of the
  hold.
- Release the mouse before `SLIDE_RESCUE` (72% of the hold) and
  `_finish(Combat.TIMING_MISS)` fires — but the label still reads off that
  stale, frozen `_offset()` sign, so a player who pressed dead-on-beat and
  just let go too soon sees "TOO EARLY" or "TOO LATE": true-sounding
  feedback for a cause that never happened. There is no "let go early" /
  "dropped" label anywhere in `_burst()`.
- Fix direction (not yet built): give `_finish()` a way to know the MISS
  came from a dropped hold (check `_holding` at call time, before it's
  cleared) rather than a mistimed tap, and show a distinct label (e.g.
  "LET GO") in that case instead of reusing `_offset()`'s stale sign.
- Found by an Explore agent scoped to `card_view.gd`/`hit_circle.gd`
  (fixer.md's own order-of-work item 3, no `to: fixer` request open this
  run) while I was mid-fix on a different, higher-priority open request
  (`2026-09-24-0822-...jump-hides-behind-intent-tag.md`) — filing rather
  than dropping it, per "Do ONE thing" this run.

## What

Full mechanism, with exact line numbers and the existing test-coverage gap
this slipped through, in the investigation report (not duplicating the
whole thing here — the key trace):

- `_t`/`_approach` are only ever written in `begin()`, the tap-timer branch
  of `_process()` (skipped once `_holding`), and `_fire()`'s stream-chain
  reset — confirmed by grepping every `_t \+?=` / `_approach ?=` in the
  file.
- Reachable in real play, not a corner case: `Progress.timing_style()`
  defaults to `TIMING_CIRCLE` (the HitCircle face) for every player who
  hasn't changed the setting, and `Combat3D.card_is_slider()` makes several
  shipped cards (grip >= 2, timed_hits <= 1) sliders. Letting go of a held
  mouse button before 72% of an 0.85s hold is an ordinary way to blow a
  slider, especially the first few times a player meets the mechanic.
- The prior `note_hit`-double-report fix
  (`2026-09-23-0300-fixer-to-fixer-note-hit-double-reports-on-dropped-slider.md`)
  explicitly noted a MISS burst still plays on a drop, but never checked
  which LABEL it shows — that's the gap this bug lives in.
- Existing tests cover the dropped-hold's *quality* (rescue window,
  downgrade to GOOD) and that `note_hit` doesn't double-fire, but nothing
  asserts on `_burst()`'s label/`_burst_grade` at release time.

**Secondary, lower-confidence/severity, same neighborhood (same investigation,
not separately verified as reachable at as high a rate):** a release PAST
`SLIDE_RESCUE` but before full completion downgrades quality via
`_finish()`'s non-MISS path, which never refreshes `_flash`/`_burst_grade`
— by the time that release happens (~0.61s in), the press-time flash has
already fully decayed (0.25s), so the player may get NO burst at all
telling them the hold was downgraded. Worth a look in the same pass, not
its own request.

## How to see it

No repro command yet (this is an investigation, not a built repro) — the
mechanism is derived from reading `hit_circle.gd`'s `_process()` (line
168-175), `_gui_input` (213-218), `_finish()` (275-288) and `_burst()`
(430-440) directly, cross-checked against `run_tests.gd`'s existing
slider-drop tests (`_test_backlog86_hit_circle_slider_released_before_rescue_misses_even_a_perfect_press`
and siblings). Whoever picks this up should confirm live first (a
timed-hit card with `card_is_slider() == true`, e.g. a Winch-class climb
card, pressed on-beat then released before the rescue threshold) before
touching the fix, per this brief's own "reproduce first" rule.

## Done when

- A dropped slider hold (released before `SLIDE_RESCUE`) shows a label
  that actually says what happened ("LET GO" or similar), not a timing
  verdict inherited from the press.
- A new test in `run_tests.gd` pins the label/grade at release time for
  both a dropped hold and an on-time press, so this can't drift back.
- Worth deciding in the same pass whether the secondary (no-burst-at-all
  on a rescue-window downgrade) needs its own fix or is out of scope.

## Nick's answer

## Result — fixer, 2026-09-24 11:34 EDT

**Both items done: the mislabel is fixed, and the secondary (no-burst on a
rescue-window downgrade) is real and fixed too, in the same pass.**

**Reproduced first, live.** Rendered `state=3dslide beast=cinder_jackal`
(the harness's own three-probe slider check: held to the end, let go past
rescue, let go before rescue) on the pre-fix code (`git stash` on just
`hit_circle.gd`): a perfect press let go at 20% of the hold — well before
`SLIDE_RESCUE` (72%) — resolved `TIMING_MISS` as expected, but the burst
that popped over the hunter read **"TOO LATE"**, inherited from `_offset()`'s
stale sign at press time. Matches the request's own prediction exactly.

**Cause, as diagnosed:** `_finish()` only ever set `_burst_grade`/`_flash`
on its `quality == TIMING_MISS` branch, and `_burst()` always derived the
label from `_offset() < 0.0` — with no notion that a MISS could come from
letting go rather than a mistimed tap, and no burst refresh at all for a
non-MISS release (the rescue-window downgrade case).

**Fix.** `_finish()` now takes two optional flags: `dropped` (this MISS
came from letting go early, not a bad tap) and `released` (this call came
from the player letting go of a hold at all, MISS or not). The `_gui_input`
release handler passes both. The label itself is pulled into a new static
`HitCircle.burst_label(grade, dropped, early)` — testable with no camera —
so a dropped MISS now shows "LET GO" and a downgrade-but-paid release
(rescue-to-completion) now refreshes `_flash`/`_burst_grade` instead of
popping nothing.

**Proven three ways:**
1. 9 new unit tests in `run_tests.gd` (label rule in isolation for all four
   grade/dropped/early combinations it can reach, plus three integration
   tests driving a real `HitCircle` through `begin()`/`_fire()`/
   `_gui_input()`) — `ALL TESTS PASSED`, existing slider tests untouched
   and still green.
2. Rendered `state=3dslide` before (old `hit_circle.gd`, new harness probe
   kept alive for the shot) and after — same camera, same beast:

![[frames/fixer/2026-09-24-dropped-slider-label-before.png]]
![[frames/fixer/2026-09-24-dropped-slider-label-after.png]]

   Before: "TOO LATE" over the jackal's legs for a dropped, dead-on-beat
   press. After: "LET GO". The harness now also prints the shown label
   (`TIMING   let go early -> miss OK burst="LET GO"`), and confirms the
   secondary fix live too: `TIMING let go late -> good OK burst="GOOD"` —
   before the fix this probe's burst never appeared at all (`_burst_grade`/
   `_flash` never touched on the non-MISS release path).
3. Full regression: `mode=play beast=cinder_jackal steps=80` — the only
   failures are the two already-open, unrelated items (`hop-distance-band`,
   the still-unresolved stone-route hop-spacing investigation; and
   `intent-tag-vs-hunter`, the still-open
   `2026-09-24-1002-playtester-...` sliver). Nothing new.

Commit: pushed as part of this run — see `game/ui/hit_circle.gd`,
`game/tools/run_tests.gd`, `game/tools/screenshot.gd` (the `3dslide`
probe now prints and can render the burst label it produces, for future
verification) in this push.
