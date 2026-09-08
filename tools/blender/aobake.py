"""Bake ambient occlusion into a model's vertex colours.

    blender --background --python tools/blender/aobake.py -- <in.glb> <out.glb> [rays] [reach]

Why this exists, 2026-09-08. Every beast in this game renders on one material,
one flat palette swatch per part, roughness 1.0, no normal map, no AO, and no
custom shader -- see kenney.py's material setup. That is a matte flat-coloured
blob by construction, and it is why six beasts each gained three points of
geometry polish and still looked like an asset pack. The models were never the
problem.

The project targets `gl_compatibility` for mobile readiness (CLAUDE.md), which
rules out SSAO and SDFGI -- the usual places cheap depth comes from. Vertex
colours work everywhere, on every renderer, at no runtime cost, so this is
where the crevice shading has to live.

WHAT IT DOES

Post-processes an already-exported .glb rather than touching kenney.py, which
is shared by every asset and belongs to the fixer lane. Non-destructive: reads
one file, writes another.

For every vertex it fires `rays` samples over the cosine-weighted hemisphere
around the normal and measures what fraction hit the model itself within
`reach` (a fraction of the model's own size). That fraction is the occlusion.
The result goes into a CORNER byte colour attribute, which the glTF exporter
writes as COLOR_0 and Godot reads into `COLOR` in a spatial shader.

Analytic rather than a Cycles bake on purpose: no render engine to configure,
no bake margins or UV requirements, deterministic output, and it runs in
seconds on a 1200-triangle model.
"""
import bpy
import sys
import os
import math
import random
import mathutils
from mathutils.bvhtree import BVHTree


def args():
    a = sys.argv[sys.argv.index("--") + 1:]
    if len(a) < 2:
        print("usage: aobake.py -- <in.glb> <out.glb> [rays] [reach]")
        sys.exit(1)
    rays = int(a[2]) if len(a) > 2 else 64
    # reach is a fraction of the model's own diagonal. 0.35 was the first guess
    # and it was far too big: at that radius almost every vertex sees another
    # part of the body, the darkest vertex came out at 0.00, and the beast went
    # from flat to a black mass in the fight. AO wants to find CREASES -- where
    # a leg meets a belly -- not measure the whole silhouette.
    reach = float(a[3]) if len(a) > 3 else 0.10
    return os.path.abspath(a[0]), os.path.abspath(a[1]), rays, reach


def hemisphere(n, count, rng):
    """Cosine-weighted directions around `n`. Cosine weighting matters: a
    uniform hemisphere over-samples the grazing angles that contribute least
    and gives a flat, washed-out result."""
    # Any vector not parallel to n gives us a tangent frame.
    up = mathutils.Vector((0.0, 0.0, 1.0))
    if abs(n.z) > 0.9:
        up = mathutils.Vector((1.0, 0.0, 0.0))
    t = n.cross(up).normalized()
    b = n.cross(t)
    out = []
    for _ in range(count):
        u1, u2 = rng.random(), rng.random()
        r = math.sqrt(u1)
        theta = 2.0 * math.pi * u2
        x, y = r * math.cos(theta), r * math.sin(theta)
        z = math.sqrt(max(0.0, 1.0 - u1))
        out.append((t * x + b * y + n * z).normalized())
    return out


