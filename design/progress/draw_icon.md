# draw — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
19 — continuing the icon rubric batches 14-18 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/draw.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). Last of batch 19's
four (see `flask_icon.md` for the batch's scope and shared rubric).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-18 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 8 | 9 | 6 | 8 | **38** |

## What is actually there

Two overlapping rectangular cards, wheat behind and cream in front, both
tilted slightly off-axis, with a small gold triangle-and-slab arrow pointing
up-and-right beside them.

- **Silhouette @ 42px (7):** the two-card overlap and the arrow both
  survive the downsample as separate, identifiable shapes rather than
  fusing into one mass. Docked because the arrow's triangle head is small
  relative to the cards and loses its point at 42px, reading closer to a
  rounded wedge than a clean arrowhead.
- **Family distinction (8):** nothing else scored under this item is a
  pair of overlapping light rectangles — clearly apart from `flask`/`bomb`/
  `gadget` (this same batch) by shape alone.
- **Mechanic match (9):** two cards plus an upward arrow reads directly as
  "draw a card," about as literal a match as this item has scored — the
  arrow is what lifts it above a generic "cards" icon into an action.
- **Colour & contrast (6):** pixel-sampled directly: the card slabs range
  RGB(171,161,148) to RGB(206,196,186) against the flat brown card standin
  RGB(139,105,74) — real luminance separation on this standin (roughly
  110-183 vs 112, a genuine gap). The lower score is not about the standin,
  it's the specific risk this icon alone carries: it is a picture of a
  card, rendered in the same wheat/cream family the game's actual card
  face is built from, and this scoring script's flat standin is only an
  approximation of that face, not sampled from the real shader
  (`intangible_icon.md`'s own stated limitation). Every other icon in this
  item uses a saturated colour (purple, charcoal, orange, steel) that
  would stay visually distinct from a real card face almost regardless of
  its exact tone; `draw` is the one icon where a closer real-face match
  than this standin approximates could plausibly let the "cards" read
  blend into the card they sit on. Flagged as unconfirmed, not scored as
  a certainty.
- **Style consistency (8):** the flat bevelled-slab cards match `wall`'s
  bricks and `gadget`'s slabs (this batch); the small triangle-plus-slab
  arrow matches `climb`'s own arrow-of-triangle-and-slab construction.
  Nothing about the render is an outlier.

## Diagnosis — two lowest

1. **Colour & contrast (6).** Concrete fix: sample the real in-game card
   face colour from the shader/theme (not this script's brown
   approximation) and confirm the wheat/cream card slabs still separate
   from it by at least the margin this standin shows; if they don't,
   darken or saturate the slabs rather than the standin.
2. **Silhouette @ 42px (7).** Concrete fix: widen the arrowhead's base by
   roughly 30% so its triangular point survives the 42px downsample
   instead of rounding off.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

The real risk named in Colour & contrast above — whether the two card
slabs actually separate from the game's real card-face colour, not just
this scoring script's flat brown standin — is the one finding in this
batch that cannot be confirmed by this render alone and would need either
the real shader's colour value or, better, a screenshot of the icon on an
actual in-game card (`needs a screen`, outside this item's scope).
