# frog_ai — Meshy-based Frog rebuild

Filed separately from `frog.md` (the current Python-primitive Frog, past its
own 42/50 hunter stop line) because this is a different asset, not a
revision of that one. Pass 1 was shape-only, before the asset-loop rubric
could apply (no texture yet). **Pass 2 (below) refines, cleans and wires it
into the live fight via `HUNTER_AI_ART` — it is the shipped
`game/assets/3d/cast/frog_ai.glb` as of 2026-09-23T17:17 UTC, first real
rubric score 41/50.**

## Why this run

`tools/agents/artist.md`'s current brief names the Frog/Goblin fidelity gap
against the Cinder Jackal as the loudest open item, and explicitly permits a
full rebuild via the same Meshy pipeline that built the jackal
(`design/guide/ai-beast-recipe.md`). Every prior run since 2026-09-23 1330–1345
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
   (`design/guide/ai-beast-recipe.md` step 2). No rotation needed; would have
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
  (`design/guide/asset-loop.md`'s Silhouette) that a shape-only, untextured pass
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

`design/guide/asset-loop.md`'s Colour & Style lines are not answerable on an
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
   `design/guide/asset-loop.md` pass with a real score.

![[frames/artist/2026-09-23-frog-meshy-spike-vs-primitive.png]]

## Pass 2 — artist, 2026-09-23T17:17 UTC: refined, cleaned, wired into the live fight

Item 2 from pass 1's own list landed first: the hunter-display-path request
(`...hunter-display-path-has-no-toon-or-rig-support.md`) is now `status:
done` — the fixer generalized `_shade_model`'s beast-only toon gate behind a
new `HUNTER_AI_ART` table and `wants_toon()`, proved with a unit test and a
live before/after crop of the *current* `frog.glb` forced through it. That
was the real bottleneck (item 2), ahead of texture (item 1) and rig (item
3) — a rigged, textured model still can't show right without it, and a
*static* textured model now can, so this pass did item 1 and shipped
without item 3 rather than wait on a rig that isn't required to be seen.

**Refine.** One Meshy `refine` task on candidate A's own preview id
(`01a0ce35-34e2-729e-a8ef-1121afbc7eb9`), texture prompt: "bright mint
yellow-green frog skin (#55BF6D) with darker forest green markings on the
back and eyelids, cream/wheat pale belly, hand-painted stylized toon game
art, matte non-metallic, clean flat shading" — pulled straight from
`frog.py`'s own colour doc-comment (MINT body, GREEN markings, CREAM/WHEAT
highlights) so this stays the same character's established palette, not a
new colour question. Task `01a0cf3c-6c1f-75e7-aa9e-86736858b27f`,
`SUCCEEDED 100` on the first try — logged in `meshy-ledger.md`. 4 of 8
daily tasks now spent (3 preview + 1 refine), 4 left. The thumbnail alone
was worth stopping to look at before doing anything else: a clean,
symmetric, hand-painted frog that matches the brief's palette without any
cleanup yet.

**Cleanup, same recipe as pass 1, on the textured mesh this time.** New
script `tools/blender/ai/frog_ai_clean.py` — `frog_ai_spike.py`'s own
weld/centre/scale-to-1.15/decimate-to-5200 steps, unchanged, run against
the refined (textured) `.glb` instead of the untextured preview, so the
material comes along through every step rather than being reapplied after.
Confirmed the material survived decimation before exporting (`mats_post
1`, i.e. still one material, not split or dropped). Output straight to
`game/assets/3d/cast/frog_ai.glb` — the `<id>_ai` naming `AI_ART`/
`HUNTER_AI_ART` both resolve — plus `tools/blender/ai/frog_ai.blend`
alongside the other AI sources. Godot's own import step wrote
`frog_ai_Image_0.jpg` (2048×2048) beside the `.glb`, the same pattern
`cinder_jackal_ai_Image_0.jpg` already sitting in this folder — not
something this pass created by hand, and needed on disk for the model to
show textured, so committed alongside it.

**Wired in.** One line: `HUNTER_AI_ART := {"frog": "_ai"}` in
`combat_3d.gd`. Nothing else to change — `_spawn_hunter` already resolves
`HUNTER_AI_ART` over `Cast.model_path()`, calls `_shade_model(m, false,
true)` for a tagged hunter, and `_fit_height` rescales to `HUNTER_HEIGHT`
regardless of the source mesh's own scale, so pass 1's careful height-match
was for the isolated renders' own sake, not load-bearing here.

**Verified, not assumed:**
- `run_tests.gd`: `ALL TESTS PASSED` (the `wants_toon` unit tests the fixer
  added already cover this exact case: a `HUNTER_AI_ART` hunter takes the
  toon path on its own flag).
- Six-view `look.sh frog_ai 2` (pass 1's own renders, at the same filenames,
  were untextured — restored with `git checkout` first so this pass's
  textured renders land as their own `pass2` set instead of overwriting
  history). Reads as a frog immediately at every angle, texture visibly
  separates head/back markings/belly, no seams or stretching from the
  weld/decimate step.
- **Silhouette connectivity, the metric this loop has actually used before**
  (pixel-label on `_sil.png`, not a raw mesh-topology count): `1` connected
  component, 11,981px — nothing floats away from the body in projection.
  Checked the raw mesh too, honestly: `193` disconnected vertex islands by
  a direct edge-graph walk — Meshy's own remesh output, never hand-cleaned
  the way the jackal's mesh was, and a real open question for Hygiene (see
  score below), but it does not cost the visual read, which is what the
  silhouette check actually answers.

  **2026-09-24T12:23 EDT update:** that "193" question is now answered, not
  open. `design/progress/goblin_mech_ai.md` pass 9 checked this exact number
  before/after a real UV re-unwrap attempt and found it's raw disconnected
  geometry (unwelded bolts/greeble from the Meshy remesh), not a UV-seam
  artifact — confirmed on this asset directly too: 193 raw mesh components
  in the untouched `.blend` matches the 193 shipped-`.glb` islands exactly,
  meaning this frog's current UV already adds zero extra splitting. A
  re-unwrap cannot reduce this number (it was tried on the Goblin Engineer
  and made it worse, on five different seam strategies) — do not attempt it
  on this asset either. Left the frog untouched this pass.
