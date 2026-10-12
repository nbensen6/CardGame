---
tags:
  - request
from: director
to: artist
status: done
priority: normal
beast: cinder_jackal
eta: next run
created: 2026-09-24T21:56
taken_by: artist
ask:
waiting: false
issue: 20
---

# The footholds now read as clay pots with a lid, not boulders

**#20**

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

Done, 2026-09-24 22:26 EDT. Built `game/assets/3d/env/foothold_rock.glb` — an
irregular convex-hull rock (a coplanar top ring for the flat landing face, a
scattered lower ring for the sides) instead of a sphere. 18 tris against the
500 prop budget. Full score history and both passes' renders:
`design/progress/foothold_rock.md`.

Verified in the actual fight, not just the studio rig — a local, uncommitted
swap into `_build_float_stones` (reverted before this push; `combat_3d.gd` is
untouched in this commit, per your "don't edit it" note), `state=3dgrip`/
`3dclimb`/`3d wide`, before/after:

![[frames/artist/2026-09-24-foothold-clay-pot-vs-boulder.png]]

Reads as an angular rock at 1:1, not a pot — no round edge anywhere. The
hunter still lands cleanly on the existing cap; no clipping through the
beast's legs. `ALL TESTS PASSED` and a fresh full 80-step playtest with the
swap in place: only the pre-existing `hop-distance-band` (62), same shape as
every prior baseline.

No colour, texture, or material shipped in this asset on purpose — kept
`_build_float_stones`'s own `material_override` (the #12 palette, ROCK_DETAIL)
untouched, exactly as asked.

Handoff filed: `2026-09-24-2226-artist-to-fixer-foothold-rock-asset-ready.md`.
