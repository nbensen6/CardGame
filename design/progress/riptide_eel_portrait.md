# riptide_eel — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/riptide_eel.png`
(512x512). Batch 12 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 5 | 6 | 5 | 7 | 6 | **29** |

Pass 2: 8 | 8 | 7 | 7 | 7 | **37** — see below.

## What is actually there

A long dark navy neck and head, tilted three-quarter, with a gold-ringed
sigil and grey climbing holds visible lower in frame. Alpha bounding box
`(138, 143, 503, 512)` — a large empty margin at top-left (138px, 143px)
with the head and neck pushed into the bottom-right, right and bottom
edges nearly touching (503/512 and exactly 512).

Zoomed on the head region to check a detail the thumbnail suggested: the
head has two eyes, but they are not both mounted on the head surface. The
near eye sits correctly on the cheek; a second eye of the same size and
colour floats in open air above and to the left of the snout, with visible
background between it and any part of the head. Checked this against the
existing 3D render kept from `riptide_eel.md`'s own pass
(`design/renders/riptide_eel_pass1_34.png`) — the same detached far eye is
visible there too, so this is a real model geometry issue, not a
portrait-specific camera or crop artifact. `riptide_eel.md`'s written
scoring never named it (it only describes "yellow eyes" without flagging
a mounting problem), so this is a genuine new finding this batch is
surfacing, not a re-read of an already-known issue.

- **Framing (5):** no clipping (unlike `glyph_tortoise_portrait` and
  `husk_beetle_portrait` this batch), but the subject occupies only the
  bottom-right half of the canvas, leaving a large, asymmetric dead zone
  at top-left rather than balanced headroom.
- **Identity (6):** the long neck and head read as serpentine/eel-like,
  but the floating detached eye is a visible oddity that undercuts
  confidence in the read rather than supporting it.
- **Readability @ 34px (5):** confirmed via a real 34px downsample. The
  floating eye survives as a small stray dot clearly separate from the
  head shape — at this size it reads as visual noise (an extra fleck)
  rather than as "an eye," and someone not already told what it is would
  not identify it as part of the face.
- **Colour & separation (7):** the dark navy head/neck separates well
  from the gold sigil and eyes; no dark-on-dark problem in this crop,
  unlike the near-black-body concern `riptide_eel.md`'s 3D pass raised
  for the full body (not visible in this closer head-and-neck crop).
- **Style consistency (6):** the head-and-shoulders convention is present,
  but the large unused top-left area, and the two other subjects scored
  this batch (`glyph_tortoise_portrait`, `husk_beetle_portrait`) all
  showing their own distinct framing problems, keeps this from matching
  the tighter, well-centred crop `frog_portrait` and `gloom_moth_portrait`
  set as the convention.

## Diagnosis — two lowest

1. **Readability @ 34px (5).** Concrete fix: this line is driven entirely
   by the floating far eye — reseating it onto the head surface (or
   confirming it is a portrait-specific render artifact and re-rendering)
   would likely lift this line and Identity together, since both name the
   same cause.
2. **Framing (5).** Concrete fix: re-centre `portraits.py`'s `FOCUS` entry
   for this asset — shift it down-right toward where the head actually
   sits, or widen the crop, to remove the large empty top-left margin.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Nothing about whether the floating eye is real — confirmed against the
kept 3D render above. Unsure why `riptide_eel.md`'s own scoring pass
didn't name it despite having the same evidence available; worth a note
that a rubric line ("Build hygiene") doesn't guarantee every visible
defect gets written down if the scorer's attention was on other parts.

## Pass 2 — #86 duty 1

