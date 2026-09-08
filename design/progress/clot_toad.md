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

---

## Pass 2 — fixer lane, 2026-08-31

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Views: `design/renders/clot_toad_pass2_*.png`, captured with
`look.cmd clot_toad 2`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 4 | 6 | 5 | 6 | 7 | **28** |
| 2 | 6 | 6 | 7 | 6 | 7 | **32** |

### Both diagnosed fixes applied

- **Silhouette (4 → 6).** The two ridge mounds (`b.ball((0.28, 0.62, 0.56), ...)`
  and `b.ball((0.24, 0.94, 0.86), ...)`) raised in Z by 0.18 each, to 0.74 and
  1.04. Neither the `shelf()` calls nor `z_for()` moved — a shelf's top is
  fixed by the climb contract, not by the ball it sits on, so this is a purely
  visual change; `build.cmd`'s own hold check still reports every Height ok.
  `clot_toad_pass2_sil.png` now shows a jagged, stepped crown at the back —
  compare `clot_toad_pass1_sil.png`'s single small notch. Not "shippable" yet:
  the main torso is still one big round mass, which is the untouched
  Proportion finding, not this pass's job.
- **Build hygiene (5 → 7).** `mark()`'s anchor pulled from y=0.86 to y=0.93,
  0.07 toward the gland ball's own centre (y=1.13). `clot_toad_pass2_34.png`
  and `_side.png` no longer show the sigil ring as a separate floating disc
  beside the gland the way `clot_toad_pass1_34.png` did — it now sits against
  the ball's surface.

+4 total, not a plateau — kept. Proportion, colour and style were not
touched, per the brief, and their scores are unchanged from pass 1.

## Unsure about, still

Same open question named in pass 1: whether the ridge/gland stack now reads
as too tall relative to the torso once it is also visually distinct — a
proportion question outside the two lines this pass was allowed to touch.

---

## Pass 3 diagnosis — #86 duty 1, 2026-09-08

Scored fresh against `clot_toad_pass2_sil.png` and `_34.png` (the only two
views committed for pass 2 — no `_side`/`_top`/`_wire` exist to check this
against), per the anchor table added 2026-09-07, before reading pass 2's
numbers.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 4 | 6 | 5 | 6 | 7 | 28 |
| 2 | 6 | 6 | 7 | 6 | 7 | 32 |
| 3 (re-score, no geometry change yet) | 5 | 5 | 7 | 6 | 7 | 30 |

The drop on Sil and Prop is the anchor table biting, not a regression — no
geometry has changed since pass 2. Re-justifying both from the actual `.py`
values rather than the pass-2 prose:

- **Silhouette (6 → 5).** `_sil.png` shows a rounded blob with a jagged
  staircase crown at the back and no other feature — no leg, eye or mouth
  cue survives. That crown is real progress over pass 1's single notch, but
  the anchor table's 6–7 band asks for "the silhouette has intent" with only
  "a specific part still fails" — here the *entire front two-thirds* of the
  silhouette is still one undifferentiated oval, which reads closer to 5:
  "primitives with taper... but the underlying box/cylinder is still the
  first thing you see."
- **Proportion (6 → 5).** Pulled the actual Z spans from `clot_toad.py`
  rather than eyeballing: torso is `ball((0,0,0.50),(0.86,0.62,0.34))`, top
  at z≈0.84. The ridge/gland/crest stack runs from the first ridge ball at
  z=0.74 up through the second ridge ball (top z≈1.24), the gland
  (top z≈1.29), to the crest ball (top z≈1.51) — the accessory's own peak is
  80% taller than the torso it grows out of, on a creature the module
  docstring calls "squat and wide... sitting low." That is a bigger gap than
  a 6 admits.

## Diagnosis — two lowest (pass 3)

1. **Silhouette (5).** The front and rear leg balls sit at
   `x = 0.62*sx` / `0.67*sx` with radii up to 0.23 — their outer edge lands
   at ≈0.85, just inside the torso's own half-width of 0.86, so the legs are
   entirely swallowed by the torso's silhouette and contribute nothing to
   the outline. Concrete fix: push both leg pairs' X anchor outward by
   ~0.12 (0.62→0.74, 0.67→0.79) so the leg balls' outer edge (≈0.97) clears
   the torso edge (0.86) by about 0.11 — enough for two leg bumps per side
   to actually show in `_sil.png` instead of zero.
2. **Proportion (5).** The ridge/gland/crest stack's own peak (z≈1.51) rises
   well above the torso's crown (z≈0.84). Concrete fix, without touching
   `shelf()`/`mark()`/`z_for()` (the climb-hold contract stays exactly where
   it is, same scope discipline as pass 2's hygiene fix): shrink the crest
   ball's radius from `(0.14, 0.13, 0.14)` to about `(0.09, 0.09, 0.09)`
   (peak z≈1.51 → ≈1.46) and the gland ball's Z half-extent from 0.21 to
   about 0.16 (peak z≈1.29 → ≈1.24) — pulling the decorative mass down
   without moving a single hold.

Not applying either — this is a diagnosis pass, not a repair; the fixer
(`tools/fixer/BRIEF.md`) owns `tools/blender/clot_toad.py`.

## Unsure about (pass 3)

Whether shrinking the crest/gland balls as proposed leaves the sigil
(`b.mark()`, unchanged here) with enough surrounding geometry to still read
as mounted rather than floating — pass 2's own hygiene fix specifically
pulled it flush, and I have no side/top render of pass 2 to check how it
looks today, let alone after a further radius change. Also flagging for
whoever applies this: `clot_toad` is one of the five beasts backlog #88
names with a possibly-occluded sigil (83% occluded) — shrinking the ball
that occludes it is very likely to help that too, but #88 is explicitly
`needs a screen` and not re-verified here.
