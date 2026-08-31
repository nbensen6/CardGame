# mountain_climbers — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset:
`game/assets/portraits/mountain_climbers.png` (512x512). Batch 9 of #83;
rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 6 | 6 | 6 | 8 | **33** |

## What is actually there

Three-quarter head-and-shoulders crop: an orange/tan helmet, one visible eye
(the other hidden by the three-quarter turn), a pale nose/mouth shape, a
blue jacket with tan crossing straps, a brown backpack strap at the shoulder,
a blue cube (canteen) at the chest, and a pale blue triangular shard
projecting near the jaw.

- **Framing (7):** good headroom above the helmet; the backpack is partially
  cut off at the right edge, a minor loss.
- **Identity (6):** reads clearly as "a person in outdoor/climbing gear," but
  the specific "mountain climber" identity is weaker than it should be — the
  3D scoring pass (batch 5 of this item) already flagged the pale blue shard
  at the cheek as reading like a shape poking out of the jaw rather than a
  held ice axe, and that exact problem carries into the portrait unchanged:
  at this crop and angle it reads as a growth on the face, not gear.
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  helmet, single eye, and blue jacket hold up; the ice-axe shard and the
  chest canteen both lose definition — the canteen in particular sits close
  in value to the surrounding jacket blue and nearly disappears into it.
- **Colour & separation (6):** the blue canteen cube and the blue jacket are
  close enough in value that they read as one shape rather than two at
  small size; tan straps separate fine against the blue.
- **Style consistency (8):** matches the shared convention.

## Diagnosis — two lowest (tied, both named)

1. **Identity (6).** Concrete fix: none available without touching the
   model — the jaw shard is the model's own geometry, and the earlier 3D
   pass already named the same defect; out of scope for a portrait-only
   scoring item, but worth flagging that the framing choice does nothing to
   hide it — the shard sits inside the portrait crop.
2. **Colour & separation (6) / Readability @ 34px (6), tied.** Concrete fix:
   none available without touching the model's own canteen colour — named
   here as a candidate for a lighter or more saturated blue (or a contrasting
   trim colour) so it separates from the jacket at small size, a colour-only
   change that wouldn't need reworking the shape.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the ice-axe read is fixable by portrait framing alone (a different
`FOCUS_XY` angle) or needs the model's own shard reshaped — the earlier 3D
finding didn't say, and this portrait's single angle can't rule either way.
