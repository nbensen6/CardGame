# Models as scripts

`kenney.py` holds the machinery: the palette, the primitives, and the join /
scale / export at the end. Each hunter script is then just a list of ellipsoids
with a colour name against each — which is the whole point, because "make the
ears rounder" should be a one-line diff you can read.

    frog.py               vine_weaver.py
    mountain_climbers.py  goblin_mech.py

`frog_smooth.py` is an earlier higher-poly take on the Frog, kept because
switching styles should be one command rather than an archaeology dig.

Build one:

    "C:/Program Files/Blender Foundation/Blender 4.1/blender.exe" --background       --python tools/blender/goblin_mech.py --       "G:/Co Op Game/game/assets/3d/cast/goblin_mech.glb"

The filename IS the wiring: `ui/cast.gd` prefers `cast/<character_id>.glb` over
the Kenney stand-in, so exporting to the right name is the entire job.

Every file here builds one model and exports it straight to `game/assets/3d/cast/`.
No `.blend` file in the middle. That is the whole idea: a model written as code is
diffable, reviewable, and re-runnable, so "make the eyes bigger" is a one-line
change with a visible diff instead of a binary blob nobody can read.

Build the Frog:

    "C:/Program Files/Blender Foundation/Blender 4.1/blender.exe" --background \
      --python tools/blender/frog.py -- "G:/Co Op Game/game/assets/3d/cast/frog.glb"

Look at it, three angles, without opening Blender:

    "C:/Program Files/Blender Foundation/Blender 4.1/blender.exe" --background \
      --python tools/blender/preview.py -- \
      "G:/Co Op Game/game/assets/3d/cast/frog.glb" out.png

Then check it against the five pipeline rules in `design/blender-pipeline.md`:

    Godot_v4.7.1-stable_win64_console.exe --headless --path game \
      --script res://tools/assetcheck.gd -- file=res://assets/3d/cast/frog.glb

## Two rules the scripts have to keep

**Blender -Y is forward.** The glTF exporter turns Blender's -Y into the +Z that
Godot wants, so build the model facing -Y and the export lands facing the camera.

**Apply transforms before you scale, then apply again.** `join()` leaves the
result carrying the first part's object scale, so setting `scale = 1.5` on it
multiplies by `1.5 / that`, not by 1.5. Apply first and the number means what it says.

## Editing one by hand

    toolslender\edit.cmd goblin_mech

Opens that model in Blender, framed, in material preview, with the MCP socket
running so Claude can see the same scene. Export back over the SAME path
(`game/assets/3d/cast/<name>.glb`, format glB) and the game picks it up next
run — `ui/cast.gd` goes by filename, so there is nothing to rewire.

**One honest catch.** Re-running the build script overwrites your hand edits,
because the script does not know about them. So pick per model:

* **Small stuff — proportions, colours, position.** Say what you want changed
  and it goes in the script. Stays diffable, stays re-runnable, and a later
  "make the ears bigger" is still a one-line change.
* **Real modelling — new geometry, sculpting, anything the primitives cannot
  say.** Edit the `.glb` and the script retires for that model; its header gets
  a line saying the file is now the source, so nobody rebuilds over your work.

## Matching the Kenney style

Measured, not guessed. `dissect.py` takes a `.glb` apart and reports how it is
built — how many pieces, what shape each piece is, how hard its edges are:

    blender.exe --background --python tools/blender/dissect.py --       game/assets/3d/cast/bunny.glb game/assets/3d/cast/fox.glb

Run against Kenney's bunny and fox, three things come back:

* **~575 triangles**, and the low-poly look comes from the VERTEX COUNT, not
  from flat shading — 80% of the bunny's faces are smooth-shaded. Faceting a
  model is what makes it read as programmer art, not the triangle budget.
* **He bevels everything.** 246 of the bunny's 833 edges sit in the 25-50 degree
  band, which is the signature of a bevelled hard edge. This is why his boxes
  read as moulded plastic and ours read as debug volumes.
* **His parts are TUBES, BOXES and TAPERS.** The fox's ears narrow 0.23 -> 0.10
  along their length. He also reuses: the fox and the bunny share the same four
  legs and the same body sphere, vertex for vertex.

Against that, the models here as they stood in August 2026 were **every part an
ellipsoid** — the Frog classified as sixteen squashed spheres, and the Stone
Warden spent 3744 triangles, six times Kenney's entire budget, making spheres
rounder rather than making shapes. Detail was never a triangle problem. It was a
vocabulary problem.

## The vocabulary

    ball    an ellipsoid                     bodies, heads, joints
    box     a BEVELLED cube                  plates, slabs, blocks, machinery
    taper   a cone or frustum                snouts, horns, claws, ears, spikes
    wedge   a box with one end shrunk        beaks, jaws, fins, blades, boots
    limb    a tapered tube along a path      tails, vines, arms, legs, necks
    ring    a torus                          mouths, collars, bands

    mirror(fn)   build once, get both sides

`limb` is the one worth reading the source of. It threads a tube through a list
of points and carries the frame forward from one to the next, so the tube does
not spin around its own axis where the path turns. Built the naive way a tail
comes out looking like a drill bit.

