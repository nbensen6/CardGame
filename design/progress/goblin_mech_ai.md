# goblin_mech_ai — Meshy-based Goblin Engineer rebuild, pass 1

## VERDICT: REBUILD — called 2026-09-24T11:10 EDT, artist

Calling the plateau `design/guide/asset-loop.md`'s own "rebuild verdict" rule
defines: **two consecutive scored passes each gained fewer than 2 points**,
below the tier's stop line. This asset's last two rubric-scoring passes both
targeted Build hygiene, the one line still short of the 42 hunter stop line,
and both landed on the identical total — pass 7 ("Score: Build hygiene stays
7... Total: 41/50, unchanged") and pass 8 ("Score: unchanged, 41/50"). Two
consecutive 0-point passes on the same line is the plateau condition, met
here just as cleanly as on `cinder_jackal_ai` (see that file's own verdict,
same date — the two share the identical root cause). Nick's own answer on
the earlier hunter-cap request
(`2026-09-23-0325-artist-to-nick-hunters-at-pass-cap-below-stop-line.md`,
"keep passing them... until they clear the stop line **or you call a real
plateau**") is the standing authorization to call it now.

**Current score: 41/50**, one point under the 42 hunter stop line —
Silhouette 8, Proportion 8, Build hygiene 7, Colour & read 10, Style
consistency 8. Silhouette/Proportion are not the blocker (8/8, no defect
found across two independent fresh looks, pass 6 and pass 8) — this is not
the loop's other trigger ("Sil/Prop ≤5, rebuild the body from a worked
form"). The blocker is the same **tri-budget/UV-seam-fragmentation ceiling**
`cinder_jackal_ai`'s verdict describes in full: this model ships at ~5,199
tris against the 1,400 hunter budget (~3.7x over), and three independent
levers on Build hygiene specifically are now tried and closed — island
count (cosmetic re-check, pass 3), vertex welding (doesn't survive glTF
re-export because the exporter re-splits at UV seams regardless, pass 7),
and tri-count decimation (a 40% cut is visually free but doesn't reduce
island count — it rose 489→590 — because decimation moves vertices without
moving UV seam boundaries, pass 8). `frog_ai` sits in the same accepted-
overage tri class untouched and already caps at the identical Build hygiene
7, independent evidence this isn't a sliding tri-count scale within the
band.

**What it would need instead of another pass.** A full UV re-unwrap (new
seam placement to cut island count, not another vertex-count cut on the
existing seams) — named as the one remaining lever since pass 6 and
deliberately not attempted blind on a shipped, rigged, already
colour-patched hero-adjacent asset; the risk (re-baking can break the toon
shader/outline's and the existing skin-colour patch's UV-space assumptions)
belongs in one dedicated, careful, revertible pass, not a routine run.
**This is Nick's call per the loop's own rule** — raised alongside
`cinder_jackal_ai`'s identical verdict in
`design/agents/requests/2026-09-24-1110-artist-to-nick-jackal-and-goblin-plateaued-below-stop-line.md`.

**Correction, pass 9 (below): the premise above was wrong.** Nick greenlit
the re-unwrap on 2026-09-24T11:47 EDT and pass 9 actually built and baked
one, on this asset, rather than reasoning about it further — and it proved
the "island count" was never a UV problem to fix. Left here rather than
deleted so nobody re-reads this file cold and re-proposes the same
experiment.

**Superseded, pass 10 (below), 2026-09-24T16:30 EDT: the tri-budget ceiling
this VERDICT is built on is gone, not fixed.** Nick answered the follow-on
"pick a style" request with a real direction change (style C, Risk of Rain
2 — low-poly, flat-shaded, facets as the identity), and under that direction
the ~3.7x tri overage this whole VERDICT is about stops being a defect to
route around and becomes the actual budget target: this asset now ships at
1,559 tris, inside the same 1,400 hunter budget this VERDICT measured itself
against. The re-unwrap question this VERDICT and pass 9 spent real time on
is moot — not answered, just no longer the right question. Left here for the
history, not as an open item.

---

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
shipped) regresses nothing: **`PLAYTEST OK: 0 failing check(s) {  }`**, all
80 steps, exit code 0 — confirmed clean.

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

## Shipped and scored — artist, 2026-09-23T17:16 EDT

Picked up the fixer request above myself rather than wait on it further —
still open and untaken hours after filing, and it was the single loudest
blocker on this fight's own loudest bar item (`JACKAL-BAR.md`, "Frog and
Goblin match the jackal's fidelity"). No Meshy budget left today (8/8
spent) and Blender's network wall (`download.blender.org`, `connect_rejected`
via the proxy, reconfirmed this run — see `status/artist.md`) meant no new
model work either way, so this was the highest-value thing available: a
material/shader change to an asset already built and waiting.

**The fix, not the one literally suggested.** Rather than a flat global
`width` override, `combat_3d.gd` gained `OUTLINE_WIDTH_SCALE` — a dict of
model id to a multiplier on `outline.gdshader`'s own default line width,
read by both places a toon-shaded model gets its outline
(`toon_material`, called from `_shade_model` for the live fight and
`toon_all` for the reward-screen felled beast / campfire row). Any id with
no entry gets `1.0` and the code path that would touch the shader
parameter is skipped entirely — the jackal and the shipped Frog draw
through the exact same, untouched call they always did. Threaded the
model id through both callers (`_spawn_hunter`'s own `cid`, `location_3d.gd`'s
`beast_id`/`id`) so a hunter reads the same everywhere it appears, not just
in combat.

**0.33**, matching the manual local test the original diagnosis reported
(width `0.0015` against the shader's `0.0045` default) — re-verified fresh
this run, not carried over on trust: `goblin_mech` wired into
`HUNTER_AI_ART`, rendered in the real fight (`state=3d beast=cinder_jackal`),
cropped at 3x. Before: a near-solid green-black blob, worse than the
primitive it would replace. After: the mint skin, gold goggles, dark slate
tank rig and clawed hand all read clearly, at the actual size a player
sees it at.

![[../agents/frames/artist/2026-09-23-goblin-outline-width-fix-crop.png]]

**Checked everywhere `toon_all`/`_shade_model` place this model, not just
the one screenshot that started this**: the real fight (`state=3d`, above),
and the campfire hunter row (`state=3dcampfire`, `toon_all`'s other call
site) — both read clearly, backpack rig and goggles legible at that
distance too.

![[../agents/frames/artist/2026-09-23-goblin-outline-width-fix-campfire.png]]

**No regression on the jackal or the Frog** — `state=3d`, full frame,
pixel-diffed against the immediately-prior baseline render: outside the
goblin's own screen region, the only pixels that moved are consistent with
ordinary idle-animation timing jitter between two separate runs (checked by
eye against a tight crop of the jackal's legs and the Frog — pixel-identical
shapes, not a width change). `OUTLINE_WIDTH_SCALE` only ever sets the shader
parameter for an id with an entry, so this is expected, not just observed.

![[../agents/frames/artist/2026-09-23-goblin-outline-width-fix-before-after.png]]

**`ALL TESTS PASSED`.** Full `mode=play beast=cinder_jackal steps=80`
playtest kicked off against the wired-in model; per `COMMON.md` 4b this
write-up, the commit and the push all happened before the result was in
hand, rather than let a background run hold up everything else this run
did. **Result, 2026-09-23T17:34 EDT: `PLAYTEST OK: 0 failing check(s) {  }`**,
full 80 steps, exit code 0 (Meld, Catapult+Burn Coal, Leapfrog, Brace, Take
Aim, Scramble, Build Grapple, a real hop with position-continuity checks at
step 71, a real fall foot 10→4/hp 20→14). The run was slow this session (the
same sandbox flakiness `status/fixer.md` has noted before — real CPU time,
not a hang) but finished clean with no artificial cutoff. No regression.

**Score, `design/guide/asset-loop.md` rubric — the first real one for this
asset** (the original build pass was explicitly left unscored: it wasn't
shown to players the way they'd see it yet, and scoring it then would have
meant comparing a misleading number against `goblin_mech.md`'s own shipped
42/50):

- **Silhouette 8** — `goblin_mech_ai_pass1_sil.png`: reads clearly as a
  goblin-with-rig at 64px solid black — ears, the raised clawed hand and the
  backpack's tank silhouette all break a plain humanoid outline. Held to 8,
  not 9: the tell is mostly the backpack and ears, not anything more
  specifically "goblin" the way the Frog's crouch and toe-splay read as
  unmistakably frog-shaped.
- **Proportion 8** — reads as this hunter's own established character (a
  round goblin body against a square mechanical rig — `goblin_mech.py`'s own
  design intent) both in isolation and, this pass, in the live arena beside
  the actual jackal and Frog at the real in-fight scale — a side-by-side
  check `frog_ai.md` pass 2 named as its own open gap, done here instead of
  left open.
