# cinder_jackal_ai — refinement log

The shipped Meshy rebuild (`game/assets/3d/cast/cinder_jackal_ai.glb`, source
`tools/blender/ai/cinder_jackal_ai.blend`), built 2026-09-22 via
`tools/blender/ai_beast.py` — see `design/guide/ai-beast-recipe.md`. This is
its **first** pass through the scoring loop (`design/guide/asset-loop.md`):
`frog_ai.md` and `goblin_mech_ai.md` have been scored and iterated on
repeatedly; this beast — the actual star of the fight — never had a rubric
score at all, only the two named fixes in `artist.md` (ear-glare glow,
foothold texture). Tier: **beast, stop at 44/50**.

Views: `design/renders/cinder_jackal_ai_pass1_*.png` (as shipped, contaminated)
and `pass2_*.png` (after this pass's fix).

## Pass 1 → Pass 2 — Build hygiene, artist, 2026-09-24T01:20 EDT

**Looked at the six-view render cold, before assuming the asset needed
anything specific**, per the loop's own "score it before reading the previous
pass's number" (there was no previous number to anchor on, but the same
discipline applies to a fresh look). Found a real, previously undiagnosed
defect immediately: a stack of untextured grey rock wedges is fused into the
model's own chest/foreleg region — visible in `_side.png`, `_form.png` and
the wireframe, and it distorts the front-leg silhouette in `_sil.png` too.
Not a rendering artifact — it is baked into the shipped mesh.

