# clot_toad — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/clot_toad.py`.** Views:
`design/renders/clot_toad_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 4 | 6 | 5 | 6 | 7 | **28** |

## What is actually there

A squat, wide toad body with bulging gold eyes on top of a flat head, four
short bent legs, and a stepped ridge of balls running back along the spine
— two low clay mounds, a swollen brick-red gland, and a pale scab-crest
above it, with a gold sigil disc mounted beside the gland. The intent
(short wide body, eyes on top, a climbable "clot" ridge that reads as a
scab when the beast turtles below 40% HP) is legible up close, but two of
the five criteria don't survive to smaller views.

- **Silhouette** (`_sil.png`): the wide flat body reads as an amorphous
  blob rather than specifically "toad" — no leg, eye, or mouth cue survives
  at 64px, and the ridge that carries the whole climb route shows up as one
  small notch rather than a visible staircase.
- **Proportion**: up close the toad reads correctly (flat, wide, low,
  eyes-on-top), but the ridge/gland stack is nearly as tall as the body is
  wide, making the "climb route" visually dominate a creature the module
  doc calls "squat and wide."
- **Build hygiene**: 2486/2600 tris, one mesh. The sigil disc at the gland
  sits noticeably off the BRICK ball's surface in the side view — it reads
  as a small object floating beside the gland rather than mounted flush on
  it, the same "orbiting part" failure already named in `ART-REVIEW.md` for
  the Vine-Weaver and Eyrie Hawk.
- **Colour & read**: SAND/WHEAT/CREAM body tones against CLAY ridge mounds
  are close in hue and value — both read as warm tan/brown — while the
  BRICK gland and GOLD eyes do stand out. At 34px the body-vs-ridge
  distinction is likely to wash out even though gland/eyes will still pop.
- **Style consistency**: rounded ball-stack construction matches the rest
  of the cast.

## Diagnosis — two lowest

1. **Silhouette (4).** The stepped ridge/gland stack — the whole point of
   the beast, since it's the climb route — reads as a single small notch in
   the black silhouette instead of a visible staircase. Concrete fix: raise
   the two ridge mounds' Z position by ~0.15–0.20 above the torso's own top
   edge so their outline clears the body silhouette as distinct steps
   rather than merging into it.
2. **Build hygiene (5).** The sigil disc floats visibly off the gland
   ball's surface in the side view. Concrete fix: pull the `mark()` anchor
   back toward the gland ball's centre by ~0.05–0.08 along Y so the disc
   sits flush against the ball instead of hovering just off it.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the ridge-stack silhouette problem is fixable by height alone or
whether the whole climb route needs to be pulled further off the
centreline to read as a distinct shape rather than a stack directly behind
the torso — I can see the geometry is there, not whether raising it is
enough on its own without also widening the stance sideways. Also unsure
how the pale scab-crest ball reads against the WHEAT body warts scattered
on the back — both use light warm tones and I can't tell from these views
whether a player would mistake one for the other.
