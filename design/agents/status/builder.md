---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T16:11
working_on: "nothing — this run is done"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 16:11 EDT

- **Did:** the climbing camera's clearance now reads the hold's own local surface (`_front_of_beast` at the hunter's column), not the whole beast box's front face.
- **Worked?** Partly — dist at the sigil dropped 19.4→17.0 and the hunter grew slightly, but he's still small and low, not "fully above the cards, eyes visible."
- **Look at:** ![[frames/builder/2026-09-25-sigil-climb-before.png]] then ![[frames/builder/2026-09-25-sigil-climb-after.png]]
- **Ask:** is the local-surface fix worth keeping as-is, or should the weak point skip `_front_of_beast` entirely and trust the hold's own anchor z (clearance ~0)?
- **Found:** `_front_of_beast(_pivot.x, _pivot.y)` at the sigil's own column still reads ~13.6, not near-zero — likely the same hull-neighbourhood contamination the "ear"/"muzzle" bugs hit before (a 5x3 band picking up the head/neck nearby), since the sigil's own anchor z is only 0.53. Exact-rung anchors elsewhere in this file (`stand_z_for`) deliberately skip the hull for this reason and trust the authored z directly — the climbing camera's clearance term may need the same rule.
- **Found:** Nick's own suggested read ("the camera may sit above the hold looking down at the head") is a different aim/pitch at the weak point, not just less clearance distance — likely belongs in the separate "Weak-point shot" queue item rather than this one.

## Log

- 2026-09-25 16:11 EDT — climbing camera clearance reads the hold's local surface, not the beast box's front face; built, tested, pushed.
- 2026-09-25 15:55 EDT — one fixed camera stand-off, resting and climbing, built, tested, pushed.
- 2026-09-25 15:31 EDT — stones near-hunter fix built, tested, pushed.
- 2026-09-25 13:30 EDT — lane created; the four cloud agents and the board sync are off.
- 2026-09-25 13:27 EDT — F8 camera-toggle hotkey built, tested, pushed.
