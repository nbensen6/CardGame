# gale_serpent — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. Asset:
`game/assets/portraits/gale_serpent.png` (512x512, rendered by
`portraits.py` from the 3D model). Rubric defined in full in
`frog_portrait.md`. First score for this asset — `gale_serpent` already had
a `FOCUS` entry and a committed portrait (it ships as one of the three
Frost Peak boss beasts), but no `_portrait.md` was ever written for it,
unlike its own 3D model (`gale_serpent.md`) and ground (`gale_serpent_
ground.md`). Scored and repaired in the same pass, per backlog #86 duty 1's
current rule ("this lane REPAIRS now") rather than the older score-only
convention `frog_portrait.md` and its batch used.

## Score (pass 1 — before this pass)

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 4 | 6 | 7 | 8 | 8 | **33** |

## What is actually there

A three-quarter crop on a horned, serpentine creature: a blue-grey wedge
head with two pale-silver horns (one crossing left, one standing right), two
orange eye-dots, a grey lower jaw, and a large gold ring-and-disc sigil set
into the neck. A hint of the coiled body is visible at the very bottom edge,
with one small violet fin spike poking out on the right.

- **Framing (4).** Checked the alpha bbox directly rather than trusting a
  glance: `(0, 90, 417, 512)` on the 512×512 canvas — left margin **0**,
  right margin **95**. The left edge is not empty canvas cut close; zooming
  into it (`design/renders/gale_serpent_portrait_pass1_full.png`, left-edge
  crop) shows a blue-grey tube — a horn or tusk root — sliced off mid-shape
  by the frame boundary, while 95px of dead brown standin sits unused on the
  right. The bottom is also flush (margin 0): the coiled body is cut off
  mid-torso rather than at a clean edge. Three separate framing problems in
  one crop, all traceable to the same cause below.
- **Identity (6).** The horns, gold neck ring and orange eyes read as a
  distinct creature, but with the body reduced to a sliver at the bottom
  edge, the crop reads as a floating horned head rather than the coiled
  serpent the model actually is — `gale_serpent.md`'s own 3D scoring names
  the coil and the small spine fins as identity features, neither of which
  is legible here.
- **Readability @ 34px (7).** Confirmed via a real 34px downsample
  (`design/renders/gale_serpent_portrait_pass1_34px_big.png`). The horns,
  gold ring and eyes all survive the downsample clearly — the strongest
  read of this batch's features — but there is no body silhouette left to
  read at all, consistent with the Framing finding above.
- **Colour & separation (8).** Blue-grey head/body, pale-silver horns, gold
  ring and orange eyes all separate cleanly at full size; no dark-on-dark
  pairing anywhere in frame.
- **Style consistency (8).** Matches the shared three-quarter convention on
  transparent background; nothing about the angle or palette is an outlier.

## Diagnosis — two lowest

1. **Framing (4).** Concrete fix: `portraits.py`'s `FOCUS["gale_serpent"]`
   was `(0.87, 0.44)` — a small `span` (0.44) zoomed in tight on the head,
   and an `at` (0.87) near the very top of the model's height, together
   leaving no room for the horn root on one side while wasting nearly a
   fifth of the canvas on the other. Widen `span` and lower `at` slightly so
   the camera pulls back and down, keeping the head in frame while bringing
   the coil into view.
2. **Identity (6).** Concrete fix: none needed beyond the Framing fix above —
   the coil and fin spikes already exist on the model; they are missing from
   the portrait only because the crop excludes them.

## Pass 2 — cloud, backlog #86 duty 1 (repair, same run as the score above)

