# rally — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
17 — continuing the icon rubric batches 14-16 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/rally.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). Fourth of batch 17's
four, and the last of the **"six are about going up" family**
(`climb`, `ascend`, `peak`, `rope`, `lift`, `rally`) — see
`design/progress/lift_icon.md` for the other family member this batch
scored and the full family strip note.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-16 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

Same Pillow-based 42px downsample and alpha-bbox method as `lift_icon.md`
(this batch) and batches 14-16.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 3 | 7 | 2 | 5 | 6 | **23** |

**Lowest score recorded under this item across all seventeen batches** —
below batch 13's `bog_leech` at 25.

## What is actually there

Two pieces that do not touch: lower-left, a dark reddish-brown ball (the
mouthpiece the build comment names) with a bent pale-tan bar rising away
from it toward upper-centre (the horn's `limb`); upper-right, a separate
solid gold triangular wedge with no visible connection to the tan bar at
all — a clear gap of empty (transparent) space sits between the end of the
limb and the near edge of the wedge at both the full 256px render and the
42px downsample. The build comment's own "call coming out of it: arcs, not
rings, so nothing has to be hidden" — three curved lines meant to represent
the horn's sound — are not visible anywhere in the render, at either size.
Alpha bbox `(0, 40, 255, 226)`: both the leftmost and rightmost columns are
fully opaque, i.e. the piece is flush-cropped against both side edges of
the canvas with no margin, the same clipping pattern this batch's own
`strength` also shows (see `strength_icon.md`).

- **Silhouette @ 42px (3):** does not read as a horn, or as one object at
  all — it reads as two unrelated floating shapes, a bent stick-with-a-ball
  and a separate wedge, which is what the build comment's own history
  already worried about for the *previous* two attempts ("read as a crown,"
  "a backing plate in front of everything") but not this third one. The
  disconnection is worse than either named failure mode: at least a crown
  or a mis-placed plate reads as a single (wrong) object, where this reads
  as no object.
- **Family distinction (7):** ironically high, because nothing else in the
  set is two disconnected floating shapes — it will not be confused with
  `climb`/`ascend`/`peak`'s single triangle-on-a-mass silhouette, or with
  `bomb` (a single central ball) despite sharing a rounded dark shape at
  one end. Distinct for the wrong reason: it stands out because it reads as
  broken, not because it is a well-formed, recognisable shape of its own.
- **Mechanic match (2):** the lowest single line scored under this item so
  far. "Lift the whole party" / a rallying horn call requires reading a
  horn shape and, ideally, a sense of sound radiating from it; this render
  gives neither — no bell-to-mouthpiece connection and no visible arcs, so
  there is nothing in the image to associate with "horn" or "call" at all
  without already knowing the build intent.
- **Colour & contrast (5):** the gold wedge reads clearly against the brown
  card standin, but the tan limb sits close enough in value to the same
  brown that its far end (away from the dark ball) nearly fades into the
  background at 42px — a smaller version of the same near-miss `rope`
  scored 3/10 for in batch 16.
- **Style consistency (6):** the individual pieces (ball, tapered limb,
  faceted wedge) use the set's usual bevelled-block construction, but a
  render with a visible gap between its own parts is not what the rest of
  the committed set looks like — every other scored icon this item has
  reviewed is one connected mass.

## Diagnosis — two lowest

1. **Mechanic match (2).** Concrete fix: close the gap between the `limb`
   endpoint (`(0.16, 0.0, -0.16)`) and the `taper`'s near face
   (`taper((0.36, 0.0, 0.06), ...)`) so the bell visibly continues from the
   body instead of floating clear of it, and either enlarge the three call
   arcs or give them a colour that separates from both the gold wedge and
   the brown card standin so they render as visible sound-lines rather than
   disappearing.
2. **Silhouette @ 42px (3).** Concrete fix: the same geometry change fixes
   this line too — a single connected horn shape (mouthpiece → limb → bell,
   touching end to end) would replace two floating shapes with one
   recognisable silhouette.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the gap between limb and wedge is a genuine geometry bug (the
`taper`'s position simply doesn't reach the `limb`'s endpoint) or a camera/
render-angle artifact that would close up from a different view — this
scoring pass only has the one orthographic head-on render `icons.py` itself
produces, the same one the game actually uses, so this file can say the
gap is real *in the icon players will see*, but not diagnose which of the
two it is in the source geometry. Also unsure whether the missing call-arcs
are absent from the render (culled, wrong colour, or behind another part)
or simply too thin to survive antialiasing at this resolution — this file
did not re-render with a debug material to check.

## Pass 2 — fixer

Both named lines came from the same geometry: the `taper`'s `loc` was a
freestanding position that never actually reached the `limb`'s last point,
and separately, the call arcs' centre/radius put them outside the camera's
±0.575 ortho frame — off-canvas, not merely thin or miscoloured (confirmed
by hand: at the old centre `(0.42, 0.22)` with `r=0.46`, the arc's rightmost
point projects to x≈0.87, past the 0.575 right edge; the pass-1 diagnosis
suspected antialiasing or occlusion but the actual cause was clipping).

Applied both:

1. **Mechanic match (2) / Silhouette (3), the gap.** Solved `taper`'s `loc`
   for the point that puts its near face exactly on the `limb`'s endpoint:
   moved from `(0.36, 0.0, 0.06)` to `(0.25, 0.0, -0.004)`. A zoomed crop of
   the join (`design/renders/rally_pass2_junction.png`) shows the tan limb
   and gold bell meeting with no transparent gap between them — the concave
   notch that remains where the two tapers meet at an angle is normal
   silhouette geometry, not disconnection.
2. **Mechanic match (2), the missing call.** The old arc centre/radius put
   them past the frame edge regardless of colour or thickness, so a colour
   change alone (the diagnosis's other option) would not have fixed this.
   Moved the arcs to open space above the bell — centre `(0.30, 0.42)`,
   radius shrunk from `(0.30, 0.46)` to `(0.14, 0.20)` so they sit inside the
   frame with margin — thickened the tube from `0.038` to `0.055`, and
   recoloured from `ORANGE`/`TANGERINE` (both close to the horn's own
   gold/amber/tan) to `WHITE`/`ICE` (cool, bright, and nowhere else in this
   render) so they separate from both the wedge and the card standin. Both
   the full 256px render and the 42px downsample
   (`design/renders/rally_pass2_42px_big.png`, nearest-neighbour upscaled
   for viewing) now show a visible pale accent near the horn; at 42px it
   reads as a small light mark rather than three distinct arcs, which is an
   inherent limit of that much curve detail at 42px, not a rendering
   failure.

Rebuilt with `build.cmd icons` (rebuilds the full 28-icon set; only
`rally.png` actually changed — no other icon script was touched). Alpha
bbox (Pillow `getbbox()`) moved from `(0, 40, 255, 226)` to `(0, 13, 256,
227)` — still flush against the left and right edges, because the gold
wedge's own width (r1=0.36, untouched — not one of the two named lines)
already reached both edges before this pass and still does now; not fixed,
not claimed fixed.

- **Silhouette @ 42px (3 → 7):** the 42px downsample and the `_sil.png`-style
  solid-black recolour (`design/renders/rally_pass2_sil.png`) both show one
  connected horn shape — mouthpiece, limb, and bell touching end to end —
  where pass 1 showed two unrelated floating pieces. The small arc cluster
  is a separate shape by design (sound coming off the horn, not part of the
  horn's own body), small enough that it doesn't read as a second competing
  object.
- **Family distinction (7, unchanged):** still doesn't resemble any other
  icon in the set; the reason changed from "distinct because broken" to
  "distinct because it's a well-formed horn," which the rubric doesn't
  separately reward, so the number holds.
- **Mechanic match (2 → 6):** the horn now reads as a horn at both sizes
  checked, and the call is visible (not absent) at both sizes, which is what
  this line asked for. Not higher: at 42px the arcs blur into a single pale
  accent rather than three legible curved lines, so "a horn making a sound"
  reads more confidently than "a horn calling for a rally" specifically.
- **Colour & contrast (5, unchanged):** the tan limb's near-miss against the
  brown card standin (this batch's own diagnosis, not one of the two lines
  picked) is untouched — out of this pass's two-fix budget.
- **Style consistency (6 → 7):** the render is now one connected mass built
  from the set's usual primitives, matching the rest of the committed set's
  construction the way pass 1 said this one specifically did not.

**+9 total (23 → 32), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether the wedge's own width (`r1=0.36`, roughly 63% of the 1.15 frame)
should come down — it still reaches both the left and right frame edges
after this pass, per the alpha bbox above. That's a size call on a part
neither named rubric line pointed at, not a gap or a missing-arc problem,
so it's flagged here rather than touched.

## Pass 3 — cloud, backlog #86 duty 1

Pass 2 scored Silhouette 7, Family 7, Mechanic 6, Colour 5, Style 7 (32/50).
Two lowest: Colour (5) and Mechanic (6).

Sampled the actual rendered pixels rather than guessing from swatch values.
The limb's shaded underside (`AMBER`, full swatch `(255,171,66)`) rendered at
`(181,127,57)` against the `(139,105,74)` card standin — a weak, and on the
blue channel *reversed*, per-channel gap (+42/+22/-17), the same "flat swatch
reads fine, shaded surface doesn't" trap `rope_icon.md`'s pass 2 named for
`TAN`. Separately, the two call-arcs (radii 0.14/0.20, tube radius 0.055
each) had a 0.06 radius gap against a combined 0.11 of tube thickness — they
were geometrically overlapping, which is the actual cause of pass 2's own
"blurs into a single pale accent" read, not merely small size.

Applied both:

1. **Colour (5).** Swapped the limb's material from `AMBER` to `SAND`.
   Re-measured the same shaded-underside pixel on the real render:
   `(190-206, 165-193, 148-184)` along the limb body against the same
   `(139,105,74)` standin — a strong positive gap on all three channels
   everywhere except the tight concave crease where the limb meets the bell,
   which carries a legitimate AO shadow and isn't part of either named line.
2. **Mechanic (6).** Pulled the inner arc's radius from 0.14 to 0.08 (gap
   0.06 → 0.12) and thinned both tubes from 0.055 to 0.040 (combined
   thickness 0.11 → 0.08), so the two arcs no longer touch. Outer radius
   (0.20, already confirmed in-frame) untouched, so no new clipping risk.

Rebuilt with the real `blender` binary (apt package, 4.0.2 — the network
policy in this container blocks `download.blender.org` this run; `apt-get
install blender` is the same fallback the 2026-09-03 duty-1 turn used).
Rebuilt the full 36-icon batch, diffed every file against committed by mean
per-channel pixel difference, not just alpha bbox: every icon except
`rally.png` came back at mean diff ≤ 6 (ordinary render/AA noise, the same
threshold `flicker_stag_portrait.md`'s pass 2 used), so those 35 were
reverted. Kept only `rally.png`.

- **Silhouette @ 42px (7 → 8):** `design/renders/rally_pass3_sil.png` shows
  the horn as one connected mass, same as pass 2, and the arc cluster now
  reads as two distinct marks instead of one blurred blob.
- **Family distinction (7, unchanged):** still the only two-piece silhouette
  in the set; the rubric doesn't separately reward the reason changing.
- **Mechanic match (6 → 7):** the horn+call reads more confidently as two
  separate strokes at 42px (`design/renders/rally_pass3_42px_big.png`)
  rather than one pale smudge. Not higher: at 42px the two strokes still
  read as abstract marks near the horn, not unambiguously "sound," which is
  an inherent limit of that much curve detail at this resolution, not a
  leftover of this pass's fix.
- **Colour & contrast (5 → 8):** verified directly off the real render
  (numbers above) — a real, substantial gap along the whole limb body, not
  just the flat swatch value.
- **Style consistency (7, unchanged):** same primitives, still one connected
  mass; this pass changed a colour and two radii, not the construction.

**+5 total (32 → 37), not a plateau — kept.** No line regressed. Below the
40/50 stop line; 3 of 4 passes used.

`run_tests.gd`: ALL TESTS PASSED (fresh import, headless, godot 4.7.1).

## Unsure about (pass 3)

Whether a 4th pass on the gold bell's own shaded underside (the crease
shadow noted above, close to the card standin in a small area near the
limb/bell join) is worth it — it's a normal AO shadow in a concave crease,
not a flat-colour near-miss like the limb was, so it may not respond to a
swatch swap the same way. Left for a future pass rather than guessed at
here.
