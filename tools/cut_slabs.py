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
from PIL import Image, ImageFilter
from scipy import ndimage as nd

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "design/art/targets/TARGET.png")
OUT = os.path.join(ROOT, "game/assets/3d/slabs")
PAD = 4
SCALE = 1  # TARGET's own pixels: the game draws them at ~0.7x, so no upsample
# The slabs are 3D sprites, so the fight's Environment (ACES tonemap, contrast
# 1.10, saturation 1.18 in combat_3d.tscn) runs over them; the jackal and the
# HUD are 2D and do not get it. Measured on the --stones pair (builder
# 2026-10-09 run 18) each channel came out as gain * TARGET + offset, the
# slab tops ~10 levels brighter and their pale top-edge light lost. So each
# cut carries the inverse: what the Environment turns back into TARGET.
# Each pass is per channel polynomial coefficients (highest power first) of
# shot = f(drawn) on 0..255, fitted on the shot after the passes before it;
# the cut undoes them last pass first.
SHARPEN = [100, 100, 80, 80, 45, 40]  # per slab, lowest first
SHARPEN_RADIUS = 1.0
ALPHA_IN = 4
SCREEN_COMP = [
    [(1.1275, -11.864), (1.16293, -17.915), (1.21524, -26.145)],
    [(-0.0044, 2.34034, -96.72835), (-0.00373, 2.09371, -75.0884), (-0.00336, 1.93158, -59.15251)],
]


def undo_screen(rgb):
    """The drawn colour the fight's Environment turns into `rgb` (0..255)."""
    xs = np.linspace(-60, 320, 3801)
    out = rgb.astype(float)
    for comp in reversed(SCREEN_COMP):
        for c in range(3):
            ys = np.polyval(comp[c], xs)
            # monotone over the slabs' tones; clip to where it rises
            keep = np.concatenate([[True], np.diff(ys) > 0])
            out[..., c] = np.interp(out[..., c], ys[keep], xs[keep])
    return out


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
        # Measured on the shot (run 18): the first pixel past TARGET's slab
        # edge came out ~20 levels bright, the slab drawn ~half a pixel fat.
        # Pull the matte in by ALPHA_IN 4x pixels.
        if ALPHA_IN > 0:
            alpha = nd.grey_erosion(alpha, size=(2 * ALPHA_IN + 1, 2 * ALPHA_IN + 1))
        # bleed: transparent pixels take the nearest slab pixel's colour
        solid = alpha > 0.5
        _, (iy, ix) = nd.distance_transform_edt(~solid, return_indices=True)
        rgb = big[iy, ix]
        rgb = undo_screen(rgb)
        img = np.dstack([np.clip(np.round(rgb), 0, 255), alpha * 255]).astype(np.uint8)
        im = Image.fromarray(img, "RGBA")
        im = im.resize((crop.width * SCALE, crop.height * SCALE), Image.LANCZOS)
        # The game shrinks the cut to ~0.7x and the sprite's linear filter
        # lands it off the pixel grid: measured on the --stones pair the
        # slab's fine detail came out ~11% under TARGET's. Pre-sharpen the
        # colour (not the alpha) by that much.
        if SHARPEN[k] > 0:
            r, g, b, al = im.split()
            rgb_s = Image.merge("RGB", (r, g, b)).filter(
                ImageFilter.UnsharpMask(radius=SHARPEN_RADIUS, percent=SHARPEN[k], threshold=0))
            im = Image.merge("RGBA", (*rgb_s.split(), al))
        im.save(os.path.join(OUT, "slab_%d.png" % k))
        print("slab_%d box=(%d,%d,%d,%d) centre=(%.1f,%.1f)" % (
            k, x0, y0, x1, y1, (x0 + x1) / 2, (y0 + y1) / 2))


if __name__ == "__main__":
    main()
