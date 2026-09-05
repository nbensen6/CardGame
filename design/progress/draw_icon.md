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

## Pass 2 — cloud, backlog #86 duty 1

Applied the silhouette fix directly; resolved the colour question by reading
the code instead of leaving it open.

1. **Colour & contrast (6).** Not a risk after all. `card_view.gd:380-386`
   shows exactly when this icon is seen: `art.texture = ICONS[...]` is only
   reached in the branch for a card with **no unique painting**, and the
   panel behind it in that case is layer 0, `ground`
   (`card_view.gd:360-369`), `Color(0.055, 0.052, 0.062)` — near-black, not
   the wheat/cream tone this scoring script's flat brown standin
   approximates. Pixel-sampled the committed render directly (Pillow,
   `alpha > 200` interior patches): the back WHEAT card averages
   RGB(199,189,178), the front CREAM card RGB(179,169,157), against the real
   ground's RGB(14,13,16) — a ~165-185-point gap on every channel, several
   times larger than the brown standin's own already-adequate margin
   (composited proof: `design/renders/draw_icon_pass2_before_realground.png`
   and `..._after_realground.png`, both showing both cards standing out
   sharply against a near-black field). The "cards blending into a real card
   face" risk this file's pass 1 flagged doesn't exist, because the real
   background here isn't a card face at all — it's the ground panel a card
   without art shows instead of one.
2. **Silhouette @ 42px (7).** `icons.py`'s `draw()`: the arrowhead's `spike()`
   base radius widened from 0.16 to 0.21 (+31%, the diagnosis's "roughly
   30%"), tip radius and length unchanged (0.02, 0.26).

Rebuilt via `blender --background --python tools/blender/icons.py --
<dir>` (apt's Blender 4.0.2, headless — needed `libegl1`/`libgl1-mesa-dri`
for the render step and `numpy`/`Pillow` in the system `python3.12`
Blender embeds, same interpreter `lift_icon.md`'s pass 2 named). Rendered
the full batch twice — once unmodified (pass 1's baseline, for a fair
before/after) and once with the fix — to two scratch directories, confirmed
via a fresh 42px Lanczos downsample that only `draw`'s silhouette changed,
then copied only `draw.png` into `game/assets/icons/`; every other
committed icon is untouched (`git status` shows exactly one modified file).
`build.cmd`'s own reimport step, run by hand: `godot --headless --path game
--import`.

Verified by looking:

- **Full 256px composite** over the brown standin
  (`design/renders/draw_icon_pass2_before_full.png` vs `..._after_full.png`):
  pass 1's arrowhead is a slim, already-slightly-rounded triangle; pass 2's
  is visibly broader at the base, the same tip position and length.
- **42px Lanczos downsample**
  (`design/renders/draw_icon_pass2_before_42px.png` vs `..._after_42px.png`):
  pass 1 rounds off into a blunt wedge with no clear point, exactly the
  finding this file's diagnosis named; pass 2 keeps a visible notch and a
  distinct triangular silhouette at the same size.
- **Alpha bbox** (Pillow `getbbox()`) moved from `(26, 31, 235, 234)` to
  `(26, 31, 245, 234)` on the 256×256 canvas — the widened base pushes the
  right edge out 10px but stays well inside the frame (245 of 256), no new
  clipping.

- **Silhouette @ 42px (7 → 8):** confirmed in the downsample comparison
  above — the arrowhead reads as a triangle again, not a rounded blob. Not
  higher: the point is still the smallest element in the icon relative to
  the two cards, so it's a secondary read rather than the first thing the
  eye lands on.
- **Colour & contrast (6 → 9):** the real-ground composite shows the
  separation is large and certain, once measured against the panel this
  icon is actually seen against rather than a flat approximation of a card
  face. Not a 10: the two card slabs (WHEAT vs CREAM) still sit close
  enough to each other in hue that they read as "two light cards" rather
  than two clearly different materials — a separate, unscored observation,
  not part of either named fix.
- **Family distinction (8), Mechanic match (9), Style consistency (8),
  unchanged:** neither fix touched composition, the arrow's meaning, or the
  shared construction vocabulary; pass 1's findings on all three still hold
  exactly as written.

**+4 total (38 → 42), not a plateau — kept. Crosses the loop's 40/50 stop
line.** No line regressed. `run_tests.gd`: **ALL TESTS PASSED** (fresh
`--import`, headless, godot 4.7.1-stable). No new tests: an icon geometry
tweak in `tools/blender/icons.py` touches nothing under `/core`, `/game`
GDScript, or any tested surface, matching every prior icon-only pass under
this item.

## Unsure about (pass 2)

Whether "two light cards" (WHEAT vs CREAM, both pale) is worth a further
colour push so the two slabs separate from EACH OTHER as clearly as they
now separate from the ground — the diagnosis this pass worked from didn't
name that as one of the two lowest lines, so it's left as a possible future
finding rather than a third fix.
