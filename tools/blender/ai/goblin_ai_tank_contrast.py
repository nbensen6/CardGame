"""goblin_mech_ai pass 5 -- tank-vs-body contrast at the 34px party-portrait
scale, the concrete next move pass 4 named (design/progress/goblin_mech_ai.md).
Pure PIL/numpy, no Blender needed for the pixel math -- same reasoning
goblin_ai_colour_boost.py (pass 2) already used.

Real bug found while measuring this: portraits.py renders straight from
goblin_mech_ai.glb, but the glb's OWN embedded texture is the raw,
never-boosted Meshy output -- pass 2's global saturation/value boost only
ever touched the loose extracted goblin_mech_ai_Image_0.png (what Godot's
importer reads for the live 3D fight). Confirmed by extracting the glb's
embedded image directly: sat/val measured 0.282/0.535, matching pass 2's own
recorded PRE-boost numbers exactly. So every portrait render since pass 2 --
party rail, character card, campfire -- has been showing the dimmer,
pre-boost goblin the whole time, invisibly out of sync with the fight itself.

Fix in two parts, run once (not idempotent -- like goblin_ai_colour_boost.py,
this is a one-shot pass script, not a tool to rerun):

1. The loose PNG (already carries pass 2's global boost) gets ONLY the new
   tank-specific boost below, applied in place.
2. The glb's embedded image (still raw) gets pass 2's global boost applied
   FIRST -- so the portrait finally matches the shipped fight colours -- then
   the same tank-specific boost on top. Verified byte-identical to the loose
   PNG's own global-boost stage before the tank step diverges them (same
   formula, same raw source).

The tank boost itself: masks pixels by HUE only (invariant to how much
saturation/value pass 2 already moved), 195-245 degrees (the tank/steel/
shorts blue-grey family this hunter's palette uses) and value < 0.6 (excludes
the near-white ice-blue goggle lens, which sits in the same hue range but
reads nothing like the dark tank). Confirmed by a diagnostic magenta
recolour, rendered in Blender: the mask lands on the backpack tank and the
shorts, nothing else. Boosts saturation and lifts value only inside that
mask, leaving skin/goggles/straps/boots untouched.
"""
import io
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from glb_image_patch import extract_image, replace_image

GLB = "game/assets/3d/cast/goblin_mech_ai.glb"
LOOSE_PNG = "game/assets/3d/cast/goblin_mech_ai_Image_0.png"

# Pass 2's own global boost (goblin_ai_colour_boost.py), reapplied here only
# to the glb's still-raw embedded image, to bring it level with the fight.
SAT_MUL = 1.55
VAL_GAMMA = 0.80

TANK_HUE_LO, TANK_HUE_HI = 195, 245
TANK_VAL_MAX = 0.6
TANK_SAT_MUL = 1.7
TANK_VAL_GAMMA = 0.68


def global_boost(rgb_u8):
    im = Image.fromarray(rgb_u8, "RGB")
    hsv = im.convert("HSV")
    h, s, v = [np.array(c, dtype=np.float32) for c in hsv.split()]
    s2 = np.clip(s * SAT_MUL, 0, 255)
    v2 = np.clip(255.0 * (v / 255.0) ** VAL_GAMMA, 0, 255)
    out = Image.merge("HSV", [Image.fromarray(h.astype(np.uint8)),
                               Image.fromarray(s2.astype(np.uint8)),
                               Image.fromarray(v2.astype(np.uint8))])
    return np.array(out.convert("RGB"))


def tank_boost(rgb_u8):
    im = Image.fromarray(rgb_u8, "RGB")
    hsv = im.convert("HSV")
    h, s, v = [np.array(c, dtype=np.float32) for c in hsv.split()]
    h360 = h / 255.0 * 360.0
    vf = v / 255.0
    mask = (h360 >= TANK_HUE_LO) & (h360 <= TANK_HUE_HI) & (vf < TANK_VAL_MAX)

    s2 = s.copy()
    v2 = v.copy()
    s2[mask] = np.clip(s[mask] * TANK_SAT_MUL, 0, 255)
    v2[mask] = np.clip(255.0 * (v[mask] / 255.0) ** TANK_VAL_GAMMA, 0, 255)

    out = Image.merge("HSV", [Image.fromarray(h.astype(np.uint8)),
                               Image.fromarray(s2.astype(np.uint8)),
                               Image.fromarray(v2.astype(np.uint8))])
    return np.array(out.convert("RGB")), mask


def main():
    loose = Image.open(LOOSE_PNG)
    has_alpha = loose.mode == "RGBA"
    alpha = loose.split()[-1] if has_alpha else None
    rgb = np.array(loose.convert("RGB"))
    rgb2, mask = tank_boost(rgb)
    out = Image.fromarray(rgb2, "RGB")
    if has_alpha:
        out.putalpha(alpha)
    out.save(LOOSE_PNG)
    print("loose PNG tank-boosted, mask px:", mask.sum())

    raw_bytes = extract_image(GLB, 0)
    raw_im = Image.open(io.BytesIO(raw_bytes))
    raw_has_alpha = raw_im.mode == "RGBA"
    raw_alpha = raw_im.split()[-1] if raw_has_alpha else None
    raw_rgb = np.array(raw_im.convert("RGB"))
    boosted = global_boost(raw_rgb)
    boosted2, mask2 = tank_boost(boosted)
    out2 = Image.fromarray(boosted2, "RGB")
    if raw_has_alpha:
        out2.putalpha(raw_alpha)
    buf = io.BytesIO()
    out2.save(buf, format="PNG")
    new_bytes = buf.getvalue()
    replace_image(GLB, GLB, 0, new_bytes)
    print("glb embedded image replaced, new size", len(new_bytes),
          "mask px:", mask2.sum())


if __name__ == "__main__":
    main()
