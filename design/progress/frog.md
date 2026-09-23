# frog — refinement log

Loop: `design/asset-loop.md`. Nick lifted the 4-pass cap for this hunter
2026-09-23 (see `requests/2026-09-23-0325-artist-to-nick-hunters-at-pass-cap-below-stop-line.md`)
— **pass 5 below, still short of the 42 hunter stop line.**

**ANCHOR:** *a squat, low-slung hopper — one wide, low body mass with a
distinct haunch bulging off its rear flank, two oversized round eyes riding
high on the skull, splayed toes front and back. Soft and round, but
crouched, not a ball.*

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 4 | 5 | 6 | 7 | 8 | **30** |
| 2 | 5 | 6 | 6 | 7 | 8 | **32** |
| 3 | 7 | 7 | 6 | 7 | 8 | **35** |
| 1-control | 6 | 7 | 7 | 7 | 8 | **35** |
| 4 | 7 | 7 | 7 | 7 | 8 | **36** |
| 5 | 8 | 8 | 7 | 7 | 8 | **38** |
| 6 | 8 | 8 | 8 | 8 | 8 | **40** |
| 7 | 8 | 8 | 8 | 8 | 9 | **41** |

**Read that table with the control row in mind.** Passes 1 and 2 were scored
through a broken camera, and most of the apparent climb from 30 to 35 is the
instrument being fixed, not the frog getting better. See below.

## The camera was the defect

`look.py` aimed its cameras with `to_track_quat("-Z", up)` and passed `"Z"` as
`up`. The second argument names the camera's **local** axis that should point at
world up, and for a camera that is `+Y` — `-Z` is already spoken for as the view
direction. Asking the solver to point the axis that runs backwards out of the
lens at the sky is unsatisfiable; with a downward tilt it fudges something close
enough to look right, and on a dead-level camera it gives up and rolls 90°.

So the profile view rendered the frog lying on its side, and the three-quarter
view — the one every score was read off — was rolled enough to turn a crouching
frog into a hunched quadruped. Pass 1's "reads as a bison, a boar, a musk ox"
was a real description of a real image of the wrong thing.

`preview.py` and `portraits.py` both had this right already. Fixed in pass 3.

## The control

`frog_pass1control_*.png` is the **original, unmodified** model rebuilt from
`git show HEAD:tools/blender/frog.py` and shot through the corrected cameras. It
already reads as a frog: two eye bumps at 64px, broad head, crouch, splayed
feet. Scored blind it lands about 35.

Which means three passes of work bought about **one point**. That is the honest
number.

## What each pass actually did

- **A — split the eyes** (x ±0.205 → ±0.250, z 1.455 → 1.485, brows pushed out
  with them). Real but small: the notch between the two bumps at 64px is
  visible in pass 4 and marginal in the control. **Kept.**
- **B — shrink the back-of-skull ball** (it spanned y −0.055..+0.435, over the
  whole torso). The head stops blending into the shoulders. **Kept.**
- **C — raise the haunch into a crouch.** Made it **worse**: the raised knee put
  a lump up beside the head that competed with it, and the silhouette got
  rounder, not more frog-like. The original slung-under leg gives a cleaner taper
  from head down to feet. **Reverted.**
- **D — take back 56 triangles** off the brow and belly balls to get under
  budget. Made it **visibly worse**: the brows faceted into hard green cubes
  poking out of the eyes, plainly visible at fight distance. **Reverted**, and
  the frog stays 4% over budget on purpose — there is now a note in the script
  saying so, because otherwise someone reclaims those 64 triangles again.

## Where it stands

Two of four fixes helped a little, two made it worse and were reverted. That is
a normal result for an asset that was already decent, and the loop caught both
regressions because it ends in looking at a render.

**Next, given another pass:** the body is a single large round mass and the
haunch merges into it, which is what holds Silhouette and Proportion at 7. Not a
crouch — that was tried. Narrowing the trunk in Y so it stops being a ball, and
pushing the haunch outward in X so the knee breaks the outline instead of
joining it.

**The bigger finding:** the frog was never the problem. The reason eleven assets
sat on the NEEDS A PASS list is that nothing had ever looked at them, and the
one tool that could have was rolling its own camera 90°. The rest of the list is
probably in better shape than it reads, and is now cheap to check.

---

## Pass 5 — artist lane, 2026-09-23

Applied pass 4's own diagnosis, unchanged: the body was a single round mass
with the haunch merged into it. Two fixes, `tools/blender/frog.py`:

