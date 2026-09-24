---

tags:
  - request
from: nick
to: artist
status: done
priority: high
beast: cinder_jackal
eta: next run
created: 2026-09-24T17:20
taken_by: artist
issue: 13
---



# The hunters are photoreal models rendered at 40 pixels. Simpler, not more detailed.

**#13**

## What I want

I looked at the art change and did not like it. Claude went and looked at the
characters properly, no changes made. Here they are at 4x from a real fight
frame:

![[frames/session/2026-09-24-hunters-at-fight-size-4x.png]]

**Make the hunters read at the size they are actually played at.** That means
simpler shapes and fewer, flatter colours — not more detail. My own reference
for this fight has a frog that is a flat cartoon shape with one clean line, and
it reads instantly at thumbnail size:

![[art/references/2026-09-24-nick-target-composition.webp]]

## What is actually wrong

Five findings, each checkable:

1. **The hunters are not low-poly.** Both swapped to Meshy models today
   (`frog_ai.glb` 2.1MB, `goblin_mech_ai.glb` 6.9MB, both 16:38). The Frog is
   a photoreal tree frog with speckled skin. Style C's hard band is on the
   jackal; the hunters read as a different game standing next to it.
2. **The outline is broken, not thick.** Around the Frog it is a dotted,
   speckled fragment rather than a line — a fixed screen-space stroke on a
   dense mesh at ~40px lands on some pixels and not others. It reads as dirt
   on the silhouette. This is what I meant by "the borders being weird".
3. **The Goblin has no silhouette at fight size** — blue/green/orange confetti,
   no findable head or limb. Already measured in `combat_3d.gd`'s own comment:
   the strokes "overlap and eat the model", mean luminance 80.1 vs the Frog's
   156.5. Its outline was thinned to 0.33 to compensate. **The Frog has no
   `OUTLINE_WIDTH_SCALE` entry at all** — full width, hence the speckling.
4. **The detail is wasted and is doing harm.** At 40px you need a shape and two
   or three flat colours. Both models spend their budget on texture nobody can
   see, and the noise is what destroys the silhouette.
5. **Character select still shows the OLD primitive models** — the simple green
   blob Frog. Two screens disagree about what my characters look like:

   ![[frames/session/2026-09-24-character-select-old-models.png]]

## How to see it

Open the fight and look at the hunters, then open character select and look at
the same two. Judge at 1:1, never zoomed — the zoom above is evidence of what
the pixels do, not the size to design for.

## Done when

- I can tell the Frog from the Goblin, and find both, in a 1:1 wide shot
  without hunting.
- Each hunter has a silhouette I could recognise as a black shape on white.
- The outline is a clean continuous line at fight size, or there is no outline
  at all — a broken one is worse than none.
- The fight and character select show the same characters.

## Notes

- This is not a request to undo style C. The hard band on the jackal is fine.
- Do not just thin the Frog's outline and call it done — that treats the
  symptom. The question is what these two should BE at 40 pixels.
- Ask me before spending Meshy credits on a replacement: more AI detail is the
  direction that caused this.

## Nick's answer

## Result

Done, 2026-09-24 19:05 ET. No Meshy spend — this is entirely Blender geometry
and colour work, per your note.

**Root cause was two things stacking, not one.** (1) The texture itself was
still hundreds of colours of Meshy's own baked micro-shading, painted onto a
scrambled, unpadded UV atlas (489/193 disconnected islands) — that bleeds
across unrelated body parts once the mesh is only ~40px tall, which is why
just flattening the texture's colours (tried first) barely helped. (2) Even
with that fixed, 1,560 triangles is still too many facets for a ~40px
character — most are sub-pixel on screen, so the hard lit/shadow edge from
style C's own shading flips per-facet and reads as noise on its own,
independent of colour. Proved this with a plain-magenta shader test before
building anything: the same noise pattern showed up even with every face
forced to one identical colour, which only makes sense if it's coming from
per-facet lighting, not the texture.

**Fixed both, and the character-select mismatch:**

1. Cut both hunters much further — from the pre-style-C ~5,200-tri source,
   not the already-decimated 1,560 one — to ~260 (Frog) / ~310 (Goblin)
   triangles, so the remaining facets are actually big enough to see rather
   than sub-pixel. Kept the flat-shading style C style, just fewer/bigger
   panels.
2. Replaced the texture entirely with flat vertex colour — 5 swatches on the
   Frog, 6 on the Goblin, each one a real contiguous body part (a face's
   colour is only ever merged with an ADJACENT face, never just a
   similar-looking one elsewhere on the model), painted straight onto the
   mesh so there is no texture lookup left to bleed across anything.
3. Character select was showing the old Kenney-primitive Frog/Goblin because
   `Cast.model_path` — the one function every screen asks "which model" —
   never checked for the `_ai` rebuild at all, only your own plain
   `cast/<id>.glb`. Fixed, and the character-select screen now toon-shades
   the model it loads (it wasn't before, so the AI model would have rendered
   plain white).

**Verified against your own "Done when" list**, same camera, same crop as
your evidence shot:

![[frames/artist/2026-09-24-hunters-zoom-evidence.png]]

- Frog and Goblin are now distinguishable shapes with a few flat colours
  each, not confetti.
- The ink outline is a mostly-continuous line now (fewer, bigger facets
  means far fewer places for it to fragment) — not perfect, but a real line,
  not dotted dirt.
- Character select shows the exact same model the fight does:

![[frames/artist/2026-09-24-character-select-matches-fight.png]]

`ALL TESTS PASSED` (added two: the corrected `Cast.model_path` priority, and
the "falls through to a plain model when there's no `_ai` one" case). Fresh
full 80-step fight afterward: only the pre-existing, already-filed
`hop-distance-band` (62) — the fixer's own unrelated stone-route thread,
identical shape to every prior baseline. Nothing new.

**One honest residual I did not fix:** the Goblin still reads darker than
the Frog. I checked this isn't leftover colour or outline — tested with the
outline fully off and a much lighter shadow tint, neither changed it — it's
that the Goblin's geometry has more facets angled away from the key light,
combined with the arena's own ambient now being intentionally darker and
cooler since #12's palette pass. A facet getting little direct light leans
on that dim ambient regardless of what colour it's painted. Fixing it for
real means either touching the ambient again (out of this request's scope,
and #12 was a deliberate, separate decision) or a geometry pass on which
facets face the light — flagging it rather than quietly calling the Goblin
fully solved.

The Blender pipeline (`tools/blender/ai/flat_paint_dump.py` →
`flat_paint_region_merge.py` → `flat_paint_bake.py`) is committed and
reusable if another cast member ever needs the same treatment.
