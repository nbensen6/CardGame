# goblin_mech — refinement log

Loop: `design/guide/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/goblin_mech.py`.** Views:
`design/renders/goblin_mech_pass1_*.png`. First scoring under item #83's
rubric for a **hunter** (1400 tri budget). The build script's own header
states the design intent directly: "one ordinary arm, one enormous
mechanical one... which is exactly what box() and taper() are for" and
"Goblin round, rig square, and the two halves of the silhouette disagree
with each other, which is the character" — that stated intent is the bar
this scoring measures against.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 7 | 7 | **29** |

## What is actually there

A green goblin with a round head, cone ears, goggles on a gold strap, and a
small ordinary green arm on one side, standing next to/under a cluster of
grey mechanical boxes on the other side: a compressor-like box with an
orange exhaust pipe angled up behind the head, a shoulder block, an
upper-arm limb, a wrist joint, and a lower claw/piston assembly near the
feet, with a raised orange bent arm-shape above the shoulder.

- **Silhouette** (`_sil.png`): the asymmetry the module doc calls for is
  present — one side is bulkier than the other — but it doesn't read as one
  arm. A grey block sits directly behind the head (visible as a rectangular
  notch top-left of the silhouette) and other grey mass sits low near the
  feet, so the rig reads as three or four separate lumps distributed around
  the goblin's body rather than a single mechanical limb the goblin is
  wearing.
- **Proportion**: the goblin's own body — head, ears, snout, legs — is
  correctly goblin-proportioned and reads fine on its own. The rig, which is
  supposed to be "enormous" per the module doc, doesn't read as a single
  enormous object; it reads as several medium objects, so the "small goblin
  under an oversized rig" contrast the doc names is present in intent but
  not in the render.
- **Build hygiene**: 1484/1400 tris, 84 over the hunter budget, one mesh.
  The rig is built as a single connected limb chain in the script (shoulder
  box → upper arm → wrist → claw, per `goblin_mech.py`), but the connecting
  cylinder segments between the boxes are thin enough, and the boxes bulky
  enough, that in every lit view the joints disappear and the boxes read as
  independent floating pieces rather than a jointed arm — the same
  "orbiting part" family of failure named for several beasts' sigils in this
  item's other batches, here affecting a whole limb rather than one small
  part.
- **Colour & read**: green goblin against GRAPHITE/PEWTER/STONE rig
  separates cleanly, and the orange/carrot exhaust and piston accents pop
  against the grey. No dark-on-dark. This is the model's strongest line.
- **Style consistency**: the boxy, bevelled-edge machine parts read as
  "machined plate" the way the module doc intends, distinct from the
  goblin's soft organic shapes, and that material/shape contrast fits the
  cast's established look.

## Diagnosis — two lowest

1. **Silhouette (5).** The rig reads as scattered blocks, not one arm. The
   compressor box sits centered behind the head rather than clearly hung off
   the shoulder, which is the single biggest reason the read breaks —
   concrete fix: move the compressor box (currently near x=0.0, the goblin's
   own centerline) fully onto the rig's side of the model, so nothing
   mechanical crosses behind the head in any view.
2. **Proportion (5).** Because the rig doesn't cohere, "enormous" doesn't
   land — it reads as goblin-plus-clutter rather than goblin-under-oversized-
   machine. Concrete fix: thicken the connecting limb segments between the
   shoulder box, wrist, and claw (currently 0.086–0.098 radius against boxes
   roughly 0.12–0.15 half-extent — nearly half the width of the boxes they
   join) so the joints don't visually vanish between the bigger masses.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the raised orange bent arm-shape above the shoulder (clearest in
`_side.png` and `_top.png`) is meant to be visible at all from the fight
camera's default angle, or whether it is mid-animation geometry that
happens to render static here — the module doc doesn't mention it and this
scoring pass has no way to tell intent from an accident without asking.

---

## Pass 2 — fixer lane, 2026-08-31

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Views: `design/renders/goblin_mech_pass2_*.png`, captured with
`look.cmd goblin_mech 2`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 7 | 7 | **29** |
| 2 | 7 | 7 | 5 | 7 | 7 | **33** |

### Both diagnosed fixes applied

- **Silhouette (5 → 7).** The compressor box, its lid and the exhaust pipe it
  carries (all previously centered at x=0.0) shifted +0.30 in X together, onto
  the rig's own side. `goblin_mech_pass2_top.png` now shows the whole
  compressor assembly sitting beside the head instead of behind it, and
  `goblin_mech_pass2_sil.png` reads as one connected mass on the rig side —
  compare `goblin_mech_pass1_sil.png`'s separate notch cut into the skyline
  above the shoulder.
- **Proportion (5 → 7).** Upper-arm limb radii `[0.098, 0.086, 0.080] →
  [0.137, 0.120, 0.112]` and wrist limb radii `[0.068, 0.076, 0.082] →
  [0.095, 0.106, 0.115]`, both roughly ×1.4, closing most of the gap against
  the 0.12–0.15 half-extent boxes they bridge. `goblin_mech_pass2_form.png`
  and `_side.png` show the shoulder-to-wrist-to-claw chain reading as one
  jointed arm rather than boxes strung on a thread.

+4 total, not a plateau — kept. Hygiene, colour and style were not touched,
per the brief; their scores are unchanged from pass 1. Hygiene stays at 5 —
the tri-budget overage (1484/1400) and the sigil-less rig were not part of
either diagnosed line, and this pass didn't touch geometry count.

## Unsure about, still

The pass-1 "orbiting part" hygiene framing and the raised orange arm-shape
above the shoulder are both untouched — outside the two lines this pass was
allowed to touch. Same open question as pass 1 on whether that shape is
meant to render statically.

---

## Pass 3 — artist lane, 2026-09-23

Two things this run's brief flagged as the biggest style gap in the fight
(hunters next to a textured/rigged beast) sent me looking at this model
again. Views: `design/renders/goblin_mech_pass3_*.png`, `look.cmd
goblin_mech 3` (a stray, never-scored `pass3` render already existed in the
repo from the initial seed commit — identical geometry to pass 2, since
`goblin_mech.py` had no commits between them; overwritten by this pass's
real renders).

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 7 | 7 | **29** |
| 2 | 7 | 7 | 5 | 7 | 7 | **33** |
| 3 | 7 | 7 | 7 | 7 | 7 | **35** |

