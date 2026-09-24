---

tags:
  - request
from: nick
to: artist
status: taken
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
