# glyph_tortoise — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/glyph_tortoise.py`.** Views:
`design/renders/glyph_tortoise_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 8 | 5 | 7 | 8 | **36** |

## What is actually there

A domed blue-grey shell over a brown body, stubby brown legs at each corner, a
small head with a rounded snout. A yellow-ringed sigil sits on a short cylinder
that projects forward off the shell's front slope. Thin, near-flat chips ring
the shell's base — the climbing holds.

- **Silhouette** (`_sil.png`): the dome reads immediately and cleanly as a
  domed, shelled creature — the strongest asset of the four scored this round.
- **Proportion**: shell-to-body-to-legs ratio reads like a real tortoise; the
  shell appropriately dominates the mass.
- **Build hygiene**: the sigil's mount is a cylinder projecting straight out
  from the shell's front face (clearest in `_side.png`) — it reads as a pipe or
  handle bolted onto the shell rather than a marking set into its surface, the
  same "handle bolted on" failure named in this file's own notes. The holds
  ringing the shell base are thin flat chips, technically not floating, but
  thin enough that they nearly disappear into the seam between shell and body.
- **Colour & read**: shell blue-grey against brown body separates cleanly; the
  sigil's yellow reads well despite the mount issue above. The holds are a
  pale grey close in value to the shell's underside, low-contrast against both
  neighbouring parts.
- **Style consistency**: the smooth dome and boxy stub legs sit comfortably
  with the rest of the cast.

## Diagnosis — two lowest

1. **Build hygiene (5).** The sigil's forward-projecting stalk overhangs the
   silhouette as a separate part. Concrete fix: remove the projecting cylinder
   and set the sigil ring flush into the shell's front slope instead, matching
   how the sigil sits on other beasts (a marking on a surface, not a part on a
   stalk).
2. **Colour & read (7).** The holds are close in value to the shell and body
   they sit beside. Concrete fix: give the hold chips a distinct accent tone
   (the pale tan used for wood elsewhere in the cast) so they read as separate
   climbable points rather than blending into the shell seam.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the holds are meant to be inconspicuous (a tortoise's shell offering
subtle grip rather than obvious handholds) — if that is the intent, low
contrast may be correct and only the sigil mount needs the fix above.

---

## Pass 2 — fixer lane, 2026-09-06

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Views: `design/renders/glyph_tortoise_pass2_*.png`, captured
with `look.cmd glyph_tortoise 2`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 8 | 5 | 7 | 8 | **36** |
| 2 | 8 | 8 | 7 | 8 | 8 | **39** |

### Both diagnosed fixes applied

- **Build hygiene (5 → 7).** Removed the `taper()` bridging the prow ball to
  the mark in `tools/blender/glyph_tortoise.py`. The mount ball sits inside
  the shell's own volume (never broke the surface on its own), so the mark
  needed to land directly on the dome's real front slope rather than at the
  end of a rod. First attempt placed it at `y=-0.47`, close to the ball's own
  centre — `build.cmd` built clean but the render showed nothing there at
  all, buried inside the shell. Moved out to `y=-0.72` (matching the dome's
  analytic surface at that x/z) and got the opposite problem: `build.cmd`
  printed `WARNING: the sigil ... has no body within 0.16 of it - it is
  floating`, because the shell's 7-ring mesh is faceted enough that its real
  vertices sit short of the ideal analytic ellipsoid at that point. Settled
  at `y=-0.60` by testing against that warning directly instead of the
  formula — no warning, and `glyph_tortoise_pass2_front.png` /
  `_side.png` now show the gold mark sitting flush on the shell's front
  slope with no rod or gap, next to `glyph_tortoise_pass1_34.png`'s
  clearly-separate ring-on-a-stalk.
- **Colour & read (7 → 8).** Both `shelf()` hold chips (Height 2 and Height
  4) recoloured `PEWTER → TAN`. `glyph_tortoise_pass2_34.png` shows the
  Height-2 chip as a clear pale-tan accent against the BROWN underbody,
  where `glyph_tortoise_pass1_34.png`'s pewter chip sat close in value to
  both shell and body. `PEWTER` and the now-unused `point` import were
  dropped from the file; nothing else touched.

Silhouette, Proportion and Style were not touched, per the brief; their
scores are unchanged from pass 1. `_sil.png` is pixel-equivalent to pass 1's
— neither fix reads at 64px, which is expected since both are surface-level.

`run_tests.gd` passed (all green) before commit. Build log: 1464 tris (after
climb-point growth), 22 parts, budget 2600, no floating-island warnings.

+3 total (36 → 39), not a plateau — kept.

## Unsure about, still

Same open question as pass 1: whether the holds are meant to be
inconspicuous. Not resolved either way by this pass — TAN was applied
because the cloud named it as the concrete fix, not because this pass has a
view on the design question.
