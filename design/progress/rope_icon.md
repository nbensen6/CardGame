# rope — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 16 (see `design/progress/climb_icon.md` for the full rubric and batch
setup — same rules apply here, not repeated). Asset:
`game/assets/icons/rope.png` (256x256). Last of the "six are about going up"
family scored this batch; `lift` and `rally` remain for a future batch.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 9 | 8 | 3 | 7 | **33** |

## What is actually there

A vertical stack of tan rings, each slightly narrower toward the middle,
forming a ribbed coiled-rope cylinder, with a silver ring (a carabiner) at
the top right. Alpha bbox `(35, 0, 242, 256)`: touches both the top and
bottom canvas edges — the coil runs off-frame at both ends, unlike every
other icon in this batch.

- **Silhouette @ 42px (6):** the ribbed coil shape survives the downsample
  and reads as a textured cylinder, but cold — without already knowing the
  keyword — it's ambiguous between "coiled rope" and other ribbed-cylinder
  readings (a spring, a stack of rings). The carabiner ring is the one
  element that disambiguates it toward "climbing gear," and it's small
  relative to the frame.
- **Family distinction (9):** unlike anything else in this batch or the
  "not dying" family scored in batch 15 — no other icon in the set uses a
  vertical ribbed-coil shape.
- **Mechanic match (8):** a coiled rope with a carabiner is a strong,
  on-genre read for "both hunters climb" — climbing gear specifically,
  not just "up" in the abstract the way `climb`/`ascend`'s arrows are.
- **Colour & contrast (3):** the lowest line scored in this batch and the
  worst colour-separation problem found across both families this item has
  scored. The tan rope body sits close enough in value to the brown card
  standin (`RGB(139,105,74)`) that at 42px the coil's outer edge nearly
  merges into the card face — only the silver carabiner ring stands out
  clearly.
- **Style consistency (7):** the ring-stack construction is a different
  vocabulary from the flat-faceted blocks most of the rest of the set uses
  (`climb`, `ascend`, `peak` are all built from slabs and spikes), so while
  the palette and render angle match, the shape language reads as slightly
  apart from the family.

## Diagnosis — two lowest

1. **Colour & contrast (3).** Concrete fix: darken the rope body or shift
   it away from the card-face brown (a cooler tan, or an outline), since a
   tan rope on a brown card is the closest colour match between an icon and
   its background found under this item so far.
2. **Top/bottom edge clipping.** Concrete fix: shrink the coil or extend
   the canvas margin so the rope doesn't run off both the top and bottom
   edges — every other icon scored under this item keeps its subject fully
   inside frame.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the ribbed-coil shape reads as "rope" on first sight with no
tooltip, versus needing the carabiner ring specifically to anchor the
read — this static comparison can't settle that, only in-hand testing
could.

## Pass 2 — #86 duty 1, nineteenth turn of the rotation

Applied both named fixes in `tools/blender/icons.py`'s `rope()`.

1. **Colour & contrast (3).** Swapped the coil's colour from `TAN` to `SAND`.
   Sampled both against the flat swatch atlas (`colormap.png`) before
   touching the script: `TAN` is RGB(217,152,111) against the standin
   RGB(139,105,74) — a per-channel gap of only (78,47,37); `SAND` is
   RGB(244,191,151) — (105,86,77), stronger on every channel, especially
   green and blue where `TAN` was weakest.
