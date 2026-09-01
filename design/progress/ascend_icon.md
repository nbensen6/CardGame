# ascend — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 16 (see `design/progress/climb_icon.md` for the full rubric and batch
setup — same rules apply here, not repeated). Asset:
`game/assets/icons/ascend.png` (256x256). Second of the "six are about going
up" family this batch scores.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 3 | 6 | 5 | 8 | **29** |

## What is actually there

The same cream/wheat arrow-on-post shape as `climb`, taller and with a wider
triangle, flanked at the base by two small gold wing-triangles and sitting
on a tan slab. Alpha bbox `(38, 5, 218, 256)`: touches the bottom canvas
edge (the tan base slab is cropped there), comfortable margin elsewhere.

- **Silhouette @ 42px (7):** the arrow-on-post reads cleanly, same as
  `climb`; the gold wings survive the downsample as two small triangular
  flags at the base, though the tan slab beneath them nearly disappears
  into the crop.
- **Family distinction (3):** the same finding as `climb_icon.md` reports
  from the other side — at 42px `ascend` and `climb` share an
  almost-identical outer triangle-on-post silhouette
  (`climb_family_42px_strip.png`), differing only in the small base
  attachments (gold wings and a tan slab here vs two dark bars on `climb`).
  Colour, not shape, is doing the separating work.
- **Mechanic match (6):** an arrow reads as "up," matching "a big climb" in
  the general sense, but nothing about this icon signals *bigger* than
  `climb`'s arrow beyond being drawn slightly taller — a difference easy to
  miss at 42px and not the kind of distinction a hand read by shape can
  rely on.
- **Colour & contrast (5):** the lowest line this batch. The tan base slab
  sits close enough in value to the brown card standin (`RGB(139,105,74)`)
  that it nearly merges with the background at 42px, and the bbox
  clipping at the bottom edge compounds it — the base reads as a vague
  smudge rather than a distinct shape.
- **Style consistency (8):** matches the rest of the set's bevelled-block
  construction.

## Diagnosis — two lowest

1. **Colour & contrast (5).** Concrete fix: darken the tan base slab or
   give it an outline distinct from the card-face brown, and pull it fully
   inside the canvas so it isn't clipped at the bottom edge.
2. **Family distinction (3).** Same fix named in `climb_icon.md`: change
   one element of the outer silhouette (not just the base colour) so
   `ascend` doesn't rely on its gold wings alone to read as different from
   `climb`.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about (pass 1)

Whether the bottom-edge clipping on the tan slab is deliberate framing
(the base is meant to feel like it continues off-screen) or an oversight —
nothing in the build script's comments says which.

## Pass 2 — cloud, backlog #86 duty 1

Both named lines trace to the same two choices: the base slab's colour and
the outer silhouette. Applied both, per this item's own "REPAIRS now" rule
(backlog #86) — cloud owns portraits and icons, so this asset is in scope.

1. **Family distinction (3).** Concrete fix from this file and
   `climb_icon.md` both: change the outer silhouette, not just the base
   attachments. Replaced the single triangle-on-post with two arrowheads
   stacked with a visible gap between them (`tools/blender/icons.py`'s
   `ascend`) — a lower blunt-tipped head at z 0.06 and an upper pointed head
   at z 0.42, with the post and side wings kept underneath. `climb` keeps
   its one triangle untouched.
2. **Colour & contrast (5).** Concrete fix: the base slab was `TAN`
   (217,152,111), whose luminance the diagnosis found sat close enough to
   the brown card-face standin (139,105,74) to soften the edge at 42px.
   Changed to `CHARCOAL` (56,56,61) — a dark neutral, clearly separated in
   both hue and value. Also moved the slab from z=-0.56 (bottom edge at
   -0.635, outside the ortho frame's ±0.575 half-extent and clipped) to
   z=-0.48 (bottom edge at -0.55), which closed the clipping the alpha bbox
   showed in pass 1.

Rebuilt with `blender --background --python tools/blender/icons.py --
<out_dir>` (the `build.cmd icons` equivalent available here); only
`ascend.png` copied over the shipped asset, no other icon script touched.
Alpha bbox moved from `(38, 5, 218, 256)` (bottom row fully opaque, clipped)
to `(38, 5, 218, 251)` — clear of the bottom edge now.

Compared against `climb` at 42px composited over the same brown standin
(`design/renders/ascend_climb_family_42px_strip_pass2.png`) and as a solid
silhouette (`design/renders/ascend_icon_pass2_sil.png`,
`design/renders/ascend_icon_pass2_42px_big.png`):

- **Silhouette @ 42px (7 → 8):** the double-head shape survives the
  downsample as a single connected mass with a visible notch between the
  two heads, rather than one smooth triangle — reads as one deliberate
  glyph, not two disconnected pieces (the failure mode `rally_icon.md`
  pass 2 named and fixed for a different icon).
- **Family distinction (3 → 8):** side by side with `climb` at 42px, the two
  no longer share an outline. `climb` is one triangle on a post; `ascend` is
  two stacked heads with side wings and a dark base. Not a 9-10 because both
  still use the same wheat/gold "up" colour language, which is intentional
  (`design/progress/intangible_icon.md`'s rubric rationale treats colour
  reuse across a family as acceptable where shape differs).
- **Mechanic match (6, unchanged):** still an "up" glyph for a bigger climb;
  doubling the arrowhead is a size/emphasis cue but wasn't one of the two
  lines this pass touched, so left as scored.
- **Colour & contrast (5 → 8):** the charcoal base now reads as a distinct
  dark shape at 42px instead of a soft-edged smudge; no other colour in the
  render was touched.
- **Style consistency (8, unchanged):** still the set's bevelled-block
  construction; two heads instead of one doesn't change the build
  vocabulary used.

**+10 total (29 → 39), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**. Triangle count 656/700 (icon budget),
up from the original build's count but still under budget.

## Unsure about (pass 2)

Whether Mechanic match should also move now that the silhouette visibly
doubles — left untouched since it wasn't one of the two named lines and
this loop's rule is two fixes per pass, not a rescore of everything that
might have shifted. Also unsure whether `climb`'s own still-lower Family
score (3, unchanged, since `climb.py` wasn't touched) should be revisited
in a future pass now that `ascend` no longer anchors the shared-silhouette
problem from both sides — `climb_icon.md` is left as scored, since backlog
#86 rule 1 caps this pass at one asset.
