---
tags:
  - request
from: nick
to: artist
status: done
priority: high
created: 2026-09-23
taken_by: artist
---

# Prove you can recreate Nick's Canva card art — one test, on the Frog's Leap

## What

Card art is Nick's job to design, not yours to invent: he paints a card in
Canva and you reproduce that style for the rest of the deck. Before any of
that scales, prove the recreate step works, ONCE, on a card he has already
made: `game/assets/cardart/leap.png` (the Frog's Leap).

Study it as the style target and say in words what defines it — flat painted
shapes, layered depth from foreground silhouettes to pale far trees, a soft
limited palette, the subject (the frog) tiny inside a big landscape, no
outlines, no texture noise.

Then produce ONE new 620x870 card art in that same style, by whatever route
you can defend (Meshy text-to-image is available through
`tools/meshy.py`-style API access; a Blender-rendered scene painted down to
flat shapes is also fair), for a card of your choice from the Frog's pool
that has no art. Put it beside Nick's Leap in one image so the styles can be
compared honestly at card size (~160px tall) as well as full size.

**Do not** ship it into `game/assets/cardart/` and do not do a second card.
This is a workflow test, and the answer may be "this route cannot match it".

## Done when

The comparison image is in `design/agents/frames/artist/`, embedded in the
result below, with your honest read on whether the style can be matched and
what it would cost per card. Then go back to characters and environment.

## Result

**What defines `leap.png`'s style, in words** (studied at 1:1 and in crops,
not guessed): flat filled shapes, no outlines, no photo texture. Depth comes
entirely from an atmospheric-perspective colour ramp — pale near-white
green/blue far back, through mid green, to near-black-green up close — never
from 3D shading (no specular, no AO, no lens-perspective distortion). The
composition is a tree-lined corridor: dense trees hug the left/right thirds
for the *full height* of the frame (many thin bare near-black trunks, sparse
leaf tufts only near their tips, rounded — not spiky — canopy lobes layered
behind them), leaving a narrow ragged sky slit up the centre-top that
narrows into open air over a path/clearing at the bottom. The frog is tiny
(~5% of frame height), off-centre, perched on a branch, camera pulled back
so the landscape is the actual subject.

**Route tried: pure 2D procedural paint** (`tools/cardpaint.py`), not a
Blender render. Reasoning: `leap.png` itself carries none of the cues a 3D
renderer produces for free (no specular highlight, no camera-lens
perspective, no ambient occlusion) — it is built from flat layered shapes,
which fighting a renderer into faking is more work than building directly.
Palette sampled straight from `leap.png`'s own quantized pixel histogram (11
colours, see the script's constants) rather than invented, so at minimum the
colour language is a real match, not an eyeballed one. Picked **Hop**
(Frog's starter deck, currently a bare icon) — a climb card like `leap`, for
a fair side-by-side.

**Took three full rewrites, not one.** First pass used stacked-triangle
"Christmas tree" silhouettes and put distance recession in a big flat empty
sky rectangle — read nothing like a forest. Second pass fixed the flat gap
but the trees pointed the wrong way (a base-height bug placed far canopies'
wide ends near the top of the frame, so they hung like icicles). Third pass:
switched canopies to overlapping rounded ellipse lobes on thin bare trunks
after cropping `leap.png`'s left/right margins and actually looking —
leap's canopies are lobed, not spiky — and rebuilt the composition as two
full-height tree "walls" in the margins with a hazy, *partly-translucent*
centre treeline (not a fully-opaque one, which read as a solid green wall)
that stops short of the clearing. Each round needed a fresh look at the
render, not just a parameter tweak — this is worth knowing before scaling.

**Honest read:** it gets the surface cues — palette (literally sampled),
flat-shape layering, atmospheric-perspective depth, tiny-subject-in-a-big-
landscape framing — close enough to read as "the same family" at a glance,
especially at card size where detail compresses. It does **not** get Nick's
hand. `leap.png`'s canopy shapes are confident, asymmetric, and read as
unmistakably pine trees the instant you see them; the procedural ellipses
here need the surrounding forest context to read as trees at all, and the
centre recession still reads as a soft green smear more than an actual
receding treeline. That gap is not a parameter I ran out of time to tune —
it is the artist's judgement about where to put a branch, how wide to make
one canopy versus its neighbour, that a human illustrator supplies for
free and a procedural script has to fake with a lot of hand-tuned
randomness per scene.

**Cost if scaled:** this one card cost three full script rewrites plus two
targeted patches, each requiring a fresh visual read — call it several
hours-equivalent of iteration for ONE reused forest template. A different
card needs a genuinely different scene (not every card is "small subject in
a forest"), so there is no shortcut where card #2 reuses card #1's tuning —
each would cost roughly the same again. Against Nick's stated preference
(he paints, the artist recreates the *style*), this route does not save
him the painting step; it produces a different, generic-vector-forest style
next to his specific one. **Recommendation: don't scale this.** If
procedural generation has a place here, it's as a rough compositional
underlay Nick paints over, not a finished-card pipeline.

Comparison (full size and card size, ~160px tall, side by side):

![[frames/artist/2026-09-23-leap-style-recreate-test.png]]

Per the request, **not shipped** into `game/assets/cardart/` and no second
card attempted. `tools/cardpaint.py` stays in the tree for reference/re-run.
`ALL TESTS PASSED` (no game code touched; ran the suite anyway rather than
assume).

