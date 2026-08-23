# Models as scripts

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

## Use Blender 4.1, not 5.2

Both are installed. 4.1 is what these scripts are tested against.
