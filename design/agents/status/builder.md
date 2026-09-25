---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T17:52
working_on: "playtest checks re-derived, waiting on Nick"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 17:52 EDT

- **Did:** hunter-off-marker/hop-distance-band's own top-hold z now matches `_top_hold()`'s hull-pushed z instead of the raw sigil anchor, so mid-route legs measure against where the route actually is.
- **Worked?** Partly — hunter-off-marker's route-mismatch failures dropped from 10 to 2 on a 25-step playtest run (the 2 left are a different, pre-existing bug, see Found); hop-distance-band stayed clean before and after.
- **Look at:** no shot — this item is ALL TESTS PASSED plus playtest.cmd, both run before/after below.
- **Ask:** the queue item wants a fully green playtest.cmd — camera-not-over-shoulder/hunter-offscreen/beast-behind-stone are still red, but read as the same camera work already open above in the queue. Same run, or split off?
- **Found:** the 2 remaining hunter-off-marker fails are footholds AT/PAST the top rung (weak_point_height) — a hunter that hops past the sigil (Leap/Grappling Hook) lands off the check's dynamic shared-foothold x by ~1.7-2.6m, byte-identical failure before and after this fix, so it's a separate bug in the check's top-branch side logic, not the route-vs-anchor bug this item targeted. Also confirmed real: `run_tests.gd` still ALL TESTS PASSED, and every OTHER playtest failure this run (beast-behind-stone, camera-not-over-shoulder, hunter-offscreen, hunter-lost-mid-hop, damage-popup-offscreen, intent-tag-vs-hunter) was already red before this change too — all already tracked by the open camera items above in the queue, not new.

## Log

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
