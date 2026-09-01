# bog_leech — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/bog_leech.png`
(512x512). Batch 10 of #83; rubric defined in full in `frog_portrait.md`.
Rendered from the model as it stands after `bog_leech.md`'s pass 2 fixer pass
(sucker-ring fattened and pulled up into the main sac).

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 5 | 3 | 5 | 7 | **26** |

## What is actually there

A squat dark-slate blob body with two smaller humps stacked on top, a gold
sigil disc set into the upper hump, four thin red ledge-shelf bars crossing
the flank, and a ring of small dark balls (the sucker-mouth) hanging at the
bottom-front of the body, most of it tucked under the main mass.

- **Framing (6):** the whole creature fits with reasonable headroom above the
  top hump, but one of the red ledge bars runs off the right edge of frame
  rather than ending inside it, and the sucker-mouth ring at the bottom sits
  close enough to the crop edge that part of it is cut rather than shown
  whole.
- **Identity (5):** reads as a dark rounded blob creature, not specifically a
  "leech" — matches `bog_leech.md`'s own finding that the stacked humps read
  as a generic snowman-stack rather than distinct fed-fat segments, and the
  sucker-mouth (the one feature the module doc calls this creature's
  identity) is visible but does not read as a mouth at this angle either.
- **Readability @ 34px (3):** confirmed via a real 34px downsample. The body
  collapses to a single dark oval with a faint gold smudge at top and a thin
  red line at the bottom — the sucker-ring, already a weak read at full size
  per the pass-2 notes, disappears entirely. Weakest read of this batch.
- **Colour & separation (5):** matches the 3D score's own finding — body and
  both humps sit in the same dark slate value range with little separation
  between them; the red ledge bars and gold sigil are the only real colour
  breaks.
- **Style consistency (7):** primitives and bevel style match the rest of the
  cast; nothing reads out of place beside other portraits.

## Diagnosis — two lowest

1. **Readability @ 34px (3).** Concrete fix: none proposable without model
   changes (out of scope) — a near-monochrome dark body has little room left
   for a 34px fix that isn't a colour or geometry change; flagging that this
   creature may need a brighter accent swatch specifically sized for
   party-panel legibility, separate from the fight-camera colour choices
   already scored.
2. **Identity (5).** Concrete fix: same root cause `bog_leech.md` already
   names — the sucker-mouth needs to read as a mouth rather than debris. A
   portrait-specific option: crop tighter on the front-bottom of the body so
   the ring gets more frame area, the way brine_urchin's tighter crop this
   batch helped its sigil read as an eye.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether a tighter, mouth-centred crop (rather than the current whole-body
composition) would fix both the framing and identity findings at once, or
whether the sucker-ring's own geometry (per `bog_leech.md` pass 2) is still
too weak a shape to read as a mouth even given more frame area — this
portrait alone can't separate a crop problem from a model problem.

## Pass 2 — fixer

Only one of the two named lines had a fix that was actually applicable here.
**Readability @ 34px (3)** was explicitly flagged as "none proposable without
model changes (out of scope)" — nothing for `portraits.py` alone to do, so
left untouched. Applied the **Identity (5)** fix: `portraits.py`'s
`FOCUS["bog_leech"]` moved from `(0.45, 1.35)` to `(0.39, 1.28)`, cropping
tighter and lower so the sucker-ring gets more frame area, per the diagnosis.

Two intermediate values were tried and rejected before this one. `(0.28,
1.00)` — a direct, aggressive "centre on the ring" crop — clipped the gold
sigil at the top edge outright (alpha bbox top = 0), trading the framing
problem this file didn't flag for a worse one it would have. `(0.36, 1.15)`
still touched the top edge (top = 0, 3px short of clipping the render but
still zero margin in the bbox). `(0.39, 1.28)` was found by backing off from
there until real headroom appeared; it keeps both the sigil and the full ring
inside frame with margin on all four sides.

Rebuilt with `build.cmd portraits` — every portrait regenerates and
Blender's WORKBENCH output isn't byte-reproducible even for unchanged
inputs (same non-determinism `thrasher_portrait.md` pass 2 and
`silk_widow_portrait.md` pass 2 both hit), so every portrait other than
`bog_leech.png` was reverted with `git checkout --` and only the changed
asset kept.

Alpha bbox (Pillow `getbbox()`) is now `(81, 12, 462, 443)` on the 512×512
canvas — margin on all four sides (top only 12px, the tightest, but present;
left 81, right 50, bottom 69) — where pass 1 was tight enough that the
sucker-ring sat close to the bottom-left crop edge and the diagnosis named a
red ledge bar running off the right edge.

- **Framing (6 → 8):** both problems pass 1 named — the ledge bar running off
  the right edge and the ring sitting close to the bottom-left edge — are
  gone; all four sides now carry real margin, even if unevenly (top tightest
  at 12px).
- **Identity (5 → 6):** the sucker-ring is visibly larger and more central in
  frame than pass 1's small, corner-crowded version — the frame-area gain the
  diagnosis asked for. Not higher: at full size the ring still reads as a
  loose scatter of dark balls and an open loop rather than unambiguously "a
  mouth," the same open question the pass-1 "Unsure about" section raised.
  Cropping alone did not resolve it.
- **Readability @ 34px (3 → 4):** confirmed via a fresh 34px downsample
  (Pillow `LANCZOS`, composited over the same brown card-face standin used in
  pass 1). The sucker-ring still does not survive as a distinct shape — same
  finding as pass 1, no fix was proposed for this line and none was applied.
  The small bump is incidental: the subject fills slightly more of the fixed
  frame, so the gold sigil reads a hair clearer.
- **Colour & separation (5 → 6):** unchanged palette, but the tighter frame
  spends more of the fixed pixel budget on the coloured sigil, red ledge
  bars, and ring, and less on flat background — same mechanism
  `thrasher_portrait.md` pass 2 named for its own colour-line gain.
- **Style consistency (7, unchanged):** composition class didn't change
  (still whole-body, not head-and-shoulders), so no change either direction.

**+5 total (26 → 31), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether the sucker-ring needs a geometry change (fatter tube, closed loop, a
darker mouth-well) to ever clear Identity/Readability past a crop's reach —
this pass confirms cropping alone hits a ceiling here, consistent with what
the pass-1 "Unsure about" section already suspected but couldn't confirm
without trying it. That would be a change to `bog_leech.py`'s model, not this
file's `portraits.py` FOCUS entry, and outside this run's two-fix budget.
