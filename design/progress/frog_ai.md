# frog_ai — Meshy-based Frog rebuild, first-stage spike

Not the `design/asset-loop.md` loop proper yet — this is the shape-only step
before that loop can start, because the loop's Colour/Style lines need a
textured model and this one is untextured grey. Filed separately from
`frog.md` (the current Python-primitive Frog, past its own 42/50 hunter stop
line) because this is a different asset, not a revision of that one.

## Why this run

`tools/agents/artist.md`'s current brief names the Frog/Goblin fidelity gap
against the Cinder Jackal as the loudest open item, and explicitly permits a
full rebuild via the same Meshy pipeline that built the jackal
(`design/ai-beast-recipe.md`). Every prior run since 2026-09-23 1330–1345
found the same wall: Meshy could generate and finish a task but this cloud
sandbox could never fetch the result (`assets.meshy.ai` 403'd at the proxy).
That wall is now down —
`requests/2026-09-23-1345-artist-to-nick-meshy-fetch-blocked-by-network-policy.md`
is `status: done`, Nick added `assets.meshy.ai` to the Meshy credential's
allowed hosts, and this run independently re-confirmed it: `python3
tools/meshy.py fetch <id> <out>` on all three of the already-generated
2026-09-23 preview tasks succeeded, no proxy 403, no tunnel failure.

A prior run apparently ran a similar spike (`design/progress/frog_ai.md`
is referenced from
`requests/2026-09-23-1330-artist-to-fixer-hunter-display-path-has-no-toon-or-rig-support.md`
as "this run — a first-stage spike, not wired into the live game yet") but
never committed it — `tools/agents/COMMON.md` §4b's exact failure mode, a run
that did real work and pushed nothing. This file and its outputs did not
exist in the repo before this run. Redone from scratch, and pushed this time.

## What was fetched

The 3 Frog preview tasks logged in `design/progress/meshy-ledger.md`
(2026-09-23), all `SUCCEEDED 100`, all still fetchable by their ledger ids —
no new Meshy spend this run, 5 of the 8 daily tasks still unspent:

- `A` = `01a0ce35-34e2-729e-a8ef-1121afbc7eb9` — "crouched in a neutral resting
  pose on all four legs" — chosen (see below).
- `B` = `01a0ce35-5660-7720-8738-b922d8ff6552` — "sitting low on all four legs
  like a real [frog]" — kept as an alternate, not built.
- `C` = `01a0ce35-7774-743f-976b-e87b63fe6b9f` — "standing on all four short
  legs, two front..." — actually came back bipedal/bear-like (weight on the
  hind legs only, front paws off the ground) — anatomically a different
  animal than the current Frog's all-fours crouch, so not built either.

**Why A over B.** Both are valid quadruped frogs. A's stance is symmetric and
front-on; B's is asymmetric with the head turned, which reads well as a candid
photo but worse as a game character that needs to sit still and be readable
from a fixed camera. Chose A for that reason, not because B is worse-built.

## Cleanup: shape only, no rig, no texture, not wired into the game

