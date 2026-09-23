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