- **The real fight, same state and camera, before/after** — `state=3d
  beast=cinder_jackal`, camera/hunter positions logged identical between
  runs (`CAM`/`HUNTER0`/`HUNTER1` lines match to 6 decimals). Before: the
  flat-shaded, outline-less primitive. After: the same black ink outline
  and toon-ramp shading the jackal itself wears, at true in-fight size —
  this is the first hunter pass on this whole thread where the win survives
  to the size a player actually sees, not just the close-up scoring camera.
  Also checked `3dgrip` (the frog standing on a foothold beside the jackal's
  leg — reads clearly, correctly scaled, no clipping) and `3dreward` (the
  reward screen; the party row sits below the visible crop at this camera,
  so nothing to compare there this pass, not a regression, just out of
  frame).

![[frames/artist/2026-09-23-frog-ai-toon-infight-crop-before-after.png]]
![[frames/artist/2026-09-23-frog-ai-infight-before.png]]
![[frames/artist/2026-09-23-frog-ai-infight-after.png]]

**Score, `design/guide/asset-loop.md` rubric, the first real one for this
asset (pass 1 was explicitly unscored — no texture yet):**

- **Silhouette 9** — reads as this frog immediately as solid black at 64px
  (verified above), symmetric, four distinct feet.
- **Proportion 8** — the crouch reads correctly as this fight's own Frog at
  the game's own height-match convention; held below 9 because this pass
  didn't do a side-by-side scale check against the Goblin/jackal in the
  live arena the way `goblin_mech.md`'s rig-scale passes did.
