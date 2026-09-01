# strength — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
17 — continuing the icon rubric batches 14-16 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/strength.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). First of
batch 17's four — `design/ART-REVIEW.md`'s own **"Strength and Dexterity
icons"** section, scored as a pair; `dexterity` is scored alongside it in
`design/progress/dexterity_icon.md`.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-16 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

Same Pillow-based 42px downsample (`Image.LANCZOS`, flat brown
`RGB(139,105,74)` card-face standin) and alpha-bbox method as batches 14-16,
plus a >10-alpha threshold pass this batch adds to separate "touches the
edge" from "actually clipped there."

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 9 | 9 | 9 | 8 | 8 | **43** |

**Tied for the best score recorded under this item across all seventeen
batches**, matching batch 14's `thorns` at 43.

## What is actually there

A dumbbell, exactly as `ART-REVIEW.md`'s own build note describes: two dark
charcoal/graphite ringed weight plates, one at each end, joined by a rust-red
bar with a gold grip wrap at centre. Alpha bbox `(0, 69, 255, 186)`: both the
leftmost and rightmost columns are fully opaque — the plates are cropped
flush against both side edges of the 256px canvas, with zero margin, the
same clipping pattern this batch's own `rally` also shows (see
`rally_icon.md`).

- **Silhouette @ 42px (9):** reads instantly and unambiguously as a
  dumbbell even through the downsample — two dark round masses joined by a
  bar is a strong, simple shape that survives heavy compression better than
  anything else scored this batch.
- **Family distinction (9):** nothing else in the 36-icon set is a
  symmetric plates-on-a-bar shape; it can't be mistaken for `sword` (one
  blade), `bomb` (one central ball), or anything else reviewed under this
  item so far.
- **Mechanic match (9):** a dumbbell for "gain Strength, adds to every
  attack" is about as direct as icon language gets — a real-world strength-
  training object standing in for the stat, no abstraction required to
  read it.
- **Colour & contrast (8):** the near-black plates and warm rust/gold
  centre read clearly against the brown card standin; docked slightly only
  because the plates' dark grey-on-charcoal shading is the same tonal
  family as several other icons in the set (`guard`, `wall`'s STEEL/PEWTER
  tones), so it isn't a colour unique to this icon the way, say, `thorns`'
  saturated green is.
- **Style consistency (8):** the same bevelled-ring-and-bar construction as
  the rest of the set; nothing about the render is an outlier.

## Diagnosis — two lowest

1. **Colour & contrast (8).** Concrete fix: none needed for legibility —
   this is the strongest score in the batch — but if Nick wants every icon
   to carry a colour unique to it the way `thorns` (saturated green) or
   `intangible` (fading tiles) do, warming the plate colour slightly off
   the STEEL/PEWTER family already used by `guard`/`wall` would do it.
2. **Style consistency (8).** No defect found; scored slightly below a
   perfect 10 only because this batch has no line for "build hygiene" to
   carry the edge-flush clipping noted above — see Unsure about, below,
   for why that isn't folded into this line instead.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

The plates are cropped flush against both left and right canvas edges (see
alpha bbox above) — the same "no margin, touching the edge" pattern batch
15 found on `wall` (also flush against its right edge) and this batch's own
`rally`/`lift`/`dexterity` all show in one direction or another, five icons
now across three batches. This file scored it as a soft aside rather than
docking any of the five rubric lines for it, since at 42px the plates still
read cleanly as a dumbbell with the edge-flush not visible as a hard crop —
but whether it causes a visible hard edge once the icon sits inside the
game's actual UI frame (`card_view.gd`'s 30x30 rail size, or the larger
hand-card art slot) rather than this scoring script's flat standin canvas
is exactly the thing a render here can't answer. Worth a shared look across
all five if Nick wants one fix rather than several.