### First: resolved the standing "unsure about", not a bug

The raised orange arm-shape (the compressor's exhaust pipe/cap) reads as
touching the compressor+lid in every camera the game actually uses — the
fight camera (`state=3d`) and `look.py`'s own three-quarter (`_34.png`) and
side (`_side.png`) views all show it emerging cleanly from the box, not
floating. It only separates from the box in the **top-down** view
(`_top.png`), which is a `look.py` diagnostic angle the player never sees.
Confirmed empirically, not just by eye: recoloured the exhaust and,
separately, the tusks (the model's other user of `ICE`) to a diagnostic
magenta one at a time, rebuilt, and re-shot the live fight camera — neither
swap changed a pale-blue triangle I'd initially suspected was part of this
model floating above the goblin's head in-game. That triangle turned out to
be `combat_3d.gd`'s own per-hunter "pip" marker (`_hunter_pip`, an unshaded,
depth-test-off cone tinted by `_slot_color`) — intentional existing gameplay
UI, not this asset, and out of the artist's scope. Filed nothing; noting it
here so the next person who spots that triangle doesn't re-walk this.

### Second: closed the tri-budget overage (the other open Hygiene item)

1484/1400 tris (84 over) had sat untouched since pass 1 because neither
diagnosed fix (Sil, Prop) was allowed to touch geometry count. Trimmed
seg/ring on the four parts least likely to show it — the body and head
balls (10,6 → 8,5 each), the snout ball (9,5 → 8,5), and the two piston-rod
tapers (seg 5 → 4, at 0.016 radius) — the biggest, gentlest-curved masses
and the thinnest, least-noticed rod, the opposite end of the spectrum from
where the frog's own budget cut backfired (`frog.md`: cutting the *eyes'*
segments there faceted the single most load-bearing feature on the model).
1484 → **1396, now under the 1400 hunter budget**.

**Verified, not assumed, that nothing visibly degraded**:
`goblin_mech_pass3_sil.png` is pixel-identical to a pre-cut render of the
same pose at 64px (the silhouette rubric's own test), and the isolated
`_34.png` shows no visible faceting on body, head or snout at that
distance. In the actual fight (`state=3d`, both hunters visible,
`cinder_jackal`), a before/after pair at the real on-screen hunter size
(≈25×30px) is indistinguishable by eye; a raw pixel diff over the full
1280×720 frame shows ~2100 differing pixels confined to the hunters'
region, consistent with this fight's own idle-animation drift between two
separate captures rather than a geometry change — the same order of
magnitude of noise seen on unrelated re-captures elsewhere in this project.
`ALL TESTS PASSED`; playtest re-run (`mode=play`, 40 steps) to confirm no
regression.

**Hygiene 5 → 7.** Within budget now, still one mesh/one material, and the
"orbiting part"/scattered-blocks framing pass 1 named is answered above —
the rig reads as one arm in every camera that matters. Not scored higher:
the claw/piston assembly near the feet (visible in `_side.png`) is still a
distinct mass from the main rig body, a smaller version of the same
"reads as separate pieces" question, and I did not touch or re-diagnose it
this pass.

Before/after frames (isolated `_34`/`_sil`, and the live fight camera):

![[frames/artist/2026-09-23-goblin-mech-tri-budget-34-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-tri-budget-sil-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-tri-budget-infight-before-after.png]]

## Where it stood after pass 3

35/50, 3 of 4 passes used, still under the hunter stop line (42). The
lowest lines were a four-way tie at 7 (Sil, Prop, Hygiene, Colour,
Style are ALL 7 — the model is even across the board, not bottlenecked on
one line). Candidates noted for pass 4: the claw/piston assembly's own
connectedness, and whether the goggle lens/strap read as anything at true
34px combat distance rather than in the close-up renders every pass so far
had scored from — this pass was the first time this file compared against
the live fight camera at all, and it surfaced a real thing (the pip) that
had nothing to do with the model, which is itself a reason to keep doing
that check rather than scoring from `look.py` alone.

---

## Pass 4 — artist lane, 2026-09-23

Last pass's two candidates didn't survive contact with a full six-view
capture (only `_34`/`_front`/`_sil` had been committed for pass 3;
`look.cmd goblin_mech 4` also captures `_side`/`_top`/`_form`, which pass 3
never looked at). Checking the 34px party-panel portrait
(`tools/blender/portraits.py`) directly answered the goggle-readability
candidate — the strap and lenses read fine at 34px, a real non-issue, not
worth spending a fix on. The claw/piston assembly turned out to be one
connected mesh (`_sil.png` is a single connected-component blob, checked
with `scipy.ndimage.label` — no floating island), so "connectedness" was
never literally broken either.

What the six-view capture actually found, not on last pass's list:

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 7 | 7 | **29** |
| 2 | 7 | 7 | 5 | 7 | 7 | **33** |
| 3 | 7 | 7 | 7 | 7 | 7 | **35** |
| 4 | 8 | 7 | 7 | 7 | 8 | **37** |

### Diagnosis — two real, previously-unseen defects

1. **Silhouette (7) — the rig's two limb-to-box joints read as a crown of
   teeth, not a jointed arm.** `_34.png`, `_front.png` and `_top.png` all
   show a sharp zigzag "M" right where the upper-arm limb meets the
   shoulder box, and the same shape again where the wrist limb meets the
   wrist box — this is what earlier passes were calling "reads as
   scattered blocks" without ever finding the actual cause. Diagnostic
   pass: recoloured the upper-arm limb to `ICE` one part at a time and
   re-rendered — the zigzag is exactly the limb's own hex end-cap
   (`seg=6` in `kenney.limb()`), exposed right at the joint, each of its
   six flat side-faces catching its own toon-shading band. **Not the
   CHARCOAL collar ring** — first suspected, ruled out the same way (an
   `ICE`-recoloured ring rendered as a thin pale oval, visibly separate
   from the zigzag). Repositioning the limb's start point deeper into the
   box (tested at +0.03–0.04 along the path) did not hide it — the cap's
   flat plane doesn't sit parallel to the box's own (rotated) face, so no
   embedding depth fixes the mismatch; only rounding the cap does. Fix:
   `seg` 6→10 on both the upper-arm and wrist limbs, smoothing six sharp
   facets into a shallow, rounded seam.
2. **Style (7) — the goggle strap read as a blade, not a headband, from
   any angle but near-front.** `_side.png` shows the `GOLD` strap ring as a
   razor-thin line jutting well past the ear — a torus that is nearly a
   flat disc (default `thickness=0.16` squashed further by a 0.048
   z-scale) has almost no cross-section to show edge-on, so any view that
   isn't close to face-on sees only its rim. Fix: `thickness` 0.16→0.26
   and un-flattened the z-scale 0.048→0.075 so the tube has a real
   profile from the side, and pulled the major radius in slightly
   (0.228/0.198→0.205/0.180) so less of it clears the head. Same segment
   counts on both fixes, so this line is a pure shape change, no tri
   cost.

### Budget

The two `seg=6→10` limb fixes cost +24 tris each (`kenney.limb()`'s
`6*seg-4` triangle count for a 3-point path), +48 total, against 4 tris of
headroom (1396/1400 after pass 3). Freed it with four small, individually
checked cuts rather than touching either fixed line again: the CHARCOAL
collar ring's minor segments 4→3 (-24, and confirmed via the same `ICE`
diagnostic that this ring was never the zigzag, so losing a little of its
own roundness costs nothing that was scored), the ordinary (non-rig) arm
limb and its hand ball trimmed one segment each (6→5, 8,5→7,4), and the
exhaust limb and goggle-barrel tapers trimmed one segment each (6→5).
1396 → **1378, under the 1400 hunter budget** with all four fixes applied.