**A box half-extent is not a sphere radius.** Swapping the numbers straight
across inflates every part by its corners — the Goblin's rig came out as a stack
of grey fridges he was hiding behind. Multiply the old radii by about 0.72.

Shading is decided by **angle**, not per part: every face is smooth, and an edge
sharper than `CREASE` (50 degrees, which is where Kenney's own edges split)
stops sharing a normal. So a sphere comes out soft and a box comes out crisp
from the same rule, and there is no `smooth=` to remember.

Colour still comes from **one material for the whole set**: a 512x512 palette
atlas, `colormap.png`, kept next to these scripts, with UVs pointing at a flat
swatch. Which is why a bunny and a koala batch together.

Two traps: the primitives already ship a `UVMap`, so `uv_layers.new()` gives you
a second layer named `UVMap.001` and the renderer keeps using the original
unwrap — write into `uv_layers[0]` instead. And set the texture node's
interpolation to `Closest`, or neighbouring swatches bleed into each other.

## What finish() shouts about

Two failures kept shipping because nothing was watching for them, so now
`finish()` prints and names both:

* **Parts that do not touch.** The Vine-Weaver stood on a spike with hoops
  orbiting it; the Goblin's fist hung 3cm clear of his forearm. `finish()` groups
  the parts by whether their bounds overlap and names any group that floats free.
  It is a loose test — two spheres can share a box corner without touching — but
  it catches the case that actually happens, which is a limb placed in mid-air.
* **The budget.** `BUDGET` in `kenney.py`: 1400 for a hunter, 2600 for a beast,
  500 for a prop. Over it, `finish()` says by how much. The Stone Warden shipped
  at 3744 and nobody noticed, because nothing was counting.

Neither is fatal. Both are meant to be read.

## Beasts carry their own climb

`beast.py` builds a Titan. A beast is not just a shape, it is a shape you CLIMB:
`bosses.json` says where the holds are, and a beast with no shelf where its data
claims one is a beast you climb by floating.

    from beast import Beast
    b = Beast("frost_sentinel", height=4.0)
    b.shelf(2, (0, -0.5), (0.75, 0.55), STEEL)   # a ledge at Height 2
    b.foot((0.0, -0.9, 0.6))                     # where the climb starts
    b.mark(at=(0.0, -0.5, b.z_for(7)), size=0.34)
    b.done(out_path(), name="FrostSentinel")

`shelf()` lands a ledge exactly where the contract wants one AND records where a
hunter stands on it. `done()` then runs Godot's own area test in Blender, so a
bad hold is a line in the build log rather than a hunter standing on air.

Every standing place is exported as an **empty named `climb_<Height>`**. glTF
carries empties through as plain nodes and Godot imports them as Node3D, so
`combat_3d.gd` reads the route out of the model: the art IS the climb data.
Move a shoulder in Blender and the hunter who stands on it moves too, with
nothing to keep in sync. Without them the view falls back to the bounding box,
which is how hunters used to hover in FRONT of a beast rather than on the
shelves it already had.

### span, and the bug it exists to stop

`z_for()` has to answer "how high is Height 3" while the script is still being
written, so it works from the range it is told the body occupies — `span`,
defaulting to the full `0..height`. Told wrong, every ledge and the sigil slide
by the same fraction and the beast still passes every other check.

The Crag Pup did exactly that for months: its shoulder shelf sat at 61% of its
body while its data said 49%, because the script asked for a 3.0-tall model and
only built 2.4 of it, and `finish()` scaled the difference back in. The hold
check passed anyway, on the body's own curvature.

So `done()` measures the real range and prints the line to paste back:

    SPAN MireSnapper: body is z 0.00..2.76 but span says 0.00..3.40. Every hold
    is off by up to 23% of the body. Paste this into the Beast():
    span=(0.00, 2.76)

## References

`design/art-references/` — drop pictures in, say which model. Its README is an
honest account of which kinds of reference change the result and which do not.
The short version: a model file beats three views, three views beat a
screenshot, and a screenshot beats a concept painting, because the ranking is by
how much can be MEASURED rather than by how good it looks.

## Use Blender 4.1, not 5.2

Both are installed. 4.1 is what these scripts are tested against.

## Driving a live Blender session

`blender-mcp` is installed. The addon opens a socket on `localhost:9876` and
Claude talks to it, so it can read the scene you have open, run code in it, and
screenshot your viewport.

Start Blender with the socket already listening — no menu hunting:

    tools\blender\open.cmd

The addon is installed for **both 4.1 and 5.2** and registers cleanly on both,
so use whichever you already have your preferences in.

`bmcp.py` speaks that socket directly, which matters because MCP tools only load
when a Claude session *starts*. If the `blender` tools are not available in a
session, this still works:

    python tools/blender/bmcp.py scene
    python tools/blender/bmcp.py obj Frog
    python tools/blender/bmcp.py code "import bpy; print(bpy.data.objects.keys())"

`get_viewport_screenshot` needs an explicit `filepath` param or it answers
"No filepath provided".

Scripts beat the socket for *building* a model — a script is diffable and
re-runnable. The socket is for working inside a file you already have open.