Deliberately stopped short of `tools/blender/ai_beast.py`'s full pipeline.
That script is beast-specific (climb-marker placement, a 20-bone quadruped
rig keyed to the boss's own climb route) and `tools/agents/COMMON.md` is
explicit: hunters are not beasts, do not force them through it. A hunter
needs its own rig/animation path, which does not exist in game code yet —
`requests/2026-09-23-1330-artist-to-fixer-hunter-display-path-has-no-toon-or-rig-support.md`
is still open, unpicked, and until it lands, a hunter model — rigged or not —
has no toon shader and no idle/attack/hit animation to play (`combat_3d.gd`
`_shade_model`'s `root == _beast` gate, `_find_anim`/`_beast_play` never
wired to `_spawn_hunter`). Dropping even a perfect static mesh in as
`cast/frog.glb` today would replace a stylised, toon-shaded, correctly-lit
character with a plain-shaded grey one — a regression, not a win. So this
pass stops at a clean, correctly-scaled, correctly-oriented static mesh,
built and verified in isolation, and does **not** touch
`game/assets/3d/cast/frog.glb`, `AI_ART`, or any other live path.

New script, `tools/blender/ai/frog_ai_spike.py` (not a copy of `ai_beast.py`
— written for this narrower job):

1. Import the Meshy `.glb`, join to one mesh, weld doubles (`dist=0.004`,
   same tolerance `ai_beast.py` uses).
2. Orientation: checked, not assumed. Compared the current `frog.glb`'s and
   Meshy A's own top-60-vertices' average Y against each model's own Y
   midpoint — both land on the `-Y` (min-Y) side, i.e. both already face
   Blender `-Y`, the project's established "front" convention
   (`design/ai-beast-recipe.md` step 2). No rotation needed; would have
   flagged it as a defect if it had come out the other way.
3. Centre X/Y, feet to `z=0`, uniform-scale to match the current `frog.glb`'s
   own height (1.15, read directly off its bounds, not guessed) — same
   height-matching approach `ai_beast.py` uses for beasts, so this stays the
   scale already accepted in the live fight rather than introducing a new
   "is the Frog too big" question (Nick's 2026-09-23 finding on the current
   model, already resolved).
4. Decimate to 5,200 tris — the current `frog.glb` is 5,136 (itself already
   3.7x the nominal 1,400 hunter budget, an accepted overage per `frog.md`
   pass 8) — so this stays in the same order of magnitude rather than making
   a new, worse budget problem.
5. Export `tools/blender/ai/frog_ai_spike.glb` + save
   `tools/blender/ai/frog_ai_spike.blend` — **outside**
   `game/assets/3d/cast/`, on purpose: that folder is what `Cast.model_path()`
   (`game/ui/cast.gd`) resolves hunter ids against and what `look.sh cast`
   globs to score every shipped model, and this is neither yet.

## Verified, not assumed

`tools/blender/look.py` six-view capture, looked at all six locally;
`design/renders/frog_ai_pass1_{34,front,sil}.png` committed (`side`/`top`/
`form`/`wire` match `.gitignore`'s existing render-cap pattern for this
folder, not committed — the three kept are enough to judge this pass's
actual questions):

- **Reads as a frog immediately, including in pure silhouette at 64px**
  (`_sil.png`) — crouched haunches, splayed toes, the eye-dome pair, all
  legible as solid black. This is the one rubric line
  (`design/asset-loop.md`'s Silhouette) that a shape-only, untextured pass
  can actually be judged on, and it already reads better than several passes
  of the current primitive frog spent trying to get exactly this (see
  `frog.md` pass 5/8's haunch and foreshoulder work).
- **Front and top views**: symmetric left/right (checked by eye against the
  centre line in both), all four feet with distinct, separated toes, no
  self-intersection or stray geometry.
- **Decimation held up**: 27,314 raw tris → 5,200 with no visible faceting in
  any of the four views, including the 64px silhouette (a bad decimate shows
  up there first, as jagged edges — none seen).
- **Scale**: exported model's own height dimension is exactly 1.150 (matches
  the reference to 3 decimal places — the scale transform, not a coincidence),
  feet sit at `z=-0.0004` (effectively 0, not floating or sunk).

**What this pass does NOT show, honestly:** no colour/texture (a Meshy
`refine` task, not spent this run — the shape question needed answering
first, and burning the ~10-credit refine on the wrong candidate would waste
it), no rig, no animation, and **no in-game comparison** — per
`tools/agents/artist.md`'s own rule ("always compare before/after in the real
fight, same state and camera"), that would normally be required, but there is
nothing to compare yet: this model is not wired into any game path, so there
is no "after" screenshot that means anything. The comparison that *is*
meaningful this pass — this spike's isolated render against the current
`frog.glb`'s own isolated render, same angle, same neutral lighting — is in
`design/agents/frames/artist/2026-09-23-frog-meshy-spike-vs-primitive.png`.

## Not scored against the asset-loop rubric

`design/asset-loop.md`'s Colour & Style lines are not answerable on an
untextured grey mesh, and scoring the other three alone would invite
comparing a partial number against `frog.md`'s full 43/50 — misleading, not
informative. This file will get real rubric scores once refine (texture) and
a rig exist to judge.

## What's still open, in order

1. **Refine** (Meshy, ~10 credits, budget available: 5/8 daily tasks unspent)
   — texture this shape. Worth doing once, not per-candidate now that A is
   chosen.
2. **The hunter-display-path request** — still open, unpicked, blocks
   anything built here from ever showing toon-shaded or animated in the live
   fight. This is the real bottleneck now, not Meshy access.
3. **A hunter-specific rig** — this shape has no bones. `ai_beast.py`'s rig
   section is close in spirit (region-gated weights off measured leg
   positions) but keyed to beast climb markers this model doesn't need;
   reusable in structure, not as-is.
4. Once 2 and 3 exist: wire into `AI_ART` (or its hunter-table equivalent),
   verify in the real fight camera, and only then does this become a
   `design/asset-loop.md` pass with a real score.

![[frames/artist/2026-09-23-frog-meshy-spike-vs-primitive.png]]
