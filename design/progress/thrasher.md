# thrasher — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/thrasher.py`.** Views: `design/renders/thrasher_pass1_*.png`.
Captured after "Darken the rock, warm the organics" (palette + UV fix) and the
three-point lighting rig landed underneath this pass via merge — re-rendered
against both before scoring; this asset's colours and findings below are
unchanged from the pre-fix render.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 6 | 5 | 6 | 7 | **32** |

## What is actually there

A low, splayed-leg newt: a long flat black body, an orange warning-colour
belly stripe carried down onto the legs, a pointed snout with two small red
eye dots, and a tail that curls sharply up and back over the spine like a
raised scorpion stinger. A thin grey crest juts out sideways near the tail's
base, carrying the gold sigil disc.

- **Silhouette** (`_sil.png`): the strongest of this batch — the raised
  curling tail against the low flat body reads as a distinct, recognizable
  shape at 64px, and reads *different* from the other quadrupeds in the
  cast rather than another generic hump-and-legs silhouette. This is
  exactly the "lash" pose the module doc is going for.
- **Proportion**: the flat crouched body and splayed legs read as newt, and
  the tail's curl is proportioned well against the body — big enough to
  read, not so big it overwhelms. The sigil crest is the one part that
  reads as added-on rather than grown from the body.
- **Build hygiene**: the sigil crest is a thin rod jutting sideways off the
  tail base with the gold disc riding its tip, visible clearly in side and
  top views as a separate stick-with-a-washer rather than a part of the
  creature — the same "orbiting part" pattern already named in
  `ART-REVIEW.md` for the Eyrie Hawk and Clot Toad, and scored the same way
  this batch in Silk Widow.
- **Colour & read**: the orange belly stripe against the black body is the
  strongest colour choice in the batch — it separates cleanly and would
  likely still read at 34px. The red eye dots pop against the black snout.
  The two dark tail-curl segments sit close in value against the black
  body and don't add much separation, but they're small enough not to hurt
  overall legibility.
- **Style consistency**: low-poly primitives, consistent bevel and palette
  with the rest of the fight-pool beasts.

## Diagnosis — two lowest

1. **Build hygiene (5).** The sigil crest reads as a floating rod-and-disc
   rather than a part of the tail. Concrete fix: same as Silk Widow this
   batch — thicken the crest's base and shorten it by roughly a third so it
   reads as a stub growing off the tail rather than a wire poking out to
   the side.
2. **Proportion (6).** The crest also pulls the eye away from the tail-curl
   silhouette that is this asset's best feature. Concrete fix: once
   thickened per above, consider moving the sigil mark onto the tail curl's
   own surface instead of a separate crest, so the sigil sits on a shape
   that's already reading well rather than adding a new one.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Nothing beyond the crest fix — this is the cleanest read of the batch, and
the open question is purely whether the sigil needs its own crest geometry
at all, which is a design call rather than a measurement.

---

## Pass 2 — fixer, 2026-09-01

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Picked under the brief's new screen-size-tier rule (beasts
before portraits/icons) rather than by lowest score — thirteen beasts,
hunters and grounds had never had a fixer pass, and this one was named
directly in the brief as the example.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 6 | 5 | 6 | 7 | **32** |
| 2 | 8 | 6 | 7 | 6 | 7 | **34** |

### Only the first named fix applied

**Build hygiene (5 → 7).** Thickened the crest taper's base (0.07 → 0.13)
and shortened it by a third (0.46 → 0.31) in `tools/blender/thrasher.py`,
same measurement Silk Widow's own crest used this batch. A first attempt
copied Silk Widow's exact recipe — shrink the taper's `depth` around its
existing centre — and rendered **no visible improvement**: shrinking around
a fixed centre pulls the thick (base) end *away* from the crest ball it
needs to fuse with, not into it, since that end sits at `centre + depth/2`.
Caught by re-rendering and diffing pixels against pass 1 before writing
anything down, not assumed from the numbers. Fixed by moving the taper's
centre forward by half the trimmed length (`y −0.02 → 0.055`) so the
shortening comes off the front (mark) end only and the thick base end stays
anchored where it was. Moved the sigil mark's own `at` from `y −0.24` to
`y −0.09` to match, since the taper's front tip is now 0.155 closer and the
old mark position would have floated past it.

Confirmed in `design/renders/thrasher_pass2_34.png` against
`thrasher_pass1_34.png`, cropped to the crest region: pass 1 shows a clear
gap of background grey between the taper/disc and the crest ball; pass 2
shows the taper visibly meeting the ball with no gap. `_top.png` shows the
same — the disc now sits inside the body's own silhouette from above rather
than projecting past its edge. Not a full fix: some seam is still visible at
full size and the assembly still reads as its own part rather than fully
grown from the body, which is why this is a 7, not the 8 Silk Widow's fatter
base reached — Silk Widow's fix nearly doubled its base radius (0.10→0.18)
where this one went from 0.07→0.13, a smaller absolute jump on an already
thinner crest.

**Silhouette (8, unchanged):** confirmed via `_sil.png` — the crest was
never large enough to register in silhouette before or after, same finding
Silk Widow's own fix logged.

### Second fix not applied

**Proportion (6, unchanged).** The diagnosis's own second line — moving the
sigil mark onto the tail curl's own surface instead of a separate crest —
ends "which is a design call rather than a measurement" in this file's own
Unsure section. That is exactly the art-direction line the brief's hard
rules stop at. Left alone.

