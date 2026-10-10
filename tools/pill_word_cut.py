"""Cut each hand card's type-pill word straight from TARGET.png.

    python3 tools/pill_word_cut.py

Matched check 2026-10-10 run 9 (both critics MINOR): TARGET's pill words are
soft painted lettering that differs card to card (Leap's smears to "SSill",
Tongue Flick's "Attack" runs its letters together); the game printed one crisp
font word. This keys the dark ink off each TARGET pill (deskewed by the
card's tilt, the pill's own pale fill estimated by a grey closing so the ink
drops out of it) and writes game/assets/ui/pill_word_<card id>.png: white,
with the ink as alpha, covering exactly the pill's bounding box, so
card_view.gd stretches it over its own pill rect and tints it TARGET's ink.
"""
from pathlib import Path

import cv2
import numpy as np
from PIL import Image
from scipy import ndimage as ndi

ROOT = Path(__file__).resolve().parent.parent
TARGET = ROOT / "design/art/targets/TARGET.png"
OUT = ROOT / "game/assets/ui"

# card id: the art window's centre in TARGET px and the card's tilt (as
# tools/cardart_cut.py); the pill sits ~20-60 px under the window's centre.
CARDS = {"scramble": (647.3, 882.4, 5.0), "leap": (373.8, 882.2, -5.0),
         "tongue_snap": (510.5, 872.5, 0.0), "flick": (781.3, 893.7, 9.0)}
UP = 8          # output px per TARGET px
GAIN = 1.2
LIFT = 6        # output px
INK = 46.0      # TARGET's darkest ink luminance (~(41,42,51))


def cut(name, cx, cy, tilt):
    T = np.asarray(Image.open(TARGET).convert("RGB")).astype(np.float32)
    M = cv2.getRotationMatrix2D((cx, cy), tilt, 1.0)
    big = cv2.resize(T, None, fx=UP, fy=UP, interpolation=cv2.INTER_LANCZOS4)
    Mb = cv2.getRotationMatrix2D((cx * UP, cy * UP), tilt, 1.0)
    R = cv2.warpAffine(big, Mb, (big.shape[1], big.shape[0]), flags=cv2.INTER_LINEAR)
    y0, y1 = int((cy + 18) * UP), int((cy + 62) * UP)
    x0, x1 = int((cx - 42) * UP), int((cx + 42) * UP)
    c = R[y0:y1, x0:x1]
    lum = c @ np.array([0.299, 0.587, 0.114], np.float32)
    sat = c.max(2) - c.min(2)
    pale = (lum > 120) & (sat < 40)
    # the pill: the biggest pale blob, holes (the word) filled
    lab, n = ndi.label(ndi.binary_opening(pale, iterations=2))
    sizes = ndi.sum(pale, lab, range(1, n + 1))
    pill = ndi.binary_fill_holes(lab == (int(np.argmax(sizes)) + 1))
    # Leap's pale foliage can join the blob above it: keep the rows as wide
    # as the capsule
    rw = pill.sum(1)
    rows = np.nonzero(rw >= 0.55 * rw.max())[0]
    pill[:rows.min()] = False
    pill[rows.max() + 1:] = False
    ys, xs = np.nonzero(pill)
    by0, by1, bx0, bx1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    # the pill's own fill under the word: grey closing wipes the dark strokes
    fill = ndi.grey_closing(lum, size=(UP * 3, UP * 3))
    a = np.clip((fill - lum) / np.maximum(fill - INK, 1.0), 0.0, 1.0)
    # only inside the pill, away from its dark rim
    inner = ndi.binary_erosion(pill, iterations=int(UP * 1.6))
    a = np.where(inner, a, 0.0)
    a[a < 0.12] = 0.0
    # the word only: drop the rim's specks (small blobs)
    lab, n = ndi.label(a > 0.25)
    if n:
        sz = ndi.sum(a > 0.25, lab, range(1, n + 1))
        small = np.isin(lab, [i + 1 for i in range(n) if sz[i] < UP * UP * 1.2])
        grow = ndi.binary_dilation(small, iterations=2) & ~ndi.binary_dilation(
            (lab > 0) & ~small, iterations=2)
        a[grow] = 0.0
        a[~ndi.binary_dilation((lab > 0) & ~small, iterations=UP // 2)] = 0.0
    a = a[by0:by1, bx0:bx1]
    # the word sits in the capsule's middle: nothing in its top and bottom
    # fifths or its end caps (Leap's arc of foliage crossed the top)
    h, w = a.shape
    a[:int(h * 0.2)] = 0.0
    a[int(h * 0.85):] = 0.0
    a[:, :int(w * 0.12)] = 0.0
    a[:, int(w * 0.85):] = 0.0
    # the hand draws the cut at ~0.6x through mips, which thins the strokes:
    # carry the ink at full strength where TARGET's core is
    a = np.clip(a * GAIN, 0.0, 1.0)
    # the card's own pill rect sits ~0.7 TARGET px lower than TARGET's pill
    # round the word: lift the word to TARGET's row
    a = np.roll(a, -LIFT, axis=0)
    rgba = np.zeros(a.shape + (4,), np.uint8)
    rgba[..., :3] = 255
    rgba[..., 3] = (a * 255).astype(np.uint8)
    Image.fromarray(rgba, "RGBA").save(OUT / f"pill_word_{name}.png")
    print(name, "pill", (bx1 - bx0) / UP, "x", (by1 - by0) / UP, "TARGET px")


if __name__ == "__main__":
    for k, v in CARDS.items():
        cut(k, *v)
