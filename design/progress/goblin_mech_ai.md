# goblin_mech_ai — Meshy-based Goblin Engineer rebuild, pass 1

Filed separately from `goblin_mech.md` (the current Python-primitive Goblin
Engineer, past its own 42/50 hunter stop line) because this is a different
asset, not a revision of that one — same split `frog_ai.md` uses for the
Frog.

## Why this run

`tools/agents/artist.md`'s brief names the Frog/Goblin fidelity gap against
the Cinder Jackal as the loudest open item on `JACKAL-BAR.md`. The Frog
already has a Meshy-built, toon-shaded, wired-in replacement
(`frog_ai.md` pass 2, 41/50, shipped via `HUNTER_AI_ART := {"frog": "_ai"}`)
— the Goblin Engineer is the other half of that gap, and had no Meshy
attempt yet. Both blockers `frog_ai.md` named (Meshy fetch network policy,
the hunter-display-path having no toon/rig support) are `status: done`, so
this was the natural next move, not a new investigation.

## Budget

6 of 8 daily Meshy tasks were already spent before this run (3 Frog
previews, 1 Frog refine, 1 arena preview, 1 arena refine — see
`meshy-ledger.md`). That left exactly 2: one preview, one refine, no room
for multiple candidates the way `frog_ai.md` pass 1 tried three. Wrote one
careful prompt instead of iterating.

## Build

**Preview** (task `01a0cfac-b8c4-71fc-88f5-e4aeb7165bcc`): "A small stylized
fantasy goblin engineer character, green goblin skin, standing upright on
two legs, wearing a large oversized mechanical robotic arm on one side with
a claw hand, the other arm small and ordinary, a compressor tank backpack
with an exhaust pipe on its back, wearing goggles on its forehead, small
tusks, hand-painted toon game character, clean readable silhouette, T-pose
or neutral standing pose, symmetric front-facing stance" — pulled the
"oversized mechanical arm, ordinary arm, tank, goggles, tusks" description
straight from `goblin_mech.py`'s own docstring. `SUCCEEDED 100` first try.

