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

### Where it stands

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
