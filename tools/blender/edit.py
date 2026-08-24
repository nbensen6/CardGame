"""Open one cast model in Blender, ready to tweak.

    tools\blender\edit.cmd goblin_mech

Imports cast/<name>.glb, frames it, turns on material preview, and starts the
MCP socket so Claude can see the same scene you are looking at.

When you are done: File > Export > glTF 2.0, save over the SAME path
(game/assets/3d/cast/<name>.glb), format glB. The game picks it up on the next
run — ui/cast.gd goes by filename, so there is no code to change.
"""
import bpy, sys, os

name = sys.argv[sys.argv.index("--") + 1]
root = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
path = os.path.join(root, "game", "assets", "3d", "cast", name + ".glb")

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
        with bpy.context.temp_override(area=area, region=region, space_data=area.spaces[0]):
            bpy.ops.object.select_all(action="SELECT")
            bpy.ops.view3d.view_selected()
    try:
        bpy.ops.blendermcp.start_server()
        print("BLENDERMCP listening on port", bpy.context.scene.blendermcp_port)
    except Exception as e:
        print("BLENDERMCP not started:", type(e).__name__, e)
    return None


bpy.app.timers.register(_setup, first_interval=1.0)
