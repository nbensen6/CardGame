# cinder_jackal_ai — refinement log

The shipped Meshy rebuild (`game/assets/3d/cast/cinder_jackal_ai.glb`, source
`tools/blender/ai/cinder_jackal_ai.blend`), built 2026-09-22 via
`tools/blender/ai_beast.py` — see `design/guide/ai-beast-recipe.md`. This is
its **first** pass through the scoring loop (`design/guide/asset-loop.md`):
`frog_ai.md` and `goblin_mech_ai.md` have been scored and iterated on
repeatedly; this beast — the actual star of the fight — never had a rubric
score at all, only the two named fixes in `artist.md` (ear-glare glow,
foothold texture). Tier: **beast, stop at 44/50**.

Views: `design/renders/cinder_jackal_ai_pass1_*.png` (as shipped, contaminated)
and `pass2_*.png` (after this pass's fix).

## Pass 1 → Pass 2 — Build hygiene, artist, 2026-09-24T01:20 EDT

**Looked at the six-view render cold, before assuming the asset needed
anything specific**, per the loop's own "score it before reading the previous
pass's number" (there was no previous number to anchor on, but the same
discipline applies to a fresh look). Found a real, previously undiagnosed
defect immediately: a stack of untextured grey rock wedges is fused into the
model's own chest/foreleg region — visible in `_side.png`, `_form.png` and
the wireframe, and it distorts the front-leg silhouette in `_sil.png` too.
Not a rendering artifact — it is baked into the shipped mesh.

