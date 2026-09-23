---
tags:
  - request
from: artist
to: fixer
status: done
priority: high
created: 2026-09-23
taken_by: fixer
---

# Hunters can't use the beast toon/rig display path (`AI_ART`) — blocks bringing them up to the jackal's fidelity

## Nick, 2026-09-23: this is the top of the fixer queue

Nick played the current build and said the Frog and Goblin "don't look any
different." He is right, and this request is why: every artist pass on them
so far has been detail work inside a close-up scoring camera (the artist's
own pass 10 note says it "honestly does not survive to true in-fight size"),
because the one change that WOULD read — a Meshy-built, toon-shaded, animated
hunter — cannot be displayed at all until this lands. Meshy downloads were
unblocked today, so this is now the only thing standing between the artist
and real hunter models. Take it before anything else.

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

**Generalized, not reimplemented.** The beast-only gates you named were all real; fixed each at
its own spot rather than building a second parallel system:

- New `HUNTER_AI_ART` table (`combat_3d.gd`, beside `AI_ART`) — a character id listed here loads
  `<id><suffix>.glb` over `Cast.model_path`'s stand-in/your-own-art result, the same way `AI_ART`
  already wins over a beast's Python-built model. Kept as its own table rather than merged into
  `AI_ART`, since `AI_ART`'s doc comment and every existing reader of it (`_show_beast`,
  `location_3d.gd`'s felled-beast lookup) means "beast" specifically. Empty until an artist ships
  a rigged hunter `.glb` — nothing changes for any hunter until then.
- `_shade_model`'s `root == _beast` gate is now `Combat3D.wants_toon(beast_here, beast_toon,
  force_toon)`, a pure static function: `beast_here`/`beast_toon` are exactly the old inline test
  (unchanged for every existing beast call), `force_toon` is the new per-call hunter knob.
  `_spawn_hunter` passes `true` when its character id is in `HUNTER_AI_ART` and the `.glb`
  exists; every other call site (`_show_beast`, the ground shade, the plain-hunter case) passes
  `false` by default, so behaviour for everything that exists today is byte-for-byte unchanged.
- `_spawn_hunter` now mirrors `_show_beast`'s own idle wiring: `_find_anim(m)` on the loaded
  model, loop `idle` if present and play it — a no-op for every hunter today (no
  `AnimationPlayer` on the Python-primitive models), live the instant a rigged `.glb` lands.
  Stored on the hunter dict as `"anim"` alongside the existing `"node"`/`"body"`/`"home"`.
- New `_hunter_play(slot, anim)` — `_beast_play`'s own twin, scoped to one hunter's
  `AnimationPlayer`. Wired into `_react`: a hunter takes damage (`hunter_dmg[i] > 0`, the same
  per-hunter loop that already drives that hunter's damage popup) plays `_hunter_play(i, "hit")`;
  a hit lands on the boss (`plan["boss_hit"]`) plays `"attack"` on every hunter. **Known limit,
  written down rather than hidden**: the shared state diff `_react` reacts to carries no
  per-hunter attribution for which hunter's card connected — only that the boss took a hit, the
  same aggregate signal `_beast_play("attack")` already uses for the beast's own side of a hit —
  so "attack" fires on every hunter together rather than only the one who acted. Real
  per-hunter attribution would need a new field in `core/combat.gd`'s snapshot/diff, out of scope
  for "generalize the display path"; flagged here rather than silently faked.
- `location_3d.gd`'s `_place_hunters` (reward screen) got the matching lookup + `toon_all(n)` —
  the same treatment its own `_lay_out_the_felled` already gives a felled `AI_ART` beast right
  next to this row.

**Proof.** `Combat3D.wants_toon` unit-tested against all four cases (`run_tests.gd`): an AI_ART
beast still takes the path (unchanged case), a plain beast doesn't toon just because some other
hunter is tagged, a `HUNTER_AI_ART` hunter takes the path on its own flag regardless of the
beast, and an untagged hunter never does even next to a toon beast. Reproduced the pre-fix gate
first: temporarily reverted `wants_toon`'s body to the old `beast_here and beast_toon` (ignoring
`force_toon`) and reran — the "hunter opts in on its own" test failed exactly as predicted
(`force_toon` had no effect), the other three still passed. Restored the fix, reran: `ALL TESTS
PASSED`.

**Live verification**, exactly as asked — no new asset needed. Temporarily set `HUNTER_AI_ART :=
{"frog": ""}` (routes the existing `frog.glb` through the new path with no suffix), rendered
`state=3d beast=cinder_jackal` before and after, cropped to the frog:

![[frames/fixer/2026-09-23-hunter-toon-path-frog-before-after.png]]

Left (untagged): flat `CREATURE`-shader frog, no outline. Right (tagged): the black ink outline
and toon-ramp shading the Cinder Jackal's own `AI_ART` build wears — confirms `_shade_model`
really routes a tagged hunter through the toon material end to end, not just in the unit test.
`frog.glb` has no `AnimationPlayer`, so the idle-loop half of this couldn't be shown live this
run; `_find_anim`/`_beast_play`'s own existing beast-side behaviour (already proven on the
Cinder Jackal) is the same code path `_hunter_play` now reuses, so it will fire the moment a
rigged hunter `.glb` exists. Reverted the temporary tag before committing —
`HUNTER_AI_ART := {}` ships empty, `git diff` confirmed clean of the test tag.

Full fresh `mode=play beast=cinder_jackal steps=80` run after the revert, to make sure the
`_react` changes (new code in the hot per-tick diff loop) didn't regress anything for the
existing, all-untagged roster: see the status note for the result.

Commit: pushed as part of this run (see `tools/agents/status/fixer.md`'s `## Log` for the hash).
