# Art waiting for a second pass

Anything the cloud routine builds in Blender lands here, because a run has no
display and cannot judge what it made. It can prove a model meets the contract —
holds where the data says, sigil at its Height, budget, one mesh, one material —
and it renders three angles so a human can look. It cannot tell you the thing is
a murky blob, or that the base reads as a spring, or that the sigil is hidden
behind the head. Every one of those got past every automated check we had.

So: the routine BUILDS and PROVES. We LOOK.

## How a run adds to this

One block per asset, newest at the top, appended by the run that made it:

```
### <name> — NEEDS A PASS
- built: 2026-08-25 by the routine, from tools/blender/<name>.py
- checks: assetcheck 4/4, holds PASS (3 holds + sigil), 2140 tris, 1 mesh, 1 material
- previews: design/art-previews/<name>_0.png (three-quarter), _1.png (front), _2.png (side)
- intent: one or two lines on what it was TRYING to be, so a reviewer can judge
  it against that rather than against a guess
- unsure about: whatever the run could not verify — silhouette, colour, whether
  the shape reads at fight distance. Say it plainly; this is the useful part.
```

Move the heading to `### <name> — DONE` once someone has looked and either
accepted it or done the pass. Do not delete the block: what a first pass got
wrong is the most useful thing in this file for the next one.

## What a reviewer is actually looking for

The failures that have happened, all of which passed every check:

- **Too dark to read.** The Stone Warden's two zones were dark and darker, so the
  seam that exists to explain its limiter was invisible.
- **Parts that do not touch.** The Vine-Weaver stood on a spike with hoops
  orbiting it; the Goblin's arm was spaced at arm's length and read as a rock
  standing beside him.
- **Detail hidden behind other detail.** The Warden's sigil sat on the crown
  behind its own head, invisible from the angle you fight it.
- **Slabs that overhang the silhouette**, reading as handles bolted on rather
  than as ledges cut from the body.

---

*(no entries yet — the routine has not built anything here)*
