"""The floating foothold, rebuilt as a real boulder — #17 (director, 2026-09-24).

`_build_float_stones` in combat_3d.gd built each stone from a SphereMesh (a
perfect sphere) plus a flat CylinderMesh cap. #16 fixed the sphere's squash so
it finally had bulk, but a true sphere with a flat lid on top is a shape this
project already has a name for: a pot. Nick's reference stones are irregular
lumps with four or five big flat faces — the same "style C" faceted language
the jackal's own body already wears (`decimate_beast.py`), just never given to
the stone.

Built as a convex hull of hand-placed points rather than a decimated sphere,
because a sphere decimated to a handful of faces still reads as "a rounded
thing with corners cut off" (every facet is nearly the same size and the
outline stays circular). A hull built from a few points at the TOP, all at the
same height, and a scatter of points below at irregular radius/angle/height
gives a true rock silhouette — few big planar faces, no two the same size,
with the top ring's shared height producing the landing face for free, not as
a separate glued-on disc.

Contract note: this ships GEOMETRY ONLY, no material logic. combat_3d.gd
keeps doing the colouring (the #12 palette, the ROCK_DETAIL multiply, the
warm rim) via material_override — #17 explicitly asks not to touch that code
or its colours here. The origin is the model's own base centre (finish()'s
usual contract); the flat top face sits at local Z = SIZE.z (printed by
finish() below) so the fixer can anchor it the same way the old cap's top
face anchored `_stand_on_model`.
"""
import sys, os, math, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bpy, bmesh
from kenney import Build, out_path, STONE

random.seed(17)   # deterministic rebuilds -- no shape drift between passes

b = Build()
bm = bmesh.new()

# The flat top: four points at the SAME height, so the hull's top face is one
# flat polygon (the landing face) -- but not evenly spaced or equal-radius,
# so it reads as a natural broken top rather than a lid stamped from a mould.
TOP_Z = 1.80
top = [(0.82, 0.15), (0.90, 1.60), (0.74, 3.35), (0.86, 4.85)]
verts = [bm.verts.new((r * math.cos(a), r * math.sin(a), TOP_Z)) for r, a in top]

# The bulk: an irregular scatter below the top ring -- varying radius, angle
# and height on purpose (a real boulder has no two faces the same size).
# Angles are offset from the top ring's own so no side face lines up flush
# under a top edge, which is what made the sphere-based version read as
# lathed rather than found.
bulk = [
    (1.02, 0.75, 1.00), (0.58, 2.05, 0.90), (1.05, 3.75, 0.78),
    (0.66, 5.35, 1.02), (0.34, 1.35, 0.12), (0.92, 3.05, 0.06),
    (0.45, 4.95, 0.18), (0.70, 0.10, 0.35),
]
for r, a, z in bulk:
    verts.append(bm.verts.new((r * math.cos(a), r * math.sin(a), z)))

hull = bmesh.ops.convex_hull(bm, input=verts)
# Points that end up inside the hull rather than on its surface (there
# shouldn't be many, with points this sparse, but a stray one would leave a
# dangling vert convex_hull doesn't clean up itself).
bmesh.ops.delete(bm, geom=hull["geom_interior"], context="VERTS")
# A convex hull is always triangulated. Left alone that is facet SOUP -- the
# opposite of "four or five big flat faces". Merging triangles that are
# already near-coplanar into their real n-gon is what turns "many small
# triangles" into "a few big rock faces"; the flat top's four points are
# exactly coplanar so they merge into one face regardless of this angle.
bmesh.ops.dissolve_limit(bm, angle_limit=math.radians(20.0),
                          verts=bm.verts, edges=bm.edges)

me = bpy.data.meshes.new("foothold_rock")
bm.to_mesh(me)
bm.free()
o = bpy.data.objects.new("foothold_rock", me)
bpy.context.collection.objects.link(o)
bpy.context.view_layer.objects.active = o
o.select_set(True)
# smooth=False: style C is a hard facet edge everywhere, not Kenney's usual
# "smooth unless the angle says crease" -- a rock has no smooth surfaces.
b._paint(o, STONE, smooth=False)

# height=None: this is a placed prop, not a character fitted to eye level --
# its own proportions (as tall as it is wide, per #16/#17) are the point and
# normalising them away would throw out the one thing being fixed.
b.finish(out_path(), name="FootholdRock", height=None, budget="prop")
