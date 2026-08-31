# vine_weaver — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/vine_weaver.py`.** Views: `design/renders/vine_weaver_pass1_*.png`.
Hunter (1400 tri budget).

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 7 | 4 | 7 | 8 | **34** |

## What is actually there

A humanoid ent: a wide green foliage canopy on top of a brown trunk-torso,
two arms that fork into leaf-clump "hands," root feet with several toes at
uneven lengths, vines with leaves wound around the waist, amber eye-dots set
into the trunk, and a small purple gem sitting off to one side near the
vines.

- **Silhouette** (`_sil.png`): distinctive — wide canopy top, forked-arm
  bumps at the shoulders, a ragged root-foot base. This is exactly the
  "canopy wider than the trunk, top of the silhouette is a mass and not a
  point" the redesign intent asked for, and it clears the old lamp-shape
  problem the previous design had.
- **Proportion**: canopy, trunk, forked arms and root feet all read as
  "walking tree" and hold up beside the cast; canopy width doesn't
  overwhelm the trunk.
- **Build hygiene**: **1704/1400 tris — 304 over budget**, which the build
  note already flags as a deliberate call rather than an oversight. Scored
  on the rubric line as written ("within budget") this is a real fail
  regardless of the reasoning. Separately, the purple gem sits visibly
  clear of the vine mass in the side view — the same "orbiting part"
  failure named for several beasts (Eyrie Hawk, Clot Toad, Silk Widow,
  Husk Beetle) — it reads as a bead resting near the vines, not set into
  them.
- **Colour & read**: brown trunk, green canopy and hand-leaves, purple gem,
  amber eyes — separates well, nothing dark-on-dark.
- **Style consistency**: rounded low-poly, sits fine beside the cast.

## Diagnosis — two lowest

1. **Build hygiene (4).** Two separate issues, both concrete: (a) the
   304-tri overage is a named trade-off already on record — the fix, if
   Nick wants one, is to say which of canopy/forked-arms/six root-toes/two
   vines gives up tris, not something to guess at here; (b) the purple gem
   is spaced away from the vine surface — concrete fix: move it inward
   along its current offset by roughly its own radius so it nests into the
   vine coil rather than sitting beside it.
2. **Proportion (7).** Solid already; the only soft spot is the canopy's
   size relative to the trunk, which the build note itself flags as
   unjudged. Left as a genuine open question rather than a manufactured
   fix — it reads fine in this render, so no change proposed.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the 304-tri budget overage should be accepted as this hunter's
permanent cost of the Ent redesign, or trimmed — that's the trade-off the
build note already named and left for Nick, and nothing in this render
changes the terms of that call.
