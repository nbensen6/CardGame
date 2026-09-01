# yoke_ox — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/yoke_ox.py`.** Views: `design/renders/yoke_ox_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 6 | 6 | 7 | 7 | **31** |

## What is actually there

A boxy ox: a rectangular torso, four black-hoofed legs, a snout wedge with one
dark nostril dot, and small forward horns. A diagonal wooden bar (the yoke, per
the beast's intent — backlog #55's `height_split` limiter) crosses the back and
shoulders, with a yellow-ringed sigil set into it near the head. Reads clearly
as "boxy quadruped with something strapped across its shoulders" in the lit
views.

- **Silhouette** (`_sil.png`): the body-box-plus-four-legs reads as an animal at
  64px, but the yoke bar merges into the horn shapes into one triangular lump
  at the front — nothing in the black silhouette says "yoke" specifically, only
  "some bump near the head."
- **Proportion**: torso, snout, and legs read as bovine. The diagonal bar reads
  more like a strap slung on at an angle than a yoke built for two — a yoke is
  a straight crossbar, and this one runs corner to corner.
- **Build hygiene**: one mesh, one material, 1316/2600 tris, nothing floating.
  In the side view the yoke bar visually clips behind/through the near horn
  rather than passing clearly in front of or behind it.
- **Colour & read**: brown body, black legs, tan-wood yoke, yellow sigil — the
  sigil pops cleanly against the wood. Nothing dark-on-dark.
- **Style consistency**: rounded boxy primitives match the rest of the cast.

## Diagnosis — two lowest

1. **Silhouette (5).** The yoke bar and the horns occupy the same silhouette
   region and read as one lump. Concrete fix: drop the yoke bar's pivot down
   ~0.08 so it crosses below the horn tips rather than through them, giving the
   silhouette two separable shapes (horns above, bar below) instead of one.
2. **Build hygiene (6).** The yoke bar appears to clip through the near horn in
   the side view. Concrete fix: push the bar back in Y by ~0.05 (or shorten the
   horns by the same amount) so the two parts clear each other in depth instead
   of intersecting.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the diagonal (corner-to-corner) angle on the yoke bar is intentional
character design or should be closer to horizontal to read as a "yoke" rather
than a strap — this is a design call, not a measurement, and is named here
rather than guessed at.

---

## Pass 2 — fixer lane, 2026-09-01

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Views: `design/renders/yoke_ox_pass2_*.png`, captured with
`look.cmd yoke_ox 2`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 6 | 6 | 7 | 7 | **31** |
| 2 | 6 | 6 | 8 | 7 | 7 | **34** |

### Both diagnosed fixes applied, together with the strap loops they carry

- **Build hygiene (6 → 8).** The yoke box moved `z: 1.58 → 1.50`
  (drop 0.08) and `y: -0.85 → -0.80` (back 0.05), per the diagnosis. The two
  strap-loop tapers, which hang off the beam's own ends, moved by the same
  deltas (`y: -0.80 → -0.75`, `z: 1.44 → 1.36`) so they stay attached to the
  beam instead of floating where it used to be — `build.cmd` printed no
  floating-part WARNING, confirming nothing came loose. `yoke_ox_pass2_top.png`
  now shows the beam sitting clearly forward of and below the horn bases, no
  longer crossing through them the way `yoke_ox_pass1_top.png` did; the
  `_side.png` profile confirms the same separation from the angle the
  diagnosis named.
- **Silhouette (5 → 6).** The same drop pulls the beam out from directly under
  the horn tips, and `yoke_ox_pass2_sil.png` now shows a small distinct notch
  above the main mass where a horn tip clears the body outline, versus
  `yoke_ox_pass1_sil.png`'s single unbroken lump. Not fully separated — the
  horns and body still read as one mass at 64px more than they read as
  "ox with horns" — so this stops short of shippable.

+3 total (31 → 34), not a plateau — kept. Proportion, colour and style were
not touched, per the brief; their scores are unchanged from pass 1.

Not re-litigated: the diagonal-angle question pass 1 named under "Unsure
about" is still a design call, not a measurement, and still Nick's.