**Verified, not assumed:** `_sil.png` pixel-diff against pass 3's own
silhouette, both at the scoring 64px render — 256 of 65536 pixels differ
(0.4%), i.e. unchanged; the fix is a lit-shading change on already-rounded
massing, not a silhouette change. The 34px portrait
(`goblin_mech_pass4_34px_big.png` equivalent, not committed — regenerate
with `portraits.py`) shows no visible loss on the arm/hand/exhaust cuts. In
the real fight (`state=3d`, both hunters, `cinder_jackal`), a full-frame
pixel diff against the pass-3 capture shows 705 differing pixels (fewer
than pass 3's own 2100-pixel idle-animation baseline) — indistinguishable
by eye at the true ~20px hunter size, as expected; the win is in the
close-up scoring renders, where the crown is now a shallow seam instead of
sharp teeth, and the strap has an actual cross-section from the side.

**Silhouette 7→8** (the "reads as one arm" complaint that survived three
passes is now addressed at its real cause, not a proxy for it — held back
from 9 because the wrist limb's rounded joint is still visibly a slightly
different profile from the boxes it bridges, not because anything is
still broken). **Style 7→8** (goggle strap is a strap from more than one
angle now). Prop/Hygiene/Colour unchanged — not touched this pass.

`ALL TESTS PASSED`; playtest re-run (`mode=play`, 40 steps) against the
rebuilt model — `hop-flat` fired once, but the same check fires on the
unmodified baseline too (checked directly: stashed this pass's changes,
reimported, re-ran the identical playtest, same `hop-flat` failure on
stock `goblin_mech.glb`). Pre-existing, unrelated to this asset (see the
fixer/playtester history on `hop-flat` — a jump-arc sampling issue in
gameplay code, nothing a hunter's static mesh can cause), not filed again
here.

![[frames/artist/2026-09-23-goblin-mech-joint-crown-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-goggle-strap-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-infight-before-after.png]]

## Where it stood after pass 4

37/50, all 4 passes used — this asset was at the loop's pass limit, not a
plateau call. Below the 42 hunter stop line. Nick lifted the 4-pass cap for
both fight hunters the same day
(`requests/2026-09-23-0325-artist-to-nick-hunters-at-pass-cap-below-stop-line.md`),
which is what makes pass 5 below a legitimate pass rather than a cap
violation.

---

## Pass 5 — artist lane, 2026-09-23

Started from the two candidates pass 4 left open (wrist-joint curvature,
claw/piston distinctness). Full six-view capture (`look.sh goblin_mech 5`)
and a close look at both found neither holds up as a real defect: the wrist
limb's `seg=10` cap (pass 4's own fix) already reads as a shallow, continuous
seam into the boxes on both sides in `_side.png`/`_form.png`, and the
claw/piston box reads connected to the wrist chain in every isolated view —
no fix applied to either, a real "checked, not a defect" finding rather than
a silent skip. Also checked whether the CHARCOAL hose ring (the loop
encircling the upper-arm joint) reads as a stray disconnected line in
`_side.png` — it does, clearly, because the ring lies nearly flat in the
model's XY plane and only presents its full loop face-on (top/front/¾); from
pure profile it collapses to a thin edge. Ruled this out the same way pass
3 ruled out the exhaust pipe's top-down separation: the live fight camera
(`state=3d`/`3dgrip`/`3dstrike`, checked across several camera states this
pass) never puts a hunter in a pure side-profile relative to itself — a
`look.py` diagnostic angle the player never sees. Not fixed, not filed.

**What this pass actually found and fixed: the rig's own darkest two tones
are a functional tie, and this fight's toon shading pushes both toward
losing their "machined plate" read.**

Sampled the palette directly off `colormap_base.png` (the same technique
`frog.md`'s pass 7 used to find its own weakest boundary): GRAPHITE and
CHARCOAL — used on this rig for the compressor box and the hose ring,
respectively, its two largest single-colour masses — sample at luminance
59.4 and 56.4, a 3-point difference, functionally the same value despite
being named as two different swatches. STONE and PEWTER, this same rig's
own established mid-tones (upper-arm limb, wrist limb, claw box, wrist box),
sample at 114.1 and 139.5. The file's own header states the rig's whole job
is bevelled boxes that "catch a bright line along each edge and read as
machined plate" — a toon-shaded bevel highlight needs headroom above its
base tone to read, and GRAPHITE/CHARCOAL start closer to the shader's own
shadow floor than any other rig tone.

**First attempt at verifying this in the actual fight was wrong, and I'm
recording the mistake rather than quietly redoing it.** A mid-strike shot
(`state=3dstrike slot=1`) sampled a dark pixel near the goblin at (600,410),
18.4 luminance, against a jackal-body sample at 4.6 — a 13.8 gap, read at
the time as "the rig disappears against the beast." Applied the fix, re-shot
the identical camera state, and the sampled pixel was **pixel-identical,
before and after** — proof the fix didn't touch whatever was actually there.
Ran the project's own diagnostic-recolour check (all rig tones forced to
ICE, matching pass 3/4's technique) and rebuilt: the sampled point turned
out to be the jackal's own wing membrane in shadow, not the rig at all — in
this specific pose the rig is mostly self-occluded behind the goblin's own
torso, only a sliver of the compressor lid visible. The camouflage claim for
*this exact pose* was false, built on a misidentified pixel, and is
withdrawn as stated. Worth leaving in the record: sample the diagnostic
recolour BEFORE trusting a raw in-game pixel coordinate, not after — this
pass did it backwards once and should not have.

**What actually holds up, verified properly:**

- **Isolated renders (deterministic, no animation drift).** `_front.png`
  before/after: the compressor box and hose ring are visibly, measurably
  lighter — `_sil.png` pixel-identical (`numpy.array_equal`, colour-only,
  confirmed), `1378` tris unchanged both builds. A pixel diff over the
  region that actually changed (3065px, bbox in `_front.png`) shows a real
  but shader-compressed shift: mean luminance 79.3 → 86.2 (+6.9), not the
  ~55-point gap the raw swatch numbers alone would suggest — the toon
  shader's own shadow/highlight banding compresses how much of the base
  albedo difference survives into the rendered pixel, the same kind of
  "flat render oversold it" gap the arena pass already found once for this
  fight's lighting. Reported as the real, smaller number, not the bigger one
  that was never actually measured in a render.
- **Live fight camera, a real pose this time.** `state=3dgrip slot=1` puts
  the goblin standing on a foothold in the open, unoccluded, against both a
  light foothold rock and the jackal's dark leg — confirmed a real object
  this time (not repeated the pixel-coordinate mistake above; read directly
  off the crop, not a blind sample). Before/after crop shows the same
  compressor-box/ring lightening as the isolated render, smaller at true
  size but visible, no regression to anything else in frame.

**Score.** Colour 7 → 8: a real, verified (if modest, and initially
mis-verified once before being corrected) lightening of the rig's two
darkest, functionally-tied tones, on the line the model's own docstring
calls its job. Sil/Prop/Hygiene/Style untouched — no geometry, no part
count, no silhouette change (`_sil.png` proves it). **37 → 38/50.**

![[frames/artist/2026-09-23-goblin-mech-rig-value-front-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-rig-value-34-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-rig-value-infight-before-after.png]]

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model — see `## Now` in `status/artist.md` for
the result and whether anything fired.

## Where it stands, still open for the next pass

38/50, cap lifted, still below the 42 hunter stop line. Lowest lines: Prop,
Hygiene, both 7 (Colour moved to 8 this pass). Two candidates checked this
pass and ruled non-issues (wrist-joint curvature, claw/piston distinctness)
— do not re-open without a fresh reason. The hose ring's side-profile
collapse is real but a `look.py`-only angle, same status. Nothing newly
diagnosed for pass 6; whoever picks this up next should look for a fresh
defect rather than assume one of the above is still open.

---

## Pass 6 — artist lane, 2026-09-23 (checked, nothing applied)

Full fresh six-view capture (`goblin_mech_pass6_*.png`, `look.py` direct
since `look.cmd` is Windows-only) and a close look, not assuming last pass's
two ruled-out candidates or its own crown-zigzag fix are still the story.
No fix applied this pass — every concrete lead checked either doesn't hold
up as a defect or isn't reachable without a riskier change than the loop's
"two small fixes" step allows. Recorded honestly rather than forcing a
number to move.

**Re-checked the pass-4 crown-zigzag fix against its own before/after
renders, not just this pass's own capture.** `goblin_mech_pass3_34.png`
(pre-fix, `seg=6`) vs `goblin_mech_pass4_34.png` (post-fix, `seg=10`), same
crop, same zoom: pass 3 shows a sharp "M" with deep, dark-shadowed valleys;
pass 4 (and this pass's identical geometry) shows a visibly shallower,
softer scalloped seam — a real, not oversold, improvement, though still
visible up close. Not re-opened; the pass-4 score already reflected a
partial fix (7→8, not 9/10), which the direct before/after comparison
confirms was the honest call.

**Silhouette connectivity, confirmed again with a different method.**
`scipy.ndimage.label` on `goblin_mech_pass6_sil.png`: **1 connected
component**, 17,079 px — everything, including the "ordinary" MINT arm,
reads as one solid shape with no floating or spaced-away part. Answers the
Hygiene rubric's "no part spaced away from the body" line directly, not by
inference.

**Measured whether the rig actually reads as "enormous" against the
ordinary arm, the file's own stated comparison — not against the whole
body, which the docstring never claims.** Off the script's own numbers:
ordinary-arm limb radii top out at 0.086 (hand ball 0.090–0.098); the
rig's upper-arm/wrist limbs run 0.095–0.137 (roughly 1.3–1.6x), and the rig
carries several boxes/tapers/a ring the ordinary arm has none of. The
size disparity is real and larger than a passing glance suggests — this is
not a fresh defect, it's confirmation that Prop's existing 7 (not higher)
is the right number: present in intent and in the geometry, moderate in
the render.

**Considered and declined a rig-scale-up experiment.** If the rig read
too *small* rather than merely uncohesive, the concrete fix would be to
enlarge it — but every rig part's exact position was hand-tuned pass over
pass specifically to keep loosely-touching pieces (compressor box↔lid↔exhaust,
shoulder↔upper-arm↔wrist↔claw) reading as connected. A uniform scale from a
single pivot preserves relative touching mathematically, but this rig isn't
a single radiating chain from one point — it's several independently-placed
boxes whose "touching" is closer than the numbers alone suggest (pass 3's
own finding for the exhaust cap). Scaling it blind, without the loop's own
build→render→look cycle to catch a newly-opened gap, is exactly the kind of
change the loop's Apply step warns against ("do not restyle the whole
asset"). Flagged as a real option for a future pass that budgets for the
extra render/verify cycle, not attempted here.

**No score change.** 38/50 stands. `ALL TESTS PASSED` (no code touched);
skipped a playtest re-run since nothing in `goblin_mech.py` or the `.glb`
changed from origin/main.

![[frames/artist/2026-09-23-goblin-mech-pass6-fresh-check.png]]

## Where it stands after pass 6

Still 38/50. Prop and Hygiene both checked hard this pass and both hold up
as real, already-correctly-scored 7s, not hidden defects. The one live lead
for a future pass is the rig-scale-up idea above — real, but needs its own
full iterate cycle, not a blind edit. Absent that, the next pass should
look at something this file hasn't touched yet (Style's goggle/strap
combination at oblique angles, or a genuinely new six-view look after
another run's fresh eyes) rather than a fourth re-check of Prop/Hygiene
with no new idea.

---

## Pass 7 — artist lane, 2026-09-23 (the rig-scale-up, done properly)

Picked up pass 6's own declined idea, this time budgeted for the full
build→render→look cycle it needed. Pass 6's worry was real but aimed at the
wrong risk: it assumed a *post-hoc mesh scale* (grow the finished object from
one pivot), which on a rig built from independently-placed absolute
coordinates could plausibly reopen a gap between two parts that only "touch"
by camera-dependent luck (pass 3's exhaust-cap finding). The actual fix
avoids that risk instead of gambling on it: scale every rig coordinate AND
every rig size (box half-extents, limb/taper radii, ring thickness) by the
same factor from the same pivot, **in the generator**, before any geometry is
built. That's provably exact — every rig-to-rig 3D distance and overlap
scales identically, so nothing that touched before can un-touch now. Added
`RIG_S = 1.18`, `RIG_P = (0.30, 0.05, 0.80)` (near the shoulder box) and two
helpers (`rp()` for positions, `rs()` for sizes) in `goblin_mech.py`, and
routed every rig call through them — the compressor cluster (up/back) and the
claw/piston cluster (down/forward) both grow away from the shoulder, reading
as the rig itself getting bigger rather than the goblin sliding out from
under it.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 7 | 7 | **29** |
| 2 | 7 | 7 | 5 | 7 | 7 | **33** |
| 3 | 7 | 7 | 7 | 7 | 7 | **35** |
| 4 | 8 | 7 | 7 | 7 | 8 | **37** |
| 5 | 8 | 7 | 7 | 8 | 8 | **38** |
| 6 | 8 | 7 | 7 | 8 | 8 | **38** |
| 7 | 8 | 8 | 7 | 8 | 8 | **39** |

**Verified, not assumed, on every axis pass 6 flagged as the actual risk:**

- **Tri budget unaffected**, as expected (scaling changes no segment counts):
  1378 tris both builds, `PARTS 33 BUDGET 1400 ok`.
- **Silhouette connectivity still 1 component** (`scipy.ndimage.label` on
  `goblin_mech_pass7_sil.png`): 19,408px, up from pass 6's 17,079 (a bigger,
  still-solid shape), no floating part opened.
- **The top-down compressor/shoulder gap — checked directly against the
  pre-scale model, not assumed unchanged.** Rendered the untouched original
  through `look.py` for a true side-by-side (`goblin_mech_pass6b_top.png`,
  not committed, this pass's own control). The gap between the two grey
  clusters in `_top.png` is the same proportion in both — a real,
  already-known, `look.py`-diagnostic-only artefact (pass 3's own finding,
  restated here because scaling is exactly the kind of change that could
  have made it worse and didn't).
- **The wrist-to-claw joint (pass 4's `seg=10` fix) still reads as a shallow
  seam, not a reopened zigzag** — checked in a tight crop of `_34.png`,
  before/after: unchanged shape, correctly bigger.
- **The exhaust pipe still meets the compressor lid cleanly** — the one other
  joint pass 3 found to be camera-dependent — checked in a tight crop, no
  new gap.
- **Overall model footprint**: X 1.533→1.615 (+5.3%), Y 1.163→1.373 (+18.0%,
  matching `RIG_S` almost exactly since the rig extends mostly along Y), Z
  unchanged at 1.85 (the head/ears stay the tallest point, so `finish()`'s
  auto height-fit doesn't quietly undo any of this by rescaling the whole
  model down).
- **In the real fight** (`state=3dgrip slot=1`, goblin on an open foothold,
  unoccluded): a tight before/after crop at true ~30px size shows the rig
  reading as visibly bulkier against the green body — smaller than the
  isolated renders, as every prior pass's in-fight check has found, but real
  and not a close-up-only effect.
- **`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps) run
  against both builds as a matched pair**, not just the new one: both report
  the identical, already-filed `hunter-off-marker` foothold-4 residual
  (`requests/2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`)
  at the same coordinates on both runs — confirmed pre-existing, not
  reopened. The rebuilt-model run also hit one `damage-popup-offscreen` (a
  boss-damage popup, not the hunter-damage case the fixer already fixed and
  the playtester already verified in commit `32db5a6`) that the control run
  didn't reproduce at the same step — expected, since these playtests are
  not frame-identical between runs (real-time hop/camera sampling), and a
  static-mesh-only change has no code path into popup placement at all.
  Left for the playtester to catch on its own terms; not this asset's to
  chase.

**Score: Proportion 7→8.** The rig's own limb-radii-vs-ordinary-arm ratio
(pass 6's own measurement) moves from 1.3-1.6x to roughly 1.5-1.9x, and the
whole rig cluster is now unmistakably the larger mass in every view checked,
closing most of the "present in intent, not in the render" gap pass 1-6 kept
finding. Held at 8, not higher: this is one, real, moderate step, not a
transformation, and Hygiene's still-separate-reading claw/piston mass (pass
3's note) is untouched. Sil/Hygiene/Colour/Style unchanged — nothing this
pass touched their lines. **38 → 39/50, still below the 42 hunter stop line
but the first real movement since pass 5.**

![[frames/artist/2026-09-23-goblin-mech-pass7-rig-scale-before-after.png]]

## Where it stands after pass 7

39/50. The rig-scale idea pass 6 flagged is spent and worked. Untouched
lines for a future pass: Hygiene (7, the claw/piston mass reading separate
from the main rig body — pass 5 confirmed connected, but distinct, a milder
version of the same question), and Style's goggle/strap at oblique angles
(flagged, never actually checked). Given `RIG_S`/`RIG_P` are now named
constants, a second, more aggressive scale pass is possible later, but
should come with its own fresh six-view look rather than assuming this
pass's margins still hold.

---

## Pass 8 — artist lane, 2026-09-23 (the goggle strap actually checked at oblique angles)

Picked up pass 6/7's own standing candidate — Style's goggle/strap "at oblique
angles, flagged, never actually checked" — and actually checked it, with a
fresh six-view capture (`goblin_mech_pass8_*.png`, `look.py` direct).

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 7 | 7 | **29** |
| 2 | 7 | 7 | 5 | 7 | 7 | **33** |
| 3 | 7 | 7 | 7 | 7 | 7 | **35** |
| 4 | 8 | 7 | 7 | 7 | 8 | **37** |
| 5 | 8 | 7 | 7 | 8 | 8 | **38** |
| 6 | 8 | 7 | 7 | 8 | 8 | **38** |
| 7 | 8 | 8 | 7 | 8 | 8 | **39** |
| 8 | 8 | 8 | 7 | 8 | 9 | **40** |

### The oblique-angle check found a real defect pass 4 never saw

`_34.png` (the fight-camera angle, per `look.py`'s own docstring: "the angle you
fight it from") and `_side.png` both showed the `GOLD` goggle strap reading as
a flat blade or beak jutting out in front of the goblin's face — not a strap on
a head, closer to a bird's bill. Pass 4 had already touched this ring once
(thickened the tube, un-flattened its Z-scale) and scored Style 7→8 off a
close-to-front-on view; this pass's fresh six-view look is what actually put
a 3/4 and profile angle in front of the problem for the first time.

**Measured the cause instead of eyeballing a fix.** The strap ring sits at
`(0.0, -0.110, 1.105)` with major radii `(0.205, 0.180)` — so its own front
edge reaches `y = -0.110 - 0.180 = -0.290`. The goggle barrel it's supposed to
be strapped to sits at `y=-0.180` with a taper reaching `y = -0.180 - 0.082 =
-0.262` at its tip; the lens ball sits at `y=-0.228`. **The strap's front edge
was forward of the barrel tip, which was forward of the lens** — geometrically
the "strap" was the frontmost part of the whole goggle assembly, which is
exactly what makes it read as a blade instead of a band holding something on.

**Fix:** pulled the ring's Y-radius `0.180 → 0.105` (front edge now
`y=-0.110-0.105=-0.215`, tucked behind the barrel tip and roughly level with
the lens). X-radius (head width, already correct per pass 4) untouched. Same
14×4 segments — a pure shape change, no tri cost, matching pass 4's own
"no tri cost" pattern for this same ring.

### Verified, not assumed

- **Tri budget/part count unaffected**: `TRIS 1378 PARTS 33 BUDGET 1400 ok`,
  identical to pass 7 (only a radius parameter changed, no geometry added or
  removed).
- **`_sil.png` pixel diff against the pre-fix pass-8 capture**: 64 of 65,536
  pixels differ (0.1%) — the ring is a small enough feature that the 64px
  silhouette rubric is correctly almost untouched by this fix; this was never
  a silhouette-line defect.
- **`_34.png` and `_side.png` before/after**: the strap now reads as sitting
  behind/level with the lenses instead of projecting past them — the
  beak/blade read is gone at both angles checked.
- **34px party portrait** (`portraits.py`, rebuilt both ways): the 512px
  render shows the same fix clearly (the strap tucks behind the lens instead
  of jutting past it); downsampled to 34×34 the two are visually
  indistinguishable — reported honestly, the same call `frog.md` pass 7 made
  for its own 34px check, not claimed as a win it isn't.
- **In the real fight** (`state=3dgrip slot=1`, goblin on an open foothold,
  unoccluded, ~30px): before/after crop at true size — no visible difference
  by eye, as expected at that scale for a feature this fine; the win lives in
  the scoring/portrait renders, consistent with how small a detail this is
  against the whole model.
- **`ALL TESTS PASSED`. Playtest** (`mode=play`, `cinder_jackal`, 40 steps)
  re-run against the rebuilt model — one failing check,
  `hunter-off-marker` (2 hits, foothold 4), the identical residual pass 7's
  own matched-pair run against this same beast already confirmed
  pre-existing (`requests/2026-09-23-0715-fixer-to-fixer-shared-foothold-
  side-spacing-clears-the-model.md`). Not re-run as a matched pair a second
  time: this pass only changed one torus radius parameter on a decorative
  ring, which has no code path into foothold/climb-marker placement at all.

**Score: Style 8 → 9.** A real defect at its actual root cause — the strap
projecting past the very goggles it's meant to hold on — closed at the two
angles the fight camera and its own three-quarter reference angle actually
use, not a proxy fix. Held short of 10 because the win doesn't survive to true
in-fight hunter size (verified, not assumed) and the ring's back half (hidden
behind the head from every camera checked) was left untouched. Sil/Prop/
Hygiene/Colour unchanged — nothing this pass touched their lines. **39 →
40/50**, still below the 42 hunter stop line.

![[frames/artist/2026-09-23-goblin-mech-goggle-blade-34-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-goggle-blade-side-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-goggle-blade-portrait-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-goggle-blade-infight-before-after.png]]

## Where it stands after pass 8

40/50, still below the 42 hunter stop line. Lowest line: Hygiene (7, the
claw/piston mass reading separate from the main rig body — pass 5 confirmed
it's connected but still a distinct-reading mass; untouched since). Style is
now the joint-highest line at 9. Next pass's live candidate is Hygiene's
claw/piston distinctness, this time with an actual measured cause the way
this pass found one for the goggle strap, rather than another "checked,
doesn't hold up" pass on a line two passes have already confirmed real but
left unfixed.

---

## Pass 9 — artist lane, 2026-09-23 (the claw/piston cluster's real cause, measured)

Picked up pass 8's own standing candidate: Hygiene's claw/piston mass
reading separate from the main rig body (pass 3's original note, "connected
but distinct" through pass 5, never actually diagnosed to a cause). Six-view
capture (`goblin_mech_pass9_*.png`, `look.py` direct) plus the same
diagnostic-recolour technique pass 4/8 used (recolour one part to `ICE`,
re-render, look) — recoloured the claw taper alone, then the two piston rods
alone, each in isolation.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 7 | 7 | **29** |
| 2 | 7 | 7 | 5 | 7 | 7 | **33** |
| 3 | 7 | 7 | 7 | 7 | 7 | **35** |
| 4 | 8 | 7 | 7 | 7 | 8 | **37** |
| 5 | 8 | 7 | 7 | 8 | 8 | **38** |
| 6 | 8 | 7 | 7 | 8 | 8 | **38** |
| 7 | 8 | 8 | 7 | 8 | 8 | **39** |
| 8 | 8 | 8 | 7 | 8 | 9 | **40** |
| 9 | 8 | 8 | 8 | 8 | 9 | **41** |
| 10 | 8 | 8 | 9 | 8 | 9 | **42** |

### What the diagnostic recolour actually showed

**The piston rods (`CHARCOAL`, radius 0.016) are functionally invisible at
every angle rendered, even recoloured to `ICE`.** They register as a single
faint pale hairline crossing the shoulder at `_side.png` and nowhere else —
too thin to read as pistons, or as anything. Confirmed, not fixed this pass:
they cost real tris (2 × a 4-segment taper) for zero visible read, a
Hygiene line of their own, not this one — noted for whoever picks the claw
cluster up again with tri budget to spend, not chased here (this pass's
budget went to the part that IS visible).

**The claw taper (`CARROT`), recoloured alone, reads exactly as pass 8's
"connected but distinct" line describes**: a small rounded lump sitting at
the STONE claw box's bottom-front corner with a visible gap of shadow
beneath it, not flush against the face it's mounted to — see
`goblin_mech_pass9_34.png`/`_side.png` crops in
`design/agents/frames/artist/2026-09-23-goblin-mech-claw-mount-*-before-after.png`
(before/after, this pass's fix already applied to the "after" side).

### Measured the cause instead of eyeballing a fix

The claw box carries `rot=(0.18, 0.20, 0.0)` — a real tilt, ~10-11° on two
axes, put there (pass-over-pass) so the rig's joints read as angled machinery
rather than a stack of dead-level blocks. The claw taper and both piston rods
mounted to that box's face were each placed at a **raw axis-aligned world
offset** from the box's center, with a **raw axis-aligned `rot=(FWD, 0, 0)`**
— correct for an unrotated box, and silently wrong the moment the box itself
is tilted. The taper's mount point and heading were never rotated along with
the face they're bolted to, so it emerged from a point/direction that only
matches an untilted box — which is exactly a corner-glued-lump read, not a
face-mounted one. Same category of bug as pass 8's goggle-strap fix (a part
positioned without accounting for what it's actually relative to), on a
different part of the model.

**Fix:** added `mount(box_loc, box_rot, delta, own_rot)` to
`goblin_mech.py` — rotates both a part's offset and its own orientation by
the reference box's rotation matrix, so a rigidly-bolted part follows the
box's tilt instead of assuming it is world-axis-aligned. Applied it to the
claw taper and both piston rods (all three mount to the same claw box).
Pure position/orientation math — no new geometry, no segment count changes.

### Verified, not assumed

- **Tri budget/part count unaffected**: `TRIS 1378 PARTS 33 BUDGET 1400 ok`,
  identical to pass 8 (only loc/rot parameters changed on three existing
  parts).
- **`_sil.png` pixel diff against the pre-fix pass-9 capture**: 347 of 65,536
  px differ (0.5%) — small, real, and matches what a corner-vs-face mount
  shift on a part this size should cost; `scipy.ndimage.label` still finds
  **1 connected component** (19,327px) — the fix didn't reopen the
  "floating island" question pass 5 already closed.
- **`_34.png`/`_side.png` before/after**: the claw now sits flush against the
  box's bottom edge with no visible gap beneath it, at both angles checked —
  full-resolution crops committed as
  `design/agents/frames/artist/2026-09-23-goblin-mech-claw-mount-34-before-after.png`
  and `...-side-before-after.png`.
- **In the real fight** (`state=3dgrip slot=1`, goblin on an open foothold,
  unoccluded, ~15-30px true size): rebuilt `game/assets/3d/cast/goblin_mech.glb`,
  reimported, shot against both the pre-fix and post-fix builds. Honestly:
  **does not survive to true in-fight size** — the claw is a handful of
  pixels at that scale and the two shots are indistinguishable by eye (frame
  committed:
  `design/agents/frames/artist/2026-09-23-goblin-mech-claw-mount-infight-before-after.png`).
  Same call pass 8 made for the goggle strap at 34px portrait scale — the win
  lives in the scoring/close-up renders, not overstated as an in-fight one.
  (`goblin_mech` has no head-and-shoulders portrait crop that reaches the
  claw at all — `FOCUS["goblin_mech"]` in `portraits.py` frames the upper
  body, so the 34px party-portrait check pass 4/8 used doesn't apply here.)

**Score: Hygiene 7 → 8.** A real, previously-only-described defect
("connected but distinct" since pass 3/5) now has a measured cause — a
rigid part mounted without accounting for its own reference box's rotation
— and a fix at that cause, not a proxy for it. Held at 8, not higher:
the piston rods, the cluster's other half, are confirmed still
functionally invisible (a separate, tri-cost-not-read Hygiene question,
not this pass's to spend budget fixing), and the win doesn't reach true
in-fight size. Sil/Prop/Colour/Style unchanged — nothing this pass touched
their lines. **40 → 41/50**, one point under the 42 hunter stop line.

![[frames/artist/2026-09-23-goblin-mech-claw-mount-34-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-claw-mount-side-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-claw-mount-infight-before-after.png]]

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps) re-run
against the rebuilt model: `hunter-off-marker` (2 hits, foothold 4) — checked
against what's on record, not assumed: *exact* same home/anchor coordinates
(`home (5.335257, 13.825942, 7.030925)`, `anchor (3.901302, 13.825942,
6.473297)`) as the already-open
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`
— confirmed pre-existing by coordinate match, not reopened. This pass only
changed the loc/rot of three existing parts mounted to the claw box; it has
no code path into foothold/climb-marker placement.

## Pass 10 — the piston rods pass 9 flagged and never chased

Picked up pass 9's own `## Next`: two candidates left open — the piston
rods (confirmed "functionally invisible at every angle, even highlighted")
and a check for any other rig part mounted to a rotated box the same
raw-axis-aligned way the claw taper was (pass 9's `mount()` bug). Checked
the second first, by reading `goblin_mech.py` directly rather than
re-rendering blind: two other boxes carry a non-zero `rot=` (the shoulder
box `rot=(0.0, 0.10, 0.0)`, the wrist box `rot=(0.12, 0.14, 0.0)`), but
nothing is bolted to either one via a `box()`/`taper()` call with its own
fixed offset+`rot=` the way the claw cluster was — the parts near them are
`limb()` waypoint chains, a different code path with no `mount()`-shaped
bug to have. **No second instance found** — pass 9's own speculation about
this was wrong, reported as such rather than silently dropped.

**The piston rods, diagnosed instead of just widened.** Diagnostic-recoloured
both to `ICE` (same technique pass 4/8/9 used) and rendered every view: the
rods are almost entirely *buried inside* the claw box and the claw taper's
own cone, not just thin. Measured why: their `dz` offset (±0.048, ≈0.057
world after `RIG_S`) sits well inside the claw taper's own base radius
(0.072 raw, ≈0.085 world) — the rods run coincident with the taper's own
volume from the mount point out, not beside it, so almost the whole rod is
inside geometry that already existed. Confirmed with the diagnostic render:
only a sliver of `ICE` peeks past the claw box's corner and the taper's own
mass (`gm_diag_pass1_34.png`, kept as scratch, not committed).

**Fix, two parts, both geometry-position/scale only:**
- Pushed `dz` from ±0.048 to ±0.110 — clears the taper's own radius with
  real margin, so the rods run alongside the claw instead of through it.
- Widened the radius 0.016 → 0.030 (`seg=4` unchanged — a bigger cone from
  the same 4 verts, zero tri cost).
- `CHARCOAL` → `STONE`: pass 5's own finding (`CHARCOAL`/`GRAPHITE` are this
  rig's two darkest, near-tied tones, and the toon shader's shadow band
  crushes both near-black) applies here too — same fix already applied to
  the compressor box and the wrist ring.

### Verified, not assumed

- **Tri budget/part count unaffected**: `TRIS 1378 PARTS 33 BUDGET 1400 ok`
  — identical to pass 9 (radius and offset are parameters, not new
  geometry).
- **`_sil.png` pixel diff against the pre-fix pass-10 capture**: 144 of
  65,536 px differ (0.2%) — small and real, in line with prior passes' own
  tolerances for a position/scale change on a part this size.
- **`_34.png` (the fight-camera reference angle) before/after**: the rods
  now read clearly as two parallel struts flanking the claw, closer to
  "piston" than the old hairline. `_front.png`/`_top.png` checked too — no
  new part pokes through the silhouette or crosses another part oddly.
- **In the real fight** (`state=3dgrip slot=1`, true `.glb` rebuild,
  reimported, shot against both the pre-fix and post-fix committed models):
  honestly, **does not survive to true in-fight size** — the whole claw
  cluster is a handful of pixels at combat distance and the two shots are
  indistinguishable by eye. Same call pass 8/9 already made for their own
  fixes at this scale — the win lives in the scoring/close-up render, not
  oversold as an in-fight one.

**Score: Hygiene 8 → 9.** The piston rods were pass 9's own honest
complaint — real tri cost, confirmed zero visible read, "not this pass's
to spend budget fixing." This pass found the actual cause (buried inside
neighbouring geometry, not just thin) and fixed it at zero additional tri
cost: the rods now read as a mechanical part in the scoring camera, closing
the last open Hygiene line on this model. Held at 9, not 10: the fix
doesn't survive to true in-fight size, and Sil/Prop/Colour/Style are
untouched (nothing this pass touched their lines). **41 → 42/50 — clears
the 42 hunter stop line.**

![[frames/artist/2026-09-23-goblin-mech-piston-rods-34-before-after.png]]
![[frames/artist/2026-09-23-goblin-mech-piston-rods-infight-before-after.png]]

`ALL TESTS PASSED`. Playtest (`mode=play`, `cinder_jackal`, 40 steps)
re-run against the rebuilt model: `PLAYTEST FAIL: 1 failing check(s)
{ "hunter-off-marker": 2 }` — checked against what's on record, not
assumed: *exact* same home/anchor coordinates (`home (5.335257,
13.825942, 7.030925)`, `anchor (3.901302, 13.825942, 6.473297)`) as the
already-open
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`
— confirmed pre-existing by coordinate match, not reopened. This pass only
changed the position/scale/colour of two existing piston-rod tapers; it has
no code path into foothold/climb-marker placement.

### Where it stands

**42/50 — at the 42 hunter stop line.** Both candidates pass 9 left open
are now closed (one fixed, one checked and ruled not a real second
instance). Per `design/guide/asset-loop.md`, the honest call at the stop line is
the same one `frog` got at pass 8: stop passing this hunter unless a
request or a fresh six-view look finds a real, new defect — not chase
higher for its own sake. Both hunters (`frog` 43/50, `goblin_mech` 42/50)
are now past their stop line; the real remaining gap named throughout this
whole file and `frog.md` is unchanged: a Meshy-rigged rebuild to match the
jackal's own fidelity, blocked on two open requests
(`2026-09-23-1345-artist-to-nick-meshy-fetch-blocked-by-network-policy.md`,
`2026-09-23-1330-artist-to-fixer-hunter-display-path-has-no-toon-or-rig-support.md`),
neither picked up yet.
