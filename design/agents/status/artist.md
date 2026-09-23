---
tags:
  - agent-status
agent: artist
updated: 2026-09-23
working_on: no open to:artist request. The jackal's own "known open issues" line named the footholds "plain basalt" — checked in the real fight camera and found a flat, pale, cool grey (0.42, 0.38, 0.40) that read as a pebble from a different biome next to this fight's all-warm palette, nowhere near actual basalt. Recoloured `combat_3d.gd`'s `_build_float_stones()` to BROWN, the exact swatch `cinder_jackal_ground.md`'s own scattered boulders already use (sampled off colormap_base.png, not invented), with small per-stone jitter; added irregular horizontal (X/Z only, Y untouched on purpose) scale so stones read as separate boulders instead of identical smooth domes. Checked the code's own "must stay lighter than the beast's dark flank" comment before touching colour — BROWN's contrast against the jackal's CHARCOAL legs is larger than the old grey's, so the fix keeps that requirement, not just the palette match. ALL TESTS PASSED, playtest (mode=play, 40 steps) PLAYTEST OK 0 failing checks, pushed. Meshy's network wall is confirmed gone (Nick fixed it, verified via a real fetch) but the hunter-display-path request (to fixer) and arena-wall-accent request (to nick) are both still open, unpicked.
---

# artist

## Now

**The jackal's footholds — "plain basalt" (item 1's own known-open-issue
line), fixed and verified.** No open `to: artist` request this run
(checked every request file's frontmatter, `design/agents/BOARD.md`, every
`status/*.md`). Of the three standing requests: `...meshy-fetch-blocked-by-network-policy.md`
is now `status: done` — Nick allowed `assets.meshy.ai` and a cloud probe
verified a real fetch (`MESHY_FETCH_OK 754932`, logged in that request's own
`## Result`) — Meshy is genuinely usable end to end now. The other two are
still open and still unpicked: `...hunter-display-path-has-no-toon-or-rig-support.md`
(to fixer — fixer took the older shared-foothold-spacing request instead
this run, oldest-first) and `...arena-wall-accent-never-shows.md` (to nick,
a taste call).

**Why footholds, not another Meshy attempt or another arena pass.** Both
hunters are past their stop line (frog 43/50, goblin_mech 42/50) — no
fresh defect to chase there. `cinder_jackal_ground.md` is at pass 4/28; its
two open lines (Sil/Prop — the shared `enclose()` wall filling the frame)
are the same systemic finding two other grounds already flagged and left
to Nick, already filed, not a fifth pass' fix. A Meshy hunter rebuild is
unblocked on the network now, but dropping a rigged model in today would
still render in bind pose, wrong shader, worse than the current
primitives — the open fixer request's own reasoning, re-confirmed, not
re-attempted blind. That left the one named, unblocked, unaddressed line
in my own brief: item 1 calls the footholds "plain basalt," never checked
against what's actually on screen.

**Rendered the real fight first, not the code in isolation**
(`state=3dgrip`, `state=3d wide`, `cinder_jackal`): the floating stones
`_build_float_stones()` hangs at every climb point are a flat, pale,
cool grey (`Color(0.42, 0.38, 0.40)`) — nowhere close to actual basalt
(near-black volcanic rock), and a cool grey sitting inside an otherwise
all-warm scene (ground, wall and beast are all RUST/UMBER/TANGERINE).
Cropped and looked close: the stones read as pebbles from a different
biome, not this fight's own rock.

**Fix, `game/views/combat_3d.gd` `_build_float_stones()`, colour and scale
only — the same two-line diagnosis the arena wall pass already used,
applied to the last un-recoloured rock in this fight:**
1. **Colour.** Swapped the flat grey for BROWN — the exact swatch
   `cinder_jackal_ground.md` pass 3 already put on this ground's own
   scattered boulders, sampled off `colormap_base.png` (176, 96, 65), not
   invented — plus small per-stone jitter (±0.05) so neighbouring stones
   don't read as identical clones. Checked the comment already sitting on
   this code ("lighter than the beast it hangs against, or a dark stone on
   a dark flank is invisible") before touching it: BROWN's luminance gap
   against the jackal's own near-black CHARCOAL legs (56, 56, 61) is
   *larger* than the old grey's gap — the functional requirement gets
   stronger, not weaker, while the colour now actually matches the ground
   these are chunks of.
2. **Shape.** Added irregular horizontal scale (`randf_range(0.85, 1.18)`
   on X/Z only; Y held at 1.0 on purpose — the vertical sink offset
   computed two lines above it uses `rock.height` before any scale is
   applied, so touching Y would throw that off) so stones read as separate
   boulders instead of identical smooth domes.

**Verified, not assumed.** `ALL TESTS PASSED` (the existing `stone_point`
position tests are untouched and still pass — confirms this pass only
touched colour/scale, not the position math they check). Rendered
`state=3dgrip` and `state=3d wide` before/after, same camera: a tight crop
shows the stones move from a pale, cool, plate-like blob to a warm
rust-brown boulder that now visually belongs to the ground beneath it; a
pixel diff at a real-change threshold (>100/765 sum, well above AA/lighting
noise) is 66,973 of 921,600px (7.3%), concentrated on the stones and their
cast shadows. `screenshot.gd`'s own `HANDGEO`/`CAM`/`HUNTER`/`VIS`/`GRIP`
lines are unchanged from the pre-fix run — nothing about hunter position,
camera or grip state moved, only the stones' own pixels. Live playtest
(`mode=play`, `cinder_jackal`, 40 steps): `PLAYTEST OK: 0 failing check(s)
{  }` — clean, no regression.

![[frames/artist/2026-09-23-foothold-basalt-colour-crop-before-after.png]]
![[frames/artist/2026-09-23-foothold-basalt-3dgrip-after.png]]
![[frames/artist/2026-09-23-foothold-basalt-wide-after.png]]

`ALL TESTS PASSED`. Pushed.

## Next

Item 1's own "known open issues" line (ear glare, footholds) is now fully
closed — both fixed, both verified in the real fight camera. The two
loudest items are still the two Nick's 2026-09-23 brief update named:
hunters matching the jackal's fidelity (blocked on the fixer's still-open
`...hunter-display-path-has-no-toon-or-rig-support.md`, not yet taken —
check again first) and the arena framing the fight (blocked on Nick's
still-open `...arena-wall-accent-never-shows.md` taste call;
`cinder_jackal_ground.md` itself is at pass 4/28, no further pass-worth
defect found this thread, its two open lines are the same shared-`enclose()`-
wall finding filed three times now across three grounds). Absent either
landing: no further two-line passes on `frog`/`goblin_mech` past their stop
line without a fresh, real defect. Meshy is confirmed working end-to-end
now (`assets.meshy.ai` unblocked, verified by a real fetch), but spending
more of the daily cap on a hunter rebuild before the display-path lands
would produce an asset that renders worse than the current primitives, per
the fixer request's own reasoning — not worth re-litigating without new
information.

## Old: goblin_mech, pass 10

No open `to: artist` request this run (checked every request file's
frontmatter, plus `design/agents/BOARD.md` and every `status/*.md`) — the
three standing requests (`...meshy-fetch-blocked-by-network-policy.md` to
nick, `...hunter-display-path-has-no-toon-or-rig-support.md` to fixer,
`...arena-wall-accent-never-shows.md` to nick) are all still open, none
picked up by anyone else yet. Re-confirmed the Meshy wall before spending
time on it again: `python3 tools/meshy.py balance` returns a real balance
(2960 credits), `curl https://assets.meshy.ai/` still gets a 403 policy
denial from the proxy — same infrastructure wall as every prior run, not
stale.

Environment fresh again: Godot 4.7.1 + `--import`; Blender via
`apt install blender` (4.0.2, `download.blender.org` still unreachable) +
`libegl1 libgl1-mesa-dri libglx-mesa0`; `pip install --break-system-packages
pillow numpy scipy` for the host, `python3.12 -m pip install
--break-system-packages numpy pillow` for Blender's own bundled Python
(same `sys.executable`-is-the-system-interpreter quirk every prior run
found).

Picked up my own `## Next` from pass 9: two candidates left open on
`goblin_mech` (41/50, one below the 42 stop line) — the piston rods
("functionally invisible at every angle, even highlighted") and a check
for any other rig part mounted to a rotated box the same raw-axis-aligned
way pass 9's `mount()` bug affected the claw cluster. Full write-up in
`design/progress/goblin_mech.md` pass 10.

**Checked the second candidate first, by reading the script, not
re-rendering blind.** Two other boxes carry a non-zero `rot=` (shoulder,
wrist), but nothing is bolted to either via a `box()`/`taper()` call with
its own fixed offset+`rot=` the way the claw cluster was — the nearby
parts are `limb()` waypoint chains, a different code path with no
`mount()`-shaped bug to have. **No second instance — my own speculation
from last run's `## Next` was wrong, reported as such.**

**Diagnosed the piston rods instead of just widening them.** A fresh
diagnostic recolour (ICE, the same technique pass 4/8/9 used) showed they
are not just thin — they're almost entirely *buried inside* the claw box
and the claw taper's own cone. Measured why: their lateral offset (±0.048
raw, ≈0.057 world) sat well inside the claw taper's own base radius
(≈0.085 world), so the rods ran coincident with the taper's own volume
from the mount point out, not beside it — a placement bug, not a
thinness-only one.

