# grove_bear (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 7. Filed as `grove_bear_ground` rather than `grove_bear` because a
beast of the same name already exists in `game/assets/3d/cast/`. **Scoring
pass only — item #83 is report, not repair; no edits made to
`tools/blender/env/grove_bear.py`.** Views:
`design/renders/grove_bear_pass1_*.png`, captured with
`look.sh env grove_bear 1`. **6300 tris against the 3600 ground budget —
75% over, the largest overage found under this item so far, worse than
`shifting_idol_ground`'s 53% scored in this same batch.**

Same rubric adaptation as the other scored grounds: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 4 | 3 | 5 | 5 | **23** |

## What is actually there

A ring of conifer trees (trunk-and-cone, thin trunks) surrounds a green
moss floor with scattered mossy-boulder shapes. This is the **third**
ground scored under this item built from the same recipe as
`bramble_hog_ground` and `root_lurker_ground` — a conifer ring around a
small hollow — and reads as visually close to both, not just structurally
similar. `_top.png` shows the moss floor and boulder scatter clearly
(matching the docstring's "deep moss, ferns, mossy boulders"), but `_34.png`
and `_side.png` show the same gap named for the other two conifer grounds:
the trunk ring narrows the visible floor to a small patch in the centre gap,
and no fern or moss texture is distinguishable at that distance — it reads
as generic green mounds.

- **Silhouette** (`_sil.png`): a bumpy, uneven pine-cone crown — legibly
  "forest," but close in overall shape to `bramble_hog_ground`'s and
  `root_lurker_ground`'s silhouettes, which used the same tree primitive.
- **Proportion**: the moss/boulder floor is visible in the centre gap of
  `_34.png`, better than the fully-blocked stone-wall grounds, but the
  docstring's specific goal — "you should half lose [the beast] against the
  treeline" — cannot be judged from a ground-only render with no beast
  present to check the camouflage claim against.
- **Build hygiene (3, lowest line scored this batch, tied with
  `shifting_idol_ground`).** 6300 tris against a 3600 budget is a 75%
  overage, the largest found under this item across seven batches,
  surpassing `shifting_idol_ground`'s 53% scored earlier in this same
  batch. No floating geometry found otherwise.
- **Colour & read**: GREEN/MINT trees against a GREEN moss floor separate
  reasonably at this render distance, and there is no dark-on-dark problem
  — but green-on-green is inherently lower-contrast than the stone
  grounds' grey-on-grey-with-accent approach, and this is now the third
  green conifer ground scored, so the palette is doing less differentiating
  work across the set than the varied stone/ice/ruin grounds scored
  earlier in this same batch.
- **Style consistency**: consistent Kenney low-poly build, but the third
  near-identical "conifer ring around a green hollow" ground scored under
  this item — style consistency *within the family* is strong, but that
  same repetition is starting to work against the "distinct place per
  beast" goal the ART-REVIEW notes have been tracking since batch 5.

## Diagnosis — two lowest

1. **Build hygiene (3).** 6300 tris is 2700 over the 3600 ground budget
   (75%), the largest overage found under this item, worse than
   `shifting_idol_ground`'s 53% scored in the same batch. Concrete fix:
   none proposed here; item #83 reports rather than repairs, but two grounds
   in one batch both breaking budget by more than half is a pattern worth
   flagging on its own rather than as two isolated findings.
2. **Proportion (4).** Whether this ground actually delivers on its
   specific design goal — the beast half-disappearing against the
   treeline — cannot be verified from a ground-only render; that claim
   needs the beast placed in the scene to check, which is outside what this
   capture shows. Not applying a fix — flagged rather than diagnosed
   further.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether `grove_bear`, `bramble_hog_ground`, and `root_lurker_ground` sharing
one conifer-ring recipe is a deliberate reuse (three "forest" beasts fought
in genuinely the same forest, which could be an intentional worldbuilding
choice) or an unintended repeat — cannot tell from the script alone, and
this item does not judge intent, only report. Also unsure, as with every
ground scored under this item, whether `look.py`'s single-creature camera
framing matches the real in-game fight camera.
