---
tags:
  - request
from: director
to: artist
status: open
priority: normal
beast: cinder_jackal
eta:
created: 2026-09-24T21:56
taken_by:
ask:
waiting: false
---

# The footholds now read as clay pots with a lid, not boulders

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- #16 gave the stones mass and that was right; but a perfect sphere with a
  flat cap and an orange rim reads, at 1:1, as a **pot or an urn**. Nick's
  reference stones are irregular lumps with four or five big flat faces.
- Build the foothold as a **model asset** (a low-poly pale boulder, a few
  large facets, style C, the flat landing cap still on top) through the
  asset loop, and hand the fixer the path to load it. Keep the size (three
  hunters wide, as tall as it is wide) and the #12 colour exactly.
- Do NOT edit `combat_3d.gd` for this. The fixer is inside
  `_build_float_stones` right now on #14 and two hands in one function will
  cost a run to untangle. The fixer swaps the mesh in when #14 lands.
- Do NOT add texture, cracks, moss or detail; do NOT change the rim colour;
  do NOT move the stones — placement is #14.
- Do NOT touch the jackal or the hunters in the same run.

## What

Left: what a player sees in the grip shot, 1:1, no zoom. Right: the stone in
Nick's drawing, scaled down to roughly the same on-screen size.

![[frames/director/2026-09-24-2154-director-stone-vs-reference.png]]

The full frame it comes from:

![[frames/director/2026-09-24-2154-director-grip.png]]

Ours is the right colour and now the right bulk (#16 worked, keep it). What
is wrong is that it is a sphere: round body, a lip, a lid. A boulder is never
round. Four or five big planar faces, one of them the cap, and it reads as
rock at any size — which is also what style C already does on the jackal's
body, so it ties the stones to the beast for free.

The reference is a placement-and-character reference only (Nick, #17), so
copy the *shape language* of its stones, not their painted look.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3dgrip beast=cinder_jackal size=1280x720

## Done when

- A boulder model with the loop's score history in `design/progress/`, six
  views in `design/renders/`, at or under the tile budget.
- Rendered *in the fight* (via a local, uncommitted swap is fine) at 1:1 in
  `state=3dgrip`: it reads as a rock, not a pot, with the hunter still
  landing on the cap. Frame in `## Result`.
- A one-line request `to: fixer` with the asset path, to wire in after #14.

## Nick's answer

## Result
