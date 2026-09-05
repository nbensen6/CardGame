# flicker_stag — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/flicker_stag.py`.** Views:
`design/renders/flicker_stag_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 7 | 7 | 5 | 8 | **33** |
| 2 | 6 | 7 | 7 | 8 | 8 | **36** |

## What is actually there

A tall, elegant stag: four long slender legs, an arched climbing neck, a
small deer head with a branching bone-coloured rack, and a low rounded
belly bulge tucked under the chest between the forelegs. Reads clearly as
"stag" in the 3/4 view — the intent (a tall creature built to look
different from the cast's low quadrupeds) comes through.

- **Silhouette** (`_sil.png`): the antler crown and legs read distinctly,
  but the chest/belly bulge sits close enough to the forelegs that their
  outlines merge into one mass near the shoulder, losing the "long slender
  legs" read the design calls for at that spot.
- **Proportion**: torso, neck, legs and rack all read as stag-proportioned
  and the animal genuinely looks tall and light rather than squat — the
  stated design goal lands.
- **Build hygiene**: 2022/2600 tris, one mesh, nothing obviously floating
  or clipping in the views captured.
- **Colour & read**: the module doc calls the belly ball CREAM against a
  RUST body specifically so it doesn't blend — in the lit renders it reads
  as a slightly darker brown than intended and sits close in value to the
  RUST torso and BROWN legs, so the "pale chest" doesn't separate the way
  the palette note says it should. Antlers (WHEAT/SAND) and the gold eye
  ring do pop cleanly.
- **Style consistency**: tapered legs and ball-torso construction match the
  rest of the cast (yoke_ox, cinder_jackal) without looking foreign.

## Diagnosis — two lowest

1. **Colour & read (5).** The CREAM belly ball reads too close in value to
   the surrounding RUST/BROWN warm tones to do the separating job the
   module doc says it's for. Concrete fix: shift the belly ball's palette
   entry toward a genuinely lighter, less saturated cream (raise its value
   noticeably, not just its hue) so it reads as a pale chest patch rather
   than another brown.
2. **Silhouette (6).** The belly ball's outline overlaps the foreleg
   region, merging chest and legs into one blob at 64px. Concrete fix: pull
   the belly ball back in Y by ~0.10–0.15 toward the torso centre so a gap
   opens between it and the forelegs in the black silhouette.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Pass 2 — fixer, applying pass 1's two proposed fixes

Views: `design/renders/flicker_stag_pass2_*.png`.

1. **Colour (5 → 8).** No per-part brightness control exists in this pipeline
   (colour is carried entirely by which palette cell a part's UV points at, in
   `kenney.Build._paint`), so "raise the value" had to mean picking a
   different named swatch rather than tuning CREAM itself — and `CREAM` (lum
   231 per `palette.py --report`) was already the second-lightest warm swatch
   in the atlas; only `WHITE` (lum 255, zero saturation) is genuinely lighter
   and less saturated. Swapped the belly ball from `CREAM` to `WHITE`,
   position unchanged. Rendered a same-camera before/after crop
   (`_tmp_cmp_orig.png` / `_tmp_cmp_coloronly.png`, not kept) and it is a real
   improvement: the patch reads as a distinct pale chest against the
   surrounding RUST/BROWN instead of another shade of brown. Kept.
2. **Silhouette (6 → 6, reverted).** Tried pulling the belly ball back in Y
   by +0.12 (toward the torso centre, within the suggested 0.10–0.15 range),
   combined with the colour fix, then rendered and compared against the
   original pixel-for-pixel. Two problems, both measured rather than
   guessed: (a) the ball's own Y half-extent is 0.78 — more than five times
   the suggested nudge — so even at +0.15 its front edge (would reach
   y≈-0.68) still doesn't clear the foreleg hip point at y=-0.58; the
   silhouette diff between pass 1 and this attempt was 628 pixels out of
   65536 (64×64), effectively noise, not a visible separation. (b) Worse,
   the shift tucked the ball far enough back that in the front view it
   retreats almost entirely behind/inside the torso mass, hiding the pale
   patch that fix 1 had just improved — a visible regression, confirmed by
   diffing front-view renders at matching pixels. Reverted this one change
   (kept the colour swap) and rebuilt; this file's Silhouette score is
   unchanged at 6. A fix that actually clears the hip point would need to
   move the centre by roughly +0.25, well outside the 0.10–0.15 the pass 1
   diagnosis proposed, or shrink the ball's Y radius — either is a bigger
   shape change than "pull it back", so leaving it rather than guessing past
   what was diagnosed.

`run_tests.gd`: ALL TESTS PASSED (fresh import, headless).

## Unsure about

Whether the antler tines read as branching or just as two straight sticks
at fight distance — the 3/4 view shows branching clearly, but the
silhouette view (where a player is actually judging threat at speed) is
much harder to parse. Also unsure whether the floating-orb read I initially
had on the belly ball was a genuine geometry gap or just a lighting/value
illusion from the render angle — noted as a colour issue above rather than
a hygiene one because the module doc's own description ("pale chest/belly,
lower") matches what's built; it's the palette value that isn't landing.
