---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T16:43
working_on: "hops-on-stones top-hold fix handed to Nick"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 16:43 EDT

- **Did:** the sigil's top hold now uses each hunter's fixed route side, so a lone climber lands on their own stone.
- **Worked?** Yes — `state=3dclimb`'s Frog now stands on the stone crate in front of the jackal's face, not floating past it at eye level.
- **Look at:** ![[frames/builder/2026-09-25-hops-on-stones-before.png]] then ![[frames/builder/2026-09-25-hops-on-stones-after.png]]
- **Ask:** should mid-route footing (state=3dgrip's second hunter) get its own look next?
- **Found:** `_stand_on_model`'s `side` parameter is now unused inside the function (the top branch was its only reader) — dead but harmless; left alone rather than reshape three call sites for a naming ticket.
- **Found:** `state=3dgrip`'s own shot didn't move — hunter0 lands on the ground after the grip fall (no stone needed there) and hunter1 sits at a non-top rung, so neither exercises the branch this run touched.
- **Found:** checked hunter1 (mid-route, weak_point_height-1) with `slot=1`: stands near the jackal's front leg, not obviously centred on its own decorative stone — worth a closer look, not confirmed broken.

## Log

- 2026-09-25 16:43 EDT — builder: sigil top hold uses each hunter's own route side, not the shared-foothold nudge; built, tested, pushed.
- 2026-09-25 16:31 EDT — session: top hold in front of the face, sigil shot lands; pushed.

- 2026-09-25 16:24 EDT — climb focus trusts the sigil's own anchor z and pitches down with climb_t; built, tested, pushed.
- 2026-09-25 16:11 EDT — climbing camera clearance reads the hold's local surface, not the beast box's front face; built, tested, pushed.
- 2026-09-25 15:55 EDT — one fixed camera stand-off, resting and climbing, built, tested, pushed.
- 2026-09-25 15:31 EDT — stones near-hunter fix built, tested, pushed.
- 2026-09-25 13:30 EDT — lane created; the four cloud agents and the board sync are off.
- 2026-09-25 13:27 EDT — F8 camera-toggle hotkey built, tested, pushed.
