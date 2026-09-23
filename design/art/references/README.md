# Drop references here

Put pictures in this folder and say which model they are for. They get read
before the next pass on that model, and they change the result a lot — the
difference between "make it look better" and "make it look like THIS" is about
four wasted iterations per model.

What follows is not a wish list. It is an honest account of what a reference
does and does not fix, so you can spend two minutes finding the right kind
instead of twenty finding a beautiful one.

## What a reference actually changes

Models here are built by **code that places shapes** (`tools/blender/*.py`).
Nothing is traced, sculpted or scanned. So a reference cannot be copied — it is
read for measurements, and those measurements go into the script.

**What it fixes, reliably:**

* **Proportion.** Head against body, limb against torso, how far a snout sticks
  out. This is where nearly all of the "it looks off" comes from, and it is the
  thing that is impossible to guess and trivial to measure.
* **Silhouette.** What the shape reads as from forty pixels away, which is the
  size a hunter actually is when it is standing on a Titan's ankle.
* **Which details carry the character** and which are noise. A frog needs
  bulging eyes and splayed toes; it does not need nostrils, but nostrils are
  cheap so they went in anyway.
* **Palette.** Which of the atlas swatches, and where the light one goes.

**What it does not fix:** anything needing geometry the vocabulary cannot say.
The vocabulary is in `tools/blender/kenney.py` — ellipsoids, bevelled boxes,
cones, wedges, tubes along a path, tori. That is a real range, but it is not
sculpting, and a reference full of cloth folds and muscle striation just makes
the gap more obvious.

## Best kind first

1. **A model file in the target style — `.glb`, `.gltf`, `.obj`, `.fbx`.**
   By a distance the most useful thing you can hand over, because it can be
   *measured* rather than looked at. `tools/blender/dissect.py` takes one apart
   and reports how it is built: how many pieces, whether each piece is a tube or
   a taper or an ellipsoid, how hard its edges are, where its triangles went.
   Everything this project now knows about the Kenney style came out of running
   that against `cast/bunny.glb` and `cast/fox.glb`.

2. **Three views of one thing: front, side, three-quarter.** Proportion comes
   from the front, depth comes from the side, and the three-quarter says whether
   the two agree. One view is a guess about the other two, and the guess is
   usually wrong — the Goblin's rig looked right from the front and read as a
   stack of crates from the corner.

3. **A screenshot of a game whose look you want.** Genuinely useful, and the
   easiest to get. Say what you are pointing at: "this palette", "this amount of
   detail", "heads this big" — a bare screenshot leaves the most important part
   to a guess.

4. **A single concept painting.** Least useful, however good it is. It shows one
   angle, usually a dramatic one, with lighting doing most of the work, and
   nothing about the back.

## What to say with it

The filename is enough if it is obvious (`frog-side.png`). Otherwise one line:
which model, and what about the picture you want. "The proportions, not the
colours" saves a whole pass.

## The current honest weak spots

Where a reference would pay for itself immediately, in order:

* **The Goblin Engineer's rig arm.** The strongest thing about the design is
  that one arm is enormous, and it still reads as boxes stacked beside him
  rather than as an arm attached to him. Any picture of a mech arm, a piston
  claw or a power loader would settle it.
* **The eleven beasts with no bodies yet.** They are Kenney farm animals. Any
  pointer at the kind of creature each should be is worth more than a paragraph
  of description, because "menacing" measures nothing.
* **Card icons.** 25 icons across 155 cards. What an icon set should look like
  is a taste call, and a reference sheet decides it in one go.