def main():
    src, dst, rays, reach_frac = args()

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=src)

    meshes = [o for o in bpy.data.objects if o.type == "MESH"]
    if not meshes:
        print("AOBAKE: no mesh in %s" % src)
        sys.exit(1)
    if len(meshes) > 1:
        bpy.ops.object.select_all(action="DESELECT")
        for o in meshes:
            o.select_set(True)
        bpy.context.view_layer.objects.active = meshes[0]
        bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active or meshes[0]
    me = ob.data

    # Work in world space so the reach distance means the same thing whatever
    # transform the export left on the object.
    mw = ob.matrix_world
    nw = mw.to_3x3().inverted().transposed()
    verts = [mw @ v.co for v in me.vertices]
    norms = [(nw @ v.normal).normalized() for v in me.vertices]

    lo = mathutils.Vector((min(v.x for v in verts), min(v.y for v in verts),
                           min(v.z for v in verts)))
    hi = mathutils.Vector((max(v.x for v in verts), max(v.y for v in verts),
                           max(v.z for v in verts)))
    reach = (hi - lo).length * reach_frac
    eps = (hi - lo).length * 0.002

    tris = []
    poly_verts = []
    for p in me.polygons:
        idx = list(p.vertices)
        poly_verts.append(idx)
        for i in range(1, len(idx) - 1):
            tris.append((idx[0], idx[i], idx[i + 1]))
    bvh = BVHTree.FromPolygons([tuple(v) for v in verts], tris, all_triangles=True)

    rng = random.Random(1234)          # deterministic: same model, same bake
    occ = [0.0] * len(verts)
    for i, (p, n) in enumerate(zip(verts, norms)):
        origin = p + n * eps
        hits = 0
        for d in hemisphere(n, rays, rng):
            loc, _, _, dist = bvh.ray_cast(origin, d, reach)
            if loc is not None and dist is not None and dist < reach:
                # Near hits occlude fully, far ones fade out. Without the
                # falloff a model reads as uniformly dirty rather than as a
                # form with creases.
                hits += 1.0 - (dist / reach)
        occ[i] = min(1.0, hits / float(rays))

    name = "Col"
    for existing in list(me.color_attributes):
        if existing.name == name:
            me.color_attributes.remove(existing)
    attr = me.color_attributes.new(name=name, type="BYTE_COLOR", domain="CORNER")

    li = 0
    darkest = 1.0
    for idx in poly_verts:
        for vi in idx:
            a = 1.0 - occ[vi]
            darkest = min(darkest, a)
            attr.data[li].color = (a, a, a, 1.0)
            li += 1

    print("AOBAKE %s: %d verts, %d rays, reach %.3f, darkest %.2f"
          % (os.path.basename(src), len(verts), rays, reach, darkest))

    # The glTF exporter writes COLOR_0 only when the MATERIAL reads the colour
    # attribute -- it will not carry an attribute nothing uses, and silently
    # drops it, which is what the first run of this script did. So wire the
    # attribute into base colour: Color Attribute -> Multiply -> Base Color.
    # This also makes the .glb self-describing: the AO is visible on import even
    # before any custom shader is attached.
    for mat in me.materials:
        if not mat or not mat.use_nodes:
            continue
        nt = mat.node_tree
        bsdf = next((n for n in nt.nodes if n.type == "BSDF_PRINCIPLED"), None)
        if bsdf is None:
            continue
        base = bsdf.inputs["Base Color"]
        if not base.links:
            continue
        tex_out = base.links[0].from_socket
        ca = nt.nodes.new("ShaderNodeVertexColor")
        ca.layer_name = name
        mix = nt.nodes.new("ShaderNodeMix")
        mix.data_type = "RGBA"
        mix.blend_type = "MULTIPLY"
        mix.inputs["Factor"].default_value = 1.0
        nt.links.new(mix.inputs[6], tex_out)       # A
        nt.links.new(mix.inputs[7], ca.outputs["Color"])  # B
        nt.links.new(base, mix.outputs[2])         # Result

    os.makedirs(os.path.dirname(dst), exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    ob.select_set(True)
    # The colour-attribute export flag has been renamed across Blender versions
    # (`export_colors` up to 4.1, `export_vertex_color` after). Ask for whichever
    # this build accepts rather than pinning one and breaking on the other.
    opts = dict(filepath=dst, export_format="GLB", use_selection=True,
                export_apply=True)
    for flag, value in (("export_vertex_color", "MATERIAL"),
                        ("export_colors", True), (None, None)):
        try:
            bpy.ops.export_scene.gltf(**({**opts, flag: value} if flag else opts))
            break
        except TypeError:
            continue
    print("AOBAKE wrote %s" % dst)


main()
