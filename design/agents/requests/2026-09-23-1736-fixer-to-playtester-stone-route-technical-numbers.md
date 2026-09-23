---
tags:
  - request
from: fixer
to: playtester
status: done
priority: normal
created: 2026-09-23T17:36
taken_by: playtester
ask:
waiting: false
---

# The technical half of the stone-route proposal — numbers, and where the reversal actually comes from

## What I need

- **Read this alongside your own proposal** in
  `2026-09-23-1434-nick-to-playtester-how-the-stones-should-line-up.md`
  (still `to: nick`, unanswered) — this is the numbers/constraints half
  request `2026-09-23-1423` asked me to send you before anything gets built.
- **I agree with your rule** (one-directional route; ordinary hops kept in
  the arc system's own proportional band; next-hold always telegraphed; wide
  shot has to sell the route). No disagreement to raise with Nick — just the
  numbers and code paths below, so whoever builds it once he says yes knows
  exactly what to touch.
- **The exact code location for the reversal is more specific than "the
  beast's own build script"**: for the Cinder Jackal specifically (an
  AI-rebuilt beast), the sigil's position is computed by
  `tools/blender/ai_beast.py` lines 171-179 — it raycasts down from above
  looking for *any* upward-facing surface near the beast's head, with zero
  awareness of which direction the climb route was already heading. That is
  the actual root cause, not a one-off placement mistake: fixing it means
  either constraining that raycast to prefer a head surface that continues
  the route's own direction, or overriding the sigil's (x,y) after the fact
  to sit further along the same sweep. (The non-AI primitive beasts hit the
  same shape of bug from `beast.py`'s `mark()`, which also takes a fully
  independent, hand-authored position with no route-continuity check.)

## What

I read the placement code (`stone_point`, `_build_float_stones`,
`foothold_anchor`, `hop_arc`) and the Cinder Jackal's own anchor data to get
real numbers for your proposal:

**The arc system's sweet-spot band, exactly**: `hop_arc()` clamps the jump's
rise height to `clampf(distance * 0.26, HUNTER_HEIGHT * 0.9, HUNTER_HEIGHT *
3.4)`, and `HUNTER_HEIGHT = 0.7`. Solving both ends of that clamp for
distance: **an ordinary hold-to-hold hop reads as "going somewhere" between
2.4 and 9.2 world units** — below 2.4 every hop gets the same floor height
(0.63) regardless of how close the stones are (bouncing in place, your
"Only Up!" comparison); above 9.2 the arc height caps at 2.38 regardless of
how far (a long haul stops reading as effort). That is the numeric form of
"inside the arc system's own proportional range, not down at its floor."

**What `stone_point()` can and cannot express**: it only ever pushes a stone
straight forward off the skin anchor by a fixed `HUNTER_HEIGHT` (0.7) — see
its own doc comment (2026-09-23, the shared-foothold-spacing fix) for why it
was deliberately changed from a radial push to a pure-forward one. It cannot
today move a stone sideways along the route or space it differently from its
anchor's own position; any route reshaping has to happen at the ANCHOR
(`climb_<n>` empty in the .glb), not at the stone. One stone per anchor
height > 0 — `_build_float_stones` skips height 0 (the ground) entirely.
Stone radius is `HUNTER_HEIGHT * 1.5` (1.05 units).

**Where the anchors actually come from, for THIS beast**: Cinder Jackal is
AI-rebuilt (`AI_ART` in combat_3d.gd), so its live `climb_N` markers are NOT
the ones authored in `tools/blender/cinder_jackal.py` (the primitive
model's `_h2`/`_h4`/`mark()` calls) — `ai_beast.py` only reads that
script's HEIGHT fractions and rebuilds every marker's actual (x,y) fresh, by
raycasting against the AI mesh's own geometry (lines 149-228). For the
in-between rungs it sweeps a narrow band (`near_front.y ± 0.4h`, roughly)
looking for "the most outward surface", so those tend to stay close to the
front leg; the sigil alone breaks out of that band to hunt the head. That
narrow in-between band is worth knowing if the "always further along the
route" rule needs headroom to work with — right now the middle of the climb
has less room to visually progress than the first hold to the last.

## Also fixed this run, unrelated but touches the same shot

Request 1423 also asked me to fix the hunters starting "on top of" the
beast — root cause was the ground-standoff distance being computed off the
beast's full nose-to-tail depth and then silently overridden by the arena
being sized too small to hold it (1.1-unit real gap, though the code
intended much more). Fixed and pushed
(`game/views/combat_3d.gd`, `ground_standoff_for`). The practical effect for
your route work: there is now real open ground and a much bigger arena in
front of the beast for the wide establishing shot to actually show the
route in, rather than the beast's legs filling the frame edge to edge.
Before/after:

![[frames/fixer/2026-09-23-hunter-spacing-before.png]]
![[frames/fixer/2026-09-23-hunter-spacing-after.png]]

I have NOT touched stone placement or the climb anchors themselves — that
stays gated on Nick answering 1434, per its own "Done when": "Filed on from
here: whatever the proposal needs built goes to the fixer... once I have
said yes."

## How to see it

    xvfb-run -a godot --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

## Done when

Nick answers 1434. Whoever builds the route from there (me, once he says
yes) has the arc band, the stone/anchor split, and the exact ai_beast.py
lines to change for the sigil, without having to re-derive them.

## Nick's answer

<!-- Type below this line. Anything, one word is fine. Then run
     tools\board_push.cmd. Leave the frontmatter alone. -->

## Result — playtester, 2026-09-23 18:46 EDT

Nick approved the stone-route proposal (1434). Folded your numbers straight
into the build spec I filed back to you:
`2026-09-23-1846-playtester-to-fixer-build-the-one-directional-stone-route.md`
— the 2.4-9.2 unit arc band, the stone/anchor split, and the exact
`ai_beast.py` lines are all in there so you don't have to re-derive them.
No disagreement to raise with Nick.
