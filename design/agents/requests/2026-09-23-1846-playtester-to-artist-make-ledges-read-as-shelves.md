---
tags:
  - request
from: playtester
to: artist
status: open
priority: normal
created: 2026-09-23T18:46
taken_by:
ask:
waiting: false
---

# Make a climbable stone read as a shelf, not a floating marker — from the wide shot

## What I need

- Nick approved the stone-route proposal (`2026-09-23-1434-...`, his answer
  2026-09-23 18:00 ET) and called this piece out as yours specifically:
  "A ledge looks like a shelf, not a floating marker: yes — artist's, file
  it."
- The stones/holds the hunters climb (`_build_float_stones` in the 3D view)
  need a material/silhouette treatment so a real ledge is visually distinct
  from a point on the beast's skin a hunter just passes through mid-fall —
  and so the route reads as climbable **from the wide establishing shot**,
  before the player is anywhere near it, not just up close.
- Reference taken from Breath of the Wild: a climbable surface reads as
  climbable by its material and lighting from far away. Right now (before
  the fixer's route fix lands) the stones read as loose pebbles even up
  close; once the route itself is fixed, the visual read still needs this
  pass on top, or it'll look like four correctly-placed but still-generic
  rocks.

## What

This is the second half of the stone-route work Nick approved — the
fixer is rebuilding the route's placement/spacing (see
`2026-09-23-1846-playtester-to-fixer-build-the-one-directional-stone-route.md`);
this request is only the look, not the placement. No need to wait on the
fixer's placement fix to start on material/shape — the shelf treatment
should work regardless of exactly where a given hold ends up.

Concretely: each stone is currently a plain shape pushed forward off the
beast's skin (`stone_point()`, `HUNTER_HEIGHT * 1.5` radius = 1.05 units).
Whatever you do to it (a flatter top face to suggest footing, a distinct
color/material against the beast's skin, a rim light or edge highlight)
needs to still read at the size/distance of the wide establishing shot, not
just in a close-up render.

## How to see it

    xvfb-run -a godot --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720 wide

Before (stones read as loose rocks, not a route):

![[frames/playtester/2026-09-23-stones-route-wide-before.png]]

## Done when

- A wide-shot frame of the Cinder Jackal where the stones visibly read as
  "the path up" against the beast's skin, at the size they render in the
  establishing shot — not just in a cropped/zoomed render.
- Ledges (real footing) and mid-air pass-through points, if any exist
  separately, look distinguishably different from each other.

## Nick's answer

<!-- Type below this line. Anything, one word is fine. Then run
     tools\board_push.cmd. Leave the frontmatter alone. -->

## Result
