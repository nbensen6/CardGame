# wall — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 15 — rubric and method as `design/progress/shield_icon.md` (this
batch's reference file), not repeated here. Asset:
`game/assets/icons/wall.png` (256x256). Third of the "not dying" family
(`shield`, `guard`, `wall`, `support`).

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 9 | 6 | 6 | 8 | **35** |

## What is actually there

A 4-row by 3-column grid of small dark blue-grey beveled rectangles (bricks),
offset row to row like real brickwork, uniform in size and shade throughout.
Alpha bbox `(24, 24, 256, 246)`: the right edge sits flush at x=256, the full
canvas width — the grid is clipped by the render frame on the right, unlike
`shield`, `guard` and `support`, all of which have margin on every side.

- **Silhouette @ 42px (6):** the grid pattern itself survives the downsample
  and reads clearly as "many small blocks," but the clipped right edge means
  the rightmost column's bricks lose their right-hand rounded corner and
  shadow, reading as partial/cut rather than as complete bricks like the
  rest of the grid.
- **Family distinction (9):** unambiguous next to the two kite shapes and
  the hand — nothing in this set has a comparable grid silhouette. The
  strongest line in this batch.
- **Mechanic match (6):** "wall" as a name is well served by a literal brick
  pattern. The card's actual mechanic per `card_view.gd`'s comment is "block
  that scales" — growth over time — and a uniform, evenly-shaded grid with
  no row-to-row variation doesn't suggest scaling or accumulation on its
  own; it reads as a static wall, not a wall being built up.
- **Colour & contrast (6):** the bricks read against the brown card standin
  fine, but every brick is close to the same dark blue-grey value as its
  neighbours, so the grid's internal structure (the offset brick pattern
  that should read as "wall" rather than "grid of buttons") is carried
  almost entirely by the drop shadows between bricks rather than by colour
  variation.
- **Style consistency (8):** the individual brick shape (rounded rect,
  bevelled, drop shadow) matches the shared vocabulary the rest of the set
  uses.

## Diagnosis — two lowest

1. **Silhouette @ 42px (6).** Concrete fix: pull the grid in from the right
   edge of the canvas (add the same margin the other three icons in this
   batch already have) so no column is clipped by the frame.
2. **Mechanic match / Colour & contrast (tied 6).** Concrete fix: vary
   brick shade or height from the bottom row to the top row (darker/shorter
   at the bottom, lighter/taller at the top, or vice versa) so the grid
   reads as something being built up rather than a static uniform block —
   would also improve internal contrast for free.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the right-edge clipping is a render-frame artifact specific to this
icon or a symptom of the same "not rebuilt/checked against canvas bounds"
gap batch 12's alpha-bbox check found on two portraits
(`glyph_tortoise_portrait`, `husk_beetle_portrait`) — worth checking whether
any of the other twenty-seven unscored card icons share it once that block
is scored.
