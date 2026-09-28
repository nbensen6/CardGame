---
tags:
  - agent-status
agent: builder
updated: 2026-09-28T14:57
working_on: "Stones: first by the hunter, last in front of the head"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-28 14:57 EDT

- **Did:** Each hunter's stone line now fans outward on its own side, a V meeting at the jackal's head.
- **Worked?** Partly: the wide view shows the V, but from behind the Frog the Goblin's big stone sits under the climb gauge. VERDICT: FAIL
- **Look at:** ![[frames/builder/2026-09-28-stone-lines-wide-before.png]] then ![[frames/builder/2026-09-28-stone-lines-wide-after.png]]; Frog view ![[frames/builder/2026-09-28-stone-lines-before.png]] then ![[frames/builder/2026-09-28-stone-lines-after.png]]
- **Ask:** Goblin's big stone is off-screen from the Frog's view. Spread the hunters wider?

## Notes

- **Found:** From behind the Frog, the hunters stand too close (about 1.2 units each side) for both big stones to sit by their hunters on screen. Narrowing the V put the Frog's stone over the jackal's legs.

## Log

- 2026-09-28 14:57 EDT — builder: stone lines fan out into a V (route_sweep_for); grader FAIL on Goblin stone under the gauge; tested, pushed.
- 2026-09-28 14:37 EDT — builder: F8 confirmed by Nick, marked 👀 for his tick; no code change.
- 2026-09-28 14:24 EDT — builder: follow camera rides the hopping hunter (live body, not landing stone), eased yaw; harness midair=S; grader FAIL x2; tested, pushed.
- 2026-09-28 13:55 EDT — builder: one hop per stone (climb_landings), no mid-air sub-landings; harness land=K; grader FAIL then PASS; tested, pushed.

- 2026-09-28 13:11 EDT — builder: stone lines split one each side of the jackal (route_offset_x, 4 hunters each side); grader FAIL then PASS; tested, pushed.
- 2026-09-28 12:51 EDT — builder: F8 cuts to a wide Dev view and back, note moved clear of the intent chip; grader FAIL on side-on Player shot; tested, pushed.
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