- **Build hygiene 7** — one mesh, one material (confirmed post-decimate),
  in the same accepted-overage tri class as the current model (5200 vs the
  current `frog.glb`'s own 5136, both well over the 1400 hunter budget),
  silhouette-connected. Held to 7, not higher: 193 raw mesh islands is a
  real unknown this pass surfaced and did not chase down — Meshy's own
  remesh, never hand-inspected piece by piece the way the jackal's mesh was
  in `ai-beast-recipe.md`'s own cleanup steps.
- **Colour & read 8** — matches the established Frog palette (MINT/GREEN/
  CREAM) and separates head, back markings and belly clearly at 512px and
  at true in-fight size (the crop above). Not verified at the 34px party-
  portrait scale — `portraits.py`'s own `AI_ART` table hasn't been extended
  to hunters, a separate, later scope, not touched this pass.
- **Style consistency 9** — the same Meshy "hand-painted stylized game art"
  pipeline as the jackal, and now the same toon-shader/ink-outline
  treatment, wired through the same code path. This is the change Nick's
  own "the Frog and Goblin don't look any different" note (quoted in the
  hunter-display-path request) was actually asking for.

**Total: 41/50** — one point under the 42 hunter stop line, an honest
number, not rounded up. The two lines to chase next are named above, not
guessed: Hygiene's 193-island question (does it cost anything once actually
inspected, or is it Meshy's normal output for a model this size) and
Proportion's missing side-by-side arena check.

`ALL TESTS PASSED`. Full `mode=play beast=cinder_jackal steps=80` playtest
re-run against the wired-in model: **`PLAYTEST OK: 0 failing check(s) {  }`**,
exit code 0, the full 80 steps (Meld, Catapult+Burn Coal, Leapfrog, Brace,
Take Aim, Scramble, Build Grapple, several climbs and hops) — no
regression.

## What's still open, in order (superseding pass 1's list)

1. **The 193-island Hygiene question** — inspect whether any of them are
   visible gaps/seams once actually looked at closely, not just confirmed
   silhouette-safe.
2. **A hunter-specific rig and idle/attack/hit animation.** `_hunter_play`
   and the idle-loop wiring already exist in `combat_3d.gd`, wired and unit-
   tested by the fixer's own request, and are a no-op on this model today
   purely because it has no `AnimationPlayer` — the moment a rig exists,
   this asset's idle life is live with no further code change.
3. **The Goblin Engineer's own equivalent** — no Meshy build attempted yet;
   its anatomy (arms, no quadruped gait) doesn't fit `ai_beast.py`'s rig
   math even in spirit, a from-scratch job.
4. ~~**Party-portrait/34px treatment**~~ — closed by pass 3 below.

## Pass 3 — Colour & read, artist, 2026-09-23T21:12 EDT

Closes item 4 above. `portraits.py`'s `AI_ART` table (`{"cinder_jackal":
"_ai"}`) only ever pointed the portrait renderer at the beast's rebuilt
model — `combat_3d.gd`'s own `HUNTER_AI_ART` table has named `frog: "_ai"`
since the hunter-display-path fix, but nothing told `portraits.py` the same
thing, so `game/assets/portraits/frog.png` (shown in the party rail, the
character card and campfire) was still rendered from the old Python-
primitive `frog.glb`, not the Meshy model actually standing in the arena. A
real fight screenshot shows it: the party rail's frog icon and the frog
hunting the jackal in the same frame did not match.

**Fix:** `AI_ART = {"cinder_jackal": "_ai", "frog": "_ai", "goblin_mech":
"_ai"}`, `painted=` now true for both hunters too (an AI model's texture
already carries painted light/shade the same way the jackal's does — same
reason `look()` already drops specular for `painted=True`). Re-rendered
both portraits with the existing `FOCUS`/`FOCUS_XY` entries unchanged —
they already framed the `_ai` mesh correctly, nothing to retune.

![[frames/artist/2026-09-23-hunter-portraits-34px-old-vs-new.png]]
![[frames/artist/2026-09-23-hunter-portraits-party-rail-before-after.png]]

**This is also the 34px verification pass 2's Colour & read line named as
outstanding**, now actually measurable instead of assumed, because the
portrait the party rail draws finally IS this model. Measured on the real
34px-downsampled render (mean saturation/value over non-transparent
pixels): **sat 0.69, val 0.44** — separates head/back-marking/belly/eye
cleanly at the size the rubric grades (`asset-loop.md`: "Legible at 34px in
the party panel, not just at 512? Nothing dark-on-dark."), confirmed by eye
against the party rail's own dark-brown background, not just the number
(frame above).

**Score: Colour & read 8 → 9.** The only reason pass 2 held this line at 8
was "not verified at the 34px party-portrait scale" — that caveat is now
answered, and answered clean, not just closed. Every other line is
unchanged (Silhouette 9, Proportion 8, Build hygiene 7, Style 9): this pass
touched no geometry, texture or shader, only which model the portrait
renderer reads. **Total: 41 → 42/50 — at the 42 hunter stop line.**
`frog_ai` on its own now clears the bar `JACKAL-BAR.md` sets for a hunter;
`goblin_mech_ai` (39/50, see its own note) is what still holds the shared
"Frog and Goblin match the jackal's fidelity" line unticked.

`ALL TESTS PASSED` (`run_tests.gd`; no game code touched, a Blender tool
table and two portrait PNGs only). No playtest re-run: nothing moves or
renders differently in the 3D scene itself, only the 2D portrait texture
the party rail and campfire already knew how to draw.

### Where it stands

**42/50 — at the hunter stop line.** Lines: Silhouette 9, Proportion 8,
Build hygiene 7, Colour & read 9, Style consistency 9. What's left, in
order: the 193-island Hygiene question (item 1 above, unchanged this pass)
and Proportion's missing side-by-side arena scale check (pass 2's own
note) — neither blocks the stop line, both are real remaining unknowns.
