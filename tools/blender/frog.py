"""The Frog.

Built from smooth-shaded spheres rather than faceted primitives, because the
faceting was the first thing that read as "programmer art". Every part is its
own object with its own material — the Kenney models do the same, and it means
the eyes, mouth and belly can be different colours without touching UVs.

    blender.exe --background --python tools/blender/frog.py -- <out.glb>
"""
import bpy, sys, math, mathutils

out = sys.argv[sys.argv.index("--") + 1]
bpy.ops.wm.read_factory_settings(use_empty=True)


def mat(name, rgb, rough=0.6):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (rgb[0], rgb[1], rgb[2], 1.0)
    b.inputs["Roughness"].default_value = rough
    return m


SKIN  = mat("Skin",  (0.055, 0.175, 0.070), 0.55)   # deep forest green
BELLY = mat("Belly", (0.600, 0.640, 0.390), 0.70)   # pale olive
SPOT  = mat("Spot",  (0.022, 0.075, 0.035), 0.50)
MOUTH = mat("Mouth", (0.030, 0.045, 0.035), 0.80)
EYE   = mat("Eye",   (0.870, 0.690, 0.110), 0.35)   # gold
PUPIL = mat("Pupil", (0.018, 0.018, 0.024), 0.25)
GLINT = mat("Glint", (1.000, 1.000, 1.000), 0.10)

parts = []


def ball(loc, scale, m, seg=20, ring=10, rot=(0, 0, 0)):
    """A smooth-shaded ellipsoid. Everything on this frog is one of these."""
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=ring, location=loc)
    o = bpy.context.object
    o.scale, o.rotation_euler = scale, rot
    o.data.materials.append(m)
    for p in o.data.polygons:
        p.use_smooth = True
    parts.append(o)
    return o


# Blender -Y is forward; the glTF exporter turns that into the +Z Godot wants.
BODY_C, BODY_S = (0.0, 0.10, 0.45), (0.40, 0.45, 0.32)
HEAD_C, HEAD_S = (0.0, -0.35, 0.44), (0.36, 0.30, 0.26)

ball(BODY_C, BODY_S, SKIN, 24, 12)
ball(HEAD_C, HEAD_S, SKIN, 24, 12)
ball((0.0, -0.06, 0.27), (0.34, 0.42, 0.19), BELLY, 20, 10)   # underside
ball((0.0, -0.47, 0.215), (0.245, 0.155, 0.100), BELLY, 16, 8)  # throat, under the jaw


def on_body(x, y):
    """Height of the body surface above (x, y) — so spots sit ON the back."""
    dx = x / BODY_S[0]
    dy = (y - BODY_C[1]) / BODY_S[1]
    r = max(0.0, 1.0 - dx * dx - dy * dy)
    return BODY_C[2] + BODY_S[2] * math.sqrt(r)


for x, y, s in [(0.17, -0.02, 1.0), (-0.20, 0.06, 0.9), (0.26, 0.26, 0.85),
                (-0.25, 0.30, 0.8), (0.02, 0.34, 0.75), (-0.06, 0.16, 0.6)]:
    ball((x, y, on_body(x, y) - 0.025), (0.085 * s, 0.105 * s, 0.045 * s), SPOT, 14, 7)

def on_head(x, y):
    """Height of the head surface above (x, y) — for nostrils that sit ON it."""
    dx = x / HEAD_S[0]
    dy = (y - HEAD_C[1]) / HEAD_S[1]
    r = max(0.0, 1.0 - dx * dx - dy * dy)
    return HEAD_C[2] + HEAD_S[2] * math.sqrt(r)


for nx in (-0.078, 0.078):
    ball((nx, -0.585, on_head(nx, -0.585) - 0.012), (0.030, 0.036, 0.020), MOUTH, 12, 6)

# The mouth is a ring, not a line: a frog's jaw wraps most of the way round its
# head. The back of the ring is buried in the body, so only the grin shows.
bpy.ops.mesh.primitive_torus_add(major_radius=1.0, minor_radius=0.052,
                                 major_segments=30, minor_segments=8,
                                 location=(0.0, -0.35, 0.335))