What came back (thumbnail in `/tmp`, not committed — see the in-repo render
below instead) is a **different read of the same brief**: rather than one
giant separate mechanical arm, Meshy gave the goblin a mechanical
tank-and-hose rig worn as a backpack, both arms ordinary-sized, one hand
raised in a clawed gesture. Not what was asked for literally, but still
unmistakably "goblin with visible machinery," which is the character's own
job — and Nick's 2026-09-23 brief explicitly allows a style change, not just
a literal rebuild ("You may change the style of the existing characters...
if the Frog and Goblin read better rebuilt in a different style, rebuild
them"). Accepted rather than spending the one remaining task on a reroll.

**Refine** (task `01a0cfae-5a1b-7309-8e83-e7be3e597de9`), texture prompt
built from the palette this hunter's own file already establishes, sampled
from the shared atlas (`tools/blender/colormap.png`), not guessed: "bright
mint green goblin skin (#55BF6D) with darker forest green markings
(#2C9858) on the ears and tail, cream-white tusks, gold goggles (#FFC044)
with pale ice-blue lenses (#D0E8FF), the mechanical backpack rig and arm
painted dark slate metal (#494B59) with lighter steel-grey panel highlights
(#5D6171), the exhaust pipe and tank fittings warm burnt orange (#EE914E
and #E38645), UMBER brown leather straps and boots (#90553C), hand-painted
stylized toon game art, matte non-metallic paint finish, clean flat
shading". `SUCCEEDED 100` first try. **8 of 8 daily Meshy tasks now spent —
none left today.**

## Cleanup

New script `tools/blender/ai/goblin_ai_clean.py` (the same weld/centre/
scale/decimate recipe `frog_ai_clean.py` proved, adapted for this hunter):
welded doubles (0.004), centred X/Y with feet at z=0, scaled to the current
`goblin_mech.glb`'s own measured height (1.85 — read off its real mesh
bounds via a Blender bounds probe, not guessed; a "Cube" placeholder object
also present in that file was excluded from the measurement), decimated
27,422 → 5,199 tris (matches `frog_ai`'s own already-accepted overage, both
well over the 1,400 hunter budget). One mesh, one material confirmed after
decimation. Orientation checked by eye against the six-view `front`/`side`
renders below (face and chest toward -Y, the project's established front),
not assumed. Exported `game/assets/3d/cast/goblin_mech_ai.glb` +
`tools/blender/ai/goblin_mech_ai.blend`.

Six-view `look.sh goblin_mech_ai 1`, looked at all six locally:

![[../renders/goblin_mech_ai_pass1_front.png]]
![[../renders/goblin_mech_ai_pass1_34.png]]

Reads clearly as a goblin with visible machinery in isolation, under
`look.py`'s own neutral lighting — mint skin, gold goggles, dark slate
tank rig, brown straps and boots all legible, symmetric, no seams from the
weld/decimate step. `_sil.png` (64px silhouette) reads as one connected
humanoid-plus-backpack shape.

## Wired in, tested against the real fight, and found wanting — not shipped

Added `"goblin_mech": "_ai"` to `HUNTER_AI_ART` (`combat_3d.gd`) —
`_spawn_hunter` already resolves this table over `Cast.model_path()`, same
as `frog`. `ALL TESTS PASSED` (the fixer's own `wants_toon` unit tests
already cover a `HUNTER_AI_ART` hunter on its own flag).

**Real fight, same camera and state as always, before/after** —
`state=3d beast=cinder_jackal`, camera and both hunters' positions logged
identical between runs (6-decimal match). Before: the flat, bright-mint
primitive. After: toon-shaded and ink-outlined like the jackal and the
Frog — but at true in-fight size, **it reads as a near-solid black blob**,
worse than the primitive it would replace:

![[../agents/frames/artist/2026-09-23-goblin-mech-ai-infight-before-after.png]]

**Measured, not just eyeballed.** The exported texture's mean luminance is
80.1 against `frog_ai`'s own shipped texture at 156.5 — about half as
bright before any shading is even applied. Tried the obvious fix first: a
gamma lift on the baked texture alone (`tools/blender/ai/
goblin_ai_brighten.py`, γ=0.62, no new Meshy spend — a post-process on the
already-downloaded image, the same kind of luminance-headroom move
`goblin_mech.py`'s own pass 5 made by swapping CHARCOAL/GRAPHITE for STONE).
It measurably brightened the texture (mean 0.296→0.457 in Blender's 0–1
linear range) but barely changed the in-fight read — still close to solid
black at this size.

**Root cause, isolated and confirmed, not guessed.** `toon.gdshader`'s own
shadow colour is a cool blue-grey (`vec4(0.38, 0.40, 0.62, 1.0)`), not
black — "shadow that goes COOL instead of going black," by the shader's own
comment. The black is coming from the *second* pass,
`game/assets/3d/outline.gdshader`: an inverted-hull ink outline whose
`width` uniform (`0.0045`, in view-space units scaled by distance so a
beast keeps the same line weight near or far) is tuned for the Cinder
Jackal and the Frog — both single, thick, continuously-rounded masses. The
Goblin's own design is the opposite on purpose (`goblin_mech.py`'s
docstring: "Goblin round, rig square... the two halves of the silhouette
disagree with each other, which is the character") — lots of individually
thin parts (straps, the tank's fittings, boot seams, limb segments) each
carrying their own outline stroke. At hunter scale those strokes are wide
relative to each part's own screen thickness and start merging into each
other, eating most of the sprite. Confirmed by temporarily dropping `width`
to `0.0015` (a local test only — reverted immediately, `git diff` clean
before committing) and re-rendering the identical frame: the same asset,
same texture, same lighting, reads clearly:

![[../agents/frames/artist/2026-09-23-goblin-mech-ai-crop-outline-width-diagnosis.png]]

Left to right: the current primitive (reads fine — this is the bar), the
Meshy rebuild at the shared default outline width (fails it), the same
rebuild with a 3x thinner outline (passes it). The texture-brightness fix
is real but secondary; **outline width is the dominant variable.**

## Decision: not shipped this run

A hunter that renders worse than what it would replace is a regression, not
a win — the same call `frog_ai.md` pass 1 made about shipping a static,
un-toon-shaded model before the display path existed, now true here for a
different reason. **Reverted `HUNTER_AI_ART` back to `{"frog": "_ai"}`** —
`git diff` on `combat_3d.gd` and `outline.gdshader` both clean before this
was committed. The built asset (`goblin_mech_ai.glb`, `.blend`, both Blender
scripts) ships in this commit, same as `frog_ai` pass 1's spike did, ready
to wire in the moment the outline-width question is resolved.

**Not scored against the asset-loop rubric** — same reasoning `frog_ai.md`
pass 1 gave: scoring a model that isn't actually shown in the fight the way
players will see it would be comparing a partial, misleading number against
`goblin_mech.md`'s full 42/50.

`ALL TESTS PASSED`. Full 80-step playtest (`mode=play beast=cinder_jackal
steps=80`) re-run after reverting, to confirm the final committed state (no
gameplay files touched, `HUNTER_AI_ART` unchanged from what's already
shipped) regresses nothing — result appended below once it lands.

## What's still open, in order

1. **Filed to the fixer** (`requests/2026-09-23-1540-artist-to-fixer-hunter-scale-outline-swallows-thin-hunters.md`):
   the outline width needs to vary by model scale/part-thickness, or hunters
   need their own (thinner) outline pass, so a mechanically-detailed hunter
   doesn't read worse toon-shaded than it did as a flat primitive. This
   almost certainly generalizes past this one asset — any future rigged
   hunter with fine parts (straps, tools, plating) hits the same wall.
2. Once that lands: re-wire `HUNTER_AI_ART := {"frog": "_ai", "goblin_mech":
   "_ai"}`, re-verify in the real fight, and only then does this become a
   real asset-loop pass with a score.
3. The 193-island-style raw-mesh question `frog_ai.md` left open for its own
   asset is worth checking here too once this ships — not chased this run,
   since the asset isn't live yet.