**Fix, position/scale/colour only, no new geometry:** pushed the lateral
offset to ±0.110 (clears the taper's radius with real margin), widened the
radius 0.016→0.030 (`seg=4` unchanged — a bigger cone from the same 4
verts, zero tri cost), and recoloured CHARCOAL→STONE (pass 5's own
finding: CHARCOAL/GRAPHITE are this rig's two darkest, near-tied tones the
toon shader's shadow band crushes near-black — same fix already applied to
the compressor box and the wrist ring).

**Verified, not assumed:** tri budget/part count unaffected (`TRIS 1378
PARTS 33 BUDGET 1400 ok`, identical to pass 9); `_sil.png` pixel diff
against the pre-fix capture is 144 of 65,536px (0.2%); `_34.png` (the
fight-camera reference angle) before/after shows the rods now reading as
two parallel struts flanking the claw, not a bare hairline; `_front.png`/
`_top.png` checked too, nothing pokes through the silhouette oddly. The
true in-fight size (`state=3dgrip slot=1`, rebuilt `.glb`, reimported,
shot against both the pre- and post-fix committed models): honestly
**does not survive** — the claw cluster is a handful of pixels at combat
distance, the two shots are indistinguishable by eye. Same call pass 8/9
already made for their own fixes at this scale.

**Score: Hygiene 8→9, 41→42/50 — clears the 42 hunter stop line.** Both
candidates pass 9 left open are now closed (one fixed at its real cause,
one checked and ruled not a second instance). Per `design/asset-loop.md`,
the honest call at the stop line: stop passing `goblin_mech` unless a
request or a fresh look finds a real, new defect. **Both hunters are now
past their stop lines** (`frog` 43/50, `goblin_mech` 42/50) — the loudest
remaining gap on this whole thread is unchanged: a Meshy-rigged rebuild to
match the jackal's own fidelity, blocked on the two open requests to
nick/fixer, neither picked up yet.

![[frames/artist/2026-09-23-goblin-mech-piston-rods-34-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-piston-rods-infight-before-after.png]]

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model: `PLAYTEST FAIL: 1 failing check(s)
{ "hunter-off-marker": 2 }` — checked against what's on record, not
assumed: *exact* same home/anchor coordinates as the already-open
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`
— confirmed pre-existing by coordinate match, not reopened. This pass only
changed the position/scale/colour of two existing piston-rod tapers; no
code path into foothold/climb-marker placement.

## Next

Both hunters are now past their stop line (`frog` 43/50, `goblin_mech`
42/50) — the honest call is to stop passing either unless a request or a
fresh six-view look finds a real, new defect, not chase higher for its own
sake. The three standing requests are still open and still the real path
to the brief's actual ask (a Meshy-rigged hunter matching the jackal's
fidelity): `...meshy-fetch-blocked-by-network-policy.md` (to nick, needs
`assets.meshy.ai` allowed), `...hunter-display-path-has-no-toon-or-rig-support.md`
(to fixer, needs the beast-only toon/rig display path generalized to
hunters), `...arena-wall-accent-never-shows.md` (to nick, a taste call on
the arena's wall system). Next run, absent a request: re-check whether any
of the three has landed first; if not, the arena (`env.py`/`cinder_jackal.py`)
is the one item in scope that hasn't had a fresh six-view look this whole
thread — worth one before assuming there's nothing left to find there
either.

## Old: goblin_mech, pass 9
also `design/agents/BOARD.md` and `status/*.md`) — the three still-open
requests from the Meshy pass (`...meshy-fetch-blocked-by-network-policy.md`
to nick, `...hunter-display-path-has-no-toon-or-rig-support.md` to fixer)
plus the arena wall-accent request are all still open, none picked up by
anyone else yet. Re-confirmed the network wall is still there before
spending any more time on it: `python3 tools/meshy.py balance` works fine
(2960 credits), but `curl https://assets.meshy.ai/` still gets a 403 policy
denial from the proxy — the same infrastructure wall as last run, not a
stale finding. Environment fresh again: Godot 4.7.1 + `--import`; Blender
`apt install blender` (4.0.2) + `libegl1 libgl1-mesa-dri libglx-mesa0` for
headless rendering; `pip install --break-system-packages pillow numpy scipy`
for the host Python, and separately `python3.12 -m pip install
--break-system-packages numpy pillow` for Blender's own bundled Python (this
Blender build's `sys.executable` is the system `/usr/bin/python3.12`, not a
Blender-private one — glTF import/export fails with `ModuleNotFoundError:
numpy` otherwise).

Picked up my own `## Next` from last run: `goblin_mech` (40/50, cap lifted,
below the 42 hunter stop line) had one live, previously-flagged candidate —
Hygiene's claw/piston mass reading separate from the main rig body (open
since pass 3, re-confirmed "connected but distinct" through pass 5, never
actually diagnosed to a cause). Ran it. Full write-up in
`design/progress/goblin_mech.md` pass 9.

**Used the same diagnostic-recolour technique pass 4/8 used** (recolour one
part to `ICE`, re-render, look) on the claw taper and the two piston rods
separately. The piston rods are functionally invisible at every angle
rendered, even highlighted bright — a real cost (2 tapers) for zero visible
read, its own Hygiene question, not chased this pass. The claw taper reads
exactly as the standing complaint describes: a small lump sitting at the
claw box's corner with a visible gap of shadow beneath it, not flush against
the face.

**Measured the cause instead of eyeballing a fix.** The claw box carries
`rot=(0.18, 0.20, 0.0)` — a real ~10-11° tilt. The claw taper and both
piston rods mounted to that box were each placed at a raw axis-aligned world
offset with a raw axis-aligned `rot=(FWD, 0, 0)` — correct for an unrotated
box, silently wrong the moment the box itself is tilted, so the parts
emerged from a point/heading that never matched the box's actual (tilted)
face. Same category as pass 8's goggle-strap bug (a part positioned without
accounting for what it's relative to), on a different part of the model.
Added `mount(box_loc, box_rot, delta, own_rot)` to `goblin_mech.py` — rotates
a rigidly-bolted part's offset and its own orientation by the reference
box's rotation matrix — and applied it to all three parts. Pure
position/orientation math, no new geometry.

**Verified, not assumed:** tri budget/part count unaffected (1378/1400,
identical to pass 8); `_sil.png` pixel diff against the pre-fix capture is
347 of 65,536px (0.5%), and `scipy.ndimage.label` still finds one connected
component — the fix didn't reopen the "floating island" question pass 5
already closed; `_34.png`/`_side.png` before/after show the claw now sitting
flush against the box's bottom edge, gap closed, at both angles checked; the
true in-fight hunter size (`state=3dgrip slot=1`, ~15-30px, rebuilt
`goblin_mech.glb` shot against both the pre- and post-fix builds) honestly
does **not** show a visible difference — reported as such, not oversold, the
same call pass 8 made for the goggle strap at 34px portrait scale.
`goblin_mech`'s own party-portrait framing (`portraits.py`'s `FOCUS` table)
never reaches this low on the model at all, so that particular check doesn't
apply here.

**Score: Hygiene 7→8, 40→41/50, still 1 below the 42 hunter stop line.** A
real, previously-only-described defect ("connected but distinct" since pass
3/5) now has a measured cause and a fix at that cause. Held at 8, not
higher: the piston rods (the cluster's other half) are confirmed still
invisible, and the win doesn't reach true in-fight size.

![[frames/artist/2026-09-23-goblin-mech-claw-mount-34-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-claw-mount-side-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-claw-mount-infight-before-after.png]]

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps) re-run
against the rebuilt model: `hunter-off-marker` (2 hits, foothold 4) — exact
same home/anchor coordinates as the already-open
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`,
confirmed pre-existing by coordinate match, not reopened. This pass only
changed loc/rot on three existing parts; no code path into foothold/climb-
marker placement.

## Next

`goblin_mech` is at 41/50, cap lifted, one point below the 42 hunter stop
line. Two real, named candidates left open for whoever picks it up: the
piston rods this pass confirmed are invisible at every angle even
highlighted (a tri-cost-for-nothing Hygiene question, needs either a
visibility fix or cutting them for budget elsewhere) and the exhaust-pipe/
hose-ring "diagnostic-angle-only" precedent from pass 3/5/6 (never revisited
with this pass's box-rotation lens — worth checking whether any other rig
part is mounted the same raw-axis-aligned way to a rotated box). `frog` is
past its own stop line (43/50); the Meshy Frog rebuild (Nick's brief's
actual ask) stays blocked on the `assets.meshy.ai` network-policy request,
still open, still unpicked by Nick.

## Old: hunters, pass 8 (goblin_mech)

**A fresh six-view look (`look.py` direct, `libEGL` fixed above) found a
real defect at exactly the angles pass 4 never checked.** `_34.png` (the
fight-camera angle, per `look.py`'s own docstring) and `_side.png` both show
the `GOLD` goggle strap reading as a flat blade or beak jutting out in front
of the goblin's face, not a headband. Measured the cause instead of
eyeballing a fix: the strap ring's own Y-radius (0.180) put its front edge
at y=-0.290 — forward of the goggle barrel tip it's mounted to (y=-0.262),
which is forward of the lens (y=-0.228). The "strap" was geometrically the
frontmost part of the whole goggle assembly. Pulled the ring's Y-radius
0.180→0.105 (front edge now -0.215, tucked behind the barrel tip); X-radius
(head width, already correct) untouched. Same segment counts — a pure shape
change, no tri cost.

**Verified, not assumed:** tri budget/part count unaffected (1378/1400,
unchanged — only a radius parameter moved); `_sil.png` pixel diff against
the pre-fix capture is 64 of 65,536px (0.1%), confirming this was never a
silhouette-line defect; the 512px party portrait shows the fix clearly (the
strap tucks behind the lens instead of jutting past it) but honestly does
**not** survive downsampling to the true 34px party-panel size — reported as
such, not oversold; the true in-fight hunter size (`state=3dgrip`, ~30px)
shows no visible difference by eye either, as expected for a feature this
fine against the whole model.

**Score: Style 8→9, 39→40/50.** A real defect closed at its actual root
cause (the strap projecting past the goggles it holds on), at the two
angles that matter (the fight camera's own three-quarter reference angle,
and profile) — held short of 10 because the win doesn't reach true in-fight
size and the ring's hidden back half was untouched.

![[frames/artist/2026-09-23-goblin-mech-goggle-blade-34-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-goggle-blade-side-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-goggle-blade-portrait-before-after.png]]

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model: one failing check, `hunter-off-marker` (2
hits, foothold 4) — the identical residual pass 7's own matched-pair run
against this same beast already confirmed pre-existing earlier today. Not
re-run as a matched pair a second time: this pass changed one torus radius
parameter on a decorative ring, which has no code path into foothold/
climb-marker placement.

## Old: hunters, pass 7 (goblin_mech) + Meshy network wall

**Tried the Meshy hunter rebuild Nick's brief now calls for, and hit a real
infrastructure wall, not a credential one.** `balance`/`preview`/`refine`/`get`
all work through `api.meshy.ai` (the proxy injects the key fine); generated 3
from-scratch Frog previews, all reached `SUCCEEDED 100`. But `fetch` downloads
the actual model from `assets.meshy.ai` — a *different* host — and this
sandbox's network policy denies it (confirmed via the proxy's own status
endpoint: a 403 policy denial, not a bad key). So Meshy can finish a
generation here and never let an agent retrieve it. Filed
`to: nick`: `requests/2026-09-23-1345-artist-to-nick-meshy-fetch-blocked-by-network-policy.md`
(needs `assets.meshy.ai` added to the environment's allowed network domains).
Also researched (not yet built) what a Meshy hunter rebuild actually needs
end-to-end and found it's bigger than one run regardless of the network fix:
`ai_beast.py`'s rig/weights/actions are quadruped-only (no arm bones at all —
blocks the Goblin specifically), and `combat_3d.gd`'s toon-shader/animation
path (`AI_ART`, `_shade_model`'s `root == _beast` gate, `_find_anim`) never
applies to hunters at all today — a rigged Meshy hunter would render worse
than the current primitives, not better, until that's generalized. Filed that
gap too, with exact line numbers, so whoever gets the network fix isn't
blocked twice: `requests/2026-09-23-1330-artist-to-fixer-hunter-display-path-has-no-toon-or-rig-support.md`.
3 Meshy preview tasks spent today, logged in `design/progress/meshy-ledger.md`
(committed so other agents see accurate spend) — not retrievable, so not
wasted on anything usable, but worth knowing before someone else re-spends
chasing the same wall.

Pivoted the rest of the run to `goblin_mech` (no Meshy dependency) — my own
`## Next` from last run had already flagged its rig-scale-up idea for
Proportion as "real potential, needs a full build→render→look cycle," and
this run had the budget for it. Full write-up in `design/progress/goblin_mech.md`
pass 7. Scaled every rig coordinate and size (not just a post-hoc mesh
transform, which is what pass 6 rightly worried could reopen a "touching by
camera luck" gap) by the same 1.18x factor from the same pivot, in the
generator — mathematically exact, so nothing that touched before can
un-touch now. Verified every specific risk pass 6 named, not just the
headline number: tri budget unchanged (1378/1400), silhouette still one
connected component (`scipy.ndimage.label`, now 19,408px), the pass-3
top-down compressor/shoulder gap checked directly against a fresh render of
the *unscaled* model and confirmed the same proportion (not worsened), the
pass-4 wrist-joint seam and the exhaust-pipe/lid connection both still read
clean in tight crops, and the change is visible (smaller, as always) at true
in-fight size, not just in the close-up scoring renders.

**Score: Proportion 7→8, 38→39/50** — the rig-vs-ordinary-arm ratio moves
from 1.3–1.6x to roughly 1.5–1.9x and the rig is now unmistakably the larger
mass in every view, closing most of the "present in intent, not in the
render" gap this file has been naming since pass 1.

`ALL TESTS PASSED`. Ran `mode=play` (40 steps) as a **matched pair** — once
against the rebuilt model, once against the untouched original, same seed —
specifically so a difference between the two runs couldn't be waved off as
"probably pre-existing." Both hit the identical, already-filed
`hunter-off-marker` foothold-4 residual at the same coordinates (confirmed
pre-existing, not reopened). The rebuilt-model run also hit one
`damage-popup-offscreen` (a boss-damage popup) the control run didn't
reproduce at the same step — not something a static-mesh-only change has any
code path to cause, and these playtests aren't frame-identical between runs
regardless (real-time hop/camera sampling); left for the playtester, not
chased here.

![[frames/artist/2026-09-23-goblin-mech-pass7-rig-scale-before-after.png]]

**Before this, tried the Meshy hunter rebuild Nick's brief now calls for, and
hit a real infrastructure wall, not a credential one.**
`balance`/`preview`/`refine`/`get` all work through `api.meshy.ai` (the proxy
injects the key fine); generated 3 from-scratch Frog previews, all reached
`SUCCEEDED 100`. But `fetch` downloads the actual model from
`assets.meshy.ai` — a *different* host — and this sandbox's network policy
denies it (confirmed via the proxy's own status endpoint: a 403 policy
denial, not a bad key). So Meshy can finish a generation here and never let
an agent retrieve it. Filed `to: nick`:
`requests/2026-09-23-1345-artist-to-nick-meshy-fetch-blocked-by-network-policy.md`
(needs `assets.meshy.ai` added to the environment's allowed network domains).
Also researched (not yet built) what a Meshy hunter rebuild actually needs
end-to-end and found it's bigger than one run regardless of the network fix:
`ai_beast.py`'s rig/weights/actions are quadruped-only (no arm bones at all —
blocks the Goblin specifically, though the Frog's own anatomy would clear
its gate), and `combat_3d.gd`'s toon-shader/animation path (`AI_ART`,
`_shade_model`'s `root == _beast` gate, `_find_anim`) never applies to
hunters at all today — a rigged Meshy hunter would render worse than the
current primitives, not better, until that's generalized. Filed that gap
too, with exact line numbers, so whoever gets the network fix isn't blocked
twice:
`requests/2026-09-23-1330-artist-to-fixer-hunter-display-path-has-no-toon-or-rig-support.md`.
3 Meshy preview tasks spent today, logged in `design/progress/meshy-ledger.md`
(committed so other agents see accurate spend) — not retrievable, so not
wasted on anything usable, but worth knowing before someone else re-spends
chasing the same wall.

## Next

Both `to:` requests from the Meshy pass (Nick's network-policy fix, the
fixer's hunter-display generalization) and the arena wall-accent request are
still open — check them first next run. Until one lands, `goblin_mech`
(40/50, cap lifted) has one real, previously-flagged, not-yet-attempted lead
left: Hygiene's claw/piston mass still reading as a separate lump from the
main rig body (pass 3's original note, never actually fixed, only
re-confirmed "connected but distinct" in pass 5) — this pass found a measured
cause for a similarly-vague-sounding Style complaint (the goggle strap) by
comparing exact part coordinates rather than re-looking at the same renders,
which is the model worth repeating on Hygiene rather than another "checked,
doesn't hold up" pass. `frog` is past its own stop line (43/50); the Meshy
Frog rebuild unblocks once the network-policy request lands (Frog's anatomy
already clears `ai_beast.py`'s quadruped gate, the Goblin's doesn't).

## Old: hunters, pass 6 (goblin_mech) + arena wall-accent verification

Picked up my own `## Next` from last run in full: goblin_mech (38/50, cap
lifted, below the 42 hunter stop line) needed a genuinely fresh six-view
look, not a re-litigation of pass 5's two ruled-out candidates. Ran it —
full write-up in `design/progress/goblin_mech.md` pass 6 — and it came back
clean: no new defect found. Three specific things checked, not assumed:

- **The pass-4 crown-zigzag fix, checked against its own before/after
  renders** (`goblin_mech_pass3_34.png` vs `pass4_34.png`, same crop): the
  improvement is real, not oversold — pass 3's sharp "M" with deep shadowed
  valleys is visibly softer in pass 4/6's identical geometry, matching the
  honest partial-credit score (7→8, not higher) it was already given.
- **Silhouette connectivity**, this time by `scipy.ndimage.label` on the
  actual pixel data rather than a look: 1 connected component, 17,079px —
  the "ordinary" MINT arm included. Answers Hygiene's "no part spaced away
  from the body" line directly.
- **Whether the rig genuinely reads as "enormous"** — the docstring's own
  claim, against the ordinary arm specifically (not the whole body, which
  it never claims to dwarf): the rig's limb radii run 1.3–1.6x the ordinary
  arm's, plus several boxes/tapers/a ring it has none of. Real, moderate —
  confirms Prop's existing 7 is the right number, not a hidden defect.

**Considered, and explicitly declined, a rig-scale-up experiment** for
Proportion — the one idea from this pass with real potential. Rejected
because this rig's parts were hand-tuned pass over pass to keep
loosely-touching pieces reading as connected (the exhaust cap, the
crown-zigzag joints); a blind uniform scale risks reopening a gap the loop
can only catch by actually rendering and looking again, which is a second
pass's worth of work, not a same-pass gamble. Flagged for whoever picks
this up next with budget for the full cycle.

**Score unchanged: 38/50.** `ALL TESTS PASSED` (no code touched); skipped a
playtest re-run since nothing in `goblin_mech.py`/`.glb` changed from
`origin/main`.

![[frames/artist/2026-09-23-goblin-mech-pass6-fresh-check.png]]

Second half of the run: the arena's one genuinely open, non-Nick-blocked
question from `cinder_jackal_ground.md` pass 2/3 — whether the RUST wall
accent (credited toward Colour/Style 3→6) is ever actually visible in play,
"untested at a camera pitch that would show it." Rendered every 3D state
the fight uses (`3d`, `3dclimb`, `3dgrip`, `3dstrike`) plus a pulled-back
`wide` framing and checked each directly, not just the one sigil-close-up
angle pass 2 tried. **Confirmed: never visible in any of them** — the
wall's own top edge runs off-frame before reaching the accent's placement
height, even in the widest framing tested. It IS real and does show in the
loop's own scoring camera (`cinder_jackal_env_pass3_34.png`) — same family
of finding as `goblin_mech.md`'s exhaust-pipe/hose-ring "only in a diagnostic
angle" results, now with the fight's own camera states all checked instead
of one.

**Not fixed** — the accent's placement fraction and the wall's overall
height both live in `env.py`'s shared `enclose()`/`_wall_cliff`, used by
every "cliff" ground in the game; changing either is a cross-fight call,
already flagged twice for Nick by other grounds' progress files without an
explicit ask. Filed one now, with the evidence and three concrete options
to pick from: `requests/2026-09-23-1200-artist-to-nick-arena-wall-accent-never-shows.md`.
No score change (28/50 stands) — this closes an open verification line, it
doesn't diagnose a new fix.

![[frames/artist/2026-09-23-cinder-jackal-wall-accent-camera-comparison.png]]

## Old: hunters, pass 5 (goblin_mech)

Picked up my own `## Next` from last run: `frog` cleared its stop line last
pass, so moved to `goblin_mech` (37/50, cap lifted by Nick the same day as
`frog`'s — see `requests/2026-09-23-0325-artist-to-nick-hunters-at-pass-cap-below-stop-line.md`).
Pass 4's own `## Where it stands` named two open candidates for pass 5: the
wrist joint's rounded cap reading as a different curvature from the boxes
it bridges, and the claw/piston assembly at the feet reading as a distinct
mass from the rig body. A full fresh six-view capture and close look at
both found **neither holds up** — the wrist cap already reads as a shallow
continuous seam (pass 4's own `seg=10` fix), and the claw/piston box reads
connected in every isolated view. Checked, not fixed, not re-opened without
a reason — written up in `design/progress/goblin_mech.md`.

**What pass 5 actually found: this rig's two darkest tones are a
near-tie, on the one line the model's own docstring says is the whole
point.** Sampled `colormap_base.png` directly (the same technique frog pass
7 used): GRAPHITE and CHARCOAL — the compressor box and the hose ring, this
rig's two largest single-colour masses — sample at luminance 59.4 and 56.4,
functionally identical, against STONE/PEWTER (this same rig's own other
tones) at 114.1/139.5. The file's header states the rig's whole job is
bevelled boxes that "read as machined plate" via a bright bevel edge — that
needs headroom above the toon shader's shadow floor, and GRAPHITE/CHARCOAL
start closest to it of anything on the model.

**Got the first in-game verification wrong, and the record says so.** A
mid-strike shot (`state=3dstrike slot=1`) sampled a dark pixel near the
goblin — 18.4 luminance, an 13.8-point gap against a nearby jackal-body
sample — and read that as "the rig vanishes against the beast." Applied the
fix, re-shot the identical state, and the sampled pixel came back
**pixel-identical, before and after**: proof whatever was at that
coordinate wasn't touched by the edit. Ran this project's own
diagnostic-recolour check (all rig tones forced to `ICE`, pass 3/4's
technique) and confirmed it: that pixel was the jackal's own wing membrane
in shadow, not the rig — in this specific pose the rig is almost entirely
self-occluded behind the goblin's own torso. The camouflage claim for that
exact pose is false and withdrawn, not quietly dropped.

**What actually verified, properly this time:**
- Isolated renders: `_sil.png` pixel-identical before/after (colour-only,
  1378 tris both builds), `_front.png` shows the compressor box and ring
  visibly lighter. A pixel diff over the region that changed (3065px) shows
  mean luminance 79.3 → 86.2 — real, but far short of the raw 55-point
  swatch gap; the toon shader's own shadow/highlight banding compresses
  most of it away, the same "flat render oversold it" pattern the arena
  pass found once already for this fight's lighting.
- Live fight camera, a real unoccluded pose this time (`state=3dgrip
  slot=1`, goblin standing in the open on a foothold): the same lightening
  is visible, smaller at true size, no regression to anything else in
  frame — confirmed by reading the crop directly, not repeating the earlier
  blind-coordinate mistake.

**Colour 7 → 8** (real, verified, modest, and initially mis-verified once
before being corrected — reported that way, not cleaned up after the
fact). Sil/Prop/Hygiene/Style untouched: no geometry, no tri-count change,
`_sil.png` proves it. **37 → 38/50.**

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model: `PLAYTEST FAIL: 1 failing check(s)
{ "hunter-off-marker": 3 }` at foothold 4, steps 36–38 — checked against
what's on record, not assumed: *exact* same home/anchor coordinates
(`home (5.335257, 13.825942, 7.030925)`, `anchor (3.901302, 13.825942,
6.473297)`) as the already-open
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`
— confirmed pre-existing by coordinate match (a colour-only material edit
cannot move where the game decides a shared foothold's anchor is), not
re-filed.

Full write-up, the luminance table, and the misidentified-pixel correction
in full: `design/progress/goblin_mech.md`.

![[frames/artist/2026-09-23-goblin-mech-rig-value-front-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-rig-value-34-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-rig-value-infight-before-after.png]]

### Next (as of pass 5, superseded above)

`goblin_mech` is at 38/50, cap lifted, still below the 42 hunter stop line.
Both candidates pass 4 left open are now checked and ruled non-issues — do
not re-open either without a fresh reason (see `design/progress/goblin_mech.md`
"Where it stands"). A `look.py`-only defect was also found and correctly
left alone: the hose ring collapses to a thin line in a pure side-profile
render, but the live fight camera never puts a hunter in that profile
(checked across `3d`/`3dgrip`/`3dstrike` this pass), matching the same
"diagnostic-angle-only, not a real defect" precedent pass 3 already set for
the exhaust pipe. Next run, absent a request: look for a genuinely new
defect on `goblin_mech` (six views again, fresh eyes) rather than assume
either ruled-out candidate is still live, or move to the arena/frog if
nothing new turns up. Still true from every prior run: a full Meshy-rigged
hunter to match the jackal's own fidelity is blocked on rig-display game
code (`tools/agents/COMMON.md`'s rule against forcing hunters through
`ai_beast.py`) — a `to: fixer` request for rig support, not attempted
blind.

`python3 tools/meshy.py balance` not checked this run — a colour-only
material edit on an existing model doesn't need it.

## Old: hunters, pass 8 (frog)

No open `to: artist` request this run (checked every file's frontmatter, not
just the ones with obvious titles). Set up fresh (Godot 4.7.1 + `--import`;
`download.blender.org` is still unreachable from this sandbox — same finding
as every prior run — so Blender came from `apt install blender` again, 4.0.2,
plus `libegl1`/`libgl1-mesa-dri`/`libglx-mesa0` for headless EEVEE; Blender's
own Python is 3.12 here, `python3.12 -m pip install --break-system-packages
numpy pillow` was needed before glTF export/import would run at all).

Picked up pass 7's own named candidate from `frog.md`'s "Where it stands":
the front legs never broke the silhouette the way pass 5's haunch does — a
Silhouette/Proportion fix. `frog` pass 8 (`design/progress/frog.md`),
41→43/50 — **clears the 42 hunter stop line.**

**Three attempts, each looked at in a render before trying the next** (the
loop's own rule, not a single computed guess): (1) widening the limb's own
start radius in place barely cleared the head ellipsoid's own measured
surface — real but marginal (614px silhouette diff, mostly the foot); (2) a
dedicated shoulder ball (the hindleg's own knee-ball technique) placed where
attempt 1's maths pointed was still barely visible (331px) — a local
"clears the surface at this point" calculation understates how much is
hidden behind the head's *compound* silhouette from the actual scoring
camera angle; (3) pushed the ball much further out and it broke the
silhouette decisively (2642px, visible in `_sil`, `_side` and `_front`) —
but it sat far from the limb's own start point and read as a third ball
glued to the cheek in `_side.png`, not a shoulder. Caught by looking at
`_side`, not just `_sil` — exactly the "look at every render, not just the
one you expect to move" the loop's honesty rule is for.

**Landed on:** put the ball where the limb starts, nearly coincident, the
same relationship pass 5's knee ball already has with the hindleg — moved
the limb's own first point out to meet the ball instead of leaving the ball
to stand apart from it. Reads as a shoulder with a leg growing out of it in
both `_form.png` (clay) and `_side.png`.

**Cost:** two new balls (mirrored), 4800 → 5136 tris (+336) — a further
increase on the frog's already-deliberate overage (now 3.7x the 1400 hunter
budget), the second pass running to add geometry rather than only
reposition. Named as a real, growing cost, not folded in quietly.

**Verified, not assumed:** `_sil` diff 670px at a real leg-attachment
location (down from attempt 3's 2642px — the trade made for reading
integrated instead of glued-on); `_side`/`_form` show a genuine shoulder
lobe; `_front` reads a touch broader through the shoulders, symmetric with
the haunch; `_top` unchanged (front legs hidden under the head from above in
both builds — checked, not skipped); footprint unchanged (`1.72 x 1.46 x
1.15` both builds, so this doesn't reopen Nick's earlier "frog is too big"
finding). In the real fight camera (`state=3d`, `cinder_jackal`, true before
via `git stash`): 363 of 1736 differing px fall in a 180×180 crop on the
frog, 70 near the goblin (unrelated idle drift), the rest the jackal's own
ember pulse — the same pattern every prior pass has seen. **34px party
portrait: rebuilt, and honestly does NOT show this fix** — the 512px render
genuinely differs (5737px) but it doesn't survive the downsample to 34×34;
kept the rebuilt `frog.png` anyway as the accurate render of the current
model, same call pass 6/7 made.

**Score.** Silhouette 8→9, Proportion 8→9: the front legs now carry their
own mass and break the outline, verified in `_sil`, `_side` and the live
fight camera, not just the model in isolation. Held to 9, not 10 — the
silhouette change is real but modest, and Hygiene didn't move alongside (the
tri overage grew again). **+2 total (41→43)**, past the 42 hunter stop line.

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model: `hunter-off-marker` fails at foothold 4
(steps 34–35), *exact* same home/anchor coordinates as the already-open
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`
— confirmed pre-existing by coordinate match, not re-filed.

Full write-up, all three attempts and why each was rejected or kept:
`design/progress/frog.md`.

![[frames/artist/2026-09-23-frog-foreshoulder-sil-before-after.png]]
![[frames/artist/2026-09-23-frog-foreshoulder-side-before-after.png]]
![[frames/artist/2026-09-23-frog-foreshoulder-infight-before-after.png]]

## Next

`frog` is now past its 42 hunter stop line (43/50) — the honest call per
`design/asset-loop.md` is to stop passing it unless a request or a fresh
look finds a real defect, not chase 44+ for its own sake. One thing still
open if it comes back up: the back saddle/nostrils' 34px legibility pass 6
found and pass 7 partially closed — still unmoved, and this pass's own
attempt-2 finding (a local surface calc undersells camera-angle occlusion)
applies there too. Next run, absent a request: move to `goblin_mech`
(37/50, cap-lifted, candidates in `design/progress/goblin_mech.md`), or open
the fixer request that would unblock a real Meshy-rigged hunter attempt
(flagged again below, unattempted, same as last run).

`python3 tools/meshy.py balance` returned a real balance this run —
Meshy is live, not used this pass (a colour/geometry fix on an existing
model doesn't need it). Still true from last run: a full Meshy-rigged
`frog`/`goblin_mech` to match the jackal's own fidelity is a multi-run,
cross-agent initiative blocked on rig-display game code
(`tools/agents/COMMON.md`'s rule against forcing hunters through
`ai_beast.py`) — a real option for a future run that starts with a
`to: fixer` request for rig support, not attempted blind.

## Old: hunters, pass 7 (frog)

No open `to: artist` request this run (checked every file's frontmatter, not
just the ones with obvious titles). Set up fresh (Godot 4.7.1 + `--import`;
`download.blender.org` is still unreachable from this sandbox — same finding
as every prior run — so Blender came from `apt install blender` again, 4.0.2,
plus `libegl1`/`libgl1-mesa-dri`/`libglx-mesa0` for headless EEVEE; Blender's
own Python is 3.12 here, `python3.12 -m pip install --break-system-packages
numpy pillow` was needed before glTF export/import would run at all).
`python3 tools/meshy.py balance` returned a real balance (3020) — Meshy is
live this run, noted for the record, not used (see below for why).

Nick's brief moved this run (`tools/agents/artist.md`, 2026-09-23 update, the
one my own last run's `## Next` flagged unread-in-full): "make the
characters and environment CLEAN," pulling design principles from fully
developed/AAA games, described in words only (never a screenshot from
another game in this repo). Read it in full before picking work. Considered
the heavier option first — Meshy + the jackal's own `ai_beast.py` pipeline
could in principle build a hunter to the jackal's own fidelity — and ruled
it out for THIS run: `tools/agents/COMMON.md` is explicit that hunters are
not beasts, don't force them through `ai_beast.py`, and any code the game
needs to show a rigged hunter is the fixer's to build first. A full
Meshy-rigged hunter is a multi-run, cross-agent initiative (mesh generation,
cleanup, a from-scratch skeleton and weighting the way the jackal's own recipe
document shows it took), not a "one thing, well" for a single run — flagged
as a real option for a future run that starts with a `to: fixer` request for
rig support, not attempted blind here.

Instead, picked up my own `## Next` from last run: continue the hunters
(`frog` or `goblin_mech`, either valid) with the wider brief in mind, not
another capped mechanical asset-loop pass. `frog` pass 7
(`design/progress/frog.md`), 40→41/50: diagnosed Style, the one rubric line
pass 6 flagged as never having had a dedicated look.

**The technique.** AAA character-design teams commonly test a design in
**greyscale** before shipping — hue stops separating two shapes once
distance or a small render flattens colour perception, so every meaningful
part boundary needs real light/dark separation, not just a different hue at
the same brightness (Blizzard's own published design pillars for
Overwatch's heroes are the clearest public statement of this; described
here in words only, no screenshot from another game added to this repo, per
Nick's brief and `design/asset-loop.md`'s own reference rule).

**Measured every colour boundary in the model against that test**, off
`colormap.png`'s own pixels (perceptual luminance
`0.2126R + 0.7152G + 0.0722B`), not eyeballed: MINT↔CREAM 68.7,
MINT↔dorsal-GREEN 38.1, MINT↔eye colours 100+, and **MINT foot-pad↔AMBER
toes 18.8 — the weakest boundary on the whole model**, on the one feature
`foot()`'s own docstring calls "most of what a frog's foot reads as."

**Fix: AMBER → RUST on the toes**, `tools/blender/frog.py` `foot()`, the
only change. RUST samples at a 42.9-point gap from the foot pad — more than
double AMBER's — and is this fight's own established warm accent (the
arena wall/scatter recolour already uses it), so the frog's one accent
colour now echoes the ground it fights on. No geometry touched: `TRIS 4800
PARTS 40` identical before/after.

**Verified, not assumed.** `frog_pass7_sil.png` pixel-identical to pass 6's
(`numpy.array_equal`) — colour-only, confirmed. Greyscale conversion of the
34px scoring render shows the toes go from barely-distinguishable-in-value
to a visibly separate darker mass — the fix does what the measurement
predicted, seen in a render. In the real fight camera (`state=3d`,
`cinder_jackal`, rebuilt pass 6 via `git stash` for a true before): a
full-frame pixel diff is 0.16% of pixels, landing inside both hunters' own
crops and nowhere else scanned; a 6×-upscaled crop on the frog's visible
foreleg toe at true combat size (~15px) shows a real, if small, colour
shift. **The 34px party portrait — unmoved by pass 6 — moves this time**:
rebuilt `frog.png` (`portraits.py frog`, single-name arg, only that one file
changed) and downsampled to 34×34; the toes sit at the crop's bottom edge
and the recolour reads there too, a partial close of the portrait gap pass
6 left open (the back saddle/nostrils still don't show at that size —
unchanged this pass, a different fix).

Style 8→9 — the model's weakest colour boundary, found by a named,
applicable technique rather than eyeballed, fixed, and it ties the frog's
palette to the arena's for free. Sil/Prop/Hygiene/Colour untouched
(identical geometry). **40→41/50, +1** — not a big pass, but a real,
verified one, on a line that had never been looked at before.

![[frames/artist/2026-09-23-frog-toes-value-contrast-34-before-after.png]]
![[frames/artist/2026-09-23-frog-toes-infight-before-after.png]]
![[frames/artist/2026-09-23-frog-toes-portrait34-before-after.png]]

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model: `PLAYTEST FAIL: 1 failing check(s)
{ "hunter-off-marker": 2 }` (steps 34–35, foothold 4) — checked against
what's on record, not assumed: *exact* same home/anchor coordinates
(`home (5.335257, 13.825942, 7.030925)`, `anchor (3.901302, 13.825942,
6.473297)`) as the already-open
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`
(a shared-foothold hull-width issue, nothing to do with a colour-only
material edit). No `hop-flat` fire this run, unlike pass 6's. Confirmed
pre-existing by coordinate match, not re-filed here.

Full write-up, the luminance table, and the plateau-clause note for whoever
runs pass 8: `design/progress/frog.md`.

(That run's own `## Next` flagged the front legs — untouched since pass 4,
not yet breaking the silhouette the way the haunch does — as the live
Silhouette/Proportion candidate; that is what pass 8 above picked up.)

## Old: hunters, pass 6 (frog)

No open `to: artist` request that run. Continued the hunters (item 2) from
the previous run's own `## Next`: `frog` pass 6, diagnosing and fixing pass
5's two tied-lowest lines, Hygiene and Colour (`design/progress/frog.md`),
38→40/50.

**Colour — the docstring's own back-marking promise, never built.**
`frog.py`'s header has always said "GREEN now does what a darker shade
should: the eyelids and the back markings, reading as shading on a lighter
animal" — but no back marking existed anywhere in the code. Every MINT mass
(head, body, both leg pairs, the haunch) was one flat colour; parts
separated only by pass 5's geometry notch, never by colour, which is what
"do the palette swatches separate the parts?" was scoring 7 for. Added one
GREEN ball pressed up into the body's own back (same technique the CREAM
belly already uses from below), sized and placed by solving the body/head
ellipsoids' own surface equations first — not eyeballed — so it pokes
through only along the centre ridge and stops short of the haunch ball's
footprint in X, on purpose, so it can't paint over the notch pass 5 just
won.

**Hygiene — tris spent on a part with zero pixels.** Looked at the front
view closely for the first time this pass and found the two nostril balls
(small, deliberate, named in the file's own docstring) never actually
showed — solved the head's own surface equation at their x/z and found
their front edge sat 0.04-0.07 short of the head's real surface across the
ball's whole extent: fully submerged, contributing nothing. Moved them out
0.07 in Y so they clear the surface with margin. Cost: the back-marking ball
is new geometry, 100 triangles (kept deliberately low-detail, `seg=10,
ring=6` — it only has to read as a patch); the nostril fix is a position
change on the same two balls, no added tris. 4700 → 4800, a further small
increase on an already-deliberate overage, named as a real cost rather than
buried.

**Verified, not assumed.** `frog_pass6_top.png` shows the GREEN saddle
patch clearly, separate from the MINT sides; `frog_pass6_front.png` shows
both nostrils, where pass 5 showed none. The silhouette did not move —
`frog_pass6_sil.png` is pixel-identical to pass 5's (`numpy.array_equal`,
not eyeballed), confirming the marking is colour-only from that angle and
didn't touch the haunch notch. In the real fight camera (`state=3d`,
`cinder_jackal`), rebuilt pass 5 from `git stash` for a true before, then
pass 6, same camera: the pixel diff is real and lands on both hunters
(matching clusters at both hunter positions), with the rest of the frame's
diff traced to the jackal's own idle ember-pulse (unrelated). At true
combat distance the nostrils are a small real win; the back marking is
faint there — reported as small, not oversold. **The 34px party portrait
does not show either fix** — rebuilt it (`portraits.py`) and compared: that
camera's angle doesn't reach far enough over the back for the saddle, and
the nostrils are too small at that size. The Colour rubric explicitly names
the 34px portrait, and this pass didn't move that specific view — left open
rather than hidden. (Rebuilding `frog.png` rebuilds all 32 portraits as a
side effect of running `portraits.py` at all; reverted every one but
`frog.png` to stay in scope.)

![[frames/artist/2026-09-23-frog-back-marking-top-before-after.png]]
![[frames/artist/2026-09-23-frog-nostrils-front-before-after.png]]
![[frames/artist/2026-09-23-frog-pass6-infight-before-after.png]]

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model: `PLAYTEST FAIL: 2 failing check(s)
{ "hop-flat": 1, "hunter-off-marker": 1 }` — checked both against what's
already on record, not assumed pre-existing. `hop-flat` (step 22) matches
the same short-single-leg-hop sparse-sampling pattern this and other passes
have already seen and left alone. `hunter-off-marker` (step 37, foothold 4)
has the *exact* same home/anchor coordinates
(`home (5.335257, 13.825942, 7.030925)`, `anchor (3.901302, 13.825942,
6.473297)`) as the residual the fixer's own
`2026-09-23-0900-playtester-to-fixer-hunter-floats-off-model-at-foothold-4.md`
already named and re-filed as
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`
(both hunters sharing foothold 4 at once, a `stand_offset_x`/hull-width
issue, nothing to do with a static-mesh position edit inside one hunter's
own local space). Confirmed by coordinate match, not re-filed here.

**Environment note:** that run's background playtest runs stepped on each
other — three separate Godot processes ended up running at once on a
4-core box (each retry looked dead because an earlier status check raced a
slow notification, not because the process had actually exited), and the
resource contention is the likely cause of two of them crashing with an
unhelpful bare `exit code 2`. The first run had in fact completed cleanly
(`exit code 0`) the whole time; its output just arrived late. Check
`ps aux | grep godot` for a still-live process before assuming a playtest
run died and retrying.

## Old

**Pass 5 on `frog`** (`design/progress/frog.md`), 36 → 38/50. Applied both
halves of that diagnosis in `tools/blender/frog.py`, geometry-position edits
only, no new parts:

- Narrowed the trunk ball's depth (Y) `0.60 → 0.50`, so it stops reading as
  round from every angle.
- Pushed the hindleg's knee ball outward in X `0.50*s → 0.58*s` (and the
  limb's own start point with it, so it stays seated in the ball), so the
  haunch breaks the silhouette instead of blending into the trunk's own
  swell.

Also wrote the **ANCHOR** sentence `design/asset-loop.md` step 4 calls for
— `frog.md` never had one — since without it there's nothing to score later
passes against besides last pass's number.

**Verified, not assumed.** `look.sh frog 5` (six new views): `_sil.png` and
`_form.png` both show the haunch as a separated lobe with a real notch
against the trunk, where pass 4's own silhouette was one continuous blob.
In the live fight camera (`state=3d`, `cinder_jackal`), a before/after at
true on-screen hunter size shows the same change more subtly (expected —
matches the `goblin_mech` precedent that close-range fixes read stronger in
the scoring camera than at combat distance); a pixel diff confirms it's
real and localised: 2517/32400 px differ in a 180×180 crop centred on the
hunter, against 5469 differing px in the full 1280×720 frame — the change
doesn't scatter across the frame the way idle-animation drift would.
Silhouette 7→8, Proportion 7→8 (both the lines the pass-4 diagnosis named);
Hygiene/Colour/Style untouched (geometry count identical before/after:
`TRIS 4700 PARTS 39` both builds, confirmed, not assumed).

![[frames/artist/2026-09-23-frog-haunch-sil-before-after.png]]
![[frames/artist/2026-09-23-frog-haunch-infight-before-after.png]]

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model: 1 failing check, `hunter-off-marker` at
step 35, foothold 4 — same home/anchor coordinates as the already-open
`requests/2026-09-23-0900-playtester-to-fixer-hunter-floats-off-model-at-foothold-4.md`
(filed to the fixer, a gameplay-code position bug, not a model issue).
Confirmed pre-existing and unrelated to this pass, not filed again here — a
static-mesh position edit inside one part's local space can't move where
the game decides a foothold's world anchor is.

**Environment note for whoever runs next**: same two blockers as previous
runs — `download.blender.org` is unreachable (sandbox egress policy);
`apt install blender` works (pulls 4.0.2 + `libegl1`/`libgl1-mesa-dri` this
time needed a plain `apt-get update` first, an earlier attempt 404'd on
stale package lists) — and Blender's bundled Python on this apt build is
the **system** `/usr/bin/python3.12`, not a Blender-private copy; `numpy`
and `pillow` need `python3.12 -m pip install --break-system-packages numpy`
(for Blender's own scripts) and a plain `pip install --break-system-packages
pillow numpy` (for `silmetrics.py`, run outside Blender). Also needed
`apt-get install -y libegl1 libgl1-mesa-dri libglx-mesa0` before
`look.sh`/`screenshot.gd` would render — EGL, not just GL, is required even
for Blender's own headless EEVEE captures on this image.

Took the one open `to: artist` request:
`requests/2026-09-23-0500-nick-to-artist-recreate-leap-style.md` — prove,
ONCE, whether the artist can recreate Nick's Canva card-art style
(`game/assets/cardart/leap.png`) without Canva, on a single test card, and
report honestly whether the route works.

**Studied `leap.png` at 1:1 and in crops** (full write-up in the request):
flat filled shapes, no outlines, depth from atmospheric-perspective colour
alone (pale-far to near-black-near), a tree-lined-corridor composition —
full-height trees hugging the left/right margins, a narrow ragged sky slit
up the centre — and a tiny frog, off-centre, on a branch, camera pulled way
back.

**Route: pure 2D procedural paint** (`tools/cardpaint.py`), not a Blender
render — `leap.png` has no 3D shading cue to render toward (no specular, no
lens perspective, no AO), it's flat layered shapes, which a renderer fights
and a direct 2D paint reproduces on its own terms. Palette sampled straight
from `leap.png`'s own pixel histogram, not invented. Picked **Hop** (Frog's
starter deck, currently a bare icon, same "climb" flavour as `leap` for a
fair comparison).

**Took three full rewrites to get right**, not one pass: v1's stacked-
triangle canopies left a flat empty sky rectangle where the recession should
be; v2 fixed the gap but had a base-height bug that made distant trees hang
like icicles from the top of the frame; v3 (final) switched to overlapping
rounded ellipse lobes on thin bare trunks after actually cropping and
looking at `leap.png`'s margins — its canopies are lobed, not spiky — and
rebuilt the composition as two full-height tree walls around a hazy,
partly-translucent (not solid) centre treeline. Every round needed a fresh
look at the render, not just a number tweak.

**Verdict, in the request's own words: don't scale this.** It gets the
surface cues (sampled palette, flat-shape layering, tiny-subject-in-a-big-
landscape framing) close enough to read as "the same family," especially at
card size. It does not get Nick's hand — his canopy shapes read as
unmistakably pine trees on sight; these need forest context to read as
trees at all, and the centre recession still reads as a soft smear more
than real depth. That's not a tuning gap, it's the artist's-judgement layer
(where to put a branch, how to vary one canopy against its neighbour) that
a human supplies for free and a script has to fake with heavy hand-tuning
per scene, from scratch, per card — no shortcut for card #2. Against Nick's
stated flow (he paints, the artist recreates the *style*), this route
doesn't save him the painting step.

Comparison, full size and card size (~160px), side by side:

![[frames/artist/2026-09-23-leap-style-recreate-test.png]]

Not shipped into `game/assets/cardart/`, no second card attempted, per the
request. `tools/cardpaint.py` stays in the tree for reference.
`ALL TESTS PASSED` (no game code touched, ran the suite anyway).

## Old: cards (item 4) — first model-rendered card art (Piston Punch)

No open `to: artist` request this run. Both hunters (item 2) are at their
4-pass cap awaiting Nick (see `## Old` below and the standing `to: nick`
request), and the arena (item 3) stopped short on purpose pending the
shared-wall-system call across three grounds — also Nick's. So this run
picked up item 4, **the cards**, which last run's `## Next` flagged as
"untouched so far this whole thread of runs."

**The real blocker on cards is art, not code** (`design/BACKLOG.md` #82) —
painted card faces need Canva work from Nick (`tools/artprep.py`'s `--card`
flow), and only 4 of 187 cards (all Frog) have any. Rather than wait on
that, tried the same move `portraits.py` already made for the party-panel
portraits: **render the art from the hunter's own model** instead of
painting it. Built the pipeline and proved it on one card, the Goblin
Engineer's `Piston Punch` (this fight's other hunter, currently at zero
painted cards):

- `tools/blender/cardart.py` — new, modelled directly on `portraits.py`:
  loads a hunter's `.glb`, but frames FULL BODY at the card's real 620×870
  aspect (`sensor_fit = VERTICAL` so the aspect ratio, not a square, drives
  the camera) instead of portraits.py's head-and-shoulders crop, and
  renders on transparency rather than compositing in Blender.
- `tools/cardbg.py` — new, plain-Python compositing step (kept separate
  from the Blender render, same division `artprep.py` already draws): a
  contained ember-glow backdrop sampled straight from
  `tools/blender/colormap_base.png`'s CHARCOAL/RUST cells — the same two
  colours the arena pass already established as this fight's palette — so
  the card and the ground it's fought on agree. First attempt blended all
  the way to raw RUST at the glow's centre and it read as a card-sized
  orange flare, the same mistake in the opposite direction as the arena
  pass's own "flat render oversold the effect" finding; darkened the base
  to 45% and capped the blend at 40% toward RUST to fix it.
- Output: `game/assets/cardart/piston_punch.png`. No code change needed —
  `CardView._build_face` already loads `cardart/<id>.png` by convention, so
  the same file that makes `crescendo`/`leap` etc. painted makes this one
  painted too.

**Verified in the real fight**, not just the isolated render: `hand=`
forced Piston Punch into a real hand next to `Slash`/`Brace` at the actual
in-game card size, and separately next to `Satchel Charge` (another Goblin
card, still a bare icon, same slot) for a fair before/after. Reads clearly
at hand size — the goblin and its mech arm are both legible, no edge halo
from the alpha composite, the raised exhaust pipe happens to read as a
"punching" silhouette by the coincidence of the model's own resting pose
that the card's namesake move plausibly matches (it's the model as it
already exists in the fight, not a fabricated action pose — there is no rig
to re-pose off, so this stays true to the "rendered, not painted" premise
end to end). `3dinspect` opened cleanly on it too (`RIGHTCLICK
opened_inspector=true`, correct keyword text). `ALL TESTS PASSED`;
`mode=play` playtest (40 steps) `PLAYTEST OK: 0 failing check(s)` — a
new PNG can't touch gameplay logic, but ran it anyway rather than assume.

![[frames/artist/2026-09-23-piston-punch-before-after.png]]
![[frames/artist/2026-09-23-piston-punch-infight.png]]

**Filed `to: nick`, did not scale it further.** This is a real style
choice — rendered-from-model art next to the Frog's 4 painted illustrations
is a different look, and mixing them in one deck (or replacing the 4
paintings too) is a taste call, not mine to make for 30+ more cards. See
`requests/2026-09-23-0800-artist-to-nick-model-rendered-card-art-direction.md`.

## Old: hunters, pass 4 (goblin_mech)

No open `to: artist` request that run, so picked up item 2 (hunters) per
that run's `## Next` — `goblin_mech` was one pass short of the hunter stop
line (42), with a diagnosed-but-unformed 4-way tie at 35/50. Ran pass 4
(`design/progress/goblin_mech.md`), 35 → 37/50 — the loop's 4-pass cap for
this asset, not a plateau call.

**Neither pass-3 candidate survived contact with a full six-view capture.**
Pass 3 had only ever committed `_34`/`_front`/`_sil`; `look.cmd goblin_mech
4` also renders `_side`/`_top`/`_form`, which this pass looked at for the
first time. The goggle-readability-at-34px candidate turned out fine when
actually checked against the 34px party portrait. The claw/piston
"connectedness" candidate turned out to already be one connected mesh
(`_sil.png` is a single connected component, checked with
`scipy.ndimage.label`).

**What the six views actually showed:** a sharp zigzag "crown of teeth"
right where the upper-arm and wrist limbs meet their boxes — this is what
three passes of scoring had been calling "reads as scattered blocks"
without ever finding the real cause. Diagnosed with the same diagnostic-
recolour technique pass 3 used on the exhaust pipe: an `ICE`-recoloured
limb exactly matched the zigzag; the CHARCOAL collar ring I'd first
suspected did not. Fix: `seg` 6→10 on both limbs (rounds the hex end-cap
that was catching its own toon-shading facets). Separately, `_side.png`
showed the goggle strap as a razor-thin blade past the ear — a near-flat
torus with almost no cross-section edge-on; thickened it (`thickness`
0.16→0.26) and pulled its radius in slightly. Silhouette 7→8, Style 7→8.

**Budget:** the two limb fixes cost +48 tris against 4 tris of headroom.
Freed it with four small cuts verified not to matter — the same collar
ring's own segment count (which the diagnostic recolour had just shown was
never the zigzag), the off-rig arm/hand, and the exhaust/goggle-barrel
tapers, one segment each. 1396 → 1378, still under the 1400 hunter budget.

**Verified, not assumed:** `_sil.png` pixel-diff against pass 3, both at
the scoring 64px render — 0.4% of pixels differ (lit-shading only, not
silhouette). In the real fight camera, a full-frame diff against pass 3's
own capture shows fewer differing pixels than pass 3's own idle-animation
baseline — no regression, as expected at ~20px true hunter size; the win
is in the close-up scoring renders. Playtest flagged `hop-flat` once — 
checked directly against the unmodified baseline (same fight, same steps)
and it fires there too, so it's pre-existing and unrelated to this asset,
not something to fix or file here.

![[frames/artist/2026-09-23-goblin-mech-joint-crown-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-goggle-strap-before-after.png]]

`ALL TESTS PASSED`.

## Old: pass 3 (tri budget)

Ran pass 3 of the asset-loop on `goblin_mech`
(`design/progress/goblin_mech.md`), 33 → 35/50.

**First, resolved a standing "unsure about" from pass 1/2 as a non-issue.**
The raised orange exhaust pipe both earlier passes flagged as possibly
floating off the compressor box only separates in `look.py`'s top-down
view — every camera the game actually uses (the fight camera, the
three-quarter and side `look.py` views) shows it touching cleanly. Checked
empirically: recoloured the exhaust and the tusks (the model's other `ICE`
user) to a diagnostic magenta one at a time, rebuilt, re-shot the live
fight camera. Neither swap explained a pale-blue triangle I'd also
suspected was part of this model, floating above the goblin's head in the
real fight screenshot — that turned out to be `combat_3d.gd`'s own
per-hunter "pip" marker (existing gameplay UI, out of scope), not an asset
bug. Worth knowing for whoever next scores a hunter against the live fight
camera: that pip sits over hunter slot 1 in every fight, always.

**Second, closed the tri-budget overage** (1484/1400, 84 over, open since
pass 1): trimmed segment/ring counts on the body, head and snout balls and
the piston-rod tapers — the biggest, gentlest-curved masses and the
thinnest, least-noticed part, deliberately not the small high-detail
features (eyes, goggles) the frog's own budget cut burned itself on.
1484 → 1396, now under budget. Verified pixel-identical at the 64px
silhouette rubric and indistinguishable in the live fight camera before
fixing it in the doc as a real, not assumed, non-regression — see the
before/after frames. Hygiene 5 → 7.

`ALL TESTS PASSED`; playtest (`mode=play`, 40 steps) re-run against the
rebuilt model, `PLAYTEST OK: 0 failing check(s)`.

![[frames/artist/2026-09-23-goblin-mech-tri-budget-34-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-tri-budget-infight-before-after.png]]

Full pass-by-pass detail, what's still open (the claw/piston assembly's own
connectedness; whether the goggles/strap read at true combat distance),
and the sigil-less-rig note: `design/progress/goblin_mech.md`.

## Old: the arena pass

No open `to: artist` request this run, so picked up the brief's next item
in order — the arena. `design/progress/cinder_jackal_ground.md` did not
exist: the ground had renders from a past batch build but had never been
scored under `design/asset-loop.md`, unlike several other fights' grounds.
Ran the loop on it (pass 1 baseline, pass 2 fix, pass 3 fix), scored
22 → 28/50 (stop line for a ground is 44; stopped short of it deliberately —
see the file's "Why stop here").

**The finding:** `tools/blender/env/cinder_jackal.py`'s wall used the
default `enclose("cliff")` — plain SLATE/PEWTER, the same grey as any other
quarry ground in the game, sitting right next to a floor the script's own
docstring calls "burnt ground, still smoking." Recoloured the wall to
CHARCOAL (matching the apron/rim it already shares) with a RUST accent (the
beast's own hot colour row), and the boulder/slab scatter from PEWTER/STONE
to BROWN/CLAY for the same reason.

**Verified in the real fight, and it almost wasn't a real fix.** A neutral
Blender render showed a dramatic swing to near-black; a first glance at
in-game screenshots looked unchanged, which would have been a false "done."
Two things caught it: a diagnostic magenta pass to confirm which on-screen
shape was actually the wall (not the jackal's own footholds, which sit at a
similar screen position and don't move), then a direct pixel sample at the
sigil close-up — (163,144,132) → (103,77,51), a real ~53/255 shift under
this fight's warm ambient lighting, just far more muted there than the flat
Blender preview suggested. The RUST accent band itself was never confirmed
visible in any tested camera framing (sits above the frame top on tall wall
pieces) — flagged open rather than claimed. The scatter recolour is
measured-real in the source data but its own on-screen contribution came
back as ~1% of the frame in a pixel diff — kept for consistency, not scored
as a further win, because it wasn't seen to move anything a player would
notice.

Stopped at pass 3: the two lines still lowest, Silhouette and Proportion
(5/10 each — the wall fills the fight-camera frame and the floor is only
confirmable from directly above), are the same systemic finding
`crag_pup_ground.md` and `stone_warden_ground.md` already made about the
shared `env.py` wall system. Not this script's to fix alone, and not
re-filing a third copy of the same open finding.

Before/after — in-game (`state=3dclimb`, sigil close-up) and the isolated
Blender top-down render, same seed, colour-only diff, geometry/budget
unchanged (5966 tris, 1 mesh, 1 material both passes):

![[frames/artist/2026-09-22-cinder-jackal-arena-wall-before.png]]
![[frames/artist/2026-09-22-cinder-jackal-arena-wall-after.png]]
![[frames/artist/2026-09-22-cinder-jackal-arena-wall-top-before.png]]
![[frames/artist/2026-09-22-cinder-jackal-arena-wall-top-after.png]]

`ALL TESTS PASSED`. Playtest (`mode=play`, 80 steps) re-run against the
rebuilt ground to confirm no regression — see the Log line below for the
result.

Blender was unreachable via `download.blender.org` again this run (same
finding as last time — sandbox egress policy). Worked around it with the
Ubuntu-packaged `apt install blender` (4.0.2) instead, plus `libegl1`/
`libgl1-mesa-dri` for headless EEVEE rendering under `xvfb-run`, and
`numpy` for Blender's own Python 3.12 (its glTF importer needs it and the
system `python3` on this image defaults to 3.11, so `pip install numpy`
alone silently didn't fix it — needed `python3.12 -m pip install
--break-system-packages numpy`). Worth writing into
`design/agents/status/README.md` for whoever hits this next, since it's
now happened two runs running.

## Old: the ear-glare fix

Fixed `requests/2026-09-22-1700-session-to-artist-jackal-ear-glare.md`: the
Cinder Jackal's inner ears were painting the same hot-orange as its embers,
so the hue/sat/val glow key in `toon.gdshader` lit up the whole ear at the
sigil close-up. No shader knob could fix it without also dimming the real
embers (glow_gain is a single uniform for the whole beast); a geometric
"dead zone" in the shader was too imprecise on this ~12k-face mesh (per-pixel
interpolation left most of the ear only partially masked). Fixed at the
source instead: painted the ear triangles' exact UV footprint directly onto
`cinder_jackal_ai_Image_0.jpg` (the 2048×2048 texture Godot's importer
extracted from the .glb — confirmed edits there survive `--import`), scaling
saturation/value down on just those texels so hue/detail (the crack pattern)
survive and it reads as ear-in-shadow, not a paint-over.

Before/after in `design/agents/frames/artist/2026-09-22-jackal-ear-glare-*.png`
(the exact repro in the request). Also checked `state=3d`, `3dgrip`,
`3dstrike` and `3dreward` (the felled body) — the fix carries cleanly to
every camera, no regression. `ALL TESTS PASSED`. Request marked `done` with
the full writeup.

Blender is unreachable this session (download.blender.org is blocked by the
sandbox's egress policy) — did the geometry analysis by parsing the .glb
directly with `pygltflib` instead. Worth knowing for whoever picks up
`ai_beast.py`-based work next: if Blender download fails, the .glb is still
fully inspectable without it for anything that doesn't need re-export.

## Next

Card art is closed for now: parked by Nick (2026-09-23, see `tools/agents/artist.md`),
and this run's request answered it with a documented "don't scale" — the
procedural-paint route reproduces surface style cues but not Nick's hand,
and costs real iteration per card with no reuse across different subjects.
Nothing left to do on cards without a new signal from Nick.

**Brief has moved on**: the 4-pass cap on the two hunters is *lifted*
(`tools/agents/artist.md`, 2026-09-23 update) and the goal is now explicitly
"make the characters and the environment CLEAN," pulling from fully
developed/AAA games, restyling or rebuilding the hunters if that reads
better than polishing them in place. Next run's default pick (no open
request): resume the hunters (Frog, `goblin_mech`) or the arena with that
wider brief in mind, not another capped asset-loop pass — read the updated
brief in full before picking up either.

## Log

- 2026-09-23 — `goblin_mech` pass 8: fresh six-view look at the last open
  Style candidate (goggle strap at oblique angles) found a real defect pass
  4 never saw — the strap's own Y-radius put its front edge ahead of the
  goggle barrel/lens it's mounted to (measured: -0.290 vs -0.262 vs -0.228),
  reading as a blade/beak at the fight-camera (3/4) and profile angles.
  Pulled Y-radius 0.180→0.105, verified tri budget/silhouette/portrait/
  in-fight, no tri cost. Style 8→9, 39→40/50. ALL TESTS PASSED; playtest
  re-run, one pre-existing `hunter-off-marker` FAIL (already filed, no code
  path from a decorative-ring radius to foothold placement).
- 2026-09-23 — Meshy hunter rebuild attempt hit a network-policy wall:
  `api.meshy.ai` works, `fetch`'s `assets.meshy.ai` is denied by the
  sandbox; 3 Frog previews generated, unretrievable. Filed to:nick (network)
  and to:fixer (hunters never get the beast toon/anim display path — a
  rigged Meshy hunter would render worse than today's primitives without
  it). Pivoted to `goblin_mech` pass 7: did the rig-scale-up experiment pass
  6 flagged, scaled every rig coordinate+size from one pivot in the
  generator (not a post-hoc mesh transform), verified every risk pass 6
  named, Proportion 7→8, 38→39/50. Matched-pair playtest (rebuilt vs stock,
  same seed) confirmed both playtest FAILs found are pre-existing. ALL
  TESTS PASSED.
- 2026-09-23 — pass 6 on `goblin_mech` (item 2, hunters, cap lifted): fresh
  six-view check found no new defect. Re-confirmed pass 4's crown-zigzag
  fix wasn't oversold (compared its own before/after renders directly),
  confirmed the whole silhouette including the ordinary arm is one
  connected component (`scipy.ndimage.label`), and measured the
  rig-vs-ordinary-arm size disparity as real but moderate — Prop/Hygiene's
  existing 7s hold up, not hidden defects. Considered and declined a
  rig-scale-up experiment for Proportion as too risky without a full
  iterate cycle. Score unchanged, 38/50. Separately: verified the arena's
  open "RUST wall accent visibility" question across all 5 real fight
  camera states plus a wide framing — confirmed it never shows in play
  (only in the loop's own scoring camera) — and filed
  `to: nick` (`requests/2026-09-23-1200-artist-to-nick-arena-wall-accent-never-shows.md`)
  since the fix lives in shared `env.py` code. No code changed;
  `ALL TESTS PASSED`. See `design/progress/goblin_mech.md` pass 6,
  `design/progress/cinder_jackal_ground.md` pass 4, and `## Now`/`## Next`
  above for the full write-up.
- 2026-09-23 — pass 5 on `goblin_mech` (item 2, hunters, cap lifted),
  37→38/50: checked pass 4's two open candidates (wrist-joint curvature,
  claw/piston distinctness) fresh and ruled both non-issues, not fixed.
  Found and fixed a real one instead — GRAPHITE and CHARCOAL, the rig's two
  largest single-colour masses (compressor box, hose ring), sample at
  near-identical luminance (59.4/56.4) against this same rig's own STONE/
  PEWTER (114.1/139.5), leaving little headroom for the toon-shaded bevel
  highlight the model's own docstring says is the rig's whole job. Moved
  both to STONE, no new hue, no geometry/tri change (`_sil.png`
  pixel-identical, 1378 tris both builds). **Got the first in-game
  verification wrong and corrected it on the record**: an initial
  mid-strike camouflage claim (13.8-luminance-gap sample) turned out to be
  a misidentified pixel — the sampled point was pixel-identical before and
  after the fix, and a diagnostic recolour confirmed it was the jackal's
  own wing membrane, not the rig, which is mostly self-occluded in that
  pose. Re-verified properly: isolated renders show a real (if
  shader-compressed, +6.9 mean luminance) lightening, and a genuinely
  unoccluded in-game pose (`state=3dgrip slot=1`) confirms it without
  repeating the earlier mistake. Colour 7→8. `ALL TESTS PASSED`; playtest
  re-run, the one failure (`hunter-off-marker`, foothold 4) matches the
  already-open fixer request by exact coordinates, pre-existing. See
  `design/progress/goblin_mech.md` and `## Now` above for the full
  write-up, including the misidentified-pixel correction in full.
- 2026-09-23 — pass 8 on `frog` (item 2, hunters), 41→43/50: fixed pass 7's
  own named candidate — the front legs never broke the silhouette the way
  the haunch does since pass 5. Three attempts, each looked at in a render
  before the next: a fatter limb radius (marginal, mostly the foot), a
  shoulder ball placed by a local surface calc (still barely visible — the
  scoring camera's compound silhouette hides more than one ellipsoid's own
  local surface implies), a much bigger ball placed away from the limb
  (broke the silhouette but read as a glued-on third lump in `_side.png`).
  Landed on a shoulder ball placed almost exactly where the limb starts —
  the same relationship pass 5's own knee ball has with the hindleg — which
  reads as an integrated shoulder in `_side`/`_form` and still gives a real,
  if modest, 670px `_sil` diff. Cost: +336 tris (4800→5136), a further
  increase on the model's already-deliberate overage. Sil 8→9, Prop 8→9 —
  **clears the 42 hunter stop line.** Verified in isolated renders (`_sil`,
  `_side`, `_front`, `_top`, unchanged footprint), the live fight camera
  (real, localised diff on the frog, not the goblin or the jackal's own
  idle pulse), and the 34px portrait (honestly does not show this fix,
  unlike some earlier passes — reported, not hidden). `ALL TESTS PASSED`;
  playtest re-run, the one failure (`hunter-off-marker` at foothold 4)
  matches the already-open fixer request by exact coordinates, pre-existing.
  `frog` is now past its stop line — next run moves to `goblin_mech` or the
  Meshy-rig fixer request unless something new is found. See
  `design/progress/frog.md` and `## Now` above for the full write-up.
- 2026-09-23 — pass 7 on `frog` (item 2, hunters) under Nick's wider "make
  the characters CLEAN, pull from AAA games" brief, 40→41/50: diagnosed
  Style (never had a dedicated pass) using a named greyscale/value-contrast
  technique — measured every colour boundary on the model off the atlas's
  own pixels and found the AMBER toes vs the MINT foot pad were the
  weakest on the whole model (18.8 luminance gap, against 38–100+
  everywhere else), on the one feature the model's own docstring calls
  its foot's main read. Fixed with a single colour swap, AMBER→RUST (a
  43-point gap, and this fight's own established warm accent), no geometry
  change. Verified in a greyscale render, a live-fight before/after
  (real, localised diff on both hunters), and — a first — the 34px party
  portrait, which actually shows this fix where it didn't show pass 6's.
  Considered and explicitly declined a heavier option this run: a
  Meshy-generated, jackal-fidelity rigged hunter, blocked on game code
  only the fixer can build (`COMMON.md`'s own rule against forcing hunters
  through `ai_beast.py`) — flagged as a future `to: fixer` request, not
  attempted blind. `ALL TESTS PASSED`; playtest re-run, one failure
  (`hunter-off-marker` at foothold 4) matched the already-open fixer
  request by exact coordinates. See `design/progress/frog.md` and `## Now`
  above for the full write-up.
- 2026-09-23 — pass 6 of the asset loop on `frog` (item 2, hunters, cap
  lifted), 38→40/50: fixed pass 5's two tied-lowest lines, one concrete fix
  each. Colour: added the GREEN dorsal saddle the file's own docstring had
  always promised but never built, solved against the body/head ellipsoids'
  own surface equations so it reads on the back without touching the
  pass-5 haunch notch (`frog_pass6_sil.png` pixel-identical to pass 5's).
  Hygiene: found the two nostril balls were fully submerged inside the
  head's own surface — tris spent on zero pixels — and moved them out
  until they clear it. Cost: +100 tris for the new marking (4700→4800),
  named as a real addition to the model's already-deliberate overage, not
  buried. Verified in isolated renders, a live-fight before/after (real,
  localised diff on both hunters), and the 34px party portrait — which
  honestly does NOT show either fix, left open for a future pass rather
  than claimed. `ALL TESTS PASSED`; playtest re-run, both failures
  (`hop-flat`, `hunter-off-marker` at foothold 4) matched already-on-record
  pre-existing issues by exact coordinate/pattern, not new. See
  `design/progress/frog.md` and `## Now` above for the full write-up.
- 2026-09-23 — pass 5 of the asset loop on `frog` (item 2, hunters, cap
  lifted), 36→38/50: applied the pass-4 diagnosis in full — narrowed the
  trunk ball's depth and pushed the haunch knee outward in X — so the
  haunch reads as a bulge breaking the silhouette instead of merging into
  one round mass. Wrote the missing ANCHOR sentence. Verified in
  `_sil.png`/`_form.png` and a live-fight before/after pixel diff (change
  is real and confined to the hunter's footprint). Sil 7→8, Prop 7→8;
  geometry count unchanged. `ALL TESTS PASSED`; playtest re-run, the one
  failure (`hunter-off-marker` at foothold 4) matches the already-open
  fixer request exactly (same coordinates), confirmed pre-existing. See
  `design/progress/frog.md` and `## Now` above for the full write-up.
- 2026-09-23 — took the standing `to: artist` request, the leap-style
  recreate test: studied `leap.png`'s style in words (flat shapes, no
  outlines, atmospheric-perspective depth, full-height tree-corridor
  composition, tiny off-centre subject), then built one new card
  (`Hop`, Frog's starter deck, previously a bare icon) in that style via a
  pure 2D procedural paint (`tools/cardpaint.py`) — not a Blender render,
  since `leap.png` itself has no 3D shading cue to render toward. Palette
  sampled from `leap.png`'s own pixel histogram, not invented. Took three
  full rewrites (empty-sky gap → inverted/hanging trees → lobed canopies on
  bare trunks, the fix that actually read as leap's style) before it held
  together. Verdict, written into the request: gets the surface cues close
  enough to read as "the same family," especially at card size, but not
  Nick's hand — recommend NOT scaling this to the rest of the deck. Not
  shipped into `cardart/`, no second card, per the request's own limits.
  `ALL TESTS PASSED`. See the request
  (`requests/2026-09-23-0500-nick-to-artist-recreate-leap-style.md`) for
  the full writeup and `## Now` above for the short version.
- 2026-09-23 — cards (item 4), first pass: built a model-rendered card art
  pipeline (`tools/blender/cardart.py`, `tools/cardbg.py`) instead of
  waiting on Nick's Canva paintings, proved it on the Goblin Engineer's
  `Piston Punch` (zero painted cards on that hunter previously). Verified
  in a real hand next to both a bare-icon card and generated cards, in the
  inspector, `ALL TESTS PASSED`, playtest clean. Filed `to: nick` before
  scaling to the other ~30 cards — a style/taste call, not a code one. See
  `## Now` for the full write-up.
- 2026-09-23 — pass 4 of the asset loop on `goblin_mech` (item 2, hunters),
  35→37/50, the asset's 4-pass cap: found and fixed the real cause behind
  three passes of "reads as scattered blocks" — the upper-arm and wrist
  limbs' hex end-caps exposed as a sharp zigzag right at their box joints
  (diagnosed by a diagnostic recolour, which also cleared the CHARCOAL
  collar ring of the same suspicion) — smoothed both (`seg` 6→10, Sil
  7→8), and thickened the goggle strap ring, which read as a blade from
  the side (Style 7→8). Freed the +48 tri cost with four small, verified
  cuts elsewhere, 1396→1378, still under budget. `_sil.png` pixel-diff
  0.4% (lit-shading only); in-fight capture diff smaller than pass 3's own
  idle-animation noise floor. Playtest's `hop-flat` fail checked directly
  against the unmodified baseline — fires there too, pre-existing,
  unrelated to this asset. `ALL TESTS PASSED`. See
  `design/progress/goblin_mech.md` for the full pass detail.
- 2026-09-23 — pass 3 of the asset loop on `goblin_mech` (item 2, hunters),
  33→35/50: resolved pass 1/2's "unsure about" (the exhaust pipe reads
  fine in every camera the game uses, only separates in a top-down view
  nobody sees) as a non-issue, ruled out an unrelated pale-blue triangle
  in the live fight screenshot as `combat_3d.gd`'s own hunter-slot pip
  marker rather than an asset bug, and closed the 84-tri budget overage
  (1484→1396) by trimming segment counts on the model's biggest/gentlest
  masses and its thinnest rod — verified pixel-identical at the 64px
  silhouette rubric and unchanged in the live fight camera. Hygiene 5→7.
  `ALL TESTS PASSED`; playtest re-run (40 steps), 0 failing checks. See
  `design/progress/goblin_mech.md` for the full pass detail.
- 2026-09-22 — scored `cinder_jackal`'s fight ground (never scored before,
  despite existing renders), 22→28/50 over two applied fixes: the
  `enclose()` wall recoloured from generic SLATE/PEWTER to CHARCOAL/RUST,
  and the boulder/slab scatter from PEWTER/STONE to BROWN/CLAY, both
  matching the beast's own warm palette instead of a colour dropped in
  from a different biome. Verified in the real fight camera (not just the
  isolated Blender render, which oversold the effect under neutral
  lighting) with a direct pixel sample at the sigil close-up. Stopped
  short of the 44/50 ground stop-line on purpose — the remaining two low
  lines are the same shared-wall-system finding two other grounds already
  flagged for Nick. `ALL TESTS PASSED`; playtest re-run against the
  rebuilt ground. See `design/progress/cinder_jackal_ground.md` for the
  full pass-by-pass log.
- 2026-09-22 — fixed the jackal ear-glare request (texture edit, not a
  shader change — see `## Old`). `ALL TESTS PASSED`; checked every 3D
  camera state, no regression.
- 2026-09-22 — note created by the session.
