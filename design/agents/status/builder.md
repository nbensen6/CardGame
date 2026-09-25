---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T18:27
working_on: "playtest.cmd green: hunter-off-marker fixed, 6 categories still red"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 18:27 EDT

- **Did:** fixed `hunter-off-marker`'s top-branch `side` (was the stale dynamic shared-foothold nudge, `_stand_on_model` has used the fixed per-hunter `route_side` there since the two-stones-sets change) and `_watch_hop`'s guard-cap bail, which used to return while a long multi-rung climb's tween was still running, leaving `home` mid-flight for every check that runs right after.
- **Worked?** Partly — `hunter-off-marker` is now 0 fails (was 2, confirmed on three separate `playtest.cmd` runs); `run_tests.gd` is `ALL TESTS PASSED`. The ticket's done-when is no FAIL at all, and 6 other categories are still red (see queue), so this stays `[?]`, not closed.
- **Look at:** no frame — this item's shot is `none`, the proof is `playtest.cmd`'s own FAIL count (7 categories → 6, `hunter-off-marker` gone).
- **Ask:** is `camera-not-over-shoulder`'s 0.95 threshold and `_shoulder`'s 2.2/s ease rate a design pair I can retune, or is that Nick's call like the other camera flips have been?
- **Found:** the remaining 6 categories, one line each, at the bottom of the queue — `camera-not-over-shoulder`'s own timing math, `beast-behind-stone`'s CHEST_CLEAR_PUSH trade-off, and three more that need a dedicated look.

## Log

- 2026-09-25 18:27 EDT — builder: playtest.cmd green -- fixed hunter-off-marker's stale side + a guard-cap bail that read `home` mid-tween; 7 failing categories down to 6; built, tested, pushed.
- 2026-09-25 18:02 EDT — builder: investigated weak-point-shot Switch behaviour, already correct in every path tried, no change shipped, item left open.
- 2026-09-25 17:52 EDT — builder: playtest's own top-hold z now hull-corrected like the real route, not the raw anchor; tested, pushed.
- 2026-09-25 17:41 EDT — builder: goblin trim (boots/shorts/strap/ear) recoloured to one muted rust, baked into goblin_mech_ai.glb's embedded texture; built, tested, pushed.
- 2026-09-25 17:26 EDT — builder: ground hunters face the beast, backs to camera, not the camera itself; built, tested, pushed.
- 2026-09-25 17:15 EDT — builder: hull built before the decorative stones, so mid-route hunters land on their own stone; built, tested, pushed.
- 2026-09-25 16:43 EDT — builder: sigil top hold uses each hunter's own route side, not the shared-foothold nudge; built, tested, pushed.
- 2026-09-25 16:31 EDT — session: top hold in front of the face, sigil shot lands; pushed.

- 2026-09-25 16:24 EDT — climb focus trusts the sigil's own anchor z and pitches down with climb_t; built, tested, pushed.
- 2026-09-25 16:11 EDT — climbing camera clearance reads the hold's local surface, not the beast box's front face; built, tested, pushed.
- 2026-09-25 15:55 EDT — one fixed camera stand-off, resting and climbing, built, tested, pushed.
- 2026-09-25 15:31 EDT — stones near-hunter fix built, tested, pushed.
- 2026-09-25 13:30 EDT — lane created; the four cloud agents and the board sync are off.
- 2026-09-25 13:27 EDT — F8 camera-toggle hotkey built, tested, pushed.
