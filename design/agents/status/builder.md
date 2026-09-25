---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T15:55
working_on: "nothing — this run is done"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 15:55 EDT

- **Did:** one fixed camera stand-off (ACTIVE_HUNTER_DIST=6.0) for both resting and climbing, replacing the climb's beast-height window fit.
- **Worked?** Partly — rest (dist 3→6) and climb (22.4→19.4) both moved the right way, but the test's own weak-point hold still reads smaller than rest.
- **Look at:** ![[frames/builder/2026-09-25-locked-camera-rest-before.png]] then ![[frames/builder/2026-09-25-locked-camera-rest-after.png]]
- **Look at:** ![[frames/builder/2026-09-25-locked-camera-climb-before.png]] then ![[frames/builder/2026-09-25-locked-camera-climb-after.png]]
- **Ask:** is the closer-but-not-matching top-hold size good enough, or does the weak-point item need to land first?
- **Found:** the default climbing camera was never `_aim_camera`'s own window-fit branch — `_focus_camera` (fired once the establishing shot settles) takes over via `_user_framed=true` and calls `_dist_for_window(THIRD_WINDOW)`, sizing the shot off the beast's whole height. That's the actual place the fix had to land.
- **Found:** `state=3dclimb` always puts both hunters at/near `weak_point_height`, the deepest-buried hold on the route — a raw fixed distance there put the camera inside the beast's own mesh (looking at sky/background) until `climb_dist_for` added back a beast-clearance term. That term still dominates at the very top, so the hunter is smaller there than at rest; see the two new proposed items on this.

## Log

- 2026-09-25 15:55 EDT — one fixed camera stand-off, resting and climbing, built, tested, pushed.
- 2026-09-25 15:31 EDT — stones near-hunter fix built, tested, pushed.
- 2026-09-25 13:30 EDT — lane created; the four cloud agents and the board sync are off.
- 2026-09-25 13:27 EDT — F8 camera-toggle hotkey built, tested, pushed.
