---
tags:
  - request
from: artist
to: fixer
status: open
priority: normal
created: 2026-09-23T15:40
taken_by:
ask:
waiting: false
---

# The shared ink-outline width reads fine on the beast/Frog but turns a mechanically-detailed hunter almost solid black at true in-fight size

## What I need

- The Goblin Engineer's new Meshy rebuild (toon-shaded, same pipeline as the
  shipped Frog) is unreadable in the real fight — not a texture problem, a
  fixed outline-width problem. Built, tested, NOT shipped; see frame below.
- `game/assets/3d/outline.gdshader`'s `width` uniform (0.0045, scaled by
  view distance) draws the same line weight on every model. It's tuned for
  thick, rounded masses (the jackal, the Frog). A hunter with several thin
  parts (straps, tank fittings, limb segments) gets that same-width stroke
  on every one of those thin parts, and at hunter scale the strokes start
  overlapping and eating the model.
- Confirmed by a local test only (reverted before committing): dropping
  `width` to 0.0015 for this one render made the identical asset read
  clearly. I'm not asking for that literal fix — you know this shader and
  where `HUNTER_AI_ART`/hunter materials are set up; a per-hunter (or
  per-model-scale) outline width knob is probably the right shape, not a
  global change that could affect the jackal or the already-shipped Frog.
- This blocks the Goblin Engineer rebuild today, and will block any future
  rigged hunter with fine mechanical/costume detail — worth fixing at the
  general level, not just for this one asset.

## What

Full build, measurement and diagnosis in `design/progress/goblin_mech_ai.md`
("Wired in, tested against the real fight, and found wanting" section). Short
version: `goblin_mech_ai.glb` (Meshy preview + refine, cleaned/decimated,
committed this run but **not** wired into `HUNTER_AI_ART`) toon-shades and
ink-outlines correctly — the same code path the Frog already uses
successfully — but at the size a player actually sees in the fight, the
outline strokes from its many thin parts merge into each other and the
model reads as a near-solid black shape. A texture-brightness fix (gamma
lift on the baked texture, no new Meshy spend) made almost no visible
difference; a temporary, reverted outline-width test made all the
difference. That rules out the texture and isolates the outline pass as the
actual cause.

## How to see it

1. In `game/views/combat_3d.gd`, temporarily set
   `const HUNTER_AI_ART := {"frog": "_ai", "goblin_mech": "_ai"}` (line 40 —
   the asset is already on disk at `game/assets/3d/cast/goblin_mech_ai.glb`,
   nothing else to build).
2. `xvfb-run -a godot --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720`
   — the Goblin (hunter1, right side) reads as almost solid black.
3. Revert the line before committing anything else (this request's own
   `git diff` on `combat_3d.gd` is clean — the flag is off in the shipped
   game right now).

![[../frames/artist/2026-09-23-goblin-mech-ai-crop-outline-width-diagnosis.png]]

Left to right: the current primitive (reads fine, the bar to clear), the
Meshy rebuild at the shared default outline width (fails it), the same
rebuild with a 3x thinner outline in a throwaway local test (passes it).

## Done when

A hunter tagged in `HUNTER_AI_ART` with several thin parts reads clearly at
true in-fight size — some form of outline-width control that doesn't
require every future hunter asset to be built with the beast's own outline
tuning in mind. Once it lands, I'll re-wire `goblin_mech` in and give it a
real asset-loop score; right now it's built and waiting, not shippable.

## Nick's answer

## Result
