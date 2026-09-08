"""Spike: turn a pile of overlapping primitives into ONE continuous surface.

    blender --background --python tools/blender/unionremesh.py -- \
        <in.glb> <out.glb> [voxel] [budget]

WHY, 2026-09-08. Nick: "limbs still don't seem like they are attached
properly." They are not, and adding shoulder masses only moved the problem
along -- the model went from sticks in a pod to spheres on a pod. The cause is
architectural: kenney.py assembles primitives and joins them WITHOUT blending,
so two overlapping smooth-shaded ellipsoids meet at a hard crease wherever they
are placed. Smooth organic forms promise a continuous surface; assembly by
intersection cannot deliver one.

THE IDEA. Every primitive this project builds is a closed manifold, so a VOXEL
REMESH of the joined mesh naturally produces the union of their volumes -- one
skin over the whole animal, with no interior shells and no intersection creases.
Legs then flow into shoulders because they are literally the same surface.

THE HARD PART is colour. This project carries colour in per-face UVs pointing at
a swatch in a shared palette atlas -- there is no texture to resample. A remesh
throws every UV away. So after remeshing, each new face's centroid is matched to
the NEAREST face on the original mesh and inherits its UV. That works here only
because UV is constant across a face (one swatch per face); it would be wrong
for a real unwrap.

WHAT IT COSTS. Voxel remeshing rounds everything: thin features near the voxel
size soften or vanish, and every hard edge the bevel gave the model is lost.
That is the trade being tested. Check the render, not the tri count.
"""
import bpy
import bmesh
import sys
import os
import mathutils
from mathutils.bvhtree import BVHTree


def args():
    a = sys.argv[sys.argv.index("--") + 1:]
    if len(a) < 2:
        print("usage: unionremesh.py -- <in.glb> <out.glb> [voxel] [budget]")
        sys.exit(1)
    voxel = float(a[2]) if len(a) > 2 else 0.06
    # Under kenney.BUDGET["beast"] (2600) rather than at it. The first run
    # decimated to exactly 2600, which leaves no room for the climb-point GREW
    # step that runs before this and can add triangles of its own.
    budget = int(a[3]) if len(a) > 3 else 2400
    return os.path.abspath(a[0]), os.path.abspath(a[1]), voxel, budget


def tris(ob):
    return sum(len(p.vertices) - 2 for p in ob.data.polygons)


def swatch(px, py):
    """Mirrors kenney.swatch — colour lives in the UV, one cell per face."""
    return (px / 512.0, 1.0 - (py + 16.0) / 512.0)


def keep_swatches(name):
    """Accent swatches for this asset, from union.txt.

    A line is `<name> [px:py ...]`. The extra pairs name palette cells whose
    faces must NOT be remeshed.

    Why this exists: the first union of cinder_jackal cut its TANGERINE spine
    ridge from 2.9% of faces to 0.5% and its AMBER eyes from 18.7% to 2.9%. A
    voxel remesh cannot keep a feature thinner than its voxel, and the ridge is
    built from radii of 0.01-0.09 against a 0.06 voxel. Those two swatches are
    exactly what the emissive channel in creature.gdshader lights, so the union
    was quietly deleting the accents that the glow exists to show -- one
    improvement eating the other.

    Held-out parts are separate closed shells to begin with (a ball, a tapered
    limb), so lifting them out leaves the body watertight and the remesh still
    unions everything that remains. They also stay CRISP, which is what an
    accent wants: on the reference Nick gave, the megalodon's spines and glowing
    cracks are the sharpest things on it.
    """
    here = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(here, "union.txt")
    if not os.path.exists(path):
        return []
    for line in open(path, encoding="utf-8"):
        bits = line.split()
        if bits and bits[0] == name:
            out = []
            for b in bits[1:]:
                if ":" in b:
                    px, py = b.split(":")
                    out.append(swatch(float(px), float(py)))
            return out
    return []