1. **Narrowed the trunk ball in Y** (front-to-back depth): `(0.64, 0.60,
   0.42) → (0.64, 0.50, 0.42)`. At 0.60 the trunk's depth was close enough to
   its own width that it read as round from every angle rather than a body
   with a haunch bulging off it.
2. **Pushed the haunch (hindleg knee ball) outward in X**: centre `0.50*s →
   0.58*s`, and the hindleg limb's own start point shifted the same 0.08 so
   it still seats inside the ball rather than the trunk. The knee's outer
   edge already cleared the trunk's own X radius before this pass (0.80 vs
   0.64) — the problem wasn't that it failed to extend past the body in X,
   it's that sitting so close behind the trunk in Y, at nearly the same
   depth, it read as one continuous swell instead of a separate lobe. Moving
   it further out doesn't fix Y-closeness by itself, but combined with fix 1
   (a shallower trunk) the two together open a visible waist between them.

Geometry count untouched — both fixes are position/scale only, no new balls
or segments — so `TRIS 4700 PARTS 39` is identical before and after
(confirmed: same numbers on both builds). Hygiene, Colour and Style were not
touched and are carried forward unchanged from pass 4.

**Verified, not assumed.** `look.sh frog 5` (six new views,
`design/renders/frog_pass5_*.png`):

- `_sil.png`: the haunch now reads as a distinct rounded lobe separated from
  the main body mass by a visible notch, where pass 4's silhouette was one
  continuous blob with legs poking out the bottom. This is the concrete
  target the pass-4 diagnosis named.
- `_form.png` (clay, no colour): same finding — a clear valley between torso
  and haunch that pass 4's clay render doesn't have.
- In the live fight camera (`state=3d`, `cinder_jackal`, both hunters), a
  direct before/after at true on-screen hunter size (~40px, cropped and
  4x-zoomed for the frame below) shows the same haunch separation, more
  subtly than the close-up scoring renders — expected, matching the
  `goblin_mech` precedent that close-range fixes read stronger in the
  scoring camera than at true combat distance. A pixel diff against the
  unmodified-model screenshot: 2517 of 32400 px differ inside a 180×180 crop
  centred on the hunter (~7.8%), against 5469 differing px in the full
  1280×720 frame — almost all of the change is confined to the hunter's own
  footprint, not scattered across the frame the way idle-animation noise
  would be, so this is a real, localised geometry change, not drift.

**Scores.** Silhouette 7→8: the haunch bulge pass 4 called for is now
visible as a break in the outline, not a merge — held back from 9 because
the notch is a soft valley, not a sharp read, and the front legs still don't
add their own silhouette incident the way the haunch now does. Proportion
7→8: the body no longer reads as one mass with limbs implied; a frog's
"low body, bulging haunch" shape is now visible, not just present in intent.
+2 total — a real gain, not a plateau, so the rebuild-verdict's
two-consecutive-under-2 clause does not apply (pass 3→4 was +1, this pass is
+2).

`ALL TESTS PASSED`; playtest (`mode=play`, 40 steps) re-run against the
rebuilt model to confirm no regression — see the Log line in
`design/agents/status/artist.md` for the result.

![[frames/artist/2026-09-23-frog-haunch-sil-before-after.png]]
![[frames/artist/2026-09-23-frog-haunch-infight-before-after.png]]

## Where it stands, still open for the next pass

38/50, one pass (5) into the lifted cap, still short of the 42 hunter stop
line. Lowest lines now Hygiene and Colour, tied at 7. Hygiene's own open
item hasn't changed since pass 1: the frog runs 4700/1400 tris, over budget
on purpose per the file's own note (cutting the eyes' or brows' segments to
hit budget was tried and reverted — visibly worse). Colour at 7 has no
open diagnosis in this file yet — worth a fresh look next pass rather than
assumed. The front legs, never touched by this pass, are the other
candidate: they don't yet break the silhouette the way the haunch now does.

---

## Pass 6 — artist lane, 2026-09-23

Diagnosed and fixed both of pass 5's tied-lowest lines, Hygiene and Colour,
one concrete fix each, `tools/blender/frog.py`. Sil/Prop/Style untouched.

