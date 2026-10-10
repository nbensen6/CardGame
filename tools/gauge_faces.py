"""Cut the climb gauge's two hunter pips' faces straight from TARGET.png.

    python3 tools/gauge_faces.py

Builder 2026-10-10 run 6 (queue "Climb gauge: TARGET's soft orb and bottom
icons"): TARGET's pips hold small muted olive glyphs of the Frog and the
Climbers; the game drew each hunter's full-colour portrait there. This cuts
the inside of TARGET's two rings (inside the ring's stroke), with a soft
round edge, to game/assets/portraits/gauge/<portrait name>.png, which the
gauge draws in place of the portrait when one exists.
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
TARGET = ROOT / "design/art/targets/TARGET.png"
OUT = ROOT / "game/assets/portraits/gauge"
# portrait name: ring centre in TARGET px (the green and the blue ring)
PIPS = {"frog": (943.6, 690.1), "goblin_mech": (976.0, 690.2)}   # the fight's two seats
R = 11.0       # TARGET px: inside the ring's stroke and its soft inner edge (outer edge ~15.5)
UP = 4         # output px per TARGET px


def cut(name: str, cx: float, cy: float) -> None:
    T = Image.open(TARGET).convert("RGB")
    n = int(np.ceil(R)) + 1
    box = (cx - n, cy - n, cx + n, cy + n)
    big = T.transform((2 * n * UP, 2 * n * UP), Image.EXTENT, box, Image.BICUBIC)
    rgb = np.asarray(big).astype(np.float32)
    yy, xx = np.mgrid[0:rgb.shape[0], 0:rgb.shape[1]]
    r = np.hypot(xx + 0.5 - n * UP, yy + 0.5 - n * UP) / UP
    a = np.clip((R - r) / 1.0, 0.0, 1.0)
    out = np.dstack([rgb, a * 255.0]).astype(np.uint8)
    OUT.mkdir(parents=True, exist_ok=True)
    Image.fromarray(out, "RGBA").save(OUT / f"{name}.png")
    print(f"gauge_faces: {name} {out.shape[1]}x{out.shape[0]}")


# Hunters TARGET does not show: their portrait recoloured into TARGET's pip
# style, a muted olive glyph on the pip's dark ground, so every pip reads alike.
OTHERS = ("vine_weaver", "mountain_climbers", "lightbearer")


def glyph(name: str) -> None:
    src = Image.open(ROOT / f"game/assets/portraits/{name}.png").convert("RGBA")
    side = int(2 * (int(np.ceil(R)) + 1) * UP)
    inner = int(round(2 * R * UP * 0.78))
    src.thumbnail((inner, inner), Image.LANCZOS)
    a = np.asarray(src).astype(np.float32)
    lum = (a[..., :3] @ np.array([0.3, 0.59, 0.11])) / 255.0
    # TARGET's glyph inks: a dark olive shadow up to a pale yellow-green light
    lo, hi = np.array([60, 66, 30.0]), np.array([196, 214, 120.0])
    ink = lo + (hi - lo) * np.clip(lum * 1.3, 0, 1)[..., None]
    ground = np.array([14, 13, 16.0])
    al = a[..., 3:4] / 255.0
    rgb = ground * (1 - al) + ink * al
    canvas = np.zeros((side, side, 3), np.float32) + ground
    oy, ox = (side - rgb.shape[0]) // 2, (side - rgb.shape[1]) // 2
    canvas[oy:oy + rgb.shape[0], ox:ox + rgb.shape[1]] = rgb
    yy, xx = np.mgrid[0:side, 0:side]
    r = np.hypot(xx + 0.5 - side / 2, yy + 0.5 - side / 2) / UP
    alpha = np.clip(R - r, 0.0, 1.0) * 255.0
    Image.fromarray(np.dstack([canvas, alpha]).astype(np.uint8), "RGBA").save(OUT / f"{name}.png")
    print(f"gauge_faces: {name} (recoloured portrait)")


if __name__ == "__main__":
    for k, (x, y) in PIPS.items():
        cut(k, x, y)
    for k in OTHERS:
        glyph(k)
