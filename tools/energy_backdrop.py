"""Cut TARGET.png's energy-box glow and the near-black floor round it.

TARGET draws the energy box in a soft orange glow over a near-black patch of
floor that runs down past the pile icons. A StyleBox shadow could not match
that falloff (grader, 2026-10-09), so the game draws TARGET's own pixels
behind the box: this script cuts them, with the box itself, the pile icons
and the first card blanked out (the game draws its own on top) and the
outer edges feathered into the floor.

    python3 tools/energy_backdrop.py

Writes game/assets/ui/energy_backdrop.png and prints the box-relative rect
combat_3d.ENERGY_BACKDROP_RECT must hold.
"""
import os

import cv2
import numpy as np
from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
TARGET = os.path.join(ROOT, "design", "art", "targets", "TARGET.png")
OUT = os.path.join(ROOT, "game", "assets", "ui", "energy_backdrop.png")

# TARGET.png (1024 px): the outer edge of the box's gold line
BOX = (19, 811, 137, 930)          # x0, y0, x1, y1 (exclusive)
# the cut: the box, its glow, the near-black floor down past the piles
CUT = (0, 772, 228, 1012)
# below this row the first card's slanted left edge: column at CARD_TOP,
# and how far it leans right per row (the game's card draws over it)
CARD_TOP, CARD_LEFT, CARD_LEAN = 826, 149, 26.0 / 187.0
# the gold line's corner radius on TARGET (its diagonal crosses at ~6 px)
RADIUS = 20.0
# the pile icons and their labels
PILES = (16, 942, 142, 1004)   # run 7: from 936 cut TARGET's glow under the box off (it fades to ~940; the icons start ~941)
DARK = np.array([9, 2, 0], float)
GLOW = np.array([95, 55, 12], float)
FACE = np.array([91, 45, 10], float)
RIM = np.array([230, 180, 95], float)
FEATHER = 5.0


def main():
    t = np.asarray(Image.open(TARGET).convert("RGB")).astype(float)
    x0, y0, x1, y1 = CUT
    img = t[y0:y1, x0:x1].copy()
    h, w = img.shape[:2]
    ys, xs = np.mgrid[y0:y1, x0:x1]
    a = np.ones((h, w))

    # the box and 2 px round it: the game draws its own, TARGET's would
    # double the gold line wherever the two are a pixel apart
    bx0, by0, bx1, by1 = BOX
    cx, cy = (bx0 + bx1 - 1) / 2.0, (by0 + by1 - 1) / 2.0
    hx, hy = (bx1 - bx0) / 2.0 - RADIUS, (by1 - by0) / 2.0 - RADIUS
    qx = np.maximum(np.abs(xs - cx) - hx, 0.0)
    qy = np.maximum(np.abs(ys - cy) - hy, 0.0)
    inner = np.minimum(np.maximum(np.abs(xs - cx) - hx, np.abs(ys - cy) - hy), 0.0)
    sdf = np.hypot(qx, qy) + inner - RADIUS
    # TARGET's face, mottled and darker at its edge, is kept (the game's
    # panel draws only the gold line now); the numeral is painted out, the
    # game draws its own
    face = sdf < -6.0
    off = np.abs(img - FACE).max(axis=2) > 20
    num = (face & off).astype(np.uint8)
    num = cv2.dilate(num, np.ones((9, 9), np.uint8))
    u8 = np.clip(img, 0, 255).astype(np.uint8)
    img = cv2.inpaint(u8, num, 6, cv2.INPAINT_TELEA).astype(float)
    # under the game's gold line: a gold fill, so no fringe either side
    # (the game's line is 3.7 TARGET px wide, its outer edge on BOX),
    # antialiased on the box's own curve
    sd = sdf[..., None]
    img = img + (GLOW - img) * np.clip(2.5 - sd, 0.0, 1.0) * np.clip(sd + 4.0, 0.0, 1.0)
    rim = np.clip(0.5 - sd, 0.0, 1.0) * np.clip(sd + 4.0, 0.0, 1.0)
    img = img + (RIM - img) * rim
    # the pile icons: the game draws its own over near-black
    px0, py0, px1, py1 = PILES
    piles = (xs >= px0) & (xs < px1) & (ys >= py0) & (ys < py1)
    img[piles] = DARK
    # anything green in the top strip is the first card's cost pip
    g = (img[..., 1] > img[..., 0] + 25).astype(np.uint8)
    g = cv2.dilate(g, np.ones((7, 7), np.uint8)).astype(bool) & (xs > bx1 + 4)
    img[g] = DARK
    # the first card's top edge, where it pokes into the strip
    img[(img.mean(axis=2) > 110) & (xs > bx1 + 4) & (ys > 800)] = DARK

    # feather: the left and top edges, the right edge of the top strip, the
    # card's left edge below it, the bottom edge
    # the left and bottom edges meet TARGET's own dark frame, which the
    # game draws too: a short feather there keeps the glow's outer reach
    d = np.minimum((xs - x0) * FEATHER / 2.0, ys - y0).astype(float)
    d = np.minimum(d, ((y1 - 1) - ys) * FEATHER / 2.0)
    card = CARD_LEFT + np.maximum(ys - CARD_TOP, 0) * CARD_LEAN
    under_card = (ys >= CARD_TOP) & (xs >= card)
    img[under_card] = DARK
    right = np.where(ys < CARD_TOP, (x1 - 1) - xs, card + FEATHER - xs)
    d = np.minimum(d, right)
    # under the strip, the corner between it and the card column
    a = np.clip(d / FEATHER, 0.0, 1.0)

    rgba = np.dstack([np.clip(img, 0, 255), a * 255]).astype(np.uint8)
    Image.fromarray(rgba, "RGBA").save(OUT)
    bw, bh = bx1 - bx0, by1 - by0
    print("wrote", OUT, rgba.shape[1], "x", rgba.shape[0])
    print("ENERGY_BACKDROP_RECT = Rect2(%.4f, %.4f, %.4f, %.4f)" % (
        (x0 - bx0) / bw, (y0 - by0) / bh, w / bw, h / bh))


if __name__ == "__main__":
    main()
