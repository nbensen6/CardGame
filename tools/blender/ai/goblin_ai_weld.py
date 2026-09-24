"""Weld the raw remesh fragmentation on the shipped `goblin_mech_ai.glb`
(Build hygiene's real open item, per `goblin_mech_ai.md` pass 6: 489 raw
mesh islands, from Meshy's remesh boundaries never getting fully welded --
`goblin_ai_clean.py`'s own `remove_doubles(threshold=0.004)` ran BEFORE the
decimate step, and decimate moved vertices in the collapsed regions enough
to reopen small coincident-vertex gaps that were closed pre-decimate).

`mesh_gap_check.py` on the shipped model found only TWO islands with a real
(non-zero) gap to their nearest neighbour -- ~5.9mm and ~15.4mm out of 489 --
every other island sits at ~0mm from its neighbour: touching duplicate
geometry from the remesh, not real separation. A weld threshold picked
BELOW the smaller real gap merges only the touching duplicates and can
never bridge either genuine gap.

    blender -b --python tools/blender/ai/goblin_ai_weld.py -- <src.glb> <out_glb> <out_blend> [threshold_m]

Default threshold 0.005 (5mm) -- safely under the ~5.9mm smallest real gap
found by `mesh_gap_check.py`.
"""
import bpy, os, sys

args = sys.argv[sys.argv.index("--") + 1:]
SRC, OUT_GLB, OUT_BLEND = args[0], args[1], args[2]
THRESH = float(args[3]) if len(args) > 3 else 0.005

def report(k, v):
    print("REPORT %s %s" % (k, v))

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=SRC)
meshes = [o for o in bpy.data.objects if o.type == "MESH"]
if len(meshes) > 1:
    bpy.ops.object.select_all(action="DESELECT")
    for m in meshes:
        m.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
body = [o for o in bpy.data.objects if o.type == "MESH"][0]
me = body.data
me.transform(body.matrix_world)
body.matrix_world.identity()

report("pre_verts", len(me.vertices))
report("pre_tris", len(me.polygons))

bpy.context.view_layer.objects.active = body
body.select_set(True)
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.mesh.remove_doubles(threshold=THRESH)
bpy.ops.object.mode_set(mode="OBJECT")

for p in me.polygons:
    p.use_smooth = True

report("post_verts", len(me.vertices))
report("post_tris", len(me.polygons))
report("threshold_m", THRESH)

os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
bpy.ops.object.select_all(action="DESELECT")
body.select_set(True)
bpy.context.view_layer.objects.active = body
bpy.ops.export_scene.gltf(filepath=OUT_GLB, use_selection=True, export_format="GLB")
bpy.ops.file.pack_all()
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND, compress=True)
report("exported", OUT_GLB)
