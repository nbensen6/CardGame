# brine_urchin — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/brine_urchin.png`
(512x512). Batch 10 of #83; rubric defined in full in `frog_portrait.md`.
No fixer pass exists for this asset — geometry matches the pass-1 render
`brine_urchin.md` already scored at 33/50.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 5 | 7 | 5 | 8 | 7 | **32** |

Pass 2: 9 | 7 | 5 | 8 | 7 | **36** — see below.

## What is actually there

A tight three-quarter crop on the spined red sphere: several tapered spines
radiate outward tipped in violet balls, a gold sigil disc sits in a socket
on the upper-left of the body, and a dark grey base with short leg-like
tendrils is visible at the bottom.

- **Framing (5):** several spines are cut mid-shaft at the left and right
  frame edges rather than shown whole or excluded entirely — since the
  spines are this creature's main identity feature per the module doc, this
  is a more costly crop trade-off here than in a headshot-style portrait.
- **Identity (7):** the tighter crop actually helps here relative to the 3D
  scoring — `brine_urchin.md` found the sigil only reads as an eye up close;
  the portrait's closer framing gives the gold disc enough relative frame
  area to read as a face cue (an eye at the crown) at full size, which the
  six standard fight-camera angles didn't achieve.
- **Readability @ 34px (5):** confirmed via a real 34px downsample. The body
  reads as a round red-orange blob with a faint gold smudge upper-left; most
  spines vanish at this size, consistent with `brine_urchin.md`'s silhouette
  finding that most spines foreshorten from the game's viewing angles. The
  gold "eye" mark survives the downsample better than the spines do.
- **Colour & separation (8):** coral/brick body, violet spine tips, gold
  sigil, and the grey base all separate cleanly — matches the strong colour
  score the 3D pass already gave this asset.
- **Style consistency (7):** matches the shared three-quarter convention;
  reads a little more "object" than "creature" in this crop, consistent with
  the "sea mine" read `brine_urchin.md` already named as an open question
  rather than a confirmed defect.

## Diagnosis — two lowest

1. **Framing (5).** Concrete fix: either pull the crop back slightly so more
   spines show whole, or accept the tighter crop but trim the frame further
   so no spine is left mid-cut — a fragment reads worse than either extreme,
   the same principle `vine_weaver_portrait.md` already named for its sigil
   bead.
2. **Readability @ 34px (5).** Concrete fix: none proposable without model
   changes (out of scope) — the spines that make this shape read as "urchin"
   rather than "ball" are a 3D geometry problem `brine_urchin.md` already
   diagnosed (rotate spines closer to the viewing plane); a portrait crop
   can't add spine visibility that isn't in the source render.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the portrait's improved "eye" read is worth deliberately cropping
tighter on future creature portraits with an off-center face cue, or whether
that's specific to this asset's socketed sigil placement — no other scored
portrait in this batch has a comparable off-center face feature to compare
against.

## Pass 2 — cloud, backlog #86 duty 1

Only the **Framing (5)** line had a fix applicable in-lane. **Readability @
34px (5)** was explicitly flagged as "none proposable without model changes
(out of scope)" — this pass touches `tools/blender/portraits.py` only, no
beast geometry, so left untouched, same split `bog_leech_portrait.md` pass 2
made for its own two-fix budget.

Applied the **Framing** fix: `portraits.py`'s `FOCUS["brine_urchin"]` moved
from `(0.62, 1.30)` to `(0.62, 1.45)` — same vertical centre, wider ortho
span so the camera pulls back rather than re-centring, per the diagnosis's
"pull the crop back" option (the other option, trimming tighter still, was
rejected first: at `span=1.40` the left spine tip still cleared the frame
edge by only 3px, too close to trust against render variance).

Rebuilt via apt's Blender 4.0.2, headless (EGL through `libegl1`/
`libegl-mesa0`/`libgles2`; `numpy`/`Pillow` installed for `/usr/bin/
python3.12`, the interpreter this Blender actually runs — same setup
`fire_icon.md` pass 3 and `bog_leech_portrait.md` pass 2 used). No
single-portrait build path exists, so ran the full `portraits.py` batch
(all 30) and diffed every output against the committed set (mean per-pixel
diff): `brine_urchin.png` at 16.7 was a real content change; `frog.png`
(58.2) and `goblin_mech.png` (15.2) also showed large diffs but from
completely different causes — spot-checking `frog.png` showed a tight
close-up on two solid-black eyes, nothing like the amber-eyed committed
portrait, meaning that model's geometry has drifted from what the committed
portrait was rendered from at some point since — not this pass's doing (its
`FOCUS` entry was never touched) and out of this lane's two-fix budget to
chase. Copied only the changed `brine_urchin.png` into
`game/assets/portraits/`; every other file in that folder reverted to the
committed version.

Verified by looking, not just by the numbers:

- **Alpha bbox** (Pillow `getbbox()`) moved from `(0, 104, 465, 500)` — left
  edge at 0, meaning content touched the frame boundary with no margin at
  all — to `(12, 119, 443, 475)`: real margin on all four sides (tightest is
  bottom at 37px, ~7% of the 512px canvas).
- **Full 512px composite** over the same brown card-face standin pass 1
  used (`design/renders/brine_urchin_portrait_pass2_full.png` vs
  `design/renders/brine_urchin_portrait_pass1_full.png`): pass 1 shows the left-most
  spine's shaft running straight off the left edge with its violet tip cut;
  pass 2 shows all six spines whole, tips included, with visible background
  beyond every one.
- **A real 34px downsample** (Pillow `LANCZOS`, nearest-neighbour upscaled
  for viewing, same brown-standin composite): the gold sigil "eye" still
  reads clearly at the same relative position and roughly the same apparent
  size; the spines are about as faint as pass 1's downsample in both
  directions — no visible gain or loss from the wider crop at this size.

- **Framing (5 → 9):** every spine, including the tip beads, is fully inside
  frame with genuine margin on all four sides, confirmed by both the alpha
  bbox and the full-render composite above. Not 10: the margin is uneven
  (37px bottom and 12px left versus ~70-90px top/right), a minor asymmetry
  the fix didn't target.
- **Identity (7, unchanged):** the sigil-as-eye read this line credited is
  about 11% smaller in frame than pass 1 (wider span, same vertical centre)
  but the 34px comparison above shows no visible loss of that read — not
  raised because this pass's fix targeted Framing, not Identity, and the
  "sea mine, not creature" caveat pass 1 named is untouched either way.
- **Readability @ 34px (5, unchanged):** pass 1 already named this
  unfixable without model geometry changes; this pass's crop-only fix
  doesn't touch the spines' own foreshortening, and the 34px comparison
  above confirms no visible change in either direction.
- **Colour & separation (8, unchanged):** no palette or material touched.
- **Style consistency (7, unchanged):** same three-quarter composition
  class, only the span changed.

**+4 total (32 → 36), not a plateau — kept.** No line regressed. Below the
loop's 40 stop line, so a pass 3 remains available (2 of 4 used) if a
concrete in-lane fix for Readability or Identity turns up later; none is
proposed here. `run_tests.gd`: **ALL TESTS PASSED** (fresh import,
headless). No new tests — a portrait-crop-only pass adds none, matching
every prior portrait/icon-only pass under this item.

## Unsure about (pass 2)

Whether `frog.png`'s and `goblin_mech.png`'s large render diffs from the
committed set (spotted only because this pass diffed the whole batch, not
because anything was looking for them) mean those two portraits are stale
against their current models — flagged here rather than fixed, since
neither is this pass's asset and confirming/rebuilding either is its own
scoring pass under this same rotation, not a silent side effect of this
one.
