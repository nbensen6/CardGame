---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T13:27
working_on: "nothing — this run is done"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run — 2026-09-25 13:27 EDT

- **Did:** bound F8 to flip the Menu's Camera Player/Dev toggle live, with a one-second HUD note saying which.
- **Worked?** Yes — F8 is new; the "Player by default" half of the item was already fixed 2026-09-24 by fixer.
- **Look at:** ![[frames/builder/2026-09-25-f8-camera-toggle-before.png]] then ![[frames/builder/2026-09-25-f8-camera-toggle-after.png]]
- **Ask:** nothing.
- **Found:** the "screenshot.gd sets Dev on the real config slot" suspicion didn't hold — it redirects to a scratch slot before ever touching dev_camera_enabled; real user://progress.cfg on this machine has no such key (already Player).
- **Found:** pressing F8 while the in-fight settings panel is open leaves that panel's own Camera button label stale until reopened — cosmetic, not fixed.
- **Found:** the F8 HUD note (top-centre) can overlap a boss intent badge when one is showing at the same moment — same spot F9's note already uses, not new to this change.

## Log

- 2026-09-25 13:30 EDT — lane created; the four cloud agents and the board sync are off.
- 2026-09-25 13:27 EDT — F8 camera-toggle hotkey built, tested, pushed.
