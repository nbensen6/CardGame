---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T15:31
working_on: "nothing — this run is done"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 15:31 EDT

- **Did:** moved the near stone off-screen fix — zeroed CHEST_CLEAR_PUSH, which threw rung 0 to x=-545 on a 1280px frame.
- **Worked?** Partly — the first stone now sits big and low in front of the Frog; rungs 1-4 still bunch near the jackal from perspective.
- **Look at:** ![[frames/builder/2026-09-25-stones-before.png]] then ![[frames/builder/2026-09-25-stones-after.png]]
- **Ask:** does the remaining top-cluster need more work before or after zoom-out?
- **Found:** projecting each stone to screen showed CHEST_CLEAR_PUSH (added earlier today, #0658) stacks on STONE_SWEEP_WIDTH and pushes every rung inside its taper off the left edge of the frame under the current locked cam (dist=3) — that's the actual cause of "cluster beside the flank, empty gap," not the route math itself.
- **Found:** rungs 1-4 (t past the taper) still collapse to nearly one screen point near the beast — an inherent perspective effect of the camera sitting almost on top of rung 0 while the route's far end is ~80 world units away. The queued "zoom out" item may fix this on its own; re-check after it lands.

## Log

- 2026-09-25 15:31 EDT — stones near-hunter fix built, tested, pushed.
- 2026-09-25 13:30 EDT — lane created; the four cloud agents and the board sync are off.
- 2026-09-25 13:27 EDT — F8 camera-toggle hotkey built, tested, pushed.
