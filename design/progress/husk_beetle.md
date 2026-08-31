# husk_beetle — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/husk_beetle.py`.** Views: `design/renders/husk_beetle_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 6 | 8 | **29** |

## What is actually there

A rounded brown grub-like beetle: one big domed shell mass with a smaller
head-bump riding on top of it, four black spiked legs, a small head at the
front with two orange mandible points, two thin antennae, and a yellow-ringed
sigil disc mounted on a thin grey rod standing straight up out of the shell's
centre. A single dark line and a short diagonal notch are the only marks
suggesting a shell seam.

- **Silhouette** (`_sil.png`): reads as a legged blob with a small head notch
  at 64px — "bug with legs," not specifically "armoured beetle with two
  shell plates." Nothing in the black shape says "segmented" or "two
  ledges"; ART-REVIEW's own build note already called this a "pill-bug"
  read and the silhouette confirms it.
- **Proportion**: the two-hump body (head-bump riding the main shell) and
  four legs read as an insect at this size, matching intent.
- **Build hygiene**: 1384/2600 tris, 1 mesh, 1 material, nothing floating on
  the legs or mandibles. The sigil disc is the exception — it sits on a bare
  rod that visibly clears the shell surface by a wide gap in the side and
  top views, reading as a flag planted in the beetle rather than a marking
  on it. Same "orbiting part" failure named for Eyrie Hawk, Clot Toad and
  Silk Widow in earlier batches.
- **Colour & read**: brown shell, black legs, orange mandibles, yellow sigil
  — the sigil separates cleanly from the shell colour, but the shell's two
  humps are close enough in value that the "two segments" the intent
  describes do not read as two segments, only as one lumpy mass. Matches
  the existing ART-REVIEW note almost exactly.
- **Style consistency**: rounded primitives, dark spiked legs — sits fine
  beside the rest of the cast.

## Diagnosis — two lowest

1. **Silhouette / Proportion (5/5, tied).** The shell is one smooth mass;
   nothing breaks the outline into the "two-segment shell forming the two
   ledges" the build intent describes. Concrete fix: cut a visible notch
   or step in the shell profile between the head-bump and the main dome
   (drop the seam ~0.05 in Z where the existing dark line sits) so the
   silhouette shows two stacked lumps with a waist between them, not one
   continuous curve.
2. **Build hygiene (5).** The sigil rod holds it clear of the shell surface
   by roughly the rod's full length. Concrete fix: shorten the rod so the
   disc sits within ~0.03 of the shell surface, or delete the rod and mount
   the disc flush against the shell like the sigil placement on beasts that
   scored well on this line (e.g. Yoke Ox's sigil, which sits set into its
   yoke bar rather than floating above it).

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the antennae crossing visually in the three-quarter view (noted
already in ART-REVIEW as a perspective artefact, not a real mesh collision)
still reads as odd enough to dock Style — left out of the score here since
front and side views read clean, matching the existing note.

---

## Pass 2 — fixer lane, 2026-08-31

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Views: `design/renders/husk_beetle_pass2_*.png`, captured with
`look.cmd husk_beetle 2`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 6 | 8 | **29** |
| 2 | 6 | 6 | 7 | 6 | 8 | **33** |

### Both diagnosed fixes applied

- **Build hygiene (5 → 7).** `mark()`'s anchor pulled from `(0.0, -0.20, ...)`
  to `(0.0, 0.00, ...)` — the tail-plate ball it should be mounted on is
  centred at y=0.35 with a 0.36 y-radius, so its own front surface sits at
  y≈-0.01; the old anchor sat 0.19 further forward than that, in open air.
  `husk_beetle_pass1_34.png` shows the gold ring floating well clear of the
  ball with a visible gap; `husk_beetle_pass2_34.png` and `_top.png` show it
  seated against the ball's face instead, the same "orbiting part" fix
  already applied to Clot Toad's gland sigil.
- **Silhouette (5 → 6), Proportion (5 → 6).** The diagnosis named one shared
  fix for the tied pair: cut a visible notch between the tail-plate ("head-
  bump" in the cloud's language) and the main thorax dome so the two read as
  stacked lumps rather than one continuous curve. Concrete change: the
  spine-seam box (the "existing dark line" the diagnosis pointed at) dropped
  from z=1.78 to z=1.73. `husk_beetle_pass1_sil.png` shows the top lobe
  blending smoothly into the main mass; `husk_beetle_pass2_sil.png` shows a
  distinct notch between them. Flagging what actually produced it, since it
  is not what was planned: the seam box is a long flat plate (y half-extent
  1.15) laid across a curved dome, and its own far end already pokes out
  past the shell surface in pass 1's render (visible as the loose black
  diagonal stroke top-left of `_34.png`) — dropping the box's z changed
  where that pre-existing poke-out lands relative to the tail-plate ball,
  and that is what reads as the notch in pass 2, not a deliberate carved
  waist. The rubric line improved and the render confirms it, but the seam
  box's own poke-out is an existing build fault this pass did not touch and
  did not diagnose — worth a look on its own later, but out of scope here
  (two fixes per run, per the brief).

+4 total, not a plateau — kept. Colour and Style were not touched, per the
brief, and their scores are unchanged from pass 1.

`run_tests.gd` passed (all green) before commit. Build log: 1396/2600 tris,
1 mesh, every climb Height and the sigil hold still `ok`.

## Unsure about, still

Whether the notch reads as intentional "two-segment shell" or as a stray
seam artefact once looked at closely — the mechanism is a floating decal
edge, not carved geometry, so a future pass with more budget might replace
it with an actual stepped profile rather than relying on this coincidence.
