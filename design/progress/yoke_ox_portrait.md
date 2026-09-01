# yoke_ox — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/yoke_ox.png`
(512x512). Batch 13 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 4 | 5 | 3 | 6 | 5 | **23** |

Lowest portrait scored under this item so far, below `clot_toad_portrait`'s
24.

## What is actually there

Alpha bounding box `(0, 19, 512, 512)` — touches the left, right, and bottom
edges of the canvas at once, with clearance concentrated almost entirely at
the top. A tight crop centred on the crossing tan-wood yoke bar and horns
over the shoulders, the yellow-ringed sigil set into the bar, a wedge snout
with one dark nostril dot at bottom-left, and black legs at the bottom edge.

- **Framing (4):** three of four canvas edges are touched at once (legs and
  horn/yoke ends cut off left, right, and bottom), tighter than
  `husk_beetle_portrait`'s single-edge touch and close to
  `silk_widow_portrait`'s all-four-edges crop this same batch.
- **Identity (5):** the crossing tan-wood shapes dominate the frame and read
  as a busy brown-on-brown jumble rather than legibly "a yoke across an ox's
  shoulders"; the snout with its nostril dot is present but pushed to the
  bottom-left corner, small in frame. This crop centres exactly on the
  region `yoke_ox.md`'s own 3D pass already flagged — "the yoke bar merges
  into the horn shapes into one triangular lump" — making that merge the
  whole picture rather than one detail among several.
- **Readability @ 34px (3):** confirmed via a real 34px downsample — the
  yellow sigil sits close enough in value to the surrounding TAN wood that
  it nearly disappears into the wood grain, and the crossing wood pieces
  read as indistinct light streaks across a brown mass rather than any
  identifiable shape. Lowest Read@34 score recorded under this item so far.
- **Colour & separation (6):** the black legs read cleanly against the
  RUST/brown body where visible, matching `yoke_ox.md`'s own "nothing
  dark-on-dark" 3D finding — but the TAN yoke bar and YELLOW sigil sit close
  enough in hue to blend at both full size and 34px, a colour-separation
  problem the wider 3D render, viewed from further back, did not surface
  (its own Colour & read line scored 7).
- **Style consistency (5):** framing this tightly on the crossing wood
  shapes departs from the head-and-shoulders convention the stronger-scoring
  portraits hold to, the third framing outlier named this batch alongside
  `thrasher_portrait` and `silk_widow_portrait`.

## Diagnosis — two lowest

1. **Readability @ 34px (3).** Concrete fix: give the sigil ring a lighter
   or higher-contrast swatch against the TAN wood (e.g. the model's own
   GOLD rather than YELLOW-on-TAN) so it survives downsampling; this is a
   colour problem the portrait crop alone cannot fix.
2. **Framing (4).** Concrete fix: pull `portraits.py`'s `FOCUS` back and
   recentre slightly downward so the snout and nostril get more frame share
   relative to the wood-and-horn tangle, and so legs/horn-ends stop being
   cut at three edges at once.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the yellow-sigil-on-tan-wood value clash is a portrait-crop framing
problem or a genuine model/material choice that would look the same at any
crop — this pass can see the values sit close, not which swatch was
intended to read as "the marking" versus "the wood."

---

## Pass 2 — fixer lane, 2026-09-01

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports.

Both diagnosed fixes named above were adapted rather than applied literally,
because both, as literally worded, ran into a hard constraint from
`tools/fixer/BRIEF.md`: "do not change a budget, a contract or a shared
constant to make a fix pass." The GOLD taper and AMBER ring the diagnosis
calls "the sigil ring" are drawn by `beast.py`'s shared `mark()` helper —
"the same gold mark every beast wears" — with the colours hardcoded in that
one shared function, not passed in per-beast. There is also no `YELLOW`
swatch in `kenney.py`'s palette at all; the sigil was already GOLD, exactly
what the diagnosis suggested switching to. Editing `mark()` to change the
colour would recolour the sigil on all nineteen cast members, which is out
of lane and out of scope for one asset.

