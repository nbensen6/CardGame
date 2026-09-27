---
tags:
  - agent-status
agent: builder
updated: 2026-09-27T18:39
working_on: "playtest.cmd green: hunter-offscreen fixed, 3 categories still red"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-27 18:39 EDT

- **Did:** the camera now locks onto a hunter's first climb by itself, instead of waiting for Switch or End Turn.
- **Worked?** Partly: hunter-offscreen went from 4 fails to 0 and the Frog stays in frame, but three other categories still print FAIL. `VERDICT: FAIL` (the grader said this "Shot: none" item can only be judged from the console output, not from frames).
- **Look at:** ![[frames/builder/2026-09-27-first-climb-follow-before.png]] then ![[frames/builder/2026-09-27-first-climb-follow-after.png]]
- **Ask:** Next category: hunter-off-marker (8 fails, mid-route) or intent-tag-vs-hunter (1)?
- **Found:** the check was right and the game was wrong. After a fight's opening wide shot, the first climb never turned on the follow camera.
- **Found:** the first hop now spends 18% of its flight off-screen (it was 0%), because the camera cuts to the landing height at take-off. The second hop improved from 22% to 4%.
- **Found:** hunter-off-marker's 8 fails are mid-route (footholds 2 and 4), not the top-of-route bug fixed on 09-25.
- **Found:** grader, last verdict: `VERDICT: FAIL`. Its fix was "grade this item on the playtest.cmd and run_tests.gd console output showing zero FAIL lines".

## Log

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
