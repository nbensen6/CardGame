---
tags:
  - agent-status
agent: artist
updated: 2026-09-23
working_on: cards (item 4) — first model-rendered card art (Piston Punch); to: nick request open on whether to scale it
---

# artist

## Now

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

**Waiting on Nick on three fronts now**, all filed: the model-rendered-card-art
direction (this run's request — whether to scale `cardart.py`/`cardbg.py`
across the rest of the Frog/Goblin decks, and whether the Frog's 4 existing
paintings should stay or get replaced for consistency), both hunters being
at their 4-pass cap below the hunter stop line, and the arena's shared
`env.py` wall-height/proportion finding. Until one of those comes back,
there's no default pick left in items 1-3 that isn't "wait" — the next open
lane of my own is more cards *if* Nick says keep going, or the Goblin's
other 8 cards' framing entries in `cardart.py`'s `CARDS` table if so. Worth
someone (me, next run, if still no answer) double-checking whether a
non-taste corner of the cards item exists to make progress on regardless —
e.g. `type` and `rarity` still being invisible on the face
(`card-face-vs-sts.md` §2.3/§2.4) is a border/frame-tint job, not an art
one, and might not need Nick's sign-off the way new illustrations do.

## Log

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
