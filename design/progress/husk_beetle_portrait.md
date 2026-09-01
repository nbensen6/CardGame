# husk_beetle — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/husk_beetle.png`
(512x512). Batch 12 of #83; rubric defined in full in `frog_portrait.md`.

Note: `husk_beetle.md`'s 3D pass (29/50, later fixer-repaired to 33 —
`design/progress/husk_beetle.md`'s own "Pass 2 — fixer" section) was scored
against the pre-fix model; this portrait was rendered after that fix landed
(`portraits.py` builds from the model), so any pre-fix-only findings below
should not be assumed to carry over unchanged.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 4 | 6 | 6 | 5 | 6 | **27** |

Second-lowest portrait scored so far under this item, one point above
`bog_leech_portrait`'s 26 and below `cinder_jackal_portrait`'s 28.

## What is actually there

A large brown shell mass fills the middle of the frame, a smaller
round hump with a gold-ringed sigil sits at the top, and a head with two
pale-orange mandible points and dark eye is visible at the bottom-left with
legs at the frame edges. Alpha bounding box `(37, 0, 457, 477)` — the top
hump touches the very top edge of the canvas (y=0) while the bottom has
35px of clearance, the opposite of the bottom-cropped convention every
other scored portrait in this batch uses.

- **Framing (4):** the top-hump-and-sigil touches the top edge with zero
  clearance, while unused space sits below the subject — a crop that is
  tight on the wrong side relative to the rest of the cast's
  headroom-above / cut-at-bottom convention.
- **Identity (6):** the two-mass shape (small sigil-bearing hump above a
  larger shell) plus mandibled head reads as "armoured bug," but the two
  masses are close enough in brown value that they read as one lumpy
  silhouette rather than the two distinct plates the build intent
  describes — the same finding `husk_beetle.md`'s 3D pass made about
  silhouette/proportion (5/10 each, pre-fix).
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  gold sigil on the upper hump stays visible as a small bright dot against
  the brown, which helps orient the shape, but the two shell masses and
  the head all blur into one continuous brown blob with legs barely
  surviving at the edges.
- **Colour & separation (5):** shell, hump, and head are all close
  variants of the same reddish-brown; only the black legs, orange
  mandibles, and gold sigil break the palette. This is the weakest line
  and matches `husk_beetle.md`'s own pre-fix Colour & read finding (6/10)
  almost exactly.
- **Style consistency (6):** the head-and-shoulders convention is present
  in spirit, but the top-edge crop breaks the shared headroom convention
  the other portraits in this batch (`gloom_moth_portrait`) hold to.

## Diagnosis — two lowest

1. **Framing (4).** Concrete fix: pull `portraits.py`'s `FOCUS` centre up
   and/or widen the span slightly so the top hump clears the canvas edge
   with visible headroom, matching the convention every other scored
   portrait uses.
2. **Colour & separation (5).** Concrete fix: give the smaller top hump a
   distinct value or hue step from the main shell (a lighter tan, per
   `husk_beetle.md`'s own earlier fix proposal for the 3D silhouette
   problem) so the two segments separate by colour even where the
   silhouette does not fully break them apart.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the top-edge crop is a `FOCUS` table oversight (this asset never
having been re-tuned after the model's fixer pass changed its geometry) or
a deliberate choice — this scoring pass can see the clipped edge, not why
it's set that way.

---

## Pass 2 — fixer lane, 2026-09-01

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Both named fixes touch files in this lane's territory
(`tools/blender/husk_beetle.py`, `tools/blender/portraits.py`) — no `game/**`
GDScript touched.

| Pass | Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 4 | 6 | 6 | 5 | 6 | **27** |
| 2 | 7 | 7 | 7 | 7 | 6 | **34** |

### Both diagnosed fixes applied

- **Colour & separation (5 → 7).** The tail-plate ("top hump") was `BROWN`
  + `UMBER` — the same reddish-brown family as the main shell's own
  `UMBER`. `TAN` (`swatch(304,320)`, RGB 217,152,111, average value 160) was
  already imported in `husk_beetle.py` but never used anywhere in the file —
  recoloured both tail-plate balls (the `(0.0, 0.35, 2.02)` and
  `(0.0, 0.50, 2.24)` balls) from `BROWN`/`UMBER` to `TAN`, against the
  shell's `UMBER` (RGB 180,96,61, average value 112), a genuine ~50-point
  value gap rather than two swatches from the same warm-brown family. A
  fresh 34px downsample (Pillow `LANCZOS`, composited on the same
  `RGB(139,105,74)` brown card-face standin the icon batches use) shows the
  hump reading as a distinctly lighter tan blob against the shell, where
  the pass-1 downsample showed the hump barely separable from the shell —
  only the small gold sigil hinted a second part existed.
- **Framing (4 → 7).** `portraits.py`'s `FOCUS["husk_beetle"]` moved from
  `(0.42, 1.15)` to `(0.46, 1.20)` — raised the focus point toward the tail
  hump and widened the frame slightly. Alpha bbox (Pillow `getbbox()`) moved
  from `(37, 0, 457, 477)` — top touching y=0 outright — to
  `(46, 10, 449, 484)`, 10px of clearance above the hump on the 512×512
  canvas. Bottom margin shrank from 35px to 28px in trade, still
  comfortable, no clipping at either edge.

Rebuilt with `build.cmd husk_beetle` (1396/2600 tris, 1 mesh, every climb
Height and the sigil hold still `ok` — no warnings) then `build.cmd
portraits`, which regenerates all thirty-two portraits from Blender's
non-deterministic WORKBENCH renderer (same non-determinism
`silk_widow_portrait.md`'s and `thrasher_portrait.md`'s pass 2 both hit) —
every portrait other than `husk_beetle.png` was reverted with
`git checkout --` and only the changed asset kept.

- **Framing (4 → 7):** the top-edge-touching fault named in pass 1 is gone —
  confirmed by the alpha bbox above, not just eyeballed. Not higher: the
  margins are still asymmetric (46px left vs 63px right, 10px top vs 28px
  bottom) rather than evenly centred, the same reason `thrasher_portrait`'s
  pass 2 stopped at 8 rather than 9+.
- **Identity (6 → 7, side effect, not one of the two named lines):** the
  hump-vs-shell colour split reinforces the "two segments" read pass 1 said
  was missing — the render now shows a light mass and a dark mass rather
  than one lumpy silhouette with a sigil on it. Not higher: the two identity
  cues (tan hump, dark shell) still sit close together in the upper-centre
  of frame rather than one shape dominating it the way `frog_portrait`'s
  eyes do.
- **Readability @ 34px (6 → 7, side effect):** confirmed via a fresh 34px
  downsample, not claimed from the 512px render alone — the tan hump reads
  as a separate lighter shape at party-panel size, where pass 1's downsample
  showed it blurring into the shell.
- **Style consistency (6, unchanged):** neither fix touched the shared
  head-and-shoulders-adjacent convention or the build vocabulary; the number
  holds.

**+7 total (27 → 34), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether the tail-plate should be pushed one step lighter still (`WHEAT`,
also imported and also unused) for more separation, or whether `TAN` against
`UMBER` is enough — this pass picked the smaller step since the diagnosis
asked for "a distinct value or hue step," not a maximum one, and two shell
tones this close in hue but far in value risk reading as a lighting
artefact rather than a deliberate two-tone build at a glance. Also unsure
whether the still-asymmetric portrait margins (left/right, top/bottom) are
worth a further `FOCUS` nudge or are Nick's call, the same open question
`thrasher_portrait`'s pass 2 left standing.
