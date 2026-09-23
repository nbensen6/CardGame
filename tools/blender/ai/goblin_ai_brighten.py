"""Brighten the Goblin Engineer AI texture in place. The first export (mean
luminance 80 vs the shipped frog_ai's 156) reads as a near-black blob at true
in-fight size once the toon shader's shadow ramp and ink outline are added on
top -- confirmed by a real before/after capture, not assumed. No new Meshy
spend: a gamma lift on the already-downloaded texture, the same kind of
luminance-headroom fix goblin_mech.py's own palette passes made for the toon
shader (CHARCOAL/GRAPHITE -> STONE, pass 5).

    blender -b --python tools/blender/ai/goblin_ai_brighten.py -- <in_blend> <out_glb> <out_blend>
"""
import bpy, os, sys
import numpy as np

args = sys.argv[sys.argv.index("--") + 1:]
IN_BLEND, OUT_GLB, OUT_BLEND = args[0], args[1], args[2]
GAMMA = 0.62   # < 1 lifts shadows/midtones, leaves white points alone

bpy.ops.wm.open_mainfile(filepath=IN_BLEND)

for i in bpy.data.images:
    print("REPORT image_seen %s %s %s" % (i.name, i.size[:], i.has_data))
imgs = [i for i in bpy.data.images if i.size[0] > 4]
assert len(imgs) == 1, "expected exactly one baked texture, found %d" % len(imgs)
img = imgs[0]

px = np.array(img.pixels[:], dtype=np.float32)
px = px.reshape((-1, 4))
rgb = px[:, :3]
before_mean = float(rgb.mean())
rgb[:] = np.clip(rgb, 0.0, 1.0) ** GAMMA
after_mean = float(rgb.mean())
img.pixels[:] = px.reshape(-1)
img.update()
img.pack()

print("REPORT before_mean %.4f" % before_mean)
print("REPORT after_mean %.4f" % after_mean)

body = [o for o in bpy.data.objects if o.type == "MESH"][0]
bpy.ops.object.select_all(action="DESELECT")
body.select_set(True)
bpy.context.view_layer.objects.active = body
os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
bpy.ops.export_scene.gltf(filepath=OUT_GLB, use_selection=True, export_format="GLB")
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND, compress=True)
print("REPORT exported %s" % OUT_GLB)
