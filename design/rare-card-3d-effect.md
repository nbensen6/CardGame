# The 3D card effect, for rares — parked, not forgotten

Nick sent [valdosh, "Blender 3D card effect - simplified
tutorial"](https://www.youtube.com/watch?v=B76I9mPd5lg) (10½ min) and asked to
keep it for the rares later. This is that note, written from the video's own
transcript so nobody has to watch it again to know whether it is worth doing.

## What the effect actually is

A card with a **hole cut through it** and a little scene sitting *behind* the
hole. From the front you look through the window into a diorama. As the card
turns, the objects inside have real parallax against the frame, because they
really are behind it.

It is the same instinct as Pokémon TCG Pocket's "immersive" cards — the camera
dives into the art and the illustration opens out into a scene — but achieved
with geometry rather than a compositing trick, and it loops.

For a game whose whole conceit is that you **climb up a Titan**, a rare card
whose window shows a hunter on a ledge with the beast behind them is about as
on-theme as a cosmetic can get.

## How it is built

1. **The card.** A plane, corners bevelled. A cube boolean'd through it makes
   the window. (He uses the BoolTool add-on; a plain Boolean modifier is the
   same thing.)
2. **The scene behind it.** Whatever should be in the window — he uses a
   sphere as a stand-in.
3. **Thickness.** Select the edge loop, extrude on Y. Extrude a second time to
   leave a wall behind the objects, so the window has a backdrop rather than
   showing the void.
4. **Two materials.** A main one, black. A second on the last extruded faces
   and the back face, and this is the trick — it is a **Holdout**.
5. **Holdout only on the OUTSIDE.** A Geometry node's **Backfacing** output
   drives a Mix Shader between Holdout and Emission. Outside the card the
   holdout wins, so with `Film > Transparent` on, the card's own body punches a
   transparent hole in the render. Inside, the emission (black) wins, so the
   inner walls of the window read as a solid dark box.

   That single node is the whole effect. Without it the card is either an opaque
   slab or fully see-through; the Backfacing split is what makes it a *window*.

6. **Parent everything inside to the card** (`Ctrl+P`, Object keep transform)
   before animating, or the frame turns and the contents stay put.

## The animation, and the part that is easy to get wrong

30 fps, and the loop is built out of **two renders composited together**:

- Frame 1: card edge-on, rotated 90° on Z. Keyframe rotation.
- Frame 60: rotate −180°. Keyframe.
- Frame 121 (**121, not 120**): rotate −180° again. The extra frame is what
  makes the loop seamless — with the first and last frame identical you get a
  visible hitch every cycle.
- Interpolation set to **Linear**, so it turns at a constant rate instead of
  easing in and out like a UI element.

Then: duplicate the card, delete the front faces, fill the back and the hole —
that is the **back side**. Render frames 1–60 with only the front side enabled,
then 61–120 with only the back side, and composite the two sequences into one.
You end up with 120 PNGs of a card turning all the way round.

## What it would take here, honestly

The output is **an image sequence**, not a live 3D card. That is good news and
bad news.

**Good:** this project already renders card assets in Blender headlessly —
`icons.py`, `portraits.py`, `frames.py`, `plates.py` all do it, and `build.cmd`
drives them. A `rares.py` that emits a sprite sheet per rare card is the same
shape of job as everything already here.

**Bad:** 120 frames per card is a lot of pixels. At 176×264 that is roughly
5.6M pixels per card before compression. For **rares only** that is affordable
— there are far fewer of them than the 187 total — but it does not scale to
every card, and it should not be attempted for one.

**The real cost is not the render, it is the art.** Each of these needs a built
scene behind the window, not just a picture. That is a modelling job per card.
Doing it for a handful of showpiece rares is a feature; doing it for all of them
is a different game.

## When to pick this up

Not yet, and the ordering matters:

1. Card art exists for a decent share of the 187 (see the Art view in the Card
   Lab). Cards need pictures before any of them need moving pictures.
2. The frame, banner, orb and pill have settled and stopped changing — the
   effect bakes the frame into every one of those 120 frames, so a frame change
   after the fact means re-rendering every rare.
3. There is a reason to want it: a shop that sells them, a reward that grants
   one, something that makes a rare feel earned. Right now `Card.foil` already
   carries the "this copy is special" flag and rolls at 14% on rares — that is
   the hook this would hang off.

Until then the foil shader (`game/ui/foil.gdshader`) is the cheap version of
the same idea, and it costs one pass over the card's own rectangle rather than
120 rendered frames.
