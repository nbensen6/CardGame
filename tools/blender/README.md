# Models as scripts

`frog.py` builds the Frog that ships. `frog_smooth.py` is the earlier
higher-poly take, kept because switching styles should be one command rather
than an archaeology dig — that is the point of models being source.

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

## Matching the Kenney style

Read off the bunny rather than guessed at:

* **~575 triangles**, and the low-poly look comes from the VERTEX COUNT, not
  from flat shading — 78% of the bunny's faces are smooth-shaded. Faceting a
  model is what makes it read as programmer art, not the triangle budget.
* **One material for the whole set**: a 512x512 palette atlas, `colormap.png`,
  kept next to these scripts. Colour comes from UVs pointing at a flat swatch,
  which is why a bunny and a koala batch together.

So one mesh can be many colours. Aim a part's UVs at a swatch and everything
joins into a single mesh with a single material — the Frog is 876 triangles in
1 mesh, where the bunny needs 5.

Two traps: the primitives already ship a `UVMap`, so `uv_layers.new()` gives you
a second layer named `UVMap.001` and the renderer keeps using the original
unwrap — write into `uv_layers[0]` instead. And set the texture node's
interpolation to `Closest`, or neighbouring swatches bleed into each other.

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
