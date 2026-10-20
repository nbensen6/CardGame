"""Paint the staircase stones off a beast sprite.

Nick, 2026-10-20: "oh it looks like the outlines are painted on the jackal."
He was right, and it is the whole answer to a week of chasing the stones'
"outline they move out of": `cinder_jackal_2d.png` carries four pale slab
shapes across the belly, picked up when the sprite was built against TARGET.png
rather than from the stone-free concept. The real slabs are drawn separately,
at their own positions, so each one sits a little off its painted ghost.

Regenerating from the concept removes them and also throws away the raised
flaming fist, which is in the shipped sprite and not in the concept. So the
stones come off the shipped sprite instead.

They separate cleanly by colour: the jackal is red-brown rock and hot orange
cracks, the stones are neutral grey. Everything neutral and bright inside the
figure is a stone; it is replaced by growing the surrounding body colour in.

    python tools/beast_destone.py cinder_jackal
    python tools/beast_destone.py cinder_jackal --check   # report only

The original is kept as `<id>_2d.orig.png` the first time.
"""

import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage as ndi

CAST = os.path.join("game", "assets", "3d", "cast")
# Neutral enough, and bright enough, to be stone rather than shadowed rock.
MAX_SAT = 0.22
MIN_LUM = 70
# Ignore specks: a real slab is a solid shape, not a stray pixel.
MIN_BLOB = 120


def destone(beast, write):
    path = os.path.join(CAST, "%s_2d.png" % beast)
    im = Image.open(path).convert("RGBA")
    a = np.asarray(im).astype(float)
    rgb, al = a[..., :3], a[..., 3]
    solid = al > 40
    mx, mn = rgb.max(axis=2), rgb.min(axis=2)
    sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1), 0)
    lum = rgb @ np.array([0.299, 0.587, 0.114])

    grey = solid & (sat < MAX_SAT) & (lum > MIN_LUM)
    # keep whole shapes, drop specks, then close their outlines' gaps
    lab, n = ndi.label(ndi.binary_closing(grey, np.ones((3, 3), bool)))
    keep = np.zeros_like(grey)
    kept = 0
    for i in range(1, n + 1):
        blob = lab == i
        if blob.sum() >= MIN_BLOB:
            keep |= blob
            kept += 1
    # a painted slab is an outline around a darker middle: fill the holes so
    # the middle goes too, then take the whole shape a little wider
    keep = ndi.binary_fill_holes(keep)
    keep = ndi.binary_dilation(keep, np.ones((5, 5), bool)) & solid
    if not write or not keep.any():
        return int(keep.sum()), kept

    # Fill with the body's own local tone rather than growing an edge inward:
    # ring-growing smeared the facet edges it met into streaks across the
    # belly, which read worse than the ghost did. A wide blur of the known
    # body is plain rock -- it loses the facets under the stone, which were
    # never visible anyway, and keeps the lighting gradient.
    known = solid & ~keep
    out = rgb.copy()
    w = ndi.gaussian_filter(known.astype(float), 22.0)
    for c in range(3):
        src = ndi.gaussian_filter(np.where(known, rgb[..., c], 0.0), 22.0)
        smooth = src / np.maximum(w, 1e-4)
        out[..., c] = np.where(keep, smooth, rgb[..., c])

    keep_path = path.replace(".png", ".orig.png")
    if not os.path.exists(keep_path):
        im.save(keep_path)
    Image.fromarray(np.dstack([np.clip(out, 0, 255), al]).astype(np.uint8),
                    "RGBA").save(path)
    return int(keep.sum()), kept


def main():
    os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    beast = args[0] if args else "cinder_jackal"
    px, blobs = destone(beast, "--check" not in sys.argv)
    print("%s: %d px in %d shape(s)%s" % (beast, px, blobs,
                                          "" if "--check" in sys.argv else " painted out"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
