"""Clean the Meshy-refined (textured) Goblin Engineer into the shipped hunter
AI model. Same weld/orient/scale/decimate recipe `frog_ai_clean.py` proved on
the Frog, run against this hunter's own refine output. Exports straight to
`game/assets/3d/cast/goblin_mech_ai.glb` (the `<id>_ai` naming convention
`AI_ART`/`HUNTER_AI_ART` both use) plus the editable `.blend` beside the
other AI sources.

    blender -b --python tools/blender/ai/goblin_ai_clean.py -- <src.glb> <out_glb> <out_blend>
"""
import bpy, os, sys
from mathutils import Vector as V, Matrix

args = sys.argv[sys.argv.index("--") + 1:]
SRC, OUT_GLB, OUT_BLEND = args[0], args[1], args[2]

REF_H = 1.85           # current goblin_mech.glb's own height (feet to top), kept for isolated-render comparisons
TARGET_TRIS = 5200      # matches frog_ai's already-accepted overage (both well over the 1400 hunter budget)

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
body.name = "Body"
for o in list(bpy.data.objects):
    if o is not body:
        bpy.data.objects.remove(o)
me = body.data
me.transform(body.matrix_world)
body.matrix_world = Matrix.Identity(4)
report("mats", len(body.data.materials))
report("pre_tris", len(me.polygons))

bpy.context.view_layer.objects.active = body
body.select_set(True)
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.mesh.remove_doubles(threshold=0.004)
bpy.ops.object.mode_set(mode="OBJECT")

def bounds():
    vs = [v.co for v in me.vertices]
    return (V([min(c[i] for c in vs) for i in range(3)]), V([max(c[i] for c in vs) for i in range(3)]))

lo, hi = bounds()
me.transform(Matrix.Translation(-V(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))))
scale = REF_H / (hi.z - lo.z)
me.transform(Matrix.Scale(scale, 4))
me.update()
report("scale_factor", "%.4f" % scale)

if len(me.polygons) > TARGET_TRIS:
    m = body.modifiers.new("dec", "DECIMATE")
    m.ratio = TARGET_TRIS / len(me.polygons)
    bpy.ops.object.modifier_apply(modifier="dec")
report("tris", len(me.polygons))
report("mats_post", len(me.materials))

lo, hi = bounds()
report("dims", "%.3f x %.3f x %.3f" % (hi.x - lo.x, hi.y - lo.y, hi.z - lo.z))
report("feet_z", "%.4f" % lo.z)

for p in me.polygons:
    p.use_smooth = True

os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
bpy.ops.object.select_all(action="DESELECT")
body.select_set(True)
bpy.context.view_layer.objects.active = body
bpy.ops.export_scene.gltf(filepath=OUT_GLB, use_selection=True, export_format="GLB")
bpy.ops.file.pack_all()
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND, compress=True)
report("exported", OUT_GLB)