def main():
    src, dst, voxel, budget = args()

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=src)
    # combat_3d._read_climb_points reads the climb anchors off NAMED CHILD NODES
    # of the export -- climb_<n> and ledge_<n>. The first version of this script
    # joined every object into one and exported that, which silently deleted all
    # ten of the jackal's markers and would have broken the climb mechanic
    # outright. They are held out of the join and exported untouched.
    markers = [o for o in bpy.data.objects
               if o.name.startswith(("climb_", "ledge_"))]
    meshes = [o for o in bpy.data.objects
              if o.type == "MESH" and o not in markers]
    if not meshes:
        print("UNION: no mesh in %s" % src)
        sys.exit(1)
    print("UNION holding %d marker(s) out of the remesh: %s"
          % (len(markers), ", ".join(sorted(o.name for o in markers)) or "none"))
    bpy.ops.object.select_all(action="DESELECT")
    for o in meshes:
        o.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    if len(meshes) > 1:
        bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    # Lift the accent swatches out before anything touches the geometry.
    accents = None
    keep = keep_swatches(os.path.basename(src)[:-4])
    if keep:
        # Through bmesh, in edit mode. Setting polygon.select in OBJECT mode does
        # not survive the switch -- the first attempt did exactly that, every
        # face came through selected, separate moved the WHOLE model into the
        # accents object and the union silently became a no-op that still
        # reported success.
        picked = 0
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_mode(type="FACE")
        bpy.ops.mesh.select_all(action="DESELECT")
        bm = bmesh.from_edit_mesh(ob.data)
        uvl = bm.loops.layers.uv.active
        if uvl is not None:
            for f in bm.faces:
                u = f.loops[0][uvl].uv
                if any((u[0] - s[0]) ** 2 + (u[1] - s[1]) ** 2 < 0.012 ** 2
                       for s in keep):
                    f.select_set(True)
                    picked += 1
            bmesh.update_edit_mesh(ob.data)
        if picked:
            bpy.ops.mesh.separate(type="SELECTED")
        bpy.ops.object.mode_set(mode="OBJECT")
        if picked:
            others = [o for o in bpy.context.selected_objects if o is not ob]
            if others:
                accents = others[0]
                accents.name = "accents"
        print("UNION holding %d accent face(s) out of the remesh across %d swatch(es)"
              % (picked, len(keep)))

    # Keep the original as the colour reference before anything destroys it.
    ref = ob.copy()
    ref.data = ob.data.copy()
    bpy.context.collection.objects.link(ref)
    ref_mesh = ref.data
    uv0 = ref_mesh.uv_layers[0] if ref_mesh.uv_layers else None
    if uv0 is None:
        print("UNION: original has no UVs — nothing to reproject")
        sys.exit(1)
    face_uv = []
    for p in ref_mesh.polygons:
        face_uv.append(tuple(uv0.data[p.loop_start].uv))
    ref_bvh = BVHTree.FromObject(ref, bpy.context.evaluated_depsgraph_get())
    mat = ref_mesh.materials[0] if ref_mesh.materials else None

    before = tris(ob)

    bpy.context.view_layer.objects.active = ob
    rm = ob.modifiers.new("remesh", "REMESH")
    rm.mode = "VOXEL"
    rm.voxel_size = voxel
    rm.use_smooth_shade = True
    bpy.ops.object.modifier_apply(modifier=rm.name)
    remeshed = tris(ob)

    # The accents are rejoined AFTER this, so the body's share of the budget is
    # what is left once they are paid for. Decimating to the full budget first
    # put the jackal at 2732 against a 2600 ceiling.
    held = tris(accents) if accents is not None else 0
    body_budget = max(200, budget - held)
    if remeshed > body_budget:
        dec = ob.modifiers.new("decimate", "DECIMATE")
        dec.ratio = float(body_budget) / float(remeshed)
        bpy.ops.object.modifier_apply(modifier=dec.name)
    after = tris(ob)

    me = ob.data
    me.materials.clear()
    if mat is not None:
        me.materials.append(mat)
    layer = me.uv_layers.new(name="UVMap") if not me.uv_layers else me.uv_layers[0]

    # Nearest ORIGINAL face wins. A remeshed face sits within half a voxel of the
    # surface it came from, so the nearest original face is the one whose colour
    # it should carry -- except across a colour boundary, where a face can land
    # on the wrong side. That fringe is the cost of the method and is visible on
    # the render as a ragged edge between swatches.
    misses = 0
    for p in me.polygons:
        c = mathutils.Vector((0.0, 0.0, 0.0))
        for vi in p.vertices:
            c += me.vertices[vi].co
        c /= len(p.vertices)
        hit = ref_bvh.find_nearest(c)
        if hit is None or hit[2] is None:
            misses += 1
            continue
        uv = face_uv[hit[2]]
        for li in range(p.loop_start, p.loop_start + p.loop_total):
            layer.data[li].uv = uv

    print("UNION %s: %d tris -> remesh(voxel %.3f) %d -> decimate %d, %d face(s) unmatched"
          % (os.path.basename(src), before, voxel, remeshed, after, misses))

    bpy.data.objects.remove(ref, do_unlink=True)

    # Put the accents back onto the remeshed body, crisp and with their original
    # UVs untouched.
    if accents is not None:
        bpy.ops.object.select_all(action="DESELECT")
        accents.select_set(True)
        ob.select_set(True)
        bpy.context.view_layer.objects.active = ob
        bpy.ops.object.join()
        ob = bpy.context.view_layer.objects.active
        print("UNION rejoined accents: %d tris total" % tris(ob))

    bpy.ops.object.select_all(action="DESELECT")
    ob.select_set(True)
    for o in markers:
        o.select_set(True)
    bpy.context.view_layer.objects.active = ob
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=dst, export_format="GLB",
                              use_selection=True, export_apply=True)
    print("UNION wrote %s" % dst)


main()
