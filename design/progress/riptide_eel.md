# riptide_eel — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/riptide_eel.py`.** Views:
`design/renders/riptide_eel_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 7 | 6 | 5 | 5 | 7 | **30** |

## What is actually there

A long S-curved eel body, near-black navy, tapering from a blunt eyed head to a
pointed tail. Yellow eyes and a yellow-ringed sigil sit near the neck. Four
grey ball-and-plate lumps (the climbing holds) run down the body, each paired
with a thin flat spike.

- **Silhouette** (`_sil.png`): the S-curve is distinct and reads as a serpentine
  creature immediately — the strongest line for this asset.
- **Proportion**: the sinuous taper reads as eel/snake well. The head's
  underbite snout is a little blunt for "eel" but not wrong.
- **Build hygiene**: `_top.png` shows every hold and fin spike mounted on ONE
  lateral side of the body rather than along the dorsal ridge or mirrored
  top/bottom — from directly above it reads lopsided, like flags stuck into one
  flank, and the tail spike is a flat blade projecting straight out from the
  body surface rather than blended into it.
- **Colour & read**: the body is near-black across its full length. The sigil's
  yellow and the holds' grey both contrast against it individually, but the
  body itself risks reading as a dark smear rather than a distinct shape at
  party-panel size (34px) — this is the "nothing dark-on-dark" line, and the
  body is close to the line even though nothing is sitting directly on it.
- **Style consistency**: primitive shapes (tapered tube, ball holds) match the
  rest of the cast's vocabulary.

## Diagnosis — two lowest

1. **Build hygiene (5).** All four holds plus the tail fin sit on one lateral
   side (`_top.png`), not mirrored or spine-centred. Concrete fix: mirror the
   tail fin and the rearmost hold to the opposite side of the body so the
   top-down view is symmetric, the way a real dorsal ridge would be.
2. **Colour & read (5).** The body is one near-black tone end to end. Concrete
   fix: lighten the belly-facing third of the body by two palette steps (a
   lighter slate-blue) so the silhouette carries an internal light/dark split
   rather than reading as a single dark mass at small size.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the asymmetric hold placement seen from top-down is deliberate (holds
meant to be reached from one side of the fight ground) or an oversight — worth
checking against `env` data for this beast's fight before treating it as a bug.
