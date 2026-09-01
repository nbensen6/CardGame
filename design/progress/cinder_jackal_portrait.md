# cinder_jackal — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/cinder_jackal.png`
(512x512). Batch 11 of #83; rubric defined in full in `frog_portrait.md`.

Unlike `frog`/`eyrie_hawk`/`flicker_stag`, this portrait is framed as a full
side-on standing shot rather than a head-and-shoulders crop — all four legs
and the whole body are in frame, the head is small relative to the canvas.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 6 | 4 | 6 | 6 | **28** |

## What is actually there

A full-body three-quarter-side view: black wedge head with two pointed ears
and a gold eye dot, a rust-red barrel body, a mustard sigil disc on the
flank, an orange rectangular bar standing proud along the spine (the
"smouldering mane"), and four thin black legs.

- **Framing (6):** the whole animal fits in frame with headroom above the
  ears and clearance below the feet, but the full-body side-on crop leaves
  the head small and off to one side rather than centred as the identity
  anchor the way the head-and-shoulders convention (frog, eyrie_hawk) does.
- **Identity (6):** the black wedge head with pointed ears and the overall
  quadruped stance read as "jackal/dog" at a glance, but nothing in the
  crop signals "ember/fire" beyond the warm body colour — the module doc's
  "smouldering mane" identity marker is present but doesn't read as fire.
- **Readability @ 34px (4):** confirmed via a real 34px downsample. The
  four thin black legs nearly disappear into faint vertical smudges, the
  mane bar and body merge into one rust-orange mass with no separation, and
  the sigil disc is barely a lighter blob within that mass. Weakest line
  of this batch — the full-body crop puts most of the frame's area on thin
  legs and background, leaving little pixel budget for the parts that
  actually carry identity.
- **Colour & separation (6):** the black head/legs separate cleanly against
  the rust body, but the mane bar's orange and the sigil's mustard sit close
  enough in hue to the surrounding red-brown body that neither pops as its
  own element, matching `cinder_jackal.md`'s own colour-adjacent finding
  about the mane reading as a rigid bar rather than fur.
- **Style consistency (6):** the full-body side crop breaks from the
  head-and-shoulders convention every other scored portrait in this batch
  (eyrie_hawk, flicker_stag) and batch 9 (frog, vine_weaver, lightbearer)
  use — worth flagging as a possible outlier rather than a deliberate
  per-beast choice.

## Diagnosis — two lowest

1. **Readability @ 34px (4).** Concrete fix: tighten `portraits.py`'s
   `FOCUS` crop for this asset toward a head/shoulder framing like the other
   scored portraits, so the party-panel size spends its pixels on the head
   and mane rather than four thin legs and empty background.
2. **Identity (6).** Concrete fix: same root cause `cinder_jackal.md`
   already names — drop the mane bar's base into the spine so it reads as
   fur rather than a bolted-on rectangle; that fix would also help this
   portrait's identity read directly.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the full-body side-on crop is this asset's own `FOCUS` entry in
`portraits.py` (a deliberate per-asset choice) or an oversight that should
match the head-and-shoulders convention most of the cast uses — this
scoring pass can see the difference but not its cause.

---

