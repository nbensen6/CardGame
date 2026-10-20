# What chasing the concept art cost the look

Nick, 2026-10-19: *"it looks boxed in and stones look weird. analyze things
that dont look right because we chased the concept art."*

`TARGET.png` is a **square illustration**. The game is a **16:9 3D scene**.
For weeks the only thing judged was the game's centred 720x720 square against
that picture — see [[DECISIONS]]. Everything below is a place where matching a
drawing produced something a drawing can get away with and a 3D camera cannot.

Measured on the frame, 2026-10-19, not eyeballed:
![[shots/2026-10-19-boxed-in.png|700]]

## 1. There is a hard seam down each side of the square

The sharpest vertical edges in the whole picture are at **x=279 and x=999** —
the left and right edges of the 720 square:

    x=278  edge 0.66
    x=279  edge 14.62      <- 5.5x the frame's average of 2.65
    x=280  edge 0.01
    x=999  edge 11.43

Brightness either side is near identical (19.0 vs 20.9), so this is not a
lighting gradient. It is a **one-pixel cut**, and it is why the scene reads as
boxed in: the picture visibly ends and something else begins.

**Where it comes from.** `cliff_flat.gdshader` fades distant wall toward the
sky's tone so the mid-ground is open, as TARGET draws it — but only near the
camera's centre line, so the two flank formations stay rock:

    uniform float lat_from = 1.0;
    uniform float lat_to   = 1.45;

That lateral cutoff was tuned to make the **square** match. On a 16:9 frame it
lands in plain sight. The fix is not a number: the rule should follow the
frame, or the flanks should be real formations with depth rather than a tone
rule applied to whatever wall happens to be there.

## 2. The flanks are dead, because nobody ever looked at them

Left of 279 and right of 999 there is no floor, no depth and no composition —
plus a few pieces of set (a red-lit block low right, a dark wedge low left)
that were never framed because they fell outside the judged area. A quarter of
the picture had no reviewer for a month.

## 3. The slabs are the painting's cheat, exposed

From `combat_3d.gd`:

> `SLAB_VIEW_TILT := 0.42` — *"TARGET.png looks DOWN onto every stone, even
> the ones at the beast's chest, so each shows its pale top; the fight camera
> sits at the hunter's height, below the upper stones, and showed only their
> dark under-edges. Leaning each slab's top toward the camera is the
> reference's own cheat."*

That is the whole problem in the comment that implements it. An illustrator
draws every stone from above because it reads better; it costs nothing because
nothing else in a painting disagrees. In a 3D scene the floor, the beast and
the camera all state a consistent perspective — and the slabs, rotated to face
the lens, **contradict all three**. They stop being objects in the space and
become stickers on the glass.

They also carry the painting's value into a darker scene: the near slab reads
**RGB (152, 129, 116) against a floor of (48, 34, 32)** — three times brighter
than everything around it, and the only neutral grey in a picture otherwise
made of fire and slate.

## 4. The jackal is pressed against a backdrop

The wall behind it is continuous and close, so the beast has nothing behind it
to be in front of. In the painting the backdrop is painted atmosphere; in 3D
the same arrangement reads as a flat behind an actor.

## What this is really a lesson about

A reference picture tells you **what the scene should look like**. It does not
tell you **what the scene is**. Copying a painting's compositional cheats —
its framing, its impossible angles, its flat backdrop — into a camera-driven
3D scene reproduces the cheats without the painting's permission to use them.

The useful next step is not to re-match anything. It is to decide what the
arena actually is — how wide, how deep, what is behind the beast, where the
stones hang and what holds them up — and let the painting inform the palette
and the mood rather than the geometry.

See [[PLAYABLE-MINUTE]] for the gameplay half of the same conversation.
