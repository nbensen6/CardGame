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