## Pass 2 — fixer, 2026-09-01

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`). Both named fixes
touch files in this lane's territory (`tools/blender/cinder_jackal.py`,
`tools/blender/portraits.py`) — no `game/**` GDScript, no palette, no
budget touched.

| Pass | Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 6 | 4 | 6 | 6 | **28** |
| 2 | 7 | 7 | 7 | 6 | 6 | **33** |

### Both diagnosed fixes applied

- **Identity (6 → 7).** `cinder_jackal_portrait.md`'s own diagnosis pointed
  at `cinder_jackal.md`'s Proportion finding — the "smouldering mane" spine
  ridge was a flat-topped `box()` held at one constant Z (1.60) the whole
  length of the spine, so while it sat close to the torso near the model's
  own centre it floated clear of the torso's own curved top surface toward
  the front (a ~0.16 world-unit gap at the shoulder, computed from the
  torso ellipsoid's surface equation) and read as a bolted-on rail rather
  than fur, exactly as diagnosed. Replaced the box with a `limb()` — the
  same primitive the tail two lines below it already uses — threaded
  through four points that follow the torso's own curve (z 1.53 → 1.60 →
  1.58 → 1.49 across the spine) with radii tapering from 0.03 at the back,
  up to 0.09 near the torso's centre, down to 0.02 at the front tip, so it
  sits flush against the body and thins into it at both ends instead of
  ending in a square edge. Confirmed in `cinder_jackal_pass2_side.png` and
  `_top.png`: the ridge now visibly follows the spine's own curve and
  narrows to a point at both ends rather than presenting a flat rectangular
  slab.
- **Readability @ 34px (4 → 7).** `portraits.py`'s `FOCUS["cinder_jackal"]`
  moved from `(0.45, 1.60)` — the loosest span of any portrait in the set,
  centred at 45% of the model's own height (mid-torso) — to `(0.60, 1.35)`,
  with a new `FOCUS_XY["cinder_jackal"] = (0.0, -0.7)` entry (the same kind
  of explicit XY override `riptide_eel` already needed, for the same
  reason: this beast is long in Y — head at one end, tail at the other —
  so the bounding-box-centre default the shared formula uses lands well
  short of the head). Iterated through nine framing trials rendered
  directly via `portraits.look()` before touching the committed asset,
  checking each with Pillow's `getbbox()` — several tighter crops (span
  0.85–1.15) put the head fully in frame but clipped a rear leg flush
  against the right/bottom canvas edge (`bbox` touching `(*, *, 512, 512)`
  exactly); span 1.35 was the loosest of the tested set with a clean
  margin on all four sides, `bbox (77, 76, 489, 500)` on the 512×512
  canvas. A fresh 34px Lanczos downsample (composited on the same
  `RGB(139,105,74)` card-face standin the icon batches use) shows the head,
  both ears, both eyes, the mane, and the sigil all as distinguishable
  shapes — a clear improvement on pass 1's "legs disappear, mane and body
  merge into one mass" finding, though the legs are still thin dark
  smudges at this size.

Rebuilt with `build.cmd cinder_jackal` (1180/2600 tris, 1 mesh, every
climb Height and the sigil hold still `ok` — no warnings) then `build.cmd
portraits`, which regenerates all thirty-two portraits from Blender's
non-deterministic `WORKBENCH` renderer (same non-determinism
`husk_beetle_portrait.md`'s, `silk_widow_portrait.md`'s and
`thrasher_portrait.md`'s pass 2 all hit) — every portrait other than
`cinder_jackal.png` was reverted with `git checkout --` and only the
changed asset kept.

- **Framing (6 → 7, side effect, not one of the two named lines):** the
  head is now the frame's clear anchor with even headroom rather than
  competing with three-quarters of a page of legs and background: alpha
  bbox `(77, 76, 489, 500)` gives comfortable, roughly balanced margins on
  all four sides where pass 1's full-body crop left the head small and off
  to one side. Not higher: this is still a full-body three-quarter-side
  shot, not the head-and-shoulders crop the rest of the cast uses — that
  structural difference (raised in pass 1's own Style line and Unsure
  section) is unchanged; only the zoom and the horizontal aim moved.
- **Colour & separation (6, unchanged):** pixel-sampled the committed PNG —
  mane RGB(175, 97, 57) against body RGB(148, 67, 55), a real but modest
  27/30/2 gap, and the sigil samples RGB(204, 182, 154), clearly lighter
  than either. The gap exists and is now easier to see simply because the
  tighter crop gives each part more of the frame, but neither named fix
  touched a colour value, and the gap itself is far smaller than
  `husk_beetle_portrait`'s ~50-point value-gap recolour, so the number
  holds rather than climbing on the strength of a side effect alone.
- **Style consistency (6, unchanged):** neither fix changed the underlying
  full-body side-on convention pass 1 flagged as a possible outlier; the
  same open question in this file's own Unsure section still stands.

**+5 total (28 → 33), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether `FOCUS["cinder_jackal"]` should go further toward an actual
head-and-shoulders crop (cropping the legs out of frame entirely) to fully
match the rest of the cast's convention, or whether keeping the full body
in frame is correct for a beast whose ledges and shelves (the game-visible
holds at Height 2 and Height 4) are part of its identity — this pass
tightened the existing full-body convention rather than replacing it,
since switching conventions entirely felt closer to an art-direction call
than a framing fix. Also unsure whether the mane's colour gap (27/30/2)
is worth a further recolour on top of the geometry fix, or whether the
geometry change alone was the two-fix budget's worth of work here — left
as a possible future finding rather than a third fix this pass.