1. **Colour — a real dorsal marking, not a promise.** The file's own header
   docstring has always claimed "GREEN now does what a darker shade should:
   the eyelids and the back markings" — but no back marking ever existed in
   the code. Every MINT mass (head, body, both leg pairs, the haunch) was
   one flat colour; the parts separated only by pass 5's geometry notch, not
   by colour at all, which is what "Colour & read" (do the palette swatches
   separate the parts?) was scoring 7 for. Added one GREEN ball, `(0.00,
   0.10, 0.80)` size `(0.24, 0.28, 0.15)`, pressed up into the body's own
   back the same way the CREAM belly is pressed up from below — sized and
   placed by solving the body/head ellipsoids' own surface equations first
   (not eyeballed), so it pokes through only along the centre ridge and
   stops short of the haunch ball's footprint in X, deliberately, so it
   cannot paint over the pass-5 silhouette notch.
2. **Hygiene — the nostrils never rendered.** Checked the front view for the
   first time this pass (previous passes never looked closely at the snout)
   and found no nostrils visible at all, on a part the file's own docstring
   calls out as deliberate ("the only other feature on the face"). Solved
   the head ellipsoid's own surface equation at the nostril's x/z: the
   ball's front edge (`-0.828` at the old `y=-0.80`) sat `0.04`–`0.07` short
   of the head's own surface there (`-0.864` to `-0.874` across the ball's
   own z-extent) — the part was fully submerged, tris spent on zero pixels.
   Moved to `y=-0.87`, clearing the surface by a margin at every z the ball
   covers, not just its centre.

**Budget.** The back marking is a new part: 100 triangles (`seg=10,
ring=6`, kept deliberately low — it only needs to read as a soft patch, not
a detailed feature). The nostril fix is a position change on the same two
balls, no added tris. 4700 → 4800. This is a further, small increase on top
of the frog's already-deliberate overage (see "ON THE BUDGET" in the
script) — a real cost, and named as one rather than folded in quietly.

**Verified, not assumed.**

- `design/renders/frog_pass6_top.png` against pass 5: the back marking
  reads clearly as a distinct GREEN saddle patch on the crown of the back,
  visibly separate from the MINT sides — the top-down angle this fight's
  camera partly shares. `design/renders/frog_pass6_front.png`: two small
  dark nostril dots now visible on the snout, where pass 5 showed none.
- **The silhouette did not move.** `frog_pass6_sil.png` is pixel-identical
  to `frog_pass5_sil.png` (checked with `numpy.array_equal`, not eyeballed)
  — the marking is a colour-only change from this angle, confirming it did
  not touch the haunch notch pass 5 just won.
- **In the real fight camera** (`state=3d`, `cinder_jackal`), rebuilt the
  pass-5 model from `git stash` to get a true before, then the pass-6
  model, both through the same camera. A pixel diff of the full frame shows
  9246 differing px, of which only 254 fall inside a 180×180 crop centred
  on hunter0 — the rest is the jackal's own idle ember-pulse on its legs
  (unrelated, confirmed by location) plus a matching, smaller cluster of
  diff pixels sitting exactly on hunter1's position too — both hunters
  show the same real, localised change, not frame-wide noise. At true
  combat distance the nostrils are a small but real win; the back marking
  is faint at this size and this specific camera angle, honestly reported
  as small rather than claimed as large.
- **The party portrait does not show the win.** Rebuilt `frog.png`
  (`portraits.py`) and compared at the true 34px party-panel size: the
  portrait camera's angle does not reach far enough over the back to catch
  the saddle, and the nostrils are too small to read at 34px either. The
  Colour rubric explicitly asks about the 34px portrait, not just the
  512px render or the fight camera — this pass does not move that specific
  view, and that gap is left open rather than hidden. (Rebuilding all 32
  portraits was a side effect of running `portraits.py` at all — reverted
  every one except `frog.png`, kept in scope.)

**Scores.** Hygiene 7→8: a genuine defect (tris spent on an invisible part)
found and fixed, not a budget cut — the model is still over budget and
that stays a known, deliberate trade, not newly resolved. Colour 7→8: real
separation now exists in the cameras a player actually watches the fight
through (the 3/4 scoring angle, the top-down angle, and — smaller but
confirmed — the true in-fight camera), which is most of what "legible" has
to mean for a hunter that's on screen the whole fight; held to 8 and not
9 because the 34px party-portrait legibility named explicitly by the
rubric is unmoved. +2 total (38→40), not a plateau.

`ALL TESTS PASSED`; playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model — see the Log line in
`design/agents/status/artist.md` for the result.

![[frames/artist/2026-09-23-frog-back-marking-top-before-after.png]]
![[frames/artist/2026-09-23-frog-nostrils-front-before-after.png]]
![[frames/artist/2026-09-23-frog-pass6-infight-before-after.png]]

