# bow — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
18 — continuing the icon rubric batches 14-17 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/bow.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). Second of batch 18's
four — the "four basic damage-type icons" (sword, bow, fire, skull); `sword`
is scored alongside it in `design/progress/sword_icon.md`.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-17 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

Same Pillow-based 42px downsample (`Image.LANCZOS`, flat brown
`RGB(139,105,74)` card-face standin) and >10-alpha-threshold bbox method
batch 17 added.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 9 | 9 | 10 | 8 | 8 | **44** |

**The best score recorded under this item across all eighteen batches**,
ahead of batch 14's `thorns` and batch 17's `strength` (both 43).

## What is actually there

A recurve bow bent into a D-shape (cream-white limb tips fading into
rust-red/orange mid-limbs, both curving toward a right-facing point), with
a horizontal string and a grey arrowhead nocked at centre, pointing right.
Alpha bbox (>10 threshold) `(58, 5, 249, 251)` — comfortable margin on all
four sides (5-7px at each edge), unlike `sword` scored alongside it, which
is flush against both top and bottom.

- **Silhouette @ 42px (9):** reads instantly as a bow-and-arrow even
  through the downsample — the D-curve, the taut string, and the
  triangular arrowhead all survive compression as distinct, separated
  shapes rather than fusing into a blob.
- **Family distinction (9):** nothing else in the set is a curved D-shape
  with a straight internal chord — clearly apart from `sword`'s single
  straight blade or anything else reviewed under this item so far.
- **Mechanic match (10):** a drawn bow with an arrow nocked for "a ranged
  strike" is as direct as icon language gets.
- **Colour & contrast (8):** the cream string and grey arrowhead read
  clearly against both the orange-red limbs and the brown card standin;
  docked only slightly because the limbs' rust-orange sits closer in hue
  to the card-face brown than the string or arrowhead do, so the limb
  outline itself relies more on its lighter highlight edge than on hue
  separation.
- **Style consistency (8):** the same bevelled-gradient limb construction
  as the rest of the set; nothing about the render angle or palette is an
  outlier.

## Diagnosis — two lowest

1. **Colour & contrast (8).** Concrete fix: none needed for legibility —
   this is the strongest score recorded under this item — but if Nick
   wants every icon to carry a hue clearly apart from the card-face brown,
   shifting the limb colour further from RUST/ORANGE toward a cooler tone
   would widen the gap.
2. **Style consistency (8).** No defect found; scored slightly below a
   perfect 10 only because this batch's rubric has no line to credit the
   comfortable, non-edge-flush framing this icon happens to have, which
   `sword` (scored alongside it) does not.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Nothing specific — this is the cleanest icon scored under this item so
far, with no open question comparable to the "orbiting part" or
"edge-flush" patterns found elsewhere in the set.
