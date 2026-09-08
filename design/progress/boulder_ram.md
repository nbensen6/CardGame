# boulder_ram — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/boulder_ram.py`.** Views: `design/renders/boulder_ram_pass1_*.png`.
Captured after "Darken the rock, warm the organics" (palette + UV fix) and the
three-point lighting rig landed underneath this pass via merge — re-rendered
against both before scoring; this asset's colours and the horn issue below are
unchanged from the pre-fix render.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 7 | 6 | 4 | 5 | 7 | **29** |

## What is actually there

A low, block-bodied quadruped: a boxy CLAY chest, an UMBER shoulder hump, a
lowered BROWN wedge head with a single dark eye dot, four short CHARCOAL legs
planted wide. The script means to mirror a pair of curled TAN ram horns up
and back off the head. What actually renders, in every lit view, is a single
grey-and-gold disc-with-rod sitting beside the hump like a bobbin or a stuck
knob — nothing that reads as a curled horn, and no second horn visible
anywhere, on either side.

- **Silhouette** (`_sil.png`): reads cleanly as a stocky charging animal —
  humped shoulders, lowered head, four stub legs. The horn geometry is
  invisible in the silhouette; it neither helps nor hurts here, which is
  itself a sign it isn't doing the "ram" work the module doc asks of it.
- **Proportion**: torso, hump, and lowered head read as "boulder-quadruped"
  exactly as intended. But the doc is explicit that curled horns are what
  reads "ram" rather than "dog or boar" — with the horns reading as a stray
  mechanical part instead, the creature's identity leans back toward
  generic stone beast.
- **Build hygiene**: the horn's `limb()` curl does not read as a curl from
  any angle captured — three-quarter, side, and top all show the same flat
  disc-with-rod, as if the four-point curl is being viewed edge-on from
  every camera at once, or the segments have collapsed toward one plane.
  Top view (`_top.png`) shows only one such shape near the right shoulder
  with nothing mirrored on the left, despite the script mirroring the horn
  with `s` over `(-1, 1)` — the second horn is not visible in any view,
  either hidden behind the hump from every angle by coincidence or not
  contributing to the silhouette/render at all.
- **Colour & read**: body colours (CLAY/UMBER/BROWN/CHARCOAL) separate
  cleanly and nothing is dark-on-dark. The horn itself renders grey with a
  gold band rather than TAN — a specular artifact on thin curled geometry,
  or the wrong swatch; either way it reads as metal, not horn keratin.
- **Style consistency**: boxy stone-plate primitives sit fine beside the
  rest of the low-poly cast.

## Diagnosis — two lowest

1. **Build hygiene (4).** The horn reads as a flat mechanical disc from
   three-quarter, side, and top alike, and only one is visible anywhere
   despite being mirrored in script. Concrete fix: render a dedicated close
   camera on just the head/horn region (crop tighter than the six standard
   views) to see whether the curl geometry is actually built as intended or
   is collapsing — this needs a closer look before a numeric fix is
   proposable.
2. **Colour & read (5).** The horn's grey-and-gold look does not match TAN.
   Concrete fix: confirm what swatch `TAN` resolves to in `kenney.py`'s
   palette and check the horn's UVs land inside it rather than off the atlas
   edge, since an off-atlas UV would explain both the wrong colour and the
   metallic look.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the horn is genuinely mis-rendering (a UV or geometry bug) or
whether it is built correctly but this creature's curled-horn shape simply
doesn't read at this poly budget from any of the six standard camera
angles — a tighter head-only crop would settle this and is worth doing
before anyone spends a fix on it.

---

## Pass 2 — fixer lane, 2026-09-05

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`). Views:
`design/renders/boulder_ram_pass1_front.png` (the dead-on angle `look.py`
gained on 2026-08-31, after this asset's pass-1 diagnosis was written — the
diagnosis above was scored without it) and
`design/renders/boulder_ram_pass2_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 7 | 6 | 4 | 5 | 7 | **29** |
| 2 | 7 | 6 | 4 | 5 | 7 | **29** |

### Colour (5) — investigated, not a bug, nothing changed

`TAN` resolves to `swatch(272, 320)` in `kenney.py` — an interior cell of the
atlas, 16px clear of every edge, same as every other named swatch. Not
off-atlas.

The dedicated close look this item asked for (`boulder_ram_pass1_front.png`)
shows why the diagnosis read "grey-and-gold, not TAN": **the grey-and-gold
disc-with-rod is not the horn.** It is the sigil assembly mounted on the
hump's own front face two lines below the horn call in the script
(`boulder_ram.py:108-109`, a STONE box plus the gold `mark()`), sitting a
few centimetres from the horn's own end point in the `34`/`side`/`top`
renders and reading as one object there. In the front view, both TAN horns
are plainly visible, correctly coloured, correctly mirrored, symmetric
either side of the head. There is no colour bug and no missing second
horn — both were an artifact of scoring against a render set that did not
yet include the front angle. Nothing to fix here; leaving the code as-is.

### Build hygiene (4) — tried and reverted

Tried thickening the horn tube to see if a thin cross-section was why it
reads as a flat disc from the fight camera: `[0.09, 0.07, 0.05, 0.02] ->
[0.16, 0.13, 0.09, 0.05]` in `boulder_ram.py`'s `limb()` call (radii only,
same points, same seg=6).

Rebuilt and compared `boulder_ram_pass2_34.png`, `_side.png` and `_top.png`
against the pass-1 versions side by side: no visible change in any of the
three. The horn is still essentially unreadable from the fight camera, the
side, and the top — it only reads (as a flat wedge, not a curl) from the
front angle, which the actual game camera never uses. Thickness was not
the problem, so reverted (`git checkout -- tools/blender/boulder_ram.py`,
rebuilt to confirm the shipped glb matches).

