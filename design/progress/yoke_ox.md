# yoke_ox — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/yoke_ox.py`.** Views: `design/renders/yoke_ox_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 6 | 6 | 7 | 7 | **31** |

## What is actually there

A boxy ox: a rectangular torso, four black-hoofed legs, a snout wedge with one
dark nostril dot, and small forward horns. A diagonal wooden bar (the yoke, per
the beast's intent — backlog #55's `height_split` limiter) crosses the back and
shoulders, with a yellow-ringed sigil set into it near the head. Reads clearly
as "boxy quadruped with something strapped across its shoulders" in the lit
views.

- **Silhouette** (`_sil.png`): the body-box-plus-four-legs reads as an animal at
  64px, but the yoke bar merges into the horn shapes into one triangular lump
  at the front — nothing in the black silhouette says "yoke" specifically, only
  "some bump near the head."
- **Proportion**: torso, snout, and legs read as bovine. The diagonal bar reads
  more like a strap slung on at an angle than a yoke built for two — a yoke is
  a straight crossbar, and this one runs corner to corner.
- **Build hygiene**: one mesh, one material, 1316/2600 tris, nothing floating.
  In the side view the yoke bar visually clips behind/through the near horn
  rather than passing clearly in front of or behind it.
- **Colour & read**: brown body, black legs, tan-wood yoke, yellow sigil — the
  sigil pops cleanly against the wood. Nothing dark-on-dark.
- **Style consistency**: rounded boxy primitives match the rest of the cast.

## Diagnosis — two lowest

1. **Silhouette (5).** The yoke bar and the horns occupy the same silhouette
   region and read as one lump. Concrete fix: drop the yoke bar's pivot down
   ~0.08 so it crosses below the horn tips rather than through them, giving the
   silhouette two separable shapes (horns above, bar below) instead of one.
2. **Build hygiene (6).** The yoke bar appears to clip through the near horn in
   the side view. Concrete fix: push the bar back in Y by ~0.05 (or shorten the
   horns by the same amount) so the two parts clear each other in depth instead
   of intersecting.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the diagonal (corner-to-corner) angle on the yoke bar is intentional
character design or should be closer to horizontal to read as a "yoke" rather
than a strap — this is a design call, not a measurement, and is named here
rather than guessed at.
