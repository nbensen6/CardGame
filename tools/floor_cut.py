"""Cut TARGET.png's floor (the hex slabs below the lava line) into a texture
the fight projects onto its ground from the rest camera.

    python3 tools/floor_cut.py

Nick, 2026-10-08: "build the concept 1:1". The procedural hex floor
(obsidian.gdshader) went eleven grader rounds without matching TARGET's
slabs: their size, their dark seams with a warm lip, their tone. As with the
jackal (tools/beast_rig.py) and the cliffs (tools/backdrop_cut.py), the floor
is TARGET's own pixels: what TARGET draws on top of it (the Frog's pedestal
and the Frog, the lowest slab, the climb gauge, the cards and the HUD) is cut
out and inpainted; the fight's own pieces stand there.

Writes game/assets/3d/cast/cinder_jackal_floor.png: TARGET rows TOP..1024,
full width, alpha feathered at the left and right edges.
combat_3d._place_backdrop() hands the rest camera to drawn_floor.gdshader,
which maps each ground point through it into this texture.
"""
from pathlib import Path

import cv2
import numpy as np
from PIL import Image
from scipy import ndimage as ndi
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import gauge_unblend  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
TARGET = ROOT / "design/art/targets/TARGET.png"
OUT = ROOT / "game/assets/3d/cast/cinder_jackal_floor.png"

TOP = 540            # TARGET row the texture starts at (the lava band's foot)
LAVA_FOOT = 548      # rows above this are the lava band: alpha fades in below it
# What TARGET paints on the floor, in TARGET px (x0, y0, x1, y1).
# TARGET's own pedestal stays: the fight's stands on it, and wherever the two
# differ the painted one reads as its foot.
HOLES = [
    (270, 524, 446, 604),     # the lowest slab
    (900, 300, 1016, 740),    # the climb gauge
]
DARK_INV = ([0, 1, 3, 7, 13, 19, 24, 30, 255], [0, 9.3, 10, 12, 15, 20, 25, 30, 255])
FROG = (440, 578, 590, 712)   # box round the Frog and its marker
BAR = (428, 692, 596, 726)    # box round its HP bar
SHADOW = ((507.0, 692.0), (56.0, 8.0))   # centre, radii in TARGET px
CARDS_ROW = 790           # TARGET row the hand starts at: below it, rows repeat
CARRY = 40                # rows under it whose seams are carried on, not mirrored
KEEP_RIGHT_X = 912      # TARGET x from which rows below CARDS_ROW stay TARGET's own (0: off)
SHEAR = 2.3               # px right per row the carried seams slide
GROW = 4
GAUGE_MIRROR = True   # the floor under the climb gauge mirrored in from its left, not inpainted
GAUGE_UNBLEND = True  # ...or, better, recovered from under TARGET's see-through panel
SLAB_GROW = 2
SLAB_SHADE = 0.85   # the floor's tone under the lowest slab, its shadow
SIDE_FEATHER = 40
# Past the square's sides the 16:9 frame shows more floor: TARGET's slabs
# mirrored outward (a seam against the 3D floor's bigger, redder tiles read as
# a hard edge at x 280 / 1000). Matches tools/backdrop_cut.py's PAD.
PAD = 420
EDGE = 20             # TARGET px at each edge left out of the mirror (its frame)
PAD_BLEND = 70.0
PAD_DARK = 0.25


