"""Cut a card's art straight from TARGET.png, framed as the fight's art window.

    python3 tools/cardart_cut.py

Builder 2026-10-09 (queue "Cards: big bright art"): the earlier cut reflected
TARGET's small window out to a 620x870 portrait, and the card's cover crop
showed the mirrored copies at its edges (a ghost creature beside Scramble's)
and TARGET's art ~1.13x too large. This cuts exactly TARGET's window at the
card's own window aspect (card_view.A1_ART on the 690x984 frame: ~1.35),
deskewed, with TARGET's cost badge and type pill inpainted out (the card draws
its own), so the cover crop shows TARGET's framing and nothing else.
"""
from pathlib import Path

import cv2
import numpy as np
from PIL import Image
from scipy import ndimage as ndi

ROOT = Path(__file__).resolve().parent.parent
TARGET = ROOT / "design/art/targets/TARGET.png"
OUT = ROOT / "game/assets/cardart"

# name: (window centre x, y in TARGET px, card tilt in degrees, + = clockwise)
CARDS = {"scramble": (643.0, 878.0, 3.0), "leap": (366.5, 884.0, -4.0)}
# Shipped from this cut: scramble only (window error 35.9 -> 30.1 on the
# --hand square). Leap's cut registered worse (24.2 -> 34.4) and the older
# reflected cut stays; run with a name to cut one card.
WIN_W = 129.0                      # TARGET px: the art under the frame too (registered: 116 drew TARGET 1.11x)
ASPECT = (0.958 * 690) / (0.498 * 984)
SCALE = 5                          # output px per TARGET px


def cut(name: str, cx: float, cy: float, tilt: float) -> None:
    T = np.asarray(Image.open(TARGET).convert("RGB"))
    M = cv2.getRotationMatrix2D((cx, cy), tilt, 1.0)
    R = cv2.warpAffine(T, M, (T.shape[1], T.shape[0]), flags=cv2.INTER_LANCZOS4, borderMode=cv2.BORDER_REFLECT)
    w, h = WIN_W, WIN_W / ASPECT
    x0, y0 = int(round(cx - w / 2)), int(round(cy - h / 2))
    crop = R[y0:y0 + int(round(h)), x0:x0 + int(round(w))].copy()
    r, g, b = [crop[..., k].astype(int) for k in range(3)]
    mx, mn = crop.max(2).astype(int), crop.min(2).astype(int)
    # TARGET's cost badge (a saturated emerald disc, top left) and its type
    # pill (pale grey, low in the window): the card draws its own.
    badge = (g > r + 40) & (g > b + 10) & (g > 90) & (b > 40)
    badge &= np.arange(crop.shape[0])[:, None] < crop.shape[0] * 0.45
    badge &= np.arange(crop.shape[1])[None, :] < crop.shape[1] * 0.4
    pill = (mx > 150) & (mx - mn < 30)
    pill &= np.arange(crop.shape[0])[:, None] > crop.shape[0] * 0.7
    hole = ndi.binary_dilation(ndi.binary_fill_holes(ndi.binary_closing(badge | pill, iterations=2)), iterations=3)
    # The name band's dark bottom edge, if the window's top row caught it.
    dark_top = np.zeros_like(hole)
    for y in range(min(6, crop.shape[0])):
        if (mx[y] < 70).mean() > 0.6:
            dark_top[y] = True
    hole |= dark_top
    bgr = np.ascontiguousarray(crop[..., ::-1])
    fill = cv2.inpaint(bgr, hole.astype(np.uint8) * 255, 5, cv2.INPAINT_TELEA)[..., ::-1]
    crop[hole] = fill[hole]
    out = Image.fromarray(crop).resize((int(round(w * SCALE)), int(round(h * SCALE))), Image.LANCZOS)
    out.save(OUT / f"{name}.png")
    print(f"cardart_cut: {name} {out.size[0]}x{out.size[1]}, {int(hole.sum())} px inpainted")


if __name__ == "__main__":
    import sys
    for n in (sys.argv[1:] or ["scramble"]):
        cut(n, *CARDS[n])