Applied both named fixes. In-lane: one is a model geometry edit in
`tools/blender/riptide_eel.py`, but its effect is judged entirely through
this flat, headless-rendered portrait (per `design/BACKLOG.md` #86's own
tier split — portraits/icons are judged flat at 512px, which a headless
render answers completely, unlike a beast's fight-distance read), the same
kind of model-plus-portrait fix `silk_widow_portrait.md`'s own Pass 2
already made.

1. **Readability @ 34px / Identity (the floating eye).** Both eye balls in
   `riptide_eel.py` sat outside the skull ball's own ellipsoid — skull
   centre `(0.02, -1.30, 2.66)`, radii `(0.22, 0.30, 0.20)`; the eye centres
   at `(±0.16, -1.44, 2.82)` gave a normalized ellipsoid distance of 1.26
   (near side) and 1.53 (far side), both **> 1**, i.e. genuinely outside the
   surface rather than sitting on it — checked numerically, not eyeballed,
   against Eyrie Hawk's own working eye-on-skull placement (`(0.13*s,
   -0.98, 2.98)` against its skull `(0, -0.82, 2.94)`, radii `(0.20, 0.24,
   0.19)`), which scores 0.91 by the same formula. Pulled both eye and
   pupil balls 22% of the way back toward the skull centre: eye
   `(0.16*s, -1.44, 2.82)` → `(0.13*s, -1.41, 2.78)` (distance 0.74/0.96),
   pupil `(0.16*s, -1.48, 2.82)` → `(0.13*s, -1.45, 2.78)`, keeping the
   same eye-to-pupil offset. Rebuilt `riptide_eel.glb`; `assetcheck.gd`'s
   hold/climb checks are unchanged (`CLIMB Height 2 at 39%`, `Height 4 at
   59%`, identical to before the edit — only the head balls moved).
2. **Framing.** `portraits.py`'s `FOCUS["riptide_eel"]` moved from `(0.873,
   0.62)` to `(0.68, 0.75)` and `FOCUS_XY["riptide_eel"]` from `(0.02,
   -1.35)` to `(0.5, -1.0)`, found by rendering a grid of `(at, span, fx,
   fy)` combinations directly through `portraits.look()` (not through the
   committed FOCUS table) and picking the alpha-bbox closest to balanced
   left/right margins with real headroom, rather than guessing one value
   and eyeballing it.

Rebuilt via apt's Blender 4.0.2, headless (`libegl1`, `libegl-mesa0`;
`numpy` and `Pillow` installed into `/usr/bin/python3.12`, the interpreter
this Blender actually runs — same package list `plated_armour_icon.md`'s
Pass 2 already needed). Ran the full `portraits.py` batch (no single-
portrait build path exists) and reverted every portrait except
`riptide_eel.png` with `git checkout --`, since WORKBENCH's render output
isn't byte-reproducible even for unchanged inputs (same non-determinism
every prior portrait Pass 2 in this set has hit).

Verified by looking, not just by the numbers:

- **Alpha bbox** moved from `(138, 143, 503, 512)` to `(44, 38, 471, 512)`
  — left 44px, top 38px, right 41px, bottom touching (the long body running
  off-frame, the same accepted convention other long-bodied portraits'
  legs/tail crop at the bottom edge). Left and right are now close to even
  (44 vs 41) where pass 1 had a 138px left margin against a touching right
  edge.
- **Full renders side by side**
  (`design/renders/riptide_eel_portrait_pass1_full.png` vs
  `..._pass2_full.png`): pass 1 shows a small orange dot floating clear of
  the head in open background, separated by a visible gap; pass 2 shows
  both eyes flush against the skull, no gap, and the subject filling the
  frame evenly instead of being crowded into the bottom-right quadrant.
- **A real 34px Pillow `LANCZOS` downsample, composited over the
  `RGB(139,105,74)` brown card-face standin** the icon and portrait batches
  use (`design/renders/riptide_eel_portrait_pass1_34.png` vs
  `..._pass2_34.png`): pass 1 shows a distinct stray amber pixel separated
  from the head blob by standin-coloured background; pass 2 shows that
  pixel folded into the head blob's own silhouette, with no floating fleck
  anywhere in frame.

Score:

- **Framing (5 → 8):** confirmed by the bbox above — real, close-to-even
  margin on left and right, real headroom on top, nothing important cut
  off. Not higher: the crop still isn't perfectly symmetric (44 vs 41,
  and top at 38 is tighter than a full head-and-shoulders convention like
  `frog_portrait`'s), and the bottom edge is still a hard crop rather than
  a composed one.
- **Identity (6 → 8):** the eyes now read as two eyes mounted on a head,
  not one correct eye plus one floating oddity — the specific defect this
  line named is gone. Not higher: the head still reads as "serpentine,"
  not specifically "eel" the way `riptide_eel.md`'s own 3D score already
  found: no fix here changed the head's actual shape, only where the eyes
  sit on it.
- **Readability @ 34px (5 → 7):** confirmed by the 34px composite above —
  the stray-fleck defect this line was built entirely around is gone. Not
  higher: at 34px the two eyes still don't read as two separate dots (they
  fuse into the dark head blob), so "two eyes" isn't legible at this size
  even though "not a floating fleck" now is.
- **Colour & separation (7, unchanged):** neither fix touched a swatch or
  the palette; the navy/gold/grey separation this line already scored is
  untouched.
- **Style consistency (6 → 7):** the new crop now uses the frame the way
  the rest of the head-and-shoulders convention does (subject filling the
  frame with real margin on the sides, one hard crop at the bottom for a
  long body) rather than being the crowded-into-one-corner outlier pass 1
  was.

**+8 total (29 → 37), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED** (fresh `--import`, headless). No new
tests — a portrait/model geometry-only pass adds none, matching every
prior portrait-only pass under this rubric.

**A separate, pre-existing finding, not fixed here — out of this pass's
two-fix budget and not a portrait/icon-lane matter:** `assetcheck.gd`
against `riptide_eel.glb` (both before and after this pass's edit — checked
against the untouched baseline first, to confirm this wasn't introduced by
the eye move) reports `FAIL no real gold mark at Height 6 (found 0.0000,
wants >= 0.0226)`, despite the sigil disc being clearly visible in every
render. `beast.py`'s `mark()` does build a `GOLD`-coloured taper
unconditionally, so the UV band check failing at exactly this beast's own
`weak_point_height` (6, matching `bosses.json` and the model's own
`_sigil_z = b.z_for(6)`) is a real, unexplained mismatch worth a duty-2
error hunt, not a portrait framing problem. Logged here rather than
guessed at a fix for, since diagnosing it means reading `assetcheck.gd`'s
UV-band math and `mark()`'s own UV placement together, which is a
different job than this pass's two named lines.

## Unsure about (pass 2)

Whether a pass 3 crop could still balance the 44px/41px left-right gap and
the tight 38px top margin further — this pass hit its two named fixes and
stopped, per the loop. Also unsure, per the note above, whether the
`assetcheck.gd` gold-mark FAIL is a UV-band math bug in the check itself or
a real geometry problem in `mark()`'s placement for this specific beast's
`facing` vector — this pass only confirmed it predates the eye fix, not
which side of that question is true.
