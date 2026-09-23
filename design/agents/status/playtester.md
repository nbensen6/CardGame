---
tags:
  - agent-status
agent: playtester
updated: 2026-09-23
working_on: full three-mode baseline (hover/hands 0 fails, play 3 fails — the known foothold-4 residual only, unchanged); the fixer's hunter-damage-popup-offscreen fix (9653ecc) verified live, 0 fails across 5 real hp-loss events; added the visibility-aware follow-up check I'd flagged as still open — damage-popup-offscreen in playtest.gd, watching every live popup's on-screen projection across its whole life, not just at spawn — proved both directions (clean on the real fix, 3/3 FAILs when I temporarily reverted the fixer's own fix to reproduce the exact old bug, then cleanly reverted my revert). No new bugs found; nothing new filed.
---

# playtester

## Now

No open `to: playtester` request this run (checked every file's frontmatter).
Fresh sandbox, Godot 4.7.1 + `--import`, `run_tests.gd`: `ALL TESTS PASSED`.

**Full three-mode baseline**: `hover` 0 flips, `hands` (1-10) 0 fails — both
clean, matching every prior baseline. `play` (80 steps): **3 failing
checks**, all `hunter-off-marker` (steps 34, 35, 71), all sharing the exact
same coordinates as every recent run (`home (5.335257, 13.825942,
7.030925)`, anchor `(3.901302, 13.825942, 6.473297)`) — this is the fixer's
own still-open `2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`,
untaken since it was filed, unchanged today. Not a new finding, not
regressed, not improved. No `script-error` this run — the intermittent End
Turn crash from my last run's `2026-09-23-1000-playtester-to-fixer-end-turn-crash-at-sigil-solo-flip.md`
(also still open, untaken by the fixer) did not reproduce here either. Worth
being honest, same as that request's own `## Done when` says: a race that
doesn't fire on one more clean run is not proof of anything — it just wasn't
this run's turn.

**Checklist item 1's remaining gap is now closed, both the bug and the
coverage.** The fixer took my `hunter-damage-popup-offscreen` request this
run (commit `9653ecc`, `Combat3D.popup_move_reach`) — their root cause
(popup travel distance scaled off the BEAST's height even for a hit that
landed on a HUNTER, six-plus hunter-heights too far) was not my own guess
from that request (an in-flight camera transition), so this needed a fresh
look, not just trusting the fix. This run's clean 80-step baseline already
shows it working live: 5 real hp-loss events (steps 34, 50, 65, 71, 77), 0
`damage-popup-missing` fails (existence, check 10, unchanged) — but until
today nothing checked existence's other half, VISIBILITY, in the wild.
That's exactly what my own last two runs' `## Next` kept flagging as the
natural follow-up once the fixer knew the real cause.

Added it: `_poll_popup` (playtest.gd) now asks the same camera question
check 9 already asks about a hunter — behind the camera, or projecting
outside the viewport — about every live `Label3D` popup's OWN current
position, every frame it's still polled (not just once at first sighting).
That last part matters: the original bug was a popup that started ON screen
and rose OFF it over its own ~1.7s tween (the fixer's own write-up: screen y
301 → -217), so a spawn-time-only check would have missed the exact case
this exists to catch. Latched per step like the existence check, one bad
frame anywhere in the popup's life is enough — new failure
`damage-popup-offscreen`.

**Proved it both directions, not just "ran clean once".**

- *Positive*: full 80-step `mode=play` baseline against the real, fixed
  code — 0 `damage-popup-offscreen` fails across all 5 real hp-loss events.
- *Negative*: temporarily reverted the fixer's own fix in `combat_3d.gd`
  (`popup_move_reach` back to always returning `beast_reach`, ignoring
  `on_hunter`) and reran a 36-step slice. Got exactly **3**
  `damage-popup-offscreen` FAILs, at the same shape the fixer's own
  before-fix numbers showed (screen y -89, -28, -86 — all well above the top
  of a 720px-tall viewport). Checked one by eye too: step 9's saved frame
  shows the HUD boss bar correctly at 42→31, but no floating number anywhere
  on screen — matching the check's verdict, not just trusting the number.
  Reverted the break immediately after (`git diff game/views/combat_3d.gd`
  clean before moving on), then re-ran `run_tests.gd` and a fresh full
  80-step baseline on the real code to get final numbers: clean, only the
  known foothold-4 residual above.

![[frames/playtester/2026-09-23-damage-popup-offscreen-check-negative-test-step009.png]]
The negative-test frame (fixer's fix temporarily reverted, for this proof
only) — boss HP visibly dropped 42→31 in the HUD, but no damage number is
anywhere on screen. This is the exact shape the new check now catches
automatically on every run.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | **gap closed** — the off-screen damage-number bug (filed two runs ago) is fixed by the fixer (`9653ecc`) and now has permanent automatic coverage (`damage-popup-offscreen`), proved both directions |
| 2 | hunters land on the beast correctly | unchanged — the shared-foothold-4 residual is still the fixer's own open, untaken request; today's 3 fails match its exact known coordinates |
| 3 | jump animation (squash/arc/landing) | unchanged this run |
| 4 | camera | unchanged this run — `hunter-lost-mid-hop` (added last run) still live, still 0 fails in the wild |
| 5 | nothing errors | ok this run (`ALL TESTS PASSED`, no `script-error`) — but the intermittent End Turn crash request is still open and unconfirmed either way; one more clean run is not proof it's gone |

No new requests filed this run — nothing failed that wasn't already known
and owned by an existing open request.

## Next

Two open `to: fixer` requests are still the loudest unclaimed items on the
board: my own high-priority End Turn crash
(`2026-09-23-1000-playtester-to-fixer-end-turn-crash-at-sigil-solo-flip.md`)
and the fixer's own shared-foothold-4 spacing
(`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`),
both untaken across at least two of my runs now. Watch for either landing,
then re-baseline: the crash needs several repeated clean runs to mean
anything (it's a race, not a deterministic repro), and foothold-4 needs a
re-check of item 2 once fixed since it's shown as intermittent even in its
current broken state. `damage-popup-offscreen` and `hunter-lost-mid-hop` are
both live now with 0 real fails found in the wild — worth remembering they
exist as coverage the next time a popup or camera change lands. Items 3/4's
human-eye frame-strip look is still current from two runs ago; nothing new
to add there this run.

## Old: 2026-09-23, mid-hop camera check, end-turn crash filed
Fresh sandbox, Godot 4.7.1 + `--import`, `run_tests.gd`: `ALL TESTS PASSED`.

**First full three-mode baseline came back completely clean** — a first for
several runs: `play` (80 steps) 0 fails, `hover` 0 flips, `hands` (1-10) 0
fails. The shared-foothold-4 residual that's been showing up in recent runs
(the fixer's own open
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`,
still untaken) simply didn't trigger this particular run — both hunters
never happened to occupy foothold 4 at the same settled-check moment on this
run's exact real-time path. Not claiming it's fixed (that request is still
open, unfixed, and I saw its exact failure mode again two runs later, see
below) — just noting today's first baseline happened to dodge it.

**Extended `playtest.gd` for checklist item 4's other half.** Check 9 (the
camera check) is explicit in its own comment that it only judges the
SETTLED shot — mid-hop framing is a separate, already-documented gap this
playtester's own `## Next` has flagged across at least three prior runs
("only the mid-hop transient... is a separate, already-documented gap").
JACKAL-BAR itself names it directly: "the camera never loses the active
hunter, **including mid-jump**." `_watch_hop` already samples the animated
hunter node every real frame while a climb tween runs (for the arc/squash
checks) — piggybacked the same loop: each sample also asks the live camera
`is_position_behind` / `unproject_position` against the hopping hunter's
`global_position`, same API check 9 already uses. Only meaningful when the
camera is actually following THIS hunter (`lock_slot_for(...) == me`, the
same fix check 9 needed after it first false-fired on the OTHER hunter
mid-climb) — skipped otherwise, so a hunter hopping off-frame while the
camera is deliberately locked on their ally never counts. Gated on
`MIN_HOP_SAMPLES` like the arc/squash checks (below that, not enough
evidence, say nothing), and only fails when the hunter was off screen for
**more than half** the sampled flight — a single-frame graze at a wide arc's
edge is not "the camera lost the hunter," and check 9 already owns the
settled end-state; new check `hunter-lost-mid-hop`.

Proved it both ways, per this playtester's own past mistake of trusting a
check that can only ever pass: smoke-tested at 20 steps first (4 hops
sampled, 0% off every time, no false positives), then deliberately broke it
(`if true or cam.is_position_behind(...)`, forcing every sample to read as
off-screen) and reran a 12-step slice — got exactly one
`hunter-lost-mid-hop` FAIL, "111/111 sampled frames (100%)". Reverted before
anything else.

**A follow-up full 80-step baseline with the finished check surfaced a real
engine crash, unrelated to my own change.** Ran the full baseline again
(same code, same seed) to get final numbers with the new check live:
`script-error` x2, the run truncated at step 64 out of 80 — a genuine Godot
assertion, `node_3d.cpp: Condition "!is_inside_tree()" is true`, thrown from
`combat_3d.gd`'s own `_apply_orbit` (called via `_focus_camera` via
`_apply_solo_turn_flip` via `_end_turn`) trying to `look_at` a camera that
was no longer in the scene tree — which then killed the whole game view, and
this bot's own harness threw a second, secondary error polling the now-freed
node. Checklist item 5 ("nothing errors") at its worst: not a cosmetic
glitch, a crash that ends the fight. A THIRD full baseline run (again,
identical code/seed) did NOT reproduce it — ran clean 80 steps, only the
already-known shared-foothold-4 residual (3x, matching the fixer's own open
request's exact numbers). One crash in three otherwise-identical runs is a
timing/race signature, not a deterministic logic bug — exactly the shape
this sandbox's slow software renderer is good at surfacing. Filed to the
fixer, priority high, with the full stack trace, the frame right before the
crash, and an honest note that I can't hand them a repro that fires every
time.

![[frames/playtester/2026-09-23-end-turn-crash-step063-before-crash.png]]

**Also did the human-eye frame-strip look on items 3/4 this playtester's own
`## Next` has been deferring for several runs** ("`a823001`... still hasn't
had a frame-strip look at anything OTHER than the two bugs it turned up").
Tiled 6 frames across a typical, non-sigil, non-foothold-4 climb (step 0,
the very first ground climb, endpoints y 0.00→8.97) and looked at it at 1:1:
real motion across the strip, the Frog visibly arcing from behind the
jackal's hind leg to a floating stone off to the side, not a frozen or
teleporting frame. No new bug there. Also looked again at a sigil-approach
hop (step 17) purely to sanity-check the mid-hop camera check's own
"0% off" verdict against a human eye, since that climb's endpoint sits right
at the sigil where the camera is known to pull in tight on the jackal's
head: confirmed the check is technically right (the Frog does project
inside the viewport, both hunters visible, tiny, perched on the jackal's
head between the ears) but a human would still call this "barely readable"
— the same known gap this playtester has logged before (Nick's third-person
camera target still pending), not a new finding, so not re-filed.

![[frames/playtester/2026-09-23-hop-strip-ground-climb-step000.png]]
![[frames/playtester/2026-09-23-sigil-camera-close-known-gap-step017.png]]

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged this run |
| 2 | hunters land on the beast correctly | unchanged — the shared-foothold-4 residual is still the fixer's own open request; today's runs show it as intermittent (0 of 3 baselines had it fail, then 3x on the 3rd) rather than fixed |
| 3 | jump animation (squash/arc/landing) | human-eye frame-strip look on a typical climb, first one done since `a823001` two runs ago — real arc, no new bug |
| 4 | camera | **new automatic check** — `hunter-lost-mid-hop`, the "including mid-jump" half JACKAL-BAR names and check 9 explicitly skipped; proved both directions; found no bug in three runs' worth of hops, but DID surface (indirectly, by running the extra baseline to get clean numbers) the End Turn crash above |
| 5 | nothing errors | **regression found** — a real, if intermittent, crash on End Turn (`_apply_orbit`/`_cam` not in tree), filed to the fixer, high priority, not yet fixed |

One request filed this run: `to: fixer`, priority high,
`2026-09-23-1000-playtester-to-fixer-end-turn-crash-at-sigil-solo-flip.md`.

## Next

Watch for the fixer taking the End Turn crash request — it's the loudest
finding this run (checklist item 5) and worth a fresh multi-run baseline
once a fix lands, since "ran clean" needs several repeats to mean anything
for a race, not one. The shared-foothold-4 residual is unchanged, still
sitting on the fixer's own open request; keep an eye out for it going
`done`, then re-verify item 2 across a few runs (today showed it's
intermittent even unfixed, so one clean run won't prove it closed).
`hunter-lost-mid-hop` is live now and found nothing yet — worth remembering
it exists next time a camera complaint comes in, since it's the first
automatic coverage of the mid-jump half of item 4 at all. Item 1 (card
plays) hasn't had a fresh look in a few runs; still worth returning to.

## Old: 2026-09-23, verify c8e965b's foothold-4 fix, fix a hop-flat false-fire in playtest.gd itself

Fresh sandbox (detached HEAD on a stale local `main` from container init —
origin/main and local main share no merge-base, so worked from
`origin/main` directly rather than force-resetting a branch ref without
asking). No open `to: playtester` request this run. HEAD started at the
fixer's own `c8e965b` ("stand_z_for trusts an exact rung's own anchor over
the hull"), which targets exactly the foothold-4 float regression I filed
last run.

Set up fresh (Godot 4.7.1 + `--import`, Xvfb), `run_tests.gd`: `ALL TESTS
PASSED`. Full three-mode baseline against `c8e965b`: `hover` 0 fails,
`hands` 0 fails (clean, matching every prior baseline). `play` (80 steps):
**2 failing checks**, `hunter-off-marker: 4` and `hop-flat: 2`.

**Foothold-4: verified the fix is real, not a no-op — and while I was
writing up the residual, the fixer beat me to it.** Before `c8e965b`,
`home.z` at foothold 4 was 10.25 — a hunter hanging in open air against the
arena wall, ~4m from the marker. After, it's 7.03, right next to the
anchor's own 6.47 — the frame now shows the hunter standing on solid ground
near the jackal's ears, not floating in dead air:

![[frames/playtester/2026-09-23-hunter-off-marker-foothold4-after-standz-fix-step038-feet.png]]
![[frames/playtester/2026-09-23-hunter-off-marker-foothold4-after-standz-fix-step038.png]]

`hunter-off-marker` still fires 4x (steps 38/39/78/79, `x` off by 1.43
against a 1.06 tolerance) — I had a follow-up request drafted for this when
a `git fetch` mid-run turned up the fixer's OWN `4c15649` ("close out
foothold-4 float — proof, write-up, and the residual"), pushed while I was
still rendering: they independently hit the exact same numbers
(`home (5.335257, 13.825942, 7.030925)`, same anchor, same 1.54m), traced it
further than I had (a debug print confirming both hunters share foothold 4
simultaneously, and `stand_offset_x`'s spacing — sized off the whole beast's
bounding-box width — overshoots the jackal's much narrower ear at that
specific foothold, plus `_build_float_stones` only ever building one
centred stone per height so the side-shifted hunter has nothing to land on
regardless), and self-filed
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`.
Two independent same-day findings landing on identical numbers is about as
strong a confirmation as this gets. Deleted my own draft rather than file a
duplicate — nothing left for me to add here; checklist item 2 stays at
"real, large improvement, smaller residual already owned."

**`hop-flat` fires 2x near the sigil, steps 49/50 — chased it down, and it
was my own tool's bug, not the game's.** Both captures had only 5 in-flight
samples and reported the peak sitting at EXACTLY the start height (18.13).
`hop_arc`'s own proven invariant (apex clears both endpoints by at least
`HUNTER_HEIGHT * 0.9`, regardless of distance — an existing unit test)
made that suspicious rather than a clean "reads as a slide" verdict. The
`git fetch` above also surfaced the fixer's OWN independent run hitting the
same shape at yet a THIRD set of step numbers (30/42/52/53, different
footholds, 6-7 samples) and dismissing it as matching my own previously-
documented sparse-sampling flake pattern. Two independent runs failing at
different steps each time is the opposite of what a real geometry bug would
do (same footholds every run) — it's the signature of a sampling gap.

Both 5-frame strips, both hunters essentially static throughout (still
reading "at the sigil" in every saved frame):

![[frames/playtester/2026-09-23-hop-flat-near-sigil-step049-strip.png]]
![[frames/playtester/2026-09-23-hop-flat-near-sigil-step050-strip.png]]

Found it: `_check_hop`'s confidence gate (`covered_from_start`) has a
`total_dist < 0.05` bypass for near-zero-distance climbs that doesn't
actually verify the samples covered the flight's real TIME, only that the
first sample was spatially close to a start/end pair that are already
almost the same point — trivially true regardless of when sampling began.
Near-sigil climbs where consecutive footholds compress to nearly the same
anchor hit this exactly, and on this sandbox's slow renderer sometimes only
get 4-6 real samples across the whole hop, which can land entirely outside
the rise/hang window purely by bad luck.

**Fixed in `playtest.gd`, not filed to the fixer** (this is my own tool,
squarely in "extend it" territory) — added `MIN_HOP_SAMPLES := 10`,
AND'd into `covered_from_start` alongside the existing spatial check.
Strictly conservative: it only ADDS a requirement, so it can never turn an
already-correct fail into a pass, only move an under-sampled "confident"
capture to "not judged." Checked against this run's own report.md before
touching anything: real, meaningful climbs got 25-120 samples every time
(steps 17, 34, 38, 78); the degenerate near-sigil ones that misfired got
4-6 (steps 10, 19, 20, 32, 36, 37, 41, 43, 49, 50) — the threshold cleanly
separates the two populations in real data, not a guess.

**Verified, not just reasoned about.** Re-ran `mode=play steps=51` (covers
the exact repro plus the big, well-sampled climbs) after the fix:
`hunter-off-marker: 2` is the ONLY failing check left — `hop-flat` and
`hop-no-squash` are gone. The five previously-flagged-or-flaggable
under-sampled captures (steps 19, 20, 36, 37, 43) now correctly report "too
few samples, arc/squash not judged" instead of a verdict. The two
well-sampled climbs in the same run (step 17: 120 samples, step 34: 26
samples) still get judged normally, "from the start" — so a real hop_arc
regression on a real climb would still be caught, unweakened.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged this run |
| 2 | hunters land on the beast correctly | **improved, residual owned by the fixer's own request** — `c8e965b` fixed the open-air float; the smaller shared-foothold gap is diagnosed and self-filed by the fixer (`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`), nothing further for me to add |
| 3 | jump animation (squash/arc/landing) | **checker bug found and fixed** — `hop-flat` was false-firing on under-sampled near-sigil captures; `MIN_HOP_SAMPLES` gate added to `playtest.gd`, verified clean on a fresh run with the real bug-catching cases (25-120 samples) still judged |
| 4 | camera | unchanged this run |
| 5 | nothing errors | ok — `ALL TESTS PASSED`, no script errors in any log this run |

## Old: 2026-09-23, foothold-4 float regression (superseded by this run's verification above)

No open `to: playtester` request this run (the board's only other open
items are `to: nick` — boss-relic-pool, hunters-at-pass-cap,
model-rendered-card-art-direction — and my own still-open `to: fixer`
damage-popup-offscreen request from last run, untaken). Ran the full
baseline first, unmodified `playtest.gd`, against today's tip — which,
since my last run, picked up Nick's own `a823001` ("Rebuild the jump:
real arc, jump-framing camera, hunters facing the boss") and the artist's
`c3992f7` (Piston Punch card art, no gameplay code).

**Not clean this time.** `hover` 0 flips and `hands` (1-10) 0 fails, both
matching the last baseline. But `play` (80 steps): `hunter-off-marker`
(check 8) FAILED 3 times (steps 34, 35, 71) — the last several runs of
this exact check were all 0 fails, so this is a real regression, not a
flake. `run_tests.gd` still prints `ALL TESTS PASSED` (the bug is a live
placement issue the unit tests don't cover, not a logic error a pure test
would catch).

All three fails share the *exact same* `home` coordinates, and two of the
three (steps 34 and 71) are different hunters reaching foothold 4 by
different climb paths (`foot 7→4` vs `foot 10→4`) — this is deterministic
on foothold 4 itself, not path- or RNG-dependent. The numbers alone
(x missed tolerance by 0.27m) undersell it: the frame shows a hunter
floating in open air against the arena wall, no stone or beast surface
anywhere near its feet — exactly the "floating beside... the body" failure
checklist item 2 exists to catch.

![[frames/playtester/2026-09-23-hunter-off-marker-foothold4-step034.png]]
![[frames/playtester/2026-09-23-hunter-off-marker-foothold4-step034-crop.png]]

My read, unconfirmed: `a823001` changed `_stand_on_model`
(`combat_3d.gd:2751-2764`) to wrap its return in `stone_point(...)`
directly, where before only the *stone's own* visual position got that
treatment and the hunter stood at the raw anchor+clearance point. Check
8's tolerance was never widened for `stone_point`'s extra push, which
likely explains the borderline x-miss — but a hunter hanging with nothing
under it at all suggests `_front_of_beast` (which feeds the z clearance
that then feeds `stone_point`) is returning something much larger than
expected at foothold 4's own rung, pushing the whole point (hunter AND
its stone) well past the model. Diagnosing which of the three functions
is actually wrong is the fixer's job, not mine — filed with both frames
and the exact repro.

One request filed this run: `to: fixer`,
`2026-09-23-0900-playtester-to-fixer-hunter-floats-off-model-at-foothold-4.md`
(priority high — this is a live gameplay regression, not a polish gap).

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged this run |
| 2 | hunters land on the beast correctly | **regressed** — check 8 (`hunter-off-marker`) now fails 3x in the 80-step play baseline, a real floating-hunter bug at foothold 4, filed to the fixer, not yet fixed |
| 3 | jump animation (squash/arc/landing) | unchanged this run (Nick's own `a823001` reworked the arc/anticipation/landing squash directly — worth a fresh look with frame strips once the foothold-4 fix lands, since that commit touches exactly this item, but didn't check it this run — floating-hunter regression took priority) |
| 4 | camera | unchanged this run (`a823001` also reworked jump-framing; same note as item 3 — worth a fresh look, not done this run) |
| 5 | nothing errors | ok — `ALL TESTS PASSED`, no script errors in any log this run |

## Old: 2026-09-23, damage popup check

Picked up checklist item 1 (card plays read) — still only partially
checkable per this playtester's own brief and last run's checklist
snapshot. The hand-layout half (fan centred, hand/energy match the model,
nothing off-screen or covering End Turn) has been checked since the
baseline request; the half that was still open is "does something on the
beast (damage number, climb, block)" — climbs get the whole hop-watch
apparatus (item 3), but nothing checked that a real hit actually shows a
**damage number**, only that the HUD's hp/boss fields changed.

Added check 10 to `playtest.gd`: `Combat3D._damage_popup` spawns a
`Label3D` child of `_rig` for every point of real damage (`_react`'s
`boss_hit` / `hunter_dmg[i] > 0` — confirmed by reading `react_plan`, the
pure half of `_react`). A naive "screenshot after the step and look for a
label" would miss it almost every time: the popup's own lifetime
(~1.7s: 0.85s rise, then a 0.4s hold and 0.45s fade) is short next to how
long this sandbox's software renderer takes to get through a step's
plain wait (its frames land every ~0.15-0.3s, same cost class this
playtester already hit with the hop check). So instead of screenshotting,
the check **polls `_rig`'s children every frame the step is still
resolving** — folded into the SAME `await` loops `_play()` already runs
(the tail wait, `_drive_timing`'s two loops, `_watch_hop`'s own loop) via
one small helper (`_poll_popup`), so watching for the popup costs nothing
beyond the waiting this bot already does. A flag latches per step
(`_step_saw_popup`, reset before each action) and after the step's
before/after snapshot, a real hp drop (boss OR the active hunter — the
only two fields `_snap` tracks) with the flag still false is
`damage-popup-missing`.

Proved it both directions, not just "ran clean once" (per item 3's own
past mistake of trusting a clean run without checking the failure mode
too):

- **Positive**: full 80-step `mode=play` baseline with the real check —
  0 fails. Five real hp-loss events in that run (steps 34, 50, 65, 71,
  77), every one correctly saw a popup. `hover`/`hands` unaffected (the
  new code only runs inside `_play()`'s own helpers) — re-ran both to
  confirm, 0 fails.
- **Negative**: deliberately broke `_poll_popup` (`if false and child is
  Label3D:`) and re-ran the same 36-step slice — got exactly one
  `damage-popup-missing` FAIL, at the same step the positive run passed
  cleanly (step 34, hp 42→36). Reverted the break before anything else.
  This is the check actually firing, not a check that can only ever pass.

While proving it, I instrumented `_poll_popup` throwaway (not shipped —
reverted before this commit) to print the popup's own
`unproject_position` against the live camera the instant the check saw
it, out of curiosity whether "exists in the tree" also meant "on
screen." It did not: all three hunter-damage popups sampled across one
run projected ABOVE the top of the 720px-tall viewport (screen y from
-99 to -604), `is_position_behind` false for all three (so not a camera
looking the wrong way entirely — a real, if unconfirmed, distinct
finding from item 4's "on screen at all" check 9). Filed to the fixer
with the exact repro and both frames — see the request. This is a real
gap in checklist item 1's own bar ("does something on the beast — a
damage number") that the existence-only check above cannot catch by
design (deliberately scoped to existence, not visibility, the same
reasoning check 9 already used to avoid re-flagging the known camera
gap) — worth a second, visibility-aware check once the fixer knows the
real cause, not before.

![[frames/playtester/2026-09-23-damage-popup-offscreen-step34.png]]
The frame right after a real hunter-damage popup spawned (Goblin
Engineer hp 42→36 this step) — HUD shows the drop, but no number
anywhere on screen. Zoomed on the Goblin, still nothing:
![[frames/playtester/2026-09-23-damage-popup-offscreen-step34-crop.png]]

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | **partially stronger** — hand layout ok (unchanged), climb ok (item 3), and now damage-shows-a-number is checked too (check 10, 0 fails on existence) — but that same work surfaced a real "reads" gap (the number can render off-screen), filed to the fixer, not yet fixed |
| 2 | hunters land on the beast correctly | ok (check 8, `hunter-off-marker`, 0 fails) |
| 3 | jump animation (squash/arc/landing) | ok, unchanged this run |
| 4 | camera | check 9 unchanged this run — still settled-state only, still not visibility-aware (see item 1's new finding above, which is arguably the same underlying gap wearing a different hat) |
| 5 | nothing errors | ok |

One request filed this run: `to: fixer`,
`2026-09-23-0430-playtester-to-fixer-hunter-damage-popup-offscreen.md`
(the off-screen damage number above).

## Old: 2026-09-23, camera check 9

Ran the full baseline first, unmodified `playtest.gd`, against that
day's tip (the artist's `goblin_mech` pass 3, no fixer code changes
since the last baseline): **play** (80 steps) 0 fails, **hover** 0
flips, **hands** (1-10) 0 fails — clean, matching the last recorded
baseline, no regression from the artist's tri-budget trim. `run_tests.gd`:
`ALL TESTS PASSED`.

Picked up checklist item 4 (camera) per last run's `## Next` — still only
"partially checkable" and named directly in this playtester's own brief as
an example gap ("camera keeps the active hunter inside the frame" — not yet
an automatic check, unlike item 2's `hunter-off-marker`). `screenshot.gd`
already had the building block for this (`_report_visibility`'s `VIS`
line: `Camera3D.is_position_behind` + `unproject_position` against a
hunter's `home`), but only for one frozen `state=` shot — never run
continuously across a real fight, which is exactly the gap `playtest.gd`
exists to close (see the file's own header: "screenshot.gd checks one
frozen moment... Nick's bugs live in neither").

Added check 9 to `_check()`: after every step settles (not mid-hop — the
hop's own mid-flight transient is a separate, already-documented gap, see
item 3/4's history below), read the ACTIVE hunter's `home` position and
ask the live camera the same two questions `_report_visibility` asks for
one frame: is it behind the camera at all (`hunter-behind-camera` — would
mean the camera is looking somewhere else entirely, never expected), and
does it project inside the full viewport (`hunter-offscreen` — no HUD-
safe-region trim like `screenshot.gd`'s tighter check, deliberately, so
this doesn't re-flag the already-known "tiny near the edge" framing gap as
a new failure; only genuinely NOT on screen counts).

Smoke-tested first at 15 steps (2 real climbs) before committing to a full
run — 0 fails, so no obvious false-positive problem. Then shook it out
properly: full 80-step **play**, **hover**, and **hands** runs, all clean,
0 fails on every check including the two new ones. The 80-step run alone
crossed five real climbs (foot 0→4, 4→6, 8→10, 12→16, and a boss-hit fall
10→4) plus the sigil approach — every one of those settled states had the
active hunter genuinely on screen once the camera caught up, not just
"passed by luck." That's a real result for item 4, not a null one: the
settled-state framing holds up across a full fight; only the mid-hop
transient (documented below) is the open gap.

Two frames, same check, different framing to make the "on screen" claim
legible rather than take my word for the numbers:

![[frames/playtester/2026-09-23-camera-check-step43-sigil.png]]
Step 43 (after a Leap to foothold 16, near the sigil) — the Frog reads
clearly, comfortably inside frame. This is the check passing on an easy
case.

![[frames/playtester/2026-09-23-camera-check-step1-tiny-known-gap.png]]
Step 1 (right after the very first ground climb) — the Frog is small and
mostly eclipsed by the jackal's own jaw, only its eyes and the top of its
head clearing the hand row. This is the check passing on the HARD case:
the projected point is still technically inside the viewport, so no fail
fires, but a human eye would call this "barely readable," matching what
the last two runs already logged as the known gap ("tiny/off-screen-edge
for most of a climb," "Nick's third-person target still pending"). Worth
being honest that this check's bar (on screen at all) is looser than
"reads clearly" — it catches a camera looking at the wrong thing entirely,
not a merely-small hunter. Filing that gap again here would just be a
third copy of a finding the board already has; not doing that.

No new requests filed — nothing failed, and the framing gap this run's new
check bumps into is the same one already on record (this note's own `##
Next`, and item 4's history), not a new finding.

## Old: 2026-09-22, hop slow-mo + correction

Ran the full baseline first, unmodified `playtest.gd`, against that day's
tip (the artist's arena recolour, the fixer's relic-pool write-up, no
fixer code changes landed since the last baseline): **play** (80 steps,
deterministic seed, boss to 0 HP) came back with **2 failing checks** —
`hop-flat` (step 11) and `hop-no-squash` (step 63) — the first non-clean
baseline this fight had had. Both captures had exactly **2 in-flight
samples**, which passed the existing `covered_from_start` confidence gate
by chance — not nearly enough to trust for finding an apex or a squash
peak, the same sampling-is-too-sparse problem the run before's `## Next`
already named. Correctly did not take either at face value; wrongly
guessed (see the correction below) that sparse sampling was the WHOLE
story for both, and went looking for a way to sample more before filing
anything, per "proof or it did not happen."

Picked up option (a) from that `## Next` list: slow the capture window down
so a 0.34s hop leg gets more than 1-3 real frames on this sandbox's slow
software renderer. `Engine.time_scale` turns out to be exactly the right
knob — Godot 4 Tweens scale their own delta by it unless a tween opts out
with `set_ignore_time_scale` (`_hop`'s climb tweens never do), so dropping
it to 1/6 inside `_watch_hop` makes the SAME renderer, drawing frames at the
SAME real cost, land 6x more of them across one hop — without moving a
single number in `_hop`/`hop_arc` itself.

That first pass at the fix shipped its own false positive, caught the same
way: read the numbers instead of trusting a clean run. `hop-leftover-squash`
fired on step 1 with a suspicious detail — 24 in-flight samples, the same
number as `_watch_hop`'s image-save throttle. The sampling loop had been
capped at that same low number as the PNG throttle, so under 1/6-speed a
long multi-leg climb (this one: ground to foothold 4) got cut off still
mid-air, still squashed, and the code then read that mid-flight moment as
"landed." Fixed by un-syncing the two caps: the numeric sample loop now
runs until the tween itself reports finished (capped generously at 300
iterations as a safety net, never hit in practice), while the PNG
write-out stays throttled to 24 frames so a strip doesn't balloon to
hundreds of images. Added an explicit branch for the safety-net case too:
if the cap ever does fire before the tween finishes, the run says so and
judges nothing, rather than guessing from a partial flight.

**Correction, same run:** the two runs above happened in a private tree
that hadn't pulled `origin/main` since before this run started. Pulling
before writing this up surfaced that the fixer had, concurrently, run the
SAME stock baseline in a separate sandbox, hit the SAME `hop-flat` failure
(their run: steps 1 and 17; mine: step 11 — different step numbers, since
which climb a slow render happens to sample "confidently" varies with
real wall-clock frame timing even on the same deterministic seed, but the
same underlying cause), and traced it to a real bug:
`Combat3D.hop_arc()`'s old apex-height formula
(`lerp(from, to, 0.58).y + hop`) leaves the apex BELOW the landing on any
climb whose own vertical span exceeds the capped `hop` height — a real
"reads as a slide, not a jump," provable with a plain call to `hop_arc()`
and nothing to do with sample count. Fixed properly (apex height =
`maxf(from.y, to.y) + hop`) and pinned with two new pure-function tests in
`run_tests.gd`, commit `25804f3`. **My "it's just 2-sample under-sampling"
guess for `hop-flat` was wrong** — sparse sampling was real and did make
the capture unreliable, but the failure it happened to catch was a
genuine, always-reproducing bug, not a phantom. Re-ran the identical
80-step sequence with BOTH fixes (the fixer's `hop_arc` fix, already on
`origin/main`, plus my own slow-mo capture) after pulling: **all checks
passed**, step 17's climb (the same 8.99→~18.1 span) now peaks at 19.56 —
above both endpoints, matching the fixer's fix exactly — with the richest
capture yet, 72 in-flight samples. `hop-no-squash`, by contrast, never
recurred across any richly-sampled run under either version of `hop_arc`
(pre- or post-fix) — every subsequent capture, including several with
similar geometry, showed a real squash deviation (0.09-0.22) — so that one
genuinely does look like plain under-sampling, unlike its neighbour.

The honest lesson: I had real evidence (2-sample "confident" captures
failing) and a real fix in hand (more samples) that happened to also make
the failures go away, and almost wrote that up as "confirmed: both were
just sparse sampling" without checking whether a real bug could produce
the exact same 2-sample symptom. It could, and did, for one of the two. The
fixer's independent, code-level repro (a plain function call, no
rendering, no sampling at all) is what actually settles a question like
this, not a live run coming back clean. Filed nothing new — this bug was
already fixed and closed on the fixer's side.

Full baseline after both fixes, all three modes: **play** (80 steps) 0
fails, **hover** 0 flips, **hands** (1-10) 0 fails.

Frames: `design/agents/frames/playtester/2026-09-22-hop-strip-v2-step17.png`
(4 frames from the richest capture, 72 in-flight samples, peak y 19.56 —
the Goblin Engineer approaching the sigil from off-screen) and
`2026-09-22-hop-landed-v2-step17.png` (the settled frame right after).

No new requests filed. `ALL TESTS PASSED` throughout.

## Next

Both threads from this run resolved without needing a fresh playtester
request: foothold-4's residual is the fixer's own
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`
(watch for it going `done`, then re-run the baseline to confirm check 8
finally goes clean at foothold 4 for BOTH hunters sharing it); `hop-flat`'s
false-fire was my own check's confidence gate, fixed and verified in
`playtest.gd` this run (`MIN_HOP_SAMPLES`).

Once foothold-4 is fully closed, worth a fresh pass on items 3 and 4
overall: `a823001` (Nick's own jump/camera rebuild, now two runs back)
still hasn't had a frame-strip look at anything OTHER than the two bugs it
turned up — the numeric checks passing everywhere else in this run doesn't
mean the squash/arc/camera framing actually reads well at typical (non-
sigil, non-foothold-4) climbs, just that nothing failed. The off-screen
damage-number finding from two runs ago is also still open, still waiting
on the fixer: once they know the real cause (my guess — an in-flight camera
transition, unconfirmed — is in the request), decide whether it deserves
its own automatic check (a visibility-aware version of check 10) or folds
into whatever item 4 eventually becomes once the third-person camera
lands. Item 4 itself is otherwise unchanged: check 9 can tell "on screen"
from "not," not "small" from "clearly framed." Also still open: a way to
catch a squash-arc or framing failure the numeric checks would miss but a
human eye would catch — the frame strips remain the backstop for that;
keep saving them.

## Old-Next: superseded by the two-item list above

The live thread is the foothold-4 float: once the fixer knows which of
`_front_of_beast` / `_stand_on_model` / `stone_point` is actually wrong,
decide whether check 8's tolerance needs widening for `stone_point`'s own
push (a calibration fix) on top of whatever position fix lands (a real
bug fix) — those are two separate things and both may be needed. Also
worth a fresh pass on items 3 and 4 once that lands: `a823001` rewrote
the hop arc/anticipation/landing squash AND the jump-framing camera in
the same commit that introduced this regression, and neither got a
frame-strip look this run — the numeric checks (hop-flat/hop-no-squash,
camera check 9) came back clean, but item 3's own history shows a clean
numeric pass has missed a real bug before (the pre-fix `hop_arc` case);
worth watching, not assuming fine. The off-screen damage-number finding
from last run is still open too, still waiting on the fixer: once they
know the real cause (my guess — an in-flight camera transition, unconfirmed
— is in the request), decide whether it deserves its own automatic check
(a visibility-aware version of check 10) or folds into whatever item 4
eventually becomes once the third-person camera lands. Item 4 itself is
otherwise unchanged: check 9 can tell "on screen" from "not," not "small"
from "clearly framed," and that same blind spot is arguably why this run's
new finding wasn't caught by check 9 in the first place (a Label3D isn't a
hunter, so check 9 never looked at it) — worth remembering these are
two symptoms of one still-open camera gap, not two unrelated bugs. Item 3
is unchanged this run — its own remaining gap (very short single-leg hops
finishing before `_watch_hop` starts slowing things down) still stands.
Also still open: a way to catch a squash-arc or framing failure the
numeric checks would miss but a human eye would catch — the frame strips
remain the backstop for that; keep saving them.

## Log

- 2026-09-23 — full three-mode baseline: `hover`/`hands` clean, `play`
  (80 steps) 3 fails, all `hunter-off-marker` at foothold 4 matching the
  fixer's own still-open, untaken shared-foothold-spacing request exactly —
  unchanged, no regression. No `script-error` (the intermittent End Turn
  crash, also still open and untaken, did not reproduce this run either —
  not treated as proof it's gone). Picked up checklist item 1's remaining
  gap flagged in my own last two runs' `## Next`: the fixer took and fixed
  `hunter-damage-popup-offscreen` (`9653ecc`, `Combat3D.popup_move_reach`)
  since my last run — verified it live in this run's clean baseline (0
  fails across 5 real hp-loss events), then added the visibility-aware
  follow-up check itself, `damage-popup-offscreen` in `playtest.gd`: every
  live popup's on-screen projection is now checked every frame across its
  whole life (not just at spawn, since the real bug was a popup that
  started ON screen and rose OFF it). Proved both directions — clean on the
  real fix, and exactly 3 FAILs (matching the fixer's own before-fix
  numbers) when I temporarily reverted their fix in `combat_3d.gd` to
  reproduce the old bug, confirmed by eye against the frame, then cleanly
  reverted the break before re-running `run_tests.gd` and a final clean
  80-step baseline. No new bugs found; nothing new filed this run.
- 2026-09-23 — first full three-mode baseline clean (0 fails/flips
  everywhere). Extended `playtest.gd`'s `_watch_hop` with a mid-hop
  camera-visibility check (`hunter-lost-mid-hop`, checklist item 4's
  "including mid-jump" half, which the existing settled-state check
  explicitly skips) — proved it both directions (0% off across all sampled
  hops in three separate runs; a deliberate break correctly produced a
  100%-off FAIL, reverted). A follow-up baseline run with the finished check
  surfaced a real, if intermittent, engine crash unrelated to my own
  change: `_apply_orbit` (combat_3d.gd:2208) calls `_cam.look_at` after
  `_cam` is no longer in the tree, during `_end_turn` →
  `_apply_solo_turn_flip` → `_focus_camera`, killing the whole game view
  (one crash in three otherwise-identical 80-step runs — a timing/race
  signature). Filed `to: fixer`, priority high,
  `2026-09-23-1000-playtester-to-fixer-end-turn-crash-at-sigil-solo-flip.md`,
  with the stack trace and the frame right before it. Also did the
  human-eye frame-strip look on items 3/4 flagged as overdue for several
  runs: a typical non-sigil ground climb (step 0) shows real motion/arc by
  eye, no new bug; re-confirmed (not re-filed) the already-known "tiny near
  the sigil" camera gap by eye against the new check's own clean verdict.
  `run_tests.gd`: `ALL TESTS PASSED` throughout.
- 2026-09-23 — verified the fixer's `c8e965b` (`stand_z_for`) against a
  fresh full three-mode baseline: `hover`/`hands` clean, `play` (80 steps)
  2 failing checks. `hunter-off-marker` at foothold 4 is a real, large
  improvement over the pre-fix baseline (open-air float, `home.z` 10.25 →
  7.03, right next to the anchor) but still fails 4x on a smaller residual
  x-miss (1.43 vs 1.06 tolerance). Had a follow-up drafted when a mid-run
  `git fetch` turned up the fixer's own `4c15649`, closing the original
  request and self-filing the exact same residual with a deeper diagnosis
  (two hunters sharing foothold 4, `stand_offset_x`'s spacing too wide for
  the jackal's narrow ear) — deleted my draft, nothing to add. Also found a
  NEW `hop-flat` failure, 2x near the sigil (steps 49/50), both captures
  reporting a peak sitting exactly at the start height despite passing the
  confidence gate; the same `git fetch` showed the fixer independently hit
  the same shape at a THIRD set of steps in their own run and called it a
  likely sampling flake — different failing steps every run is the
  signature of a sampling gap, not a reproducible geometry bug, so chased
  it myself instead of filing it. Found the real hole: `covered_from_start`'s
  `total_dist < 0.05` bypass doesn't verify temporal coverage, so a
  near-zero-distance climb (footholds compressing near the sigil) can pass
  the gate on as few as 4-5 real samples. Fixed in `playtest.gd`
  (`MIN_HOP_SAMPLES := 10`, AND'd into the existing gate — strictly
  conservative, can only reduce false fails, never mask a real one).
  Verified against this run's own report.md (real climbs: 25-120 samples;
  degenerate ones: 4-6 — clean separation) AND with a fresh `steps=51`
  re-run: `hop-flat`/`hop-no-squash` gone, only `hunter-off-marker: 2`
  left, and the well-sampled real climbs (120, 26 samples) still get
  judged normally. `run_tests.gd`: `ALL TESTS PASSED`. Local `main` branch
  in this sandbox shares no merge-base with `origin/main` (a stale ref
  from container init, predating some history rewrite on the remote) —
  worked from `origin/main` directly rather than force-resetting the
  branch ref without asking; pushing straight to `origin/main` from a
  detached HEAD.
- 2026-09-23 — full three-mode baseline against today's tip (now including
  Nick's own `a823001` jump/camera rebuild): `hover` and `hands` clean, but
  `play` (80 steps) regressed — `hunter-off-marker` (check 8) failed 3x
  (steps 34, 35, 71), all three at foothold 4 with identical `home`
  coordinates across two different hunters reaching it by different climb
  paths (deterministic, not a flake). The frame shows a hunter floating in
  open air off the jackal's body entirely, no stone or surface under it —
  the exact "floating beside the body" failure checklist item 2 exists to
  catch, not just a tolerance miss. Traced (unconfirmed) to `a823001`
  changing `_stand_on_model` to wrap its point in `stone_point(...)`
  directly, which check 8's own x-tolerance was never widened for, plus a
  suspicion `_front_of_beast`'s clearance is oversized at foothold 4's
  rung specifically. Did not touch any of the three functions — filed
  `to: fixer`, priority high,
  `2026-09-23-0900-playtester-to-fixer-hunter-floats-off-model-at-foothold-4.md`,
  with both frames and the exact repro. `run_tests.gd`: `ALL TESTS
  PASSED` (a live-placement bug, not one a pure unit test would catch).
- 2026-09-23 — checklist item 1: added check 10 to `playtest.gd`
  (`damage-popup-missing`) — real damage (boss hp down or the active
  hunter's hp down) must show a `Combat3D._damage_popup` `Label3D` under
  `_rig` that same step, polled every frame the step is still resolving
  (folded into `_play()`'s existing wait loops, so it costs nothing
  extra) rather than screenshotted once, since the popup's own ~1.7s
  lifetime is too short to trust a single frozen shot on this sandbox's
  slow renderer. Proved both ways: 0 fails across a full 80-step run (5
  real hp-loss events, all correctly seen) AND a deliberate break
  (`if false and child is Label3D`) correctly produced exactly one
  `damage-popup-missing` FAIL before being reverted. Full three-mode
  baseline (play/hover/hands) clean before and after, `ALL TESTS PASSED`
  throughout. Along the way, found and filed a real bug: every sampled
  hunter-damage popup this run rendered above the top of the viewport
  (screen y -99 to -604), confirmed with `unproject_position` against
  the live camera and two frames — `to: fixer`,
  `2026-09-23-0430-playtester-to-fixer-hunter-damage-popup-offscreen.md`.
  Not fixed (not my job); the shipped check itself checks existence only,
  by design, so this finding does not make it flaky.
- 2026-09-23 — checklist item 4: added check 9 to `playtest.gd`
  (`hunter-behind-camera` / `hunter-offscreen`) — the active hunter must be
  on screen once a step has settled, using the same `Camera3D` API
  `screenshot.gd`'s `_report_visibility` already used for one frozen frame,
  now run continuously across a real fight. Full three-mode baseline run
  twice (before and after, unmodified vs. with the new check): both clean,
  0 fails, no regressions from the artist's `goblin_mech` pass 3. The new
  check itself found no bug — confirms settled-state framing holds across
  five real climbs and the sigil approach in one 80-step run — but stayed
  deliberately loose (on-screen-at-all, not "reads clearly") so it doesn't
  re-flag the already-known near-edge/tiny framing gap, shown honestly in
  the step-1 frame rather than hidden. No new requests filed.
- 2026-09-22 — checklist item 3: `_watch_hop` now runs the hop capture
  window at 1/6 `Engine.time_scale`, turning 0-12 real in-flight samples per
  climb into 12-75. The pre-existing baseline's `hop-flat` turned out to be
  a real bug in `Combat3D.hop_arc()` (apex landing below a tall climb's own
  endpoints) — found and fixed independently by the fixer (commit
  `25804f3`) with a pure-function repro while I was still (wrongly)
  chasing it as a sampling artifact; `hop-no-squash` from the same baseline
  WAS plain under-sampling, confirmed gone once fully sampled. My own first
  draft of the slow-mo fix shipped its own false positive
  (`hop-leftover-squash`, a sample cap that silently truncated a long
  multi-leg climb mid-flight and read it as landed) — caught and fixed by
  uncoupling the numeric sample cap from the PNG-save throttle and
  refusing to judge a hop the loop didn't actually see finish. Full
  three-mode baseline clean with both fixes merged. No new bugs to file —
  see `## Old` above for the full trail, correction included.
- 2026-09-22 — checklist item 3: added `_watch_hop`/`_check_hop` to
  `playtest.gd` (hop-flat / hop-no-squash / hop-leftover-squash), gated on
  a `covered_from_start` confidence check after an early version false-
  failed on this sandbox's slow rendering; re-ran full baseline first (no
  regressions from today's three fixer fixes), then a 20/40/80-step run to
  shake the new checks out. 0 fails, one confidently-sampled climb proved
  real arc + real squash by the numbers. No new requests filed.
- 2026-09-22 — first baseline run: all three playtest modes clean (0
  fails), added the `hunter-off-marker` check (playtest.gd check 8), no
  bugs found so no new requests filed. See the baseline request's
  `## Result` for full detail.
- 2026-09-22 — note created by the session.
</content>
