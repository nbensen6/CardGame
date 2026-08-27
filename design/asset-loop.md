# The asset refinement loop

Adapted from `MD/asset-refinement-loop.md` for this project. Follow it for every
3D asset. The brackets in the template are filled in below; two rubric lines are
**changed**, and the changes are argued for rather than assumed — see "What was
changed and why".

Do **not** generate an asset in a single pass. Work on one asset at a time,
start to finish.

## The loop (max 4 passes per asset)

1. **Build / revise** — edit the asset's script in `tools/blender/`.
2. **Capture** — `tools\blender\look.cmd <asset> <pass>`. Six views into
   `design/renders/<asset>_pass<N>_*.png`.
3. **Look** — read the images back in. Describe what is actually there, not what
   the script was trying to make. **If you cannot see the render, stop and say
   so.** Do not continue blind.
4. **Score** — 1–10 on each rubric line, with a one-line justification each,
   into `design/progress/<asset>.md`.
5. **Diagnose** — name the two lowest lines and write one concrete fix for each.
   Concrete means "raise the eye domes 0.06 and pull them 0.10 apart so the
   silhouette has two bumps instead of one hump", not "improve the silhouette".
6. **Apply** — commit first, then apply **only those two fixes**. Do not restyle
   the whole asset.
7. Repeat from 2.

## Stop conditions

Whichever comes first:

- total ≥ **40/50**, or
- a pass gains fewer than 2 points (plateaued), or
- 4 passes done.

Then report: final score, the per-pass history, and the one thing you would fix
next given another pass.

40 is an average of 8. At this fidelity 8 is "shippable and good"; 10 is a
Kenney model that a professional made and sold, and chasing it on nineteen
characters is how the schedule dies.

## Rubric (1–10 each)

| Criterion | Question |
|---|---|
| **Silhouette** | Readable as this creature as solid black at 64px? Open `_sil.png` — do not judge this from a lit render. |
| **Proportion** | Do the masses read as the creature it is named after, and does it hold up beside the others at its size? |
| **Build hygiene** | Within budget, one mesh, one material, no floating islands, no part spaced away from the body, tris spent where the reading is. |
| **Colour & read** | Do the palette swatches separate the parts? Legible at **34px** in the party panel, not just at 512? Nothing dark-on-dark. |
| **Style consistency** | Does it sit beside the approved assets without looking like it came from a different game? |

## Hard constraints

- **Art direction:** Kenney low-poly, and this is measured rather than guessed —
  `tools/blender/dissect.py` on the real packs gives ~575 tris median, ~80% of
  faces smooth-shaded, ~30% of edges in a 25–50° bevel band, parts built from
  tubes, boxes and tapers. `tools/blender/kenney.py` is that vocabulary.
- **Reference:** the Kenney models still in `game/assets/3d/` as stand-ins, and
  `dissect.py` output. There is no reference image per creature — that is the
  single biggest quality ceiling here, and the template says so.
- **Poly budget** (`kenney.BUDGET`): hunter 1400, beast 2600, prop 500,
  ground 3600, tile 460, landmark 900, icon 700.
- **Engine target:** Godot 4.7. A build **must** end in `--import` or the game
  keeps drawing the old model — `build.cmd` does this and running Blender by
  hand does not.
- **Contract:** origin at base centre, **-Y forward** (every model faces -Y;
  portraits, icons and the fight camera all assume it), transforms applied, one
  joined mesh, one material, UVs pointing into the shared `colormap.png`.
- **Versions:** git, not `_v1.blend`. Commit before each Apply step so a pass
  that makes it worse is one `git revert` away. The scripts are the source; a
  `.blend` copy of generated output is not a version, it is a screenshot.

## Honesty rule

Never claim an improvement you have not seen in a render. If a pass made it
worse, say so and revert. This project has a history of the opposite: eleven
assets marked "NEEDS A PASS" that passed every automated check and were never
looked at by the thing that built them.

## What was changed and why

Two rubric lines from the template would have scored correct decisions here as
failures, and following them would have made the art worse:

- **"Topology — clean quads, no n-gons in deforming areas"** → **Build hygiene.**
  Nothing in this game deforms. Every asset is static, generated procedurally
  with bevel modifiers, and exported as triangles. N-gon and quad-loop rules are
  rules for things that bend. What the criterion is *for* — density in the right
  places, no junk — is kept.
- **"Materials & UVs — real PBR channels (not default grey), unwrapped without
  visible stretch"** → **Colour & read.** This project deliberately uses one flat
  512 palette atlas, one material, no PBR channels at all, and UVs that point at
  a swatch rather than unwrap a surface. Scoring "no PBR" as a failure would push
  toward per-asset materials and break the thing that makes the cast look like
  one game. What the criterion is *for* — does the colour work, at the size it is
  actually seen — is kept, and pinned to 34px, which is the size the party panel
  draws a portrait at.

The other three lines transfer unchanged.

## The upgrade not taken

The template suggests a fresh subagent as critic, on the grounds that
self-critique is biased toward "looks good". That is a real bias and the
suggestion is sound. Not doing it by default here because agent runs are
expensive on this plan and the first pass of looking has plenty of obvious
findings left in it. Worth doing once the easy findings run out — an agent that
sees only `_sil.png` and the rubric, and never learns what the thing was
supposed to be, is the strongest version of this loop.
