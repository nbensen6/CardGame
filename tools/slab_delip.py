"""Close the hairline that splits a slab's lip off its top.

Nick, 2026-10-19: "the stones still have an outline ... can you see the part
that is separated from the stone?"

The six staircase slabs are cut straight out of `TARGET.png`. At the painting's
size each stone carries a thin darker line along its upper-left, separating a
narrow pale lip (the far edge, catching light) from the top surface. That is a
good painted detail at 1024 px. In the fight the same stone is drawn a few
dozen pixels wide, the line falls to about one pixel, and the lip stops reading
as part of the stone: it reads as a sliver floating off it.

So the hairline is closed and the lip joins the top. Anything WIDE stays --
the real top/side division that gives the stone its form is untouched.

    python tools/slab_delip.py            # rewrite the six cuts in place
    python tools/slab_delip.py --check    # report only, change nothing

Originals are kept beside them as `<name>.orig.png` the first time, so this is
reversible.
"""

import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage as ndi

SLABS = os.path.join("game", "assets", "3d", "slabs")
# A line thinner than this many pixels is a hairline, not a face boundary.
MAX_LINE = 2
# How much darker than its pale neighbours a pixel must be to count as the line.
DARK_BY = 14


def delip(path, write):
    im = Image.open(path).convert("RGBA")
    a = np.asarray(im).astype(np.int16)
    rgb, alpha = a[..., :3], a[..., 3]
    solid = alpha > 200
    lum = rgb @ np.array([299, 587, 114]) // 1000

    # the stone's pale material: the brighter half of its own solid pixels
    if not solid.any():
        return 0
    pale_cut = np.percentile(lum[solid], 55)
    pale = solid & (lum >= pale_cut)

    # a hairline is what separates two pale regions across a gap at most
    # MAX_LINE wide: close the pale mask by that much and keep what filled in
    closed = ndi.binary_closing(pale, np.ones((MAX_LINE + 1, MAX_LINE + 1), bool))
    line = closed & ~pale & solid & (lum <= pale_cut - DARK_BY)
    n = int(line.sum())
    if n == 0 or not write:
        return n

    # fill each line pixel with the pale tone around it
    out = rgb.copy()
    for c in range(3):
        ch = rgb[..., c].astype(float)
        src = np.where(pale, ch, np.nan)
        # mean of the pale neighbours in a small window
        filled = ndi.generic_filter(np.nan_to_num(src), np.mean, size=5)
        weight = ndi.uniform_filter(pale.astype(float), size=5)
        filled = np.divide(filled, np.maximum(weight, 1e-3))
        out[..., c] = np.where(line, np.clip(filled, 0, 255), ch).astype(np.int16)

    keep = path.replace(".png", ".orig.png")
    if not os.path.exists(keep):
        im.save(keep)
    Image.fromarray(np.dstack([out, alpha]).astype(np.uint8), "RGBA").save(path)
    return n


def main():
    os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    write = "--check" not in sys.argv
    total = 0
    for i in range(6):
        p = os.path.join(SLABS, "slab_%d.png" % i)
        if not os.path.exists(p):
            continue
        n = delip(p, write)
        total += n
        print("slab_%d: %4d hairline px %s" % (i, n, "closed" if write and n else ""))
    print("%d px in all%s" % (total, "" if write else " (check only)"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
