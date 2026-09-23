# The 3D card effect, for rares — BUILT 2026-09-01

> **Status.** No longer parked. `tools/blender/rare3d.py` renders it and
> `CardView` plays it back. Everything below the line is the original note,
> written from the video before anything was built; it is kept because the
> reasoning in it is still the reasoning, and because two of its three
> objections were answered by changing the design rather than by waiting.
>
> **What shipped, and how it differs from the tutorial:**
>
> - **Only the window's contents are rendered, never the card.** The tutorial
>   bakes the card body into every frame. Here the sheet is exactly what is
>   inside the hole; card_view's real banner, cost orb, type and rules draw on
>   top of it, live. This kills the "re-render every rare when the frame
>   changes" objection outright — a frame change does not touch a sheet — and it
>   is the only construction that works inside a Control, where the furniture
>   must not turn with the picture.
> - **24 views, not 120 frames.** It is not an animation. The sheet is an ANGLE
>   LOOKUP: `CardView._turn_window()` picks the view from the same `tilt` the
>   foil shader uses — pointer on a desktop, accelerometer on a phone. A loop
>   reads as a GIF stuck to the card; tracking the hand reads as an object being
>   turned, which is what the tutorial's card actually does.
> - **A shear, not an off-axis camera.** The textbook construction — perspective
>   camera sliding sideways, lens shifted to pin the aperture plane — was built
>   first and thrown away: the end views came back 45% black. Under an
>   orthographic camera a turn is exactly a shear (each plane slides in
>   proportion to its depth, the window's reveal opens by the same amount), it
>   needs no calibration, and every number ends up measured in card-widths.
> - **Cost.** One 1860×1740 sheet per card, about 4 MB on disk. The parked note
>   worried about 120 frames at 176×264; 24 views at 310×435 is a fifth of the
>   pixels and looks better, because the resolution went into the cell instead
>   of into the frame count.
> - **The art requirement is different.** Not a modelled diorama — one 620×870
>   painting, the same export as every other card, with its subject kept inside
>   the middle ~80% (the edges hang outside the window by construction). An
>   optional `--fg` PNG with alpha adds a second plane near the glass, and THAT
>   is where it stops being a wobble and becomes a diorama.
>
> The third objection stands and was not designed away: **each of these still
> wants art made for it.** One painting is cheap; a foreground plate that reads
> as depth is a deliberate composition. Worth doing for a handful of showpiece
> rares, not for 187 cards.

---

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
