# lightbearer — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/lightbearer.png`
(512x512). Batch 9 of #83; rubric defined in full in `frog_portrait.md`
(Framing / Identity / Readability @34px / Colour & separation / Style
consistency, 1–10 each).

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 7 | 6 | 7 | 8 | **34** |

## What is actually there

Three-quarter crop of the whole upper figure: a tall conical hood, a dark
jagged band across the face with amber dots (eyes), an amber orb set in the
chest, and a raised staff topped with a lantern, held in the left hand. A
second small amber shape sits in the right hand.

- **Framing (6):** the lantern at the top of the staff sits very close to
  the frame's top edge (little headroom above it), while there is real
  unused space on the right side of the frame the figure doesn't use —
  crop feels staff-heavy and off-balance rather than centred on the figure.
- **Identity (7):** the staff-and-lantern plus the dark visor band are this
  character's signature and both read, but backlog #75/batch-4's own
  write-up flagged a "second light" orb near the hand with no connecting
  geometry, reading as a stray floating ball — from this single three-
  quarter angle the amber shape in the right hand looks plausibly attached
  to the fingers, but a portrait alone can't confirm or clear that earlier
  finding; carried forward as unresolved, not re-verified here.
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  lantern's own structure (its frame bars) is lost, collapsing to a soft
  amber blob at the top of a thin line; the staff shaft itself thins to a
  near-invisible single-pixel diagonal. The dark visor band against the tan
  hood is the strongest surviving read at this size.
- **Colour & separation (7):** dark visor against pale tan robe separates
  well, amber accents (chest orb, hand, lantern) pop against the same tan;
  no dark-on-dark.
- **Style consistency (8):** matches the shared three-quarter, transparent-
  background convention.

## Diagnosis — two lowest

1. **Framing (6).** Concrete fix: shift the `FOCUS` crop for `lightbearer`
   left and down a little (from the current `(0.69, 0.78)`) so the empty
   space currently on the right of frame moves to a smaller margin on the
   left, centring the figure+staff group rather than the figure alone.
2. **Readability @ 34px (6).** Concrete fix: none obvious that doesn't touch
   the model itself (a bulkier lantern head would read better small, but that
   is a body-script change, out of scope for a scoring-only item).

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the right-hand amber shape is the "second light" orb ART-REVIEW
already flagged as floating with no connecting geometry, or a separate,
correctly-attached detail — this single portrait angle can't settle it; the
original finding was made looking at the full model, not this crop.

## Pass 2 — cloud, backlog #86 duty 1

Checked the alpha bounding box directly rather than trusting the pass-1
description: `(105, 57, 389, 512)` — left 105, top 57, right 123, **bottom 0**.
The bottom edge is fully opaque; the robe's lower panels are cut clean off by
the canvas, a worse problem than either line pass 1 named. Confirmed it is a
real crop failure and not a rendering fluke by projecting the model's own
vertices through the same camera math `portraits.py` uses (focus point, EYE
direction, ortho scale) without a full render: at the old `FOCUS`
`(0.69, 0.78)` the simulated content bottom lands at pixel 734 against a
512px canvas — 222px of robe below the frame, invisible regardless of what a
render shows.

Applied the framing fix only — the diagnosis's second line (lantern
structure lost at 34px) is a model change, out of `portraits.py`'s scope; see
the note added to `lightbearer.md` for the fixer lane instead.

1. **Framing (6).** Solved numerically rather than guessed: used the same
   camera-projection script to search `(at, span)` pairs until the simulated
   top and bottom margins matched (`at=0.47, span=1.15`, up from `(0.69,
   0.78)`), then rendered for real to confirm. Real alpha bbox: `(148, 26,
   364, 486)` — margins L=148, T=26, R=148, B=26, matching the simulation
   within 1px. All four edges clear for the first time, and left/right now
   land exactly even (both driven by the same bbox-centre X, which was
   already symmetric — the pass-1 write-up's "unused space on the right" read
   was the bottom-clip distorting the eye's sense of balance, not a real X
   offset).

Rebuilt with `blender --background --python tools/blender/portraits.py --
game/assets/portraits` (the full 30-portrait batch `build.cmd portraits`
runs). WORKBENCH output isn't byte-reproducible even for an unchanged FOCUS
entry, the same non-determinism `glyph_tortoise_portrait.md` pass 2 and
`silk_widow_portrait.md` pass 2 hit, so every portrait but `lightbearer.png`
was reverted with `git checkout --` and only the changed one kept.

- **Framing (6 → 9):** every edge clear with symmetric margins, both
  measured directly off the real render. Not a 10 — the zoom-out needed to
  clear the bottom leaves generous unused space on all four sides rather than
  a tight crop, which is a real cost of the fix, not free.
- **Identity (7 → 8):** the full robe, including the fluted base panels that
  pass 1's crop cut off entirely, is now visible alongside the staff-lantern
  and visor band, so the read no longer depends on a partial figure. The
  right-hand orb's attachment is still unresolved from this angle — carried
  forward unchanged, same as pass 1.
- **Readability @ 34px (6, unchanged):** confirmed via a real 34px downsample
  (`design/renders/lightbearer_portrait_pass2_34px_big.png`, Pillow
  `LANCZOS`) against the equivalent pass-1 crop. A real trade, not a free
  win: the staff and lantern frame bars are slightly smaller and no more
  legible than pass 1's already-thin read, but the robe's triangular base
  panels — invisible before, since they were off-canvas — are now visible as
  small pale flutes at the hem. Net read across the whole figure holds
  rather than improves, so the number holds rather than moving either way.
- **Colour & separation (7, unchanged):** not one of the two fixed lines, and
  no material or lighting changed — same palette, same separation.
- **Style consistency (8, unchanged):** already scored well against the
  shared three-quarter convention; this pass changed the crop's framing, not
  the angle or background convention it was already matching.

**+4 total (34 → 38), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether Framing could reach a tighter crop without reopening the bottom
clip — not attempted; the fix budget is two named lines and both moved
(Framing directly, Identity as a consequence of the same change). Also still
open: the right-hand orb attachment question pass 1 raised, since this pass
didn't touch the model and a portrait alone can't resolve it.
