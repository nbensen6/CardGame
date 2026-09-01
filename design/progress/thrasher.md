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
