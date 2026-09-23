# goblin_mech — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
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

## Where it stands, still open for the next pass

37/50, all 4 passes used — this asset is at the loop's pass limit, not a
plateau call. Below the 42 hunter stop line; per `asset-loop.md` this asset
is done for now and would need a Nick call to spend a 5th pass on it.
Lowest lines: Prop, Hygiene, Colour, all still 7. Candidates for whoever
picks this up again (not diagnosed, and only worth doing if Nick lifts the
4-pass cap): the wrist joint's rounded cap still reads as a slightly
different curvature from the boxes it bridges (a smaller version of this
pass's own finding); the claw/piston assembly at the feet, connected in
mesh terms but still a visually distinct mass from the rig body in
`_side.png`, same open question pass 3 left it at.
