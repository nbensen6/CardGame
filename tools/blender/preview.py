import bpy, sys, math, mathutils
src, out = sys.argv[sys.argv.index("--")+1], sys.argv[sys.argv.index("--")+2]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)

tgt = mathutils.Vector((0, 0, 0.55))
def cam(name, loc):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object
    d = tgt - mathutils.Vector(loc)
    c.rotation_euler = d.to_track_quat('-Z', 'Y').to_euler()
    return c

sc = bpy.context.scene
sc.render.engine = 'BLENDER_WORKBENCH'
sc.display.shading.light = 'STUDIO'
sc.display.shading.color_type = 'MATERIAL'
sc.display.shading.show_shadows = True
sc.render.film_transparent = False
sc.world = bpy.data.worlds.new("W")
sc.world.color = (0.16, 0.17, 0.20)
sc.render.resolution_x = 520
sc.render.resolution_y = 520

for i, loc in enumerate([(2.3, -2.6, 1.5), (0, -3.4, 0.9), (2.9, 0.6, 1.2)]):
    sc.camera = cam("c%d" % i, loc)
    sc.render.filepath = out.replace(".png", "_%d.png" % i)
    bpy.ops.render.render(write_still=True)
    print("VIEW", sc.render.filepath)