## Where it stands, still open for the next pass

40/50, two passes into the lifted cap, 2 short of the 42 hunter stop line.
Lowest line now Style alone, at 8, tied with everything else except it's
never had a dedicated pass — no open diagnosis exists for it yet, worth a
first real look. The 34px party-portrait gap this pass found and did not
close (the back marking and nostrils both fail to read at that size, from
that specific camera) is the other live candidate — either give the
portrait camera a reason to show the back, or accept the in-fight read is
what matters most and say so explicitly. The front legs, still untouched
since pass 4, remain a third option: they don't yet break the silhouette
the way the haunch now does.

---

## Pass 7 — artist lane, 2026-09-23 (Style, wider brief)

Nick's brief moved (`tools/agents/artist.md`, 2026-09-23): make the hunters
CLEAN, pulling from fully developed/AAA games for silhouette, palette
discipline and distance-readability — describe the reference in words, never
paste in a screenshot. Diagnosed Style, the one line pass 6 flagged as never
having had a dedicated look, `tools/blender/frog.py`.

**The reference and what it says.** Character-design teams on shipped AAA
titles (Blizzard's own published design pillars for Overwatch's heroes are
the clearest public statement of this, though the technique is standard
practice, not one game's invention) test every character in **greyscale**
before shipping, specifically because hue alone stops separating two shapes
once distance, dim lighting, or a small render shrinks colour perception —
what has to survive is **value** (how light or dark), not just colour. What
that means concretely here: every boundary between two parts of a model
should have real light/dark separation, not just a different hue at the same
brightness.

**Measured the model's own boundaries against that test, not guessed.**
Sampled every swatch this model uses directly off `colormap.png`'s own
pixels (the atlas the UVs point into) and computed luminance
(`0.2126R + 0.7152G + 0.0722B`, the standard perceptual weighting):

| boundary | luminance gap |
|---|---|
| MINT body ↔ CREAM throat/belly | 68.7 |
| MINT ↔ CHARCOAL / WHITE (eye) | 100+ |
| MINT body ↔ GREEN dorsal saddle | 38.1 |
| **MINT leg/foot-pad ↔ AMBER toes** | **18.8** |

The toes were the weakest colour boundary anywhere on the model — worth
naming because `foot()`'s own docstring calls the four-toe fan "most of what
a frog's foot reads as," so the model's least legible boundary sat on the
one feature it was relying on most.

**Fix: AMBER → RUST on the toes** (`tools/blender/frog.py` `foot()`), the
model's only colour change this pass. RUST samples at luminance 119.6
against the foot pad's 162.5 — a 42.9-point gap, better than double AMBER's
18.8, and comfortably clear of every other boundary's value. RUST is also
this fight's own established warm accent — the arena wall/scatter recolour
(`cinder_jackal_ground.md`) already uses it — so the frog's one accent colour
now echoes the ground it's fought on rather than sitting on an unrelated
orange. No geometry touched: `TRIS 4800 PARTS 40` identical before and
after.

**Verified, not assumed.**

- `frog_pass7_sil.png` is pixel-identical to `frog_pass6_sil.png`
  (`numpy.array_equal`) — confirms this is a colour-only change, silhouette
  untouched.
- Converted `frog_pass6_34.png` and `frog_pass7_34.png` to greyscale and
  compared side by side: in pass 6 the toes are barely distinguishable in
  value from the leg they're attached to; in pass 7 they read as a visibly
  darker, separate mass — the fix does what the measurement predicted, seen
  in a render, not just computed.
- **In the real fight camera** (`state=3d`, `cinder_jackal`), rebuilt pass 6
  from `git stash` for a true before, then pass 7, same camera, same
  hunter position. Full-frame pixel diff: 1467/921600 px differ (0.16%);
  cropping to each hunter's own on-screen footprint shows the change lands
  there (190px in a 180×180 crop around the frog, 72px around the goblin's
  crop, both non-zero, both matching the toe positions) and nowhere else
  scanned. A tight, 6×-upscaled crop on the frog's visible foreleg toe at
  true combat size (~15px across) shows a real colour shift, small but
  visible, from a dull amber blob to a distinctly reddish one.
- **The 34px party portrait — pass 6 left this camera unmoved; this pass
  does move it.** Rebuilt `frog.png` (`portraits.py frog`, single-name
  argument this run — only the one file changed, not all 32) and downsampled
  to the true 34×34 party-panel size: the toes sit at the bottom edge of
  this crop and the recolour is visible there too, reading as a clearer red
  accent against the cream belly rather than blending toward it. This is a
  genuine, if partial, close of the "34px portrait" gap pass 6 flagged open
  — the toes now separate at that size; the back saddle and nostrils still
  don't (unchanged this pass, out of scope for a Style-line fix).

**Score.** Style 8→9: the model's single weakest colour boundary is fixed,
diagnosed by a named, applicable industry technique rather than eyeballed,
and it also happens to tie the frog's palette to the arena's — a real style-
consistency win on two counts. Held to 9, not 10, because "sits beside the
approved assets" is a whole-cast judgement and this pass only touched one
hunter; Sil/Prop/Hygiene/Colour untouched (identical geometry, only the toe
material differs). **+1 total (40→41)** — under the loop's own "two passes
under 2 points" plateau clause this would be the second such pass (pass 6
was +2, so it does not trigger yet), but worth flagging for whoever runs
pass 8: a plateau reads differently on a hunter that just moved from a
0-diagnosis line to a named, verified fix than one that re-touched an
already-worked line, so treat the number honestly rather than as a stop
signal on its own.

