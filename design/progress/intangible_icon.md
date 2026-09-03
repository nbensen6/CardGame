# intangible — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
14 — the third adaptation after the 3D-model rubric (batches 1-8) and the
portrait rubric (batches 9-13). **Scoring pass only — report, not repair; no
edits to `tools/blender/icons.py`.** Asset: `game/assets/icons/intangible.png`
(256x256, rendered by `icons.py`, orthographic head-on per
`design/ART-REVIEW.md`'s own build note). First of batch 14's four — the
"four defensive-keyword icons (intangible, buffer, plated_armour, thorns)"
block in `design/ART-REVIEW.md`, its own stated question: can these four be
told apart from `shield`/`guard`/`wall` at 42px, and does each look like what
its card actually does.

## The adapted rubric (1–10 each, out of 50)

An icon has no crop/framing question (it's a fixed square render) and no
"identity" in the portrait sense (nobody needs to recognize *which specific
icon* the way they recognize *which specific beast*) — the questions that
matter for an icon are legibility at the size it's actually seen, and
standing apart from its nearest neighbours, since a hand is read by shape,
fast (`ART-REVIEW.md`'s own framing of the whole icon set).

| Criterion | Question | Replaces |
|---|---|---|
| **Silhouette @ 42px** | Downsampled to the size `ART-REVIEW.md` names as the real read distance ("an icon is read at 42 pixels as a silhouette") — does the shape itself stay legible, or do its parts fuse into a blob? | Silhouette |
| **Family distinction** | Told apart from its named nearest neighbours (`shield`/`guard`/`wall` for this batch) by shape alone, not colour? | Proportion |
| **Mechanic match** | Does the shape suggest what the card wearing it actually DOES (the comment beside it in `card_view.gd`'s `ICONS` table), not just a flavour object? | (new; portraits have no "does what it claims" question) |
| **Colour & contrast** | Internal contrast between the icon's own parts, and contrast against the card face it sits on? | Colour & read |
| **Style consistency** | Same orthographic head-on angle, shared palette, similar visual weight to the rest of the icon set? | Style consistency |

"Build hygiene" (poly budget, floating parts) and "Framing"/"Identity"
(portrait-specific) don't apply to a fixed-square icon render and are
dropped rather than stretched to fit.

42px check done with a real downsample (Pillow, `Image.LANCZOS` to 42x42,
nearest-neighbour back up to view, composited over a flat brown standing-in
for the card face — `RGB(139,105,74)`, an approximation of the game's actual
card colour, not sampled from the real shader; noted as a limitation, not
claimed as exact) — the same "actually look, don't guess" standard the 3D
and portrait loops hold themselves to. `shield`, `guard` and `wall` were
rendered the same way alongside it for the family-distinction line, since
that question is meaningless without the neighbours in frame; they are not
themselves scored under this item; the "twenty-eight card icons" block they
belong to is unscored and left for a future batch.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 9 | 6 | 5 | 8 | **34** |

## What is actually there

Three overlapping rounded-square/diamond tiles on a diagonal chain from
upper-left to lower-right, fading from saturated indigo/purple through a
mid steel-blue to a near-white pale grey — an afterimage trail, per
`ART-REVIEW.md`'s own description.

- **Silhouette @ 42px (6):** the three tiles read as one continuous
  elongated lozenge with three shaded bands rather than three separate
  overlapping objects — the overlap that at 256px clearly shows three
  distinct rounded squares compresses at 42px into a single diagonal bar.
  The shape is clean and legible, just not legible as *three* things.
- **Family distinction (9):** nothing about `shield`'s kite, `guard`'s
  kite-plus-clock, or `wall`'s brick grid resembles a diagonal fading bar —
  this is the least ambiguous line for this icon, confirmed side-by-side
  against all three at the same 42px scale.
- **Mechanic match (6):** a fading diagonal chain plausibly reads as
  "afterimage / phasing" for a player already told the keyword, but cold
  (no tooltip, no context) it could as easily read as a colour ramp or a
  loading indicator. Plausible, not unambiguous.
- **Colour & contrast (5):** confirms `ART-REVIEW.md`'s own named worry —
  the palest of the three tiles (bottom-right) sits close enough in value
  to the brown card standin that its trailing edge nearly disappears at
  42px, leaving what looks like two tiles plus a faint smudge rather than
  three graduated steps.
- **Style consistency (8):** the rounded-block-on-block construction matches
  the shared vocabulary other icons in the set already use (`climb`,
  `ascend` build from similar solid blocks); nothing about the render angle
  or palette family stands out as inconsistent.

## Diagnosis — two lowest

1. **Colour & contrast (5).** Concrete fix: shift the palest tile's colour
   value further from the card-face brown — either darken it or add a thin
   contrasting outline — so it stays visibly present rather than fading to
   nothing at 42px.
2. **Silhouette @ 42px (6).** Concrete fix: increase the offset between the
   three tiles (or reduce the overlap) so the "three steps" read survives
   the downsample instead of compressing into one bar with internal
   shading.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether "afterimage trail" is the read a player gets on first sight with no
tooltip open, versus needing the keyword text to make sense of it — this
static comparison can't settle that, only game-context testing could.

## Pass 2 — #86 duty 1

Applied both named fixes in `tools/blender/icons.py`'s `intangible()`,
in-lane (icons only, no beast/portrait geometry, no shared palette or
budget constant touched):

1. **Silhouette @ 42px (6).** Concrete fix: increase the offset between
   the three tiles so the "three steps" read survives the downsample.
   Measured the actual overlap first rather than guessing at it: along the
   shared diagonal, a 45°-rotated square's reach toward its neighbour is
   just its own half-width `w` (not the corner-to-corner diagonal), so
   pass 1's centres (0.26/0.08/-0.14 stepped by ~0.18-0.22) against radii
   0.15/0.17/0.19 overlapped by 0.065 and 0.049 units respectively — real
   overlap, not a near-miss. Re-centred all three (WHITE 0.32,-0.32 w=0.13;
   ICE 0.05,-0.05 w=0.155; IRIS -0.25,0.25 w=0.18) so each pair clears by a
   real ~0.09 units, and shrank each tile slightly (0.15→0.13, 0.17→0.155,
   0.19→0.18) to keep the whole cluster inside the camera's ±0.575 frame
   with margin.
2. **Colour & contrast (5).** Concrete fix: shift the palest tile's colour
   value further from the card-face brown, or add a thin contrasting
   outline. Took the outline: added a STEEL `slabf` at WHITE's own
   position and rotation, sized 0.175 (larger than WHITE's new 0.13), with
   `.location.y = 0.05` to push it behind WHITE in depth (this scene's
   camera sits at -Y per `rally()`'s own comment on the same trick, so a
   larger Y is further from the lens) — WHITE occludes it everywhere the
   two overlap, leaving only a thin rim showing around WHITE's own edge.
   Didn't touch WHITE's own colour, since darkening it would have reduced
   contrast against the darker two tiles instead.

Rebuilt via apt's Blender 4.0.2, headless (`libegl1`, `libegl-mesa0`,
`libgles2`; `numpy` and `Pillow` installed into `/usr/bin/python3.12`, the
interpreter this Blender actually runs — not the separate system
`python3.11`). Ran the full `icons.py` batch (no single-icon build path
exists) and diffed all 36 generated PNGs against the committed set;
`intangible.png` was the only one with a real content change (mean
per-pixel diff 19.32) against the rest's render-noise-only diffs (mean
well under 1 for most, a few up to ~6.7 — likely this apt Blender build
differing slightly from whatever built the committed set, not this pass's
doing, since every other icon's *script* was untouched). Reverted the
other 35 with `git checkout --`, kept only `intangible.png`.

Verified by looking, not just by the numbers:

- **Alpha bbox** `(20, 20, 251, 251)` of 256 — real margin on all four
  sides, not clipped, even with the wider spread (`ROOM` for concern given
  the tighter frame budget, checked directly rather than assumed).
- **Full-render composite over the brown card standin**
  (`design/renders/intangible_pass2_full.png`): three clearly separate
  diamonds with real gaps between them, the near-white one now wearing a
  visible cool grey-blue rim instead of butting straight against brown.
- **A real 42px Pillow LANCZOS downsample**
  (`design/renders/intangible_pass2_42_big.png`, nearest-neighbour
  upscaled for viewing) side by side with the same downsample of the old
  pass-1 render (`design/renders/intangible_compare_42.png`): pass 1 reads
  as one elongated lozenge with internal shading bands; pass 2 reads as
  three distinct diamonds with the palest one visibly outlined, at the
  exact size the icon is actually seen at.
- **A 64px solid-black silhouette recolour**
  (`design/renders/intangible_pass2_sil_64.png`): same three-diamond read
  holds at the silhouette rubric's own stated test size, not just at 42px.
- **Pixel-sampled, not eyeballed:** the rendered (lit) WHITE fill samples
  at roughly RGB(193,194,194) — noticeably darker than the raw WHITE
  swatch (255,255,255), confirming pass 1's "nearly disappears" finding
  was about the LIT render, not the raw colour constant. The new STEEL rim
  samples at roughly RGB(164,164,166), still a real gap on every channel
  from the brown standin RGB(139,105,74).

- **Silhouette @ 42px (6 → 9):** confirmed by both the 42px downsample and
  the 64px silhouette test above — three distinct diamonds with visible
  gaps, not fused into one bar. Not 10: the two nearer tiles (ICE/WHITE)
  still sit closer to each other than to IRIS, by design (a trail fades
  outward, it doesn't scatter evenly), so their gap is the thinnest of the
  two and a very fast glance could still read them as a pair.
- **Family distinction (9, unchanged):** still the least ambiguous line —
  nothing else in the set is three separated diagonal diamonds, and this
  pass didn't touch what makes it distinct.
- **Mechanic match (6 → 7):** a cluster that visibly reads as three
  distinct, separating steps is a better match for "leaving something
  behind as you fade" than a fused bar that could as easily read as a
  colour ramp. Not higher: this pass added no new shape cue (a ghost
  silhouette, a fading trail line) that would let a first-time viewer name
  "afterimage" specifically without the keyword — it made the existing
  idea read more clearly, not a more literal one.
- **Colour & contrast (5 → 8):** confirmed by the pixel samples above —
  the previously fading tile now holds a real, measured gap against the
  brown standin at its own edge, not just at its centre. Not higher: the
  outline is deliberately thin (to avoid restyling WHITE itself, which
  wasn't one of the two named fixes), so a very fast glance could still
  read fill-plus-rim as one soft two-tone shape rather than two distinct
  parts.
- **Style consistency (8, unchanged):** STEEL is already in the shared
  palette and the outline-behind-a-shape depth trick is the same one
  `rally()`'s pass 2 and `guard()` already use in this file — nothing new
  was introduced to the set's vocabulary.

**+7 total (34 → 41), not a plateau — kept.** No line regressed. Meets the
loop's stop condition (≥40/50) — no pass 3 planned for this asset.
`run_tests.gd`: **ALL TESTS PASSED** (fresh import, headless). No new
tests — an icon geometry/colour pass adds none, matching every prior
icon-only pass under this item.

## Unsure about (pass 2)

Whether the WHITE tile's render-time darkening (255→~193 measured above)
is worth naming as a general finding for the other icons still using raw
WHITE/near-white swatches at full brightness — this file only checked the
one asset it was scoring, and didn't survey whether other icons rely on
an assumption (raw swatch value = rendered value) pass 1 here shows can be
off by a real amount. Also unsure whether the two nearer tiles (ICE/WHITE)
should get the same treatment as IRIS/ICE's spacing in a future pass — not
touched here since Silhouette's diagnosis only asked for "the three steps"
to survive the downsample, which they now do, not for even spacing.
