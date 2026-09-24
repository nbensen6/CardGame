"""Style C (Risk of Rain 2 / Hopoo Games — low-poly, flat-shaded), Nick
2026-09-24: decimate a shipped, already colour-patched AI-cast .glb and
switch it to FLAT shading so the facets read as the visual identity instead
of being smoothed away.

Same Decimate (Collapse) lever `design/progress/goblin_mech_ai.md` pass 8
already proved (ratio 0.3 on the Goblin Engineer lands right on the 1400-tri
hunter budget and visibly facets the tank and boots) — the only change here
is `use_smooth = False` instead of pass 8's default `True`. Pass 8 was
hiding the facets as a defect under the old smooth-toon style; this is
showing them on purpose, because under style C the facets ARE the style.

    blender -b --python tools/blender/ai/lowpoly_facet.py -- <src.glb> <out_glb> <out_blend> <ratio>

ratio is Blender's own Decimate ratio (0.3 = keep 30% of the tris). Run
against the SHIPPED .glb, never the older source .blend — the shipped file
carries colour patches (skin-saturation, tank-contrast, etc.) applied
straight to the exported texture that an older .blend would silently
revert.
"""
import bpy, os, sys

args = sys.argv[sys.argv.index("--") + 1:]
SRC, OUT_GLB, OUT_BLEND, RATIO = args[0], args[1], args[2], float(args[3])

def report(k, v):
    print("REPORT %s %s" % (k, v))

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=SRC)
body = [o for o in bpy.data.objects if o.type == "MESH"][0]
me = body.data
report("pre_tris", len(me.polygons))

m = body.modifiers.new("dec", "DECIMATE")
m.ratio = RATIO
bpy.context.view_layer.objects.active = body
bpy.ops.object.modifier_apply(modifier="dec")
report("tris", len(me.polygons))

for p in me.polygons:
    p.use_smooth = False
if hasattr(me, "free_custom_split_normals") and me.has_custom_normals:
    me.free_custom_split_normals()

os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
bpy.ops.object.select_all(action="DESELECT")
body.select_set(True)
bpy.context.view_layer.objects.active = body
bpy.ops.export_scene.gltf(filepath=OUT_GLB, use_selection=True, export_format="GLB")
bpy.ops.file.pack_all()
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND, compress=True)
report("exported", OUT_GLB)
