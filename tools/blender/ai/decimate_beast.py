"""Decimate the rigged Cinder Jackal Body mesh while preserving skinning,
armature, animations and climb/ledge markers.

Run against the SHIPPED .glb (already carries every colour patch), not the
older source .blend.

    blender -b --python tools/blender/ai/decimate_beast.py -- <src.glb> <out_glb> <out_blend> <ratio> [flat]

ratio is Blender's Decimate ratio (0.22 keeps ~22% of Body's tris).
Pass "flat" as a 5th arg to also flat-shade (style C) the decimated mesh;
omit it to keep smooth shading for an A/B render comparison.
"""
import bpy, os, sys

args = sys.argv[sys.argv.index("--") + 1:]
SRC, OUT_GLB, OUT_BLEND, RATIO = args[0], args[1], args[2], float(args[3])
FLAT = len(args) > 4 and args[4] == "flat"


def report(k, v):
    print("REPORT %s %s" % (k, v))


bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=SRC)

body = next(o for o in bpy.data.objects if o.name == "Body")
rig = next(o for o in bpy.data.objects if o.type == "ARMATURE")
me = body.data
report("pre_tris", len(me.polygons))
report("pre_vgroups", len(body.vertex_groups))

m = body.modifiers.new("dec", "DECIMATE")
m.ratio = RATIO
# Run Decimate BEFORE the Armature modifier so it collapses the rest-pose
# mesh, not a pose-deformed one.
while body.modifiers[0].name != "dec":
    with bpy.context.temp_override(object=body):
        bpy.ops.object.modifier_move_up(modifier="dec")
bpy.context.view_layer.objects.active = body
with bpy.context.temp_override(object=body):
    bpy.ops.object.modifier_apply(modifier="dec")
report("tris", len(me.polygons))
report("post_vgroups", len(body.vertex_groups))

if FLAT:
    for p in me.polygons:
        p.use_smooth = False
    if hasattr(me, "free_custom_split_normals") and me.has_custom_normals:
        me.free_custom_split_normals()
report("flat_shaded", FLAT)

bpy.context.scene.frame_set(0)
os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
bpy.ops.object.select_all(action="DESELECT")
for o in bpy.data.objects:
    o.select_set(True)
bpy.context.view_layer.objects.active = rig
bpy.ops.export_scene.gltf(filepath=OUT_GLB, use_selection=True, export_format="GLB",
                           export_animations=True, export_animation_mode="ACTIONS",
                           export_skins=True, export_force_sampling=True, export_frame_range=False)
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
bpy.ops.file.pack_all()
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND, compress=True)
report("exported", OUT_GLB)
