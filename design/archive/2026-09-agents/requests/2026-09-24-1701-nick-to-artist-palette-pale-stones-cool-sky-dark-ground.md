---

tags:
  - request
from: nick
to: artist
status: done
priority: high
beast: cinder_jackal
eta:
created: 2026-09-24T17:01
taken_by: artist
issue: 12
---



# The palette in the reference is the point: pale stones, cool sky, dark ground

**#12**

## What I want

Same reference as #11 (the fixer's composition ticket):

![[art/references/2026-09-24-nick-target-composition.webp]]

Style C's hard shading is right and stays. What is wrong is that the fight is
now ONE colour — floor, walls and beast are all the same orange-brown, so
nothing separates from anything. The reference solves that with three values,
and those are what I want:

- **The stones are pale, nearly white.** They are the brightest thing in the
  picture after the beast's own heat, which is exactly why the path reads at a
  glance. Ours are basalt brown against brown ground.
- **The ground is dark.** Almost black in the foreground. It is what makes both
  the pale stones and the hot beast pop.
- **The sky is cool — purple into pink.** It is the only reason the orange
  beast reads as hot rather than as more of the same.

## How to see it

Click the link above and look at the wide shot: everything in the same orange
family, no value separation.

## Done when

- A wide shot where the stones are unmistakably the lightest thing on screen,
  the ground is clearly darker than both, and the backdrop is not orange.
- Nick can tell the stones from the ground from the beast in a thumbnail.

## Notes

- Do not undo style C. This is the palette pass on top of it.
- Geometry is the fixer's (#11); this is colour and value only.

## Nick's answer

## Result

Done, 2026-09-24 17:24 ET. Colour and value only, geometry untouched, exactly
as scoped.

- **The floor was the actual culprit.** The wall was already dark (CHARCOAL)
  — only the ground disc was still warm UMBER, which is what made the whole
  arena read as one orange-brown mass. Changed it to CHARCOAL, both in
  `tools/blender/env/cinder_jackal.py` (the source recipe) and, because the
  game actually loads a separate hand-combined file for this fight
  (`cinder_jackal_ai.glb` — a Meshy wall + a procedural floor, see
  `tools/blender/ai/cinder_jackal_env_ai.py`), rebuilt that Floor mesh fresh
  from the same updated recipe and recombined it with the existing Wall
  (untouched, no Meshy spend).
- **The floating footholds went from basalt-brown to pale, near-white** —
  `game/views/combat_3d.gd`'s `_build_float_stones`, both the body and the
  lit top cap.
- **The sky, ambient and fog for this fight only** (`quarry_ember`, scoped to
  `cinder_jackal` alone via `BEAST_BIOME`) moved from a warm tan/dust family
  to a cool purple-into-pink dusk, colours sampled directly off your
  reference image's own pixels.
- The beast's own key light stays warm on purpose — it's still supposed to
  be the hottest thing in frame, just against a cool backdrop now instead of
  a warm one.

Verified: fresh `ALL TESTS PASSED`, a full 80-step fight with only the
pre-existing, already-filed `hop-distance-band` failing (unrelated, the
fixer's own stone-route thread — no new fails anywhere). Looked at real
frames, not just checks — wide shot, the sigil close-up, and a 160x90
thumbnail all show the pale stones as the clear lightest thing on screen, the
ground clearly darker than both stones and beast, and the sky/backdrop cool
rather than orange.

![[frames/artist/2026-09-24-palette-wide-before-after.png]]
![[frames/artist/2026-09-24-palette-grip-before-after.png]]
![[frames/artist/2026-09-24-palette-climb-after.png]]
