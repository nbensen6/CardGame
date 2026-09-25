---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T17:15
working_on: "hops-on-stones mid-route hull-order fix handed to Nick"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 17:15 EDT

- **Did:** `_show_beast` built the decorative stones before the hull existed; swapped the order so both read the same hull.
- **Worked?** Yes — `state=3dclimb slot=1`'s Goblin now stands on the boulder by the jackal's leg instead of floating beside it; HUNTER/STONE z now match within 0.1 on every rung checked (were 0.84–2.62 off).
- **Look at:** ![[frames/builder/2026-09-25-hops-on-stones-before.png]] then ![[frames/builder/2026-09-25-hops-on-stones-after.png]]
- **Ask:** nothing.
- **Found:** `tools/shot.cmd` invoked with a RELATIVE `out=` path silently fails to save (`img.save_png` errors, but the harness prints "SHOT SAVED" anyway) when the process isn't launched from the repo root — this session's first before/after pair was actually just recycled bytes from an already-committed frame, caught only by an md5 check against HEAD. An absolute `out=` path saves correctly. Worth a fix in `screenshot.gd` (check `save_png`'s return code) so a future run can't ship a silently-stale frame as proof.
- **Found:** `_stand_on_model`'s `side` parameter is still unused inside the function (noted by the prior run, still true, still harmless).

## Log

- 2026-09-25 17:15 EDT — builder: hull built before the decorative stones, so mid-route hunters land on their own stone; built, tested, pushed.
- 2026-09-25 16:43 EDT — builder: sigil top hold uses each hunter's own route side, not the shared-foothold nudge; built, tested, pushed.
- 2026-09-25 16:31 EDT — session: top hold in front of the face, sigil shot lands; pushed.

- 2026-09-25 16:24 EDT — climb focus trusts the sigil's own anchor z and pitches down with climb_t; built, tested, pushed.
- 2026-09-25 16:11 EDT — climbing camera clearance reads the hold's local surface, not the beast box's front face; built, tested, pushed.
- 2026-09-25 15:55 EDT — one fixed camera stand-off, resting and climbing, built, tested, pushed.
- 2026-09-25 15:31 EDT — stones near-hunter fix built, tested, pushed.
- 2026-09-25 13:30 EDT — lane created; the four cloud agents and the board sync are off.
- 2026-09-25 13:27 EDT — F8 camera-toggle hotkey built, tested, pushed.
