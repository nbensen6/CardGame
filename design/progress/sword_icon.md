# sword — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
18 — continuing the icon rubric batches 14-17 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/sword.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). First of batch 18's
four — the "four basic damage-type icons" (sword, bow, fire, skull), the
plainest four of the "twenty-eight card icons" block and the first not yet
scored under this item.

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
| 7 | 9 | 10 | 6 | 8 | **40** |

## What is actually there

A single vertical sword: a grey blade tapering to a point at top, a
rust-red crossguard, and a dark rust-brown grip/pommel gradient below it.
Alpha bbox (>10 threshold) `(69, 0, 187, 256)` — the blade tip is flush
against row 0 and the pommel flush against row 255, zero margin top and
bottom, the same "no margin, touching the canvas edge" pattern named for
five other icons across batches 15-17 (`wall`, `rally`, `lift`,
`dexterity`, `strength`) — six icons now across four batches.

- **Silhouette @ 42px (7):** the blade-plus-crossguard reads clearly and
  immediately as a sword even compressed, but the grip/pommel below the
  guard is a thin (a few pixels wide even at 256px) vertical sliver that
  all but disappears at 42px, leaving what reads as a blade-and-crossguard
  floating with no visible handle rather than a complete sword.
- **Family distinction (9):** nothing else in the 36-icon set is a single
  straight vertical blade shape — clearly apart from `bow`'s curve,
  `volley`, or anything else in the set reviewed so far.
- **Mechanic match (10):** a sword for "a plain attack" is the most
  direct, zero-ambiguity read available — no abstraction needed.
- **Colour & contrast (6):** pixel-sampled directly (not eyeballed): the
  grip/pommel gradient runs from RGB(173,151,143) near the guard down to
  RGB(101,56,37) at the tip, against the RGB(139,105,74) card-face
  standin — real contrast exists (the tip is genuinely darker than the
  card), but the gradient's lightest values sit close enough to the card
  colour, and the sliver is narrow enough, that it reads as barely-there
  rather than a confidently visible handle once compressed.
- **Style consistency (8):** the same bevelled-gradient construction as
  the rest of the set (e.g. `bow`'s limbs); nothing about the render is an
  outlier.

## Diagnosis — two lowest

1. **Colour & contrast (6).** Concrete fix: widen the grip/pommel to more
   than its current few-pixel width, or lighten it further from the
   card-face brown, so it survives the 42px downsample as a visible
   handle instead of a near-invisible sliver.
2. **Silhouette @ 42px (7).** Concrete fix: same as above — thickening the
   grip is what would let the whole sword (not just blade-plus-guard) read
   as one continuous object at 42px.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the top/bottom edge-flush framing (zero margin) causes a visible
hard crop once the icon sits inside the game's actual UI frame rather than
this scoring script's flat standin canvas — the same open question named
for the five other edge-flush icons in `strength_icon.md` and worth a
shared look across all six if Nick wants one fix rather than several.
