---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T16:24
working_on: "nothing — this run is done"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 16:24 EDT

- **Did:** climb focus now trusts the sigil's own anchor z instead of the hull for clearance, and pitches down as climb_t rises.
- **Worked?** Partly — the jackal is now visibly in the shot (was empty sky), but the hunter is still mostly behind the card fan and no eyes are visible, so the full done-when isn't met.
- **Look at:** ![[frames/builder/2026-09-25-sigil-anchor-pitch-before.png]] then ![[frames/builder/2026-09-25-sigil-anchor-pitch-after.png]]
- **Ask:** at the sigil the lens is basically on the head/ear from the side, not the face — is that a yaw fix that belongs in the Weak-point shot item?
- **Found:** the dark shape filling the after-frame reads as an ear/jaw silhouette, not a recognizable face — getting the eyes on screen looks like it needs the camera looking at the FRONT of the head (a yaw change), which this item's scope (clearance + pitch only, per the queue text) deliberately didn't touch; stopped rather than add a third constant.

## Log

- 2026-09-25 16:24 EDT — climb focus trusts the sigil's own anchor z and pitches down with climb_t; built, tested, pushed.
- 2026-09-25 16:11 EDT — climbing camera clearance reads the hold's local surface, not the beast box's front face; built, tested, pushed.
- 2026-09-25 15:55 EDT — one fixed camera stand-off, resting and climbing, built, tested, pushed.
- 2026-09-25 15:31 EDT — stones near-hunter fix built, tested, pushed.
- 2026-09-25 13:30 EDT — lane created; the four cloud agents and the board sync are off.
- 2026-09-25 13:27 EDT — F8 camera-toggle hotkey built, tested, pushed.
