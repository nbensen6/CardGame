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

## Pass 2 — #86 duty 1

Applied both named fixes to `icons.py`'s `wall()`.

1. **Silhouette @ 42px (6).** The old `off` alternated `0.0`/`0.16` — an
   uncentred half-brick stagger. The offset rows' rightmost column sat at
   `x=0.48`; with the brick's own half-width (`0.145`) that puts its right
   edge at `0.625`, past the camera's `+-0.575` ortho half-extent
   (`FRAME = 1.15`), which is exactly why the alpha bbox sat flush at
   `x=256` before this pass. Recentred `off` to `+-0.08` on alternating
   rows instead of `0.0`/`0.16` — the relative stagger between adjacent
   rows is still `0.16`, the same running-bond offset, just centred on the
   frame instead of shifted right. Widest column now sits at `0.545`,
   margin on both edges.
2. **Mechanic match / Colour & contrast (tied 6).** The old
   `PEWTER if (row + k) % 2 else STONE` checkerboard alternated brick to
   brick with no row-to-row trend — two tones repeating, not a gradient.
   Replaced with one swatch per row, `STONE` (darkest) at the bottom rising
   through `PEWTER`, `SLATE`, to `STEEL` (lightest) at the top — sampled
   from `colormap.png` directly: `(73,75,89) -> (93,97,113) -> (108,113,137)
   -> (124,131,157)`, a real ~15-24-per-channel step between every
   adjacent row, bigger than the old two-tone's own gap and monotonic
   instead of alternating.

Rebuilt with `blender --background --python tools/blender/icons.py --
game/assets/icons` (apt's Blender 4.0.2, headless; needed `apt install
blender python3-numpy` first, same non-deterministic-WORKBENCH-output
situation every prior icon/portrait pass has hit) — diffed all 36 icons
against `HEAD` and reverted the 35 that weren't touched, keeping only
`wall.png`.

Looked at three ways: the full 256px composite over the same brown
card-face standin other batches use
(`design/renders/wall_icon_pass2_full.png`), a real 42px Lanczos downsample
nearest-neighbour upscaled for viewing
(`design/renders/wall_icon_pass2_42px_big.png`), and a black-on-white alpha
silhouette (`design/renders/wall_icon_pass2_sil.png`). Alpha bbox (Pillow
`getbbox()`) moved from `(24, 24, 256, 246)` — right edge flush against the
canvas — to `(6, 24, 250, 246)`, margin on every side now.

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 8 | 8 | 8 | **41** |

- **Silhouette @ 42px (6 → 8):** every brick in the grid, including the
  former rightmost column, is now a whole rounded-bevel shape with its own
  corner and shadow in both the full render and the 42px downsample — the
  clipped-column read named in pass 1 is gone. Not higher: it is still a
  plain uniform grid, less distinctive in outline than a shaped icon like
  `sword` or `skull`.
- **Family distinction (9, unchanged):** geometry and layout class didn't
  change, still unambiguous next to the rest of the set.
- **Mechanic match (6 → 8):** the bottom-dark-to-top-light row gradient
  reads as the wall being built up tier by tier, confirmed in both the full
  render and the 42px downsample (lightest row clearly brightest at top in
  both). Not a 9/10: the read is a colour cue, not a shape one — someone
  who has never seen a growing wall built this way could still read it as
  "textured wall" rather than "wall in progress."
- **Colour & contrast (6 → 8):** the four-row gradient gives real,
  measured separation between every adjacent row (pixel-sampled down the
  centre column of the rendered PNG: values fall from 171 near the top row
  to 62 near the bottom, monotonically) — the internal structure now reads
  from colour, not just from drop shadows, exactly what the diagnosis
  asked for.
- **Style consistency (8, unchanged):** same bevelled-slab vocabulary,
  untouched by either fix.

**+6 total (35 → 41), not a plateau — kept.** No line regressed. Both named
lines improved and Silhouette moved as a direct side effect of the framing
fix, same as `clot_toad_portrait.md` pass 2's pattern. Clears the loop's
40/50 stop line, so this is the last pass for `wall` unless a later run
finds something new to fix. `run_tests.gd`: **ALL TESTS PASSED**.
