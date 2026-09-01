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

---

## Pass 2 — fixer lane, 2026-09-01

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Views: `design/renders/riptide_eel_pass2_34.png`,
`design/renders/riptide_eel_pass2_sil.png`, captured with
`look.cmd riptide_eel 2`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 7 | 6 | 5 | 5 | 7 | **30** |
| 2 | 7 | 6 | 7 | 7 | 7 | **34** |

### Both diagnosed fixes applied

- **Build hygiene (5 → 7).** All four holds and the sigil crest sat on the
  +X side only. Mirrored, decoratively, onto -X: matching `ball()`s at
  each hold height plus a plain `box()` plate at each (not a second
  `shelf()` call — `shelf()` re-registers the climb anchor for that
  Height, so a second call at the same Height would have silently moved
  where a hunter actually stands, not just added geometry), and a
  matching undecorated crest (ball + taper, no `mark()`) beside the sigil.
  `riptide_eel_pass2_top.png` now shows two holds per side at each height
  and a symmetric pair of crests, against `riptide_eel_pass1_34.png`'s
  single-flank read. The sigil itself stays singular, per every other
  beast in the cast — only its crest got a twin.
- **Colour & read (5 → 7).** The belly band (`BELLY = SPINE[:7]`) was
  MIDNIGHT, the darkest swatch in its own colour family and barely
  distinct from the NAVY spine — the "still close to monochrome" finding.
  Swapped to SLATE, already imported and already used on this same body
  for the ridge plates, a genuinely lighter blue-grey rather than another
  near-black. `riptide_eel_pass2_front.png` shows the belly-facing third
  reading as a visibly lighter band against the black spine and jaw.

Build log: 1696/2600 tris (was 1316), 1 mesh, every hold and the sigil
still `ok`, no climb point moved (`CLIMB Height 2 at 39%, contract says
39% ok`; `CLIMB Height 4 at 59%, contract says 59% ok` — identical to
pass 1's own numbers). `run_tests.gd` passed (all green) before commit.

+4 total, not a plateau — kept. Silhouette, proportion and style were not
touched, per the brief; their scores are unchanged from pass 1.

## Unsure about, still

Same open question as pass 1: whether the asymmetric hold placement was
deliberate for the fight ground's own layout. Mirroring it for the
model's own read doesn't answer that — if the fight ground genuinely
only offers one side, this pass may have fixed a read at the cost of a
hint about where to stand, which is Nick's call to weigh.
