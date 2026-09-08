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

---

## Pass 3 diagnosis — #86 duty 1, 2026-09-08

Lowest-scoring beast with no pending diagnosis and a current, uncollided
render on disk (`bog_leech` and `clot_toad` already carry unapplied pass-3
fixes from earlier rotations; `boulder_ram` was diagnosed earlier this same
rotation; the 14 original-cast beasts — see `gale_serpent.md` — cannot be
scored at all until `look.sh`/`look.cmd`'s output-naming collision is fixed,
which is duty-2 shaped, not this pass's job). Confirmed `tools/blender/
husk_beetle.py` unchanged since the renders were captured (both land in the
same commit, `8c84bc8`), so `husk_beetle_pass2_34.png` and `_sil.png` are
current. No `_side`/`_front`/`_top` were captured for this asset in either
pass — scoring against what exists rather than blocking on renders nobody
has.

Re-scored from the actual images rather than anchoring on pass 2's numbers,
per the anchor rule.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 6 | 8 | 29 |
| 2 | 6 | 6 | 7 | 6 | 8 | 33 |
| 3 (re-score, no geometry change yet) | 5 | 6 | 5 | 6 | 8 | 30 |

**What pass 2 under-scored.** Pass 2's own writeup already named the cause —
"the seam box's own poke-out is an existing build fault this pass did not
touch and did not diagnose" — but never revised the two rubric lines that
poke-out actually damages. Looking again at `husk_beetle_pass2_34.png`: two
loose black diagonal strokes sit clearly OUTSIDE the shell surface, upper-
left of the tail-plate, reading as broken twigs or scratches laid over the
beetle rather than a seam cut into it — the single most visually prominent
defect in the render, more so than anything pass 2 actually fixed.
`husk_beetle_pass2_sil.png` confirms it isn't just a lit-render shading
artefact: a thin jagged spike pokes out of the otherwise-clean blob outline
at roughly 10 o'clock, which is geometry breaking the silhouette, not a
texture read.

**Root cause, from the actual coordinates in `husk_beetle.py`.** The main
spine seam is `b.box((0.0, -0.30, 1.73), (0.020, 1.15, 0.030), CHARCOAL)` —
a flat plate at constant z=1.73 with a y half-extent of 1.15, laid across the
curved thorax ball (`b.ball((0.0, 0.10, 1.02), (0.96, 1.35, 0.80), UMBER,
...)`). Solving for where that ellipsoid's surface is still above z=1.73 at
x=0: `((y-0.10)/1.35)^2 <= 1 - ((1.73-1.02)/0.80)^2 = 0.2123`, so the dome
only clears z=1.73 for `y` in roughly **[-0.52, 0.72]**. The box is centred
at y=-0.30 with half-extent 1.15, spanning **y in [-1.45, 0.85]** — well
outside that window at both ends, so both tips of the flat plate exit the
dome's curved surface and hang in open air, exactly the "loose stroke"
visible in the render. This is the same shape of fault named on Yoke Ox's
and Silk Widow's earlier passes ("a part spaced away from the body"), just
never connected to a rubric number here until now.

**Colour (6, unchanged) — checked, not the problem pass 1 guessed.** Pass
1's diagnosis blamed "the shell's two humps" being close in value. Sampled
`tools/blender/colormap.png` at the actual swatch centres (`kenney.swatch`'s
`+16` convention): UMBER (the main shell) is `rgb(144,85,60)`, value ≈100;
TAN (the tail-plate the sigil sits on) is `rgb(217,152,111)`, value ≈167 — a
67-point gap on a 0–255 scale, not "close." `husk_beetle_pass2_34.png`
confirms it by eye too: the tail-plate reads as a distinctly lighter warm
brown against the darker main mass. Leaving Colour's score where pass 2 left
it and not proposing a colour fix this pass — the real defect is geometry,
not palette.

## Diagnosis — two lowest (pass 3)

Both trace to the same root cause (the spine seam's poke-through), so one
fix, same precedent as `bog_leech.md` pass 2 and `boulder_ram.md` pass 3
("one visual unit").

1. **Build hygiene (5).** Concrete fix: shrink the main spine seam's y
   half-extent in `husk_beetle.py` from `1.15` to about `0.20` — i.e.
   `b.box((0.0, -0.30, 1.73), (0.020, 0.20, 0.030), CHARCOAL, bevel=0.0)` —
   which keeps the whole box inside the `[-0.52, 0.72]` window the dome
   actually clears at z=1.73, with margin, instead of overshooting it by
   roughly a full unit at the far end.
2. **Silhouette (5).** Same fix as above — the jagged spike in `_sil.png` is
   this exact box's far tip breaking the outline; shortening it removes both
   the render artefact and the silhouette spike in one change, not two
   separate edits.

Not applying either — this item scores and proposes; `tools/blender/
husk_beetle.py` is the fixer's file (`tools/fixer/BRIEF.md`).

## Unsure about (pass 3)

Whether `0.20` leaves the seam long enough to still read as a spine mark at
all once actually rendered — the geometry math only proves where it stops
poking out, not how short is too short to be seen. Also unsure whether the
two smaller diagonal side-seam boxes (`(-0.46, 0.30, 1.36)` and
`(0.46, 0.30, 1.36)`, half-extent 0.30, rotated ±0.35 rad) contribute to
either visible mark or are a separate, smaller instance of the same
poke-through — they were not checked against the ball's surface the way the
main spine seam was, and this run's two-fix budget went to the confirmed
larger defect instead.

---

## Pass 4 — fixer lane, 2026-09-08

Applied pass 3's diagnosed fix. Views: `design/renders/husk_beetle_pass4_*.png`,
captured with `look.cmd husk_beetle 4`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 3 (re-score, no geometry change yet) | 5 | 6 | 5 | 6 | 8 | 30 |
| 4 | 5 | 6 | 7 | 6 | 8 | **32** |

### The one diagnosed fix, applied

Changed `b.box((0.0, -0.30, 1.73), (0.020, 1.15, 0.030), CHARCOAL, bevel=0.0)`
to `(0.020, 0.20, 0.030)`, exactly as diagnosed — the main spine seam no
longer overshoots the thorax dome's clearance window.

- **Build hygiene (5 → 7).** `husk_beetle_pass2_34.png` showed a long dark
  plate crossing loose in open air above the shell, top-left of the
  tail-plate, plus a second shorter loose stroke below it — the pokethrough
  named in the pass 3 diagnosis. `husk_beetle_pass4_34.png` and `_top.png`
  show that plate gone: what remains of the seam sits flush on the dome as a
  short dash, the same fix pattern as `bog_leech` pass 2. Not a 9 — see
  below.
- **Silhouette: unchanged (5), not the claimed fix.** The diagnosis
  attributed the jagged spike in `_sil.png` at roughly 10 o'clock to this
  same box and expected shortening it to remove the spike. Comparing
  `husk_beetle_pass2_sil.png` and `husk_beetle_pass4_sil.png` pixel-for-pixel:
  the spike is still there, in the same place, unchanged. `_front.png`
  explains why — the two smaller diagonal side-seam boxes at `(-0.46, 0.30,
  1.36)` and `(0.46, 0.30, 1.36)`, flagged as "unsure about" in the pass 3
  notes and explicitly left untouched, visibly poke past the shell's outer
  edge on both shoulders in the pass 4 front render. That is almost
  certainly the real source of the silhouette spike, not the main seam this
  pass fixed. Leaving the score at 5 rather than claiming an improvement the
  render does not show — the honesty rule in `design/asset-loop.md`.
  Colour and Style untouched, scores carried over from pass 3.

+2 total. Not a plateau on its own (pass 3 was a re-score, not a geometry
pass), so no rebuild verdict triggered.

`run_tests.gd` passed (all green) before commit. Build log: 1396/2600 tris,
1 mesh, every climb Height and the sigil hold still `ok`.

## Unsure about, still

The two side-seam boxes now read as the likely cause of the persistent
silhouette spike (see above) — next diagnosis pass should check them against
the thorax ball's surface the same way pass 3 checked the main seam, instead
of assuming the fix already covered it.
