---
tags:
  - agent-status
agent: builder
updated: 2026-09-25T17:41
working_on: "goblin trim recolour handed to Nick"
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-25 17:41 EDT

- **Did:** Unified the Goblin's boots/shorts/strap/ear-tuft from four bright warm hues into one muted rust, so green (body) + blue (pack) read as the one silhouette, same as the Frog's own palette shape.
- **Worked?** Yes — the goblin-only crop shows 47% of its own pixels changed, boots and straps read as trim now instead of a third competing bright colour.
- **Look at:** ![[frames/builder/2026-09-25-goblin-reads-before.png]] then ![[frames/builder/2026-09-25-goblin-reads-after.png]]
- **Ask:** does this read as "one silhouette" now, or does the pack still need to shrink too?
- **Found:** the loose `goblin_mech_ai_Image_0.png` is gitignored and regenerated from the `.glb`'s embedded image on import — editing only that file (as a couple of the artist's own earlier passes did) does not survive a fresh checkout; the fix has to live in the `.glb` itself. Also: two screenshots of the identical, unchanged state differ by ~43,000 px in the background tent/box region alone — a real, large, pre-existing run-to-run render difference there, not just the small idle-animation jitter this project's notes usually describe; not chased, since it wasn't part of this item.

## Log

- 2026-09-25 17:41 EDT — builder: goblin trim (boots/shorts/strap/ear) recoloured to one muted rust, baked into goblin_mech_ai.glb's embedded texture; built, tested, pushed.
- 2026-09-25 17:26 EDT — builder: ground hunters face the beast, backs to camera, not the camera itself; built, tested, pushed.
- 2026-09-25 17:15 EDT — builder: hull built before the decorative stones, so mid-route hunters land on their own stone; built, tested, pushed.
- 2026-09-25 16:43 EDT — builder: sigil top hold uses each hunter's own route side, not the shared-foothold nudge; built, tested, pushed.
- 2026-09-25 16:31 EDT — session: top hold in front of the face, sigil shot lands; pushed.

- 2026-09-25 16:24 EDT — climb focus trusts the sigil's own anchor z and pitches down with climb_t; built, tested, pushed.
- 2026-09-25 16:11 EDT — climbing camera clearance reads the hold's local surface, not the beast box's front face; built, tested, pushed.
- 2026-09-25 15:55 EDT — one fixed camera stand-off, resting and climbing, built, tested, pushed.
- 2026-09-25 15:31 EDT — stones near-hunter fix built, tested, pushed.
- 2026-09-25 13:30 EDT — lane created; the four cloud agents and the board sync are off.
- 2026-09-25 13:27 EDT — F8 camera-toggle hotkey built, tested, pushed.
