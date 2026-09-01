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
