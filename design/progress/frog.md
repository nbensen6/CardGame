# frog — refinement log

Loop: `design/asset-loop.md`. **Stopped at pass 4 — 36/50.**

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 4 | 5 | 6 | 7 | 8 | **30** |
| 2 | 5 | 6 | 6 | 7 | 8 | **32** |
| 3 | 7 | 7 | 6 | 7 | 8 | **35** |
| 1-control | 6 | 7 | 7 | 7 | 8 | **35** |
| 4 | 7 | 7 | 7 | 7 | 8 | **36** |

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
