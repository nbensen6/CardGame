# skull — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
18 — continuing the icon rubric batches 14-17 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/skull.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). Last of batch 18's
four — the "four basic damage-type icons" (sword, bow, fire, skull).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-17 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

Same Pillow-based 42px downsample (`Image.LANCZOS`, flat brown
`RGB(139,105,74)` card-face standin) and >10-alpha-threshold bbox method
batch 17 added.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 8 | 6 | 8 | 8 | **38** |

## What is actually there

A blocky rounded-square mint-green head with two solid black ovoid eye
sockets, a small charcoal nose slab, and a jaw of three vertical charcoal
teeth-bars below. Alpha bbox `(56, 38, 200, 227)` — comfortable margin on
all four sides, no edge-flush framing.

- **Silhouette @ 42px (8):** the head-plus-jaw shape reads clearly and
  survives the downsample as a distinct blocky face — the two dark eye
  sockets and the teeth bar remain visibly separate elements rather than
  fusing into the head mass.
- **Family distinction (8):** nothing else in the set is a face/head
  shape at all, so it can't be confused with anything else reviewed under
  this item — docked only slightly because the read is "a green blocky
  face" rather than anything more specific within that.
- **Mechanic match (6):** the green colour supports "poison" clearly, but
  the shape itself reads more as a blocky robot or alien head than
  specifically a skull — the eye sockets are solid black ovals rather than
  the hollow triangular/round sockets a skull silhouette usually uses, and
  the teeth are three even rectangular bars rather than a jaw shape. It
  reads unambiguously as "a face, something's death-coded," which covers
  the comment's "poison, wound, death" fairly well, but not as
  unambiguously "a skull specifically" as the comment's literal name
  implies.
- **Colour & contrast (8):** the mint-green head separates cleanly from
  the brown card standin, and the charcoal eyes/teeth separate cleanly
  from the green — the strongest internal contrast of this batch's four
  icons.
- **Style consistency (8):** the same blocky, rounded-bevel low-poly
  construction as the rest of the set; nothing about the render is an
  outlier.

## Diagnosis — two lowest

1. **Mechanic match (6).** Concrete fix: none proposed beyond naming the
   gap — if a more literal skull read is wanted, hollowing or angling the
   eye sockets toward a triangular shape and narrowing the jaw would move
   it closer to a classic skull silhouette rather than a blocky
   robot/alien face; not confirmed whether the current read causes any
   real confusion in play, since "green face" already carries the
   poison/death association well.
2. **Family distinction (8).** No defect found; scored short of a perfect
   10 only because a single unique shape in its own class has less to
   prove than the closely-packed families (`shield`/`guard`/`wall`,
   `climb`/`ascend`/`peak`/etc.) scored in earlier batches.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether "green blocky face" reads as *skull* on first sight with no
tooltip, or needs the keyword text to land as death/poison rather than
just "an enemy's face" — the same kind of question `intangible_icon.md`
(batch 14) left open for "afterimage," and one this static comparison
can't settle on its own.

## Pass 2 — #86 duty 1

Applied the one fix pass 1 named — **Mechanic match (6)** — in-lane, no
palette or budget edit: `icons.py`'s `skull()`.

1. The two solid `ball()` eyes (round, opaque ovoids) were replaced with a
   `taper()` each, pointed straight down via `rot=point((0, 0, -1))` — wide
   at the brow (`r0=0.12`), narrowing to a point toward the nose
   (`r1=0.02`) — a real hollow-orbit shape instead of a filled dot.
2. The jaw plate was narrowed (half-extent `0.20, 0.14` → `0.16, 0.13`) and
   the three even rectangular teeth-bars were replaced with three tapered
   fangs (`taper()` again, same downward point, `r0` 0.026/0.034/0.026 for
   the outer/centre/outer tooth) instead of uniform slabs.

Rebuilding turned up a second bug pass 1 never had a chance to name: the
first attempt centred each tooth's `taper()` at `y=0.0` (what `spike()`
does automatically) — flush with the jaw plate's own centre, whose front
face sits at `y=-0.05`. A tooth's front-most point never gets closer than
`y=-r0` (at most `-0.034`), so every tooth rendered fully **behind** the
jaw's own opaque front face — invisible, the identical occlusion class
`guard_icon.md` pass 2 found in its clock ring hiding behind the body
plate. Called `taper()` directly (not the `spike()` wrapper, which hardcodes
`y=0.0`) with `y=-0.08` so each tooth clears that face and actually renders.

Rebuilt with `blender --background --python tools/blender/icons.py --
game/assets/icons` (apt's Blender 4.0.2, headless EGL, `libegl1`/`libgles2`
installed first — same environment prior `#86` duty-1 passes used).
Console: `TRIS 296 PARTS 5 BUDGET 700 ok`, no floating-parts warning.
Diffed all 36 icons against `HEAD` — every icon shows Blender's usual
WORKBENCH render noise (the non-determinism `fire_icon.md` pass 3 and
others hit before); reverted every file except `skull.png`.

Composited the new PNG over the flat brown card-face standin
`RGB(139,105,74)` and looked at it three ways: the full 256px composite
(`design/renders/skull_icon_pass2_full.png`), a real 42px Lanczos
downsample nearest-neighbour upscaled for viewing
(`design/renders/skull_icon_pass2_42px_big.png`), and a black-on-white
alpha silhouette (`design/renders/skull_icon_pass2_sil.png`). Alpha bbox
(`>10` threshold) `(56, 38, 200, 224)` — essentially unchanged from pass 1's
framing, confirming the narrower jaw didn't cost any margin.

- **Mechanic match (6 → 8):** the full-size render shows two clearly hollow,
  downward-pointing dark sockets — an unmistakable eye-socket read, not a
  solid dot — and three small fangs on the jaw. Pixel-sampled the darkest
  socket pixel at `RGB(20, 20, 23)`, genuinely near-black against the mint
  head, confirming the hollow isn't a rendering illusion. Not a 10: at the
  42px downsample the fangs shrink to a faint darker smudge under the nose
  rather than three distinct points — confirmed by looking at
  `skull_icon_pass2_42px_big.png` directly — and the jaw itself is still a
  plain rounded box, not a curved mandible shape.
- **Silhouette @ 42px (8, unchanged):** the outer head/jaw footprint barely
  moved (bbox `(56, 38, 200, 224)` vs pass 1's `(56, 38, 200, 227)`), so the
  overall blocky-face shape still reads the same at a glance; this line was
  never about the internal marks.
- **Family distinction (8, unchanged):** still the only face/head shape in
  the set; neither fix touched anything that would change that.
- **Colour & contrast (8, unchanged):** same `MINT`/`CHARCOAL` pairing;
  neither fix touched the palette.
- **Style consistency (8, unchanged):** `taper()` is the same primitive
  `spike()` already wraps elsewhere in this file (`sword`, `fire`); calling
  it directly for depth control introduces no new build vocabulary.

**+2 total (38 → 40), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether the jaw needs an actual curved/tapered mandible shape (rather than
a narrowed box) to read as more than "a smaller face-plate below the
sockets" — this pass's budget went to the sockets, which pixel-sampling
confirms is the bigger win, and the jaw shape itself is unchanged in kind
from pass 1. Also whether three fangs that only read at full size (not at
the 42px hand-scale this rubric checks) are worth their triangle cost, or
whether a single wider dark jaw-shadow would carry the same "something
died here" read at both sizes for less geometry.
