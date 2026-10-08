"""Cut TARGET.png's six staircase slabs out as RGBA sprites.

TARGET 1:1 (Nick, 2026-10-08): the procedural flagstones never took TARGET's
shapes, so the game draws the slabs TARGET drew. Each slab is the connected
grey region (low saturation, bright) in TARGET's staircase band, holes filled,
not grown (TARGET's slabs carry no dark rim), edge feathered, and the colour bled
outward under the transparent part so filtering leaves no dark halo.

Writes game/assets/3d/slabs/slab_<k>.png, k = 0 (lowest) .. 5 (top), and
prints each slab's TARGET box. Re-run is safe.

    python3 tools/cut_slabs.py
"""
import os
import numpy as np
from PIL import Image
from scipy import ndimage as nd

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "design/art/targets/TARGET.png")
OUT = os.path.join(ROOT, "game/assets/3d/slabs")
PAD = 4
SCALE = 1  # TARGET's own pixels: the game draws them at ~0.7x, so no upsample


def main():
    a = np.asarray(Image.open(SRC).convert("RGB")).astype(int)
    mx, mn = a.max(2), a.min(2)
    m = (mx - mn < 40) & (mx > 95)
    m[:300] = 0
    m[650:] = 0
    lab, _ = nd.label(m)
    comps = []
    for i, s in enumerate(nd.find_objects(lab)):
        if (lab[s] == i + 1).sum() > 300:
            comps.append((i + 1, s))
    # lowest slab first: sort by bottom edge, descending
    comps.sort(key=lambda c: -c[1][0].stop)
    assert len(comps) == 6, len(comps)
    os.makedirs(OUT, exist_ok=True)
    for k, (i, s) in enumerate(comps):
        y0, y1 = s[0].start - PAD, s[0].stop + PAD
        x0, x1 = s[1].start - PAD, s[1].stop + PAD
        mask = lab[y0:y1, x0:x1] == i
        mask = nd.binary_closing(mask, iterations=2)
        mask = nd.binary_fill_holes(mask)
        # Work at 4x so the edge is a smooth curve, not TARGET's pixel steps:
        # a soft grey-and-bright score, kept to the slab's own region.
        crop = Image.fromarray(a[y0:y1, x0:x1].astype(np.uint8))
        big = np.asarray(crop.resize((crop.width * 4, crop.height * 4), Image.BICUBIC)).astype(float)
        bmx, bmn = big.max(2), big.min(2)
        # grey share of a pixel blended with orange (saturation) or with the
        # dark floor (brightness): ~0.5 on the drawn edge
        soft = np.minimum(np.clip((110 - (bmx - bmn)) / 70, 0, 1), np.clip((bmx - 60) / 80, 0, 1))
        region = np.asarray(Image.fromarray(mask.astype(np.uint8) * 255).resize(
            (crop.width * 4, crop.height * 4), Image.NEAREST)) > 0
        core = nd.binary_erosion(region, iterations=6)
        region = nd.binary_dilation(region, iterations=3)
        soft = np.where(core, 1.0, soft * region)
        soft = nd.gaussian_filter(soft, 1.2)
        alpha = np.clip((soft - 0.3) / 0.4, 0, 1)
        # bleed: transparent pixels take the nearest slab pixel's colour
        solid = alpha > 0.5
        _, (iy, ix) = nd.distance_transform_edt(~solid, return_indices=True)
        rgb = big[iy, ix]
        img = np.dstack([rgb, alpha * 255]).astype(np.uint8)
        im = Image.fromarray(img, "RGBA")
        im = im.resize((crop.width * SCALE, crop.height * SCALE), Image.LANCZOS)
        im.save(os.path.join(OUT, "slab_%d.png" % k))
        print("slab_%d box=(%d,%d,%d,%d) centre=(%.1f,%.1f)" % (
            k, x0, y0, x1, y1, (x0 + x1) / 2, (y0 + y1) / 2))


if __name__ == "__main__":
    main()
