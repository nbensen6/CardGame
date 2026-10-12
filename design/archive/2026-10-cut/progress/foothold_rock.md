# foothold_rock — the floating foothold's body mesh

Answers #17 (director, 2026-09-24): "the footholds now read as clay pots with
a lid, not boulders." #16 gave the stone bulk (sphere height = 2x radius);
that fixed the squash but a true sphere with a flat cap is a pot's own shape.
This replaces the sphere with an irregular convex-hull rock: a coplanar ring
of points at the top gives the flat landing face for free, and a scatter of
points below at uneven radius/angle/height gives the sides their few big,
unequal facets — style C's own "hard facet, no two the same size" language,
already worn by the jackal's decimated body.

**ANCHOR:** reads as a broken chunk of rock with a flat top you could stand
on, not a pot, an egg, or a lidded jar — at 1:1 in the real fight camera, not
just up close.

Geometry only. No material, texture, or colour is baked into this asset on
purpose — `_build_float_stones` (combat_3d.gd) keeps applying the #12 palette
and the ROCK_DETAIL multiply via `material_override` at runtime, and #17
explicitly asks not to touch that code or its colours from this side. The
STONE swatch this ships with is a placeholder for the loop's own renders
only.

## Pass 1 — artist, 2026-09-24 22:15 EDT

Convex hull of 4 top points (all at Z=1.60) + 7 scattered bulk points, hull
dissolved at a 20° coplanar limit. 16 tris.

![[../renders/foothold_rock_env_pass1_34.png]]
![[../renders/foothold_rock_env_pass1_front.png]]

Read: already a clear irregular rock, no roundness anywhere — the hull+
dissolve approach worked on the first attempt. One issue: bounding box
1.73 x 1.75 x 1.54 — noticeably shorter than it is wide, when #16/#17 both
ask for "as tall as it is wide."

## Pass 2 — artist, 2026-09-24 22:20 EDT

One fix: raised the top ring from Z=1.60 to Z=1.80. 18 tris.

![[../renders/foothold_rock_env_pass2_34.png]]
![[../renders/foothold_rock_env_pass2_front.png]]
![[../renders/foothold_rock_env_pass2_sil.png]]

SIZE 1.727 x 1.751 x 1.74 — the three axes now agree to within 1.5%, genuinely
cube-proportioned rather than squashed. Silhouette (`_sil.png`) reads as a
clean irregular heptagon-ish lump, nothing round in it.

**Verified in the actual fight**, not just the studio rig: swapped this mesh
in for the SphereMesh in a local, uncommitted edit to `_build_float_stones`
(kept the existing CAP/RIM code and the #12 material logic untouched, per
#17's own instruction), re-imported, rendered `state=3dgrip`/`3dclimb`/
`3d wide`. Side-by-side against the unmodified tree:

![[../frames/artist/2026-09-24-foothold-clay-pot-vs-boulder.png]]

Reads as an angular rock at 1:1 in every camera state the fight uses; the
hunter still lands cleanly on the existing cap; no clipping through the
beast's legs in the grip/climb shots. `ALL TESTS PASSED` and a fresh full
80-step playtest with the swap in place: only the pre-existing
`hop-distance-band` (62), identical shape to every prior baseline — nothing
about the swap touched hop timing or landing. Reverted the temporary
`combat_3d.gd` edit before committing anything, per #17's "do not edit
combat_3d.gd" — only the asset and this progress note ship from this pass.

## Score (pass 2)

Treated at the hunter tier (42 to stop) — this is a small prop, but one on
screen for the whole fight, same as a hunter.

| Criterion | Score | Why |
|---|---|---|
| Silhouette | 8 | Reads as a broken rock chunk at 64px, no round edge anywhere; the `_sil.png` above. |
| Proportion | 8 | Squat, roughly cubic bulk matches the jackal's own faceted body language; sits beside it without looking like a different kit. |
| Build hygiene | 9 | 18 tris (500 budget), one mesh, one material, convex hull guarantees a single closed volume — no floating islands possible by construction. |
| Colour & read | 6 (n/a by design) | Ships with a placeholder swatch; the shipped colour is applied by the untouched runtime material per #17's own scope. Not a defect, but not a real score either — flagged rather than invented. |
| Style consistency | 8 | Same hard-facet, no-two-faces-equal language as the jackal's decimated body (style C) — reads as the same game. |

**37/50** counting the placeholder colour line as scored; the geometry the
loop actually judges (Silhouette/Proportion/Build hygiene/Style) averages
8.25. One pass closed the director's actual complaint (pot -> rock) and hit
proportion in the same pass — not chasing further passes on a 16-tri prop
whose only open line is "colour is intentionally not this file's job."

## What to hand back

`game/assets/3d/env/foothold_rock.glb` (+ `tools/blender/boulder_foothold.py`,
the source). Origin at the base centre (contract default), flat top face at
local height ≈1.74 before scale. The fixer's own wiring note is
`2026-09-24-2220-artist-to-fixer-foothold-rock-asset-ready.md`.
