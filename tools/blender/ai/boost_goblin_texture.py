"""Apply the goblin's own validated global colour boost (SAT_MUL 1.55,
VAL_GAMMA 0.80 -- goblin_ai_tank_contrast.py's "global_boost", itself pass 2's
recipe) to the freshly rebuilt smooth model's texture, in Blender, since the
external glb patcher only handles a last-bufferView layout and this export
doesn't have one.

    blender -b --python tools/blender/ai/boost_goblin_texture.py -- <in_blend> <out_glb> <out_blend>
"""
import bpy, os, sys
import numpy as np


def rgb_to_hsv(rgb):
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    maxc = np.max(rgb, axis=-1)
    minc = np.min(rgb, axis=-1)
    v = maxc
    deltac = maxc - minc
    s = np.where(maxc > 0, deltac / np.where(maxc > 0, maxc, 1), 0)
    deltac_safe = np.where(deltac == 0, 1, deltac)
    rc = (maxc - r) / deltac_safe
    gc = (maxc - g) / deltac_safe
    bc = (maxc - b) / deltac_safe
    hue = np.zeros_like(maxc)
    r_is_max = r == maxc
    g_is_max = (g == maxc) & (~r_is_max)
    b_is_max = (~r_is_max) & (~g_is_max)
    hue[r_is_max] = (bc - gc)[r_is_max]
    hue[g_is_max] = (2.0 + rc - bc)[g_is_max]
    hue[b_is_max] = (4.0 + gc - rc)[b_is_max]
    hue = (hue / 6.0) % 1.0
    hue[deltac == 0] = 0
    return np.stack([hue, s, v], axis=-1)


def hsv_to_rgb(hsv):
    h, s, v = hsv[..., 0], hsv[..., 1], hsv[..., 2]
    i = np.floor(h * 6.0).astype(int) % 6
    f = (h * 6.0) - np.floor(h * 6.0)
    p = v * (1.0 - s)
    q = v * (1.0 - s * f)
    t = v * (1.0 - s * (1.0 - f))
    r = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5],
                  [v, q, p, p, t, v])
    g = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5],
                  [t, v, v, q, p, p])
    b = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5],
                  [p, p, t, v, v, q])
    return np.stack([r, g, b], axis=-1)

args = sys.argv[sys.argv.index("--") + 1:]
IN_BLEND, OUT_GLB, OUT_BLEND = args[0], args[1], args[2]
SAT_MUL = 1.55
VAL_GAMMA = 0.80

bpy.ops.wm.open_mainfile(filepath=IN_BLEND)
imgs = [i for i in bpy.data.images if i.size[0] > 4]
assert len(imgs) == 1, "expected exactly one baked texture, found %d" % len(imgs)
img = imgs[0]

w, h = img.size
px = np.array(img.pixels[:], dtype=np.float32).reshape((h, w, 4))
rgb = px[:, :, :3]
before_sat_mean = None

mx = rgb.max(axis=-1)
mn = rgb.min(axis=-1)
sat = np.where(mx > 0, (mx - mn) / np.where(mx > 0, mx, 1), 0)
print("REPORT before_sat %.4f" % sat.mean())
print("REPORT before_val %.4f" % mx.mean())

# HSV boost, vectorised, matching goblin_ai_tank_contrast.py's global_boost
# formula (SAT_MUL, VAL_GAMMA), worked in float 0..1 instead of 0..255.
hsv = rgb_to_hsv(np.clip(rgb, 0, 1))
hsv[..., 1] = np.clip(hsv[..., 1] * SAT_MUL, 0, 1)
hsv[..., 2] = np.clip(hsv[..., 2] ** VAL_GAMMA, 0, 1)
out_rgb = hsv_to_rgb(hsv).astype(np.float32)

px[:, :, :3] = out_rgb
mx2 = out_rgb.max(axis=-1)
mn2 = out_rgb.min(axis=-1)
sat2 = np.where(mx2 > 0, (mx2 - mn2) / np.where(mx2 > 0, mx2, 1), 0)
print("REPORT after_sat %.4f" % sat2.mean())
print("REPORT after_val %.4f" % mx2.mean())

img.pixels[:] = px.reshape(-1)
img.update()
img.pack()

body = [o for o in bpy.data.objects if o.type == "MESH"][0]
bpy.ops.object.select_all(action="DESELECT")
body.select_set(True)
bpy.context.view_layer.objects.active = body
os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
bpy.ops.export_scene.gltf(filepath=OUT_GLB, use_selection=True, export_format="GLB")
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND, compress=True)
print("REPORT exported %s" % OUT_GLB)
