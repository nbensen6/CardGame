# stone_warden (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** rather than a
creature for the first time under item #83 — filed as `stone_warden_ground`
rather than `stone_warden` because a beast of the same name already exists
in `game/assets/3d/cast/` and will need its own file. **Scoring pass only —
item #83 is report, not repair; no edits made to
`tools/blender/env/stone_warden.py`.** Views:
`design/renders/stone_warden_pass1_*.png`, captured with
`look.sh env stone_warden 1`.

**Rubric adaptation.** The five-line rubric in `design/asset-loop.md` is
written for a single creature ("readable as this creature"). For a ground,
each line is reinterpreted the same way item #83's own ART-REVIEW batch note
already reinterprets grounds — silhouette/proportion ask whether it reads as
a *place*, not a creature — rather than inventing a separate rubric.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 5 | 6 | 5 | 7 | **29** |

## What is actually there

A near-continuous ring of tall, irregular dark-slate slabs encloses a small
tan-floored circle. From the fight-camera-angle view (`_34.png`) and the
profile (`_side.png`), the ring fills nearly the entire frame edge to edge
and top to bottom; only a thin sliver of the tan floor is visible at the
very bottom, with a short pale bar shape (the half-worked block described in
the build script) barely peeking through the gap between two slabs. The top
view (`_top.png`) shows what the side views hide: a dished sand-and-graphite
floor with two straight bar shapes and scattered dots on it, ringed evenly
by the tall slabs.

- **Silhouette** (`_sil.png`): a jagged, uneven-topped dark mass — reads
  generically as "wall" or "ruins" rather than specifically "quarry." Not
  a bad silhouette on its own terms, just not a distinctive one.
- **Proportion**: hard to judge fairly, because the enclosure wall
  (`e.enclose("cliff")`) occupies nearly all of both the `_34` and `_side`
  frames — the actual quarry storytelling the build script describes (cut
  benches stepped down, stacked sawn blocks, the half-worked block with saw
  marks, spoil drifts, weeds) is almost entirely hidden behind the wall from
  this angle. What little floor is visible is proportioned fine; the
  question the rubric line is meant to answer — does the *place* read — is
  effectively unanswerable from these views.
- **Build hygiene**: what is visible (the wall slabs) is clean — bevelled
  edges, no obvious floating pieces, varied slab widths and heights avoiding
  a repeated-tile look. Cannot confirm the same for the floor detail (the
  stacked blocks, the half-worked block, the stepped benches) because it is
  not visible enough to inspect in any of the six captured views.
- **Colour & read**: the wall is built from PEWTER/SLATE/GRAPHITE/SILVER,
  four greys close enough in value that the ring reads as one near-uniform
  dark mass rather than as individually readable blocks — the same
  dark-on-dark family of concern flagged for other assets in this file
  (e.g. brine_urchin's body-vs-spines note).
- **Style consistency**: hard-edged, bevelled boxes fit the "everything here
  has a straight edge" intent from the script's own docstring, and contrast
  correctly with crag_pup's more organic, leaning shard shapes when the two
  are compared.

## Diagnosis — two lowest

1. **Colour & read (5).** The wall's four grey materials sit too close in
   value to separate from each other at a glance. Concrete fix: none
   proposed here — this is a value-spacing question across an existing
   4-colour set (PEWTER/SLATE/GRAPHITE/SILVER), not a single measurement to
   change, and item #83 reports rather than repairs.
2. **Proportion (5).** The enclosure wall dominates the fight-camera-angle
   frame so completely that the floor detail the script spends the most
   code on (cut benches, stacked blocks, the half-worked block) is nearly
   invisible from it. Not fixable as a single number here either — the
   fix, if one is wanted, is a camera or wall-height decision, which is
   Nick's call.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether `look.py`'s three-quarter camera — built and calibrated against
single creature-sized assets — actually reproduces the real in-game fight
camera's framing for an asset this much wider (46 units across vs. a beast's
1–2). If the real fight camera sits closer to the beast at the ground's
centre than this capture implies, the wall may not dominate play the way it
dominates this render. This scoring pass has no way to tell without seeing
the actual in-game camera, and flags it rather than guessing either way.
