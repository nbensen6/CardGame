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
SHARPEN = [60, 60, 60, 60, 60, 60]  # per slab, lowest first
SHARPEN_RADIUS = 1.0
REBLEED = True
ALPHA_IN = 3
ALPHA_IN_DARK = 110  # ... where the slab's background is darker than this
MATTE = True
MATTE_IN = 3     # 4x px inside the opaque slab its colour is read from
MATTE_OUT = 4    # 4x px outside where the background colour is read
MATTE_POW = 1.0  # the edge's alpha squared: the shot's resample spreads it ~half a pixel out
MATTE_MIN = 30.0 # least slab-to-background colour distance the matte trusts
LIP = 2          # TARGET px of dark grey underside lip the slab grows into
LIP_MIN = 70     # its darkest level
EDGE_CLEAN = 6   # 4x px: the edge band whose warm pixels are cleaned
EDGE_SAT = 28    # grey slab pixels stay under this max-min spread
# The colour matte reads a new background colour per edge pixel, so over the
# jackal's cracks its contour came out notched: the grader named the middle
# slab's lower edge ragged against TARGET's smooth line (run 18, R3-R5).
# Smooth the contour (4x px sigma) and rebuild a one-TARGET-px AA ramp.
EDGE_SMOOTH = 2.0
EDGE_RAMP = 4.0  # 2.5 tried (run 19): no closer  # 4x px over which alpha goes 0 -> 1
# TARGET draws a dark lip and shadow line just under each slab that the
# fight's backdrop behind the cut does not carry, so the edge read pale
# (grader run 18). The cut carries RING TARGET px of TARGET's own pixels
# round the slab, fading out, composited under the slab's edge.
# Under the slab only, the edge's part-covered pixels are TARGET's own blend,
# opaque: the rig's rebuilt crack under the stone showed through them as a
# yellow speck where TARGET's crack tip meets the middle slab (run 19).
UNDER_OPAQUE = 0.0  # tried 0.15 at 4x (run 19): the 1x resize left it part-covered
# At TARGET's own pixels: the first UNDER_LIP px under the slab's opaque
# underside are TARGET's own, opaque, where TARGET is darker than LIP_DARK.
UNDER_LIP = 0  # tried 1 (run 19): slab error 4.3 -> 4.7, the lip landed off TARGET's
LIP_DARK = 140
RING = 0.0  # tried 2.0 (run 19): slab error 4.3 -> 5.4 levels, a halo on the tops
# The fight draws the cuts through drawn_sprite.gdshader (combat_3d
# STAIR_SLAB_DRAWN), whose colour table already undoes the Environment.
DRAWN = True
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
        # The slab's dark grey underside lip (~100 levels, TARGET's own
        # edge under the stone) fails the bright test: without it the
        # fight's crack showed through as warm specks along the slab's
        # underside (critics 2026-10-09 run 18). Grow into grey pixels
        # touching the slab, LIP px at most.
        if LIP:
            crop_a = a[y0:y1, x0:x1]
            grey = ((crop_a.max(2) - crop_a.min(2)) < 28) & (crop_a.max(2) > LIP_MIN)
            for _ in range(LIP):
                mask = mask | (nd.binary_dilation(mask) & grey)
        mask = nd.binary_closing(mask, iterations=2)
        mask = nd.binary_fill_holes(mask)
        # Work at 4x so the edge is a smooth curve, not TARGET's pixel steps:
        # a soft grey-and-bright score, kept to the slab's own region.
        crop = Image.fromarray(a[y0:y1, x0:x1].astype(np.uint8))
        big = np.asarray(crop.resize((crop.width * 4, crop.height * 4), Image.BICUBIC)).astype(float)
        bmx, bmn = big.max(2), big.min(2)
        # grey share of a pixel blended with orange (saturation) or with the
        # dark floor (brightness): ~0.5 on the drawn edge
        soft = np.minimum(np.clip((110 - (bmx - bmn)) / 70, 0, 1), np.clip((bmx - LIP_MIN + 10) / 50, 0, 1) if LIP else np.clip((bmx - 60) / 80, 0, 1))
        region = np.asarray(Image.fromarray(mask.astype(np.uint8) * 255).resize(
            (crop.width * 4, crop.height * 4), Image.NEAREST)) > 0
        core = nd.binary_erosion(region, iterations=6)
        region = nd.binary_dilation(region, iterations=3)
        soft = np.where(core, 1.0, soft * region)
        soft = nd.gaussian_filter(soft, 1.2)
        alpha = np.clip((soft - 0.3) / 0.4, 0, 1)
        fgcol = None
        if MATTE:
            # Colour matting at the edge (builder run 18): each edge pixel is
            # TARGET's blend of the slab's grey and what lies behind it, so
            # its alpha is how far it sits from the nearest outside colour
            # toward the nearest slab colour. A threshold ramp drew the
            # slabs half a pixel fat over dark rock and, pulled in, let the
            # lava and cracks through as warm specks.
            inner = nd.binary_erosion(alpha > 0.99, iterations=MATTE_IN)
            outer = ~nd.binary_dilation(alpha > 0.01, iterations=MATTE_OUT)
            _, (fy, fx) = nd.distance_transform_edt(~inner, return_indices=True)
            _, (gy, gx) = nd.distance_transform_edt(~outer, return_indices=True)
            fg, bg = big[fy, fx], big[gy, gx]
            dv = fg - bg
            den = (dv * dv).sum(2)
            am = np.clip(((big - bg) * dv).sum(2) / np.maximum(den, 1e-3), 0, 1)
            band = ~inner & ~outer & (den > MATTE_MIN ** 2)
            # The slab's own darker grey (its underside lip, ~100) is slab,
            # not a blend with the dark behind it: opaque, its own colour.
            lip = region & ((bmx - bmn) < 28) & (bmx > LIP_MIN)
            am = np.where(lip, 1.0, am)
            alpha = np.where(band, am ** MATTE_POW, np.where(outer, 0.0, alpha))
            fg = np.where(lip[..., None], big, fg)
            fgcol = fg
        # Measured on the shot (run 18): the first pixel past TARGET's slab
        # edge came out ~20 levels bright, the slab drawn ~half a pixel fat.
        # Pull the matte in by ALPHA_IN 4x pixels.
        if ALPHA_IN > 0:
            er = nd.grey_erosion(alpha, size=(2 * ALPHA_IN + 1, 2 * ALPHA_IN + 1))
            if fgcol is not None:
                # only over dark rock: over the lava line and the cracks a
                # pulled-in edge let them through as warm specks
                bgl = nd.grey_dilation(bg.max(2), size=(2 * ALPHA_IN + 3, 2 * ALPHA_IN + 3))
                er = np.where(bgl < ALPHA_IN_DARK, er, alpha)
            alpha = er
        if EDGE_SMOOTH > 0:
            sm = nd.gaussian_filter(alpha, EDGE_SMOOTH)
            # signed distance to the smoothed 0.5 contour, as a ramp
            inside = sm >= 0.5
            d_in = nd.distance_transform_edt(inside)
            d_out = nd.distance_transform_edt(~inside)
            sd = np.where(inside, d_in - 0.5, 0.5 - d_out)
            alpha = np.clip(0.5 + sd / EDGE_RAMP, 0, 1)
        # bleed: transparent pixels take the nearest slab pixel's colour
        solid = alpha > 0.5
        _, (iy, ix) = nd.distance_transform_edt(~solid, return_indices=True)
        rgb = big[iy, ix]
        if fgcol is not None:
            edge = ~nd.binary_erosion(alpha > 0.99, iterations=MATTE_IN)
            rgb[edge] = fgcol[edge]
        # TARGET's slab edges are anti-aliased against the jackal's orange
        # cracks: those edge pixels carried the orange in, a row of warm
        # specks along a slab's underside (critics 2026-10-09 run 18). The
        # slabs are grey: an edge pixel with colour in it takes the nearest
        # grey core pixel's colour instead.
        core = nd.binary_erosion(solid, iterations=EDGE_CLEAN)
        sat = rgb.max(2) - rgb.min(2)
        warm = ~core & (sat > EDGE_SAT)
        _, (cy, cx) = nd.distance_transform_edt(~(core & (sat <= EDGE_SAT)), return_indices=True)
        rgb[warm] = rgb[cy[warm], cx[warm]]
        if UNDER_OPAQUE > 0:
            op = alpha > 0.99
            _, (oy, ox) = nd.distance_transform_edt(~op, return_indices=True)
            yy = np.arange(alpha.shape[0])[:, None]
            under = (alpha > UNDER_OPAQUE) & ~op & (oy < yy - 1)
            rgb = np.where(under[..., None], big, rgb)
            alpha = np.where(under, 1.0, alpha)
        if RING > 0:
            r4 = RING * 4
            d_out = nd.distance_transform_edt(alpha < 0.5)
            ra = np.clip(1 - d_out / r4, 0, 1)
            # the edge is TARGET's own blend, so it is not added twice
            edge4 = alpha < 0.99
            A = np.where(edge4, ra, 1.0)
            rgb = np.where(edge4[..., None], big, rgb)
            # past the ring: the bled colour, so filtering leaves no halo
            far = A < 1e-3
            _, (iy2, ix2) = nd.distance_transform_edt(far, return_indices=True)
            rgb = rgb[iy2, ix2]
            alpha = A
        if not DRAWN:
            rgb = undo_screen(rgb)
        img = np.dstack([np.clip(np.round(rgb), 0, 255), alpha * 255]).astype(np.uint8)
        im = Image.fromarray(img, "RGBA")
        im = im.resize((crop.width * SCALE, crop.height * SCALE), Image.LANCZOS)
        if REBLEED:
            # Pillow's RGBA resize leaves the clear pixels black, and the
            # unsharp mask below then lit a pale fringe along every slab's
            # edge (the middle slab's lower edge, grader run 19). Bleed the
            # slab's colour out again under the part-clear pixels first.
            px = np.asarray(im).astype(float).copy()
            sol = px[..., 3] > 127
            _, (by, bx) = nd.distance_transform_edt(~sol, return_indices=True)
            w = (px[..., 3] / 255.0)[..., None]
            # part-covered edge pixels keep their own colour where they have one
            keep_own = (px[..., 3] > 20)[..., None]
            bled = px[by, bx, :3]
            px[..., :3] = np.where(keep_own, px[..., :3], bled)
            im = Image.fromarray(np.clip(np.round(px), 0, 255).astype(np.uint8), "RGBA")
        # The game shrinks the cut to ~0.7x and the sprite's linear filter
        # lands it off the pixel grid: measured on the --stones pair the
        # slab's fine detail came out ~11% under TARGET's. Pre-sharpen the
        # colour (not the alpha) by that much.
        if SHARPEN[k] > 0:
            r, g, b, al = im.split()
            rgb_s = Image.merge("RGB", (r, g, b)).filter(
                ImageFilter.UnsharpMask(radius=SHARPEN_RADIUS, percent=SHARPEN[k], threshold=0))
            im = Image.merge("RGBA", (*rgb_s.split(), al))
        if UNDER_LIP:
            px = np.asarray(im).astype(float).copy()
            al = px[..., 3] / 255
            tc = a[y0:y1, x0:x1].astype(float)
            op = al > 0.97
            lip_m = np.zeros_like(op)
            below = op.copy()
            for _ in range(UNDER_LIP + 1):
                nxt = np.zeros_like(below)
                nxt[1:] = below[:-1]
                lip_m |= nxt & ~op
                below = nxt
            # only those directly under the slab, and dark in TARGET
            lip_m &= (tc.max(2) < LIP_DARK) & nd.binary_dilation(op, iterations=UNDER_LIP + 1)
            # not where the slab only touches a corner: an opaque px above
            up = np.zeros_like(op)
            for d in range(1, UNDER_LIP + 2):
                up[d:] |= op[:-d]
            lip_m &= up
            px[lip_m, :3] = tc[lip_m]
            px[lip_m, 3] = 255
            im = Image.fromarray(np.clip(np.round(px), 0, 255).astype(np.uint8), "RGBA")
        im.save(os.path.join(OUT, "slab_%d.png" % k))
        print("slab_%d box=(%d,%d,%d,%d) centre=(%.1f,%.1f)" % (
            k, x0, y0, x1, y1, (x0 + x1) / 2, (y0 + y1) / 2))


if __name__ == "__main__":
    main()
