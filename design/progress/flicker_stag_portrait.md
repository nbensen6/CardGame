# flicker_stag — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/flicker_stag.png`
(512x512). Batch 11 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 8 | 6 | 5 | 7 | **32** |

Pass 2: 8 | 8 | 6 | 5 | 7 | **34** — see below.

## What is actually there

A head-and-shoulders three-quarter crop, tighter on the body than
`eyrie_hawk_portrait`: two tall thin cream antlers reading against the white
background, a rust-brown head with a dark blue-grey block at the jaw, a gold
sigil ring at the neck, and a large rust body mass filling most of the lower
frame with no visible cream belly ball.

- **Framing (6):** the antlers get full headroom and stay inside frame, but
  the body mass is cropped tightly enough that the CREAM belly ball
  `flicker_stag.md`'s 3D pass calls out is not visible anywhere in this
  crop — the one element that pass flagged as a colour-separation problem
  isn't present to judge here at all.
- **Identity (8):** the tall thin antlers are an immediately distinctive
  silhouette against the white background and read as "stag" clearly, the
  strongest single element in this batch.
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  antlers stay visible as thin pale lines against white, which is the
  identity-carrying read; the dark blue-grey jaw block reads as an
  ambiguous dark shape near the mouth rather than anything specific, and
  the body mass below softens into one undifferentiated rust blob.
- **Colour & separation (5):** the antlers separate cleanly against white,
  but the rust head and rust body blend into one mass with no internal
  colour break, and the dark blue-grey jaw block reads closer to black than
  a distinct third colour at this size — the weakest line in this batch.
- **Style consistency (7):** head-and-shoulders convention held, though the
  crop sits tighter than `frog`/`eyrie_hawk`'s, cutting off more of the body.

## Diagnosis — two lowest

1. **Colour & separation (5).** Concrete fix: same as `flicker_stag.md`'s
   own finding — shift the belly ball's palette toward a genuinely lighter,
   less saturated cream so head and body separate by value, not just hue;
   this portrait shows the problem may be broader than just the belly ball,
   since the rust head and rust body also read as one mass here with no
   belly ball even in frame to break them up.
2. **Framing (6).** Concrete fix: loosen the `FOCUS` crop slightly to bring
   the belly ball into frame, both so this element is judgeable in the
   portrait and so it can do the colour-separating job the module doc
   intends for it in the party panel, not just the fight-camera renders.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the belly ball being entirely outside this crop is deliberate (the
portrait convention favours a tighter head shot for stags than for birds)
or an oversight in `FOCUS` — this scoring pass can see it's absent, not why.

## Pass 2 — cloud, backlog #86 duty 1

Only the **Framing (6)** line had a fix applicable in-lane. **Colour &
separation (5)** was diagnosed as a model-palette problem ("shift the belly
ball's palette toward a genuinely lighter, less saturated cream") — that is
`flicker_stag.py` geometry/material, not `portraits.py`, so left untouched,
the same split every prior pass under this item has made for its own
two-fix budget.

Applied the **Framing** fix: `portraits.py`'s `FOCUS["flicker_stag"]` moved
from `(0.80, 0.62)` to `(0.70, 0.68)` — lowered the focus point and widened
the span so the camera pulls back and down far enough to clear the belly
ball's own z-range (measured off the real mesh bounding box, `lo.z=0.0`,
`hi.z=3.6`; the belly ball sits at world z 1.46-2.14), instead of the old
crop's tight head-and-shoulders framing that centred near the antler base.

Rebuilt via apt's Blender 4.0.2, headless (EGL through `libegl1`/
`libegl-mesa0`/`libgles2`; `numpy`/`Pillow` installed for Blender's own
embedded python3.12, same setup prior passes under this item used — apt's
mirror had gone stale since the last pass and needed `apt-get update`
first, `download.blender.org` still unreachable through the proxy). No
single-portrait build path exists, so ran the full `portraits.py` batch
(all 30) and diffed every output against the committed set (mean per-pixel
diff): `flicker_stag.png` at 32.6 was a real content change; `frog.png`
(58.2) and `goblin_mech.png` (15.2) showed the same pre-existing large
diffs `brine_urchin_portrait.md` pass 2 already flagged as stale model
drift, unrelated to this pass (`FOCUS` entries for both untouched);
`yoke_ox.png` (2.6) is ordinary WORKBENCH render noise, well under every
prior pass's noise/content line. Copied only the changed `flicker_stag.png`
into `game/assets/portraits/`; every other file reverted to committed.

