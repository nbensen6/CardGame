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

## Pass 3 — cloud, backlog #86 duty 1

Before touching anything, rebuilt both `ascend` and `climb` fresh
(`blender --background --python tools/blender/icons.py -- <out>`) and looked
at them side by side again — `climb_icon.md`'s pass 2 rebuilt `climb` from
an arrow-on-post into a three-step staircase (see `climb()`), which happened
after this file's own pass 2 was written. That pass 2 entry above still
describes `climb` as "one triangle on a post," which is stale: the current
`climb.png` shares nothing with `ascend`'s silhouette any more. Correcting
that observation alone (no geometry touched) moves **Family distinction
(8 → 9)** — not a full 10, for the same reason pass 2 gave: both icons still
use the shared wheat/gold "up" colour language on purpose.

That leaves **Mechanic match (6)** as the one genuinely low line. Diagnosis:
a doubled arrow reads as "up," same as `climb`'s staircase, with nothing in
the shape saying *bigger* beyond a mild, easy-to-miss-at-42px size
difference between the two heads. Concrete fix: widen the size gap between
the two heads dramatically instead of subtly — shrink the top head (base
0.24 → 0.16, height 0.26 → 0.20) and grow the bottom head (base 0.40 → 0.44,
height 0.30 → 0.32, tip tapered 0.06 → 0.05 so it still necks cleanly into
the post) — so the shape reads as one small head building into a much
bigger one, rather than two similar chevrons. That same size swing widens
the gap between the two heads from 0.08 to 0.11 world units, which also
hardens **Silhouette @ 42px (8)** against the downsample ever fusing the
notch shut — the other named-lowest line, addressed as a side effect of the
same two-number change rather than a second, separate fix.

Rebuilt with `blender --background --python tools/blender/icons.py --
"$PWD/game/assets/icons"` (the `build.cmd icons` equivalent available on
this run) and reimported with the Godot 4.7.1 headless binary — only
`ascend.png` differed from the shipped set after the rebuild; every other
icon came back byte-different too (background renderer is Blender 4.0.2 via
apt here, not the 4.1.1 this project normally uses, and produces
sub-pixel anti-aliasing differences — max channel diff 69/255, mean 0.3),
so those were reverted with `git checkout` and only `ascend.png` was kept.
Alpha bbox stayed clear of every edge: `(38, 12, 217, 250)` on a 256px
canvas, no clipping. Triangle count unchanged at 656/700 (icon budget) —
every change this pass was to existing primitives' size and position, not
new geometry.

Compared fresh at 42px against `climb`
(`design/renders/ascend_climb_family_42px_strip_pass3.png`), the full
render (`design/renders/ascend_icon_pass3_full.png`), the downsample
(`design/renders/ascend_icon_pass3_42px_big.png`) and the silhouette
(`design/renders/ascend_icon_pass3_sil.png`):

- **Silhouette @ 42px (8 → 9):** the notch between the two heads is now
  clearly wider and survives the downsample even more comfortably than
  pass 2's already-adequate gap; still one connected mass, not two floating
  pieces.
- **Family distinction (8 → 9):** correcting the stale pass-2 comparison,
  not a fix — `climb` is a staircase now, sharing nothing with `ascend`'s
  outline. Not a 10: same reasoning as pass 2, the shared colour language is
  deliberate.
- **Mechanic match (6 → 7):** the small-cap-on-a-big-head read now clearly
  signals escalation/growth rather than "two arrows of slightly different
  size," which is a real gain — not higher, because the connection to
  *climbing* specifically (rather than just "growing" in the abstract) is
  still carried by position and colour, not shape alone.
- **Colour & contrast (8, unchanged):** neither swatch nor slab position
  changed this pass.
- **Style consistency (8, unchanged):** still the set's bevelled-block
  vocabulary; a size change to existing primitives doesn't touch it.

**+2 total (39 → 41) — crosses the 40 stop line.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED** (fresh `--import`, headless, Godot
4.7.1.1).

## Unsure about (pass 3)

Whether Mechanic match could still climb further with a change this pass
didn't make — e.g. a third, even smaller head above the current tip, or a
short motion-line trail beside the post — both cost triangles this asset
has little budget left for (656/700) and neither was tried. Also: whether
`climb_icon.md`'s own Family score (still 3, last touched when `climb` was
rebuilt) should be revisited now that this file's side of the comparison
has moved past it a second time — left as scored, one-asset-per-pass still
holds.