**Root cause, confirmed by reading the pipeline, not guessed.**
`design/guide/ai-beast-recipe.md` step 6 describes the ORIGINAL approach for
this exact beast: "grow the footing: a separate `Footholds` mesh of
flat-topped basalt outcrops... one per Height" — real rock geometry baked
onto the body along the climb route. That approach was replaced
2026-09-23 ("since 2026-09-23 the footing is NOT modelled: `combat_3d.
_build_float_stones` hangs a stone at every climb point... `ai_beast.py`
places the markers only") — `ai_beast.py`'s own foothold-building loop now
opens with `if True: continue # stones float in-engine now; no foothold
geometry is exported`. But the CURRENT `ai_beast.py` doesn't rebuild this
beast from a fresh Meshy download — the fixer's own last two rebuilds
(`design/agents/status/fixer.md`, 2026-09-23/24) explicitly "re-fed" the
already-shipped `cinder_jackal_ai.glb` back into the pipeline as its own raw
source, to avoid spending Meshy credits on a beast whose anatomy/rig are
already right. Every one of those re-feeds re-imports whatever geometry the
PREVIOUS export already contained — including the basalt chunk baked in
before the 2026-09-23 refactor, which the "if True: continue" guard was never
going to strip because it only stops NEW icosphere geometry from being
ADDED, not old geometry already present in the incoming mesh. The
contamination has been silently round-tripping forward through every rebuild
since, invisible because nobody had run a fresh six-view look at this
specific beast since it first shipped.

**Confirmed the geometry is a fully disjoint island before touching
anything** (`tools/blender/ai/cinder_jackal_ai.blend`, `Body` mesh): 320
faces carry a `Basalt` material distinct from the body's own `Material_0`;
those faces share **zero** vertices with the rest of the mesh (603 basalt
verts, 10369 other verts, 0 shared). Deleting them cannot open a hole in the
real body surface. Also found a second, smaller, unrelated piece of junk in
the same file: a stray untextured unit icosphere (42 verts, no material) sat
exactly at the model's local origin — a leftover default-primitive object
from manual editing, contributing nothing and rendering as a flat grey lump.

**Fix.** Opened `tools/blender/ai/cinder_jackal_ai.blend`, deleted the 320
Basalt-material faces from `Body` (0 loose verts left behind, confirming the
island really was fully disjoint), dropped the now-unused `Basalt` material
slot and datablock, deleted the stray `Icosphere` object outright, and
deleted the now-pointless empty `Footholds` mesh object (0 verts even before
this pass — `ai_beast.py`'s own dead branch still creates it every rebuild).
Re-exported with the exact same glTF export call `ai_beast.py`'s own step 6
uses (`use_selection=True`, `GLB`, animations via `ACTIONS`, skins, forced
sampling) over `game/assets/3d/cast/cinder_jackal_ai.glb`, and re-saved the
cleaned `.blend`. Climb/ledge marker empties, the rig, and every action were
untouched — they live as separate objects, never touched by this edit.

**Verified nothing else moved.** `total_verts`/`total_islands` before and
after: 12399 tris / (contaminated) → 12079 tris, 10370 verts, 440 raw mesh
islands after (`tools/blender/ai/mesh_gap_check.py`, the same tool
`goblin_mech_ai` pass 3 used) — **0 islands with a real 3D gap** at a
1%-of-body-diagonal threshold, so the topology is otherwise clean; 440 is
this beast's own UV-seam count, the same story `goblin_mech_ai` pass 7 found
for its own 489. The beast's own runtime bounding box (`_beast_box`, read
from `screenshot.gd`'s `CAM` line) shrank from `size.x=12.92` to
`size.x=10.78` — a real, understood change: the removed chunk's own X extent
(0.10–0.99 in local space, on the near/camera side) had been making the
model's AABB read as symmetric (±0.99) when the real body is asymmetric
(−0.99 / +0.66) in this running pose. Checked this doesn't break anything
the box feeds: rendered `state=3d`, `wide`, `3dclimb` and `3dgrip` after the
fix — hunters land in the right spots (`HUNTER0`/`HUNTER1 ... OK` on every
one), the arena still frames the beast the same way, nothing clips or reads
wrong. `ALL TESTS PASSED` (`run_tests.gd`) throughout — no GDScript touched,
only the asset.

![[../agents/frames/artist/2026-09-24-cinder-jackal-basalt-cleanup.png]]

Side and clay views, same camera, same pose: before, a visible stack of grey
wedges cuts across the front leg and belly; after, a clean canid line with
nothing foreign in the silhouette.

## Score — Pass 2, first rubric pass on this asset

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 2 | 8 | 8 | 7 | 9 | 8 | **40** |

- **Silhouette (8).** `_sil.png` (post-fix) reads clearly as a lean running
  canid at 64px — ears, snout, four legs and a tail all separate cleanly,
  nothing merges into an unreadable clump. The pre-fix silhouette had a
  visible defect right at the front leg/chest junction (the basalt chunk);
  that's gone now, and nothing else is currently named against this line.
- **Proportion (8).** Masses read as a jackal: lean torso, sharp head,
  slender legs — matches the "lean chase predator" the module doc and the
  recipe both describe. No specific mass reads wrong in the six-view set.
- **Build hygiene (7).** The one real, fixable defect this pass found — a
  320-face floating basalt island and a stray icosphere, both now gone,
  confirmed disjoint before deletion, confirmed no other real gaps exist
  (`mesh_gap_check.py`: 0/440 islands with a measurable gap). What's left is
  the same structural ceiling every Meshy-built asset in this cast carries:
  12079 tris against the old primitive-beast budget of 2600 (~4.6×over) — the
  same shape of overage `frog_ai`/`goblin_mech_ai` already carry against
  their own 1400 hunter budget, not something a same-pass fix reaches.
- **Colour & read (9).** Black body, orange-ember markings, amber eyes —
  clean separation confirmed in the actual in-fight camera (`state=3d`),
  not just the studio six-view render. The original Python primitive's own
  pass-1 note called this "the best colour read of the four beasts scored
  that pass"; the AI rebuild keeps the same strong palette discipline.
- **Style consistency (8).** Shares the same toon shader, ink outline and
  painted-texture pipeline as `frog_ai`/`goblin_mech_ai` — sits beside them
  as the same game, not a different one.

**40/50, 4 points under the beast stop line (44).** Build hygiene is the
clear lowest, but its concrete, fixable part is now closed — the remaining
gap there is the same tri-budget structural ceiling the hunters already
carry, not a same-pass fix. Nothing else has a named concrete defect from
this pass's look; the next useful move is either a dedicated silhouette/
proportion pass looking specifically for a smaller defect this first look
missed (this was pass 2's main find, not an exhaustive audit of those two
lines), or accepting the tri-count ceiling and moving to whichever of
Silhouette/Proportion/Style a fresh, more critical look turns up something
concrete on.

`silmetrics.py` was not run this pass — Blender's own bundled Python has no
`PIL` in this sandbox and the tool needs it; per `asset-loop.md` this is not
a gate ("these are not gates and they do not fail an asset"), so scoring
proceeded without it.

### Where it stands

**40/50.** Lines: Silhouette 8, Proportion 8, Build hygiene 7, Colour & read
9, Style consistency 8. The real defect this pass found and fixed — leftover
foothold geometry from before the 2026-09-23 "stones float in-engine" switch,
silently propagating forward through every subsequent rebuild that reused
the shipped model as its own source — is now closed and the source `.blend`
is clean going forward. Worth flagging for whoever next rebuilds this beast
from itself: the contamination existed because nothing had looked at this
specific beast's own six-view render since it first shipped, not because
`ai_beast.py`'s current logic is wrong.