1. **Readability @ 34px (3).** Diagnosis' intent — separate the sigil from
   its surroundings — applied through the one piece of that geometry that
   *is* per-asset: the small mounting plate `yoke_ox.py` builds behind the
   sigil (`b.box((0.20, -1.00, _sigil_z), ..., SAND, ...)`). Measured the
   actual palette RGB values in `colormap.png` before touching anything:
   `GOLD (255,192,68)` has a relative luminance of ~196 against `SAND
   (244,191,151)`'s ~199 — a near-exact match, which is *why* the sigil
   nearly disappeared, not a vague "looks close" call. Swapped the plate
   from `SAND` to `CHARCOAL (56,56,61)`, luminance ~57, already imported in
   this file and already used on the legs and strap loops (so it reads as
   "metal fitting," not a random new colour). `GOLD`-on-`CHARCOAL` is a
   ~140-point luminance gap instead of a 3-point one.
2. **Framing (4).** `portraits.py`'s `FOCUS["yoke_ox"]` moved from
   `(0.55, 1.00)` to `(0.45, 1.25)` — centre pulled down toward the snout
   and the span widened, in line with the fix's own wording ("pull FOCUS
   back and recentre slightly downward").

Rebuilt with `build.cmd yoke_ox` (colour-only change; tris/holds/climb
points unaffected, `run_tests.gd`-relevant contract untouched — build log
confirms `CLIMB` percentages match the pre-fix numbers), then `build.cmd
portraits`. All nineteen portraits re-rendered non-reproducibly at the byte
level (same non-deterministic WORKBENCH output every prior 2D fixer pass
hit); reverted every file except `yoke_ox.png` with `git checkout --`.

Re-viewed `game/assets/portraits/yoke_ox.png` directly, a real 34px
downsample (Pillow, `Image.LANCZOS`), and an alpha-bbox check, the same
method `frog_portrait.md` established.

| Pass | Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 4 | 5 | 3 | 6 | 5 | **23** |
| 2 | 7 | 7 | 7 | 7 | 6 | **34** |

- **Framing (7):** alpha bbox is now `(25, 27, 512, 465)` — real margin on
  three of four sides (left 25px, top 27px, bottom 47px); only the right
  edge still touches, and what touches it there is the barrel chest's own
  curve, not a limb or horn end. Down from three edges touching to one,
  matching the single-edge-touch convention the better-scoring portraits in
  this batch use. Not an 8+: the margins aren't evenly balanced (top is
  tighter than bottom).
- **Identity (7):** the snout, both eyes' worth of face, and a visible foreleg
  are now fully in frame with real headroom, instead of the muzzle being
  squeezed into the bottom-left corner. The wood/horn crossing is still the
  dominant shape in the upper two-thirds of the frame — this crop does not
  fix that the yoke and horns visually merge, `yoke_ox.md`'s own 3D finding
  — so it reads as "an ox under a wooden yoke" rather than a clean single
  read, held below 8.
- **Read@34px (7):** confirmed via a real 34px downsample. The sigil now
  holds as a distinct dark-ringed gold disc, clearly separated from the
  wood around it — the specific failure pass 1 named. The wood-on-wood
  crossing shapes (yoke beam vs. horns, both still light warm tones) still
  read as an indistinct light mass at this size, which is why this isn't a
  9 — the fix solved the sigil, not the wider TAN-on-SAND-on-BROWN read.
- **Colour & separation (7):** the sigil now separates cleanly from its
  plate at both full size and 34px, the specific gap pass 1 named. Legs
  against the RUST/brown body remain clean, unchanged. Held below 8: the
  SAND yoke beam and TAN horns are still close enough in hue that they read
  as one wood mass, an untouched pre-existing softness this pass's two
  fixes didn't target.
- **Style consistency (6):** the crop now sits much closer to the
  headroom-plus-single-edge convention the stronger portraits use, up from
  the tightest three-edge crop in the batch. Not higher: the framing is
  still tighter and more crossing-shape-dominated than the cleanest
  head-and-shoulders portraits (e.g. `frog_portrait`).

**+11 total (23 → 34), not a plateau — kept.** Both named rubric lines
improved by 4 points each; Identity and Style moved as a consequence of the
same two fixes; nothing was touched beyond the plate colour and the FOCUS
tuple. `run_tests.gd` passes.

## Unsure about, still

Whether the yoke-beam/horns wood-on-wood softness (still holding Read@34px
and Colour at 7, not higher) is worth a third pass — that would mean either
recolouring the yoke beam itself (currently `SAND`, chosen deliberately per
`yoke_ox.py`'s header comment "so it reads as a separate, carried object")
or lightening the horns, both of which read as the kind of geometry/material
call this pass's two named fixes didn't cover and the next diagnosis should
decide, not this one.
