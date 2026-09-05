# eyrie_hawk — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/eyrie_hawk.py`.** Views:
`design/renders/eyrie_hawk_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 7 | 4 | 7 | 7 | **33** |

## What is actually there

A bipedal bird: a crested head with a curved beak, a rounded blue-grey body
with a tan belly patch, two large triangular wings, spiked tail feathers, and
clawed legs. A yellow-ringed sigil disc sits beside the head.

- **Silhouette** (`_sil.png`): crest, hooked beak, wings and legs are all
  distinct at 64px — reads as a bird of prey immediately, the strongest line
  for this asset.
- **Proportion**: body and legs read as avian; the two wing slabs are wide,
  flat triangles that read more like stiff flaps than folded feathers.
- **Build hygiene**: `_side.png` and `_top.png` both show the sigil disc
  floating in open air beside the beak with no visible mount to the body or
  head — the exact "part spaced away from the body" failure this file already
  names for the Vine-Weaver's orbiting hoops.
- **Colour & read**: blue-grey body, tan belly, brown head separate cleanly;
  the sigil's yellow contrasts well were it actually attached to something.
- **Style consistency**: proportions and primitive shapes fit the rest of the
  cast.

## Diagnosis — two lowest

1. **Build hygiene (4).** The sigil disc has no visible attachment to the
   model. Concrete fix: move the sigil to sit flush against the chest/shoulder
   plumage (reduce its offset from the torso mesh to near zero) instead of
   hovering beside the head with empty space around it.
2. **Proportion (7).** The wings are flat wide triangles that read as bulky
   panels rather than feathered wings. Concrete fix: taper each wing's trailing
   edge by roughly 40% and add 2–3 of the same thin spike shapes already used
   on the tail, so the wing reads as layered pinions instead of one solid slab.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the sigil was intended to sit on the head crest (close by, on a small
mount) rather than the chest — either placement fixes the floating problem,
but they read differently on the model and it isn't this pass's call which.

---

## Pass 2 — fixer lane, 2026-09-05

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`). Views:
`design/renders/eyrie_hawk_pass2_*.png`, captured with `look.cmd eyrie_hawk 2`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 7 | 4 | 7 | 7 | **33** |
| 2 | 8 | 8 | 7 | 7 | 7 | **37** |

### Both diagnosed fixes applied

- **Build hygiene (4 → 7).** The crest ball and its `mark()` moved from
  `(0.16, -0.90, z6)` / `(0.16, -1.10, z6)` to `(0.10, -0.69, z6)` /
  `(0.10, -0.89, z6)` in `eyrie_hawk.py` — pulled in toward the neck instead of
  hanging off to the side, `z6` (the Height 6 contract) untouched throughout so
  the sigil's climb percentage never moved. The build log's own floating-part
  check confirms it: the first attempt at this still printed `WARNING: ...
  floating free ... 0.025 away`, a second nudge got it to `0.005 away`, and the
  position landed here prints no warning at all. `eyrie_hawk_pass2_form.png`
  and `_34.png` show the disc sitting flush against the neck/shoulder, no
  daylight around it — compare `eyrie_hawk_pass1_34.png`, where the same disc
  floats beside the head with a clear gap.
- **Proportion (7 → 8).** `wing()`'s folded-mass taper end radius `0.09 → 0.054`
  (roughly 40% thinner at the trailing tip), and the trailing-primary loop
  extended from 3 spikes to 5 by continuing its own spread progression
  (`-0.16, 0.02, 0.20` → `-0.16, 0.02, 0.20, 0.38, 0.56`), the same thin taper
  shape the loop already used, just more of them. `eyrie_hawk_pass2_34.png`
  and `_top.png` show a narrower main panel with five fanned feather-spikes
  trailing off it, next to `eyrie_hawk_pass1_34.png`'s three-spike, blunter
  panel.

Neither line dropped and both moved up a full point or more — **+4 total (33 →
37), not a plateau, kept.** Colour and Style were not touched, per the brief;
their scores are unchanged from pass 1.

`build.cmd eyrie_hawk`: 1636 tris, 1 mesh, budget ok, every climb Height and
the sigil hold still `ok`, no floating-part warning. `run_tests.gd`: **ALL
TESTS PASSED**.

## Unsure about, still

Same open question as pass 1: whether the sigil belongs on the chest/shoulder
or the head crest is still a placement choice, not a measurement — this pass
just closed the gap at the placement pass 1 already had, per the brief's
two-fixes budget. Also new from this pass: whether five primaries reads as
"more feathers" or as "more spikes" at fight distance rather than this static
render — worth a look under the real fight camera and lighting.
