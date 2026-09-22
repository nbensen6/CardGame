---
tags:
  - agent-status
agent: playtester
updated: 2026-09-22
working_on: first baseline done — no bugs found this run
---

# playtester

## Now

Finished `requests/2026-09-22-1700-session-to-playtester-first-baseline.md`.
Ran all three `playtest.gd` modes against Cinder Jackal (fresh Godot 4.7.1
+ Xvfb/llvmpipe sandbox): **play** (80 steps, foothold 0→16, boss to 0 HP),
**hover** (worst 0 flips), **hands** (sizes 1-10). All three: **0 failing
checks**. Full detail and the checklist table are in the request's
`## Result` — not duplicating it here.

Added a new check to `game/tools/playtest.gd` (check 8,
`hunter-off-marker`, the suggested "hunters land within reach of a climb
marker after every climb" check): after every action, a hunter mid-climb
must sit at the model's real `climb_N` anchor for their Height (exact on
y, within the game's own side-offset on x), not the bounding-box fallback
a beast with no exported anchors would fall into. It ran clean across
every climb this run — Cinder Jackal's anchors are good — but it's now a
standing regression guard for the next beast. `ALL TESTS PASSED`.

Checklist snapshot (baseline, first run so nothing to diff against yet):

| # | item | state |
|---|---|---|
| 1 | card plays read | ok |
| 2 | hunters land on the beast correctly | ok (new check added, 0 fails) |
| 3 | jump animation (squash/arc/landing) | not yet checkable |
| 4 | camera | partially checkable, ok so far; over-the-shoulder target still pending (Nick's, not a bug) |
| 5 | nothing errors | ok |

Frames: `design/agents/frames/playtester/2026-09-22-baseline-*.png` (sigil
close-up with both hunters, a mid-climb, a 10-card hand fan) — all read at
1:1, nothing flagged.

No new requests filed this run — nothing broke.

## Next

Checklist item 3 (jump animation) is the biggest gap: playtest.gd only
captures one settled frame per step, so it can't see the hop itself. Next
run: extend playtest.gd (or a new tool) to grab a frame-strip mid-hop
(every few frames across one climb action) and tile it, then judge
anticipation/arc/landing squash and add an automatic check if a clean one
exists (e.g. no frame-to-frame position jump larger than X during a hop —
mentioned as an example in the brief). Otherwise: take the next open
`to: playtester` request, or go deeper on checklist item 4 (camera
framing) once the fixer/artist have more to show there.

## Log

- 2026-09-22 — first baseline run: all three playtest modes clean (0
  fails), added the `hunter-off-marker` check (playtest.gd check 8), no
  bugs found so no new requests filed. See the baseline request's
  `## Result` for full detail.
- 2026-09-22 — note created by the session.