Verified by looking, not just by the numbers:

- **Alpha bbox** (Pillow `getbbox()`, >10 alpha threshold) moved from
  `(38, 106, 491, 512)` to `(58, 46, 478, 512)` — top margin dropped from
  106px to 46px (the frame pulled down, as intended) and the bottom is
  still flush against the canvas edge at 0 margin in both passes — an
  existing characteristic (a leg/hoof already ran off the bottom-right
  corner in pass 1's own render), not something this pass introduced or
  was asked to fix.
- **Full 512px composite** over the same brown card-face standin pass 1
  used (`design/renders/flicker_stag_portrait_pass2_full.png` vs
  `..._pass1_full.png`): pass 1 shows no cream anywhere in frame; pass 2
  shows all four legs and, cropped tight in a zoomed check
  (`/tmp/flicker_crop.png`, not committed — a scratch crop, not a new
  asset), a real pale cream mass tucked between the front legs, right
  where `flicker_stag.md`'s own 3D scoring already placed the belly ball.
- **A real 34px downsample** (Pillow `LANCZOS`, nearest-neighbour upscaled
  for viewing, same brown-standin composite): the antlers stay just as
  legible as pass 1's tighter crop, and the shape now reads as a
  four-legged standing animal rather than a head-and-shoulders bust; the
  belly ball itself is too small to register as a distinct patch at this
  size in either pass — no gain or loss there, consistent with the line
  this fix did not target.

- **Framing (6 → 8):** the belly ball pass 1 named as entirely missing is
  now in frame with real margin on three sides (top 46px, left 58px,
  right 34px) — confirmed by both the alpha bbox and the zoomed crop
  above. Not 10: the bottom is still flush against the edge (0 margin),
  the same pre-existing leg-crop characteristic pass 1's own render
  already had, just more visible now that more leg is in frame.
- **Identity (8, unchanged):** the antlers are still the dominant,
  immediately-legible silhouette element at both 512px and the 34px
  downsample; this pass's fix targeted Framing, not Identity, and showing
  more of the body didn't visibly compete with the antler read.
- **Readability @ 34px (6, unchanged):** the 34px comparison above shows
  the antler read holding steady and the belly ball too small to register
  either way — no visible change from the wider crop at this size.
- **Colour & separation (5, unchanged):** no palette or material touched;
  the belly ball being newly in-frame doesn't fix its value-closeness to
  the rust body, the model problem `flicker_stag.md` already diagnosed.
- **Style consistency (7, unchanged):** the render still uses the shared
  three-quarter, bevelled-primitive convention; a wider, more whole-body
  crop is not a new composition class in this set (`bog_leech`,
  `thrasher`, `boulder_ram` and others already use `span` > 1.0 for a
  similar whole-body read), so this line doesn't move either direction.

**+2 total (32 → 34), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED** (fresh import, headless). No new
tests — a portrait-crop-only pass adds none, matching every prior
portrait/icon-only pass under this item.

## Unsure about (pass 2)

Whether the belly ball would read as a distinct colour patch rather than
just "more of the same rust mass" to someone glancing at the 512px
portrait without already knowing it's there — the zoomed crop confirms the
geometry and cream colour are both present and unoccluded from this
camera angle, but a full-frame glance is a different read than a
deliberately zoomed-in one, and this pass didn't test that. Also unsure
whether a pass 3 spending its two-fix budget on tightening the bottom
crop (trim the now-more-visible cut legs, the same "fragment reads worse
than either extreme" principle `bog_leech_portrait.md`/`vine_weaver_
portrait.md` already named) would be worth it, or whether 34/50 is close
enough to the 40 stop line that Nick should see it before another pass —
2 of 4 passes used, 2 remain.