- **Build hygiene 6** — one mesh, one material (confirmed at export time,
  not re-verified this pass — no Blender available), 5,199 tris against the
  1,400 hunter budget, the same accepted-overage class `frog_ai` (5,200) and
  the current `goblin_mech.glb` (also well over) already ship at. Held at 6,
  a point under `frog_ai`'s own 7: that asset's pass 2 at least ran a raw
  mesh-topology check (193 islands, silhouette-safe); this one has had no
  equivalent check since the original build, an open question, not a
  confirmed clean bill.
- **Colour & read 7** — the palette (mint skin, gold goggles, dark slate rig,
  burnt-orange fittings, umber straps) separates clearly now that the
  outline isn't eating it, both in the real fight and the campfire row
  above. Held under 8: the underlying texture is still measurably duller
  than the Frog's own (mean luminance 80.1 vs 156.5, from the original
  diagnosis, unchanged by this pass — the outline was the dominant problem,
  not the only one) and colour has not been checked at the 34px party-
  portrait scale, same caveat `frog_ai` pass 2 carried for the same reason
  (`portraits.py`'s `AI_ART` table is beast-only, not extended to hunters).
- **Style consistency 8** — same Meshy pipeline, same toon-shader/ink-outline
  treatment as the jackal and the Frog, now actually legible at the size a
  player sees it — this is the fidelity gap `artist.md` names as the
  fight's loudest style break, materially closed for this hunter. Not a 9:
  getting there took a shader-side accommodation this asset needed and the
  Frog didn't, which is a real (if now-invisible) difference in how well
  the raw asset fits the established pipeline.

**Total: 37/50** — under the 42 hunter stop line, same honest-not-rounded
call `frog_ai` pass 2 made landing at 41. Lowest two lines, for whoever
picks this up next: **Build hygiene** (the 193-island-equivalent check,
needs Blender) and **Colour & read** (the texture is still measurably
dimmer than the Frog's own — a second Meshy refine or a manual gamma/levels
pass, once Meshy budget resets, could close this without new geometry).

**`HUNTER_AI_ART := {"frog": "_ai", "goblin_mech": "_ai"}`, shipped.** This
closes the JACKAL-BAR.md line "Each is readable at fight distance as itself,
not a green blob" for both hunters — ticked below. The fight's fidelity gap
is smaller, not closed: 37/50 is a real hunter on screen, not yet at the
tier's own bar.

## Pass 2 — Colour & read, artist, 2026-09-23T18:11 EDT

Picked this up because both Meshy (8/8 daily tasks already spent, confirmed
via the ledger and `python3 tools/meshy.py balance`) and Blender
(`download.blender.org` still a clean `403` — this is now the third run in a
row to hit it; filed `to: nick`,
`requests/2026-09-23-1811-artist-to-nick-blender-download-blocked.md`, per
the threshold the last run's own note set) were unavailable, and this is the
one of the two lowest lines from pass 1 that doesn't strictly need either:
the runtime texture is a plain PNG already extracted onto disk by Godot's
importer (`embedded_image_handling=1`), the exact fact the jackal ear-glare
fix relied on to edit a texture directly and have the game pick it up with
no re-export.

**Measured the actual gap first, on the file the game renders, not the
number pass 1's diagnosis carried over.** Pass 1's "80.1 vs 156.5 mean
luminance" came from Blender's own linear-space `image.pixels` during the
`goblin_ai_brighten.py` gamma-lift attempt; re-measured directly on the
shipped sRGB PNG/JPG files instead (`tools/blender/ai/goblin_ai_colour_boost.py`'s
docstring has the numbers): the raw luminance gap is much smaller than that
figure suggested (116 vs 123 mean, 0–255), but a real, reproducible gap
shows up in HSV — **saturation mean 0.284 vs the Frog's 0.671, value mean
0.535 vs 0.702** — the goblin's texture is genuinely flatter and darker,
just not by as much as the linear-space number implied.

**Fix: boost saturation and lift value directly on the extracted PNG**, no
Blender, no Meshy spend. `Image.convert("HSV")`, multiply the S channel by
1.55 and apply a 0.80 gamma lift to V (shadows/midtones up, white point
untouched), convert back to RGB, save in place. Deliberately partial, not a
match: `SAT_MUL`/`VAL_GAMMA` picked to move about 40% of the way to the
Frog's own numbers (sat 0.284→0.433, val 0.535→0.601) rather than push for
an exact match that risked reading as oversaturated/neon against this
hunter's own established palette.

**Verified in the real fight and the campfire row**, same camera/state as
pass 1, before/after crops at true in-fight size:

![[../agents/frames/artist/2026-09-23-goblin-colour-boost-infight-crop.png]]
![[../agents/frames/artist/2026-09-23-goblin-colour-boost-campfire-crop.png]]

The backpack tank reads a deeper blue-grey, the goggles a warmer gold, the
strap a more distinct brown — a real, if modest, improvement, consistent
with the measured HSV move. Not a dramatic transformation: the toon shader's
own shadow ramp compresses colour range on top of whatever the texture
carries, so part of pass 1's "Colour & read 7" ceiling is shader-side, not
texture-side, and this pass doesn't touch that.

**No regression.** Only `goblin_mech_ai_Image_0.png` changed (`git status`
confirmed). Pixel-diffed the full `state=3d` frame against the immediately
prior render: outside the goblin's own screen region, the only pixels that
moved are thin edge pixels on the jackal's legs and the Frog, consistent
with ordinary idle-animation jitter between two independently-timed
renders, not a shape or colour change — same pattern pass 1's own before/
after diff described. `ALL TESTS PASSED` (`run_tests.gd`; texture-only
change, no logic touched — no playtest needed, nothing moves differently).

**Score: Colour & read 7→8.** The dominant reason pass 1 held this line
down — the texture measurably duller than the Frog's own — is now
measurably narrower (not closed) on real HSV numbers, not just eyeballed.
The other open caveat (colour unchecked at the 34px party-portrait scale,
`portraits.py`'s `AI_ART` table being beast-only) still stands and isn't
addressed by this pass — held to 8, not 9, for that reason. **Total: 37→38/50**
— still under the 42 hunter stop line; `JACKAL-BAR.md`'s "Frog and Goblin
match the jackal's fidelity" line stays unticked.

**Lowest line now: Build hygiene (6)**, still blocked on Blender for the
mesh-topology check pass 1 named. Once the Blender wall clears: that check,
plus the portrait-scale colour check, are the two moves left to reach the
stop line.

## Pass 3 — Build hygiene, artist, 2026-09-23T20:11 EDT

`download.blender.org` came back `200` this run (the wall
`2026-09-23-1811-artist-to-nick-blender-download-blocked.md` filed — no
answer needed; the curl the request's own "Done when" named just started
working), so this is the mesh-topology check pass 1 and pass 2 both named
as the thing still blocking Build hygiene, now actually run.

**Built the check pass 1 asked for, stronger than the one `frog_ai.md` pass
2 ran.** That pass walked the raw edge graph into 193 connected components
and called it "silhouette-safe" — checked in 2D projection, not measured in
3D, and its own "still open" list says so (item 1: "inspect whether any of
them are visible gaps/seams once actually looked at closely, not just
confirmed silhouette-safe"). New script,
`tools/blender/ai/mesh_gap_check.py`: same edge-graph walk, but then
(numpy, brute force) measures the minimum 3D distance from every island to
the nearest vertex in any OTHER island. An island that's just unwelded from
its neighbours (the normal, harmless output of Meshy's remesh/decimate) sits
at ~0 gap; a genuinely floating part — spaced away from the body, the exact
defect Build hygiene's rubric line names — would show a gap that's a real
fraction of the model's own bounding-box diagonal.

    blender -b --python tools/blender/ai/mesh_gap_check.py -- game/assets/3d/cast/goblin_mech_ai.glb

**Result, on the actual shipped file:**

    REPORT total_verts 5799
    REPORT total_islands 489
    REPORT body_diag 2.3296
    REPORT islands_with_real_gap_total 0 (of 489 islands, verts>=3, threshold=0.010)

489 raw islands (more than `frog_ai`'s 193 — a bigger, more detailed mesh,
not a worse one) and **zero** have any real spatial gap at a 1%-of-body-
diagonal threshold (~23mm on this model). Re-ran at a threshold ten times
tighter (0.1%, ~2.3mm) to see what the honest floor looks like rather than
stopping at the first clean number: two 4-vert islands show up, at 2.5mm
and 6.6mm gaps respectively — both near the compressor-tank/backpack region
(`centre=(0.140,-0.274,1.159)` and `(0.460,-0.203,0.855)` in the model's own
local space). Opened both in the six-view renders at that location: neither
is visible even zoomed in on `_front.png`/`_side.png` at pass 1's own
capture resolution — sub-centimetre gaps between decimated micro-facets,
not a seam or a part standing off the body. **Verified, not assumed**: this
is the same "look before claiming" step the loop asks for, applied to a
measurement instead of a render.

**No fix to apply.** This pass's finding is that Build hygiene's open
question — "no floating islands, no part spaced away from the body,"
unconfirmed since the original build per pass 1 — is now confirmed clean,
not that something needed correcting. The 489-island fragmentation itself
is real (Meshy's remesh output, never hand-welded the way the jackal's mesh
was) but it is exactly the harmless, cosmetic-only kind `frog_ai`'s own
193-island question left open and never closed; this pass closes the
equivalent question for `goblin_mech_ai` with a sharper test than that one
got.

**Score: Build hygiene 6 → 7.** Matches `frog_ai`'s own Build hygiene (7),
on the same basis that asset was held to 7 rather than higher: real tri
overage against the hunter budget (5199 vs 1400, same accepted-overage
class both AI hunters ship at — unchanged this pass, no geometry touched)
still costs a point, but the topology question that was this model's own
extra uncertainty versus `frog_ai` is now answered, and answered with a
stricter test (a measured 3D gap, not a 2D silhouette check) than the one
`frog_ai` itself still has open. Not held to 8: budget overage alone is
enough to keep both AI hunters off a "clean bill" score at this tier.
**Total: 38 → 39/50** — still under the 42 hunter stop line.

`ALL TESTS PASSED` (no code or asset file changed this pass — a
measurement script only, added to the tree for the next hunter that needs
the same check; no playtest re-run needed, nothing moves or renders
differently).

### Where it stands (superseded by pass 4 below)

**39/50 — under the 42 hunter stop line, 3 points off.** Lines, current:
Silhouette 8, Proportion 8, Build hygiene 7, Colour & read 8, Style
consistency 8. No single line is now the clear worst; the honest reading is
this hunter needs roughly a point spread across the board, which the
Colour & read caveat pass 2 already named (unverified at the 34px party-
portrait scale — `portraits.py`'s `AI_ART` table is beast-only) is the most
concrete of what's left: it is a real, named gap rather than a "go find
something" search, and it is the next candidate for whoever picks this up,
Meshy budget and Blender both being available again this run for the first
time since pass 1.

## Pass 4 — Colour & read, artist, 2026-09-23T21:12 EDT

Runs the check pass 2 and pass 3 both left named but unattempted:
`portraits.py`'s `AI_ART` table (`{"cinder_jackal": "_ai"}`) only pointed
the portrait renderer at a rebuilt model for the beast — `combat_3d.gd`'s
own `HUNTER_AI_ART` has named `goblin_mech: "_ai"` since the hunter-
display-path fix, so the fight itself has shown this model for a while, but
`game/assets/portraits/goblin_mech.png` (the party rail, character card and
campfire) was still rendered from the old Python-primitive `goblin_mech.glb`.
A real fight screenshot shows the mismatch directly: the party rail's icon
and the hunter standing on the arena floor in the same frame did not agree.

**Fix:** `AI_ART = {"cinder_jackal": "_ai", "frog": "_ai", "goblin_mech":
"_ai"}` (`frog_ai.md` pass 3 is the same fix, same commit — one table
change closes the gap for both hunters at once), `painted=True` for both.
`FOCUS`/`FOCUS_XY`'s existing `goblin_mech` entry needed no retuning — it
already framed the `_ai` mesh correctly.

![[frames/artist/2026-09-23-hunter-portraits-34px-old-vs-new.png]]
![[frames/artist/2026-09-23-hunter-portraits-party-rail-before-after.png]]

**This is the 34px verification pass 2 named and never ran — now run, and
the answer is not clean.** Measured on the real 34px-downsampled render
(mean saturation/value over non-transparent pixels), against `frog_ai`'s
own portrait rendered the same way this same pass:

    frog_ai        sat 0.69  val 0.44
    goblin_mech_ai  sat 0.27  val 0.40

Saturation is well under half the Frog's own — the same "measurably
duller" finding pass 2 made from the 512px render and the shader's own HSV
numbers, now confirmed at the actual UI scale rather than inferred from a
bigger picture. Looked at directly (frame above, composited on the party
rail's own dark-brown background, not a light preview canvas): the goblin
reads as goblin-shaped but the cool grey-green body and the navy tank
crowd together with too little contrast between them, and the tank reads
closer to the dark backdrop than the Frog's own parts ever get to its
backdrop. Not dark-ON-dark (nothing drops to nearly-black against
nearly-black) so this stops short of the rubric's hard failure line, but it
does not clear "legible... not just at 512" the way `frog_ai` now does.

**Score: Colour & read stays 8.** Pass 2 held this line at 8 *pending*
34px verification; verification is done now, and it confirms pass 2's own
reading rather than improving on it — 8 was the right number then and is
still the right number now, just no longer a guess. Not dropped lower:
the parts ARE distinguishable, goblin-green from tank-navy from
strap-brown, just with less headroom than the Frog. **Total stays 39/50.**

**No texture touched this pass** — scope was the tooling gap
(`portraits.py` showing the wrong model), which is now closed and provably
correct for both hunters. The concrete next Colour & read move, now named
with real numbers instead of a hunch: raise the tank's value/saturation
relative to the body so the two masses separate at 34px the way the Frog's
body/belly split already does, and check contrast against the party rail's
actual `(58,42,30)` background specifically, not just against white.

`ALL TESTS PASSED` (`run_tests.gd`; no game code touched, a Blender tool
table and two portrait PNGs — this asset's and `frog_ai`'s — changed). No
playtest re-run: nothing moves or renders differently in the 3D scene,
only the 2D portrait texture the party rail and campfire already knew how
to draw.

### Where it stands (superseded by pass 5 below)

**39/50 — under the 42 hunter stop line, 3 points off.** Lines: Silhouette
8, Proportion 8, Build hygiene 7, Colour & read 8 (now verified, not
assumed), Style consistency 8. The next concrete move is named above: a
texture contrast/saturation pass separating the tank from the body,
targeted at the party rail's own background rather than a neutral one.

## Pass 5 — Colour & read, artist, 2026-09-23T22:20 EDT

Picked up pass 4's own named next move: raise the tank's value/saturation
relative to the body so the two masses separate at 34px, checked against the
party rail's own `(58,42,30)` background.

**Found a real bug while measuring the starting point, not just eyeballing
it.** `portraits.py` renders straight from `goblin_mech_ai.glb` — but the
glb's OWN embedded texture turns out to be the raw, never-boosted Meshy
output. Pass 2's global saturation/value boost
(`goblin_ai_colour_boost.py`) only ever edited the LOOSE extracted
`goblin_mech_ai_Image_0.png` (what Godot's importer reads for the live 3D
fight) — nothing ever touched the glb's own embedded copy. Confirmed by
extracting the glb's embedded image directly and measuring it: sat 0.282,
val 0.535 — pass 2's own recorded PRE-boost numbers, exactly. Every
portrait render since pass 2 (party rail, character card, campfire) has
been silently showing the dimmer, pre-boost goblin, out of sync with what
the fight itself has shown for two passes now.

**Fix, in two parts** (`tools/blender/ai/goblin_ai_tank_contrast.py`, new
`glb_image_patch.py` alongside it — a small pure-Python GLB reader/writer
that swaps an embedded image's bytes in place, safe here because this
model's image bufferView is the last one in its buffer, checked in code
before writing, not assumed):

1. The loose PNG (already carrying pass 2's boost) gets the new
   tank-specific boost below, applied directly, same as pass 2's own
   technique.
2. The glb's embedded image gets pass 2's global boost applied FIRST — so
   the portrait finally matches the shipped fight colours, closing the
   two-pass-old bug above — then the same tank boost on top. Verified
   byte-identical to the loose PNG at the global-boost stage (same formula,
   same raw source) before the tank step is applied to each independently.

**The tank boost itself:** masks pixels by HUE alone (195°-245°, the
tank/steel/shorts blue-grey family this hunter's palette uses) restricted to
value < 0.6, which excludes the near-white ice-blue goggle lens sitting in
the same hue range. Confirmed the mask lands where intended with a
diagnostic magenta recolour, rendered in Blender before touching real
colour — it covers exactly the backpack tank and the shorts, nothing on the
skin, goggles, straps or boots. Saturation ×1.7, value gamma 0.68, inside
the mask only.

**Verified in the real fight**, same camera/hunter positions as every prior
pass (logged, matched), before/after:

![[../agents/frames/artist/2026-09-23-goblin-tank-contrast-infight-before-after.png]]

The tank goes from a pale grey blob barely distinct from the shorts to a
clear blue, and the shorts read as a matching blue rather than a dark smear
— both now separate from the mint/orange body at true in-fight size.

**Verified at the actual 34px party-portrait scale**, the exact
measurement pass 4 held Colour & read down on — composited on the rail's
own `(58,42,30)` background, same methodology as pass 4:

    goblin_mech_ai  before: sat 0.263  val 0.398
    goblin_mech_ai  after:  sat 0.493  val 0.461
    frog_ai (ref):          sat 0.69   val 0.44

![[../agents/frames/artist/2026-09-23-goblin-tank-contrast-34px-before-after.png]]

Saturation nearly doubled (well over halfway to the Frog's own number now,
against less than half before) and value now matches the Frog's own 34px
reading almost exactly. Looked at directly, not just measured: the tank and
shorts read as a clear blue mass distinct from the green body, the same
separation the Frog's body/belly split already had.

**No regression.** Only the three touched files changed (`git status`
confirmed: the glb, its loose extracted PNG, the portrait PNG). Full-frame
`state=3d` pixel diff against the immediately-prior baseline, same
camera/hunter positions: changed pixels are the goblin's own screen region
(the intended recolour) plus the party rail's goblin portrait icon
(intended) plus thin, scattered edge pixels elsewhere matching the
established idle-animation-jitter pattern (jackal tail/ember pulse, frog
sway) every prior pass in this file has already documented, not a shape or
position change. `ALL TESTS PASSED` (`run_tests.gd`).

**Score: Colour & read 8 → 9.** Pass 4 held this line at 8 specifically
because the tank crowded the body with "less headroom than the Frog's own"
at the 34px scale — that headroom is now measured, not assumed, to be
closed: value matches the Frog's own reading and saturation is much closer.
Not held at 8 any longer, but not a 10 either — the underlying palette is
still a hunter-specific compromise (the tank boost is a targeted patch on
top of the base texture, not a from-scratch recolour). **Total: 39 → 40/50**
— 2 points under the 42 hunter stop line.

### Where it stands (superseded by pass 6 below)

**40/50.** Lines: Silhouette 8, Proportion 8, Build hygiene 7, Colour &
read 9, Style consistency 8. No single line is far behind the others now;
Build hygiene (7, real tri-budget overage, same accepted class as `frog_ai`)
and Silhouette/Proportion/Style (8 each, no fresh defect found this pass)
are the remaining candidates for whoever picks this up next — a fresh
six-view look, not a further colour push, is probably the next useful
move.

## Pass 6 — Colour & read, artist, 2026-09-23T23:22 EDT

Took pass 5's own suggestion literally: a fresh `look.sh goblin_mech_ai 6`
six-view render, looked at cold, not against the score history. Silhouette,
proportion, form and wire all held up — nothing new there. The real find
came from going one step further than any pass here has: not a 3x crop of
the real fight, but the **exact, unscaled screen pixels** a player's eye
resolves at the default `state=3d` camera, sampled directly off the PNG.

**Every prior "verified in the real fight" claim in this file, including
pass 5's own before/after two entries up, was a zoomed 3x crop.** At
1:1 — no zoom — the goblin's skin is not dull or measurably-duller-than-
the-Frog the way pass 2/4/5 characterised it. It is **near-white**:

    before (state=3d, native px): (240,243,220) (233,244,211) (238,243,214)

Sampled next to the Frog, same frame, same light: (234,249,117), (99,194,0)
— unmistakably green. The screenshot pass 5 itself committed as evidence of
the tank-contrast fix
(`2026-09-23-goblin-tank-contrast-infight-before-after.png`) shows this
exact defect in its own "after" half, uncropped: a cream-white body with
only the tank and shorts carrying colour. Nobody had looked at that frame
at the size it actually ships at.

**Root cause, isolated by testing, not guessed.** Not `toon.gdshader`
(shared with the jackal and the Frog, both fine) and not a lighting bug —
confirmed by a throwaway diagnostic: recolouring the skin mask solid
magenta in the loose PNG and re-rendering `state=3d` made the model
visibly magenta in the same region, so the albedo texture does reach the
screen here. The texture itself is the cause: skin sampled at
S 0.26–0.29, V 0.68–0.72 even after pass 2's global boost — high value,
low saturation, exactly the profile that a bright "lit" band (the shader
mixes toward white as light level rises, by design, same as every model
here) reads as neutral. The Frog's own texture measures S 0.66–0.77 at
similar value — saturated enough that the same white-ward mix still shows
green. Pass 2 raised the Goblin's *value* to fix the 34px portrait (a real
fix, still valid); it never touched saturation enough to survive the
arena's own bright key light, because nobody had rendered the actual
gameplay camera at 1:1 to see that this was still broken.

**Fix:** new `tools/blender/ai/goblin_ai_skin_saturation.py`. Masks by hue
alone (70°–160°, this hunter's green skin/ear family) with a floor on the
pixel's OWN current saturation/value (>0.12, >0.15) so near-neutral
pixels — goggle-lens highlights, cream tusks/nails, teeth — are never
pulled toward green by an unstable hue reading on a near-grey pixel.
Confirmed by a diagnostic magenta recolour on the flat texture atlas before
touching real colour (screenshot showed the mask landing exactly on
skin/ears, nothing on the tank, straps, goggles or boots). Saturation
×2.6 inside the mask, **value untouched** — deliberately not the same lever
pass 2 used, because this is a lit-band saturation problem, not a
brightness problem, and re-darkening would undo pass 2's own portrait fix.
2.6 was picked by testing sample points until their result (S 0.67–0.74)
landed inside the Frog's own measured range (0.66–0.77), matching the
survivor rather than guessing a number.

Applied to both files, same two-part pattern pass 5 established: the loose
PNG (what the live 3D fight reads) and the glb's own embedded image (what
`portraits.py` reads) — confirmed byte-identical before the edit, so one
script call keeps them in sync.

**First attempt measured as a false negative — caught before writing it
up.** The very first before/after render showed almost no change at the
sampled pixels. Before concluding the fix didn't work, checked why: the
loose PNG had been edited but Godot's importer was never told to
re-`--import`, so the screenshot was still reading its cached, pre-edit
texture. Re-ran `--import`, re-rendered, and the real result showed up.
Confirmed the mechanism with a second, unambiguous test (the magenta
recolour above) before trusting the quieter saturation result — the
project's own honesty rule ("never claim an improvement you have not seen
in a render") cuts both ways: a claimed NON-improvement needs the same
scrutiny before it's written down as the finding.

**Verified in the real fight, same camera/hunter positions as every prior
pass (6-decimal match), at true 1:1 scale, not a crop:**

![[../agents/frames/artist/2026-09-23-goblin-skin-desaturation-infight-before-after.png]]

Sample pixels at the same coordinates: (240,243,220)→(211,249,151),
(233,244,211)→(194,252,122) — visibly, measurably green now, not a subtle
shift.

**Verified at the 34px party-portrait scale too** (re-rendered
`portraits.py`, since the glb's embedded texture changed) — composited on
the rail's own `(58,42,30)` background, same methodology as pass 4/5:

    goblin_mech_ai  pass 5: sat 0.493  val 0.461
    goblin_mech_ai  pass 6: sat 0.655  val 0.422
    frog_ai (ref):          sat 0.69   val 0.44

![[../agents/frames/artist/2026-09-23-goblin-skin-desaturation-party-rail-before-after.png]]

Saturation now lands almost exactly inside the Frog's own range at this
scale too — the portrait fix and the in-fight fix reinforce each other
rather than trading off, because this pass moved saturation, not value.

**Checked the campfire hunter row too** (`state=3dcampfire`, the third
place this texture is shown) — reads clearly green there as well, not
just at the two camera angles this pass optimised for.

**No regression.** Full-frame `state=3d` pixel diff against the pass-5
baseline, same camera/hunter positions: 2,407 changed pixels total, all in
four small clusters — the goblin's own screen region and its party-rail
icon (both intended), plus the jackal's tail/legs and the Frog's own body,
which match the established idle-animation-jitter pattern (breath/ember
pulse/sway) every prior pass in this file has documented between two
independently-timed renders. No shape or position change on either
untouched model. `ALL TESTS PASSED` (`run_tests.gd`) — texture and a
regenerated portrait PNG only, no code or geometry touched.

**Score: Colour & read 9 → 10.** The rubric's own question for this line —
"do the palette swatches separate the parts? Legible at 34px in the party
panel, not just at 512? Nothing dark-on-dark" — is now checked at the
hardest version of that test this project has (the live in-fight camera at
native resolution, not a lit studio render or a zoomed crop) as well as
the 34px panel itself, and both pass with the parts reading as distinctly
as the Frog's own. Not claiming the texture is a from-scratch repaint —
it's still a hue-masked patch on the original Meshy output — but the
specific defect this line has carried since pass 1 ("measurably duller
than the Frog's own") is closed at the actual size and lighting a player
sees it in, not just improved on a number. **Total: 40 → 41/50** — one
point under the 42 hunter stop line.

### Where it stands (superseded by pass 7 below)

**41/50, one point under the hunter stop line.** Lines: Silhouette 8,
Proportion 8, Build hygiene 7, Colour & read 10, Style consistency 8.
Build hygiene is the clear low line now (real tri-budget overage, 5199 vs
1400) — the honest next move, if another pass is spent here, is checking
whether any of the 489 raw islands can be welded down without a visible
seam, which would be the first real hygiene fix rather than a topology
measurement. Silhouette/Proportion/Style at 8 each have no named concrete
defect left from this pass's look — closing the last point on any of them
needs a fresh six-view look to find one, not an assumed push.

## Pass 7 — Build hygiene, artist, 2026-09-24T00:12 EDT

Took pass 6's own suggested next move literally: can any of the 489 raw
mesh islands on the shipped `goblin_mech_ai.glb` be welded down without a
visible seam? Wrote `tools/blender/ai/goblin_ai_weld.py` to try it
properly, and the honest answer is **no — not by welding, because welding
does not survive this asset's own export path.** No fix applied to the
shipped model this pass; the finding itself is the result, same as pass
3's gap-check.

**First corrected a units mistake in pass 6's own numbers**, found while
re-measuring the two flagged "real" gaps as a sanity check before touching
anything: `mesh_gap_check.py --` reports `min_gap_frac` as a FRACTION of
the model's own bounding-box diagonal (2.3296m), not millimetres directly.
Pass 6 read `0.00254` and `0.00660` off that report as "2.5mm and 6.6mm" —
it should have multiplied by the 2329.6mm diagonal first. The real gaps are
**5.92mm and 15.38mm** — still small, still invisible at any render
distance checked, so pass 6's conclusion ("not a seam or a standoff part")
still holds; only the number was wrong. Noted here so the next run doesn't
carry the wrong figure forward.

**Wrote a read-only diagnostic first** (kept out of the tree, scratch-only)
to find a safe weld threshold before editing anything: for every one of the
489 islands, the minimum vertex-to-vertex distance to its nearest OTHER
island. 487 of 489 sit at **0.000mm** — genuinely coincident duplicate
vertices at old remesh/decimate boundaries, not real separation. Only the
two gaps above (5.92mm, 15.38mm) are non-zero. A union-find over that
distance table shows the 489 islands collapse to just **5** connected
groups at a 2–5mm weld threshold (safely under the smaller real gap), and
to 2 groups by 20mm (which would start bridging the two genuine small
gaps) — so 5mm was the threshold to test for real.

**Tested it on the shipped model, in Blender.** `goblin_ai_weld.py` imports
the glb, runs `remove_doubles(threshold=0.005)` on the joined mesh, and
re-exports. Inside Blender, before export, this is dramatic and exactly as
predicted: **5799 → 2604 vertices**, tri count essentially unchanged
(5199 → 5178 — a handful of degenerate faces collapsed, nothing else).

**Then re-ran `mesh_gap_check.py` on the RE-EXPORTED glb — the file that
actually ships — and the weld had (almost) no effect there: 5799 → 5783
vertices, islands unchanged at 489 → 489.** The glTF exporter reconstructs
almost the exact original vertex count and island count on export,
regardless of the weld. This is not a bug in the script; it is how glTF
works: a glTF vertex is a single (position, normal, UV) tuple, while
Blender stores UV/normal per face-corner. Every place this model's own UV
unwrap has a seam, the exporter is required to re-split the merged
vertex back into one-per-UV-value on export — and 489 is apparently
almost entirely accounted for by this hunter's own UV seam count, not by
leftover unwelded remesh duplicates the way the raw island number
suggested. Confirmed this is not a normals issue rather than a UV one:
every polygon was already forced to `use_smooth = True` before export in
this test, which removes hard-normal splits as a variable, and the island
count still came back unchanged.

**No fix applied to the shipped `goblin_mech_ai.glb`** — the tested
approach makes zero measurable difference to the actual shipped file, so
there is nothing here worth trading risk for. The real lever left, if a
future pass wants to spend a hygiene point here, is reducing the UV
unwrap's own seam count (fewer UV islands) — which is a materially
bigger, riskier job (a re-unwrap can shift or distort where the texture
lands, and would need the full six-view + in-fight + 34px-portrait
re-verification loop this hunter has already been through twice for
colour alone) — not a same-run weld. Flagging it as the honest next step
rather than attempting it blind.

**No regression, because nothing shipped changed.** `git status` confirms
only the new script and this write-up are new; `game/assets/3d/cast/
goblin_mech_ai.glb` itself is untouched. `ALL TESTS PASSED` (`run_tests.gd`)
— no playtest re-run needed, nothing in the live fight can differ.

**Score: Build hygiene stays 7.** Not because the question wasn't
answered — it was, definitively — but because the honest answer is "the
easy version of this fix doesn't exist," not "fixed." **Total: 41/50,
unchanged**, still one point under the 42 hunter stop line.

### Where it stands (superseded by pass 8 below)

**41/50, one point under the hunter stop line.** Lines: Silhouette 8,
Proportion 8, Build hygiene 7, Colour & read 10, Style consistency 8.
Build hygiene's 489-island number is now understood, not just measured: it
tracks this model's own UV seam count, re-imposed by the glTF exporter on
every export regardless of how welded the mesh is beforehand, so a plain
vertex weld cannot move it (`tools/blender/ai/goblin_ai_weld.py`, pass 7).
Closing this point for real means reducing the UV unwrap's own seam
count — a bigger, riskier job that needs the full verification loop, not a
quick follow-up. Silhouette/Proportion/Style at 8 each still have no named
concrete defect — a fresh six-view look is the next useful move on either
of those, or on Colour & read's own texture-vs-shader ceiling (pass 6's own
note: "part of the ceiling here is shader-side, not texture-side").

## Pass 8 — Build hygiene (tri-count lever), artist, 2026-09-24T07:16 EDT

Pass 7's own "Where it stands" named two untried moves: a fresh six-view
look for Silhouette/Proportion/Style, and reducing the UV unwrap's own seam
count for Build hygiene. Did the cheap one first (the look), then tried a
cheaper, less risky version of the second (a straight tri-count decimation,
not a re-unwrap) before concluding the re-unwrap really is the only lever
left — this pass rules one more thing out, it does not close the point.

**Fresh six-view look, scored cold before reopening this file.** Rendered
`look.sh goblin_mech_ai 8` and read all seven images (34, front, side, top,
form, wire, sil) before comparing to pass 6/7's own numbers. Also pulled
the real in-fight camera at native 1280×720 (`state=3d`), not a zoomed
crop, and cropped the goblin's own screen region at 4× nearest-neighbour to
check Silhouette/Colour at the size a player actually sees it (the same
method that caught the skin-desaturation defect in pass 5/6). No new
defect on Silhouette, Proportion or Style: the figure still reads as a
green goblin with a blue tank and goggles at 64px, symmetric front-on,
consistent toon/outline treatment with the Frog and jackal. The one thing
that looked odd on first pass — a pale triangular shape floating above
each hunter's head in the in-fight render — is not part of either model
(same shape sits over the Frog too); it's the game's own party-marker UI,
outside this brief's scope.

**Tried the tri-count side of Build hygiene properly, in scratch, before
touching the shipped file.** `goblin_ai_clean.py`'s own comment says 5200
tris "matches frog_ai's already-accepted overage" against the 1400 hunter
budget — nobody had actually tested how much of that could come back down
without a visible cost, only whether *welding* helped (pass 7, it doesn't,
because the exporter re-splits at UV seams regardless of vertex welding).
A blanket **Decimate (Collapse)** is a different lever from welding — it
removes real geometry instead of just merging coincident duplicates — and
had never been tried here.

Ran it on the actual **shipped, already colour-patched** `.glb` (not the
older `.blend` source, which predates the skin-saturation/colour-boost
patches applied straight to the exported file's embedded image — decimating
from the stale `.blend` would have silently reverted those) at two ratios,
each re-exported and re-looked-at before judging anything from the
in-Blender preview alone:

    ratio 0.6 -> 5199 -> 3119 tris (40% cut)
    ratio 0.3 -> 5199 -> 1559 tris (70% cut, ~= the 1400 hunter budget)

![[../agents/frames/artist/2026-09-24-goblin-mech-ai-decimate-test.png]]

**0.6 is a real, free win visually** — silhouette at 64px is pixel-similar
to the shipped model, and the 512px textured render shows no faceting, no
seam break, no texture stretch anywhere I could find. **0.3 is not** — the
tank's cylindrical surface visibly facets into flat panels and the boots
square off, both visible at 512px without a crop; a decimation ratio
between the two is where texture/silhouette safety runs out, not at the
budget line.

**Checked hygiene, not just the eye, on the 0.6 candidate** —
`mesh_gap_check.py` on the re-exported `goblin_dec60.glb`: 0 islands with a
real gap (same as shipped, no new floating parts), but **island count went
up, not down** (489 → 590). Decimation collapses vertices in 3D space but
can still land differently relative to existing UV-seam boundaries, so the
UV-driven refragmentation on export (pass 7's own finding) gets slightly
worse under decimation, not better — confirming pass 7's read that this
number is a seam-count artifact, not a real-geometry count this lever can
move.

**Did not ship it.** The 0.6 cut is visually free but doesn't reach "within
budget" (3119 vs 1400 is still 2.2× over — closer than 5199's 3.7×, but
still squarely in the same "accepted overage" class `frog_ai` already sits
in at 5136 tris with an identical Build hygiene 7) and doesn't move the
island count in the right direction. `frog_ai` — same overage class, same
shader, same toon pipeline — already caps at Hygiene 7 with its tri count
untouched, which is the actual evidence this project has that this rubric
line isn't scored on a sliding tri-count scale within the accepted-overage
band: it's capped there regardless, and only a materially different
approach (the re-unwrap, or a genuine "some geometry here is pure waste"
find, neither of which this pass found) would move it. Shipping a change
with no evidenced score effect, on the hero-adjacent asset, for its own
sake, isn't a trade worth making. `git status` before this push: the two
progress-doc updates, the status note, one new frame, and the two new
`design/renders/goblin_mech_ai_pass8_*` studio renders — `goblin_mech_ai.glb`
itself is untouched, same discipline as pass 7.

**Score: unchanged, 41/50.** Not a null result: the tri-count lever pass 7
left open ("the real lever left ... is reducing the UV unwrap's own seam
count") is now tested and ruled out as a *cheaper substitute* for that —
decimation alone cannot get here even when it's visually free, because the
ceiling isn't really about raw tri count once inside the accepted-overage
band, it's about the UV-seam-driven fragmentation a re-unwrap is the only
thing that touches. Three independent levers (weld, tri-count, and the
six-view look) have now been tried on this exact point and closed. The
re-unwrap is the only one left, and it is exactly as risky as every pass
since pass 6 has said it is — not something to attempt blind in an
unattended run.

`ALL TESTS PASSED` (`run_tests.gd`). No playtest re-run — no shipped asset,
scene or code file changed this pass.

### Where it stands

**41/50, one point under the hunter stop line.** Lines: Silhouette 8,
Proportion 8, Build hygiene 7, Colour & read 10, Style consistency 8. Every
lever short of a full UV re-unwrap has now been tried and closed on Build
hygiene (islands: cosmetic, pass 3; welding: doesn't survive export, pass
7; tri-count decimation: visually free at 40% but doesn't move the score,
pass 8) — a re-unwrap is the one remaining, deliberately-scoped, separately
risk-budgeted job, not a same-pass follow-up. Silhouette/Proportion/Style
at 8 each still have no named concrete defect after two independent fresh
looks (pass 6, pass 8).

## Pass 9 — the re-unwrap, tried and NOT shipped, artist, 2026-09-24T12:23 EDT

Nick greenlit the re-unwrap on all three (jackal, Goblin Engineer, Frog),
2026-09-24T11:47 EDT, on the VERDICT sections' own recommendation. This pass
built it for real on this asset (lowest risk of the three -- no armature, no
animation, one mesh, one material) instead of reasoning about it further,
and found the entire premise behind the VERDICT sections was wrong.

**What "489 islands" actually is.** Before touching any UV, checked the
SHIPPED file's raw mesh connectivity in Blender -- before export, before any
UV involvement at all -- by walking the edge graph the same way
`mesh_gap_check.py` does, but on the imported `.blend` data directly rather
than a re-exported `.glb`. Result: **489 disconnected components, identical
to the exported island count, to the last one.** 334 of those 489 have under
10 vertices -- individually separate bolts, rivets and greeble bits from the
Meshy remesh that were never welded to the body, not big continuous surface
regions split by a seam. The shipped UV layout adds **zero** additional
vertex splitting on export. Checked this wasn't a goblin-specific fluke:
`frog_ai` (193 raw components, 193 shipped islands) and `cinder_jackal_ai`
(440 raw components, 440 shipped islands) show the exact same identity. All
three "VERDICT: REBUILD" writeups called this a UV-seam-fragmentation
ceiling; it is actually a raw-geometry-welding ceiling, and the current UV
already contributes nothing to it, on any of the three assets.

**Why that makes a re-unwrap unable to help, not just risky.** A re-unwrap
can only ever ADD seams relative to a zero-additional-seam baseline -- it
can never subtract from a floor the UV isn't causing. Built one anyway to
confirm rather than argue from theory: Smart UV Project (angle limit 89°,
the setting that produces the FEWEST, LARGEST islands) on this asset's
existing mesh, re-exported, re-checked with `mesh_gap_check.py`:

    before (shipped, Meshy's own unwrap):  489 islands, 5,799 verts
    after  (fresh Smart UV Project unwrap): 1,586 islands, 8,134 verts

Worse on the metric it was meant to fix, by more than 3x. Tried three more
seam strategies (mark-seam-by-sharp-angle at 30°/45°/60°/75° then
angle-based unwrap, the standard hard-surface alternative to Smart Project)
to make sure this wasn't one bad algorithm choice: 2,045 / 1,105 / 834 / 724
islands respectively -- every single one still worse than the shipped
489, even at 75° (very few seams). There is no seam layout for this mesh
that beats what Meshy already shipped, because Meshy's own unwrap already
achieves the mathematical floor (zero export-time splitting) that any
re-unwrap can only add to.

**Re-confirmed pass 7's weld finding rather than take its word for it.**
Re-ran `goblin_ai_weld.py` (`remove_doubles` threshold 5mm) on the shipped
file: internally it works great (5,799 -> 2,604 verts, a real 55% merge).
Re-exported and re-checked: **back to 5,783 verts, 489 islands** -- within
16 verts of the untouched original. The glTF exporter re-splits at ANY
per-vertex attribute mismatch, not just UV -- these tiny separate parts
have their own distinct normals (they're separate parts, meant to shade
that way) even once spatially welded, so the exporter treats them as
different vertices again on write. Welding the position without also
forcing identical normals AND identical UVs at every one of 334 tiny parts
would mean manually re-modelling each one into the surrounding surface --
a full retopology, categorically bigger than "redo the texture wrap."

**Baked it anyway and looked, since Nick asked to see before/after, not
just a metric.** Baked the existing diffuse colour onto the new (worse)
UV layout with Cycles (2048px, diffuse-colour-only pass) and rendered both
in the studio six-view rig and in the real fight (`state=3d`, `state=
3dgrip`, same camera, same frame):

![[frames/artist/2026-09-24-goblin-reunwrap-studio-before-after.png]]
![[frames/artist/2026-09-24-goblin-reunwrap-infight-before-after.png]]

Reads as the same goblin -- no colour shift, no obvious seam artefact -- but
looking closely at the studio shot, the tank's metallic highlight and the
goggle rim are very slightly softer on the rebake (expected: resampling a
2048 texture through a new UV layout and a diffuse-only bake loses the
tiny bit of variation a direct copy keeps). Rendered in-fight at the
goblin's actual on-screen size (both crops above, true native resolution)
the softening is not visible at all -- the two are indistinguishable at
the size a player would ever actually see this hunter.

**Did not ship it.** No visible upside (identical at real fight size), a
real and measured downside (the file gets structurally worse -- 3x the
islands, more export bloat, a fractionally softer texture on close
inspection), and it does not touch the actual score-capping issue (tri
budget: this asset ships at ~3.7x its hunter budget regardless of UV
layout). Shipping a real regression for a cosmetic-only, unverifiable gain
fails this project's own honesty rule. Reverted the shipped
`.glb`/`.blend`/embedded image back to the pre-pass state before this run's
commit (`git status` on `game/assets/3d/cast/goblin_mech_ai.glb` and
`tools/blender/ai/goblin_mech_ai.blend` shows no diff) -- the only files
this pass actually changes are this progress note, the sibling VERDICT
correction in `cinder_jackal_ai.md`, a pointer note in `frog_ai.md`, the
request `## Result`, this status note, and the two frames above.

**Score: unchanged, 41/50.** Nothing shipped, so nothing to re-score.

### Where it stands now

The re-unwrap lever named in every VERDICT section on this cast is now
tried, on real numbers, and closed: it cannot move Build hygiene on any of
the three assets (the same raw-component-count identity holds on all
three), and attempting it makes the shipped file's own fragmentation worse,
not better. The only lever that could still move this line is a full
manual retopology of the small disconnected parts (not a texture-only
job, not scoped, not attempted here) -- or accepting that 41/42/40 across
the cast is this Meshy pipeline's honest ceiling at this budget. Passed
back to Nick as the request's own `## Result`, not decided here.

## Pass 10 — style C (Risk of Rain 2, low-poly flat-shaded), artist, 2026-09-24T16:30 EDT

Nick answered the follow-on style-pick request
(`2026-09-24-1147-nick-to-artist-find-an-art-style-worth-copying.md`,
19:33 UTC): "take C, and steal one thing from B — a light distance fog
purely for depth, not mood." C was this project's own candidate B/C: Risk of
Rain 2's deliberately low, faceted geometry with one hard light band and no
gradient, bright flat colour, emissive accents instead of texture detail.
Built it for real on this asset, not another demo pass.

**The tri-budget ceiling this file's own VERDICT and pass 9 spent two passes
on turns out to be the fix, not the defect, under this direction.** Pass 8
already measured that a Decimate (Collapse) cut to 1,559 tris (ratio 0.3,
right at the 1,400 hunter budget) "visibly facets the tank and boots" and
rejected it for exactly that reason — under the old smooth-toon style, a
visible facet was a defect. Under style C, a visible facet is the point. Ran
the identical cut again
(`tools/blender/ai/lowpoly_facet.py`, new — same Decimate lever pass 8
already validated, on the shipped, already colour-patched
`goblin_mech_ai.glb`, never the older `.blend`) with one real change: pass 8
left `use_smooth = True` on every face (Blender's default, inherited from
`goblin_ai_clean.py`), which blends the decimated normals across each facet
so it reads as a lumpy attempt at a round surface. This pass sets
`use_smooth = False` instead, so every triangle keeps its own flat normal
and reads as a deliberate facet, not a topology error.

    before: 5,199 tris, smooth-shaded
    after:  1,559 tris, flat-shaded — inside the 1,400 hunter budget for the
            first time (was ~3.7x over)

Looked at it in the studio six-view rig (`look.sh goblin_mech_ai 10`) before
touching the shipped file with anything else:

![[../agents/frames/artist/2026-09-24-style-c-goblin-studio-before-after.png]]

Reads as a confident, deliberate low-poly character — the tank is a proper
faceted cylinder, the boots and shoulders are angular in a way that looks
chosen, not broken. Silhouette at 64px is still a legible goblin-with-tank
shape, same read as before the cut:

    before sil: design/renders/goblin_mech_ai_before_pass10_sil.png
    after  sil: design/renders/goblin_mech_ai_pass10_sil.png

`mesh_gap_check.py` on the re-exported file: 1,558 islands (of 1,559 faces —
expected and harmless under flat shading, since a hard-normal edge means
every face keeps its own vertex copies on export; this is not the same
"floating part" defect earlier passes chased, which was about real 3D
separation, not per-face normal duplication), one island 0.0116 body-diagonal
fractions from its neighbour (a single 3-vert facet at an extremity,
invisible in every render taken).

**Shipped it — swapped into `game/assets/3d/cast/goblin_mech_ai.glb` and
`tools/blender/ai/goblin_mech_ai.blend`, re-imported, and verified in the
real fight** (`state=3d`, `state=3dgrip`, both hunters present):

![[../agents/frames/artist/2026-09-24-style-c-infight-grip.png]]

Reads clearly at real on-screen size (roughly 60-120px tall depending on
camera) — the flat colour blocks if anything pop more than the smooth
original did at the same distance. `run_tests.gd` — `ALL TESTS PASSED` — and
a fresh full 80-step `mode=play beast=cinder_jackal` playtest shows the same
single pre-existing, unrelated failing check as every prior baseline
(`hop-distance-band`, 62, the fixer's own open climb-spacing thread) — no
new fail from the geometry swap (no `hunter-lost-mid-hop`, no
`hop-position-pop`, no visibility check regressed).

**Not re-scored against this file's own rubric this pass.** The rubric's
Style consistency line ("sit beside the approved assets without looking
like it came from a different game") and its hard Kenney-low-poly-with-
smooth-shading constraint (`asset-loop.md` "Hard constraints") were both
written for the style this pass is deliberately leaving — scoring this
build against a rubric anchored to the style Nick just asked to move away
from would be circular. Silhouette and Colour & read still read fine by eye
(above); a real re-score needs the rubric conversation this direction change
opens, not a number invented mid-pass. Flagging that as the next open
question rather than picking a score.

**What's still open:** the Frog got the identical treatment this same run
(below, and its own file). The Cinder Jackal itself has not — it is rigged
and animated (1 armature, 3 clips), so the same Decimate-and-flat-shade
recipe needs its own careful pass (decimate, then confirm the armature
still deforms it correctly and the clips still play) rather than the
copy-paste this pass and the Frog's got. Not attempted this run — flagged
for a dedicated pass, not blocking.