def build() -> None:
    T = np.asarray(Image.open(TARGET).convert("RGB"))
    if GAUGE_UNBLEND:
        # The floor behind TARGET's see-through gauge, recovered: the fight's
        # panel lands back on TARGET's pixels over it (tools/gauge_unblend.py).
        T = np.clip(gauge_unblend.unblend(T), 0, 255).astype(np.uint8)
    img = T[TOP:].copy()
    H, W = img.shape[:2]
    hole = np.zeros((H, W), bool)
    for i, (x0, y0, x1, y1) in enumerate(HOLES):
        if i == 1 and GAUGE_UNBLEND:
            continue
        if i == 0:
            # The lowest slab: its own pixels (pale grey, and its dark rim),
            # not its box. The box's corners showed past the fight's slab as
            # a dark rectangle once its fill went plain (grader 2026-10-09).
            ya, yb = max(0, y0 - TOP), y1 - TOP
            r = img[ya:yb, x0:x1].astype(int)
            mx, mn = r.max(2), r.min(2)
            g = (mx > 95) & ((mx - mn) < 0.3 * mx)
            g = ndi.binary_fill_holes(ndi.binary_closing(g, iterations=3))
            g = ndi.binary_dilation(g, iterations=SLAB_GROW)
            hole[ya:yb, x0:x1] |= g
            continue
        hole[max(0, y0 - TOP - GROW):max(0, y1 - TOP + GROW), max(0, x0 - GROW):x1 + GROW] = True
    # The Frog and its HP bar: only their own pixels (the green body and its
    # dark outline, the red bar and its rim), so the fill does not smear the
    # plinth round them (grader 2026-10-09, --frog close-up).
    for (x0, y0, x1, y1), keyf in ((FROG, "frog"), (BAR, "bar")):
        r = img[y0 - TOP:y1 - TOP, x0:x1].astype(int)
        if keyf == "frog":
            m = (r[..., 1] > r[..., 0] + 15) & (r[..., 1] > 70)
        else:
            m = (r[..., 0] > 110) & (r[..., 0] > r[..., 1] + 50)
        m = ndi.binary_closing(m, iterations=3)
        m = ndi.binary_fill_holes(m)
        m = ndi.binary_dilation(m, iterations=4 if keyf == "frog" else 3)
        hole[y0 - TOP:y1 - TOP, x0:x1] |= m
    bgr = np.ascontiguousarray(img[..., ::-1]).copy()
    plain = cv2.inpaint(bgr, hole.astype(np.uint8) * 255, 7, cv2.INPAINT_TELEA)[..., ::-1]
    # The lowest slab's hole reaches up into the lava band: inpainted from it,
    # its orange ran down under the fight's slab as a brown smear (grader
    # 2026-10-09). The band's rows are masked to the floor's own dark first.
    lava_rows = slice(0, max(0, LAVA_FOOT + 10 - TOP))
    floor_dark = np.median(img[LAVA_FOOT + 20 - TOP:LAVA_FOOT + 60 - TOP, :356].reshape(-1, 3), axis=0)
    bgr[lava_rows] = floor_dark[::-1].astype(np.uint8)
    fill = cv2.inpaint(bgr, hole.astype(np.uint8) * 255, 7, cv2.INPAINT_TELEA)[..., ::-1]
    out = img.astype(float)
    out[hole] = plain[hole]
    # Under the lowest slab TARGET's floor is plain dark rock in the slab's
    # shadow: past a few px in from its edge the hole goes to that tone, so
    # no seam the inpaint drags in streaks out below the fight's slab.
    x0, y0, x1, y1 = HOLES[0]
    slab = np.zeros((H, W), bool)
    slab[max(0, y0 - TOP - GROW):y1 - TOP + GROW, x0 - GROW:x1 + GROW] = True
    slab &= hole
    out[slab] = fill[slab]
    k = np.clip(ndi.distance_transform_edt(slab) / 4.0, 0, 1)[..., None]
    ring = ndi.binary_dilation(slab, iterations=10) & ~slab
    ring[:LAVA_FOOT + 12 - TOP] = False
    rp = img[ring].astype(float)
    tone = np.median(rp[rp.sum(1) < np.percentile(rp.sum(1), 60)], axis=0)
    out = out * (1 - k) + (tone * SLAB_SHADE) * k
    # The climb gauge's hole: inpainted, it pulled the lava band's orange
    # down onto the floor as a glow smear left of the gauge, and the floor's
    # seams stopped short of it (queue "Floor by the climb gauge", run 15).
    # The floor beside it is mirrored in instead, seams and all.
    if GAUGE_MIRROR and not GAUGE_UNBLEND:
        gx0, gy0, gx1, gy1 = HOLES[1]
        a0, a1 = gx0 - GROW, min(W, gx1 + GROW)
        rows = slice(0, max(0, gy1 - TOP + GROW))
        span = a1 - a0
        out[rows, a0:a1] = out[rows, a0 - span:a0][:, ::-1]
    # TARGET's soft shadow under the Frog, sampled: (28,23,33) on the plinth.
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    (sx, sy), (rx, ry) = SHADOW
    d = ((xx - sx) / rx) ** 2 + ((yy + TOP - sy) / ry) ** 2
    k = np.clip((1.0 - d) / 0.35, 0, 1)[..., None]
    out = out * (1 - k) + np.array([28.0, 23.0, 33.0]) * k
    # Rows past CARDS_ROW mirror the floor above them (the 16:9 frame's
    # corners show this part beside the hand; a carried last row read as
    # vertical stripes).
    band = CARDS_ROW - TOP
    for y in range(band, H):
        out[y] = out[max(0, 2 * band - 1 - y)]
    # The first CARRY rows under CARDS_ROW show between and beside the hand:
    # mirrored, TARGET's diagonal seams folded into chevrons there (grader
    # 2026-10-09, "a dark slab past the pedestal's lower right"). There each
    # row is the row above slid SHEAR px right, so the seams by the hand (they
    # run down and right at about 0.43) carry straight on.
    if CARRY:
        xs = np.arange(W, dtype=float)
        for y in range(band, min(H, band + CARRY)):
            for k in range(3):
                out[y, :, k] = np.interp(xs - SHEAR, xs, out[y - 1, :, k])
    # Right of End Turn and Switch TARGET's floor below the hand row is its
    # own: mirrored and sheared, a dark wedge of it landed as a seam above
    # End Turn (grader run 15, "Right of and under the climb gauge").
    if KEEP_RIGHT_X:
        out[band:, KEEP_RIGHT_X:] = img[band:, KEEP_RIGHT_X:]
    out[:, :EDGE] = out[:, EDGE:EDGE + 1]
    out[:, W - EDGE:] = out[:, W - EDGE - 1:W - EDGE]
    # Mirror only clean floor: left of the pedestal (x < 356) and between it
    # and the climb gauge (652..896), stretched to PAD.
    def stretch(block):
        im = Image.fromarray(np.clip(block, 0, 255).astype(np.uint8))
        return np.asarray(im.resize((PAD, block.shape[0]), Image.LANCZOS)).astype(float)
    # Past the first PAD_BLEND px (TARGET's edge mirrored, no seam) the pad is
    # each row's own tone carried on, darkening outward: plain dark floor, as
    # tools/backdrop_cut.py does for the cliffs (a stretched mirror read as
    # long bands of bright seams, grader 2026-10-09).
    def flatten(block):
        flat = np.repeat(ndi.gaussian_filter(block.mean(axis=1), (14, 0))[:, None, :], PAD, axis=1)
        t = np.clip(np.arange(PAD) / PAD_BLEND, 0, 1)[None, :, None]
        dark = 1.0 - PAD_DARK * np.clip(np.arange(PAD) / PAD, 0, 1)[None, :, None]
        return (block * (1 - t) + flat * t) * dark
    left = flatten(stretch(out[:, EDGE:356][:, ::-1])[:, ::-1])[:, ::-1]
    right = flatten(stretch(out[:, 652:896][:, ::-1]))
    out = np.concatenate([left, out, right], axis=1)
    W = out.shape[1]
    a = np.ones((H, W))
    xs = np.arange(W)
    a *= np.clip(np.minimum(xs, W - 1 - xs) / SIDE_FEATHER, 0, 1)[None, :]
    ys = np.arange(H) + TOP
    a *= np.clip((ys - (LAVA_FOOT - 4)) / 4.0, 0, 1)[:, None]
    # The colour table crushes TARGET's darkest values: measured on the
    # rendered floor, inputs 0-8 all draw 0, 10 draws 3, 15 draws 13 (the
    # plinth's navy side faces went flat black, grader 2026-10-09). Pre-map
    # each channel through the inverse so the screen shows TARGET's values.
    out = np.interp(out, DARK_INV[0], DARK_INV[1])
    rgba = np.dstack([np.clip(out, 0, 255), a * 255]).astype(np.uint8)
    Image.fromarray(rgba, "RGBA").save(OUT)
    print("floor:", OUT.relative_to(ROOT), W, "x", H, "pad", PAD)


if __name__ == "__main__":
    build()
