"""Boost saturation and value on the Goblin Engineer AI texture, in place.
Pure PIL/numpy -- no Blender needed, since Godot's importer already extracted
this PNG (embedded_image_handling=1) and the game renders straight off it,
the same fact the jackal ear-glare fix relied on.

Measured gap against the shipped frog_ai texture (both HSV, 0-1 scale):
  goblin: sat mean 0.284 std 0.144 | val mean 0.535 std 0.130
  frog:   sat mean 0.671 std 0.148 | val mean 0.702 std 0.156
Goblin is markedly less saturated and darker -- this is the real, measurable
half of "Colour & read" duller than the Frog's own (design/progress/
goblin_mech_ai.md, "Shipped and scored").
"""
import sys
import numpy as np
from PIL import Image

SRC = "game/assets/3d/cast/goblin_mech_ai_Image_0.png"
SAT_MUL = 1.55     # toward the frog's own saturation, not all the way (avoid neon)
VAL_GAMMA = 0.80   # <1 lifts shadows/midtones, leaves white points alone

im = Image.open(SRC)
has_alpha = im.mode == "RGBA"
alpha = im.split()[-1] if has_alpha else None
rgb = im.convert("RGB")

hsv = rgb.convert("HSV")
h, s, v = [np.array(c, dtype=np.float32) for c in hsv.split()]

s2 = np.clip(s * SAT_MUL, 0, 255)
v2 = np.clip(255.0 * (v / 255.0) ** VAL_GAMMA, 0, 255)

out_hsv = Image.merge("HSV", [
    Image.fromarray(h.astype(np.uint8)),
    Image.fromarray(s2.astype(np.uint8)),
    Image.fromarray(v2.astype(np.uint8)),
])
out_rgb = out_hsv.convert("RGB")
if has_alpha:
    out_rgb.putalpha(alpha)
out_rgb.save(SRC)

a = np.array(rgb).astype(np.float32) / 255.0
mx, mn = a.max(-1), a.min(-1)
print("before sat/val mean:", np.where(mx>0,(mx-mn)/np.where(mx>0,mx,1),0).mean(), mx.mean())
b = np.array(out_rgb).astype(np.float32) / 255.0
mx2, mn2 = b.max(-1), b.min(-1)
print("after  sat/val mean:", np.where(mx2>0,(mx2-mn2)/np.where(mx2>0,mx2,1),0).mean(), mx2.mean())