Rebuilt with `build.cmd thrasher` (1280/2600 tris, 1 mesh, budget ok, no
floating-part warning), captured with `look.cmd thrasher 2`, viewed every
tracked view directly. `run_tests.gd`: **ALL TESTS PASSED**.

**+2 total (32 → 34), not a plateau — kept.** No line regressed.

---

## Pass 3 diagnosis — #86 duty 1, 2026-09-08

Lowest-scoring beast tier candidate with no pending diagnosis and a current
render on disk: `tools/blender/thrasher.py` and `design/renders/thrasher_
pass2_*.png` land in the same commit (`21b0360`), so the pass-2 renders are
current. Re-scored from the actual images rather than anchoring on pass 2's
numbers, per the anchor rule. `thrasher_pass2_sil.png`,`_34.png` and
`_front.png` are the only three views captured for this asset (no side/top/
wire) — scoring against what exists.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 6 | 5 | 6 | 7 | 32 |
| 2 | 8 | 6 | 7 | 6 | 7 | 34 |
| 3 (re-score, no geometry change yet) | 8 | 6 | 7 | 6 | 7 | 34 |

No score moved — pass 2's own numbers hold up against a fresh read of
`thrasher_pass2_sil.png` (still the clearest silhouette in this batch) and
`_front.png`. Proportion and Hygiene tie for lowest at 6/7 respectively but
Hygiene is genuinely the worse defect on screen — see below — so this pass
treats both as one root cause the way `husk_beetle.md` pass 3 and
`boulder_ram.md` pass 3 did.

**What `_front.png` actually shows.** The gold sigil disc sits at the end of
a visibly thin dark rod poking sideways off the crest, distinct from the
head/horn mass behind it — a clear gap of background-coloured shading
between the rod's thin midsection and the body proper. Pass 2's own notes
already called this "not a full fix... reads as its own part," and the
render confirms it is still the single most visible defect in the image.

**Root cause, from the actual coordinates in `thrasher.py`.** The crest ball
is `b.ball((0.34, 0.34, z5), (0.16, 0.22, 0.16), ...)`, so its near edge
(toward the mark, −Y) sits at `y = 0.34 − 0.22 = 0.12`. The mount taper is
`b.taper((0.34, 0.055, z5−0.02), 0.13, 0.02, 0.31, ...)` — centre `y=0.055`,
half-depth `0.155`, so its thick (base) end sits at `y=0.21` (inside the
ball, embedded 0.09 deep — good) and its thin (tip) end sits at `y=−0.10`.
That means `0.12 − (−0.10) = 0.22` of the taper's own `0.31` total length
pokes out **past the ball's own surface** as bare, thinning rod before the
mark (`at y=−0.09`) even begins — this is the floating-rod read, not a
lighting artefact, and it is a bigger exposed length than the ball's own
radius that is supposed to be hiding it.

This same geometry also explains the tied Proportion score: at `(0.16, 0.22,
0.16)` the crest ball is close in scale to the leg-joint balls elsewhere on
this model, so it reads as a second small head riding beside the tail-curl
rather than a mount — competing with the tail-curl for the silhouette's one
dramatic shape, which is this asset's best feature (per pass 1's own note).
Not the same finding as pass 1's "move the sigil onto the tail curl's own
surface," which is still a design call and is left alone here — this is a
pure scale measurement on the mount ball, no relocation involved.

## Diagnosis — two lowest (pass 3)

One root cause (the oversized, under-embedded sigil mount), same "one visual
unit" precedent as `husk_beetle.md` and `boulder_ram.md` pass 3:

1. **Build hygiene (7).** Concrete fix: shorten the taper's exposed length by
   moving its embedding rather than its overall size. Move the taper centre
   from `(0.34, 0.055, z5−0.02)` to `(0.34, 0.125, z5−0.02)` and shrink depth
   from `0.31` to `0.17`, keeping the base end anchored at `y=0.21` (still
   embedded 0.09 into the ball) while the tip moves from `y=−0.10` to
   `y=0.04` — cutting the bare-rod length outside the ball from `0.22` to
   about `0.08`. Move the mark's `at` from `(0.34, −0.09, z5)` to
   `(0.34, 0.02, z5)` to match the shortened tip.
2. **Proportion (6).** Concrete fix: shrink the crest ball's radii from
   `(0.16, 0.22, 0.16)` to about `(0.13, 0.17, 0.13)` — small enough that it
   reads as a mount rather than a second bump, while still large enough to
   keep the taper's base (fix 1, now at `y=0.21`) inside its new surface: at
   the unchanged centre `y=0.34` with the shrunk `r_y=0.17`, the ball spans
   `y` in `[0.17, 0.51]`, which still covers `y=0.21` — embedded 0.04 deep
   rather than fix 1's own 0.09, shallower but still inside, not floating.

Not applying either — this item scores and proposes; `tools/blender/
thrasher.py` is the fixer's file (`tools/fixer/BRIEF.md`).

## Unsure about (pass 3)

Whether shrinking the crest ball to `(0.13, 0.17, 0.13)` still reads as
"grown from the tail" once actually rendered, or starts to look like the
taper is now oversized relative to its own mount — the math only proves the
embedding stays valid, not how the proportions of ball-to-taper read at a
glance. Also unsure whether Colour (6, unchanged) deserves its own pass —
pass 1's note about the tail-curl's two dark segments sitting close in value
against the black body is still true in `_34.png`, but it reads as a minor
issue next to the mount's own defects, and this run's two-fix budget went to
the confirmed larger one instead.
