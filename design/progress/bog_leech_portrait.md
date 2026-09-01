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