Rather than guess a new `(at, span)` pair, swept both numerically and read
the real alpha bbox after each render (Blender 4.0.2 via apt — the same
route prior passes under this item used, `download.blender.org` still
unreachable through this container's proxy). Model's own vertex bbox
(measured directly, not assumed): X **-1.67..1.67**, Y **-1.58..1.58** (both
symmetric — a bbox-centre `FOCUS_XY` override is not needed here), Z
**0..5** (`tall=5`).

| Trial | at | span | bbox | L | T | R | B |
|---|---|---|---|---|---|---|---|
| baseline | 0.87 | 0.44 | (0,90,417,512) | 0 | 90 | 95 | 0 |
| t2 | 0.80 | 0.55 | (10,60,501,512) | 10 | 60 | 11 | 0 |
| t5 | 0.72 | 0.55 | (10,0,501,512) | 10 | 0 | 11 | 0 (head clips) |
| t6 | 0.78 | 0.65 | (48,75,463,512) | 48 | 75 | 49 | 0 (too much margin, smaller subject) |

`t2` (`at=0.80, span=0.55`) balances left/right almost exactly (10 vs 11px)
without clipping the head — simply widening `span` from the original's tight
0.44 fixed the left/right imbalance on its own, since the asymmetry traced
to being zoomed in past the frame's usable width, not to an off-centre
focus point. Lower `at` values (t5) reclaimed bottom margin only by
clipping the head instead, a straight trade rather than a win, so not
pursued further. The bottom stays flush (0 margin) across every trial in
this range — the coil's own lowest point sits at the model's Z floor, and
this is the same "whole-body crop, bottom flush" characteristic
`flicker_stag_portrait.md` and others already found and left alone rather
than force a trade against the head; not fixed here either.

Applied `FOCUS["gale_serpent"] = (0.80, 0.55)` in `tools/blender/
portraits.py`. Rebuilt the full 30-portrait set (no per-asset build path
exists) and diffed every output against committed by mean per-pixel
difference: `gale_serpent.png` at 41.8 was the intended change. `frog.png`
(58.2) reproduced the exact same pre-existing stale-model-drift value
`brine_urchin_portrait.md` and others already flagged (untouched `FOCUS`
entry, not this pass's doing). One new finding: `eyrie_hawk.png` diffed at
8.55 with its own alpha bbox shifting slightly (61→56 left edge) despite
its `FOCUS` entry also being untouched — higher than the ~0-2.6 noise band
every other untouched portrait showed this run, and not previously named by
any prior pass's own drift check. Not investigated further, same call
`goblin_mech_portrait.md` pass 2 made for `frog`/`thrasher`/`yoke_ox`: worth
a duty-2 look, not a duty-1 one. Reverted every portrait except
`gale_serpent.png`.

Verified by looking, not just by the numbers:

- **Full 512px composite** over the brown card-face standin
  (`design/renders/gale_serpent_portrait_pass2_full.png` vs
  `..._pass1_full.png`): pass 1 shows a horned head with a sliver of body at
  the very bottom edge and a horn root sliced off on the left; pass 2 shows
  both horns whole, the full neck ring, and the coiled body with its small
  violet fin spikes, all inside frame with visible standin on every side.
- **A real 34px downsample** (Pillow `LANCZOS`, nearest-neighbour upscaled
  for viewing, same brown-standin composite,
  `design/renders/gale_serpent_portrait_pass2_34px_big.png` vs
  `..._pass1_34px_big.png`): the horns, ring and eyes read exactly as
  clearly as pass 1's tighter crop, and the coiled body plus fin spikes are
  now visible as a distinct shape trailing off to the lower-right — a real
  gain over pass 1's "floating head," not just a wash.

Score:

- **Framing (4 → 8):** the clipped horn root and the 95px of dead space are
  both gone, confirmed by the alpha bbox (10/60/11/0) and the full-render
  comparison above. Not a 10: the bottom is still flush against the canvas
  edge, the same whole-body characteristic named above rather than something
  this fix targeted.
- **Identity (6 → 8):** the coil and fin spikes `gale_serpent.md`'s 3D score
  already named as identity features are now visible in the portrait,
  confirmed in both the full render and the 34px downsample — reads as a
  coiled horned serpent rather than a floating head.
- **Readability @ 34px (7 → 8):** confirmed by the direct pass1-vs-pass2 34px
  comparison above — the previously-legible head features are unchanged, and
  the body silhouette is a new, genuine addition to what survives the
  downsample.
- **Colour & separation (8, unchanged):** no palette or material touched.
- **Style consistency (8, unchanged):** same three-quarter convention; a
  wider crop is not a new composition class in this set (several other
  beasts already use `span` > 0.5 for a similar whole-body read).

**+7 total (33 → 40), not a plateau — reaches the loop's 40/50 stop line.**
No line regressed.

`run_tests.gd`: **ALL TESTS PASSED** (fresh `--import`, headless, Godot
4.7.1, Blender 4.0.2 apt install). No new tests — a portrait `FOCUS`-only
change adds none, matching every prior portrait/icon-only pass under this
item.

## Unsure about

Whether the still-flush bottom margin is worth a third pass trading some of
the now-generous top margin (60px) for a lower `at`, the same "close to the
stop line, is this Nick's call" question `flicker_stag_portrait.md` left
standing — not attempted here since the stop line is already met. Also
flagging `eyrie_hawk.png`'s newly-found render drift (see above) for
whoever next takes a duty-2 pass — this file did not chase it since it is
not this asset and not this duty's job.
