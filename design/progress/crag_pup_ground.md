# crag_pup (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83.
Filed as `crag_pup_ground` rather than `crag_pup` because a beast/companion
model of the same name already exists in `game/assets/3d/cast/` and may need
its own scoring file later. **Scoring pass only — item #83 is report, not
repair; no edits made to `tools/blender/env/crag_pup.py`.** Views:
`design/renders/crag_pup_pass1_*.png`, captured with `look.sh env crag_pup 1`.

Same rubric adaptation as `stone_warden_ground.md`: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 5 | 5 | 4 | 7 | **27** |

## What is actually there

A ring of dark, leaning slate slabs of varied width and height surrounds a
small rust/clay-coloured dished floor. Small dark rocks sit scattered near
the inner edge of the ring, visible mainly from above. As with
`stone_warden_ground`, the fight-camera-angle (`_34.png`) and profile
(`_side.png`) views are dominated by the ring — only a thin band of the
clay floor shows at the bottom — while the top view (`_top.png`) reveals the
dished gravel floor and scattered boulders the build script describes as
the ground's "read at a glance."

- **Silhouette** (`_sil.png`): an uneven, jagged-topped ring — reads as
  "broken/leaning rocks" more distinctly than stone_warden_ground's smoother
  wall-top does, which matches the script's "as if something shoved them"
  intent and is the strongest line here.
- **Proportion**: same issue as stone_warden_ground — the enclosure
  (`e.enclose("crag")`) plus the `arc=BACK` shard scatter together fill
  almost the whole frame from the fight-camera angle, so the floor identity
  the script names directly ("a pale gravel floor, boulders sunk into it")
  is only confirmable from the top view, not from the angle a player would
  actually see it at.
- **Build hygiene**: individual slabs vary in width, height and lean angle
  cleanly (no obvious repeated-tile look), and the small scattered rocks
  near the ring's inner edge look properly sunk rather than floating. Cannot
  confirm the gravel chips or scrub described in the script — like
  stone_warden_ground, they are essentially invisible from the angle that
  matters most.
- **Colour & read**: SLATE and GRAPHITE, both near-black, make up almost the
  entire visible mass in every angled view — the two materials the script
  uses specifically to distinguish "boulders" from "the broken ridge slabs"
  don't separate enough in value to read as two different things; the ring
  reads as one dark silhouette rather than a boulder field plus a ridge
  behind it. This is a slightly worse case of the same value-crowding
  stone_warden_ground shows.
- **Style consistency**: the leaning, irregular shard shapes correctly
  contrast with stone_warden_ground's cut rectangular blocks — "same stone,
  opposite hand," per the sibling script's docstring, actually lands when
  the two are compared.

## Diagnosis — two lowest

1. **Colour & read (4).** SLATE and GRAPHITE are too close in value to
   separate the boulders from the ridge slabs at a glance, and the whole
   ring reads as one dark mass at fight-camera distance. Concrete fix: none
   proposed here — this item reports rather than repairs, and a value-gap
   fix between two named palette colours is a call for whoever owns the
   palette.
2. **Proportion (5).** As with stone_warden_ground, the enclosure and BACK-
   arc shards together occupy nearly the whole angled frame, leaving the
   floor — the thing the script's own comment says should be the "read at a
   glance" — visible only from directly above. Not a single fixable number;
   flagged rather than diagnosed further.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Same camera-representativeness question as `stone_warden_ground.md`:
whether `look.py`'s bounds-derived three-quarter camera, calibrated for
single creatures, actually matches the real in-game fight camera's distance
and height for a ring this wide. Also unsure whether the small dark rocks
visible near the ring's inner edge in `_top.png` are the "boulders sunk into
it" the script's docstring names as the floor's main content, or the
separate `arc=ANY` GRAPHITE scatter — both read the same dark colour from
this camera and there is no way to tell them apart by eye alone.
