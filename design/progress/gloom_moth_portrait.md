# gloom_moth — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/gloom_moth.png`
(512x512). Batch 12 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 7 | 6 | 7 | 8 | **35** |

Best of this batch, and the best-scoring beast portrait so far (ahead of
`eyrie_hawk_portrait`'s 35 by rubric-line spread, not just total).

## What is actually there

Head-and-shoulders crop, three-quarter angle: a large purple wing-hump
over a black-blue thorax, a rounded black head with one blue eye-dot and
an orange curled proboscis, two thin antennae, and a small gold sigil disc
riding one antenna near the head. Alpha bounding box `(50, 44, 429, 512)`
— comparable margins to `frog_portrait`'s (59, 50, 506, 512), the
best-framed portrait scored under this item.

- **Framing (7):** headroom above the wing-hump, sigil and both antennae
  fully inside frame, body cut at the bottom edge in line with the
  cast-wide crop convention. Not an 8+: the wing-hump sits slightly
  off-centre toward the left, leaving a touch more dead space on the
  right than the tightest-framed portraits.
- **Identity (7):** the purple hump plus black head with orange proboscis
  reads as insectoid and distinct from the cast's other bug beasts
  (husk_beetle, brine_urchin) by colour alone, though the wing-hump shape
  itself doesn't add a moth-specific cue beyond colour.
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  purple hump and black head stay separated as two shapes, and the eye-dot
  survives as a small blue fleck; the gold sigil on the antenna and the
  orange proboscis both blur into indistinct smears at this size — the
  same "small sigil against a dark antenna could wash out at 34px" risk
  `gloom_moth.md`'s 3D pass flagged is confirmed here.
- **Colour & separation (7):** purple against black/blue thorax separates
  clearly; the blue eye-dot pops against the black head. No dark-on-dark
  failure, though purple and the near-black thorax sit closer in value
  than the cast's brighter colour pairs.
- **Style consistency (8):** matches the shared three-quarter
  head-and-shoulders convention on a transparent background cleanly.

## Diagnosis — two lowest

1. **Readability @ 34px (6).** Concrete fix: this is the same sigil-on-
   antenna placement `gloom_moth.md`'s 3D pass already flagged (Build
   hygiene 6/10) proposing to slide the disc toward the head — doing so
   would also move it into a higher-contrast area of the portrait crop,
   which should help the 34px read as a side effect.
2. **Framing (7).** Concrete fix: nudge `portraits.py`'s `FOCUS` centre
   slightly right (the wing-hump currently sits left-of-centre) to balance
   the dead space on the right edge.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the orange proboscis is meant to read as a distinct feature at
party-panel size — at 34px it all but disappears into the black head, so
if it's meant to be an identity cue (the way the eyespot marking is
called out as one in `gloom_moth.md`) this crop and size don't carry it.
