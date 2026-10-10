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
from PIL import Image, ImageEnhance, ImageFilter
from scipy import ndimage as ndi

ROOT = Path(__file__).resolve().parent.parent
TARGET = ROOT / "design/art/targets/TARGET.png"
OUT = ROOT / "game/assets/cardart"

# name: (window centre x, y in TARGET px, card tilt in degrees, + = clockwise[,
# window width in TARGET px when the card's window is not WIN_W])
CARDS = {"scramble": (647.3, 882.4, 5.0, 137.0), "leap": (373.8, 882.2, -5.0, 137.0),
         "tongue_snap": (510.5, 872.5, 0.0, 137.0), "flick": (781.3, 893.7, 9.0, 138.3)}   # run 16: the window runs 0.033 of the card further left (card_view A1_LEFT_OUT)
# Shipped from this cut: scramble only (window error 35.9 -> 30.1 on the
# --hand square). Leap's cut registered worse (24.2 -> 34.4) and the older
# reflected cut stays; run with a name to cut one card.
SATURATE = {"leap": 1.2}
USM = {"flick": 40, "tongue_snap": 60}   # run 6-7: at 130 the halo lit the blade's grey right face as bright as its left, and drew the zigzag crisper and thinner than TARGET's (zigzag error 21 -> 15)
EDGE_FIX = {"leap", "tongue_snap", "flick"}                # cards whose cut needs the edge columns replaced (scramble's trim is tilted across them)
KEEP_TOP = {"flick"}         # the sword's tip reaches the name band: inpainting the top rows smeared it
PILL_ROW = {"flick": 0.86}   # the sword's guard and grip sit low, over the 0.7 line: key only the pill's own rows
FOOT_CLEAR = {"flick": 6, "tongue_snap": 6}
FOOT_BLACK = {"tongue_snap": 8.5}   # TARGET px: under the zigzag's bar TARGET's window is plain black; the pill's inpaint left a blue-grey blob there (run 6)    # TARGET px: the top of TARGET's pill cut off at the window's foot; the key missed it and a pale sliver showed past the card's own pill (run 6, 2026-10-10)
WIN_W = 122.0                      # TARGET px: the window inside the gold line (run 14: the frame now trims a 2 px bleed)
ASPECT = (0.889 * 690) / (0.456 * 984)   # card_view.A1_ART (run 16: 0.039 .. 0.928)
SCALE = 1.4                        # output px per TARGET px: ~2x the window on screen, so the card's mip 1 lands 1:1 and the art stays as crisp as TARGET's (run 14)