**Real cause, as best determined by looking:** the curl sits low against
the head and nearly edge-on to every camera except the front one — from
`34`/`side`/`top` it is occluded by or foreshortened flat against the head
and hump, not merely thin. Fixing that means moving or re-angling the curl
so it projects clear of the head from the fight-camera direction, which is
a shape change to how prominently a "ram horn" silhouette should read
against this body, not a measurement — flagging rather than guessing at it
inside this run's two-fix budget.

Total unchanged (29), a plateau on the numbers, but not wasted: one of the
two named problems (colour) turns out not to exist, and the real hygiene
problem is now stated correctly (occlusion/angle, not thickness or a
missing horn) for whoever takes the next pass.

---

## Pass 3 diagnosis — #86 duty 1, 2026-09-08

Lowest-scoring beast among the uncollided (non-`_ground`-paired) cast with no
pending diagnosis — `bog_leech` (28) and `clot_toad` (26) already have
unapplied pass-3 fixes waiting on the fixer as of this same rotation, and
`boulder_ram`'s own pass 2 ended in a plateau with an open "for whoever takes
the next pass" line, so this is that pass. Re-read `boulder_ram_pass2_34.png`,
`_front.png` and `_sil.png` (no `_side`/`_top` committed for this asset) and
`tools/blender/boulder_ram.py`'s actual coordinates before rescoring, per the
anchor table's own warning not to anchor on the previous number.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 7 | 6 | 4 | 5 | 7 | 29 |
| 2 (reverted, no net change) | 7 | 6 | 4 | 5 | 7 | 29 |
| 3 (re-score, no geometry change yet) | 7 | 6 | 4 | 7 | 7 | 31 |

- **Colour & read (5 → 7).** Pass 2 already established this pass's own
  "grey-and-gold, not TAN" complaint was a misattribution — the disc-with-rod
  is the shoulder sigil (`boulder_ram.py:108-109`), not the horn, and
  `boulder_ram_pass2_front.png` shows both horns correctly, cleanly TAN, with
  no metallic or off-swatch read anywhere. That finding was never carried
  through to the scoreboard; doing so now rather than re-scoring blind. Body
  colours (CLAY/UMBER/BROWN/CHARCOAL/TAN) separate cleanly at both viewed
  sizes and nothing sits dark-on-dark. Not touching Style, Silhouette or
  Proportion on the same basis — no equivalent misattribution found in those.
- **Silhouette (7, unchanged) and Proportion (6, unchanged).** Re-confirmed
  against `boulder_ram_pass2_sil.png`: the stocky charging-quadruped shape
  reads cleanly with or without the horn (Sil holds at 7), and Proportion
  stays capped at 6 for the reason pass 1 named — the doc calls curled horns
  the feature that reads "ram" rather than "dog or boar," and with the horn
  reading as a flat sliver from every angle except front (see below), that
  identity work still isn't landing.

With Colour cleared, the two lowest lines are now **Build hygiene (4)** and
**Proportion (6)**, and both trace to the same root cause pass 2 isolated by
looking rather than measuring: the horn curl's four control points move
mostly in Y (front-to-back) and Z (up), and barely in X (left-right) —
`(0.18*s, -1.15, 0.78) → (0.40*s, -1.05, 1.08) → (0.54*s, -0.82, 1.20) →
(0.48*s, -0.60, 1.10)`, X only ever spanning 0.18 to 0.54 before *pulling
back in* to 0.48 at the very tip. A curl whose whole arc lives in one
near-planar sheet reads with real width only from the one camera roughly
normal to that sheet (front, which is why `_front.png` alone shows it
cleanly) and edge-on/foreshortened from every other angle, exactly what pass
2 saw and confirmed wasn't a thickness problem.

## Diagnosis — two lowest (pass 3)

1. **Build hygiene (4).** Concrete fix: keep the base point fixed (it anchors
   to the head) and make every following point's X grow **monotonically and
   by more each step**, instead of peaking at the third point and retreating
   at the tip: `(0.18*s, -1.15, 0.78) → (0.44*s, -1.02, 1.10) → (0.70*s,
   -0.85, 1.22) → (0.92*s, -0.68, 1.08)`. Total X swing goes from 0.36 (and
   *closing* to 0.06 short of that at the tip) to 0.74, monotonic the whole
   way — the curl sweeps continuously outward rather than curling back toward
   centreline exactly where the tip most needs to clear the head/hump
   silhouette. This is a position/spread change, not a thickness change (pass
   2 already tried and reverted thickness), so it doesn't repeat a dead end.
2. **Proportion (6).** Concrete fix: none beyond the same edit — this is the
   same root cause pass 2 named, not a second defect, so applying fix 1 and
   re-scoring both lines off the same render is the honest path rather than
   inventing an unrelated second change. Precedent: `bog_leech.md` pass 2
   moved two rubric lines with one edit for the same reason ("one visual
   unit").

Not applying — this is a diagnosis pass; `tools/blender/boulder_ram.py` is
the fixer's file (`tools/fixer/BRIEF.md`).

## Unsure about (pass 3)

Whether pushing the tip out to X=0.92 (nearly double the old peak) reads as a
confident curled horn or overshoots into looking detached from the head once
actually rendered — the plane-collapse argument is sound from the coordinates
alone, but a fix that measures right can still look wrong (same caveat
`bog_leech.md` pass 3 and `clot_toad.md` pass 2 both flagged on similarly
reasoned changes), and this run has no way to render and check. Also unsure
whether widening the horn this much changes its own clearance from the
shoulder sigil crest at `(0.32, -0.68, z_for(5))` — the horn's nearest point
to the crest is well above and forward of it in the current geometry, but
nobody has re-measured that gap against the proposed new points.
