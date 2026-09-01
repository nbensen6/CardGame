# gadget — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
19 — continuing the icon rubric batches 14-18 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/gadget.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). Third of batch 19's
four (see `flask_icon.md` for the batch's scope and shared rubric).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-18 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 9 | 5 | 7 | 8 | **36** |

## What is actually there

Three stacked steel/pewter slabs (wide top, narrower middle, wide bottom),
two thin carrot-orange spikes angled outward from the top slab like
antennae, and a carrot-orange ball riveted to the centre of the middle slab.

- **Silhouette @ 42px (7):** the three-tier stack stays legible as three
  distinct horizontal bands even compressed, and the two top spikes and
  centre rivet all survive the downsample as visible marks rather than
  vanishing. Docked because the overall shape reads as a generic blocky
  totem/idol rather than anything specifically mechanical — nothing in the
  silhouette itself (as opposed to colour) signals "device."
- **Family distinction (9):** nothing else scored under this item is a
  three-tier horizontal slab stack — clearly apart from `flask`/`bomb`
  (this same batch, both round-bodied) and everything scored in earlier
  batches.
- **Mechanic match (5):** the lowest line in this batch, and the reason
  for the batch's lowest total. `card_view.gd`'s comment reads "the
  Engineer builds," but a stack of grey plates with one orange rivet does
  not, on its own, suggest *building* or *construction* as an action —
  cold, without the tooltip, it reads as plausibly a small robot torso, a
  trophy, or a totem as it does "a gadget." `ART-REVIEW.md` names this
  exact risk for a neighbouring icon (`plated_armour` "reads as a cairn or
  totem"); `gadget` hits the same failure mode independently.
- **Colour & contrast (7):** pixel-sampled directly: the steel slabs range
  RGB(106,116,136) to RGB(198,163,173) against the card standin
  RGB(139,105,74) — real separation from the cool-grey hue alone, plus the
  two orange accents (spikes, rivet, roughly RGB(190,126,80)) add a second,
  warmer contrast point. Docked because the two antenna spikes are thin
  enough (a few pixels at 256px) that they read closer to hairline marks
  than solid shapes once downsampled, even though they remain visible.
- **Style consistency (8):** the same bevelled-slab construction `wall`'s
  brick grid and `climb`'s steps already use; nothing about the render
  angle or palette is an outlier.

## Diagnosis — two lowest

1. **Mechanic match (5).** Concrete fix: add one clearly mechanical detail
   that a totem/idol wouldn't have — a small gear tooth on the rivet, or a
   seam/gap line between the slabs suggesting assembled parts rather than
   a single carved block.
2. **Silhouette @ 42px (7).** Concrete fix: same as above — a
   gap/seam between the three slabs would also help the silhouette read as
   "assembled from parts" rather than "one solid stacked shape," which is
   the missing cue behind both this line's and Mechanic match's scores.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether "the Engineer builds something" is meant to depict the *act* of
building (which this render does not attempt — there's no tool, no
in-progress state) or simply *a thing the Engineer has built* (which this
render is closer to) — the comment in `card_view.gd` doesn't disambiguate,
and the two readings would call for different concrete fixes. Scored
against the more literal "does the shape itself suggest construction"
reading, the harder of the two.
