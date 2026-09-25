---
tags:
  - request
from: director
to: artist
status: open
priority: normal
beast: cinder_jackal
eta:
created: 2026-09-24T22:57
taken_by:
ask:
waiting: false
---

# The horizon is a hard 3-pixel red line through the beast's ankles, in every ground shot

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- After #13 (Nick's live ask on the hunters comes first) — not before.
- In `state=3d` and `3dgrip` at 1:1 there is a hard red stripe, 3-4 px, the
  full width of the frame, where the ground meets the sky. It runs through
  the jackal's ankles and behind both hunters' heads. It reads as a debug
  line, not a horizon.
- It is the sky, not geometry: the jackal biome's `horizon` colour is hot red
  and the `ProceduralSkyMaterial` horizon band is left at its default width,
  so a colour meant to be the lava glow in Nick's drawing collapses to one
  bright row. Widen the band (the sky/ground curve on that material) so it is
  a glow that fades up into the purple over the bottom third of the sky,
  the way his drawing has it.
- Do NOT change the colours (#12 settled them: cool sky, hot horizon, dark
  ground — those are right). Do NOT add geometry, a wall, a plane or a
  shader. Do NOT touch the camera. One or two numbers in `combat_3d.BIOME`
  or where the biome is applied, nothing else — `CLAUDE.md` §12: light is
  the cheapest identity we have, reach for it before geometry.

## What

Tonight's ground shot at 1:1 beside his drawing. His horizon is a broad glow;
ours is the red line at y≈435:

![[frames/director/2026-09-24-2250-director-resting-vs-reference.png]]

Same line in the grip shot, at y≈185, behind the beast's legs:

![[frames/director/2026-09-24-2250-director-grip.png]]

This has been in every director frame since 21:54 and I did not call it
until now; that miss is mine, not yours. It predates Nick's 22:12 camera
commit.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

Sample any column at rows 430-440: three rows of (180, 50, 70) between the
purple sky above and the dark ground below.

## Done when

- `state=3d` at 1:1: no single row along the horizon is more saturated than
  the rows five pixels above and below it; the red reads as a band of glow,
  not a line. Before/after frame in `## Result`, both 1:1, full frame.
- Nothing else in the frame changed: same stone colour, same ground, same
  camera (`CAM` line identical).
- Not Nick's judgement to close — a measured line — so `done` is yours. If
  you find yourself wanting to make the glow bigger or hotter than his
  drawing, stop and ask him instead.

## Nick's answer

## Result
