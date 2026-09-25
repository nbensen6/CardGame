---
tags:
  - agent-status
agent: fixer
updated: 2026-09-24T23:44
working_on: Handed the Risk of Rain camera shot back to Nick; #14 (stones/gap) is next.
---

# fixer

## This run — 2026-09-24 23:44 EDT

- **Did:** finished the Risk of Rain camera pass — the resting shot now
  trucks over-the-shoulder like the climbing one, and sits closer.
- **Worked?** Yes. Frog now fills about a quarter of the frame, like you
  asked; the beast is capped smaller by #14's own gap, flagged not fixed.
- **Next:** your look at the frame; #14 (stones/gap) once you weigh in.
- **Need from you:** does the shot read right? Frame's on the ticket.

## Now

Finished `2026-09-24-2155-...player-camera-toggle...` (the Risk of Rain
framing pass the director queued after the lock-by-default push). The
resting camera now trucks over-the-shoulder onto the active hunter
(`want_shoulder_truck`, new pure static, ORs in a `grounded` case the old
rule never had) and sits closer (`GROUND_VIEW_DIST` 9→3, `GROUND_VIEW_EYE`
3.2→1.05, new `GROUND_VIEW_PITCH` 0.08) — the flat, dead-centre "everyone
on one vertical line" shot is now a real diagonal, Frog foreground-left,
beast upper-right. Climbing camera is provably untouched (pixel-identical
`state=3dclimb`/`3dgrip` before/after). Full numbers, before/after frames,
and the one genuine limit found (the beast can't reach "upper two-thirds"
without #14 narrowing its own gap — out of scope here) are in the
ticket's own `## Result, pass 3`. Handed back `to: nick`, never `done` —
the ticket's own Done-when is his eyes on it.

One expected, non-regression playtest fail: `camera-ots-while-grounded`
(1) — that check asserts the OLD grounded behaviour on purpose and the
playtester already has a ticket open (`2026-09-24-2233-...`) to flip it to
match tonight's change. Left it alone rather than touch the playtester's
own file mid-ticket. `hop-distance-band` (62), `hunter-off-marker` (8) and
`hop-position-pop` (1) are pre-existing, confirmed identical on `git
stash` of this change.

![[frames/fixer/2026-09-24-ror-shot-camera-close-shoulder.png]]

Next real pick, once Nick answers (or if nothing's open next run): #14
(stones-in-front / the gap), still `taken` by fixer, blocked on a
parametric-path rewrite for the open-air holds.

## Old: 2026-09-24 22:40 EDT — the camera lock itself

- **Did:** built the Camera Dev/Player menu toggle, then Nick answered live
  mid-push wanting it locked by default in every build — flipped that too.
- **Worked?** Yes. Fresh launch is now locked third-person even in a debug
  build; Dev is a Menu opt-in; all tests pass.
- **Next:** the Risk of Rain shot itself (pivot on active hunter, distance,
  pitch) — a real tuning pass, not done yet. Then back to #14.
- **Need from you:** nothing right now — the lock is live tonight like you
  asked; the exact shot still needs a next-run pass.

## Now

Took the sole high-priority open `to: fixer` request (2155, director's own
ordering note on #14: camera switch first, then back to #14). Built the
toggle — `Progress.dev_camera_enabled(is_debug_build)` /
`set_dev_camera_enabled(on)` (`game/core/progress.gd`) and a `Camera:  Dev /
Player` button above the keybind rows (`game/views/combat_3d.gd`
`_open_settings`) — and was mid-push (pass 1) when Nick answered live,
22:25 EDT: *"The camera should be locked to 3rd person on the character. I
still cannot find the toggle."* The first design defaulted the setting to
`is_debug_build` (Dev in a debug build) — but his own build is always
debug (`tools/dev.cmd`), so that default never locked anything for him at
all. `git pull --rebase` landed the director's rewritten ticket mid-push;
resolved the conflict and did pass 2 in the same run rather than push a fix
that didn't fix his actual complaint.

**Pass 2:** `Progress.dev_camera_enabled()` dropped the `is_debug_build`
input and now defaults to `false` (Player/locked) unconditionally — nothing
set, in any build, is locked. `free_camera_allowed` itself is unchanged
(still ANDs `is_debug_build` separately, so a release build stays hard
-locked regardless of the Menu). Fixed `state=3dfreecam`
(`tools/screenshot.gd`) to force Dev before its own drag tests, since that
harness's whole job is exercising the free camera and would otherwise read
the new locked default as "nothing works."

Proved it, not just logically:
- Fresh scratch config, `state=3dsettings`: button reads **"Camera:
  Player"** — frame below.
- `run_tests.gd`: `ALL TESTS PASSED`, including a fresh-config check that
  `Progress.dev_camera_enabled() == false` with nothing set, and the
  ticket's required "Player forces it false even in a debug build" case on
  `free_camera_allowed`.
- `state=3dfreecam` still drags/pans/WASDs correctly once Dev is set (forced
  by the harness itself now) — same per-spot pattern as before this pass.
  `gauge` flickers `drags`/`DEAD` run to run — a pre-existing harness timing
  flake at that one spot (reproduced 3x on identical code), not new.
- `state=3d`/`3dclimb`/`3dgrip` hash mismatches before/after turned out to
  be pre-existing: unmodified `main` doesn't hash-match itself between two
  back-to-back runs either (software-GL jitter, confirmed with `git stash`).

Did NOT touch the Risk of Rain framing itself (pivot on the active hunter,
the 9-unit standoff, pitch/distance) — a real visual-tuning task, separate
from the mechanical lock-by-default fix, and not rushed into the same push.
Left `2155` at `status: taken`, `to: fixer` (not `nick` — the ticket's
Done-when for the framing half still needs work before there's anything to
show him); `## Result` has both passes in full, with frames.
![[frames/fixer/2026-09-24-camera-locked-by-default.png]]

## Old: 2026-09-24 21:49 EDT — stones and the gap (#14)

## This run — 2026-09-24 21:49 EDT

- **Did:** took #14 (open the gap, lay the stones). Proved hunter placement
  alone can't open a visible gap — the camera cancels it. Tried moving the
  stones toward the head, reverted twice.
- **Worked?** No net change shipped — both attempts made things worse or
  hit a real anatomical/architecture wall. Wrote up why, with numbers, on
  #14 so the next run doesn't re-try either dead end.
- **Next:** #14 needs the director's call on the camera conflict, then a
  real rewrite (a parametric path, not a raycast-onto-surface tweak) for
  the stones. 2-3 runs once that's confirmed.
- **Need from you:** director, please read #14's `## Result` — item 1's
  Done-when ("gap visible in state=3d") looks unsatisfiable without
  touching the camera; need your call on which one gives.

## Now

Claimed the only open `to: fixer` request this run,
`2026-09-24-1835-director-to-fixer-stones-in-front-nick-is-waiting.md`
(#14), high priority, the sole open item addressed to fixer.

**Investigation 1 — the resting camera cancels any hunter-placement change.**
`_lock_point()` locks the resting camera's pivot to the active hunter's own
(x, z), unconditionally, at `CAMERA_LOCK = 1.0`, and `dist_for_window_for`'s
"stand off from the beast's front" term is already clamped to 0 once the
hunter is this far out. Pushed `GROUND_STANDOFF` from 0.62 to 32.0 (hunter
world Z from 26.7 to 544, a 20x change) and projected both the hunter and
the beast's own front-paw point to screen pixels at each step: the hunter's
screen position (640, 448) never moved by even one pixel at ANY standoff
tested, because the whole camera rig translates by exactly the hunter's own
displacement every time. The paw only crept from 443 to 428 (asymptotic,
converging hard by 8x). Conclusion, with numbers: no hunter placement, at
any distance, can satisfy "a clear stretch of ground visible in `state=3d`"
under the current resting camera. That's a direct conflict with #14's own
"do not touch the camera" — flagged back to the director rather than
guessed at.

**Investigation 2 — the stones, two attempts, both reverted.**
Rebuilt the shipped Cinder Jackal AI model twice (`ai_beast.py`, reusing its
own already-exported `.glb` as the source, no Meshy spend):

- Attempt A: bias the middle-rung search window toward the head as climb
  height rises (new `climb_lane_center` in `route.py`, unit tested).
  Diagnosed the real anatomy first (a standalone horizontal sweep at every
  climb height, not part of the build): the front leg slants BACKWARD as it
  rises (a real leg shape, not a bug), and the belly directly above the paw
  is open air at low climb heights — nothing to raycast onto near the head
  until much higher up the body. A target that assumes steady progress
  toward the head either fails outright at the low rungs or gets dragged
  back toward the tail anyway by the existing one-directional rule, which
  locks onto whatever direction the (anatomically backward-slanting) first
  rung sets.
- Attempt B: leave the search alone, just raise the floating standoff off
  the skin (`OPEN_AIR_WORLD` in `route.py`, from an effective ~1.16 world
  units to 1.4). The standoff isn't purely cosmetic — it's baked into the
  SAME distance math that decides which candidate is "in the hop-distance
  band," so raising it changes WHICH surface point gets picked, not just
  how far the final stone sits from it. Rendered before/after at 1:1: 4
  stones now read individually (real progress) but ended up stacked tight
  against the leg, in its own shadow — closer-looking than the 2-stone
  original, not further.

Both reverted in full — `git status` showed zero diff against
`combat_3d.gd`, `ai_beast.py`, `route.py`, `test_route.py`, or the shipped
`cinder_jackal_ai.glb`/`.blend` before this push. `python3
tools/blender/test_route.py` and `run_tests.gd` both `ALL TESTS PASSED` on
the unchanged tree.

**Recommendation, written into #14:** the raycast-onto-surface approach is
very likely the wrong architecture for open-air stones — every attempt
still asks "where is the body's surface" and pushes off it, so the route
stays shaped by the mesh silhouette no matter what. A parametric path
(2-point curve from near the hunter to near the sigil, sampled at N holds,
each checked only for CLEARANCE against the body rather than anchored to
it) is the real fix, and a bigger rewrite than either attempt above.

Frames (this run's own before/after on Attempt B, kept for the record):
![[frames/fixer/2026-09-24-open-air-standoff-before.png]]
![[frames/fixer/2026-09-24-open-air-standoff-after.png]]

Left `#14` at `status: taken`, not `done` — nothing of it is finished, and
the camera question needs the director's answer before item 1 can even be
attempted again.

## Old: 2026-09-24 17:43 EDT — camera composition (#11)

## This run — 2026-09-24 17:43 EDT

- **Did:** stopped the resting camera cutting to a tight lock while
  everyone is grounded, so the whole beast and both hunters fit (#11).
- **Worked?** Yes — full 80-step playtest clean, only the pre-existing
  hop-distance-band (#4) still fails, camera checks all pass.
- **Next:** #11 needs Nick's own eyes on the frame vs. his reference
  before it can close; stone-path legibility stays on #4.
- **Need from you:** compare the after frame on #11 to your drawing and
  say yes/no there.

## Now

Nick's #11 ("hunters far back, stones a visible path") showed the resting
shot was cropping the Cinder Jackal to "four legs and a shadow." Root cause:
`_focus_camera()` — called every time a hunter is selected, which includes
automatically at fight start and on every solo End Turn — pinned the camera
to a fixed 8-world-unit window centred on the hunter's own eye height,
permanently, the instant the fight's opening establishing shot finished.
That's a tight over-the-shoulder lock, and it doesn't care how tall the
beast is; a 20-unit jackal simply doesn't fit in 8 units.

The code already had the right shot ready and unit-tested for exactly this
moment — `climb_frame_for`'s own "nobody has climbed yet" branch sizes the
window off the beast's real height — it just never got a turn, because
`_focus_camera` always overrode it the moment anyone picked a hunter.

**Fix (`combat_3d.gd`):** new pure helper `anyone_off_ground(hunters)` (same
0.05 epsilon `climb_frame_for` already uses internally). `_focus_camera()`
now checks it first: while nobody has left the ground, it clears
`_focused`/`_user_framed` and returns, handing framing straight back to
`_aim_camera`'s per-frame ground shot. The shoulder truck/aim (`want_ots`)
is already gated on `_focused`, so "not over the shoulder while grounded"
comes for free — no second change needed. The moment anyone actually
climbs, `_focus_camera` runs exactly as it always has; nothing about the
tuned climbing camera (jump framing, hunter-offscreen dead zones, the OTS
shot mid-climb) was touched.

![[frames/fixer/2026-09-24-composition-ground-before.png]]
![[frames/fixer/2026-09-24-composition-ground-after.png]]

Before: `CAM dist=8.98`, legs and a shadow, hunters barely on screen at the
very bottom edge. After: `CAM dist=31.44` (the beast's own 20-unit height
driving the window instead of the fixed 8), whole beast head-to-foot, both
hunters small at the bottom with real ground between them and it, two of
the route's stones visible mid-body.

Left the yaw at the straight-on angle `_frame_beast` already opens on,
rather than inventing an untuned three-quarter turn — reads as "looking at
the fight," not down anyone's neck, which is the concrete complaint in
#11's own bullet 4. Flagged in the request as an open question if Nick
wants an actual three-quarter camera angle on top of this.

**Not touched, on purpose:** the stone route's own placement (only 2 of the
climb's stones read clearly in the after frame) is `#4`'s open hop-distance
work, already deep into its own investigation
(`2026-09-23-1846-...build-the-one-directional-stone-route.md`) — #11's own
notes say those rules "still apply," i.e. this request is about the camera,
not a stone-geometry rebuild. Didn't fold it in.

**Proof:** `run_tests.gd` — `anyone_off_ground`'s own epsilon tests
(grounded exactly at 0/just under 0.05/off the ground/mixed pair), plus two
`_focus_camera` behavior tests (holds the wide shot even with a stale
`_focused=true` left from a previous fight; still locks tight once someone
is actually climbing). `ALL TESTS PASSED`. Rendered `state=3d` (above),
`state=3dclimb` and a hover state — both pixel-unchanged from before this
fix, confirming the climbing camera and the HUD-hover path are unaffected.

A full `mode=play beast=cinder_jackal steps=80` regression (the playtester's
own `camera-not-over-shoulder`/`hunter-offscreen`/etc. checks) was still
running when the stop-hook forced this push — pushing now per the standing
rule (commit before verifying long-running background work, never lose a
push to the sandbox dying mid-flight). Will report the result on #11 the
moment it lands; if it surfaces a regression this write-up missed, the next
pass fixes or reverts it.

Left `#11` at `status: taken`, not `done` — the playtest hasn't confirmed
clean yet.

**Update, 17:43 EDT: the playtest came back clean.** Full 80-step run
played to a real ending (Pounce landed at step 30). Only failing check
across the whole run: the pre-existing `hop-distance-band` (Height 3→4 and
4→5), already fully diagnosed on `#4`, untouched by this change. Zero
`camera-not-over-shoulder`, zero `hunter-offscreen`, mid-hop camera
coverage 100% on every sampled hop — the climbing camera is confirmed
unaffected, not just reasoned about. Set `#11` to `to: nick` / `status:
open` with `ask:`/`waiting: false` filled in, per the standing rule that a
`from: nick` request asking for his own visual sign-off ("Nick can look at
a screenshot and say yes") isn't done until he says so — not marking it
`done` myself.

## This run — 2026-09-24 14:42 EDT

- **Did:** fixed the real, small case the playtester's own margin-guarded
  check kept finding after my last hunter-clamp fix: at the very start of
  a ground-level hop, the intent tag's left edge grazed the hunter's own
  on-screen body for exactly one sampled frame in every full run.
- **Worked?** Yes. Root cause wasn't the placement math (`intent_tag_pos`)
  at all — it was `_position_intent_tag()` running from `_process()`,
  which this node's own `_process()` always executes BEFORE the active
  hunter's climb tween applies that frame's own position move. So the tag
  was placed to clear a hunter position that was already one frame stale
  by the time the frame it belonged to actually rendered. Proved this live
  by instrumenting both sides (not guessed): the position `_position_intent_tag`
  read matched the PREVIOUS real engine frame's position, every single
  frame of the hop, not just the first tick. Tried `call_deferred` first —
  no change, still stale (deferred calls flush before the tween's own step
  too). Fix: run `_position_intent_tag` off `RenderingServer.frame_pre_draw`
  instead, which fires only once this frame's process/physics/tweens have
  already applied. Confirmed live: the AABB overlap that fired 1/28 sampled
  frames every full run is gone, and a fresh full 80-step regression plays
  clean to the fight's own real ending with only the pre-existing, unrelated
  `hop-distance-band` item left.
- **Next:** nothing of mine left on this one. Order-of-work for a future
  run: the stone-route hop-distance item (still `taken`, one real lever
  left after five ruled-out dead ends) or a fresh read of the fight's code
  paths if no request is open.
- **Need from you:** nothing.

![[frames/fixer/2026-09-24-intent-tag-hop-start-before.png]]
![[frames/fixer/2026-09-24-intent-tag-hop-start-after.png]]

## Now

Took the open `to: fixer` request
`2026-09-24-1002-playtester-to-fixer-intent-tag-still-grazes-hunter-at-hop-start.md`
(the only open `to: fixer` request this run — checked every request's
frontmatter; the stone/camera/hop-distance thread is still `taken`, not
`open`, and already carries five documented dead ends, so order-of-work
put this actual open request first).

**Reproduced first, live.** `xvfb-run ... playtest.gd -- mode=play
beast=cinder_jackal steps=1` on the unmodified tree reproduced exactly what
the request described: `FAIL [step 0] intent-tag-vs-hunter: the intent tag
overlapped the jumping hunter's own on-screen body for 1/28 sampled frames`,
on the opening `Tongue Snap` hop, hunter still low over the beast's front leg.

**Found the cause, not just the symptom, by instrumenting both sides.**
`intent_tag_pos` (the pure placement math) was never wrong — given ANY
`hunter_rect`, its clamp already keeps the tag off it, and the four existing
tests already prove that. The bug was in `_position_intent_tag()`'s own
timing: it runs from `Combat3D._process()`, but the active hunter's climb
tween applies ITS OWN per-frame `position` move at a point in the frame that
this node's `_process()` runs ahead of — so every single frame of a hop, not
just the first tick, `_position_intent_tag()` was reading (and placing the
tag to avoid) the hunter's position as of the PREVIOUS real engine frame,
one full step behind whatever that frame actually rendered. Proved this by
printing the hunter rect on both the placement side (inside
`_position_intent_tag`) and the check side (playtest.gd's own fresh
recomputation right after the frame it just watched render) and comparing:
the placement side's value for "frame N" was, every time, an exact match
for the check side's value from "frame N-1" — not a hunch, a live number
match across dozens of consecutive frames of the same hop.

**First attempt (`call_deferred("_position_intent_tag")`) did not fix it** —
identical staleness, because a deferred call also flushes before the tween's
own per-frame step. Second attempt worked: connect `_position_intent_tag`
to `RenderingServer.frame_pre_draw` in `_ready()` instead of calling it from
`_process()`. That signal fires once everything driving this frame — process,
physics, tweens — has already run, right before it is actually rendered, so
it is the first point where the tag can see the same hunter position the
frame is about to show.

**Proof.**
1. Re-ran the exact repro on the fixed tree: the AABB overlap the check
   found is gone (confirmed both via the check's own PASS/FAIL and by
   independently recomputing the intersection from the same printed numbers
   in Python — zero overlapping frames across the whole hop, where the
   unfixed tree had exactly one).
2. Two new tests in `run_tests.gd`. The first pins the MECHANISM with real
   captured numbers from two consecutive real engine frames (115, 116) of
   the live repro: pairing frame 116's crown position with frame 115's
   (stale) hunter rect reproduces a real >8px-margin overlap against the
   REAL frame-116 hunter rect; pairing it with frame 116's own hunter rect
   clears it. The second pins the actual fix in the scene: instantiates
   `combat_3d.tscn` and asserts `RenderingServer.frame_pre_draw.is_connected
   (c3d._position_intent_tag)` — a regression back to a direct `_process()`
   call would still pass every math-only test, so this is the guard that
   actually catches it. `ALL TESTS PASSED` (both new tests plus the full
   existing suite).
3. Full fresh `mode=play beast=cinder_jackal steps=80` regression: the fight
   played to its own real ending (Pounce landed, screen changed to
   Location3D) with **zero** `intent-tag-vs-hunter` fails (was 1 before),
   and only the pre-existing, unrelated `hop-distance-band` item left (62
   occurrences, the same already-`taken` thread five prior runs have been
   chipping at — untouched by this change).

Before/after frames above: `hop_000_03.png` from a live repro run, same
camera, same beast, same step. The overlap this check catches is a real but
small AABB graze (the hunter's real silhouette is tighter than the AABB
`hunter_screen_rect` measures, per that function's own doc comment), so the
two frames read close at a glance — this was never the artist's original
half-tag swallow, it is the much smaller sliver the request's own title
says survived that fix. The quantitative before/after (1/28 sampled frames
failing vs 0/28, across a full clean run) is the real proof; the frames are
context for what moment that was.

Commit: see `game/views/combat_3d.gd` (the `frame_pre_draw` fix, `_ready()`
and `_process()`), `game/tools/run_tests.gd` (2 new tests) in this push.
Filled the request's own `## Result` and set `status: done`.

## Old: 2026-09-24, dropped-slider-shows-wrong-timing-label

## This run — 2026-09-24 11:34 EDT

- **Did:** fixed the bug I self-filed last run — a dropped slider hold's
  MISS burst said "TOO EARLY" or "TOO LATE", which is never the real
  reason it missed (the press was fine; the player just let go too soon).
  Also fixed a same-neighborhood bug in the same pass: letting go past the
  rescue point (a real, paid downgrade, not a MISS) popped no burst at all.
- **Worked?** Yes on both. Reproduced the mislabel live first (before/after
  render, frames below), fixed it with a new "LET GO" label plus a small
  static rule so it's unit-testable, and confirmed the no-burst case now
  shows "GOOD" instead of nothing. Full regression playtest shows nothing
  new — only the two already-known, unrelated open items (hop-distance-band,
  intent-tag-vs-hunter sliver).
- **Next:** nothing of mine left on this one. Order-of-work for a future
  run: the stone-route hop-distance item (still `taken`, one real lever
  left after five ruled-out dead ends) or a fresh read of the fight's code
  paths if no request is open.
- **Need from you:** nothing.

![[frames/fixer/2026-09-24-dropped-slider-label-before.png]]
![[frames/fixer/2026-09-24-dropped-slider-label-after.png]]

## Now

Took the self-filed `to: fixer` request
`2026-09-24-0840-fixer-to-fixer-dropped-slider-shows-wrong-timing-label.md`
(oldest open `to: fixer` request this run — checked every request's
frontmatter; the other unfinished item, the stone/camera/hop-distance
thread, is `taken` not `open`, and already has five documented dead ends
against it, so per order-of-work an actual open request came first).

**Reproduced first, live.** `git stash` on just `hit_circle.gd` to get back
the pre-fix behaviour, rendered `state=3dslide beast=cinder_jackal`: a
perfect press let go at 20% of an 0.85s hold (well short of `SLIDE_RESCUE`,
72%) resolved `TIMING_MISS` as expected, but the burst read **"TOO LATE"**
— inherited from `_offset()`'s sign at press time, frozen ever since
(`_process()`'s holding branch never touches `_t`/`_approach`). Exactly the
mechanism the self-filed request predicted from reading alone.

**The fix.** `_finish(quality, dropped, released)` gets two new optional
flags. `dropped` marks a MISS that came from letting go early rather than a
bad tap; `released` marks any window-close that came from the player
letting go of a hold at all (MISS or not) — added because the rescue-window
downgrade case (`quality != MISS`) never touched `_burst_grade`/`_flash`
before, so its burst popped nothing (the press-time flash from `_fire()`
had long since decayed by the time a release that late can happen). The
label itself moved into a new static `HitCircle.burst_label(grade, dropped,
early)`, checkable with no camera or `_draw()` call, so a dropped MISS
shows "LET GO" and everything else keeps its old label unchanged.

**Proof.**
1. 9 new unit tests in `run_tests.gd`: the label rule in isolation for
   every grade/dropped/early combination it can reach, plus three
   integration tests driving a real `HitCircle` through
   `begin()`/`_fire()`/`_gui_input()` (dropped-before-rescue marks the
   burst dropped and still pops it; an unpressed timeout never marks
   dropped; released-past-rescue pops a GOOD burst instead of nothing).
   `ALL TESTS PASSED`, every existing slider test still green.
2. Rendered `state=3dslide` before/after, same camera, same beast, same
   probe (extended `screenshot.gd`'s existing 3-probe slider check to print
   and render the shown label rather than just the resolved quality):

![[frames/fixer/2026-09-24-dropped-slider-label-before.png]]
![[frames/fixer/2026-09-24-dropped-slider-label-after.png]]

   Before: "TOO LATE" for a dropped, dead-on-beat press. After: "LET GO".
   The harness's own print also confirms the secondary fix:
   `TIMING   let go late -> good OK burst="GOOD"` (this probe's burst never
   appeared at all before the fix).
3. Full regression: `mode=play beast=cinder_jackal steps=80` — only the
   two already-open, unrelated items (`hop-distance-band`, the still-open
   stone-route hop-spacing investigation; `intent-tag-vs-hunter`, the
   still-open `2026-09-24-1002-playtester-...` sliver). Nothing new.

Commit: pushed as part of this run — `game/ui/hit_circle.gd`,
`game/tools/run_tests.gd`, `game/tools/screenshot.gd` (the `3dslide` probe
now prints and can render the burst label it produces).

## Old: 2026-09-24, jump-hides-behind-intent-tag

## This run — 2026-09-24 08:46 EDT

- **Did:** fixed a fresh request from the artist — mid-jump, a hunter's own
  sprite could render behind the boss's intent tag ("† Attack 7"), hiding
  part of the hunter right at the peak of a hop. Same shape as the
  already-fixed party-panel overlap, just never extended to a moving
  hunter. Also spent part of the run ruling out one more dead end on the
  still-open stone-route hop-distance item, and found (but didn't fix, to
  keep this run to one thing) a real mislabeling bug in the slider
  minigame — filed both for the record.
- **Worked?** Yes on the intent-tag fix — reproduced the artist's exact
  numbers, fixed it so the tag now prefers sitting just above a hunter it
  would otherwise overlap (falling back to below, or leaving it alone, when
  there's no room), and a fresh live re-render of their exact repro hop
  shows the two clear of each other at every sampled frame. Full regression
  playtest shows nothing new — only the already-known, unrelated
  hop-distance-band failures.
- **Next:** the self-filed dropped-slider-shows-wrong-label request is real
  and ready to build from (mechanism, line numbers and a fix direction
  already written up) — good next pick if nothing higher-priority is open.
  The stone-route hop-distance item (last two short hops) is down to one
  real remaining lever (a 2-rung lookahead in Height 4's own candidate
  scoring) after this run closed off a 5th dead end.
- **Need from you:** nothing.

![[frames/fixer/2026-09-24-intent-tag-clear-of-hunter-hop000-06-after.png]]

## Now

Took the new `to: fixer` request
`2026-09-24-0822-artist-to-fixer-jump-hides-behind-intent-tag.md` (the only
open `to: fixer` request this run — it landed mid-run, after I'd already
started a code-reading pass per order-of-work item 3 since nothing was
open at the time; per "requests to you come before your own work," dropped
that pass — already written up as a self-filed request below — and took
this one instead the moment it appeared).

**The fix.** `intent_tag_pos` (`combat_3d.gd`) gets a new `hunter_rect`
parameter (default `Rect2()`, so the three existing call sites in
`run_tests.gd` are untouched). Unlike the party panel — fixed to the
top-left corner, so a one-sided "push the Y floor down" always clears it —
a hunter can be anywhere the camera can see, and the artist's own measured
numbers showed the hunter's bbox straddling the tag's y-range from both
sides at once. So this is a real 2D rect-overlap test: when it fires, the
tag moves to sit just above the hunter (closer to where it already tracks
the crown); if there's no room above, just below; if neither side has
room, the pre-hunter answer is left alone rather than picking an arbitrary
worse spot. `hunter_screen_rect()` (new) supplies the rect itself, by
projecting the active hunter's real, live-tweened AABB (`_merged_aabb` on
its holder node — the same node the hop tween moves, so mid-air position
and squash are both included, not just the resting foothold) through the
same `unproject_position`/`is_position_behind` the crown-tracking already
uses.

**Proof.** Four new tests in `run_tests.gd`, all built on the artist's own
reported step-0 numbers (tag `[295,168]..[450,204]`, Frog bbox
`[282,141]..[364,222]`): a sanity check that those exact inputs reproduce
their reported overlap through the old, hunter-blind clamp; the
above-fallback; the below-fallback (crafted so "above" has no room); the
no-clear-spot case (a hunter tall enough to span the whole legal band)
leaving the prior clamp's y untouched. `ALL TESTS PASSED`.

**Live re-render of their exact repro.** Fresh `--import`,
`mode=play beast=cinder_jackal steps=15`: `hop_000_03.png` through
`hop_000_14.png` (covering their own named `hop_000_06.png`) all show the
Frog fully clear of "† Attack 7", at 1:1. Frame above. Full regression:
only the already-open, unrelated `hop-distance-band` (32, identical
shape/count to every recent run) — no `script-error`, no new failure
category.

Commit: `73ae6b4` (`game/views/combat_3d.gd`, `game/tools/run_tests.gd`).

**Also this run, not the main item:**
- Ruled out a 5th dead end on the stone-route hop-distance ceiling
  (`...1846-...build-the-one-directional-stone-route.md`): confirmed by
  reading AND a live experiment that the Python reference model's own
  sigil height has zero effect on the shipped beast's actual sigil
  placement — `ai_beast.py`'s sigil branch never reads the `z` it computes
  from the reference model's fractions at all. Full mechanism and the
  experiment's numbers are in that request's own new section. Reverted the
  experiment before this note; nothing of it is in the pushed diff.
- Dispatched an Explore agent (order-of-work item 3, since nothing was open
  at the time) scoped to `card_view.gd`/`hit_circle.gd`. It found a real,
  reachable bug — a dropped slider hold shows a "TOO EARLY"/"TOO LATE"
  label that's actually just the stale sign left over from the original,
  successful press, never the real reason (letting go too soon) it missed.
  Self-filed rather than built, since the higher-priority intent-tag
  request landed while I was mid-investigation and "Do ONE thing" applied:
  `2026-09-24-0840-fixer-to-fixer-dropped-slider-shows-wrong-timing-label.md`.

## Old: 2026-09-24, intent-tag-hides-behind-party-panel

## This run — 2026-09-24 05:34 EDT

- **Did:** fixed the intent-tag-hides-behind-party-panel request the
  playtester filed — the boss's telegraph ("† Attack 7") could render
  partially behind the top-left party panel.
- **Worked?** Yes. Reproduced the playtester's exact numbers first, fixed
  the root cause they'd already diagnosed (the tag's clamp never accounted
  for the party panel), then ran the fight all the way to a real ending —
  zero `intent-hidden` failures anywhere in the run, including their own
  two named repro points.
- **Next:** nothing of mine left on this one. The still-open stone-route
  request (last two short hops, a real geometric ceiling per the last two
  runs) is the only other `taken` item sitting unfinished.
- **Need from you:** nothing.

![[frames/fixer/2026-09-24-intent-tag-clear-of-party-step000.png]]

## Now

Open `to: fixer` request
`2026-09-23-2141-playtester-to-fixer-intent-tag-hides-behind-party-panel.md`
(the only genuinely `open` `to: fixer` request this run — the two `taken`
stone/camera items are a previous run's own unfinished work with two
documented dead ends already on record; the last run explicitly deferred
picking that back up rather than risk a third partial attempt, so this was
the real front of the queue).

**Root cause, confirmed by reading before touching anything.**
`_position_intent_tag` (`combat_3d.gd`) clamps the tag's Y away from the
boss HP bar (`lo_y = 70.0`) and away from the hand (`hi_y`), but never
clamped X (or Y) away from the top-left party panel — and `lo_y=70` already
sits inside the panel's own y-range (`Party`'s own offsets in
`combat_3d.tscn`: `x:[16,320] y:[12,160]`). The only thing that ever kept
the tag clear was the beast's crown happening to project past x≈320, which
the playtester's own step 0 and step 13 repros show isn't reliable.

**Reproduced their exact numbers first.** Fed their reported tag rect
(`[257.5,70]..[417.5,104]`) and party rect (`[16,12]..[320,160]`) through
the OLD clamp logic and got the identical overlapping rect back before
writing a single line of the fix.

**Fix.** Pulled the rule into a pure static, `Combat3D.intent_tag_pos(p,
sz, vp, party_rect)` — provable with no camera or scene tree. When the
tag's X-range would overlap the party panel's real global rect, `lo_y` is
raised to clear the panel's bottom (+10px) instead of the HP bar;
otherwise nothing changes. `_position_intent_tag` now just reads
`_party.get_global_rect()` (or an empty `Rect2()` if it's missing/hidden)
and calls the static.

**Proof.**
- Three new tests in `run_tests.gd`, built on the playtester's own step-0
  numbers: the fix clears the panel via a Y move only (X untouched, still
  `257.5`); the SAME inputs with no party-panel awareness reproduce the
  exact reported overlap (proves the fixture really exercises the bug);
  a crown nowhere near the panel keeps the ordinary clamp byte-for-byte
  unchanged. `ALL TESTS PASSED`.
- Fresh `--import`, full `mode=play beast=cinder_jackal steps=40` under
  `xvfb-run`: the fight ran to a real ending at step 30 (Pounce landed).
  Zero `intent-hidden` failures across the whole run, including the
  playtester's own named step 0 and step 13 states. The only failures (62
  hits) are the already-open, unrelated `hop-distance-band` check from the
  still-open stone-route request.
- Rendered the real fight at step 0 and step 13 on the fixed tip and read
  both at 1:1: "† Attack 7" (step 0) and "Defend 5" (step 13) both sit
  fully clear of the party rows now. Frames in the request's own
  `## Result` and above.

Commit: `183a8a6` (`game/views/combat_3d.gd`, `game/tools/run_tests.gd`).

## This run — 2026-09-24 02:54 EDT

- **Did:** fixed the boss-damage-popup-offscreen-at-sigil request. A boss
  hit's damage number rises a fixed WORLD distance; a close-in camera (the
  sigil's own tight framing) can turn that into enough screen pixels to
  poke past the top edge by a few px, exactly what the playtester measured
  (676,-5 on a 1280x720 frame). Added a small check that scales the rise
  down so it lands on a safe pad instead of past it.
- **Worked?** Yes, provably — pinned with three new tests built on the
  playtester's own exact numbers, plus a full live playtest run (0
  `damage-popup-offscreen` fails). One honest wrinkle: I could not make the
  ORIGINAL failure happen live on the current tip any more, with or without
  my fix — I think an unrelated later change (the stone-route fix moving
  the sigil off the nose) shifted the hit point just enough to no longer
  clip. Fixed the real underlying gap anyway rather than leaving it to
  chance; full reasoning is in the request's own `## Result`.
- **Next:** also spent part of this run confirming (not fixing) the
  stone-route request's last two short hops — instrumented the build live
  and proved it's a genuine "no real point on the mesh reaches far enough"
  ceiling, not a retry-budget bug (raising 4 attempts to 20 changes
  nothing). Whoever picks that back up should read its own `## Result` —
  a fourth dead end is now ruled out on top of the previous run's two.
- **Need from you:** nothing blocking.

![[frames/fixer/2026-09-24-boss-popup-sigil-step19-after.png]]

## Now

Took the open `to: fixer` request
`2026-09-23-1735-playtester-to-fixer-boss-damage-popup-offscreen-at-sigil.md`
(priority normal — the only OPEN `to: fixer` request left; the other,
`...2141-...intent-tag-hides-behind-party-panel.md`, is also normal and
still open for the next run). Passed over the `taken`, priority-high
`...1846-...stone-route...` item rather than attempt a third structural
fix blind — see below — since two failed attempts were already on record
and a third risks becoming a fourth without ever landing something
finished this run.

**The fix.** `combat_3d.gd`: new `POPUP_TOP_PAD` (30px, matching the scale
of the existing `GAUGE_PAD_TOP`) and `popup_rise_scale(screen_y_at,
screen_y_full, pad)` — a pure function next to the existing
`popup_move_reach`. `_damage_popup` now projects the popup's start and its
full, un-scaled rise destination to screen space before starting the tween;
if the destination would land above the pad, the rise is scaled down by
exactly the fraction that lands it ON the pad instead of past it. Verified
against the playtester's own reported numbers to the pixel (a rise that
lands at screen y=-5 with a start at y=650 and a 30px pad scales down to
land at EXACTLY y=30, not still over or short — the test computes this
identity directly, not just a pass/fail band).

**Why I could not reproduce the original bug live, and why I fixed it
anyway.** A fresh `mode=play beast=cinder_jackal steps=25-30` run on the
UNMODIFIED code (`git stash`) also shows 0 `damage-popup-offscreen` fails,
on the exact same step 19 / 'Tongue Snap' / (376,475) the report named.
Between the report (17:35) and now, the stone-route request
(`...1846-...`) moved the Cinder Jackal's own sigil position — its own
write-up says the sigil "no longer sits on the tip of the snout... lands
near the base of the neck/shoulder instead." That plausibly moved the hit
point enough to pull the popup back on screen by itself, on a bug that was
only ever 3-5px over to begin with. The architectural gap the playtester
actually diagnosed (a fixed world rise, a camera whose zoom varies) is real
regardless of where the sigil happens to sit today, so I fixed it directly
rather than leaving it to depend on geometry nobody meant to fix it.

**The stone-route investigation (not a fix — that request stays `taken`).**
Instrumented `ai_beast.py` live (temporary debug print, not committed),
re-feeding the shipped `cinder_jackal_ai.glb` through the pipeline exactly
like the previous run did. Confirmed the 4-attempt push/re-snap loop for
Height 3→4 is not attempt-starved: raised to 20 attempts, every single one
re-derives the IDENTICAL target point (`enforce_hop_floor`'s own answer,
gap=0.39999) but the real mesh surface at that Y never reaches it
(re-snapped real distance stays `0.3603` against a `0.3709` floor) — the
loop just repeats the same short answer forever. Height 4→5 (the sigil)
shows the same shape from a different angle: its own real, route-continuing
candidates cap out at `0.2967`, well under the floor, because none of the
real head/neck surface in its search sweep reaches further along the
route's own direction. Full numbers and the conclusion (a genuine
geometric ceiling for these two rungs, not a bug in the retry loop) are in
the request's own new section, dated this run.

## This run — 2026-09-24 00:24 EDT

- **Did:** picked up the two unfinished pieces of the stone-route request.
  Confirmed the next-hold ring already lights up correctly with no code
  change needed. For the hop-distance rule, built the real math, added a
  permanent build-time check for it, and made two of the five real hops on
  the Cinder Jackal noticeably better-spaced.
- **Worked?** Partly. Two hops now sit comfortably inside the intended
  range instead of barely squeaking by; the two hops closest to the very
  top (near the sigil) are still too short — I tried two different fixes
  for those and both broke something else (the climb briefly doubled back
  on itself), so I undid both rather than ship a regression.
- **Next:** whoever picks this back up should read the request's own
  `## Result` — it names exactly which two approaches already failed and
  why, so that's two dead ends already ruled out.
- **Need from you:** nothing blocking. If you want, take a look at the
  before/after frame below — it shows real progress even though the job
  isn't finished.

![[frames/fixer/2026-09-24-hop-distance-route-before.png]]
![[frames/fixer/2026-09-24-hop-distance-route-after.png]]

## Now

Open `to: fixer` request
`2026-09-23-1846-playtester-to-fixer-build-the-one-directional-stone-route.md`
(priority high, still the only high-priority item open or taken this run —
the other two open `to: fixer` items, `...1735-...boss-damage-popup-
offscreen-at-sigil.md` and `...2141-...intent-tag-hides-behind-party-
panel.md`, are both `priority: normal`). Continued rather than switched,
since it was already `taken` by a previous run of this same agent with two
of its three items unfinished — per order-of-work, an unfinished `taken`
item is this queue's own unfinished business, not something to leapfrog for
a newer `open` one.

**Item 3, next-hold ring: verified correct, no fix needed.**
`_refresh_ledge_marks`/`ledge_mark_state` (`combat_3d.gd`) already derive
the highlight purely from `foot`/`next_safe` — state read fresh on every
`_refresh()` (every state broadcast, hunter switch, End Turn), never gated
on a card being tapped. Rendered `state=3d` at the very start of a fresh
fight, before either hunter has played a card: the next safe stone already
glows gold. Full detail and the frame are in the request's own `## Result`.

**Item 2, 2.4-9.2 unit hop band: real but incomplete.** `route.py` gained
`hop_world_distance()`/`hop_distance_violation()`, solving `hop_arc()`'s own
clamp for the DISTANCE it clamps, not the arc height it produces (an easy
mix-up — the request's own numbers name the 2.4/9.2 band as the distance,
and I nearly wired the wrong pair of constants before checking the algebra
against `hop_arc()`'s actual formula). Hard-gated into `beast.py`'s
`_prove()`, scoped to Heights exactly one apart (a beast with sparse named
anchors can legally skip several Heights in one hop; that's a different move
with its own distance, not what this rule is for). `ai_beast.py`'s middle-
rung search now prefers a real candidate already inside the band over the
widest-reaching one. Measured on the real shipped `cinder_jackal_ai.glb`
(re-fed back into its own build as the source, no Meshy spend): Height
1→2 and 2→3 went from just barely clearing the floor to comfortably inside
the band; Height 3→4 and 4→5 (the two nearest the sigil) stay short —
2.39 and 1.52 world units against a 2.42 floor.

**Two structural fixes tried for the last two hops, both reverted.**
(1) Widening the per-rung search window and centring it on the previous
rung, instead of always the same fixed `near_front.y` band: does find a
real in-band candidate for every hop, but lets a middle rung swing far
enough sideways that the LIVE `_climb_points` come out reversed —
`PLAYTEST FAIL: climb rung 4 reverses the route -- -3.50m backward`,
reproduced live, not just predicted. (2) The sigil's own pre-existing
fallback (moving a rejected pick, then re-raycasting with no surface-normal
check) can land on a real but wrong point — confirmed live, the sigil
landed on the neck instead of the head. Fixed (2) on its own (now safe,
in this push) but it doesn't unlock (1) without reintroducing the reversal.
Full numbers, the exact playtest failure lines, and what a real fix needs
are all in the request's `## Result` — read that before trying either
approach again.

**Proof this run.** `python3 tools/blender/test_route.py`: 33 assertions,
`ALL TESTS PASSED` (20 new, covering the hop-floor math and the push/re-snap
helper against the real Cinder Jackal numbers both before and after this
fix). `run_tests.gd`: `ALL TESTS PASSED`, unaffected (no GDScript touched).
Fresh `--import`, full `mode=play beast=cinder_jackal steps=80` under
`xvfb-run`: zero `route-reversal`, zero anatomy failures; the only
failure is the pre-existing, already-open `intent-hidden` (12 occurrences,
unrelated). Rendered the real shipped `.glb`'s own `climb_N` markers
before/after in Blender (foot red, sigil pale yellow) — the top three used
to sit almost on top of each other; now all six are clearly separated,
visible progress even where the numbers don't yet clear the floor.


## This run — 2026-09-23 20:45 EDT

- **Did:** fixed the Cinder Jackal's climb reversal at its actual root, not
  just for this one beast. Both `ai_beast.py` (the Meshy-rebuild raycast)
  and `beast.py` (a human typing `anchor()`/`mark()` calls) can place a hold
  that doubles back past the one before it — Nick asked for the cause fixed,
  not a one-off nudge. One shared rule now, `tools/blender/route.py`.
- **Worked?** Yes. Re-ran the real pipeline on the real shipped Cinder Jackal
  (no network, no Meshy credits — reused its own already-exported glb as the
  source): the sigil went from jumping 1.08 units backward past every hold
  used to reach it, to being the smallest, forward-most step of the six.
  Rendered proof below. Only the route's DIRECTION is fixed this run — the
  spacing band and the next-hold ring (parts 2 and 3 of the same request)
  are still open.
- **Next:** whoever picks this back up should read the request's own
  `## Result` for exactly what's left — the 2.4-9.2 unit spacing band, and
  checking whether the next-hold ring already fires early or needs a real
  change. The regression playtest finished clean after I first wrote this
  up (see below) — nothing left to chase there.
- **Need from you:** a look at the trade-off called out in the request —
  the fixed sigil now sits near the neck/shoulder rather than the tip of the
  snout, because that's the nearest real head-adjacent surface that doesn't
  reverse the climb. Say if that's fine or if the sigil should be hunted
  further back along the skull specifically.

![[frames/fixer/2026-09-23-stone-route-sigil-reversal-before.png]]
![[frames/fixer/2026-09-23-stone-route-sigil-reversal-after.png]]

## Now

Open `to: fixer` request
`2026-09-23-1846-playtester-to-fixer-build-the-one-directional-stone-route.md`
(priority high, oldest-among-high-priority open requests this run — the only
other open `to: fixer` item, the boss-damage-popup-offscreen-at-sigil
request, is `priority: normal`). Full technical write-up, before/after
numbers, and the trade-off flag are all in that request's own `## Result` —
not duplicating them here. Left `status: taken`, not `done`: only item 1 of
the request's three numbered asks is finished.

**Why I stopped at item 1.** This request bundles three genuinely separate
pieces of work (route direction, hop-distance spacing, ring telegraphing)
under one ticket. Item 1 was both the one Nick's own approval note called
out by name ("fix the CAUSE... a per-beast patch that leaves the next beast
broken is not done") and the one with an actual measurable bug already
proven live (the 1.08-unit reversal) — worth doing well and proving properly
rather than splitting attention across all three and shipping any of them
half-verified. Items 2 and 3 need their own reproduce-fix-prove pass.

**Lease/time note.** Standing up Blender in this sandbox (download +
regenerate + render) ate a real chunk of this run's budget; the `mode=play`
regression playtest was still at 16/80 steps (slow sandbox this run) when I
committed and pushed the fix, rather than hold the finished part hostage to
a slow background render. It finished shortly after, in the same session:
full 80-step fight, real ending (Pounce at step 30), one failing check —
`damage-popup-offscreen` at step 9, which is the already-open, unrelated
`2026-09-23-1735-playtester-to-fixer-boss-damage-popup-offscreen-at-sigil.md`
(a hit on the boss near the sigil, exactly that request's shape), not this
change. `run_tests.gd` (unaffected — no GDScript touched) and the
pure-Python `test_route.py` both pass; the in-game `state=3d` render shows
no errors against the regenerated asset. Regression check: clean.

## Old: 2026-09-23, stones-camera-and-hunter-spacing
left `taken` (not `done`) — camera and spacing are finished and proven,
stones is still open on your answer elsewhere. Filed
`2026-09-23-1736-fixer-to-playtester-stone-route-technical-numbers.md` to
converge with the playtester's own proposal (already written, sitting on
`to: nick` in 1434) rather than duplicating it.

**Camera.** `_unhandled_input`'s drag/pan/zoom branch and `_fly()`'s
WASD/QE now both open with `if not free_camera_allowed(OS.is_debug_build()):
return`. `free_camera_allowed` is a one-line static (`return
is_debug_build`) pulled out only so `run_tests.gd` can pin the boolean
identity down — nothing in this sandbox can produce an exported Release
build to flip `OS.is_debug_build()` itself, so the test proves the rule
isn't accidentally inverted, not that the OS call reads false in a real
Steam export (that still wants checking once a build exists). Verified
`OS.is_debug_build()` prints `true` under plain `--headless` here, and
re-ran `state=3dfreecam` after the change — drags at centre/sky-left/
top-bar exactly as before (the ground-gap/gauge "DEAD" zones and the
harness's own `SHOT TIMEOUT` are pre-existing, reproduced identically on
`git stash` of my changes — not something I introduced).

**Hunter spacing.** `GROUND_STANDOFF` (0.62) was always meant to hold
hunters off the beast's front face, but the formula that used it
(`_beast_box.end.z + _beast_box.size.z * GROUND_STANDOFF`) scaled the
standoff by the beast's FULL nose-to-tail depth. For a squat beast that's
roughly the same as scaling off the front-edge distance alone (the box is
symmetric about the origin, so `end.z` already implies half of `size.z`) —
but the Cinder Jackal is long and low, so `size.z` (32.98) is almost
exactly double `end.z` (16.49), and the formula was counting the tail
twice: once implicitly in `end.z`, again explicitly in the `* size.z`
term. That inflated the WANTED standoff to 36.95 — plausible-looking, but
irrelevant, because the arena radius (`_arena_r`, from `_show_beast`'s
`want_r`) was sized only off the beast's own footprint (20.45) with no
awareness of what the standoff formula wanted, so its own clamp
(`_arena_r * 0.86` = 17.59) silently won and hunters landed at z=17.59 —
1.1 units past the front edge (16.49). New rule,
`ground_standoff_for(front_edge) := front_edge * (1.0 + GROUND_STANDOFF)`,
called from BOTH `_show_beast`'s `want_r` (divided by the same 0.86 so its
own clamp can never bite) and `_place_hunters`' ground clamp, so the two
can't drift apart again. Live: hunters now at z=26.72, a 9.5-unit gap.
Frames in the request. 5 new unit tests (`ground_standoff_for` grows with
front edge / matches the live jackal numbers exactly / survives the arena
clamp it used to lose to; `free_camera_allowed` pins both ways) —
`ALL TESTS PASSED` before and after.

Fresh sandbox, Godot 4.7.1 + `--import`. Started an 80-step `mode=play`
playtest as extra verification beyond the unit tests and rendered frames
above (which already meet the bar); it was still running when I wrapped up
this run — if it surfaces anything, the next run picks it up.

## Old — 2026-09-23 15:01 EDT, pull_ally gate over-blocking mixed cards

- **Did:** fixed a card-playability bug — Chain Lift and Tongue Grab (real
  reward cards, Goblin Engineer/Frog) went completely unplayable, losing
  their Block/Rhythm grant too, whenever the ally they'd pull was just out of
  grapple range.
- **Worked?** Yes. Grappling Arm (the pure-pull card) keeps its existing
  "unplayable out of range" behaviour exactly as-is; only cards that pair the
  pull with something else are affected.
- **Next:** nothing blocking. Worth someone eventually checking Guide Rope
  (same `pull_ally + ally_block` shape) actually reaches a reward pool too.
- **Need from you:** nothing — flagged the one small rules call I made (kept
  Grappling Arm hard-blocked rather than loosening every pull_ally card) in
  the request write-up in case you'd rather I'd gone the other way.

## Now

No open `to: fixer` request this run (checked every request's frontmatter —
the only other open item, the boss-relic-pool sizing question, is still
sitting on `to: nick`, untouched, someone else's call). Fresh sandbox, Godot
4.7.1 + `--import`, `run_tests.gd`: `ALL TESTS PASSED` before touching
anything.

**Order-of-work item 2** (a playtest failure nobody has filed): full fresh
baseline, all three modes, all clean —
`mode=play beast=cinder_jackal steps=80`: `PLAYTEST OK: 0 failing check(s)`
(the first attempt hit this sandbox's known flakiness — see `tools/agents`
notes on prior runs stalling — and my own `timeout 590` wrapper killed it at
56/80 steps; a second run with no artificial cutoff, backgrounded properly,
completed clean in full). `mode=hover`: `0 flips`. `mode=hands`: `0 fails`.
Nothing to file.

**Order-of-work item 3** (a bug in the jackal fight's own code paths, found
by reading): dispatched an Explore agent scoped to `combat_3d.gd`,
`card_view.gd`, `hit_circle.gd`, and `core/combat.gd`'s Frog/Goblin Engineer
card fields, given the long list of functions prior runs already scarred
(`hop_arc`, `stand_offset_x`, `wants_toon`, `card_is_slider`, `stone_point`,
`popup_move_reach`, `_focus_camera`'s is_inside_tree guard, `note_hit`,
`reward_header_text`, and others) so it wouldn't re-surface one of those, and
specifically pointed at `_meld_cards`'s ~20 summed/maxed fields — only the
`grip`/`timed_hits` pair (the slider-swallow fix) had been individually
audited against how it's actually consumed downstream.

**What it found, confirmed myself before touching anything.** Not a meld
bug — `can_play()` itself (`core/combat.gd:331-339`):

```gdscript
if card.pull_ally > 0 and has_ally(pi):
    var gap: int = ps.foothold - int(players[ally_index(pi)].foothold)
    if gap <= 0 or gap > card.pull_ally:
        return false   # blocked the ENTIRE card
```

Every sibling ally field (`ally_block`, `ally_grip`, `ally_energy`,
`sac_ally_grip`) is never gated in `can_play()` at all — each one just no-ops
gracefully inside `play_card()` if its own target condition isn't met, the
"playable-and-inert" pattern this exact function's own comments already
describe for the has_ally case (#86 duty 2, the prior fix directly above
this one in the file). `play_card()` already had that same graceful fallback
for `pull_ally` too (`"%s plays %s — no ally in grapple range."`,
combat.gd:1225) — but `can_play()` never let a mixed-effect card reach it;
the whole card came back unplayable instead.

**Confirmed two real, reachable cards hit this**, both checked against
`characters.json`'s actual reward pools:
- **Chain Lift** (Goblin Engineer's reward pool, `characters.json:299`):
  `{"cost": 2, "pull_ally": 5, "ally_block": 5, "text": "Ally gains 5 Block.
  Pull your ally up to you."}`
- **Tongue Grab** (Frog's reward pool, `characters.json:39`):
  `{"cost": 1, "pull_ally": 4, "rhythm": 1, "text": "Rhythm 1. Pull your
  ally up to you."}`

Concrete case: Goblin Engineer at foothold 2, ally at foothold 4 (level or
above). `gap = 2 - 4 = -2 <= 0` → `can_play()` false → Chain Lift renders
disabled in hand — the player can't play it for its 5 Block, an effect that
has nothing to do with the grapple gap, purely because the OTHER half of the
card (the pull) isn't valid right now. Same for Tongue Grab's Rhythm 1. A
third card, Guide Rope (`pull_ally: 4, ally_block: 4`), has the identical
shape — didn't chase where it's offered from, but the fix covers it either
way.

**Fix.** `can_play()`'s gate now only hard-blocks when the pull really is
the card's entire reason to exist (`card.ally_block == 0 and card.rhythm ==
0`). Grappling Arm (neither field set, pure `pull_ally`) keeps today's exact
behaviour unchanged. Chain Lift/Guide Rope/Tongue Grab now fall through; the
pull itself still no-ops gracefully and logs it, same as a solo fight with
no ally at all already does.

**Rules call, smallest sane version — flagged rather than guessed.** An
existing test (`_test_grappling_arm_pulls_ally`) explicitly attributes "the
card is simply UNPLAYABLE" out of range to Nick — a deliberate call for the
pure-pull case. Rather than flip that too (which every OTHER ally field's
own behaviour would argue for, per the finding above), I kept it as-is and
only widened the gate for cards that have something else to do. Small
enough I didn't think it needed its own `to: nick` note, but said so plainly
in the request in case he'd rather I'd gone further.

**Reproduced first.** Two new tests against the unfixed tree failed exactly
as predicted: Chain Lift/Tongue Grab both came back `can_play() == false`
when level with the ally, and their Block/Rhythm never landed either — not
just the pull, the whole card was inert. (One of my own first-draft
assertions was ALSO wrong the first time through — checking `log[-1]` for
the pull's own no-op line, not realizing the card's Block/Rhythm log line
comes right after it, not before; fixed the test to search the log instead
of assuming position, verified that failure was a test bug and not a second
real bug before moving on.)

**Proof.** Three new tests in `run_tests.gd`:
- Chain Lift stays playable out of range, its Block lands on the ally, the
  ally's Height doesn't move, and the pull's own "no ally in grapple range"
  line is still logged.
- Tongue Grab stays playable out of range and its Rhythm lands.
- Regression guard: Grappling Arm (no other effect) is still unplayable out
  of range, exactly as before this fix — proves the narrowing didn't
  silently remove the gate outright.

All three failed on the unfixed tree, pass on the fixed one. Full suite:
`ALL TESTS PASSED`.

**No live frame.** Pure `core/combat.gd` rule, same convention the melded-
slider and `note_hit` fixes used earlier today — `Dev`/`hand=` can force
which cards are dealt but has no switch to force a specific foothold gap, so
there's no harness path to put Chain Lift in hand exactly level with an
ally on-screen. The pre-fix full `play`/`hover`/`hands` baseline above (run
before this change, same tip) is the general-regression check; the unit
tests are the correctness proof, per this file's own established pattern
for pure timing/rule fixes with no rendering surface.

Self-filed and self-fixed —
`requests/2026-09-23-1500-fixer-to-fixer-pull-ally-gate-blocks-a-cards-other-effect.md`.

## Next

Item 3 found a real gap in a part of `_meld_cards`'s field list that hadn't
been individually audited before (this run only chased `pull_ally` itself,
not a melded combination) — worth someone eventually checking the REMAINING
~18 summed/maxed fields in `_meld_cards` the same way, not just the ones
already scarred (`grip`/`timed_hits`, `pull_ally`/`cheapen_amount` per the
existing meld tests). Also worth finding where Guide Rope is actually
offered from and confirming it's reachable, same as Chain Lift/Tongue Grab
were confirmed here. `hover`/`hands` baseline completed clean this run (all
three modes, unlike some recent runs that had to drop one for CPU headroom).

## Old: 2026-09-23, hunter-display-path-has-no-toon-or-rig-support

Took the high-priority `to: fixer` request
`2026-09-23-1330-artist-to-fixer-hunter-display-path-has-no-toon-or-rig-support.md`
over the older, normal-priority shared-foothold-side-spacing request (still
sitting self-filed, see `## Old` below) — Nick's own note inside the newer
request names it "the top of the fixer queue," and fixer.md's order-of-work
puts `priority: high` before "oldest first" among open requests.

**What it asked for.** The rigged, toon-shaded, idle-animated display path
`AI_ART`/`_shade_model`/`_show_beast` already gives a beast (the Cinder
Jackal's own `cinder_jackal_ai.glb`) only ever matched on `root == _beast` —
no hunter id could reach it however it was tagged, so any Meshy-built hunter
rebuild would have to ship un-toon-shaded and un-animated. Confirmed all four
of the artist's named gaps by reading first: `AI_ART` beast-only (line ~30),
`_shade_model`'s toon branch gated on `root == _beast` (~2518), `_beast_anim`
only ever wired in `_show_beast`/`_strike` and never touched by
`_spawn_hunter`, and `location_3d.gd`'s `_place_hunters` with no shading call
at all.

**Generalized each gate at its own spot**, per-detail writeup and the live
proof in the request's own `## Result`:
- New `HUNTER_AI_ART` table (parallel to `AI_ART`, kept separate since
  `AI_ART`'s own doc comment and readers mean "beast" specifically) — a
  character id listed here beats even your own `cast/<id>.glb`, same
  precedence `AI_ART` already has over a beast's Python-built model.
- `_shade_model`'s inline `_beast_toon and not is_ground and root == _beast`
  pulled into a pure `Combat3D.wants_toon(beast_here, beast_toon,
  force_toon)` — every existing call keeps `force_toon` defaulted `false`
  (byte-for-byte unchanged behaviour for beasts/ground); `_spawn_hunter`
  passes `true` only for a `HUNTER_AI_ART`-tagged id whose `.glb` exists.
- `_spawn_hunter` now runs `_find_anim`/idle-loop wiring exactly like
  `_show_beast` does for the beast, stored as a new `"anim"` key on the
  hunter dict.
- New `_hunter_play(slot, anim)` (`_beast_play`'s own twin, one hunter's
  `AnimationPlayer`), wired into `_react`: a hunter's own damage (existing
  per-hunter `hunter_dmg[i]` loop) plays `"hit"`; a hit landing on the boss
  plays `"attack"` on every hunter together — the shared state diff carries
  no per-hunter attribution for which hunter's card connected, the same
  aggregate granularity `_beast_play("attack")` already uses for the beast's
  side of a hit. Written down as a known limit in the request rather than
  faked finer than the data supports.
- `location_3d.gd`'s `_place_hunters` got the matching lookup +
  `BEAST_MODEL.toon_all(n)`, the same treatment its own `_lay_out_the_felled`
  already gives a felled `AI_ART` beast on the same screen.

**Proof.** Four new `wants_toon` unit tests (`run_tests.gd`) covering all
four cases: AI_ART beast unchanged, a plain beast doesn't toon-leak from a
tagged hunter nearby, a tagged hunter toons on its own regardless of the
beast, an untagged hunter never toons even beside a toon beast. Reproduced
the pre-fix gate first — temporarily reverted `wants_toon`'s body to
`beast_here and beast_toon` (force_toon ignored) — the "hunter opts in on
its own" test failed exactly as predicted, the other three still passed.
Restored, `ALL TESTS PASSED`.

**Live verification, exactly as the request's "Done when" asked** — no new
asset needed. Temporarily set `HUNTER_AI_ART := {"frog": ""}`, rendered
`state=3d beast=cinder_jackal` before/after, cropped to the frog:

![[frames/fixer/2026-09-23-hunter-toon-path-frog-before-after.png]]

Left: flat `CREATURE`-shader frog. Right: the black ink outline + toon ramp
the Cinder Jackal's own `AI_ART` build wears — confirms the tagged hunter
really routes through `_shade_model`'s toon branch end to end, not just in
the unit test. `frog.glb` has no `AnimationPlayer`, so the idle-loop half
couldn't be shown live this run — `_find_anim`/`_beast_play`'s own logic is
reused unchanged by `_hunter_play`, already proven on the beast side, and
will fire the moment a real rigged hunter `.glb` exists. Reverted the tag
before committing; `HUNTER_AI_ART := {}` ships empty.

**Live regression check**, since the new code sits in `_react` (the per-tick
state-diff hot path, run for every hunter every fight): full fresh
`mode=play beast=cinder_jackal steps=80`, pushed the code first per the
"never end a run on a background task" rule, ran this after (in the
background once it ran past the foreground timeout — the code was already
pushed by then, so nothing was at risk). Result: `PLAYTEST OK: 0 failing
check(s)` through the whole 80 steps — exercised Meld/Catapult+Burn Coal,
Leapfrog, Brace, Take Aim, Scramble, several real climbs and a real fall
(foot 10→4, hp 20→14 at step 71) — no regression from the new `_hunter_play`
calls in the per-hunter damage loop or the per-tick `boss_hit` branch. The
`ObjectDB`/resource-leak warning at exit is the same pre-existing
`Music`-at-`quit()` harness noise several earlier entries in this log already
identified and ruled out; not new here.

Commits: pushed in two parts — the fix/tests/request/frame first, this
regression result second (see `## Log` for both hashes).

## Old: 2026-09-23, shared-foothold-side-spacing-clears-the-model

Open `to: fixer` request
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`
— the oldest open request that run (self-filed two runs earlier), taken over
the newer `2026-09-23-1330-artist-to-fixer-hunter-display-path-has-no-toon-or-rig-support.md`
per order-of-work "oldest first" among the requests open at the time.

**Reproduced first, headless**, with the request's own live numbers:
`stand_offset_x(3.901302, +1.0, 12.92)` then `stone_point(...)` on that
result reproduced the request's exact `home` (5.335, 13.826, 7.031) and
x-drift (1.434 against the check's own 1.06 tolerance) before touching
anything.

**Found the cause, not the symptom.** The request's own two sub-questions
(narrow `stand_offset_x`'s spacing at a narrow feature, or build a stone per
side) both assumed the side-spacing math itself was too generous. It wasn't.
`stone_point()` — added the same day as the foothold-4 z fix this request
split off from, to push a standing point off the skin onto its floating
stone — pushed **radially away from world origin** in the XZ plane
(`Vector3(on_skin.x, 0, on_skin.z).normalized() * HUNTER_HEIGHT`), not
forward off the body. Fine near the spine (x≈0); wrong the moment an anchor
already sits off-axis in x on its own, which foothold 4's anchor does (3.9,
it's the ear) even before any side offset is added. That radial push added
its OWN ~0.42 units of x-drift on top of `stand_offset_x`'s already-correct
1.01, compounding past the tolerance. `stand_offset_x`'s spacing was never
the problem, and the single centred stone was already close enough to serve
both sides once the extra drift was gone — building a second stone (the
request's sub-question 2) would have masked this, not fixed it.

**Fix.** `stone_point()` now pushes purely forward (+z), the same "away from
the body" direction `_front_of_beast`/`GROUND_STANDOFF` already use
everywhere else in this file, so it can never add an x-component regardless
of an anchor's own x. One function; every call site (`_stand_on_model`,
`_build_float_stones`, `_build_ledge_marks`) is unchanged.

**Proof.** Three new unit tests in `run_tests.gd`: `stone_point` only ever
touches z, not x/y; the push is exactly one `HUNTER_HEIGHT`; and the repro
itself — `stand_offset_x` + `stone_point` at foothold 4's real anchor/width
stays inside check 8's own tolerance formula. Ran all three against the
unfixed function first (`git stash` on just `combat_3d.gd`): failed exactly
as predicted (1.434 vs 1.06). Restored the fix, reran: `ALL TESTS PASSED`.

**Live playtest.** Full `mode=play beast=cinder_jackal steps=80` under
`xvfb-run`: `report.md` — zero FAIL lines. HUD confirms both hunters shared
foothold 4 at step 34 ("↑4/5" on both); the frame shows the side-shifted
Goblin Engineer standing plausibly on the ear/mane, not clear of both the
model and the Frog's stone the way the request's own "before" crop showed.

![[frames/fixer/2026-09-23-shared-foothold4-fixed-step034-crop.png]]

Commit: pushed as part of that run (see `## Log` below for the hash).

## Old: 2026-09-23, end-turn-crash-at-sigil-solo-flip

Took the high-priority end-turn-crash-at-sigil-solo-flip request. Root cause was NOT a race in the sense the playtester guessed (it's deterministic, just timing-*triggered*) — game_3d.gd's router removes and frees the current Combat3D view SYNCHRONOUSLY, mid-_end_turn(), whenever that End Turn is the one that ends combat, because _client.end_turn() resolves all the way through the host and back to state_updated.emit() before returning. _end_turn() then keeps going regardless and reaches _cam.look_at() on a camera that just left the tree. Fixed with a one-line is_inside_tree() guard on _focus_camera (same idiom location_3d.gd already uses for this exact router race), two new tests against a real combat_3d.tscn instance, pushed.

Open `to: fixer` request `2026-09-23-1000-playtester-to-fixer-end-turn-crash-at-sigil-solo-flip.md`
(the only high-priority open request this run, and a real engine-level
crash — took it over the older normal-priority
shared-foothold-spacing request still sitting self-filed from two runs ago).

**Reproduced by reading, then confirmed live.** The playtester's own report
already did the hard work of naming the exact stack
(`_end_turn` -> `_apply_solo_turn_flip` -> `_focus_camera` -> `_apply_orbit`
-> `_cam.look_at`) and flagged it as "timing/race" without chasing which
upstream event does the freeing — that was the open half. Traced it: `_end_turn()`
(combat_3d.gd:873) calls `_client.end_turn(_cmd_slot())` FIRST, and
`GameClient.end_turn` -> `LocalTransport.send_command` -> the in-process
`GameHost` resolve -> `_broadcast_state()` -> `GameClient._on_message` ->
`state_updated.emit(...)` all happen **synchronously**, before
`_client.end_turn(...)` returns control to `_end_turn()`. `views/game_3d.gd`
(the phase router) connects its own `state_updated` listener in `_ready()`,
which — since it's the parent that instantiates Combat3D as a child — fires
*before* Combat3D's own listener in Godot's per-signal FIFO order. So the
instant an End Turn is the one that takes the fight out of "combat" (boss
dies, or any other phase change), `game_3d.gd`'s `_sync()` does exactly what
its own comment says it must: `remove_child(_view); _view.queue_free()` on
the CURRENT Combat3D — the very instance whose `_end_turn()` is still
running. Control returns to `_end_turn()`, which keeps going regardless and
reaches `_cam.look_at()` on a camera that just left the tree. **Not a race
in the sense of "sometimes wrong, sometimes right"** — it is 100%
deterministic given the game state at that exact End Turn; what LOOKS like a
race across identical-seed runs is that this sandbox's slow software
renderer can shift how a turn's timed minigames grade (PERFECT/GOOD/MISS),
which changes damage, which changes exactly which End Turn ends the fight.
The playtester's own read of the SHAPE was right; this is the trigger.

**Not a fresh bug class** — `location_3d.gd`'s own `_refresh()` already
documents this precise router race in detail (backlog #7, commit
`0934ea9915b2`) and guards itself with `is_inside_tree()`; combat_3d.gd's
own `_refresh()` independently dodges the same race by bailing the moment
`phase` isn't "combat" any more (both existed before this run). Neither
guard covers `_focus_camera()`, which `_end_turn()`/`_switch_to()` reach
directly and unconditionally with only a `_cam == null` check — true for
"never had a camera," never for "my camera's node just left the tree."

**Fix.** One line: `_focus_camera()`'s existing guard
(`combat_3d.gd`) now also checks `not is_inside_tree()`, the same idiom
`location_3d.gd` already uses for the identical race. `_apply_solo_turn_flip`
flips `_active_slot` BEFORE calling `_focus_camera()`, so this doesn't touch
the ordinary end-of-turn hand-off at all — confirmed the existing sibling
test (`..._still_flips_with_no_timing_window_open`) still passes unchanged.
`_apply_orbit()`'s other call sites are all `_process`/input-driven and
never fire on a detached node (Godot stops calling those once removed), so
this one guard closes the only reachable path.

**Proof.** A bare `Combat3D.new()` (the existing sibling flip tests' own
trick) never resolves the `%Camera` onready var, so `_cam` stays null and
would mask this bug rather than catch it — instantiated the real
`combat_3d.tscn` into the test runner's own tree instead, called
`remove_child` on it (the exact call `game_3d.gd` makes), then called
`_focus_camera()` directly. Temporarily reverted just the new
`or not is_inside_tree()` clause and reran: failed exactly as predicted,
printing the SAME engine error the request's log shows verbatim —
`ERROR: Node not inside tree. Use look_at_from_position() instead. at: look_at
(scene/3d/node_3d.cpp:1253)` — from `_apply_orbit` via `_focus_camera`, with
the camera's own position mutated even though the view had already left the
tree. Restored the fix, reran: passes, camera left untouched. A sibling test
proves the guard doesn't swallow the ordinary case (a view still in the tree
still moves its own camera). Two new tests in `run_tests.gd`; `ALL TESTS
PASSED`.

**Live verification, since finished.** The `mode=play beast=cinder_jackal
steps=80` run that was still rendering when the above was written completed
clean against the fixed tree: full 80 steps (0-79, no truncation — the
crash's own tell), End Turn exercised 11 times with real HP/energy/foothold
swings, zero `script-error`. `PLAYTEST FAIL: 1 failing check(s) {
"hunter-off-marker": 3 }` — the already-open, unrelated
shared-foothold-4-spacing request, not a new issue. The fight didn't
conclude in 80 steps, so this run didn't land on the exact "End Turn ends
combat" trigger state (expected — that's a specific game state, not
something a rerun can force); the unit-test reproduction against the real
engine error remains the authoritative proof, this is a clean regression
check on top of it.

Commit: pushed as part of this run (see `## Log` below for the hash).

## Old: 2026-09-23, hunter-damage-popup-offscreen

Open `to: fixer` request `2026-09-23-0430-playtester-to-fixer-hunter-damage-popup-offscreen.md`
(oldest open `to: fixer` request this run — took it over the newer
shared-foothold-spacing request I filed to myself last run, per order-of-work
"oldest first"). Root cause was NOT the playtester's own guess (a camera
mid-climb-transition not caught up) — reproduced live
(`mode=play beast=cinder_jackal steps=36`, temp debug print in `_react`/
`_damage_popup`, never committed) and it's `_damage_popup` itself: its rise
tween and `popup_offset`'s minimum-separation both scale off `reach =
_beast_box.size.y` (the BEAST's own height, ~20 units on the Cinder Jackal)
regardless of whether the hit landed on the beast or on a hunter. That's
correct for a beast hit (the glyph has to travel far enough to read against
a Titan) and wildly oversized for a hunter — `HUNTER_HEIGHT` is 0.7, so a
beast-scale rise (~4.4 units) carries a hunter's own popup six-plus
hunter-heights into the air, and beast-scale popup spacing (~10 units, when
two hunters are hit the same frame) flings the second one most of the
beast's own width sideways. Both send the number well outside a frame
still centred on the (stationary) hunter — live numbers matched the
playtester's exactly (label rose from screen y=301 to y=-217, ~600px above
the top edge, within under a second).

**Fix**: new static `Combat3D.popup_move_reach(beast_reach, on_hunter)` —
beast hits keep the beast-scale reach; `on_hunter` gets `HUNTER_HEIGHT *
3.0` (2.1 units) instead. Both the rise tween and the `popup_offset` call
in `_damage_popup` now read this instead of the raw beast reach; glyph
*size* (`pixel_size`) untouched, since that already read fine — this was
purely the popup's own travel distance, not its scale.

**Proof**: 3 new unit tests in `run_tests.gd` using the exact numbers from
the live repro (rise 4.4→0.46 world units, lateral fling 7.88→under 4.0),
`ALL TESTS PASSED`. Visual: a clean synthetic repro
(`screenshot.gd state=3dstrike`, firing `_damage_popup` at hunter 1's real
node position — the same formula `_react` uses) before/after the fix,
same camera, same wait — before, the "11" lands top-right of frame,
disconnected from the Goblin Engineer; after, it lands right at the point
of impact:

![[frames/fixer/2026-09-23-hunter-damage-popup-before-fix.png]]
![[frames/fixer/2026-09-23-hunter-damage-popup-after-fix.png]]

**Environment was flaky this run** — two full `mode=play steps=36`
playtest renders stalled for 10+ minutes each (Godot burning CPU but
barely advancing a step) and had to be killed; a bare `screenshot.gd`
render took its normal ~5-6s once the stuck processes were gone, so the
before/after proof above is the targeted `state=3dstrike` repro rather
than a fresh full end-to-end playtest pass. The unit tests carry the real
numbers from the one `mode=play` run that DID complete cleanly (the
original reproduction, before any fix), so the fix is proven against the
actual reported bug either way. Didn't chase why the environment slowed
down; if it recurs for the next agent, killing the stuck Godot process and
retrying seemed to fully clear it (confirmed: a plain screenshot went from
apparently hung to ~5s once the old process was gone).

Commit: pushed as part of this run (see `## Log` below for the hash).

## Old: 2026-09-23, hunter-floats-off-model-at-foothold-4

**Reproduced first.** Added a temporary debug print in `_stand_on_model`
(never committed) and ran `mode=play beast=cinder_jackal steps=40/80` under
`xvfb-run`. Confirmed the playtester's own read exactly:
`_front_of_beast(3.901, 13.826)` — the (x, y) of foothold 4's own anchor —
returned **13.164**, nowhere near the anchor's own authored z of **6.473**.
Dumped `hull_front_at`'s 5-row×3-col neighbourhood directly: the "best"
(max) cell it found was two full hull bands *above* foothold 4's own row,
in an otherwise-empty row (every neighbour but that one cell was `-1e9`) —
a single, disconnected point that isn't the torso/neck surface near the
anchor at all. Rendered the region: it's the jackal's own right **ear**.
The neighbourhood search (deliberately widened past a plain 3×3 to avoid a
*different* known failure — a muzzle in the next column reading as empty,
see the function's own doc comment) reached far enough to grab an unrelated
thin feature and used it as "the front of the body," overriding a correct
anchor.

**Root cause, not the symptom.** The anchor was never wrong — `beast.py`'s
own export (`_decorate`, `tools/blender/beast.py`) already raycasts every
`climb_<h>` anchor out to the real mesh, clearance included
(`push = (reach + hs * 0.80) - here`). The bug was `_stand_on_model`
re-deriving that same answer from a noisy runtime hull and letting the
worse answer win via `maxf(anchor.z, hull_clear)` — on EVERY exact rung,
not just this one; foothold 4 is just where the geometry (a beast whose
climb path runs right past its own ears) made the neighbourhood's blind
spot bite.

**Fix.** New static `Combat3D.stand_z_for(anchors, foot, anchor_z,
hull_clear)`: trusts `anchor_z` outright when `foot` is an exact key in the
model's own climb anchors; only falls back to `maxf(anchor_z, hull_clear)`
for a foothold BETWEEN two rungs, where `foothold_anchor` lerps a straight
line across the body's curve and there's no baked, raycast-true anchor to
trust — the one case that still needs the hull. `_stand_on_model` now skips
the hull query entirely on an exact rung. Noted but did not touch a
separate, now-moot latent bug found while reading the surrounding code:
`_build_float_stones()` runs before `_build_hull()` in the beast-load
sequence, contradicting its own doc comment — harmless after this fix since
both `_build_float_stones` and `_build_ledge_marks` always call
`_stand_on_model` with an exact anchor height, so neither ever touches the
hull anymore.

**Proof.** Three new unit tests (`run_tests.gd`): the repro itself
(anchor wins even past a hull read more than double it — the live 6.47 vs
13.16 numbers, reproduced with round inputs), plus two guards that the
off-anchor/lerped path is byte-for-byte unchanged in both directions.
Reproduced on the unfixed formula first (temp-reverted just
`stand_z_for`'s body to the old always-`maxf`), confirmed the repro test
fails exactly as predicted; restored the fix, `ALL TESTS PASSED`.

**Live playtest, before/after** (same seed, `mode=play beast=cinder_jackal
steps=80`). Before: `home (5.230187, 13.825942, 10.253428)`, a 3.78
world-unit z-gap from the anchor, hanging over the arena wall with nothing
under it — the playtester's own frames. After: `home (5.335257, 13.825942,
7.030925)`, z-gap down to 0.56 world units — the wild float is gone:

![[frames/fixer/2026-09-23-hunter-foothold4-fixed-step037.png]]

**Not fully closed — split out on purpose.** `hunter-off-marker` (check 8)
still fails narrowly (x-tolerance) at the exact moment BOTH hunters share
foothold 4 (`side=±1`, confirmed live with a second temp debug print,
`other_foot=[4, 4]`). `stand_offset_x`'s spacing (scaled to the whole
beast's bounding-box width) pushes the side-shifted hunter clear of the
narrow ear at that spot, and `_build_float_stones` only ever builds one
CENTRED stone per height — the side-shifted hunter has nothing to land on
regardless of z:

![[frames/fixer/2026-09-23-hunter-foothold4-shared-side-gap-step037-crop.png]]

A genuinely different mechanism from the ear/hull bug above, much smaller
in magnitude (about one hunter-width of gap, not several world units over
a blank wall). Filed rather than folded in:
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`.
Both temporary debug prints were removed before committing — `git diff`
confirmed clean (fix + tests only) before every push.

Also surfaced, not chased: two pre-existing `hop-no-squash` / `hop-flat`
failures in the same 80-step run (steps 30, 42, 52, 53), all with 6-7
in-flight samples — matches the playtester's own documented sparse-sampling
flake signature for short single-leg hops on this sandbox's slow renderer
(their status note, `## Old: 2026-09-22, hop slow-mo + correction`), not
anything this fix touches. Left alone, noted in the request's `## Result`
so nobody re-diagnoses them as new.

## Old: 2026-09-23, Meld slider swallows multi-hit windows

Fresh sandbox. No open `to: fixer` request (the boss-relic-pool request is
still sitting on `to: nick`, untouched — his call, not mine). Order-of-work
item 1-2: ran `run_tests.gd` (`ALL TESTS PASSED`) then a full fresh
`mode=play beast=cinder_jackal steps=80` — clean, no failing checks through
the whole run. Fell to item 3 (bugs in the jackal fight's own code paths,
found by reading): dispatched an Explore agent scoped strictly to
`combat_3d.gd`/`card_view.gd`/`hit_circle.gd`/`core/combat.gd`'s Frog/Goblin
Engineer card fields, told exactly which functions the last several runs'
logs already call settled (`hop_arc`, `hunter_side_offset`, `gauge_dot_dx`,
`foothold_anchor`, `stand_offset_x`, `climb_frame_for`, `popup_offset`,
`pattern_shove`, `height_gap_between`, `react_plan`, `_markup`/`_word_index`/
`_kw`, `fire_quality`/`_fire`/`_end_timing`/`zone_bonus_t`, and `note_hit` —
last run's own fix) so it wouldn't re-surface one of those.

**What it found, confirmed myself before touching anything.**
`HitCircle.begin()` (`ui/hit_circle.gd:139-151`) sets `_hits_needed = 1 if
_slider else points.size()` — whether a card is a "slider" (one held note)
or a tap chain was decided in `combat_3d.gd`'s `_on_card_tapped` purely by
`card_climb_for(card) >= SLIDER_CLIMB` (printed `grip >= 2`), with no regard
at all for the card's own `timed_hits`. No single shipped card carries both
a slider-eligible climb and more than one real timing window — but **Meld**,
the Goblin Engineer's own signature starter card, reaches it for real:
`_meld_cards` (`core/combat.gd:388,399`) sums `grip` and takes
`maxi(timed_hits)` independently, so melding **Winch** (`grip:2`, built via
Build Winch) with **Satchel Charge** (`timed_hits:3`, in the Goblin
Engineer's own starter deck ×2) — confirmed both are in the Goblin
Engineer's card pool via `data/characters.json` — produces `grip:2,
timed_hits:3`. On the HitCircle face that resolved as ONE 0.85s hold with
`SLIDE_RESCUE` forgiveness instead of three separately-graded windows — a
real difficulty cut on a real, reachable card, and disagreeing with the
sweep-bar `CardView` face's own `start_timing(hits)`, which already demands
all `hits` windows for the identical melded card with no slider concept at
all. Two faces of one rule silently disagreeing on what the rule was — same
shape as several prior `#86` finds, just never closed in this exact spot.

**Fix.** Extracted `Combat3D.card_is_slider(card, hits) -> bool` —
`card_climb_for(card) >= SLIDER_CLIMB and hits <= 1` — and pointed
`_on_card_tapped`'s `_circle.begin(...)` call at it instead of the old
inline `climb >= SLIDER_CLIMB`. Every currently-shipped slider card has
`timed_hits` implicitly 1, so this is a no-op for all of them; it only
changes behavior for a melded card that combines a slider climb with a real
multi-window chain, which now correctly falls back to the tap chain both
faces then agree on.

**Reproduced first.** Temporarily reverted just the new function's body to
the old formula (`return card_climb_for(card) >= SLIDER_CLIMB`, ignoring
`hits`), kept the call site and the four new tests: the melded-shape test
failed exactly as predicted (`{grip:2}, hits=3` → `card_is_slider` true when
it must be false). Restored the fix, reran: `ALL TESTS PASSED`.

**Proof.** Four new tests covering the full 2×2 truth table: a plain climb
card (grip 2, hits 1, every shipped slider today) stays a slider; a plain
attack card (grip 0) is never a slider; the melded shape (grip 2, hits 3)
now correctly falls back to a tap chain — the repro above; a high-`hits`
card with no climb (Satchel Charge alone, grip 0, hits 3) was already
correct and stays a tap chain, guarded against a regression in the other
direction. No live frame: reaching this exact card needs Build Winch held
alongside Satchel Charge, then Meld — no dev-harness switch forces a
synthetic melded id into a hand (`Dev.hand`/`hand=` only resolve real
`data/cards.json` ids via `Content.make_card`; a meld's id is built at
runtime, not data-driven) and the deterministic `playtest.gd` script never
happens to build Winch and meld it with Satchel Charge in its fixed
sequence — proof here is the before/after unit test, the same convention
every other pure timing-minigame rule in this file already uses
(`card_climb_for`, `fire_quality`, `zone_bonus_t`, none of which have a live
frame either).

Re-ran a fresh full `mode=play beast=cinder_jackal steps=80` against the
fixed tree as a general-regression sanity check — clean throughout, no
errors, no behavior change on any of the real card plays along the way
(none of them melded Winch+Satchel Charge, so this run couldn't have
exercised the fixed branch specifically, only confirmed nothing else broke).
`hover`/`hands` were started too but killed early to free the sandbox's 4
cores for `play` alone under 3-way contention that was making all three
crawl; nothing in this change touches hover/flicker timing or hand-size
layout, so the risk from not completing their run this time is low.

Self-filed and self-fixed —
`requests/2026-09-23-0700-fixer-to-fixer-meld-slider-swallows-multi-hit-windows.md`.

## Old: 2026-09-23, note_hit double-report on a dropped slider

Fresh sandbox. No open `to: fixer` request (the boss-relic-pool request is
still sitting on `to: nick`, untouched — his call, not mine). Order-of-work
item 2: ran a full fresh `mode=play beast=cinder_jackal steps=80`,
`mode=hover`, and `mode=hands` — all three `PLAYTEST OK: 0 failing check(s)`,
clean baseline, nothing to file. Fell to item 3 (bugs in the jackal fight's
own code paths, found by reading) and read `ui/hit_circle.gd` — the file's
own status-note history shows the last several duty-3 passes hammered
`combat_3d.gd`'s climb/hop/gauge functions repeatedly; `hit_circle.gd` had a
thorough thirty-second-pass audit for its TAP grading and its SLIDER
press/hold/release rules, but every one of those tests only ever listens for
`resolved()` (fires once per WINDOW) — none of them connect `note_hit`
(fires once per NOTE) for the slider path specifically.

**What I found.** `note_hit`'s own doc comment: "`index` is 0-based, `quality`
grades that note alone" — one verdict per note. A slider window has exactly
one note (`_hits_needed = 1`, `_hits_done` never leaves `0`). `_fire()`'s
slider branch already emits `note_hit(0, press_quality)` the instant a good
press lands. But `_finish()`'s MISS branch **unconditionally** also emitted
`note_hit(_hits_done, TIMING_MISS)` — so a slider pressed perfectly and then
dropped before `SLIDE_RESCUE` reports index 0 as `PERFECT`, then immediately
reports the *same* index 0 as `MISS`. Not yet visible to a player —
`combat_3d.gd` only ever connects `resolved`, never `note_hit` — but the
signal exists precisely so a future per-note UI reaction (the doc comment
names "the camera-follow judgement pop") can be wired off it, and this bug
would corrupt that reaction the day it's connected.

**Reproduced first.** Wrote the repro as a unit test, ran it against the
unfixed tree (`git stash` on just `hit_circle.gd`, keeping the new test):
failed exactly as predicted, `got [[0, 2], [0, 0]]` (PERFECT then MISS for
index 0).

**Fix.** Added `_slider_note_hit`, set `true` right after the slider press's
own `note_hit.emit(0, _worst)`, reset `false` in `begin()`. `_finish()`'s MISS
branch now skips the `note_hit.emit(...)` call when `_slider and
_slider_note_hit` — the note already reported its real verdict at press time.
The **visual** MISS burst is untouched and still plays on a dropped slider (a
player who blew the hold still needs to see why); only the signal
double-report was the bug.

**Proof.** Two new tests: the repro above, plus a sibling proving the guard
doesn't silence the legitimate single MISS report when the press itself
misses the window (never enters holding, so `_finish()` is the only place
that note is ever reported). Both pass on the fixed tree; restored the
stashed fix and reran the full suite: `ALL TESTS PASSED`. Re-ran `mode=hands`
post-fix as a sanity check (pure logic fix, nothing rendered changes):
`PLAYTEST OK: 0 failing check(s)`, same known harness-only leak-at-exit noise
as every prior clean run. No frame to attach — this bug never reached a
pixel; the before/after test output is the evidence.

Self-filed and self-fixed —
`requests/2026-09-23-0300-fixer-to-fixer-note-hit-double-reports-on-dropped-slider.md`.

## Old: 2026-09-23, duty 3 — reward header lied "Tap a relic" with an empty row

Fresh sandbox. No open `to: fixer` request (the boss-relic-pool request from
a prior run is still sitting on `to: nick`, untouched). Order-of-work item 2:
ran a full fresh `mode=play beast=cinder_jackal steps=80`, `mode=hover`, and
`mode=hands` — all three `PLAYTEST OK: 0 failing check(s)` / 0 fails, clean.
Item 3/4: rather than re-reading the same already-scarred `combat_3d.gd`
functions by hand again, dispatched an Explore agent to hunt for a genuinely
untested mechanic for this run's `#86` rotation slot, telling it what the
~30 prior duty-3 log entries already cover so it wouldn't re-suggest one.
Rotation state per `BACKLOG.md`: last commit was duty 2 (`09438cd`, the
sealed-door history fix), so this run owed duty 3 ("verify a mechanic
actually works").

**What it found.** `Location3D.reward_header_text()` (`location_3d.gd:526`)
— already a pure static function, 8 existing tests, but none of them (and no
parameter on the function at all) covered "the reward row has zero choices
in it". That state is real, not hypothetical: my own prior-run request
(`2026-09-22-2245-fixer-to-nick-boss-relic-pool-runs-dry-at-half-the-titans.md`,
still open, Nick's call) already proved 2-player co-op empties the shared
4-relic boss pool by the 3rd Titan. With the pool empty, `picked` false and
`has_selection` false, the function unconditionally returned "Tap a relic to
select" — with nothing on screen to tap and "Lock In Reward" permanently
disabled. That request already flagged this half as "definitely a bug
regardless" of the pool-sizing question; this run is where it got fixed.

**Fix.** Added a `has_choices: bool` parameter. When false (and neither
picked nor mid-selection), the prompt now reads "Nothing left to take — Skip
to continue" — the same "say why the option is gone" pattern the campfire's
"Sharpen — nothing left to sharpen" button already uses. `_render_reward()`
passes `not reward.get("choices", []).is_empty()`.

**Proof.** Updated all 11 existing `reward_header_text` call sites in
`run_tests.gd` to `has_choices=true` (none were testing the empty case).
Added three new tests: the empty-row message text itself; a regression
guard that the word "tap" never appears with zero choices (the literal
string the bug produced — `"Tap a relic to select"` on an empty row); and
that "locked in" still wins over the empty-row message for a player who
already picked (branch-order guard, since the `elif` chain checks `picked`
first). Proved all three against the unfixed behaviour first — temporarily
reverted just the new `elif` branch (kept the new signature so the calls
still matched) and reran: all three failed exactly as predicted. Restored
the fix, reran: `ALL TESTS PASSED`.

**Visual proof.** Rendered `state=3dreward` (`beast=cinder_jackal`) with
both hunters' `reward_choices` forced empty (matches the real drought
state): row empty, "Lock In Reward" correctly disabled, prompt now honest,
"Skip — keep the deck lean" visible and unambiguous.

![[frames/fixer/2026-09-23-reward-empty-choices-prompt.png]]

Re-ran the full `mode=play beast=cinder_jackal steps=80` / `mode=hover` /
`mode=hands` baseline after the fix: all three still `PLAYTEST OK: 0 failing
check(s)` — no regression from the change. Added a `## Result` to the
standing `to: nick` request noting item (2) — the prompt text — is now
fixed, and item (1) — whether the pool itself should be resized for 2-player
co-op — is still his call, untouched.

Full write-up in `design/plan/BACKLOG.md`'s `## Log` (2026-09-23 entry). Next
`#86` turn is duty 2.

## Old: 2026-09-23, duty 2 — sealed-door ending recorded as a win in history

Fresh sandbox. No open `to: fixer` request (the boss-relic-pool request from
a prior run is still sitting on `to: nick`, untouched, and unlike the rest of
this note that one is still someone else's call to make). Order-of-work item
2: ran a full fresh `mode=play beast=cinder_jackal steps=80` (the whole 80
steps; the earlier `run_in_background` mistake from two runs ago did NOT
recur this time — used it correctly from the start), `mode=hover`, and
`mode=hands` — all three `PLAYTEST OK: 0 failing check(s)`, matching
yesterday's clean baseline (the hop_arc fix from two runs ago is holding:
step 17's climb still peaks at 19.56). Item 3: read `hop_arc`,
`hunter_side_offset`, `gauge_dot_dx`, `foothold_anchor`, `stand_offset_x`,
`climb_frame_for`, `popup_offset`, `pattern_shove`, `height_gap_between`,
`react_plan`, and card_view.gd's `_markup`/`_word_index`/`_kw` keyword
markup — nothing new; every one of these already carries an earlier `#86`
fix's scar tissue and reads correct.

Fell through to item 4 (backlog #86 duty — the only one of the four that
isn't scoped to the Cinder Jackal fight, "hunt a bug anywhere"). Rotation
state per `BACKLOG.md`'s own log: last turn was duty 3 (`21734f1`), so this
one owed duty 2 ("find an error and resolve it"). Dispatched an Explore
agent over the files the last several `#86` entries call already "fully
spent" for `game/views`/`game/ui`/`game/session` — pointed it at
`game/core/run.gd`, `run_save.gd`, `run_map.gd`, `progress.gd`, `boss.gd`,
`character.gd`, `card.gd`, `location_3d.gd`, `deck_view.gd`, `console.gd`,
`net/*`, cross-referenced against every existing `_test_backlog86_*` name so
it wouldn't re-find something already fixed. It came back with a real "two
copies of one truth" bug: `game_host.gd`'s `_note_progress()` correctly
gates `Progress.record_win()` on `phase == WON and true_ending` (an earlier
duty-2 fix, because the sealed-door ending — reaching the fourth Titan
without all three keys, backlog #64 — sets `phase = WON` with no fight ever
happening), but the very next line, unconditional
`Progress.record_run(_run.history_entry())`, still built its own `result`
field off the bare `phase == WON` test the sibling fix had already rejected.
A walked-away sealed-door run correctly left the career win counter alone
but still landed in the player's permanent run history reading
`"result": "win"`.

**Reproduced first.** Extended the existing
`_test_backlog86_sealed_door_ending_does_not_bank_a_win` test to also read
`Progress.run_history()` after the sealed-door `_broadcast_state()` call;
ran it against the unfixed tree and it failed exactly as predicted —
`got result=win`.

**Fix.** `Run.history_entry()` (`game/core/run.gd`) now matches
`_note_progress()`'s own condition — `phase == Phase.WON and
stats.get("true_ending", false)` — before setting `result = "win"`. A
sealed-door WON now falls through to the function's existing `""` default,
the same sentinel it already used for "neither WON nor LOST," so this is
the honest state, not a new one.

**Proof.** Reran the extended test on the fixed code: passes, `result=""`.
Full suite (including both pre-existing `history_entry` shape tests for a
real win and a real loss, and every `run_history`/`record_run` test)
unaffected — a real win always has `true_ending` true by the time
`_after_node()` reaches `WON`. `$GODOT --headless --path game --script
res://tools/run_tests.gd` → `ALL TESTS PASSED`. Re-ran `mode=hands` under
`xvfb-run` post-fix as a sanity check (this is a pure logic fix, nothing
rendered changes) — `PLAYTEST OK: 0 failing check(s)`. No frame to attach —
this bug never touched a pixel, only a persisted `ConfigFile` value; the
before/after numeric proof above is the evidence, same convention the
hop-arc trajectory fix used two runs ago.

Full write-up in `design/plan/BACKLOG.md`'s `## Log` (2026-09-23 entry, now
superseded as the newest by this run's duty-3 entry). Next `#86` turn was
duty 3 (done above); the one after that is duty 2.

## Old: 2026-09-22, clean-bill-of-health run

No open `to: fixer` request this run (fresh sandbox; the boss-relic-pool
request from my own prior run is still sitting on `to: nick`, untouched).
Order-of-work item 2 (a playtest failure nobody has filed) and item 3
(bugs found by reading) both came back empty after a genuinely thorough
pass — writing that up honestly rather than manufacturing a fix, per the
brief's own "reproduce it first, or say you can't."

**What I ran.** A full live `mode=play beast=cinder_jackal steps=80` (the
whole 80 steps, fight never quite finished — Goblin Engineer down to 6 HP
at the end), `mode=hands` (every hand size 1-10) and `mode=hover` (the
flicker sweep). All three: `PLAYTEST OK: 0 failing check(s)`. The play
run alone exercised nearly the whole Frog/Goblin Engineer kit for real,
including the two hardest-to-reach paths: Meld (fused `Catapult + Burn
Coal`, played it, resolved cleanly through the two-pick exhaust_cheapen
flow) and Satchel Charge's 3-hit timed chain. Also hit Goblin Jetpack
(fired correctly at the next round start), Leapfrog, Grappling Arm/Hook,
Build Mech, Brace's 3rd-card condition, and a real fall (a boss hit
knocked the Goblin from foothold 10 back to 4, HP 20→14 — landed cleanly
on an intermediate ledge, both hunters still visibly separated, checked
against `step_071.png`). Frame-by-frame look (not just the automated
checks) at several of these — sigil pair-up, the fall/ledge landing, the
low-HP endgame — found nothing wrong: no overlap, no clipped text, no
missing glyphs, hunters always where the HUD says they are.

**What I read.** `core/combat.gd`'s `preview()`/`play_card()` against
every field the Frog and Goblin Engineer starter+reward cards actually
use (`timed_hits`, `pull_ally`, `sac_ally_grip`, `block_per_play`,
`prepare`/`_resolve_prepared`, `meld`/`_meld_cards`, `condition`/
`condition_bonus`), `combat_3d.gd`'s hand-tap/timing/selection flow
(`_on_card_tapped`, `_hold_points`, `selection_mode_for`), and
`card_view.gd`'s live face-text and tap-to-inspect keyword list. All of
it carries `backlog #86 duty 2` scars already — this system has had a
lot of real, careful attention from earlier runs, and it showed: I could
not find a gap that wasn't already closed.

**Two things I chased that turned out NOT to be bugs**, written down so
nobody re-chases them:
- Satchel Charge (`damage: 6`) showing "**Deal 1 damage.**" in a forced
  `hand=satchel_charge` screenshot (`state=3d`, foothold 0). Looked like
  a live bug at first glance. It isn't: `combat.gd:706-710`, the armored-
  hide mechanic — below the weak point, `swing = max(1, dmg /
  ARMORED_DIVISOR)` (`ARMORED_DIVISOR = 4`), so `6/4 = 1`. Correct,
  intended, by design.
- `mode=hands` prints `WARNING: 4 ObjectDB instances were leaked at
  exit` / `ERROR: 2 resources still in use at exit` (an `AudioStreamOggVorbis`
  + its playback, from `combat.ogg` via the static `Music._player`).
  `mode=play` (80 real steps, ~40 min) and `mode=hover` (also long) never
  show it; only the fast-exiting `mode=hands` does. Nothing in the
  shipped game ever calls `SceneTree.quit()` — a real player's process
  just dies, no warning printed to anyone. This is `quit()`-timing noise
  specific to the headless test tool calling `quit()` while
  `Music`'s looping stream is still mid-flight, not a Cinder-Jackal-fight
  bug. Leaving it alone; flagging here in case a future run sees the same
  warning and wonders.

Nothing fixed, nothing pushed to `game/`. Ran
`$GODOT --headless --path game --script res://tools/run_tests.gd` first
and last to confirm the tree was green throughout (`ALL TESTS PASSED`,
unchanged since no code moved).

![[frames/fixer/2026-09-22-clean-audit-meld-catapult-burncoal-sigil.png]]
![[frames/fixer/2026-09-22-clean-audit-fall-onto-ledge.png]]

## Old: 2026-09-22, earlier in the day

No open `to: fixer` request this run (fresh sandbox). Widened the "states
around the fight" look (per my own prior run's "Next" note) to the
campfire/shop/event screens (`location_3d.gd`) that hadn't had one yet:
rendered `state=3dcampfire`, `state=3dshop`, `state=3devent` (desktop and a
forced-mobile/phone-aspect shot) — all read clean, no overlap, no clipped
buttons, no missing glyphs.

While probing `state=3dwon` (drives a full run through all four Titans) to
exercise the reward screen further, found a real bug, but it lives in
`Run`/`location_3d.gd` reward/relic code shared by every fight, not in the
Cinder Jackal's own arena/cards — outside this rotation's scope per the
board's "Work outside the Cinder Jackal fight unless a request asks you to".
Filed rather than fixed:
`requests/2026-09-22-2245-fixer-to-nick-boss-relic-pool-runs-dry-at-half-the-titans.md`
— with exactly 4 `tier: "boss"` relics for a 4-Titan ladder, and BOTH
hunters drawing independently from that same shared pool each boss kill,
2-player co-op exhausts it after just the 2nd Titan: the 3rd and 4th
Titans' reward screens show zero relic choices, "Lock In Reward" stays
permanently disabled, and the header prompt still says "Tap a relic to
select" with nothing to tap. Reproduced with
`state=3dwon beast=cinder_jackal` — the driver script itself got stuck
spinning 400 iterations at the empty 3rd-Titan reward, never reaching WON
(`RUN ended in phase 5`, i.e. still REWARD). Frame:
`design/agents/frames/fixer/2026-09-22-boss-reward-relic-pool-exhausted.png`.
Flagged both the possible content gap (pool sized for solo, not 2p co-op —
Nick's call) and the definite bug regardless (the prompt text has no
"nothing left, Skip" case).

Then ran the play/hover/hands baseline fresh against the tip (order-of-work
item 2 — a failure the current playtest shows nobody has filed). `mode=play
beast=cinder_jackal steps=80` failed twice: `hop-flat` at steps 1 and 17,
"hop peak y=18.13 never rose above its endpoints (8.99 -> 18.17/18.18) --
reads as a slide, not a jump". Both were big single-leg climbs (Leap/Hop,
no intermediate ledge to split the hop) spanning several hunter-heights of
pure world-Y in one tween. Root cause: `Combat3D.hop_arc()` built the
apex's height as `lerp(from, to, 0.58).y + hop`, where `hop` is
deliberately clamped small (≤2.5 hunter heights) so a long haul doesn't
arc absurdly high — fine for a short hop, but for a climb whose own
vertical span already dwarfs that cap, the uncovered 42% of the span left
the apex BELOW the landing height. Reproduced headless with
`hop_arc(Vector3(0,8.99,0), Vector3(0.3,18.17,-0.4), 0.34)`: apex.y was
15.97 (below to.y=18.17). Fixed by taking the apex's height from
`maxf(from.y, to.y) + hop` instead of the lerp (x/z still lean toward the
landing as before) — apex.y is now 19.82, clearing both endpoints. Two new
`hop_arc` tests in `run_tests.gd` (the exact live numbers, plus the general
"apex always clears the higher endpoint" invariant — every prior `hop_arc`
test only ever moved flat, which is exactly why this slipped through).
`ALL TESTS PASSED`. Re-ran the identical `mode=play` repro on the fixed
code: `PLAYTEST OK: 0 failing check(s) {  }`, step 17's climb (same
8.99→~18.1 span) now peaks at 19.56. Self-filed and self-fixed —
`requests/2026-09-22-2300-fixer-to-fixer-hop-arc-reads-as-slide-on-tall-climb.md`,
commit `25804f3`.

Lost some time mid-run to my own harness mistake, worth remembering: I
backgrounded a playtest render with a bare shell `&` instead of the Bash
tool's `run_in_background`, which got reaped the moment that tool call
returned; retried without noticing and ended up with three overlapping
`playtest.gd` processes fighting over the same 4 cores and the same output
directory, which is why the first couple of attempts looked like they died
silently. Always use `run_in_background: true`, never a bare `&`, for
anything meant to outlive the current tool call.

## Next

Items 1-2 (open requests, live playtest failures) are clean this run, same
as the last several. Item 3 found a real gap this time: two faces of the
timing minigame (HitCircle's osu circles vs CardView's sweep bar) disagreed
on how many windows a melded slider+multi-hit card needs — only reachable
via the Goblin Engineer's own Meld + Winch + Satchel Charge, so a live frame
would need scripting that exact build-then-meld sequence rather than the
deterministic playtest's fixed script; proved it headless instead, same as
every other pure timing-minigame rule already is. Worth someone eventually
checking whether OTHER Meld combinations produce a similarly-disagreeing
pair of derived fields (this run only chased the slider/hits pair) — didn't
audit `_meld_cards`'s other ~20 summed/maxed fields against how each one is
actually consumed downstream. `hover`/`hands` baseline wasn't completed this
run (killed early for CPU headroom, see `## Now`) — worth a full three-mode
run next time nothing else takes priority, though nothing in this fix
touches either.

## Old: 2026-09-23, note_hit double-report on a dropped slider

Items 1-2 (open requests, live playtest failures) were clean that run, same
as several before. Item 3 found a real gap: `hit_circle.gd` had
heavy prior test coverage, but every existing test only ever listened for
`resolved()` (fires once per window) — none connected `note_hit` (fires once
per note) for the slider path, which is exactly where the double-report bug
was hiding. Worth remembering: a thoroughly-tested FILE can still have an
untested SIGNAL CONTRACT if every test only exercises one of the signals it
fires. Worth someone eventually checking `card_view.gd`'s
`timing_resolved`/inspector signals the same way — I didn't chase this
beyond `hit_circle.gd` itself this run. What's still outstanding: (1) the
boss-relic-pool REQUEST is still waiting on Nick for the sizing/cadence
question, prompt-text half already fixed. (2) the "pure shape function
tested on only one axis" question stands unresolved for
`combat_3d.gd`/`card_view.gd` specifically — every function I've personally
read there is clean, but nobody has audited ALL of them. (3) the `mode=hands`
ObjectDB/AudioStreamOggVorbis leak-at-exit noise is still just noise, still
untouched, still low priority. (4) Backlog #86 itself isn't Cinder-Jackal-
scoped and clearly still has real bugs/gaps in it — the general
`game/core`/`game/session`/`game/views` layer outside the jackal fight's own
hand/climb/camera code keeps paying off faster than re-reading the same
already-scarred `combat_3d.gd` functions, so keep pointing the Explore-agent
hunt there first when it's that duty's turn. Next `#86` rotation turn (last
commit before mine was duty 3) is duty 2 ("find an error and resolve it") —
this run's own item-3 find took priority over dropping to the backlog
rotation, per the brief's own order of work. (5) Worth someone eventually
checking whether other reward-adjacent screens (event/treasure rolls, not
just boss relics) can also produce an empty choice row — didn't chase this
further either.

## Log

- 2026-09-24 22:40 EDT — #18's camera-switch request (2026-09-24-2155), two
  passes: built the Menu's Camera Dev/Player toggle, then Nick answered live
  wanting it locked by default in EVERY build (his own is always debug) —
  flipped `Progress.dev_camera_enabled()` to default `false` unconditionally.
  `free_camera_allowed` still ANDs `is_debug_build` separately. Fixed
  `state=3dfreecam` to force Dev before its own drag tests. `ALL TESTS
  PASSED`. Left `to: fixer`, `status: taken` — the Risk of Rain framing
  itself (not just the lock) is still open, next run.
- 2026-09-24 17:43 EDT (latest) — #11 composition (hunters far back, whole
  beast in frame): fixed the camera half. `_focus_camera` no longer cuts to
  a tight over-the-shoulder lock while everyone is grounded (new
  `anyone_off_ground` guard) -- the wide, beast-scaled ground shot
  `climb_frame_for` already computed just gets to run instead of being
  overridden. Climbing camera untouched. `ALL TESTS PASSED`, before/after
  frames attached. Full 80-step playtest came back clean: only the
  pre-existing `hop-distance-band` (#4) fails, zero camera regressions.
  Handed to Nick (`to: nick`) for the visual sign-off his own "Done when"
  bullet asks for. Stone path geometry (#4) not touched, out of scope.
- 2026-09-24 14:42 EDT — intent-tag-still-grazes-hunter-at-hop-start:
  fixed. Not a math bug in `intent_tag_pos` -- `_position_intent_tag()` ran
  from `_process()`, one full engine frame ahead of the active hunter's own
  climb-tween position update, so it always placed the tag to clear a
  hunter position that was already stale by the time that frame rendered
  (proved live, numbers matched frame-for-frame). `call_deferred` did not
  fix it; wiring `_position_intent_tag` to `RenderingServer.frame_pre_draw`
  instead did. 2 new tests (real captured numbers pin the mechanism; a
  scene test pins the actual signal wiring), full 80-step regression clean
  (0 `intent-tag-vs-hunter` fails, was 1).
- 2026-09-24 11:34 EDT — dropped-slider-shows-wrong-timing-label:
  fixed. A dropped slider hold's MISS burst read "TOO EARLY"/"TOO LATE" off
  a frozen, stale `_offset()` sign instead of saying it was let go; also
  fixed the same-neighborhood bug where a rescue-window downgrade (release
  past `SLIDE_RESCUE`, a real GOOD, not a MISS) popped no burst at all.
  New "LET GO" label, a testable static `burst_label()` rule, 9 new tests,
  before/after render, full regression clean.
- 2026-09-24 08:46 EDT — jump-hides-behind-intent-tag: fixed.
  `intent_tag_pos` gets a `hunter_rect` param with a real 2D overlap test
  (prefer above, fall back below, else leave alone) — the artist's own
  find, mid-jump the hunter's sprite could render behind the boss's intent
  tag. 4 new tests on the artist's exact numbers; live re-render of their
  named repro hop shows no overlap; full regression clean (only the
  already-known hop-distance-band). Also ruled out a 5th dead end on the
  stone-route ceiling and self-filed a real dropped-slider mislabeling bug
  an Explore pass found, for a future run.
- 2026-09-24 05:34 EDT — intent-tag-hides-behind-party-panel:
  fixed. `_position_intent_tag`'s Y clamp (clear of the HP bar, clear of
  the hand) never accounted for the top-left party panel, and the HP-bar
  clamp itself sits inside the panel's own y-range. New pure static
  `Combat3D.intent_tag_pos()` raises the Y floor to clear the panel
  whenever the tag's X-range would overlap it. Reproduced the playtester's
  exact numbers first; 3 new tests pinned to those numbers; full live
  playtest to a real fight ending, 0 `intent-hidden` fails.
- 2026-09-24 02:54 EDT — boss-damage-popup-offscreen-at-sigil:
  fixed. A boss hit's damage-popup rise is a fixed world distance; the
  sigil's own tight camera framing turned it into enough screen pixels to
  poke a few px past the top edge. New `popup_rise_scale()` (combat_3d.gd)
  scales the rise down so it lands on a 30px pad instead. 3 new tests
  pinned to the playtester's own exact reported numbers; full live
  playtest, 0 `damage-popup-offscreen` fails. Could not reproduce the
  ORIGINAL failure live on the current tip (likely moot since the
  stone-route fix moved the sigil) — fixed the real underlying gap anyway.
  Also confirmed (not fixed) that the stone-route request's last two short
  hops are a genuine geometric ceiling, not a retry-budget bug — a fourth
  dead end ruled out and written into that request.
- 2026-09-24 00:24 EDT — build-the-one-directional-stone-route,
  items 2/3. Item 3 (next-hold ring) verified already correct, no fix
  needed. Item 2 (2.4-9.2 unit hop band): built `hop_world_distance()`/
  `hop_distance_violation()` in `route.py`, hard-gated into `beast.py`'s
  `_prove()`, improved `ai_beast.py`'s middle-rung candidate selection —
  fixed 2 of 5 real hops on the shipped Cinder Jackal (Height 1→2, 2→3),
  the two nearest the sigil (3→4, 4→5) stay short. Two structural attempts
  to close that gap both reintroduced a live route-reversal (playtester's
  own check) and were reverted; written down in the request so the next
  agent doesn't retry either. `test_route.py` 33 assertions, `run_tests.gd`,
  and a full 80-step live playtest all clean (one pre-existing, unrelated
  `intent-hidden` fail). Left `status: taken`.
- 2026-09-23 15:01 EDT — no open `to: fixer` request; full
  play/hover/hands baseline clean. Explore agent found a real bug in
  `core/combat.gd`'s `can_play()`: the `pull_ally` range gate blocked a
  card's ENTIRE effect out of grapple range, not just the pull — hit two real
  reward cards (Chain Lift's Block, Tongue Grab's Rhythm). Narrowed the gate
  to only hard-block a pull_ally-only card (Grappling Arm unchanged, matches
  Nick's own prior call); mixed cards now stay playable. Three new tests,
  reproduced on the unfixed tree first, `ALL TESTS PASSED`. Self-filed
  `requests/2026-09-23-1500-fixer-to-fixer-pull-ally-gate-blocks-a-cards-other-effect.md`.
- 2026-09-23 — took the high-priority hunter-display-path request
  (artist-filed, Nick's own note named it top of the fixer queue). The
  toon-shaded, rigged/animated display path a beast gets (`AI_ART`,
  `_shade_model`, `_beast_anim`) was gated on `root == _beast` throughout, so
  no hunter id could ever reach it. Generalized each gate at its own spot: a
  new parallel `HUNTER_AI_ART` table; `_shade_model`'s toon branch pulled into
  a pure `Combat3D.wants_toon(beast_here, beast_toon, force_toon)` with every
  existing call site unchanged (`force_toon` defaults false); `_spawn_hunter`
  now wires a hunter's own `AnimationPlayer` idle loop exactly like
  `_show_beast` does; new `_hunter_play` (`_beast_play`'s twin) fires "hit" on
  the hunter who took damage and "attack" on every hunter when a hit lands on
  the boss (no per-hunter attribution exists in the shared state diff for
  which hunter's card connected — same aggregate granularity the existing
  beast-side "attack" trigger already uses; written down as a known limit,
  not faked finer than the data supports); `location_3d.gd`'s reward-screen
  hunter row got the matching lookup. Four new `wants_toon` unit tests; repro
  against the pre-fix gate (force_toon ignored) failed exactly as predicted,
  fixed passes, `ALL TESTS PASSED`. Live-verified exactly as the request
  asked — temporarily tagged the existing `frog.glb` into `HUNTER_AI_ART`
  (no new asset), confirmed it toon-shades in a `state=3d` screenshot,
  reverted the tag before committing. Live regression check after pushing —
  full `mode=play beast=cinder_jackal steps=80` — `PLAYTEST OK: 0 failing
  check(s)`, no regression from the new per-tick `_hunter_play` calls. See
  `## Now` and the request's own `## Result`.
- 2026-09-23 — fixed the shared-foothold-4 side-gap (self-filed
  request, oldest open `to: fixer`). Root cause was neither of the request's
  own two sub-questions: `stone_point()` pushed a standing point radially
  away from WORLD ORIGIN in the XZ plane instead of straight forward off the
  body, so an anchor already off-axis in x (foothold 4 is the jackal's own
  ear, x=3.9) picked up its own extra x-drift on top of `stand_offset_x`'s
  correct side spacing, compounding past playtest.gd check 8's tolerance at
  a shared foothold. Fixed by making `stone_point` push purely forward (+z).
  Three new unit tests (repro fails unfixed, passes fixed), `ALL TESTS
  PASSED`. Live `mode=play steps=80`: zero FAIL lines; frame at step 34
  (both hunters confirmed at foothold 4 via the HUD) shows the side-shifted
  Goblin Engineer plausibly on the model, not floating clear of it. See
  `## Now` and the request's own `## Result`.
- 2026-09-23 — took the high-priority
  `end-turn-crash-at-sigil-solo-flip` request, a real engine-level crash.
  Root cause: `_end_turn()` calls `_client.end_turn()` first, which resolves
  SYNCHRONOUSLY all the way through the host and back to
  `state_updated.emit()` before returning — and `views/game_3d.gd`'s phase
  router, connected to that same signal earlier (it's the parent that
  instantiates Combat3D), reacts to a phase change by `remove_child`-ing the
  CURRENT Combat3D view immediately, mid-`_end_turn()`. Control returns to
  `_end_turn()`, which carries on regardless into
  `_apply_solo_turn_flip()` -> `_focus_camera()` -> `_apply_orbit()` ->
  `_cam.look_at()` on a camera that just left the tree — the exact stack
  trace filed. Deterministic given game state, not a true race; what looked
  race-like across identical seeds is the slow sandbox renderer nudging
  timed-minigame grades, which changes which End Turn ends the fight.
  `location_3d.gd` already documents and guards this exact router race
  (backlog #7); `_focus_camera()` had no such guard. Fixed with one line —
  `_focus_camera()`'s existing `_cam == null` guard now also checks
  `not is_inside_tree()`. Reproduced against a REAL `combat_3d.tscn`
  instance (a bare `Combat3D.new()` never resolves `%Camera`, masking the
  bug): removed it from the test tree the same way `game_3d.gd` does, called
  `_focus_camera()` — with the guard's new clause temporarily reverted this
  printed the identical engine error the request's log shows
  (`Node not inside tree ... at: look_at`) and moved the camera anyway;
  restored, it does neither. Two new tests, `ALL TESTS PASSED`. A live
  `mode=play steps=80` run was still rendering (timing-dependent trigger,
  slow sandbox) when this was written — see `## Now` for whether it landed
  in time.
- 2026-09-23 — took `hunter-damage-popup-offscreen` request
  (playtester's guess of a camera-timing gap was wrong). Root cause:
  `Combat3D._damage_popup`'s rise tween and `popup_offset`'s minimum
  separation both scaled off the BEAST's own height (`reach`, ~20 on the
  Cinder Jackal) even for a hunter hit — a hunter is 0.7 units tall, so a
  beast-scale rise (~4.4 units) or spacing (~10 units) sent the number
  flying off-frame while the camera correctly stayed on the (stationary)
  hunter. Fixed with `Combat3D.popup_move_reach(beast_reach, on_hunter)`;
  hunter hits now scale off `HUNTER_HEIGHT * 3.0` instead. 3 new tests
  using the live repro's exact numbers, `ALL TESTS PASSED`; before/after
  frames via a targeted `screenshot.gd state=3dstrike` repro (the full
  `mode=play` playtest render was unreliable this session — see `## Now`).
- 2026-09-23 — took the high-priority
  `hunter-floats-off-model-at-foothold-4` request. Root cause:
  `Combat3D._stand_on_model` let a coarse runtime hull estimate
  (`_front_of_beast`) override an EXACT rung's own already-correct anchor
  (raycast-placed at export time by `beast.py`'s `_decorate`) — at foothold
  4, `hull_front_at`'s neighbourhood scan reached two hull bands above the
  anchor's own row and grabbed a single, disconnected cell belonging to the
  Cinder Jackal's own ear, using it as "the front of the body" and dragging
  the hunter's z from 6.47 to 13+. New static `Combat3D.stand_z_for`
  trusts the anchor directly whenever `foot` is an exact climb-anchor key,
  only falling back to the hull for a lerped, between-rung foothold. Three
  new unit tests (repro + two off-anchor guards); repro fails on the old
  always-`maxf` formula, passes fixed; `ALL TESTS PASSED`. Live
  `mode=play` before/after: z-gap from the anchor 3.78 → 0.56 world units,
  the wild "hanging over the arena wall" float is gone. Commit `c8e965b`.
  Found and split out a smaller, separate residual (two hunters sharing a
  narrow foothold, `stand_offset_x`'s spacing clearing the model) into its
  own request rather than folding it in — see the request's `## Result`
  and `## Now` above for both.
- 2026-09-23 — fixed `Combat3D._on_card_tapped` picking a melded
  card's HitCircle face (slider vs. tap chain) by `card_climb_for(card) >=
  SLIDER_CLIMB` alone, ignoring `timed_hits`: melding Winch (grip 2) with
  Satchel Charge (timed_hits 3) — both in the Goblin Engineer's own pool,
  via their own Meld card — produced a fused card that collapsed to a
  single 0.85s slider hold instead of the 3 separately-graded windows the
  sweep-bar CardView face already correctly demands for the identical card.
  Extracted `Combat3D.card_is_slider(card, hits)` — `card_climb_for(card) >=
  SLIDER_CLIMB and hits <= 1` — a no-op for every currently-shipped slider
  (all have `timed_hits` 1), fixing only the melded case. Four new tests
  (full 2×2 truth table); repro fails on the old formula
  (temp-reverted just the new function's body), passes fixed. `ALL TESTS
  PASSED`; fresh `mode=play` baseline clean (general-regression sanity, this
  exact melded card isn't in the scripted sequence). No live frame — no
  dev-harness switch forces a synthetic melded card into a hand; proof is
  the before/after unit test, same convention every other pure
  timing-minigame rule in this file uses. Self-filed and self-fixed — see
  the request's `## Result`.
- 2026-09-23 — fixed `HitCircle.note_hit` (ui/hit_circle.gd)
  double-reporting a slider's one note: a good press emitted `note_hit(0,
  PERFECT)` immediately, then dropping the hold before `SLIDE_RESCUE`
  unconditionally emitted `note_hit(0, MISS)` too — two conflicting verdicts
  for the same index, violating the signal's own "quality grades that note
  alone" contract. Not yet player-visible (`combat_3d.gd` only connects
  `resolved`, not `note_hit`, yet) but a real logic bug in code explicitly
  in the fixer's scope, found by order-of-work item 3 after items 1-2 (open
  requests, live playtest) came back clean. Added `_slider_note_hit`; guards
  `_finish()`'s MISS emission so a slider's already-reported note isn't
  re-reported. Visual MISS burst untouched — still plays on a dropped hold.
  Two new tests (the double-report repro; a sibling proving the guard
  doesn't silence a genuinely missed press) — repro fails on the unfixed
  tree (`git stash` on just `hit_circle.gd`) with `got [[0, 2], [0, 0]]`,
  both pass fixed. `ALL TESTS PASSED`; `mode=play`/`hover`/`hands` baseline
  clean before, `mode=hands` re-checked clean after (pure logic fix, nothing
  rendered changes). Self-filed and self-fixed — see the request's
  `## Result`.
- 2026-09-23 — backlog #86 duty 3: fixed
  `Location3D.reward_header_text()` telling a player to "Tap a relic to
  select" when the reward row was empty (2-player co-op runs the boss relic
  pool dry by the 3rd Titan — already filed `to: nick`, still open for the
  sizing call). Added a `has_choices` parameter; empty + not picked/selected
  now reads "Nothing left to take — Skip to continue". Three new tests
  (message text, "tap" never appears, locked-in still wins over the empty
  message); all three fail on the unfixed `elif` chain, pass on the fix.
  Rendered `state=3dreward` with both hunters' choices forced empty to see
  it live. `ALL TESTS PASSED`; full `play`/`hover`/`hands` baseline clean
  before and after. See `## Now` and the request's own `## Result`.
- 2026-09-23 — backlog #86 duty 2: fixed `Run.history_entry()` recording a
  sealed-door ending (fourth Titan reached without all three keys) as
  `"result": "win"` in `Progress.run_history()`, even though the sibling
  `_note_progress()` check correctly kept it out of the real win counter —
  matched `history_entry()`'s condition to that sibling's
  (`phase == WON and true_ending`). Extended the existing sealed-door test
  to check `run_history()` too; failed on the unfixed tree (`got
  result=win`), passes now. `ALL TESTS PASSED`; `mode=hands` playtest clean.
  Full write-up in `design/plan/BACKLOG.md`'s `## Log`. Items 1-3 (Cinder-
  Jackal-scoped) came back clean first, same as yesterday's audit — see
  `## Now`.
- 2026-09-22 — full audit pass, no bug found: live `mode=play` (80
  steps, exercised Meld/Catapult+Burn Coal fusion, Satchel Charge,
  Goblin Jetpack, a real fall onto an intermediate ledge), `mode=hands`,
  `mode=hover` all `PLAYTEST OK: 0 failing check(s)`; read
  `core/combat.gd`, `combat_3d.gd` and `card_view.gd` against every
  Frog/Goblin Engineer card field. Ruled out two apparent bugs (Satchel
  Charge's armored-hide-reduced "Deal 1 damage" preview; a `mode=hands`-
  only audio-resource-leak warning at `quit()`, both by design/harness
  noise, not gameplay bugs). Nothing fixed, nothing pushed to `game/` —
  `run_tests.gd` unchanged and green throughout.
- 2026-09-22 — fixed `Combat3D.hop_arc()` building a hop's apex below the
  landing height on a tall single-leg climb (Leap/Hop spanning several
  hunter-heights in one hop), caught live by the playtester's `hop-flat`
  check; apex height now `maxf(from.y, to.y) + hop` instead of a 58% lerp
  plus a capped hop. Two new unit tests, playtest report before/after
  (`PLAYTEST FAIL: 1 failing check(s)` → `PLAYTEST OK: 0 failing check(s)`).
  Self-filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — filed (did not fix, outside the Cinder Jackal fight's scope)
  the boss-relic pool running dry by the 3rd of 4 Titans in 2-player co-op
  (only 4 `tier: "boss"` relics, both hunters draw from the same shared
  pool each kill) — reward screen shows nothing to tap while the prompt
  still says to tap one. `to: nick`, frame attached.
- 2026-09-22 — fixed the reward screen's prompt line ("Tap a card to
  select") being painted over by the reward row's own cards and fighting
  the felled beast's 3D corpse for contrast — wrapped it in a
  `PanelContainer` (the same backdrop pattern every combat HUD label
  already uses) and moved its band clear of the row, gated on non-empty
  text so other screens don't gain a stray empty bar; before/after frames.
  Self-filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — fixed the attack icon ("⚔") rendering as a bare "×" on the
  boss's intent telegraph and the party card's incoming-damage readout —
  U+2694 CROSSED SWORDS has no glyph in this build's font-fallback chain.
  Replaced it with a new `Combat3D.ATTACK_GLYPH` constant (†), probe-verified
  to render; four unit tests (three updated, one new); before/after frames.
  Self-filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — fixed the climb rail's gauge drawing one hunter's dot on top
  of the other's at the sigil (raw-foothold vs clamped-foothold comparison
  in the dot-offset logic, same bug class as the two fixes below but in a
  spot neither one touched); one new pure function
  (`Combat3D.gauge_dot_dx`), four new unit tests, before/after frames. Self-
  filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — fixed the party panel showing a raw foothold past the sigil
  ("↑16 / 5"); clamped the numerator in `party_card_stats()`, one new unit
  test, before/after frames. See the request's `## Result`.
- 2026-09-22 — fixed hunters overlapping at the sigil (raw-foothold vs
  clamped-foothold comparison in `hunter_side_offset`); two new unit tests,
  a new playtest check, before/after frames. See the request's `## Result`.
- 2026-09-22 — note created by the session.
