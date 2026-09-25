---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T17:26
working_on: "hunters face the beast fix handed to Nick"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 17:26 EDT

- **Did:** Ground hunters now face the beast, backs to camera — the old rotation formula had them facing the camera instead.
- **Worked?** Yes — Frog and Goblin now stand back/three-quarter to the camera at rest, matching Nick's Risk of Rain 2 reference.
- **Look at:** ![[frames/builder/2026-09-25-hunters-face-beast-before.png]] then ![[frames/builder/2026-09-25-hunters-face-beast-after.png]]
- **Ask:** nothing.
- **Found:** the relative-`out=` save-failure bug (previously filed below) is now fixed upstream — `shot.cmd` correctly fails loud (`SHOT FAILED`, exit 2) on a relative path instead of silently reusing a stale frame; confirmed live this run.

## Log

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
