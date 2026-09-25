---
tags:
  - request
from: artist
to: fixer
status: done
priority: normal
beast: cinder_jackal
eta: done
created: 2026-09-24T22:26
taken_by: fixer
ask:
waiting: false
---

# Wire the new boulder mesh into `_build_float_stones` once #14 lands

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- `game/assets/3d/env/foothold_rock.glb` is a low-poly rock mesh (18 tris) —
  swap it in for the BODY's `SphereMesh` in `_build_float_stones`
  (`combat_3d.gd`). Answers #17 (director) — the current sphere reads as a
  pot; this reads as rock. See `design/progress/foothold_rock.md` for the
  build and the in-fight verification frame.
- Not touched here on purpose (per #17): keep the CAP/RIM code, the #12
  palette (`body_mat.albedo_color`), and the `ROCK_DETAIL` multiply exactly
  as they are — this mesh carries no colour or texture of its own.
- Left for you rather than built into the same commit as #14: you're already
  inside `_build_float_stones` for the gap/stones/camera sequence, and two
  hands in one function the same day is how a run gets spent untangling a
  merge instead of shipping either fix.

## What

The mesh's origin is at its own base centre (this project's usual contract),
**not** centred like the old `SphereMesh` — its flat top (the landing face)
sits at local height ≈1.74 before any scale, not at the object's own centre.
I proved the wiring works with this local math (reverted before this push,
not committed):

    var rock_radius := HUNTER_HEIGHT * 1.5
    var rock_height := rock_radius * 2.0
    var scale := (rock_radius * 2.0) / 1.74   # model's native width/height
    body.position = Vector3(0.0, cap_height * 0.5 - rock_height, 0.0)
    body.scale = Vector3.ONE * scale

(the old code's `cap_mesh.top_radius = rock.radius * 0.92` etc. need
`rock_radius` in place of the removed `SphereMesh`'s own `.radius`.) That's
scaffolding to get you started, not a patch to apply blind — you're already
mid-edit in there for #14, so fold it into whatever shape that lands in.

Per-instance variety: I dropped the old per-stone squash/tilt (it was tuned
for a sphere and would distort this mesh's own irregular shape unpredictably)
and kept only a random Y-axis spin. If two stones at neighbouring heights
reading as identical clones bothers you, `boulder_foothold.py` is easy to
extend with a second/third hull variant — say so and I'll build them, rather
than guessing you want that now.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3dgrip beast=cinder_jackal size=1280x720

Before/after already proven, this run:

![[frames/artist/2026-09-24-foothold-clay-pot-vs-boulder.png]]

## Done when

The shipped fight shows the new rock mesh (not the sphere) at every camera
state that uses a foothold, colour/rim unchanged, hunter still lands on the
cap, no regression in `run_tests.gd` or a full playtest.

## Nick's answer

## Result — fixer, 2026-09-25 01:48 EDT

Done as part of #14 (the director's own 23:57 note: "wiring its mesh is part
of this, not a separate run"). Used your own scaffolding numbers verbatim —
`(rock_radius*2.0)/1.74` scale, `cap_height*0.5 - rock_height` sink — in
`_build_float_stones` (`combat_3d.gd`). Loaded via `PackedScene.instantiate()`
same as every beast model in this file; the imported scene is a `Node3D`
wrapper around one `MeshInstance3D`, found by `find_children` so
`material_override` still lands on the real mesh. Dropped the old tilt/squash
per your own note, kept a random Y spin only. CAP/RIM/palette code untouched.

`ALL TESTS PASSED`. Full 80-step playtest: no new failures (only the
pre-existing, unrelated `hop-distance-band`, see #14). Rendered `state=3dgrip`
fresh — reads the same clean angular rock your own verification frame showed:

![[frames/fixer/2026-09-25-stone-sweep-3dgrip-after.png]]
