# goblin_mech — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/goblin_mech.png`
(512x512). Batch 10 of #83; rubric defined in full in `frog_portrait.md`.
Rendered from the model as it stands after `goblin_mech.md`'s pass 2 fixer
pass (compressor box moved off the goblin's centerline, limb radii thickened)
— this portrait reflects that geometry, not the pass-1 render the earlier 3D
score describes.

## Score (pass 1)

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 7 | 5 | 8 | 8 | **34** |

## What is actually there

Three-quarter crop of a green goblin's head and upper torso: pointed ears, a
gold goggle-strap across the eyes, a small dark mouth/tusk mark, a brown
chest satchel with a diamond stitch mark, one raised orange ordinary arm at
top-right, and a cluster of dark-grey mechanical shapes (shoulder block,
jointed limb segments, a claw) filling the frame's right side.

- **Framing (7):** decent headroom above the ears and a clean torso crop at
  the bottom, but the raised orange arm crowds the top-right corner close to
  the frame edge, and there's a little unused white space at top-left that a
  small reframe could reclaim.
- **Identity (7):** the goblin face (ears, goggles, tusk mark) reads
  immediately, and "grey machinery on one side" is legible at full size — the
  pass-2 fix (box off the centerline) means nothing mechanical crosses behind
  the head here, matching what `goblin_mech.md`'s pass 2 reports. Docked
  because the rig itself doesn't read as a single arm the character is
  wearing, only as "goblin plus grey machine," which is the same "several
  medium objects, not one enormous one" proportion gap the 3D scoring named
  and pass 2 did not fully close.
- **Readability @ 34px (5):** confirmed via a real 34px downsample. The green
  head, orange raised arm, and brown satchel still separate, but the grey rig
  collapses into one dark, undifferentiated mass with no visible joints or
  boxes — worse than the 3D pass's "scattered blocks" read, since at this size
  it isn't even scattered, just a blob.
- **Colour & separation (8):** green goblin, orange arm/exhaust accents, brown
  satchel, and grey rig all separate cleanly at full size; no dark-on-dark
  pairing anywhere in frame.
- **Style consistency (8):** matches the shared three-quarter convention; the
  machined-plate rig against the organic goblin reads consistent with the
  cast's established material contrast.

## Diagnosis — two lowest

1. **Readability @ 34px (5).** Concrete fix: none available without touching
   the model (out of scope here) — the rig's boxes are close enough in value
   and small enough on-screen that no crop or framing change fixes this; worth
   flagging to Nick as a portrait-specific case where a fix that helped the
   3D silhouette (pass 2's box repositioning) didn't carry through to a
   readable 34px icon.
2. **Framing (7).** Concrete fix: nudge the crop left/down slightly so the
   raised orange arm has clearance from the top-right corner, recovering the
   unused space at top-left in trade.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the grey-rig collapse at 34px is a portrait-crop problem (the rig
occupies less relative frame area than the goblin, so it gets less pixel
budget) or would also affect the party-panel read of any future "elite"
character with a similarly busy attachment — no other scored portrait so far
carries a comparably detailed side-attachment to compare against.

## Pass 2 — cloud, backlog #86 duty 1

Before touching anything, re-rendered the committed asset from scratch
(`portraits.py`'s unchanged `FOCUS["goblin_mech"] = (0.67, 0.84)`, apt
Blender 4.0.2) and diffed it pixel-for-pixel against the actual PNG in the
repo: identical (mean/max diff 0), so this pass's own render pipeline is a
faithful stand-in for whatever built the committed file.

That render disagrees with this file's own pass-1 "what is actually there"
in one respect worth naming rather than silently overriding: pass 1 called
Framing's problem "the raised orange arm crowds the top-right corner" with
"unused white space at top-left." A real alpha-bbox measurement of the
committed PNG (Pillow, threshold alpha>128) says the more severe defect is
on the opposite side — `x: 0-447` on a 512 canvas, meaning the *ordinary
green arm's hand* is touching/clipped at the frame's **left** edge, not the
orange exhaust crowding the right. Both problems may be real (the exhaust
does sit close to the top-right too), but the hand clip is the one a fixed
crop can and should stop, so that's the one this pass targeted.

Applied the only one of the two named fixes that lives in `portraits.py`:
**Framing (7)**. `Readability @ 34px (5)` was explicitly diagnosed as
needing a model change (the rig's own box values, geometry not crop) — left
untouched, same as pass 1 flagged.

`FOCUS["goblin_mech"]` moved from `(0.67, 0.84)` to `(0.62, 0.94)` — `span`
widened first (0.84 → 0.94) to pull the left edge back from the clipped
hand, then `at` lowered (0.67 → 0.62) to claw back the extra headroom the
wider span added at top, landing close to pass 1's own top margin rather
than trading one imbalance for another. Found by direct measurement, not
guesswork: swept `span` alone first (0.84/0.94/2.0-for-reference), then
swept `at` at the fixed `span=0.94` in both directions and read the alpha
bbox after each render — decreasing `at` moved the *top* edge down (less
headroom), the opposite of the intuitive reading, so the initial "nudge
down" instinct from pass 1's diagnosis wording turned out backwards; the
measured sweep caught it before a wrong value was committed.

Alpha bbox (Pillow, alpha>128) is now `(16, 57, 486, 511)` on the 512×512
canvas, where pass 1 was `(0, 58, 447, 511)`: left margin went from 0
(clipped) to 16, right margin from 65 to 26 (tighter, but nothing near the
edge — the exhaust tip and shoulder box both sit clear in the render), top
margin essentially unchanged (58 → 57), bottom unchanged (511, the same
deliberate torso crop this file's pass 1 already called "clean").

Rebuilt the full 33-portrait set through `portraits.py` directly (no
per-asset build target exists) and reimported through Godot so the .scn
cache picks it up. Diffed every PNG against committed by mean/max
per-channel pixel difference: `goblin_mech.png` alone showed the intended
large diff (mean 35.5, max 255 — a real crop change); most others sat at
the same near-zero noise floor prior duty-1 passes measured (mean <1, max
≤~124). Three did not — `frog.png` (mean 58.2), `thrasher.png` (mean 0.91,
low enough to be noise on reflection), and `yoke_ox.png` (mean 2.62) — and
`frog.png` in particular rendered as a completely different image: an
extreme, mistaken close-up on one eye instead of the committed head shot,
reproduced twice in isolation with no other portrait touched, so it is a
real render-environment behaviour (apt Blender 4.0.2 disagreeing with
whatever built the committed file for this specific model/FOCUS
combination), not a flake. **Not investigated further here — out of scope
for a one-asset framing fix, and worth a duty-2 look, not a duty-1 one.**
All three were reverted along with the other 29 untouched portraits;
`goblin_mech.png` is the only portrait this commit changes.

- **Framing (7 → 9):** the hand clip is gone with real margin on the side
  that had none, and the top/bottom margins pass 1 already liked are
  preserved rather than traded away. Not a 10: the four margins are still
  uneven (16/57/26/0), just no longer touching on a side that shouldn't be.
- **Identity (7, unchanged):** same features, same relative sizes on
  screen; a wider crop with more headroom doesn't change what's readable.
- **Readability @ 34px (5, unchanged):** checked a fresh 34px downsample
  side by side with the old one (`design/renders/goblin_mech_portrait_
  pass2_34px_big.png` vs. the pre-fix render) — the rig still reads as one
  grey mass at this size, same finding as pass 1, no fix was applied for
  it and none was attempted.
- **Colour & separation (8, unchanged), Style consistency (8, unchanged):**
  neither palette nor geometry touched.

**+3 total (34 → 37), not a plateau — kept.** No line regressed.
Renders: `design/renders/goblin_mech_portrait_pass2_full.png`,
`_34px_big.png`, `_sil.png`. `run_tests.gd`: **ALL TESTS PASSED** (fresh
`--import`, headless, Godot 4.7.1).

## Unsure about (pass 2)

The `frog`/`thrasher`/`yoke_ox` render-environment finding above is the
useful open question this pass leaves: whether it is specific to those
three models (something about their geometry or `FOCUS` values Blender
4.0.2 handles differently) or a narrower version-compatibility gap that
happens not to show on the other 30. Left as a pointer for whichever duty-2
run reads this next, not chased down here.
