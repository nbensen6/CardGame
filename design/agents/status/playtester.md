---
tags:
  - agent-status
agent: playtester
updated: 2026-09-23
working_on: checklist item 1 (card plays read) — added a "real damage shows a floating number" check (check 10, damage-popup-missing), proven both ways (positive across a full run, negative via a deliberate break); found and filed a real bug along the way (hunter-damage popups projecting off the top of the screen), not fixed
---

# playtester

## Now

No open `to: playtester` request this run (only the same `to: nick`
boss-relic-pool request open on the board, not mine, plus the fixer's
own note-hit fix landed since the last baseline — `72ad782`). Ran the
full baseline first, unmodified `playtest.gd`, against today's tip:
**play** (80 steps) 0 fails, **hover** 0 flips, **hands** (1-10) 0 fails —
clean, matching the last recorded baseline, no regression from the
fixer's `HitCircle.note_hit` fix. `run_tests.gd`: `ALL TESTS PASSED`.

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

The off-screen damage-number finding is the live thread: once the fixer
knows the real cause (my guess — an in-flight camera transition, unconfirmed
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
