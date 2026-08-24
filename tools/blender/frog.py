"""The Frog, built to match the Kenney models it stands next to.

Copying that style meant reading it off the bunny rather than guessing:

  * ~575 triangles, and the low-poly look comes from the VERTEX COUNT, not
    from flat shading — 78% of the bunny's faces are smooth-shaded.
  * ONE material for the whole Kenney set: a 512x512 palette atlas. Colour
    comes from UVs pointing at a flat swatch, which is why a bunny and a
    koala batch together.

So this frog uses their actual colormap.png. Every part is one mesh with one
material, coloured by aiming its UVs at a swatch, and it stands as tall as the
bunny so the cast reads at one eye level.

    blender.exe --background --python tools/blender/frog.py -- <out.glb>
"""
import bpy, sys, os, math, mathutils

out = sys.argv[sys.argv.index("--") + 1]
HERE = os.path.dirname(os.path.abspath(__file__))
TARGET_HEIGHT = 1.85          # the Kenney bunny is 1.83 tall

bpy.ops.wm.read_factory_settings(use_empty=True)

img = bpy.data.images.load(os.path.join(HERE, "colormap.png"))
img.name = "colormap"
mat = bpy.data.materials.new("colormap")
mat.use_nodes = True
bsdf = mat.node_tree.nodes["Principled BSDF"]
bsdf.inputs["Roughness"].default_value = 1.0
tex = mat.node_tree.nodes.new("ShaderNodeTexImage")
tex.image = img
tex.interpolation = "Closest"          # never blend two swatches together
mat.node_tree.links.new(bsdf.inputs["Base Color"], tex.outputs["Color"])


def swatch(px, py):
    """UV of a palette cell, by its pixel in colormap.png (PNG y runs down)."""
    return (px / 512.0, 1.0 - py / 512.0)


SKIN  = swatch(432, 320)   # 3da679  deep green
LIGHT = swatch(400, 320)   # 61cb8b  mint
BELLY = swatch(336, 320)   # fde4c7  cream
GOLD  = swatch(464, 320)   # ffc044
DARK  = swatch(336, 448)   # 38383d

parts = []


def paint(o, uv, smooth=True):
    o.data.materials.append(mat)
    layer = o.data.uv_layers[0] if o.data.uv_layers else o.data.uv_layers.new(name="UVMap")
    for loop in layer.data:
        loop.uv = uv
    for p in o.data.polygons:
        p.use_smooth = smooth
    parts.append(o)
    return o


def ball(loc, scale, uv, seg=10, ring=6, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=ring, location=loc)
    o = bpy.context.object
    o.scale, o.rotation_euler = scale, rot
    return paint(o, uv)


def slab(loc, scale, uv, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    o = bpy.context.object
    o.scale, o.rotation_euler = scale, rot
    return paint(o, uv, smooth=False)


# Blender -Y is forward; the exporter turns that into the +Z Godot wants.
ball((0.00,  0.00, 0.72), (0.44, 0.40, 0.46), SKIN,  10, 6)   # body
ball((0.00, -0.05, 1.26), (0.44, 0.42, 0.34), SKIN,  10, 6)   # head
ball((0.00, -0.24, 0.62), (0.30, 0.24, 0.32), BELLY,  8, 5)   # belly
bpy.ops.mesh.primitive_torus_add(major_radius=1.0, minor_radius=0.052,
                                 major_segments=14, minor_segments=4,
                                 location=(0.0, -0.05, 1.10))
_m = bpy.context.object
_m.scale = (0.400, 0.381, 0.55)
paint(_m, DARK)                                               # mouth

for sx in (-1, 1):
    eye = mathutils.Vector((0.235 * sx, -0.120, 1.520))
    look = mathutils.Vector((0.34 * sx, -0.86, 0.38)).normalized()
    ball(eye, (0.160, 0.160, 0.160), GOLD, 8, 5)
    ball(eye + look * 0.105, (0.078, 0.078, 0.052), DARK, 6, 4)     # slit pupil
    ball((0.360 * sx,  0.090, 0.420), (0.180, 0.280, 0.260), SKIN,  7, 4)   # haunch
    ball((0.310 * sx, -0.045, 0.235), (0.135, 0.150, 0.185), SKIN,  6, 4)   # shin
    ball((0.265 * sx, -0.210, 0.095), (0.185, 0.300, 0.095), LIGHT, 6, 4)   # foot
    ball((0.345 * sx, -0.160, 0.760), (0.105, 0.105, 0.235), SKIN,  6, 4)   # arm

# One material means the whole frog can be ONE mesh and still be many colours.
bpy.ops.object.select_all(action="SELECT")
bpy.context.view_layer.objects.active = parts[0]
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
bpy.ops.object.join()
frog = bpy.context.object
frog.name = "Frog"

co = [v.co for v in frog.data.vertices]
lo = mathutils.Vector((min(c.x for c in co), min(c.y for c in co), min(c.z for c in co)))
hi = mathutils.Vector((max(c.x for c in co), max(c.y for c in co), max(c.z for c in co)))
k = TARGET_HEIGHT / (hi.z - lo.z)
mid = mathutils.Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
for v in frog.data.vertices:
    v.co = (v.co - mid) * k          # to scale, and standing on the floor

frog.data.calc_loop_triangles()
print("TRIS", len(frog.data.loop_triangles), "MESHES 1 MATERIALS 1")
print("SIZE", round((hi.x - lo.x) * k, 3), round((hi.y - lo.y) * k, 3),
      round((hi.z - lo.z) * k, 3))

bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", use_selection=False)
print("WROTE", out)