def cut(name: str, cx: float, cy: float, tilt: float, win_w: float = 0.0) -> None:
    T = np.asarray(Image.open(TARGET).convert("RGB"))
    M = cv2.getRotationMatrix2D((cx, cy), tilt, 1.0)
    R = cv2.warpAffine(T, M, (T.shape[1], T.shape[0]), flags=cv2.INTER_LANCZOS4, borderMode=cv2.BORDER_REFLECT)
    w = win_w or WIN_W
    h = w / ASPECT
    x0, y0 = int(round(cx - w / 2)), int(round(cy - h / 2))
    crop = R[y0:y0 + int(round(h)), x0:x0 + int(round(w))].copy()
    r, g, b = [crop[..., k].astype(int) for k in range(3)]
    mx, mn = crop.max(2).astype(int), crop.min(2).astype(int)
    # TARGET's cost badge (a saturated emerald disc, top left) and its type
    # pill (pale grey, low in the window): the card draws its own.
    badge = (g > r + 85) & (g > b + 45) & (g > 120) & (r < 95)   # the emerald disc only: the looser key took Leap's light foliage too (run 14)
    badge &= np.arange(crop.shape[0])[:, None] < crop.shape[0] * 0.45
    badge &= np.arange(crop.shape[1])[None, :] < crop.shape[1] * 0.4
    pill = (mx > 150) & (mx - mn < 30)
    pill &= np.arange(crop.shape[0])[:, None] > crop.shape[0] * PILL_ROW.get(name, 0.7)
    # Only the pill itself: the biggest pale blob round the window's middle.
    # The loose key also took Leap's pale low foliage, and its inpaint drew a
    # white haze across the art's foot (run 14).
    lab, n = ndi.label(ndi.binary_closing(pill, iterations=2))
    if n:
        sizes = ndi.sum(pill, lab, range(1, n + 1))
        cxs = [np.nonzero(lab == i)[1].mean() for i in range(1, n + 1)]
        keep = [i + 1 for i in range(n) if 0.25 < cxs[i] / crop.shape[1] < 0.75]
        if keep:
            best = max(keep, key=lambda i: sizes[i - 1])
            pill = lab == best
        else:
            pill[:] = False
    hole = ndi.binary_dilation(ndi.binary_fill_holes(ndi.binary_closing(badge | pill, iterations=2)), iterations=3)
    # The name band's dark bottom edge, if the window's top row caught it.
    dark_top = np.zeros_like(hole)
    for y in range(0 if name in KEEP_TOP else min(6, crop.shape[0])):
        if (mx[y] < 70).mean() > 0.6:
            dark_top[y] = True
    hole |= dark_top
    if name in FOOT_CLEAR:
        n = int(round(FOOT_CLEAR[name] * crop.shape[0] / h))
        foot = np.zeros_like(hole)
        foot[-n:] = (mx[-n:] > 60) & (mx[-n:] - mn[-n:] < 40)
        hole |= ndi.binary_dilation(foot, iterations=1)
    # TARGET's own trim or name band caught at the window's edges (a column
    # or row within 8 px of the edge that is dark or carries the gold line):
    # replaced by the nearest clean column / row, so no border shows inside
    # the card's own (run 14).
    lum = crop.mean(2)
    def bad(v):
        return v.mean() < 75 or (v > 150).mean() > 0.6
    W_, H_ = crop.shape[1], crop.shape[0]
    for side in ((0, 1) if name in EDGE_FIX else ()):
        xs = range(0, 8) if side == 0 else range(W_ - 1, W_ - 9, -1)
        bad_x = [x for x in xs if bad(lum[int(H_ * 0.15):int(H_ * 0.8), x])]
        if bad_x:
            edge = max(bad_x) + 1 if side == 0 else min(bad_x) - 1
            sl = slice(0, edge) if side == 0 else slice(edge + 1, W_)
            # inpainted, not a copied column: a copied column read as a
            # smeared green stripe down Leap's left side (run 16)
            hole[:, sl] = True
    top_bad = [y for y in range(0, 6) if lum[y, int(W_ * 0.3):int(W_ * 0.7)].mean() < 75]
    if top_bad and name in EDGE_FIX:
        e = max(top_bad) + 1
        crop[:e] = crop[e:e + 1]
    bgr = np.ascontiguousarray(crop[..., ::-1])
    fill = cv2.inpaint(bgr, hole.astype(np.uint8) * 255, 5, cv2.INPAINT_TELEA)[..., ::-1]
    crop[hole] = fill[hole]
    if name in FOOT_BLACK:
        n = int(round(FOOT_BLACK[name] * crop.shape[0] / h))
        ground = np.median(crop[int(crop.shape[0] * 0.6):, :6].reshape(-1, 3), axis=0)
        crop[-n:, 6:-6] = ground.astype(crop.dtype)
    out = Image.fromarray(crop).resize((int(round(w * SCALE)), int(round(h * SCALE))), Image.LANCZOS)
    # The card draws this through a mip and a bilinear tap; a light unsharp
    # mask gives back the edge contrast TARGET's window has (run 14).
    out = out.filter(ImageFilter.UnsharpMask(radius=1.6, percent=USM.get(name, 130), threshold=1))   # run 16: the graders still read both windows soft at 70
    # Drawn small through the card's filters, Leap's sky and leaves lose a
    # little colour against TARGET's crisp window; give it back (run 14).
    if name in SATURATE:
        out = ImageEnhance.Color(out).enhance(SATURATE[name])
    out.save(OUT / f"{name}.png")
    print(f"cardart_cut: {name} {out.size[0]}x{out.size[1]}, {int(hole.sum())} px inpainted")


if __name__ == "__main__":
    import sys
    for n in (sys.argv[1:] or ["scramble"]):
        cut(n, *CARDS[n])
