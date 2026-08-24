"""Look at a .glb from three angles without opening Blender.

    blender.exe --background --python tools/blender/preview.py -- <in.glb> <out.png>

Writes <out>_0/_1/_2.png: three-quarter, front, and side. Frames whatever it
imports, so it works for a 0.8-tall model and a 2-tall one alike, and shades
with TEXTURE so palette-atlas models show their real colours.
"""
import bpy, sys, mathutils

src, out = sys.argv[sys.argv.index("--") + 1], sys.argv[sys.argv.index("--") + 2]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)

co = [o.matrix_world @ v.co for o in bpy.data.objects if o.type == "MESH"
      for v in o.data.vertices]
lo = mathutils.Vector((min(c.x for c in co), min(c.y for c in co), min(c.z for c in co)))
hi = mathutils.Vector((max(c.x for c in co), max(c.y for c in co), max(c.z for c in co)))
mid = (lo + hi) / 2
reach = max(hi.x - lo.x, hi.y - lo.y, hi.z - lo.z)

sc = bpy.context.scene
sc.render.engine = "BLENDER_WORKBENCH"
sc.display.shading.light = "STUDIO"
sc.display.shading.color_type = "TEXTURE"
sc.display.shading.show_shadows = True
sc.world = bpy.data.worlds.new("W")
sc.world.color = (0.16, 0.17, 0.20)
sc.render.resolution_x = sc.render.resolution_y = 520

for i, d in enumerate([(1.15, -1.30, 0.55), (0.0, -1.85, 0.18), (1.85, 0.10, 0.30)]):
    loc = mid + mathutils.Vector(d) * reach
    bpy.ops.object.camera_add(location=loc)
    cam = bpy.context.object
    cam.rotation_euler = (mid - loc).to_track_quat("-Z", "Y").to_euler()
    sc.camera = cam
    sc.render.filepath = out.replace(".png", "_%d.png" % i)
    bpy.ops.render.render(write_still=True)
    print("VIEW", sc.render.filepath)