**Root cause, confirmed by reading the pipeline, not guessed.**
`design/guide/ai-beast-recipe.md` step 6 describes the ORIGINAL approach for
this exact beast: "grow the footing: a separate `Footholds` mesh of
flat-topped basalt outcrops... one per Height" — real rock geometry baked
onto the body along the climb route. That approach was replaced
2026-09-23 ("since 2026-09-23 the footing is NOT modelled: `combat_3d.
_build_float_stones` hangs a stone at every climb point... `ai_beast.py`
places the markers only") — `ai_beast.py`'s own foothold-building loop now
opens with `if True: continue # stones float in-engine now; no foothold
geometry is exported`. But the CURRENT `ai_beast.py` doesn't rebuild this
beast from a fresh Meshy download — the fixer's own last two rebuilds
(`design/agents/status/fixer.md`, 2026-09-23/24) explicitly "re-fed" the
already-shipped `cinder_jackal_ai.glb` back into the pipeline as its own raw
source, to avoid spending Meshy credits on a beast whose anatomy/rig are
already right. Every one of those re-feeds re-imports whatever geometry the
PREVIOUS export already contained — including the basalt chunk baked in
before the 2026-09-23 refactor, which the "if True: continue" guard was never
going to strip because it only stops NEW icosphere geometry from being
ADDED, not old geometry already present in the incoming mesh. The
contamination has been silently round-tripping forward through every rebuild
since, invisible because nobody had run a fresh six-view look at this
specific beast since it first shipped.

**Confirmed the geometry is a fully disjoint island before touching
anything** (`tools/blender/ai/cinder_jackal_ai.blend`, `Body` mesh): 320
faces carry a `Basalt` material distinct from the body's own `Material_0`;
those faces share **zero** vertices with the rest of the mesh (603 basalt
verts, 10369 other verts, 0 shared). Deleting them cannot open a hole in the
real body surface. Also found a second, smaller, unrelated piece of junk in
the same file: a stray untextured unit icosphere (42 verts, no material) sat
exactly at the model's local origin — a leftover default-primitive object
from manual editing, contributing nothing and rendering as a flat grey lump.

**Fix.** Opened `tools/blender/ai/cinder_jackal_ai.blend`, deleted the 320
Basalt-material faces from `Body` (0 loose verts left behind, confirming the
island really was fully disjoint), dropped the now-unused `Basalt` material
slot and datablock, deleted the stray `Icosphere` object outright, and
deleted the now-pointless empty `Footholds` mesh object (0 verts even before
this pass — `ai_beast.py`'s own dead branch still creates it every rebuild).
Re-exported with the exact same glTF export call `ai_beast.py`'s own step 6
uses (`use_selection=True`, `GLB`, animations via `ACTIONS`, skins, forced
sampling) over `game/assets/3d/cast/cinder_jackal_ai.glb`, and re-saved the
cleaned `.blend`. Climb/ledge marker empties, the rig, and every action were
untouched — they live as separate objects, never touched by this edit.

**Verified nothing else moved.** `total_verts`/`total_islands` before and
after: 12399 tris / (contaminated) → 12079 tris, 10370 verts, 440 raw mesh
islands after (`tools/blender/ai/mesh_gap_check.py`, the same tool
`goblin_mech_ai` pass 3 used) — **0 islands with a real 3D gap** at a
1%-of-body-diagonal threshold, so the topology is otherwise clean; 440 is
this beast's own UV-seam count, the same story `goblin_mech_ai` pass 7 found
for its own 489. The beast's own runtime bounding box (`_beast_box`, read
from `screenshot.gd`'s `CAM` line) shrank from `size.x=12.92` to
`size.x=10.78` — a real, understood change: the removed chunk's own X extent
(0.10–0.99 in local space, on the near/camera side) had been making the
model's AABB read as symmetric (±0.99) when the real body is asymmetric
(−0.99 / +0.66) in this running pose. Checked this doesn't break anything
the box feeds: rendered `state=3d`, `wide`, `3dclimb` and `3dgrip` after the
fix — hunters land in the right spots (`HUNTER0`/`HUNTER1 ... OK` on every
one), the arena still frames the beast the same way, nothing clips or reads
wrong. `ALL TESTS PASSED` (`run_tests.gd`) throughout — no GDScript touched,
only the asset.

![[../agents/frames/artist/2026-09-24-cinder-jackal-basalt-cleanup.png]]

Side and clay views, same camera, same pose: before, a visible stack of grey
wedges cuts across the front leg and belly; after, a clean canid line with
nothing foreign in the silhouette.

## Score — Pass 2, first rubric pass on this asset

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 2 | 8 | 8 | 7 | 9 | 8 | **40** |

- **Silhouette (8).** `_sil.png` (post-fix) reads clearly as a lean running
  canid at 64px — ears, snout, four legs and a tail all separate cleanly,
  nothing merges into an unreadable clump. The pre-fix silhouette had a
  visible defect right at the front leg/chest junction (the basalt chunk);
  that's gone now, and nothing else is currently named against this line.
- **Proportion (8).** Masses read as a jackal: lean torso, sharp head,
  slender legs — matches the "lean chase predator" the module doc and the
  recipe both describe. No specific mass reads wrong in the six-view set.
- **Build hygiene (7).** The one real, fixable defect this pass found — a
  320-face floating basalt island and a stray icosphere, both now gone,
  confirmed disjoint before deletion, confirmed no other real gaps exist
  (`mesh_gap_check.py`: 0/440 islands with a measurable gap). What's left is
  the same structural ceiling every Meshy-built asset in this cast carries:
  12079 tris against the old primitive-beast budget of 2600 (~4.6×over) — the
  same shape of overage `frog_ai`/`goblin_mech_ai` already carry against
  their own 1400 hunter budget, not something a same-pass fix reaches.
- **Colour & read (9).** Black body, orange-ember markings, amber eyes —
  clean separation confirmed in the actual in-fight camera (`state=3d`),
  not just the studio six-view render. The original Python primitive's own
  pass-1 note called this "the best colour read of the four beasts scored
  that pass"; the AI rebuild keeps the same strong palette discipline.
- **Style consistency (8).** Shares the same toon shader, ink outline and
  painted-texture pipeline as `frog_ai`/`goblin_mech_ai` — sits beside them
  as the same game, not a different one.

**40/50, 4 points under the beast stop line (44).** Build hygiene is the
clear lowest, but its concrete, fixable part is now closed — the remaining
gap there is the same tri-budget structural ceiling the hunters already
carry, not a same-pass fix. Nothing else has a named concrete defect from
this pass's look; the next useful move is either a dedicated silhouette/
proportion pass looking specifically for a smaller defect this first look
missed (this was pass 2's main find, not an exhaustive audit of those two
lines), or accepting the tri-count ceiling and moving to whichever of
Silhouette/Proportion/Style a fresh, more critical look turns up something
concrete on.

`silmetrics.py` was not run this pass — Blender's own bundled Python has no
`PIL` in this sandbox and the tool needs it; per `asset-loop.md` this is not
a gate ("these are not gates and they do not fail an asset"), so scoring
proceeded without it.

## Pass 3 — fresh critical look, artist, 2026-09-24T02:14 EDT

Pass 2's own "Where it stands" named two live options: a dedicated look for a
smaller Silhouette/Proportion defect pass 2's first look might have missed,
or accepting the tri-count ceiling and pushing on whichever of Silhouette/
Proportion/Style a fresh, more critical pass turns up something concrete on.
Did the first one for real, not just re-read pass 2's own numbers.

**Re-rendered all six views fresh** (`look.sh cinder_jackal_ai 3`) and read
every one cold before opening pass 2's write-up again, same discipline the
loop calls for. `_side.png`, `_front.png`, `_top.png` and `_form.png` (clay)
all confirm the basalt fix from pass 2 is holding — the front-leg/chest
silhouette is clean in every angle, no new foreign geometry, no seam or gap
visible anywhere the six views can catch. `_wire.png` shows an even,
unremarkable topology; nothing bunches or stretches oddly on the legs, ears
or tail. `_sil.png` at true 64px still reads as a lean running canid, all
four legs, the tail and both ears separating cleanly.

![[../agents/frames/artist/2026-09-24-cinder-jackal-fresh-critical-look.png]]

**Also checked the in-fight camera directly**, not just the studio render —
`state=3dgrip wide` (full body, hunters climbing) and `state=3dclimb`/
`state=3dstrike` (weak-point-height shots) all still frame the beast as the
clear subject, ember markings read the same clean black/orange split at
in-fight scale as the studio render, and the ear-glow at the sigil close-up
(`3dstrike`) stays legible — eyes, muzzle and ear structure still read
distinctly through the glow, the 2026-09-22 ear-glare fix is holding, not
regressing back toward the "two white blobs" it used to be.

**Found nothing new to fix.** No silhouette defect, no proportion mismatch,
no style break against the shared toon/outline/painted pipeline the whole
cast uses — a genuinely critical look, not a rubber stamp, and the honest
result is that pass 2's fix was the real defect this asset had. This matches
the same shape of result `goblin_mech_ai` pass 7 recorded on its own weld
attempt: a real, deliberate check that closes an open question in the
negative rather than manufacturing a change to justify the run.

**Score unchanged: 40/50** (Sil 8, Prop 8, Hygiene 7, Colour 9, Style 8).
Build hygiene's remaining gap is the same tri-budget structural ceiling
every Meshy-built asset in this cast carries (12079 tris here, 5199/5178 on
`frog_ai`, 5199 on `goblin_mech_ai`'s own pre-Meshy-remesh count) — all three
cast notes now independently name this as a real ceiling, not a same-pass
fix, and none has found a safe way to reduce it without risking the rig or
the UV layout on a shipped hero asset. Not attempting a decimation pass on
the beast blind this run — three separate passes across three assets in this
cast (`frog_ai`, `goblin_mech_ai` twice) have already concluded the same
thing, and a rigged hero asset is the wrong place to test a first attempt at
that risk.

`ALL TESTS PASSED` (`run_tests.gd`) — nothing shipped changed this pass, so
no playtest re-run; `git status` shows only the three tracked studio renders
(`_front`/`_sil`/`_34`, `_side`/`_top`/`_form`/`_wire` are gitignored scratch
per `.gitignore`) and this write-up.

### Where it stands

**40/50, unchanged since pass 2.** Lines: Silhouette 8, Proportion 8, Build
hygiene 7, Colour & read 9, Style consistency 8. Pass 2's real defect —
leftover foothold geometry from before the 2026-09-23 "stones float
in-engine" switch, silently propagating forward through every subsequent
rebuild that reused the shipped model as its own source — is closed and the
source `.blend` is clean going forward. Pass 3's fresh critical look
confirmed that fix is holding, in both the studio six-view render and the
real in-fight camera, and found nothing further on Silhouette/Proportion/
Style. The one remaining gap, Build hygiene's tri-budget overage, is now a
confirmed structural ceiling shared by all three Meshy-built cast members
(`frog_ai`, `goblin_mech_ai`, this beast) — closing it needs a deliberate,
separately-scoped decimation/re-unwrap pass with its own risk budget, not
another six-view look. Worth flagging for whoever next rebuilds this beast
from itself: the pass-2 contamination existed because nothing had looked at
this specific beast's own six-view render since it first shipped, not
because `ai_beast.py`'s current logic is wrong.

## Pass 4 — "alive when idle" and "reacts" verification, artist, 2026-09-24T03:21 EDT

`JACKAL-BAR.md`'s creature section had two unticked bullets nobody had ever
checked directly for this beast: "it is alive when idle... without drifting"
and "it reacts: attack, hit and death all read as different events." No
asset or code change this pass — pure verification, in the real engine, not
assumed from reading the shader/animation code.

**Alive when idle, without drifting.** `_beast_play`/the imported glb's own
`idle` clip loops every 4.0s. Rendered `state=3d` at `anim=idle@0.0/@2.0/@4.0`
and diffed: real motion every time (2.6k-4.8k changed pixels, all inside the
beast's own screen box) — not a frozen pose. The "without drifting" half of
the bullet needed more than one loop to actually test: diffed frame 0 against
10 loops later (`@40.0`) and 100 loops later (`@400.0`) and the changed-pixel
count stayed flat (2641 → 2602, same bounding box) rather than growing —
confirmed by numbers, not eyeballing, that the idle motion is bounded
(shader-driven ember pulse + normal loop, matching the jitter pattern earlier
passes already documented for the hunters) and never accumulates into a
net drift over time.

**Reacts: attack, hit and death all read as different events.** Attack and
hit were already known to differ (separate animation clips, `_strike()`'s
own camera-shake/flash/weak-point emphasis). "Death" had never been checked
at all — the glb itself carries no `death` animation clip, and
`combat_3d.gd` never branches on `boss.is_dead()`. Reading `location_3d.gd`
found the actual mechanism: on the REWARD phase the beast is torn down out
of the fight scene entirely and `_lay_out_the_felled()` (already
beast-specific-tuned: "a four-legged tower... roll it onto its flank
instead", written for exactly this beast) lays a second, static instance of
the same glb on its side in the reward scene. Rendered
`state=3dreward beast=cinder_jackal` — confirmed this fires for the jackal
and reads as a fallen animal, not an abstract shape: snout/ears cluster at
one end, four legs splayed, the same spine markings as the standing pose.
Cross-checked the ambiguous parts of that in-game render (a bright orange
mass that doesn't appear anywhere on the standing 3/4 render) with a
scratch three-angle probe (front/side/top, same rotation as the shipped
code, discarded after use, not committed) before calling it a defect: it is
the tail's own small ember tip, foreshortened almost end-on by this
particular fall angle, not a texture or geometry problem — confirmed by the
top-down angle, where the tail reads correctly as a slender curve.

**Verdict: both bullets hold, ticked below.** No fix needed — the systems
that make idle read as alive and death read as distinct from a hit already
existed and already worked; nobody had pointed a render at either question
before. Three-state composite (idle / hit-at-the-sigil / felled-in-reward),
same beast, same run:

![[frames/artist/2026-09-24-cinder-jackal-idle-hit-death-composite.png]]

Score unchanged — this pass verified two definition-of-done lines, not the
five-line rubric — 40/50 stands from pass 3.

## Pass 5 — "the weak point is obvious... as you climb toward it", artist, 2026-09-24T04:35 EDT

The last unchecked line in `JACKAL-BAR.md`'s creature section, nobody had
ever pointed a render at it either. Unlike pass 4's two verifications, this
one found a real defect.

**Where the weak point can even be on screen.** `screenshot.gd`'s own
`_report_visibility` already documents the design on purpose: the 3D sigil
mark is only expected to be visible once the hunter you're playing is
within 3.5 world units of it (`combat_3d.gd` line ~571) — below that, it is
correctly off-frame, "the scale doing its job, not a framing bug." Confirmed
this holds at `state=3d` (hunter 15.9 below) and `state=3dgrip` (9.4 below):
both correctly print `VIS n/a sigil ... out of frame by design`, not a fail.
So for most of a climb the *only* "stays obvious" signal is the persistent
2D ladder gauge (`_draw_gauge`, right edge of the HUD) — checked it too: it
marks the sigil's own Height with a distinct gold rail-cap and a
`✦ <N>` label at all times the weak point exists, separate from the tan
ledge rungs below it. That part already works and needed no fix (zoomed
render: `design/agents/frames/artist/2026-09-24-cinder-jackal-sigil-lift-before-after.png`
is about the 3D mark specifically, not this gauge).

**The real gap: once close enough that the 3D mark IS on screen
(`state=3dstrike`, hunter at the sigil), it was invisible in practice.**
`_place_sigil` puts the glowing mark at the same `_climb_points[wp]` anchor
`_build_float_stones` hangs the climbing shelf from (`_stand_on_model` →
`stone_point`, same key) — the shelf itself got a bright faceted-rock
texture on 2026-09-23 (`foothold_rock_detail.md`). Sampled the actual
rendered pixels at the sigil's own reported screen position
(`state=3dstrike`, `VIS OK sigil: (534, 320)`) directly, not by eye first:
every pixel in that neighbourhood was already at or past R=234-255 — the
shelf's own highlight, already brighter than the sigil's
`emission_energy_multiplier=3.0` gold had anything left to add. A small
emissive gold sphere sitting on top of an already-blown-out gold shelf
cannot read as a separate thing; the before frame (left half of the PNG
above) shows only the faintest lighter fleck on the shelf's own cream ring,
easy to mistake for a texture detail.

**Fix — a placement change, not a colour or size change.** The boulder body
under a shelf's flat standing cap is mostly *below* the stand point, not
above it (`cap_height*0.5 - rock.height*0.5` in `_build_float_stones`, a
negative offset) — a hunter's-height of open air sits above every shelf,
against the dark cave wall, not the bright rock. Lifted the sigil's own
position by `HUNTER_HEIGHT * 0.9` in `_place_sigil`'s climb-point branch so
it sits in that open, dark space instead of level with the shelf surface.
Deliberately did not touch colour or `_sigil_scale` — those are shared with
every future beast through the same function, and the placement alone was
enough to test cleanly on this one beast without widening the change.

**Verified with pixels, not just by eye.** Re-rendered `state=3dstrike` and
sampled the same neighbourhood: a small but genuinely separated bright spot
(242,242,229, blown toward white the way an overexposed point light blooms)
now sits against a dark cave-wall background reading 50-90 per channel — a
~5x brightness gap against its own surroundings, versus the old position
where the "sigil" pixels were statistically indistinguishable from the
shelf around them. Right half of the frame above shows it: a small clear
gold spark floating above the shelf, not a highlight on it.

**Honest limit, not fully solved.** Re-checked `state=3dclimb`, where the
CAMERA's own followed hunter stands exactly at the sigil (not just near
it, the way `3dstrike`'s establishing angle happens to separate them): from
that angle the lifted position lands right behind the hunter's own body,
and the "distinct gold spark" reads as part of the hunter's sprite rather
than a separate mark. Not a regression — the pre-fix position was
*equally* unreadable there (blended into the shelf either way) — but it
means the fix's real win is specifically the wider establishing shots where
hunter and mark are not co-located, not every camera angle. The party
panel and gauge already say "at the sigil" in text at that exact moment
(confirmed in both renders), so a viewer isn't left guessing even when the
3D mark itself is occluded by the hunter standing on it. Left
`JACKAL-BAR.md`'s line unticked rather than claim more than this run
actually proved — a real, verified improvement in the states where it
matters most (approaching, not yet standing on it), not a closed case.

`ALL TESTS PASSED` (`run_tests.gd`). 80-step playtest
(`mode=play beast=cinder_jackal steps=80`) run in the foreground after
pushing this change, per `COMMON.md` 4b; result recorded in `status/
artist.md` once it finished.

## Pass 6 — Build hygiene re-check + cast-wide Style consistency, artist, 2026-09-24T05:17 EDT

**Started by chasing what looked like a real regression, and it was a false
alarm — writing down why so nobody re-chases it blind.** Re-inspected the
shipped `cinder_jackal_ai.glb` to sanity-check pass 2's basalt/icosphere
cleanup was still holding (a routine re-verify, not triggered by any new
report). A plain `bpy.ops.import_scene.gltf()` re-import in Blender 4.1.1
consistently shows a SECOND mesh object, `Icosphere` (42 verts, 80 tris, no
material, sitting at local origin) — looking exactly like the "stray
untextured unit icosphere... leftover from manual editing" pass 2's own
write-up says it deleted. First read: pass 2's fix hadn't actually made it
into the shipped file.

**Checked the raw file before touching anything, and the alarm was wrong.**
Parsed the `.glb`'s own JSON chunk directly (no Blender in the loop) —
1 mesh (`Mesh_0`/"Body"), 1 material, 33 nodes, no Icosphere anywhere in the
data. Re-exported fresh straight from the current `tools/blender/ai/
cinder_jackal_ai.blend` (which also has no Icosphere object, confirmed by
listing `bpy.data.objects` on open) using `ai_beast.py`'s own step-6 export
call — the raw JSON of THAT export is equally clean. The Icosphere only
ever exists in Blender's own in-memory scene after a `gltf` REIMPORT; it is
not in the file, not in the source `.blend`, and — confirmed by rendering a
real `look.py` pass and reading the `_side`/`_sil` frames at 1:1 — it does
not show up in the render pipeline either (fully invisible, whatever it
is). `mesh_gap_check.py`'s own multi-mesh join step hits a silent "No mesh
data to join" warning in background mode when this happens, but that
failure mode happens to leave `meshes[0]` ("Body") as the analysed object
either way — so every earlier hygiene number for this beast (440 islands,
10370 verts, 0 real gaps) was already reading the real body, unaffected.

**Root cause not fully chased down** (some background-mode-only quirk in
Blender 4.1.1's glTF importer, reproducible on this specific file only —
`frog_ai.glb` and `goblin_mech_ai.glb` reimport clean, one mesh object
each) — not worth more time on since it provably never reaches the shipped
asset or the game. Flagging it here so a future pass that reimports this
beast in Blender and sees a phantom "Icosphere" object doesn't repeat this
investigation from zero: check the raw glTF JSON first, not just Blender's
reimported scene.

**No change made to any shipped file.** `git status` before writing this up
shows only this progress note, `JACKAL-BAR.md` (below) and the status note
as new — `cinder_jackal_ai.glb`, `.blend`, and every other asset are
byte-identical to before this run.

**Also used the clean bill of health to check something never checked as a
group: does the trio (jackal + both `_ai` hunters) actually read as one
game, side by side, at true in-fight scale — not just each asset's own
Style consistency line in isolation.** Rendered `state=3d` and `state=
3dgrip wide` (same camera/positions the fight itself uses) and cropped the
Frog and Goblin at native resolution, no scaling tricks:

![[frames/artist/2026-09-24-cast-trio-style-check.png]]

Holds. Same thick black ink outline on all three, same flat/cel-shaded
palette-atlas colouring, same "painted" light read (no separate specular
highlight, matching `portraits.py`'s own `painted=True` treatment for all
three models) — nothing about either hunter reads as being from a
different pipeline than the beast standing over them. This is the closest
this project has come to a literal side-by-side check of the "Frog and
Goblin match the jackal's fidelity" bar line; the remaining gap that keeps
it unticked is `goblin_mech_ai`'s own 41/50 (one point under the 42 hunter
stop line, Build hygiene's tri-budget overage — see `goblin_mech_ai.md`
pass 7), not a stylistic mismatch. No fix applied; nothing to fix here.

`ALL TESTS PASSED` (`run_tests.gd`). No playtest re-run — no game file
changed this pass (asset, script, or scene), only progress notes and one
new frame.

## Pass 7 — "the weak point is obvious", the `state=3dclimb` gap from pass 5, artist, 2026-09-24T06:18 EDT

Pass 5 left one honest gap: from `state=3dclimb` — the camera that follows
whoever is standing AT the sigil, not the wider establishing shots pass 5
fixed — the lifted mark (`HUNTER_HEIGHT * 0.9` above the climb point) landed
right at that hunter's own torso/head height and read as part of their
sprite. Its own write-up named the two remaining options: a colour change
(a taste call) or lifting it further. This pass tried the second, since it
costs no colour change and is not a taste call.

**Confirmed the occlusion first, precisely, before changing anything.**
Rendered `state=3dclimb` at the shipped `0.9x` lift and read the exact
pixel the game itself reports for the sigil (`VIS OK sigil: (425, 440)`,
14px from `VIS OK hunter0: (431, 450)`, the hunter standing on it). A tight
1:1 crop at that coordinate shows nothing but the Frog — no separate gold
fleck anywhere, confirming pass 5's own read rather than assuming it still
held.

**Why 0.9x lands there.** A hunter is `HUNTER_HEIGHT` (0.7) tall, feet at
the climb point. `0.9 * HUNTER_HEIGHT` = 0.63 world units up — inside the
hunter's own body height, not above their head. That is the whole
mechanism: the mark was never behind the hunter in depth, it was floating
at head height, directly in the same screen column the camera already
frames them in.

**Fix: raised the lift from `0.9x` to `1.7x` `HUNTER_HEIGHT` in
`_place_sigil`** (`game/views/combat_3d.gd`), clearing a standing hunter's
head at the same anchor. No colour, scale, or Z-offset change — the same
placement-only lever pass 5 used, just further along it. Confirmed this
does not run off the top of frame: `climb_frame_for`'s own headroom
handling already reserves space for a visible sigil up to
`active + 3.0` world units when `sigil_visible` is true, well past the
extra ~0.75 units this adds.

**Verified from the angle that mattered.** Re-rendered `state=3dclimb`: the
sigil moved from `(425, 440)` to `(424, 420)` — 20px up on screen — and a
1:1 crop now shows a small distinct gold spark sitting above the Frog's
head, clear of their sprite, against the cave-wall background:

![[frames/artist/2026-09-24-cinder-jackal-sigil-3dclimb-before-after.png]]

**Re-checked pass 5's own win, not just assumed it still held.** The bigger
lift moves the mark further from the climbing shelf's bright rock texture
too, so re-rendered `state=3dstrike` (the establishing shot pass 5 fixed)
to make sure raising the number further didn't overshoot into some new
problem (off-frame, inside geometry, etc.) — it did not; the mark still
reads as a clean separated spark against the dark cave wall, if anything
more clearly separated from the hunter now than before:

![[frames/artist/2026-09-24-cinder-jackal-sigil-3dstrike-recheck.png]]

**Checked the other two 3D states too.** `state=3d` and `state=3dgrip`
still correctly report the sigil `n/a` / out of frame by design (hunter
below the 3.5-unit visibility threshold in both) — unaffected, as expected
for a change scoped to the one branch that only fires once
`_climb_points.has(wp)`. `state=3dgrip`'s own `VIS FAIL hunter1: (230, 96)`
is pre-existing — confirmed by re-rendering the same state against the
pre-change code (`git stash`) and getting the identical failure — not
something this pass touched or should claim credit/blame for.

**Ticking the bar line.** All four camera angles that can show the sigil
now separate it from both the shelf (pass 5) and the hunter standing on it
(this pass); the 2D climb gauge already marked it clearly at every other
distance (pass 5). `JACKAL-BAR.md`'s "the weak point is obvious" line is
ticked.

`ALL TESTS PASSED` (`run_tests.gd`). 80-step playtest
(`mode=play beast=cinder_jackal steps=80`) run per `COMMON.md` 4b:
`PLAYTEST FAIL: 1 failing check(s) { "hop-distance-band": 62 }` — an exact
match for the already-filed, already-open `hop-distance-band` item
(`status/playtester.md`, the fixer's known-incomplete stone-route item 2),
which measures hop distance between climb points and has nothing to do
with a `Node3D`'s own `.position` in `_place_sigil`. Not a regression from
this pass.
