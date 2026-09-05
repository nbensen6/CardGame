# vine_weaver — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/vine_weaver.png`
(512x512). Batch 9 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 9 | 8 | 7 | 8 | **38** |

## What is actually there

Three-quarter crop centred on a tree-being's canopy and upper trunk: a green
foliage mass on top, a brown trunk body below it with two amber eye-dots and
a thin black mouth slot, and four brown branch-arms ending in small green
foliage "hands" at the frame's edges. A small purple bead is visible, mostly
cut off, at the very bottom edge of frame.

- **Framing (6):** the canopy nearly touches the top edge of frame (almost
  no headroom), and the small purple bead at the bottom is cropped enough
  that it reads as an unidentifiable colour fragment rather than a shape —
  likely the sigil crest gem the 3D scoring pass (batch 4 of this item)
  already flagged as "visibly clear of the vine mass"; the portrait crop
  makes that worse by showing only a sliver of it.
- **Identity (9):** the canopy-over-trunk-with-branch-hands read is
  immediate and distinctive — the strongest, most identity-clear silhouette
  concept in this batch, no ambiguity with any other cast member.
- **Readability @ 34px (8):** confirmed via a real 34px downsample. The
  canopy/trunk colour block stays clearly separated and the tree shape
  reads fine; the face (eye-dots, mouth slot) blurs away entirely at this
  size, but the character's identity carries through the tree silhouette
  itself rather than the face, so the loss costs little.
- **Colour & separation (7):** green canopy against brown trunk separates
  cleanly; the small red mark on the canopy (visible at full size, a bud or
  leaf detail) reads as an unexplained red dot rather than anything
  specific, at both full size and 34px.
- **Style consistency (8):** matches the shared convention.

## Diagnosis — two lowest

1. **Framing (6).** Concrete fix: drop the `FOCUS` centre fraction for
   `vine_weaver` slightly (from the current `(0.77, 0.67)`) to open a little
   headroom above the canopy, and either crop the purple bead out entirely
   or open the frame enough to show it whole — a fragment reads worse than
   either extreme.
2. **Colour & separation (7).** Concrete fix: none identified that doesn't
   touch the model itself — the red canopy mark is a modelling/colour
   choice, out of scope for a scoring-only item; named here as a question
   for Nick (is it meant to read as something specific?) rather than a
   proposed pixel fix.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

What the small red mark on the canopy is meant to represent — a bud, an
eye, damage — it doesn't read as any of those specifically in this portrait.

## Pass 2 — cloud, backlog #86 duty 1

Only the **Framing (6)** line had a fix applicable in-lane. **Colour &
separation (7)** was diagnosed as a model/palette question (the red canopy
mark), not `portraits.py`, so left untouched — same split every prior pass
under this item has made for its own two-fix budget.

Applied the **Framing** fix: `portraits.py`'s `FOCUS["vine_weaver"]` moved
from `(0.77, 0.67)` to `(0.74, 0.85)` — lowered the focus point slightly and
widened the span (zoomed out) so the frame both opens headroom above the
canopy and pulls the bottom edge down past the lilac vine-flower bead's own
z-range, instead of the old crop that put the bead almost exactly on the
cutoff line.

Rebuilt via apt's Blender 4.0.2, headless (`libegl1`/`libgles2` installed,
system `python3.12` needed `numpy`/`Pillow` added via pip — same setup prior
passes under this item used; `download.blender.org` unreachable through the
proxy, apt's mirror worked). No single-portrait build path exists, so ran
the full `portraits.py` batch (all 30) and diffed every output against the
committed set (mean per-pixel diff): `vine_weaver.png` at 36.85 was a real
content change; `frog.png` (58.2) is the same pre-existing stale-model-drift
noise `flicker_stag_portrait.md`/`brine_urchin_portrait.md` already flagged
(its `FOCUS` entry untouched); everything else sat at 0–2.6, ordinary
WORKBENCH render noise. Copied only the changed `vine_weaver.png` into
`game/assets/portraits/`; nothing else touched.

Verified by looking, not just by the numbers:

- **Alpha bbox** (Pillow `getbbox()`, >10 alpha threshold) moved from
  `(0, 93, 478, 512)` to `(34, 110, 431, 512)` — the left edge, flush at 0
  in pass 1 (the left branch's foliage ball touched it), now has 34px of
  clearance, and the right margin grew from 34px to 81px. The bottom stays
  flush at 512 in both passes, but for a different reason: pass 1's bottom
  edge cut through the face, both hands and the bead all at once; pass 2's
  only touches the very tip of the left hand's fingers (confirmed with a
  zoomed crop, `/tmp/bottom_crop.png`, not committed — a scratch check, not
  a new asset) — a peripheral limb-tip crop, the same convention several
  other cast portraits already use at their own bottom edge, not a new
  failure this pass introduced.
- **Full 512px composite** over the same brown card-face standin pass 1
  used (`design/renders/vine_weaver_portrait_pass2_full.png` vs
  `..._pass1_full.png`): pass 1 shows the bead as a thin coloured sliver
  right at the bottom edge with both hands cut off entirely; pass 2 shows
  the bead as a whole small purple ball with clear margin below it, and
  both arms/hands fully in frame.
- **A real 34px downsample** (Pillow `LANCZOS`, nearest-neighbour upscaled
  for viewing, same method pass 1 used): pixel-sampled the composite rather
  than eyeballing it — the most blue-shifted pixel in the frame is
  RGB(153,139,186) at (11,28), a real lilac tone distinct from the
  surrounding greens and browns, confirming the bead survives as a small
  but genuine colour fleck at party-panel size, where pass 1's edge-sliver
  version was mostly anti-aliased away.

- **Framing (6 → 8):** both named problems are gone — real headroom above
  the canopy on top, left and right, and the bead is a whole shape instead
  of a fragment. Not 10: the left hand's fingertips still touch the bottom
  edge, the residual crop named above.
- **Identity (9, unchanged):** not one of the two fixed lines; the
  canopy-over-trunk-with-branch-hands read was already the strongest in its
  batch and showing more of the arms doesn't compete with it, but this pass
  didn't target it and Identity was already near the ceiling.
- **Readability @ 34px (8, unchanged):** the tree silhouette reads the same
  as pass 1 at this size — slightly smaller now that the frame pulled back,
  offset by the bead now surviving as a real colour fleck rather than an
  edge artifact (pixel-sampled above). No clear net gain or loss either
  way, so left where pass 1 scored it rather than guessed up.
- **Colour & separation (7, unchanged):** not one of the two fixed lines,
  and no palette or material touched — the red canopy mark question from
  pass 1 stands exactly as it was.
- **Style consistency (8, unchanged):** still the same three-quarter,
  bevelled-primitive convention on a transparent background; pulling the
  crop back to show more of the body is not a new composition class (`bog_
  leech`, `boulder_ram` and others already use a wider, more whole-body
  span), so this line doesn't move either direction.

**+2 total (38 → 40), reaching the 40/50 stop line — kept, stop here.** No
line regressed. `run_tests.gd`: **ALL TESTS PASSED** (fresh import,
headless). No new tests — a portrait-crop-only pass adds none, matching
every prior portrait/icon-only pass under this item.

## Unsure about (pass 2)

Whether the left hand's fingertip touching the bottom edge is worth a
further pass — three of four passes remain unused, but 40/50 is this
item's own stop line and the residual crop is a peripheral limb tip, not an
identity-carrying feature, the same class of "good enough" crop several
other cast portraits already ship with at their own edges.