`ALL TESTS PASSED`; playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model — see the Log line in
`design/agents/status/artist.md` for the result.

![[frames/artist/2026-09-23-frog-toes-value-contrast-34-before-after.png]]
![[frames/artist/2026-09-23-frog-toes-infight-before-after.png]]
![[frames/artist/2026-09-23-frog-toes-portrait34-before-after.png]]

## Where it stands, still open for the next pass

41/50, three passes into the lifted cap, 1 short of the 42 hunter stop line.
Sil/Prop/Hygiene/Colour all sit at 8, Style now 9. The two candidates pass 6
named are both still open and either would plausibly close the gap: the
front legs (untouched since pass 4, don't yet break the silhouette the way
the haunch does — a Silhouette/Proportion candidate) and the back
saddle/nostrils' own 34px legibility (still unmoved this pass — a further
Colour candidate, though it may need the shared portrait camera rather than
the model itself, which is a bigger, cross-cutting change this pass
deliberately did not risk).

---

## Pass 8 — artist lane, 2026-09-23 (Silhouette/Proportion: the front legs)

Picked up pass 7's own named candidate: the front legs don't break the
silhouette the way pass 5's haunch does — they start deep inside the head
ball at too small a radius to ever reach its surface, so no shoulder mass
shows in the outline; the leg only appears where the foot pokes out below.
`tools/blender/frog.py` `foreleg()`, the only function touched.

