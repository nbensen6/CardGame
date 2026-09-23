---
tags:
  - agent-status
agent: artist
updated: 2026-09-23
working_on: no open to:artist request; frog pass 6, 38→40/50 (Hygiene and Colour, the two lines pass 5 left tied lowest) — 2 short of the 42 hunter stop line; next run either a frog Style pass or goblin_mech
---

# artist

## Now

No open `to: artist` request this run (checked every file's frontmatter, not
just the ones with obvious titles). Continued the hunters (item 2) from last
run's own `## Next`: `frog` pass 6, diagnosing and fixing pass 5's two
tied-lowest lines, Hygiene and Colour (`design/progress/frog.md`), 38→40/50.

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

**Environment note for whoever runs next:** this run's background playtest
runs stepped on each other — three separate `steps=40`/`steps=10` Godot
processes ended up running at once on a 4-core box (each retry looked dead
because an earlier status check raced a slow notification, not because the
process had actually exited), and the resource contention is the likely
cause of two of them crashing with an unhelpful bare `exit code 2`. The
first run had in fact completed cleanly (`exit code 0`) the whole time;
its output just arrived late. Check `ps aux | grep godot` for a still-live
process before assuming a playtest run died and retrying — retrying an
apparently-hung run is how three ended up racing each other here.

## Next

40/50 on `frog`, two passes into the lifted cap, 2 short of the 42 hunter
stop line. `frog.md`'s own "Where it stands" names the candidates: Style
(8, tied with everything else but never had a dedicated pass — no open
diagnosis yet, worth a first real look), the 34px party-portrait gap this
pass found and left open (the back marking and nostrils both fail to read
from that camera at that size — either give the portrait camera a reason
to show the back, or explicitly accept the in-fight read is what matters
and say so), and the front legs, still untouched since pass 4 (don't yet
break the silhouette the way the haunch now does). Next run, absent a
request: continue `frog` toward 42, or move to `goblin_mech` (37/50, also
cap-lifted, its own next candidates in `design/progress/goblin_mech.md`'s
"Where it stands, still open") — either is valid, whichever gets looked at
with fresh eyes.

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
