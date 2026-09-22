---
tags:
  - agent-status
agent: playtester
updated: 2026-09-22
working_on: hop sampling now runs in slow motion (checklist item 3) — two false positives found and killed before shipping, 0 real bugs this run
---

# playtester

## Now

Ran the full baseline first, unmodified `playtest.gd`, against today's tip
(the artist's arena recolour, the fixer's relic-pool write-up, no fixer code
changes landed since the last baseline): **play** (80 steps, deterministic
seed, boss to 0 HP) came back with **2 failing checks** —
`hop-flat` (step 11) and `hop-no-squash` (step 63) — the first non-clean
baseline this fight has had. Before filing anything, read the actual
capture behind both: each had exactly **2 in-flight samples**, and both
happened to pass the existing `covered_from_start` confidence gate by
chance. Two samples is not enough to find an apex or a squash peak in
either direction — this is the same sampling-is-too-sparse problem the
last run's `## Next` already named, now caught actually misfiring instead
of just silently under-covering. Did not file either as a game bug without
first ruling out the bot's own sampling, per "proof or it did not happen."

Picked up option (a) from that `## Next` list: slow the capture window down
so a 0.34s hop leg gets more than 1-3 real frames on this sandbox's slow
software renderer. `Engine.time_scale` turns out to be exactly the right
knob — Godot 4 Tweens scale their own delta by it unless a tween opts out
with `set_ignore_time_scale` (`_hop`'s climb tweens never do), so dropping
it to 1/6 inside `_watch_hop` makes the SAME renderer, drawing frames at the
SAME real cost, land 6x more of them across one hop — without moving a
single number in `_hop`/`hop_arc` itself. Re-ran the identical 80-step
sequence (the seed is fixed, so it's the same climbs step-for-step): both
prior failures gone, and every hop that had previously scraped by on 2-3
samples now landed 12-75. Confirms both were exactly what they looked like
— under-sampling, not a real flat hop or a real missing squash.

That first pass at the fix shipped its own false positive, though, and I
caught it the same way: read the numbers instead of trusting a clean run.
`hop-leftover-squash` fired on step 1 with a suspicious detail — 24
in-flight samples, the same number as `_watch_hop`'s image-save throttle.
The sampling loop had been capped at that same low number as the PNG
throttle, so under 1/6-speed a long multi-leg climb (this one: ground to
foothold 4) got cut off still mid-air, still squashed, and the code then
read that mid-flight moment as "landed." Fixed by un-syncing the two caps:
the numeric sample loop now runs until the tween itself reports finished
(capped generously at 300 iterations as a safety net, never hit in
practice), while the PNG write-out stays throttled to 24 frames so a strip
doesn't balloon to hundreds of images. Added an explicit branch for the
safety-net case too: if the cap ever does fire before the tween finishes,
the run says so and judges nothing, rather than guessing from a
partial flight. Re-ran the same 80 steps a third time: **all checks
passed**, richest capture yet (up to 75 in-flight samples on the step-17
sigil climb), no false anything.

Full baseline after the fix, all three modes: **play** (80 steps) 0 fails,
**hover** 0 flips, **hands** (1-10) 0 fails.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | ok |
| 2 | hunters land on the beast correctly | ok (check 8, `hunter-off-marker`, 0 fails) |
| 3 | jump animation (squash/arc/landing) | **substantially more checkable now** — same 3 automatic checks, but hops now sample 3-75 real frames each (was 0-12) via a slow-motion capture window (`Engine.time_scale`, `HOP_TIME_SCALE = 1/6`), and two real sampling-artifact false positives (one pre-existing, one introduced by my own first attempt at this fix) are gone. Still not every climb: a handful of very short single-leg hops finish before `_watch_hop` even starts watching (the click → timed-card-minigame → pick-selection prelude before the watch loop runs at NORMAL speed, so slow-mo starting only inside `_watch_hop` is sometimes too late) — logged honestly as "too fast," never silently skipped. |
| 4 | camera | partially checkable, ok so far; over-the-shoulder target still pending (Nick's, not a bug). Tried to get a clean visual (not just numeric) confirmation of a slow-mo'd hop this run and mostly couldn't — the current wide establishing camera keeps the climbing hunter tiny/off-screen-edge for most of a climb (step 17's strip below shows the Goblin Engineer entering from off-frame, barely readable at native size). Not a new finding, same gap this item already names. |
| 5 | nothing errors | ok |

Frames: `design/agents/frames/playtester/2026-09-22-hop-strip-v2-step17.png`
(4 frames from the richest capture this run, 75 in-flight samples, the
Goblin Engineer approaching the sigil from off-screen — read individual
frames at 1:1 before scaling this strip down for the note) and
`2026-09-22-hop-landed-v2-step17.png` (the settled frame right after, full
resolution).

No new requests filed — the only two "failures" this run were the bot's
own sampling catching up to itself, killed before either reached a
request file. `ALL TESTS PASSED` on `run_tests.gd` throughout (this is bot
behavior, not a unit under test).

## Next

Checklist item 3 is close to "ok" but not quite: the remaining honest gap
is the handful of very short single-leg hops that finish during the
normal-speed prelude (click → timed-card minigame → pick-selection loop)
before `_watch_hop` ever starts slowing things down — logged as "too fast,"
never silently skipped, same as before, just a smaller set of them now.
Closing that fully means starting the slow-mo earlier (around the click
itself, or specifically around whichever part of card resolution triggers
`_hop`), which risks slowing down non-climb actions and timed-card
minigames too — didn't attempt it this run; worth scoping carefully next
time rather than reaching for a blanket "slow the whole step down," which
would multiply this sandbox's already-slow render time across all 80 steps
for little gain on the (mostly non-climbing) majority of them. Also still
open: checklist item 4 (camera) once the fixer/artist have more to show
there — this run's attempt to get a clean VISUAL (not just numeric)
confirmation of a slow-mo'd hop mostly failed on the current wide camera,
which is the same gap this item already names, not a new one. And finding
a way to catch a squash-arc failure the numeric checks would miss but a
human eye would catch (the frame strips are the backstop for that — keep
saving them).

## Log

- 2026-09-22 — checklist item 3: `_watch_hop` now runs the hop capture
  window at 1/6 `Engine.time_scale`, turning 0-12 real in-flight samples
  per climb into 3-75. Caught and killed two false positives before
  shipping: the pre-existing baseline's `hop-flat`/`hop-no-squash` (both
  were 2-sample under-sampling, confirmed gone once fully sampled) and one
  introduced by my own first draft of this fix (`hop-leftover-squash` from
  a sample cap that silently truncated a long multi-leg climb mid-flight
  and read it as landed — fixed by uncoupling the numeric sample cap from
  the PNG-save throttle and refusing to judge a hop the loop didn't
  actually see finish). Full three-mode baseline clean after the fix. No
  bugs to file — see `## Now` for the full trail.
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
