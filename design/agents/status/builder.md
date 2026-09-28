---
tags:
  - agent-status
agent: builder
updated: 2026-09-28T12:24
working_on: "Zoom out: one fixed camera behind the held hunter"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-28 12:24 EDT

- **Did:** the camera now sits one fixed distance behind the hunter you hold, centred, at rest and climbing.
- **Worked?** Partly: the Frog is centred, a fifth of the frame, same range everywhere, but it still reads side-on. `VERDICT: FAIL`
- **Look at:** ![[frames/builder/2026-09-28-camera-behind-before.png]] then ![[frames/builder/2026-09-28-camera-behind-after.png]] and ![[frames/builder/2026-09-28-camera-behind-climb-after.png]]
- **Ask:** Is this the range? If yes, should the Frog turn its back to camera next?

## Notes

- **Found:** the Frog still reads side-on at rest. The lens is behind it on the line to the beast, but the model faces about 90 degrees off that line.
- **Found:** at rest, from hunter height, the near stones hide the jackal's body. Only its head clears them.
- **Found:** the fight still opens on a wide shot of the whole beast and eases in. That is a zoom Nick may not want either.
- **Found:** mid-climb the other hunter ends up behind the camera (VIS FAIL hunter1), now that the lens is this close.
- **Found:** grader, last verdict: `VERDICT: FAIL`. Its fix was "swing the camera round to sit directly behind the Frog so its back faces the lens, and the Jackal stands clear above the stones".

## Log

- 2026-09-28 12:24 EDT — builder: one fixed follow distance (3.2) behind the held hunter, centred, yaw on the beast-to-hunter line; grader FAIL on side-on Frog; tested, pushed.
- 2026-09-27 18:39 EDT — builder: the first climb engages the locked follow camera; hunter-offscreen 4 fails to 0; built, tested, pushed.
- 2026-09-27 18:24 EDT — builder: camera-not-over-shoulder waits for the truck's ease instead of 45 frames; 9 fails to 0; built, tested, pushed.

- 2026-09-25 20:55 EDT — session: 65-degree lens, stairs visible, beast whole; pushed.

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
