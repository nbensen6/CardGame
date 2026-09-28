---
tags:
  - request
from: session
to: artist
status: done
priority: high
created: 2026-09-22
taken_by: artist
---

# The jackal's inner ears fill the screen at the sigil

## What

When a hunter reaches the sigil the camera sits at the jackal's head, and the
two inner ears — painted the same hot orange as its markings — render as two
huge yellow flames covering most of the frame. glow_gain is already down to
0.55 for this beast (`combat_3d.gd` AI_MOTION); the ears are still the
brightest thing on screen.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3dclimb beast=cinder_jackal size=1280x720

## Done when

At the sigil the ears read as ears (darker inside, a warm edge at most), the
hunter and sigil are the focus of the frame, and the embers on the back still
glow. Before/after frames committed.

## Result

**Cause.** `toon.gdshader`'s glow is a hue/saturation/value key on the painted
texture (`fragment()`: hue within ~0.08 of orange, sat>0.55, val>0.55 lifts
into `EMISSION`) — there is no UV mask, because `game/assets/3d/cast/
cinder_jackal_ai_Image_0.jpg` (2048×2048, the actual texture the material
uses — extracted from the .glb by Godot's importer at `gltf/
embedded_image_handling=1`, confirmed by hash match and that a re-`--import`
does **not** overwrite it) paints the ears' whole surface — outer AND the
medial inner face — the same saturated hot-orange as the intended embers
(spine ridge). `glow_gain` (already 0.55 for this beast) scales the whole
model uniformly, so turning it down further would have dimmed the real
embers just as much as the ears; there was no cheap uniform knob left.

Tried first: a position-based "dead zone" in `toon.gdshader` (a varying
carrying model-space vertex position, multiplying `hot` by a mask keyed off
where the .glb's own vertex data says the ears are). Measured the ears off
the mesh directly (`pygltflib`, no Blender available this session — network
egress to download.blender.org is blocked in this sandbox): head-bone
vertices widen past |x|=0.15 only above y=2.45, the muzzle stays under that
the whole way up. The shader mask worked in principle but the model is only
~12k faces total for the whole beast, so a handful of large triangles span
the ear and per-pixel interpolation between a low-y base vertex and a
high-y tip vertex left most of the visible ear only partially masked.
Reverted it (`git checkout` on `toon.gdshader` / `combat_3d.gd`) rather than
ship a shader knob that barely moved the screenshot.

**Fix: paint the texture directly**, at the exact triangle footprint rather
than a geometric guess. Script (kept for any future beast that needs the
same treatment, not committed — one-off): for every triangle in `Mesh_0`,
compute an "earness" from its vertices' bind-pose position (outer ear:
y∈[2.42,2.62]→[0.09,0.20] on |x|; inner/medial face folds back toward the
centreline so it stays narrow in X — caught separately by y∈[2.4,2.6] and
z∈[1.85,2.0], forward enough to be head rather than the z≈1.0–1.5 the spine
ridge sits at on its way up the neck), rasterize each qualifying triangle's
UV footprint into a mask at the texture's own 2048×2048 resolution, blur 2px
so triangle edges don't show as facets, then scale saturation and value down
(up to ×0.18 and ×0.28 at full "earness") on exactly those texels — hue and
local detail (the crack pattern) untouched, so it reads as the ear in shadow
rather than a flat paint-over. 2,244 of 11,999 triangles qualified.

Iterated by rendering after each pass (`screenshot.gd state=3dclimb`) and
checking a crop at 3× — the first two passes only muted the outer cone
(x-gated too tight, missed the medial face); confirmed coverage against the
actual "hot" texels (not just the geometric guess) by recomputing the hue/
sat/val key on the edited texture and flagging triangles still above
threshold, which is what caught the medial-face gap.

**Proof.** `ALL TESTS PASSED` (`run_tests.gd`; texture-only change, no logic
touched). Before/after at the exact repro
(`design/agents/frames/artist/2026-09-22-jackal-ear-glare-{before,after}.png`):
the ears now read as dark, cracked, copper-rimmed ears — the hunter and
sigil are the frame's focus — and the same fix carries to the normal combat
camera (`state=3d`) and the felled-body reward screen, both checked, neither
regressed. The forehead's own small ember (between the ears, near the mouth)
was deliberately left lit — it isn't an ear, it's on the head not the back,
and it sits right at the sigil the camera is aimed at.

Commit: see the commit that introduces this Result section. Touches only
`game/assets/3d/cast/cinder_jackal_ai_Image_0.jpg`.

### Frames

![[frames/artist/2026-09-22-jackal-ear-glare-after.png]]
![[frames/artist/2026-09-22-jackal-ear-glare-before.png]]