2. **Top/bottom edge clipping.** The old stack's outer ring (radius 0.34 at
   z=±0.42, thickness 0.22) worked out to an on-screen extent of z=±0.76 —
   the camera's ortho half-extent is 0.575 (`FRAME=1.15`), so the coil
   was guaranteed to run off both the top and bottom of the 256px frame
   before any render was taken. Rather than shrink one axis and turn the
   rings into ellipses, every ring's centre, radius and thickness — and the
   carabiner's position and size, at the same ratio — was scaled down
   together (roughly ×0.85 on radius, spacing tightened from 0.115 to keep
   the tallest ring's top edge at z≈0.52, inside frame with real margin).

Rebuilt with `blender --background --python tools/blender/icons.py --
game/assets/icons` (this container's Blender is 4.0.2 via apt — the 4.1.1
tarball is still blocked by the egress proxy here, same finding
`climb_icon.md` pass 2 recorded). All 36 icons re-rendered and, as that
same entry warned, apt Blender's antialiasing shifts every PNG's bytes even
where the build code didn't change — reverted all 35 unrelated icons with
`git checkout --` and kept only `rope.png`.

Verified two ways, not just by re-running the diagnosis's own numbers:

- **Alpha bbox.** Pillow `getbbox()` at the >10-alpha threshold this item's
  batches use: was x(35,241) y(0,255) — touching both top and bottom rows
  outright. Now x(49,222) y(13,242) — real margin on all four sides, the
  tightest being 13px top / 14px bottom out of 256 (about 5%). The raw
  any-alpha bbox on the fresh 42px `LANCZOS` downsample still shows rows 0
  and 41 as "touched", but the actual alpha there tops out at 2-4/255 —
  Lanczos ringing, not content; the >10 threshold on that same downsample
  sits at y(2,39), x(8,36), comfortably inside the 42×42 frame.
- **Pixel sample, not the raw swatch.** Sampled the RENDERED (lit,
  workbench-shaded) coil pixels directly, old vs. new PNG, both against the
  standin RGB(139,105,74): old coil averaged RGB(173,135,111), a gap of
  (34,30,37); new coil averages RGB(171,148,131), a gap of (32,43,57). Red
  barely moved — the render's own shading compresses the raw swatch gap
  more than the atlas numbers alone predicted — but green and blue both
  opened up substantially, which is the pair the old render was weakest on.

Re-viewed `game/assets/icons/rope.png` directly and the 42px downsample
composited over the card standin (`design/renders/rope_pass2_full.png`,
`rope_pass2_42px_big.png`), side by side against the same views rendered
from the pre-fix PNG (`rope_pass1_42px_big.png`, kept for the comparison,
not committed as a scored asset). The old version's coil visibly nears the
background colour along its lower and side edges, and the carabiner is cut
in half by the top of the frame. The new version holds a visible outline on
all sides and the carabiner reads as a complete ring, not a fragment.

- **Silhouette @ 42px (6 → 8):** the coil no longer runs off-frame, and the
  carabiner — the one element that disambiguates the shape as "climbing
  gear" per the pass-1 finding — is now whole instead of clipped in half.
  Confirmed in the real 42px downsample, not assumed from the full-res
  render.
- **Family distinction (9, unchanged):** geometry proportions and shape
  were preserved (a uniform scale, not a redesign); still nothing else in
  the set uses a vertical ribbed-coil silhouette.
- **Mechanic match (8, unchanged):** same composition, same read — a
  coiled rope with a carabiner still says "climbing gear" specifically.
  Neither fix touched the shape's identity, only its size and colour.
- **Colour & contrast (3 → 6):** real, measured separation gain (above),
  but not to the 45-70-per-channel bar this item's better-scoring icons
  clear on every channel — red stayed close to the standin even after the
  swatch swap, because the workbench shading darkens the lit coil's red
  channel toward the background's own. Visibly better, not solved.
- **Style consistency (7, unchanged):** the ring-stack vocabulary is
  exactly as before — this pass changed a colour and a scale factor, not
  the construction — so the "different vocabulary from the rest of the
  set" finding from pass 1 neither improved nor worsened.

**+5 total (33 → 38), not a plateau — kept.** No line regressed. Below the
loop's 40/50 stop condition, so a future duty-1 turn could pick this back
up; the concrete next fix would be the red channel specifically (a cooler,
less-red tan, or a thin darker outline on the coil, neither of which this
turn's two-fix budget covered).
`run_tests.gd`: **ALL TESTS PASSED** (fresh import, headless).

## Unsure about (pass 2)

Whether the tighter ring spacing (needed to keep the coil circular rather
than squashing it into an ellipse to fix the Z clipping) reads as more or
less "coiled" than pass 1's more separated rings — both versions read as a
ribbed cylinder in the renders checked here, but this file only compared
the two directly, not against how the change reads next to the rest of a
real hand of cards, which is a `needs a screen` question.
