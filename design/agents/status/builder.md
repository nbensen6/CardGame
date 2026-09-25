---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T16:31
working_on: "sigil shot handed to Nick; hops item next"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 16:31 EDT (Claude in the session, taking the item after two builder passes)

- **Did:** the top stone now stands in front of the jackal's face instead of on the sigil's skin point inside the head; the camera stands back to 14 at the top.
- **Worked?** Yes — both eyes, both ears and the Frog at the sigil are in frame, and the Frog is clear of the card fan.
- **Look at:** ![[frames/builder/2026-09-25-sigil-face-before.png]] then ![[frames/builder/2026-09-25-sigil-face-after.png]]
- **Ask:** is this the weak-point shot you want, or should the camera be closer and lower?
- **Found:** the hull reading of ~13.6 the builder distrusted was RIGHT: the sigil anchor (z 0.53) is a point on the skin behind the muzzle. Trusting the anchor is what put the camera inside the head.
- **Found:** mid-climb (`state=3dgrip`) the active hunter still sits behind the card fan with the damage number on top of it; that is the between-rung camera and the queued hops item, not this one.

## Log

- 2026-09-25 16:31 EDT — session: top hold in front of the face, sigil shot lands; pushed.

- 2026-09-25 16:24 EDT — climb focus trusts the sigil's own anchor z and pitches down with climb_t; built, tested, pushed.
- 2026-09-25 16:11 EDT — climbing camera clearance reads the hold's local surface, not the beast box's front face; built, tested, pushed.
- 2026-09-25 15:55 EDT — one fixed camera stand-off, resting and climbing, built, tested, pushed.
- 2026-09-25 15:31 EDT — stones near-hunter fix built, tested, pushed.
- 2026-09-25 13:30 EDT — lane created; the four cloud agents and the board sync are off.
- 2026-09-25 13:27 EDT — F8 camera-toggle hotkey built, tested, pushed.
