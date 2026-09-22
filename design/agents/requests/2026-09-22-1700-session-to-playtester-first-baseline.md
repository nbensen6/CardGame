---
tags:
  - request
from: session
to: playtester
status: done
priority: normal
created: 2026-09-22
taken_by: playtester
---

# First run: baseline the jackal fight

## What

Run all three playtest modes rendered, record the result in your status
note, then go through your five-item checklist once and record the state of
each (ok / bug filed / not yet checkable). File what you find. Add the first
new automatic check you think matters most (suggestion: hunters land within
reach of a climb marker after every climb).

## Done when

Your status note has the baseline table and at least one new check is in
playtest.gd.

## Result

Ran all three `playtest.gd` modes against Cinder Jackal on a fresh Godot
4.7.1 + Xvfb/llvmpipe sandbox (this run's the first real one — no prior
baseline to diff against, so nothing here is a regression by definition).
All three came back clean:

- `mode=play steps=80`: **0 failing checks**. 80 real actions (climbs,
  timed hits, Meld/pick selections, End Turns), foothold went 0 → 16 (past
  the Height-5 sigil, well into `FOOTHOLD_MAX` territory), boss HP 42 → 0.
  `report.md` / frames: `/tmp/pt_play` this run (not committed — the three
  frames below are the kept sample).
- `mode=hover`: **0 failing checks**, worst 0 flips for a still mouse
  (perfect — 0-1 is "correct").
- `mode=hands` (hand sizes 1-10): **0 failing checks**.

Checklist, this baseline:

| # | item | state |
|---|---|---|
| 1 | card plays read | **ok** — every play changed hand/energy/hp/foothold/turn (0 dead-click fails across 80 steps), hand stayed centred, never covered End Turn/Switch, at every hand size 1-10 |
| 2 | hunters land correctly on the beast | **ok** — 0 hunters-overlap fails; new check (below) found 0 off-marker placements across every climb from foothold 0 to 16 |
| 3 | jump animation (squash/arc/landing) | **not yet checkable** — playtest.gd only captures one settled frame per step, after the hop finishes. Needs a mid-hop frame-strip capture; noted as next work, not attempted this run |
| 4 | camera | **partially checkable, ok so far** — no HUD/hand element ever left the screen or got clipped. Whether framing is "good" (third-person over-the-shoulder, Nick's stated target) isn't automatable; watched several `step_*.png` by eye and it matches the documented current state (wide establishing shot, `_focus_camera` gradually closing in) — not a regression |
| 5 | nothing errors | **ok** — 0 script-error fails across all three modes |

New check added to `game/tools/playtest.gd` (check 8, `hunter-off-marker`):
after every action, any hunter mid-climb (foothold strictly between the
ground and the sigil) must sit within `_stand_on_model`'s own tolerance of
the model's real `climb_N` anchor for their Height — height (y) exact,
lateral (x) within the side-offset the game itself uses. Catches exactly
what checklist item 2 asks for ("hunters land within reach of a climb
marker after every climb") and the "floating beside/inside the body"
failure mode the README calls out (a beast with no exported anchors
silently falls back to a bounding-box guess). Found nothing wrong this run
— Cinder Jackal's anchors are good — but it's a real regression guard for
whichever beast gets built next. `ALL TESTS PASSED` on `run_tests.gd`
(unaffected — this is a new invariant in the bot, not a unit under test);
proven live by the 3 clean playtest runs above, which exercise it on every
one of the ~15 real climbs in the play run.

Frames kept: `design/agents/frames/playtester/2026-09-22-baseline-*.png`
(sigil close-up with both hunters, a mid-climb, a 10-card hand fan).

Commit: see this repo's `git log` for the playtest.gd change and this
write-up, pushed together.

### Frames

![[frames/playtester/2026-09-22-baseline-hands-step010-10card.png]]
![[frames/playtester/2026-09-22-baseline-play-step002-climb.png]]
![[frames/playtester/2026-09-22-baseline-play-step020-sigil.png]]
