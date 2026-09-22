---
tags:
  - agent-status
agent: playtester
updated: 2026-09-22
working_on: hop sampling now runs in slow motion (checklist item 3) — richer sampling helped confirm the fixer's independent hop_arc fix, killed one own false positive, no new bugs to file
---

# playtester

## Now

Ran the full baseline first, unmodified `playtest.gd`, against today's tip
(the artist's arena recolour, the fixer's relic-pool write-up, no fixer code
changes landed since the last baseline): **play** (80 steps, deterministic
seed, boss to 0 HP) came back with **2 failing checks** —
`hop-flat` (step 11) and `hop-no-squash` (step 63) — the first non-clean
baseline this fight has had. Both captures had exactly **2 in-flight
samples**, which passed the existing `covered_from_start` confidence gate
by chance — not nearly enough to trust for finding an apex or a squash
peak, the same sampling-is-too-sparse problem the last run's `## Next`
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
this, not a live run coming back clean. Filed nothing new — this bug is
already fixed and closed on the fixer's side.

Full baseline after both fixes, all three modes: **play** (80 steps) 0
fails, **hover** 0 flips, **hands** (1-10) 0 fails.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | ok |
| 2 | hunters land on the beast correctly | ok (check 8, `hunter-off-marker`, 0 fails) |
| 3 | jump animation (squash/arc/landing) | **substantially more checkable now** — same 3 automatic checks, but hops now sample 12-75 real frames each (was 0-12) via a slow-motion capture window (`Engine.time_scale`, `HOP_TIME_SCALE = 1/6`). One real bug this richer sampling helped surface (the fixer's `hop_arc` apex fix, commit `25804f3` — a real "reads as a slide" on tall single-leg climbs, NOT a sampling artifact, confirmed by their own pure-function repro) plus one genuine sampling-only false positive (`hop-no-squash`) are both gone, and one false positive my own first attempt at this fix introduced (`hop-leftover-squash`, a truncated-capture bug) was caught and killed before shipping. Still not every climb: a handful of very short single-leg hops finish before `_watch_hop` even starts watching (the click → timed-card-minigame → pick-selection prelude runs at NORMAL speed, so slow-mo starting only inside `_watch_hop` is sometimes too late) — logged honestly as "too fast," never silently skipped. |
| 4 | camera | partially checkable, ok so far; over-the-shoulder target still pending (Nick's, not a bug). Tried to get a clean visual (not just numeric) confirmation of a slow-mo'd hop this run and mostly couldn't — the current wide establishing camera keeps the climbing hunter tiny/off-screen-edge for most of a climb (step 17's strip below shows the Goblin Engineer entering from off-frame, barely readable at native size). Not a new finding, same gap this item already names. |
| 5 | nothing errors | ok |

Frames (from the final run, both fixes applied):
`design/agents/frames/playtester/2026-09-22-hop-strip-v2-step17.png`
(4 frames from the richest capture, 72 in-flight samples, peak y 19.56 —
the Goblin Engineer approaching the sigil from off-screen; read individual
frames at 1:1 before scaling this strip down for the note) and
`2026-09-22-hop-landed-v2-step17.png` (the settled frame right after, full
resolution).

No new requests filed — `hop-flat` was already fixed and closed on the
fixer's side by the time I'd confirmed it, and `hop-no-squash` and my own
`hop-leftover-squash` mistake were both bot-side sampling issues that never
needed a request. `ALL TESTS PASSED` on `run_tests.gd` throughout (this is
bot behavior, not a unit under test).

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
  see `## Now` for the full trail, correction included.
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
