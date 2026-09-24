"""goblin_mech_ai pass 6 -- skin desaturates to near-white under the arena's
own lit-band lighting, found by a fresh six-view look plus a real in-fight
render (design/progress/goblin_mech_ai.md, "Pass 6").

Not a shader bug. `toon.gdshader`'s lit band multiplies the albedo by white
(mix(shadow_color, vec3(1.0), level), level->1 in full light) -- the same
thing happens to every toon-shaded model here, jackal and Frog included.
The Frog survives it because its own texture is saturated enough (measured
S 0.66-0.77) that multiplying toward white still leaves it reading green.
The Goblin's skin, even after pass 2's global boost, measures S 0.26-0.29 --
close enough to grey that the same multiply reads as near-white/cream at
true in-fight size. Confirmed directly on the shipped `state=3d` screenshot,
not inferred: skin pixels there sample as (240,243,220), (233,244,211) --
S under 10%, visibly cream, not green, next to the Frog's own clearly green
pixels in the same frame under the same light.

Fix: raise ONLY the skin's saturation further, leaving value alone -- this
is a `toon.gdshader` lit-band problem, not a brightness problem (pass 2
already made brightness right for the 34px portrait; darkening now would
undo that). Masks by hue alone (70-160 degrees, this hunter's green skin/ear
family) plus a floor on the CURRENT saturation and value (>0.12, >0.15) so
already-near-neutral pixels -- goggle-lens ice-blue highlights, cream tusks
and nails, teeth -- are never pulled toward green by an unstable hue reading
on a near-grey pixel. Confirmed by a diagnostic magenta recolour on the flat
texture atlas: the mask lands exactly on the skin/ear regions, nothing on
the tank, straps, goggles or boots.

SKIN_SAT_MUL 2.6 chosen by testing against known skin sample points until
their post-boost saturation (0.67-0.74) lands inside the Frog's own measured
range (0.66-0.77), not beyond it -- matching the survivor, not guessing.

Applies to both files, like pass 5:
1. The loose PNG (`goblin_mech_ai_Image_0.png`, already carrying pass 2 and
   pass 5's boosts) gets this skin boost added directly.
2. The glb's own embedded image (also already carrying pass 2 and pass 5,
   confirmed by pass 5's own fix) gets the identical boost, so the party
   portrait and the live fight stay in sync.
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

SKIN_HUE_LO, SKIN_HUE_HI = 70, 160
SKIN_SAT_MIN = 0.12
SKIN_VAL_MIN = 0.15
SKIN_SAT_MUL = 2.6


def skin_boost(rgb_u8):
    im = Image.fromarray(rgb_u8, "RGB")
    hsv = im.convert("HSV")
    h, s, v = [np.array(c, dtype=np.float32) for c in hsv.split()]
    h360 = h / 255.0 * 360.0
    sf = s / 255.0
    vf = v / 255.0
    mask = (h360 >= SKIN_HUE_LO) & (h360 <= SKIN_HUE_HI) & \
           (sf > SKIN_SAT_MIN) & (vf > SKIN_VAL_MIN)

    s2 = s.copy()
    s2[mask] = np.clip(s[mask] * SKIN_SAT_MUL, 0, 255)

    out = Image.merge("HSV", [Image.fromarray(h.astype(np.uint8)),
                               Image.fromarray(s2.astype(np.uint8)),
                               Image.fromarray(v.astype(np.uint8))])
    return np.array(out.convert("RGB")), mask


def main():
    loose = Image.open(LOOSE_PNG)
    has_alpha = loose.mode == "RGBA"
    alpha = loose.split()[-1] if has_alpha else None
    rgb = np.array(loose.convert("RGB"))
    rgb2, mask = skin_boost(rgb)
    out = Image.fromarray(rgb2, "RGB")
    if has_alpha:
        out.putalpha(alpha)
    out.save(LOOSE_PNG)
    print("loose PNG skin-boosted, mask px:", mask.sum())

    raw_bytes = extract_image(GLB, 0)
    raw_im = Image.open(io.BytesIO(raw_bytes))
    raw_has_alpha = raw_im.mode == "RGBA"
    raw_alpha = raw_im.split()[-1] if raw_has_alpha else None
    raw_rgb = np.array(raw_im.convert("RGB"))
    boosted2, mask2 = skin_boost(raw_rgb)
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
