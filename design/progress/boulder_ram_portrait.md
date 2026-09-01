# boulder_ram — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/boulder_ram.png`
(512x512). Batch 10 of #83; rubric defined in full in `frog_portrait.md`.
No fixer pass exists for this asset — geometry matches the pass-1 render
`boulder_ram.md` already scored at 29/50.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 4 | 6 | 6 | 7 | **30** |

## What is actually there

A low, block-bodied quadruped in three-quarter view: a boxy clay-brown
chest, an umber shoulder hump, a lowered brown wedge head with a dark eye
dot, and dark charcoal legs. A grey-and-gold disc-on-a-rod sits on the
shoulder hump where the module doc calls for a pair of curled ram horns.

- **Framing (7):** the body fits with clean headroom above the hump and the
  legs crop naturally near the frame's bottom edge without cutting off a
  hoof mid-shape; the back-right leg sits close to the right edge but stays
  inside frame.
- **Identity (4):** reads clearly as a stocky quadruped, but not specifically
  a *ram* — this matches `boulder_ram.md`'s own finding exactly: the curled
  horn geometry renders as a flat grey-and-gold disc-with-rod rather than a
  horn from every angle, and only one is visible with no second horn
  anywhere. Without a working horn read, the identity leans toward a generic
  stone ox or boar.
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  boxy body silhouette and dark legs stay legible as a blocky animal shape,
  and the gold disc still shows as a small bright dot on the hump — enough
  to notice something is there, though at this size it reads as a decorative
  stud rather than anything specific.
- **Colour & separation (6):** clay/umber/brown/charcoal body tones separate
  cleanly and the gold disc pops against the hump, but the disc itself
  renders grey-and-gold rather than the intended TAN horn colour, the same
  mismatch `boulder_ram.md` already flagged as reading like metal rather
  than keratin.
- **Style consistency (7):** boxy stone-plate primitives sit fine beside the
  rest of the cast.

## Diagnosis — two lowest

1. **Identity (4).** Same root cause `boulder_ram.md` already names and
   proposes investigating with a dedicated close camera on the head/horn
   region — this portrait can't add anything new beyond confirming the same
   failure carries through to the 2D asset unchanged.
2. **Colour & separation (6).** Concrete fix: same as the 3D finding —
   confirm what swatch `TAN` resolves to and whether the horn's UVs land
   inside it, since the metallic grey-and-gold look persists in this render
   too.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Same open question `boulder_ram.md` already raised: whether the horn
geometry is mis-rendering (a bug) or is built as intended but simply doesn't
read as a curled horn at this poly budget from any angle, portrait crop
included. This 2D view doesn't resolve it either way.
