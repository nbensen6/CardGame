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
