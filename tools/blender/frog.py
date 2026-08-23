import bpy, sys, math, mathutils

out = sys.argv[sys.argv.index("--") + 1]

# clean slate
bpy.ops.wm.read_factory_settings(use_empty=True)

def sphere(name, loc, scale, seg=12, ring=6):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=ring, location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = scale
    return o

def box(name, loc, scale, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = scale
    o.rotation_euler = rot
    return o

parts = []
# Blender: -Y is forward (exports as +Z forward in glTF/Godot). Z is up.
parts.append(sphere("body", (0, 0.05, 0.42), (0.34, 0.42, 0.30)))
parts.append(sphere("head", (0, -0.38, 0.50), (0.28, 0.26, 0.22)))
for sx in (-1, 1):
    parts.append(sphere("eye", (0.15 * sx, -0.46, 0.68), (0.10, 0.10, 0.10), 8, 5))
    # folded back leg: thigh up-and-back, shin down
    parts.append(box("thigh", (0.30 * sx, 0.26, 0.36), (0.11, 0.20, 0.11), (math.radians(28), 0, 0)))
    parts.append(box("shin",  (0.32 * sx, 0.44, 0.17), (0.09, 0.09, 0.17)))
    parts.append(box("foot",  (0.32 * sx, 0.30, 0.05), (0.10, 0.22, 0.05)))
    # front arm
    parts.append(box("arm",   (0.22 * sx, -0.26, 0.16), (0.07, 0.07, 0.16)))
    parts.append(box("hand",  (0.22 * sx, -0.31, 0.04), (0.08, 0.13, 0.04)))

# join into one mesh
for o in parts:
    o.select_set(True)
bpy.context.view_layer.objects.active = parts[0]
bpy.ops.object.join()
frog = bpy.context.object
frog.name = "Frog"

bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
frog.scale = (1.5, 1.5, 1.5)
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

# flat shading — the low-poly look
for p in frog.data.polygons:
    p.use_smooth = False

# drop origin to the feet, centred on X/Y
mn = mathutils.Vector((min(v.co.x for v in frog.data.vertices),
                       min(v.co.y for v in frog.data.vertices),
                       min(v.co.z for v in frog.data.vertices)))
mx = mathutils.Vector((max(v.co.x for v in frog.data.vertices),
                       max(v.co.y for v in frog.data.vertices),
                       max(v.co.z for v in frog.data.vertices)))
off = mathutils.Vector(((mn.x + mx.x) / 2, (mn.y + mx.y) / 2, mn.z))
for v in frog.data.vertices:
    v.co -= off

mat = bpy.data.materials.new("FrogSkin")
mat.use_nodes = True
mat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.30, 0.62, 0.28, 1)
mat.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.75
frog.data.materials.append(mat)

frog.data.calc_loop_triangles()
print("TRIS", len(frog.data.loop_triangles))
print("SIZE", round(mx.x-mn.x, 3), round(mx.y-mn.y, 3), round(mx.z-mn.z, 3))

bpy.ops.export_scene.gltf(filepath=out, export_format='GLB', use_selection=False)
print("WROTE", out)
