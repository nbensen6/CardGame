---
tags:
  - agent-status
agent: artist
updated: 2026-09-22
working_on: idle — took the ear-glare request, done; picking next brief item next run
---

# artist

## Now

Fixed `requests/2026-09-22-1700-session-to-artist-jackal-ear-glare.md`: the
Cinder Jackal's inner ears were painting the same hot-orange as its embers,
so the hue/sat/val glow key in `toon.gdshader` lit up the whole ear at the
sigil close-up. No shader knob could fix it without also dimming the real
embers (glow_gain is a single uniform for the whole beast); a geometric
"dead zone" in the shader was too imprecise on this ~12k-face mesh (per-pixel
interpolation left most of the ear only partially masked). Fixed at the
source instead: painted the ear triangles' exact UV footprint directly onto
`cinder_jackal_ai_Image_0.jpg` (the 2048×2048 texture Godot's importer
extracted from the .glb — confirmed edits there survive `--import`), scaling
saturation/value down on just those texels so hue/detail (the crack pattern)
survive and it reads as ear-in-shadow, not a paint-over.

Before/after in `design/agents/frames/artist/2026-09-22-jackal-ear-glare-*.png`
(the exact repro in the request). Also checked `state=3d`, `3dgrip`,
`3dstrike` and `3dreward` (the felled body) — the fix carries cleanly to
every camera, no regression. `ALL TESTS PASSED`. Request marked `done` with
the full writeup.

Blender is unreachable this session (download.blender.org is blocked by the
sandbox's egress policy) — did the geometry analysis by parsing the .glb
directly with `pygltflib` instead. Worth knowing for whoever picks up
`ai_beast.py`-based work next: if Blender download fails, the .glb is still
fully inspectable without it for anything that doesn't need re-export.

## Next

Haven't started the hunters (Frog, Goblin Engineer still Python-primitive
next to a textured/rigged beast — the biggest style gap per the brief) or the
arena/cards. Will pick up the brief in that order next run, checking
`requests/` first as always.

## Log

- 2026-09-22 — fixed the jackal ear-glare request (texture edit, not a
  shader change — see `## Now`). `ALL TESTS PASSED`; checked every 3D camera
  state, no regression.
- 2026-09-22 — note created by the session.