**Three things tried, each looked at in a render before the next** (the
loop's own "look before continuing," not assumed from the first idea):

1. Widened the limb's own start radius (0.185 → 0.24) in place. Measured
   against the head ellipsoid's own surface equation at that point's y/z
   (0.636 in X), the old radius's outer edge (0.485) was nowhere near the
   surface; the new one (0.64) barely clears it. Real but marginal: 614px
   differ in the `_sil` diff, almost all of it the foot, not a shoulder.
2. A dedicated shoulder ball (the hindleg's own technique — pass 5's knee
   ball is a separate mass, not a fatter limb), placed where #1's maths
   pointed (centre 0.50*s). Still only 331px differ. **The finding:** a
   local "does this point clear the head's surface at this y/z" calculation
   undersells how much of a point is actually hidden behind the REST of the
   head's compound silhouette from the scoring camera's actual angle — the
   3/4 camera sees more than one ellipsoid slice at once.
3. Pushed the ball much further out (centre 0.60*s, radius 0.30 — close to
   the hindleg knee ball's own proportions). This finally broke the
   silhouette decisively (2642px diff, visible in `_sil`, `_side` and
   `_front`) — but the ball sat 0.30 away in X from the limb's own start
   point (still 0.30*s), and in `_side.png` it read as a third ball glued to
   the cheek, not a shoulder growing a leg. A real defect, caught by looking
   at `_side`, not just `_sil` — the honesty rule this loop names.

**Landed on:** put the ball where the hindleg's own knee ball sits relative
to ITS limb — centre and limb-start nearly coincident, not offset — and
move the limb's start point out to meet it rather than leaving the ball to
stand alone. `start = (0.42*s, -0.44, 0.42)`; ball radius `(0.26, 0.24,
0.20)` there; the limb's own first point is now `start` itself. This reads
as a shoulder with a leg growing out of it in `_form.png` (clay) and
`_side.png` alike — checked both, not just the silhouette this time, after
attempt 3's exact failure mode was "looked right in `_sil`, wrong in
`_side`."

**Budget.** Two new balls (mirrored), `seg=12 ring=8` each: 4800 → 5136
tris, +336. A further increase on the frog's already-deliberate overage
(now 3.7x the 1400 hunter budget), named as a real cost, not folded in
quietly — this is the second pass running to add geometry (pass 6 added
100 tris for the dorsal saddle) rather than only repositioning, and that
trend is worth flagging for whoever runs pass 9 or the goblin next: cheap
position-only fixes are running out on this model.

**Verified, not assumed.**

- `_sil` diff (final version) against pass 7: 670px, in two small clusters —
  one right at the front leg's own attachment, one near the haunch (an
  unrelated 1-2px rounding shift from the new geometry's shadow on the
  render, not a haunch change; `_sil` is flat unlit so this is a real
  boundary pixel, not a shading artefact). Smaller than attempt 3's 2642px,
  which is the trade made for looking integrated instead of glued-on.
- `_side.png` and `_form.png` (clay) both show a real, distinct shoulder
  lobe between the head and the haunch, with the leg visibly emerging from
  it — the concrete target this pass set out for. `_front.png` shows the
  frog reading a touch broader through the shoulders, symmetric with how
  the haunch already reads from behind.
- `_top.png`: no visible change (the front legs are hidden under the head
  from directly above in both builds) — checked, not skipped.
- Footprint unchanged: `SIZE frog is 1.72 x 1.46 x 1.15` before and after,
  so this doesn't reopen Nick's earlier "frog is too big" finding.
- **In the real fight camera** (`state=3d`, `cinder_jackal`), rebuilt pass 7
  via `git stash` for a true before, then this pass, same camera. Full-frame
  diff is 1736px, of which 363 fall in a 180×180 crop centred on the frog
  (hunter0) and only 70 near the goblin (hunter1, unrelated — idle-animation
  drift); the rest is the jackal's own idle ember pulse, the same pattern
  every prior pass has seen. At the party-panel card-view size (the closest
  the fight camera gets to the frog), the shoulder thickening is visible in
  a direct crop comparison.
- **34px party portrait**: rebuilt (`portraits.py frog`). The 512px render
  genuinely differs (5737 of 262144 px), but downsampled to 34×34 the two
  are visually indistinguishable — this fix doesn't survive to portrait
  size, honestly reported rather than claimed. Kept the rebuilt `frog.png`
  anyway since it's now the accurate render of the current model, the same
  call pass 6/7 made.

**Score.** Silhouette 8→9: the front legs now break the outline the way the
haunch already does, verified in `_sil`, `_side` and the live fight camera,
not just claimed from the model. Proportion 8→9: the shoulder mass gives
the front legs their own presence instead of reading as afterthought lines
under the head — the model now has a matched pair of leg-masses (front and
rear) rather than one real one and one implied one. Held to 9, not 10, on
both: the change is real but modest (670px on the scoring silhouette,
smaller than pass 5's haunch win), and Hygiene did not improve alongside —
the tri overage grew again. **+2 total (41→43)** — clears the 42 hunter
stop line.

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model — see the Log line in
`design/agents/status/artist.md` for the result.

![[frames/artist/2026-09-23-frog-foreshoulder-sil-before-after.png]]
![[frames/artist/2026-09-23-frog-foreshoulder-side-before-after.png]]
![[frames/artist/2026-09-23-frog-foreshoulder-infight-before-after.png]]

## Where it stands, still open for the next pass

**43/50 — over the 42 hunter stop line.** `design/asset-loop.md`: "4 passes
done. Then report final score, the per-pass history, and the one thing you
would fix next" — this is pass 8, past the nominal 4-pass cap Nick already
lifted for this hunter specifically, and now also past the stop line, so
the honest call is: **stop passing `frog` unless a request or a fresh look
finds a real defect**, not chase 44+ for its own sake (the loop's own
"chasing 10 on nineteen characters is how the schedule dies"). The one
thing still open if someone does pick it back up: the back saddle/nostrils'
34px legibility pass 6 found and pass 7 partially closed (the toes) — still
unmoved, and this pass's own attempt-2 finding (a local surface calc
undersells occlusion from the scoring camera) applies to it too, so it
would need the same "try, look, iterate" approach rather than a single
computed fix.
