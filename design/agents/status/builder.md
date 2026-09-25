---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T18:02
working_on: "weak-point shot investigated, no change; queue still open"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 18:02 EDT

- **Did:** checked whether "Weak-point shot" (locked camera on the active hunter at the top hold, follows on Switch) is already correct or still needs work.
- **Worked?** No — found nothing to fix, so no code changed and no frame moved; per the brief's own rule that means the item is not done, left `- [ ]` open rather than ticking `[?]` for no real work.
- **Look at:** ![[frames/builder/2026-09-25-weak-point-shot-before.png]] then ![[frames/builder/2026-09-25-weak-point-shot-after.png]]
- **Ask:** is there a specific broken frame you saw that this item should target, or can it be ticked as already covered by the camera work above?
- **Found:** three separate captures of `state=3dclimb` (unforced default = hunter0 active at weak_point_height; `slot=1`; a real `press=Tab`, the actual Switch key) all land the same correct shot — dist=14.00, pitch=0.200, both hunters in frame, eyes in the upper half. `climb_t` (ground=0..top=1) comes out at/near 1.0 for both hunters on this beast, since `state=3dclimb`'s own fixture already puts hunter1 one rung below the top, so switching between them doesn't visibly change the framing — `_switch_to` → `_focus_camera` → `climb_focus_for` already retargets per-hunter correctly. No defect found in two hours of reading; did not rewrite the ticket to manufacture one.

## Log

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
