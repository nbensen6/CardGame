"""Flat vertex-colour hunter pipeline, step 3 of 3 (see flat_paint_dump.py).
Per-face flat VERTEX colours instead of a baked texture -- a baked flat
TEXTURE still bled between unrelated UV islands at the hunters' real
on-screen size (~40px): a fine mesh's texture-space derivative forces a
blurry mip level that averages colour across whatever happens to sit next to
it in the packed atlas, which is scrambled (489/193 disconnected islands, see
goblin_mech_ai.md pass 9). Vertex colour has no such lookup: the rasterizer
fills each triangle with its own flat colour straight from mesh data, at any
distance, with zero texture-space bleed.

Reads a JSON of {face_index: [r,g,b] 0-255} produced by
flat_paint_region_merge.py, assigns it to every loop of that face, swaps the
material's texture for a flat white 1x1 (so ALBEDO = tint * COLOR, see
toon.gdshader's own comment), and exports.

    blender -b --python flat_paint_bake.py -- <src.glb> <colors.json> <white_1x1.png> <out_glb> <out_blend>
"""
import bpy, os, sys, json

args = sys.argv[sys.argv.index("--") + 1:]
SRC, COLORS_JSON, WHITE_PNG, OUT_GLB, OUT_BLEND = args

def report(k, v):
    print("REPORT %s %s" % (k, v))

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=SRC)
body = [o for o in bpy.data.objects if o.type == "MESH"][0]
me = body.data

bpy.context.view_layer.objects.active = body
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.mesh.quads_convert_to_tris(quad_method="BEAUTY", ngon_method="BEAUTY")
bpy.ops.object.mode_set(mode="OBJECT")

colors = json.load(open(COLORS_JSON))
report("faces_in_json", len(colors))
report("polygons", len(me.polygons))
assert len(colors) == len(me.polygons), "face count mismatch vs the UV dump this JSON was built from"

vc = me.color_attributes.new(name="Col", type="BYTE_COLOR", domain="CORNER")
me.color_attributes.active_color = vc
for p in me.polygons:
    c = colors[str(p.index)] if str(p.index) in colors else colors[p.index]
    rgba = (c[0] / 255.0, c[1] / 255.0, c[2] / 255.0, 1.0)
    for li in p.loop_indices:
        vc.data[li].color = rgba

mat = me.materials[0]
nt = mat.node_tree
img_node = None
bsdf = None
for n in nt.nodes:
    if n.type == "TEX_IMAGE":
        img_node = n
    if n.type == "BSDF_PRINCIPLED":
        bsdf = n
white_img = bpy.data.images.load(WHITE_PNG)
white_img.pack()
img_node.image = white_img

# The exporter only emits COLOR_0 when the MATERIAL's own node tree reads
# the colour attribute (mesh data alone isn't enough) -- wire it into Base
# Color so gltf2_blender_gather_primitives_extract.py's vc_info detects it.
vcol_node = nt.nodes.new("ShaderNodeVertexColor")
vcol_node.layer_name = vc.name
nt.links.new(vcol_node.outputs["Color"], bsdf.inputs["Base Color"])

os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
bpy.ops.object.select_all(action="DESELECT")
body.select_set(True)
bpy.context.view_layer.objects.active = body
bpy.ops.export_scene.gltf(
    filepath=OUT_GLB, use_selection=True, export_format="GLB",
    export_colors=True,
)
bpy.ops.file.pack_all()
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND, compress=True)
report("exported", OUT_GLB)
