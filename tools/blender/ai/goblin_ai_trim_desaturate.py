"""goblin_mech_ai -- unify the warm trim into one muted rust (BUILDER-QUEUE.md:
"Goblin reads at 40 px. The Frog reads at fight size; the Goblin is noise.").

The Frog reads clean at fight size because it is basically one hue (MINT)
with two small accents (CREAM belly, RUST toes). The Goblin's warm trim --
boots, shorts, waist strap, ear tuft -- samples at four distinct hues (16,
36, 40 degrees, all near-full saturation), each competing with the green
skin and the blue tank for attention instead of sitting behind them. Folds
all of it into one low-saturation rust, the same role RUST already plays on
the Frog, so the fight reads as green (body) + blue (the pack, the one
accent) instead of green + blue + three different warm colours.

Same technique and the same two-file pattern goblin_ai_skin_saturation.py
(pass 6) already used and documented: mask by hue alone, above a saturation
floor that excludes skin (~0.3-0.5) and the pale background bleeding into a
UV island's edge. Patches both files so the live fight and the party
portrait (portraits.py reads the .glb directly) stay in sync -- not just the
loose PNG, which is gitignored, regenerated from the .glb's own embedded
image on a fresh --import, and so cannot be the durable fix on its own
(confirmed: reverting only the loose PNG reverts the live render too).
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

# Warm band (red through gold), wrapping through 0 degrees, above a
# saturation floor that excludes skin and background bleed.
TRIM_HUE_LO_DEG, TRIM_HUE_HI_DEG = 340, 55
TRIM_SAT_MIN = 0.35

TARGET_HUE_DEG = 20  # one consistent muted rust
SAT_MUL = 0.55
VAL_MUL = 0.85


def trim_desaturate(rgb_u8):
    im = Image.fromarray(rgb_u8, "RGB")
    hsv = im.convert("HSV")
    h, s, v = [np.array(c, dtype=np.float32) for c in hsv.split()]
    h360 = h / 255.0 * 360.0
    sf = s / 255.0
    mask = ((h360 <= TRIM_HUE_HI_DEG) | (h360 >= TRIM_HUE_LO_DEG)) & (sf > TRIM_SAT_MIN)

    h2, s2, v2 = h.copy(), s.copy(), v.copy()
    h2[mask] = TARGET_HUE_DEG / 360.0 * 255.0
    s2[mask] = np.clip(s[mask] * SAT_MUL, 0, 255)
    v2[mask] = np.clip(v[mask] * VAL_MUL, 0, 255)

    out = Image.merge("HSV", [Image.fromarray(h2.astype(np.uint8)),
                               Image.fromarray(s2.astype(np.uint8)),
                               Image.fromarray(v2.astype(np.uint8))])
    return np.array(out.convert("RGB")), mask


def main():
    raw_bytes = extract_image(GLB, 0)
    raw_im = Image.open(io.BytesIO(raw_bytes))
    raw_has_alpha = raw_im.mode == "RGBA"
    raw_alpha = raw_im.split()[-1] if raw_has_alpha else None
    raw_rgb = np.array(raw_im.convert("RGB"))
    out_rgb, mask = trim_desaturate(raw_rgb)
    out = Image.fromarray(out_rgb, "RGB")
    if raw_has_alpha:
        out.putalpha(raw_alpha)
    buf = io.BytesIO()
    out.save(buf, format="PNG")
    new_bytes = buf.getvalue()
    replace_image(GLB, GLB, 0, new_bytes)
    print("glb embedded image replaced, new size", len(new_bytes),
          "mask px:", int(mask.sum()))

    # The loose PNG is Godot's own extract-on-import cache (gitignored, not
    # the fix itself) -- delete it so the next --import re-extracts fresh
    # from the now-patched .glb instead of leaving a stale pre-fix copy on
    # disk that happens to still pass a diff-less `git status`.
    if os.path.exists(LOOSE_PNG):
        os.remove(LOOSE_PNG)
        print("removed stale loose PNG cache, will re-extract on next --import")


if __name__ == "__main__":
    main()
