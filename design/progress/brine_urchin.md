# brine_urchin — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/brine_urchin.py`.** Views:
`design/renders/brine_urchin_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 4 | 6 | 8 | 8 | 7 | **33** |

## What is actually there

A spined red ball clamped to a grey rock base by four short tendrils, with
tapered spines at odd radial angles tipped in violet/iris balls, and a gold
sigil disc mounted in a socket on one flank. The top-down view reads
clearly as a sea-mine/urchin silhouette with all eight spines visible and
evenly spread; the 3/4 and side views read much weaker.

- **Silhouette** (`_sil.png`): only two or three of the eight spines show
  up as black silhouette spikes at 64px — the rest point close enough
  toward or away from this camera angle that they foreshorten to almost
  nothing, so the body reads as a plain round blob rather than a spined
  urchin.
- **Proportion**: the body itself is a near-perfect sphere with no clear
  front, face, or asymmetry beyond the sigil socket — from the fight's
  default angle it reads closer to a spiked mine than a creature with a
  face, even though the module doc calls out "a single glowing eye/mouth at
  the crown."
- **Build hygiene**: 1768/2600 tris, one mesh, spines and tendrils both
  join the body cleanly in `_form.png` with no floating islands or gaps.
- **Colour & read**: CORAL/BRICK body against VIOLET/IRIS spine tips and a
  STONE base gives three clearly separated zones even at small size; the
  gold sigil pops cleanly against the red body.
- **Style consistency**: round-plus-taper construction fits the rest of the
  cast; the mine-like read is more a proportion/silhouette issue than a
  style mismatch.

## Diagnosis — two lowest

1. **Silhouette (4).** Most spines foreshorten to points from the
   game's actual viewing angle instead of projecting sideways into the
   outline. Concrete fix: rotate a few of the spines (particularly the pair
   nearest the front-facing axis) by roughly 20–30° around Z so more of
   them read as visible spikes crossing the silhouette rather than dots.
2. **Proportion (6).** The body reads as a generic spiked sphere with no
   face cue at fight distance, despite the module doc's intent of a
   glowing eye/mouth at the crown. Concrete fix: enlarge the socket the
   gold sigil sits in by roughly 30%, or darken its rim, so it reads as an
   eye/mouth from the default fight camera rather than only up close.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the "sea mine" read is actually a problem — the boss's `at_sigil`
+ `attack_all` mechanic (punish reaching the sigil alone) has real
menace-as-a-device logic behind it, and a mine-like silhouette might
support that better than a face would. Flagging it as a proportion finding
rather than assuming the fix; a design call, not a measurement. Also unsure
whether the tendrils gripping the base read as "clinging" at fight
distance or just as short stubby legs — could not tell from these six
views alone.
