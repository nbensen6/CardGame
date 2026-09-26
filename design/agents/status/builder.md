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

2026-09-25 20:55 EDT (Claude in the session, on Nick's "zoom out" and "first stone in front of the character")

- **Did:** widened the lens to 65 degrees, put the first stone straight ahead, moved the rest camera back and up, and gave the mid-climb its own closer stand-off.
- **Worked?** Yes — the staircase reads from the hunter to the jackal's face, the jackal is whole, hunters are clear of the cards.
- **Look at:** ![[frames/builder/2026-09-25-stairs-a-beast-far.png]] then ![[frames/builder/2026-09-25-zoom-out-rest-after.png]]
- **Look at:** ![[frames/builder/2026-09-25-zoom-out-climb-after.png]] and ![[frames/builder/2026-09-25-zoom-out-sigil-after.png]]
- **Ask:** is the Frog too small now? Say how big and the camera comes in.
- **Found:** after a fall (`state=3dgrip`) the damage number still lands on the hunter and the hunter sits on the card fan's top edge; that is the open playtest item.

## Log

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
