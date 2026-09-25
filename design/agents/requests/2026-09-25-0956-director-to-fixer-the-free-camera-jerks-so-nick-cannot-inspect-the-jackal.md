---
tags:
  - request
from: director
to: fixer
status: open
priority: high
beast: cinder_jackal
eta:
created: 2026-09-25T09:56
taken_by:
ask:
waiting: false
---

# The Dev camera jerks under the mouse, so Nick cannot look the jackal over — ease it, touch nothing else

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- Nick, on #21, 22:30 last night (reached the repo 09:35 today): "i cannot properly look at the model without a free cam toggle. I also would like the free cam to be more smooth. come back to me when this is complete so i can verify the model." The toggle exists (your #19 pass 1, Menu → Settings → "Camera: Dev"); he has not found it and the camera under it snaps.
- What he feels: in Dev mode a drag turns the view by exactly the mouse's motion the same frame, with no ease-in and a dead stop on release; the wheel zooms in hard steps; WASD/QE moves in lurches. It reads as a tool, not a camera.
- Make the free camera damped: yaw/pitch, distance and pan chase their targets with a short exponential ease (the `1.0 - exp(-delta * k)` shape the follow camera already uses at 2307-2339), settling in well under half a second, with no drift after the hand comes off.
- Do NOT touch the locked Player camera, its resting framing, the climb camera, `GROUND_VIEW_*`, `ORBIT_SENSITIVITY`'s direction, or the Dev/Player default. Do NOT add momentum that keeps turning after release — he asked for smooth, not floaty. Do NOT change which screen spots accept a drag.
- Take this ahead of #0258 and #0405. It is small, it has waited eleven hours without anyone seeing it, and it is the gate on him answering #21 (the faceted jackal) and on his own look at #19.

## What

`combat_3d.gd` `_unhandled_input` (2712-2777): `_yaw -= mm.relative.x * ORBIT_SENSITIVITY`, `_pitch += …`, then `_apply_orbit()` in the same event — the camera is wherever the mouse is, that frame. Wheel up/down adjusts `_dist` in a fixed step and applies at once. The follow camera, by contrast, lerps `_dist`, `_pivot` and `_shoulder` per frame in `_process` — that is the shape to reuse: drag and wheel write a target; the per-frame step eases toward it.

Nothing on screen changes for a player; this is for Nick's inspection camera only. That is why it is high and small at once.

## How to see it

    R="xvfb-run -a -s '-screen 0 1280x720x24'"
    eval $R $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/fc.png state=3dfreecam beast=cinder_jackal size=1280x720

`3dfreecam` forces Dev and synthesises a drag at 7 spots. Today `_yaw` moves in the same frame as the synthetic motion; after the fix it should move over several. Capture a strip of frames across one synthetic drag and tile it — that is the proof, not a number.

## Done when

- A tiled strip of one synthetic drag (say 8 frames) shows the yaw easing across frames rather than jumping in one, and settling with no drift by the last frame. Same for one wheel step.
- `state=3dfreecam`: the same drags/DEAD pattern at the 7 spots as pass 1 of #19 (`gauge`'s known flicker aside).
- `state=3d`, `3dclimb`, `3dgrip`: `CAM`/`HUNTER`/`VIS` lines identical to before — the locked and climb cameras untouched.
- `ALL TESTS PASSED`; a pure test on the easing step if you extract one.
- Then say so in the Result and set `done`. The director hands #21 back to Nick with the frame; do not edit #21 yourself.

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
