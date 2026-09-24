"""Flat vertex-colour hunter pipeline, step 1 of 3 -- request #13, 2026-09-24:
Nick found the low-poly hunters (frog_ai.glb, goblin_mech_ai.glb) still
carried their full photoreal Meshy texture, which reads as noise ("confetti")
at a hunter's real ~40px on-screen size. The fix is flat, per-face colour with
NO texture at all (a texture bleeds across unrelated UV islands once the mesh
is this small on screen; vertex colour can't, since the rasterizer fills a
triangle straight from its own colour, not a texture lookup). Chain:

    1. flat_paint_dump.py   (this file, Blender) -- per-face UV + adjacency
    2. flat_paint_region_merge.py (pure Python)   -- merge into K contiguous
       colour regions, sampling the SOURCE texture only to seed the colours
    3. flat_paint_bake.py   (Blender)             -- write those colours as
       real per-face vertex colour and export

Run against a SHIPPED, already-decimated cast .glb (lowpoly_facet.py) -- or,
for a much bigger cut (this request also found 1,560 tris is still too many
facets for a ~40px character: each is sub-pixel, so toon.gdshader's hard
lit/shadow edge flips per-facet and THAT reads as noise too, independent of
colour), re-run lowpoly_facet.py first with a much smaller ratio against the
pre-decimation ~5,200-tri source (`git show <pre-style-C commit>:path` gets
it back) so facets are big enough to actually see.

This script: one mesh state, per-face UV (for colour sampling) AND per-face
adjacency (after welding the flat-shaded export's duplicate-per-face vertices
back together), so the two never risk drifting out of index sync across
separate Blender runs.

    blender -b --python flat_paint_dump.py -- <src.glb> <out_json>
"""
import bpy, bmesh, sys, json

args = sys.argv[sys.argv.index("--") + 1:]
SRC, OUT_JSON = args[0], args[1]

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=SRC)
body = [o for o in bpy.data.objects if o.type == "MESH"][0]
me = body.data

bpy.context.view_layer.objects.active = body
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.mesh.quads_convert_to_tris(quad_method="BEAUTY", ngon_method="BEAUTY")
bpy.ops.object.mode_set(mode="OBJECT")

uv_layer = me.uv_layers.active.data
tris = []
for p in me.polygons:
    assert len(p.loop_indices) == 3
    tris.append([list(uv_layer[li].uv) for li in p.loop_indices])
n_faces = len(tris)

bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.mesh.remove_doubles(threshold=0.0001)
bpy.ops.object.mode_set(mode="OBJECT")
assert len(me.polygons) == n_faces, "remove_doubles changed the face count/order"

bm = bmesh.new()
bm.from_mesh(me)
bm.faces.ensure_lookup_table()
assert len(bm.faces) == n_faces

pairs = []
for f in bm.faces:
    for e in f.edges:
        for nf in e.link_faces:
            if nf.index != f.index:
                pairs.append([f.index, nf.index])

print("REPORT faces", n_faces, "pairs", len(pairs))
json.dump({"uvs": tris, "adjacency": pairs}, open(OUT_JSON, "w"))