mouth = bpy.context.object
mouth.scale = (0.350, 0.293, 0.62)
mouth.data.materials.append(MOUTH)
for p in mouth.data.polygons:
    p.use_smooth = True
parts.append(mouth)

for sx in (-1, 1):
    eye = mathutils.Vector((0.205 * sx, -0.415, 0.655))
    out_dir = mathutils.Vector((0.45 * sx, -0.80, 0.26)).normalized()
    ball(eye, (0.118, 0.118, 0.118), EYE, 20, 10)
    p = eye + out_dir * 0.070
    ball(p, (0.060, 0.060, 0.036), PUPIL, 16, 8)          # horizontal frog slit
    g = eye + out_dir * 0.098 + mathutils.Vector((-0.030 * sx, 0.0, 0.042))
    ball(g, (0.021, 0.021, 0.021), GLINT, 10, 6)
    ball(eye + mathutils.Vector((0, 0.008, 0.040)),
         (0.129, 0.126, 0.085), SKIN, 20, 10)             # heavy lid

    # folded back leg
    ball((0.335 * sx, 0.295, 0.400), (0.135, 0.225, 0.155), SKIN, 18, 9,
         (math.radians(24), 0, 0))
    ball((0.360 * sx, 0.470, 0.215), (0.105, 0.105, 0.190), SKIN, 16, 8)
    ball((0.345 * sx, 0.190, 0.062), (0.115, 0.230, 0.055), SKIN, 16, 8)
    for i, fx in enumerate((-0.075, 0.0, 0.075)):
        ball((0.345 * sx + fx, -0.030 - abs(fx) * 0.5, 0.050),
             (0.042, 0.115, 0.038), SKIN, 12, 6)

    # front arm
    ball((0.240 * sx, -0.300, 0.230), (0.080, 0.080, 0.205), SKIN, 16, 8)
    ball((0.250 * sx, -0.360, 0.052), (0.092, 0.125, 0.048), SKIN, 14, 7)
    for fx in (-0.058, 0.0, 0.058):
        ball((0.250 * sx + fx, -0.470 - abs(fx) * 0.4, 0.044),
             (0.033, 0.085, 0.032), SKIN, 10, 5)

# Apply first, THEN scale, then apply again: join/primitive ops leave an object
# scale behind, so scaling before the first apply multiplies by the wrong number.
bpy.ops.object.select_all(action="SELECT")
bpy.context.view_layer.objects.active = parts[0]
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
for o in parts:
    o.scale = (1.5, 1.5, 1.5)
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

# 43 separate objects is 43 draw calls per frog, and with four hunters on screen
# that adds up for no reason. Parts sharing a material are one mesh; nothing about
# the shape changes.
groups = {}
for o in parts:
    groups.setdefault(o.data.materials[0].name, []).append(o)
parts = []
for name, group in groups.items():
    bpy.ops.object.select_all(action="DESELECT")
    for o in group:
        o.select_set(True)
    bpy.context.view_layer.objects.active = group[0]
    if len(group) > 1:
        bpy.ops.object.join()
    merged = bpy.context.object
    merged.name = name
    parts.append(merged)

# Drop the whole frog onto the floor, centred left-to-right.
lo = mathutils.Vector((1e9, 1e9, 1e9))
hi = mathutils.Vector((-1e9, -1e9, -1e9))
for o in parts:
    for v in o.data.vertices:
        lo = mathutils.Vector((min(lo.x, v.co.x), min(lo.y, v.co.y), min(lo.z, v.co.z)))
        hi = mathutils.Vector((max(hi.x, v.co.x), max(hi.y, v.co.y), max(hi.z, v.co.z)))
off = mathutils.Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
for o in parts:
    for v in o.data.vertices:
        v.co -= off

tris = 0
for o in parts:
    o.data.calc_loop_triangles()
    tris += len(o.data.loop_triangles)
print("TRIS", tris, "PARTS", len(parts))
print("SIZE", round(hi.x - lo.x, 3), round(hi.y - lo.y, 3), round(hi.z - lo.z, 3))

bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", use_selection=False)
print("WROTE", out)
