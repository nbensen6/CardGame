---
tags:
  - request
from: artist
to: fixer
status: open
priority: normal
created: 2026-09-23
taken_by:
---

# Hunters can't use the beast toon/rig display path (`AI_ART`) — blocks bringing them up to the jackal's fidelity

## What

Nick's current brief for the artist (`tools/agents/artist.md`, 2026-09-23) names the Frog and
Goblin Engineer's fidelity gap against the Cinder Jackal as one of the two loudest items on
`design/agents/JACKAL-BAR.md`, and explicitly allows rebuilding them in a different style,
including via Meshy — the same pipeline that built `cinder_jackal_ai.glb`
(`design/ai-beast-recipe.md`, `tools/blender/ai_beast.py`).

I confirmed (research pass this run, not yet acted on in game code — this is squarely game code,
not mine) that **the display path a rigged/toon Meshy model needs only exists for beasts, not
hunters**:

- `game/views/combat_3d.gd` `AI_ART` (~line 30) lists beast ids that load `<id>_ai.glb` and get
  the toon shader + ember glow.
- `_shade_model` (~line 2490-2530) only takes the TOON/painted-texture path when
  `root == _beast` (line ~2503) — a hunter model always falls through to the plain
  CREATURE-shader path built for the procedural palette-atlas UVs the Python-primitive hunters
  use, never toon, never glow.
- `_find_anim` / `_beast_anim` / `_beast_play` (idle loop, attack/hit triggers on damage) are
  only ever wired to `_beast`, in `_show_beast` (~1533-1568) and `_strike`
  (~4037-4056). `_spawn_hunter` (~3217-3236) never looks for or plays an AnimationPlayer on a
  hunter model at all.
- `game/views/location_3d.gd` `_place_hunters` (~341-361, character-select/reward screens) has no
  shading call at all for hunters.

So a rigged, Meshy-textured, animated hunter `.glb` dropped in today (e.g.
`game/assets/3d/cast/frog_ai.glb`, matching the beast `<id>_ai` naming convention) would render
in its bind pose, with no idle/attack/hit motion, shaded by the wrong material — it would look
worse than the current primitives, not better, until this is generalized.

## What I need

Generalize the beast-only rigged/toon-animated path so a hunter can opt into it the same way a
beast does — roughly: let a hunter id also be listed (in `AI_ART` or a parallel hunter table),
extend `_shade_model`'s `root == _beast` gate to also match a hunter root flagged this way, and
wire `_find_anim`/idle-loop/attack-or-hit triggers for a hunter's own AnimationPlayer (hunter
"attack" = playing a card that hits the beast; "hit" = the hunter taking damage — whatever
signal `_spawn_hunter`/its caller already has for that hunter's turn/damage events).

I'm not asking for a specific implementation — you know this file. Whatever shape fits the
existing beast plumbing best is fine; I just need hunters to be able to reach the same visual
treatment beasts already get.

## Why this can't wait on a separate "do it all in Blender" workaround

There's no way to fake the toon shader or the idle animation from the asset side — both are
runtime, code-side behaviours keyed off `root == _beast`. Until this lands, any Meshy-based
hunter rebuild has to ship as a **static, un-toon-shaded, un-animated** model (see my own
`design/progress/frog_ai.md`, this run — a first-stage spike, not wired into the live game yet
for exactly this reason).

## How to see it

Isolated repro: build any rigged glb with an `AnimationPlayer` named e.g. `idle`, drop it at
`game/assets/3d/cast/frog_ai.glb`, and it will not toon-shade or animate in
`state=3d beast=cinder_jackal` the way `cinder_jackal_ai.glb` does — because nothing routes a
hunter id through `AI_ART`/`_shade_model`'s beast branch. No isolated harness script exists for
this since it's an absence, not a crash; reading the four code locations above is the fastest
way to confirm it.

## Done when

A hunter id can be declared to use the toon-shaded, animated beast-style path, and a quick real
test proves it: point a hunter (even the current `frog.glb`/`goblin_mech.glb`, temporarily
tagged in, no new asset needed) at that path and confirm in a live-fight screenshot
(`state=3d`) that it toon-shades and its idle animation plays if the glb has one — then a
regression test in `game/tools/run_tests.gd` that a hunter tagged this way resolves through the
beast branch of `_shade_model`, so this doesn't silently regress later.

## Result

(filled in by whoever takes it: what changed, which commit, how verified)
