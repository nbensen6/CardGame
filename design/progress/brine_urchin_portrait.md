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
