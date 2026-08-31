# root_lurker (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 6. Filed as `root_lurker_ground` rather than `root_lurker` because a
beast of the same name already exists in `game/assets/3d/cast/`. **Scoring
pass only — item #83 is report, not repair; no edits made to
`tools/blender/env/root_lurker.py`.** Views:
`design/renders/root_lurker_pass1_*.png`, captured with
`look.sh env root_lurker 1`.

Same rubric adaptation as the other scored grounds: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 5 | 6 | 5 | 6 | **28** |

## What is actually there

A ring of conifer trees, close kin to `bramble_hog_ground`'s treeline,
surrounds a small brown hollow. `_top.png` shows the hollow floor: a
rust-brown disc scattered with thin dark root-like sticks and a few small
green tufts near the rim. `_side.png` shows a small extra cluster of
low, cone-shaped bushes sitting right at the hollow's centre, in front of
(and shorter than) the surrounding trees — the ambush prop the beast is
meant to hide among.

- **Silhouette** (`_sil.png`): a spiky treeline silhouette effectively
  identical in shape to `bramble_hog_ground`'s — both use the same conifer
  vocabulary, and there is nothing in this silhouette that reads as
  specifically "root lurker" rather than "generic pine ring." The two
  grounds risk being indistinguishable by silhouette alone, which matters
  because the ART-REVIEW note for this batch of grounds explicitly asks
  whether they read as fourteen distinct PLACES.
- **Proportion**: the small bush cluster at centre is visible from
  `_side.png`, unlike the fully-hidden floor detail in the two stone
  grounds, but it is small relative to the treeline and does not obviously
  read as "roots breaking the surface and going back under" — the specific
  image in the script's docstring. From this camera distance it reads as
  a small shrub, not as root structures.
- **Build hygiene**: the trees are evenly varied in height and spacing
  with no floating geometry. The root/mushroom props described in the
  script (`root()`, presumably a mushroom helper further down the file)
  are too small and too far from camera to inspect for hygiene in any of
  the six views.
- **Colour & read**: same GREEN-vs-UMBER/CHARCOAL separation as
  `bramble_hog_ground`, which works well for tree-vs-floor but leaves the
  floor itself close to a flat brown field once the (likely BROWN) root
  sticks are too small to register at this distance.
- **Style consistency**: sits fine beside `bramble_hog_ground` as "another
  forest floor," which is a problem rather than a strength here — the
  script's own docstring stresses this beast's whole gimmick is "you
  cannot tell which knot [is the beast]," so a ground that itself looks
  near-identical to its forest neighbour undercuts rather than supports
  that idea.

## Diagnosis — two lowest

1. **Colour & read (5).** Whatever root and mushroom detail the script
   scatters across the floor is too small or too close in value to the
   UMBER base to register from fight-camera distance — the hollow reads as
   one flat brown disc, same as `bramble_hog_ground`'s floor. Concrete fix:
   none proposed here; item #83 reports rather than repairs.
2. **Proportion (5).** The specific "roots breaking the surface" identity
   the script's docstring calls for is not distinguishable from a generic
   small shrub at this camera distance, and is nearly absent from the
   angled views entirely. Not applying a fix — flagged rather than
   diagnosed further.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether `root_lurker_ground` and `bramble_hog_ground` are meant to look
this similar (both are forest-floor hollows ringed by near-identical
conifers) or whether the similarity is itself a defect worth flagging as a
set-level finding, alongside the ART-REVIEW batch note's own question about
whether the fourteen grounds read as fourteen distinct places. Also unsure,
as with the other grounds scored, whether `look.py`'s single-creature
camera framing matches the real in-game fight camera for an environment
this wide.
