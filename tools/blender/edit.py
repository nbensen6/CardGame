"""Open a model in Blender to look at or tweak by hand.

    tools\\blender\\edit.cmd frog            a hunter or a beast
    tools\\blender\\edit.cmd env crag_pup    a fight's ground
    tools\\blender\\edit.cmd map grass       an overworld tile
    tools\\blender\\edit.cmd blends          write .blend files for ALL of them

Why this exists rather than just double-clicking the file: **Blender cannot OPEN
a .glb.** glTF is an import format, not a save format, so `File > Open` will not
list one and double-clicking does nothing. There is also no .blend anywhere in
this project — the scripts in this folder are the source, and the .glb files are
their output.

So this imports the right file, frames it, turns on material preview so the
palette colours show, and starts the MCP socket so Claude can see the same scene
you are looking at.

`blends` is the other half of the answer: it writes a real .blend beside every
model in `tools/blender/blends/`, which you CAN double-click. Treat those as a
scratch copy to look at and experiment in — the script is still the source, and
rebuilding overwrites the .glb without touching your .blend.

When you want a hand edit to stick: File > Export > glTF 2.0, over the SAME path
the model came from, format glB. The game goes by filename, so there is nothing
to rewire. Then put a line at the top of that model's script saying the file is
now the source, so nobody rebuilds over your work.
"""
import bpy, sys, os, glob

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                    "..", ".."))
HERE = os.path.dirname(os.path.abspath(__file__))
FOLDERS = {
    "cast": os.path.join(ROOT, "game", "assets", "3d", "cast"),
    "env": os.path.join(ROOT, "game", "assets", "3d", "env"),
    "map": os.path.join(ROOT, "game", "assets", "3d", "hexown"),
}

args = sys.argv[sys.argv.index("--") + 1:]
kind = "cast"
if args and args[0] in FOLDERS:
    kind, args = args[0], args[1:]
elif args and args[0] == "blends":
    kind, args = "blends", args[1:]


def fresh():
    bpy.ops.wm.read_homefile(use_empty=True)


def write_blends():
    """A .blend for every model, in one folder, ready to double-click."""
    out = os.path.join(HERE, "blends")
    os.makedirs(out, exist_ok=True)
    made = 0
    for name, folder in FOLDERS.items():
        for path in sorted(glob.glob(os.path.join(folder, "*.glb"))):
            fresh()
            bpy.ops.import_scene.gltf(filepath=path)
            stem = os.path.splitext(os.path.basename(path))[0]
            dest = os.path.join(out, "%s-%s.blend" % (name, stem))
            bpy.ops.wm.save_as_mainfile(filepath=dest)
            made += 1
            print("BLEND", dest)
    print("WROTE %d .blend files to %s" % (made, out))
    print("These are a scratch copy to look at. The scripts are still the "
          "source: rebuilding replaces the .glb and leaves these alone.")
    bpy.ops.wm.quit_blender()


if kind == "blends":
    write_blends()
else:
    name = args[0] if args else ""
    path = os.path.join(FOLDERS[kind], name + ".glb")
    if not os.path.exists(path):
        have = sorted(os.path.splitext(os.path.basename(p))[0]
                      for p in glob.glob(os.path.join(FOLDERS[kind], "*.glb")))
        print("no %s model called %r. There is: %s" % (kind, name, ", ".join(have)))
        bpy.ops.wm.quit_blender()

    for o in list(bpy.data.objects):
        if o.type == "MESH":
            bpy.data.objects.remove(o, do_unlink=True)
    bpy.ops.import_scene.gltf(filepath=path)
    print("EDITING", path)

    def _setup():
        for area in bpy.context.screen.areas:
            if area.type != "VIEW_3D":
                continue
            area.spaces[0].shading.type = "MATERIAL"   # show the palette colours
            region = [r for r in area.regions if r.type == "WINDOW"][0]
            with bpy.context.temp_override(area=area, region=region,
                                           space_data=area.spaces[0]):
                bpy.ops.object.select_all(action="SELECT")
                bpy.ops.view3d.view_selected()
        try:
            bpy.ops.blendermcp.start_server()
            print("BLENDERMCP listening on port", bpy.context.scene.blendermcp_port)
        except Exception as e:
            print("BLENDERMCP not started:", type(e).__name__, e)
        return None

    bpy.app.timers.register(_setup, first_interval=1.0)
