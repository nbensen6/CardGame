"""Cut TARGET.png's Frog into a sprite the fight lays over its 3D Frog at rest.

    python3 tools/frog_cut.py

Nick, 2026-10-08: "build the concept 1:1". The Frog is a 3D model with a
toon outline; at the rest view TARGET draws a clean cel Frog with a thin dark
line, and the model read heavier, darker and stair-stepped (queue, "Frog:
TARGET's clean cel line"). As with the jackal, the cliffs and the floor, the
rest-view Frog is TARGET's own pixels: combat_3d._place_frog_art() lays this
over TARGET's box in the screen's centred square while the Frog stands on its
rock, and the model stands in again the moment it moves.

TARGET's marker triangle on the Frog's head comes with it; the fight hides
the Frog's 3D pip while the drawn Frog shows.

Writes game/assets/3d/cast/frog_target.png, TARGET box FROG, RGBA.
"""
from pathlib import Path

import json
import sys

import cv2
import numpy as np
from PIL import Image
from scipy import ndimage as ndi

ROOT = Path(__file__).resolve().parent.parent
TARGET = ROOT / "design/art/targets/TARGET.png"
OUT = ROOT / "game/assets/3d/cast/frog_target.png"
# Per-channel pre-map: the inverse of what the fight does to the cut's tones
# (written by `frog_cut.py <rest shot>`, like tools/jackal_tone_fix.json).
TONE = ROOT / "tools/frog_tone_fix.json"

# TARGET px (x0, y0, x1, y1); combat_3d.FROG_ART_BOX must match.
FROG = (440, 578, 590, 712)
# The Frog's own dark line: this many px past its green fill.
LINE_PX = 3
FEATHER = 1.2


def build() -> None:
    T = np.asarray(Image.open(TARGET).convert("RGB")).astype(int)
    x0, y0, x1, y1 = FROG
    r = T[y0:y1, x0:x1]
    R, G, B = r[..., 0], r[..., 1], r[..., 2]
    green = (G > R + 15) & (G > 70)
    # The marker: minty (blue high for its green), the component that holds
    # the triangle's top rows, plus its own dark rim.
    minty = green & (B > 0.55 * G) & (G > 150)
    lab, n = ndi.label(minty)
    top = np.zeros_like(minty)
    for i in range(1, n + 1):
        ys, _ = np.nonzero(lab == i)
        if ys.min() < 20:
            top |= lab == i
    tri = ndi.binary_dilation(ndi.binary_fill_holes(top), iterations=2)
    # The rows above the Frog's head are only the triangle and its rim.
    head_top = 18
    # The Frog: green, or its pale yellow-green highlights (bright, green at
    # least 0.8 of red); the floor's seams are orange and its slabs dark.
    frogpx = (green | ((G > 90) & (G >= 0.8 * R))) & ~tri
    body = ndi.binary_fill_holes(ndi.binary_closing(frogpx, iterations=3))
    body[:head_top] = False
    body = ndi.binary_opening(body, iterations=1)
    lab, n = ndi.label(body)
    if n > 1:
        sizes = ndi.sum(body, lab, range(1, n + 1))
        body = lab == (1 + int(np.argmax(sizes)))
    # TARGET's marker stays in the cut: the fight hides the Frog's own pip
    # while the drawn Frog shows (its 3D cone sat ~1 px off and lighter).
    sil = ndi.binary_fill_holes(body | ndi.binary_fill_holes(top))
    out = r.astype(float)
    # Alpha: the silhouette grown by the Frog's own dark line, feathered.
    keep = ndi.binary_dilation(sil, iterations=LINE_PX)
    d_in = ndi.distance_transform_edt(keep)
    a = np.clip(d_in / FEATHER, 0, 1)
    if TONE.exists():
        lut = np.array(json.loads(TONE.read_text())["lut"], float)
        # Measured on the Frog's greens only: the marker keeps its own.
        mark = ndi.binary_dilation(ndi.binary_fill_holes(top), iterations=1)
        for k in range(3):
            ch = np.interp(out[..., k], np.arange(256), lut[k])
            out[..., k] = np.where(mark, out[..., k], ch)
    rgba = np.dstack([np.clip(out, 0, 255), a * 255]).astype(np.uint8)
    Image.fromarray(rgba, "RGBA").save(OUT)
    print(f"frog_target: {OUT.name} {rgba.shape[1]}x{rgba.shape[0]}, {int(keep.sum())} px")


def measure(shot: str) -> None:
    """Fold the fight's tone response on the drawn Frog into TONE."""
    t = np.asarray(Image.open(TARGET).convert("RGB").resize((720, 720), Image.LANCZOS)).astype(float)
    im = Image.open(shot).convert("RGB")
    side = min(im.size)
    x = (im.size[0] - side) // 2
    g = np.asarray(im.crop((x, 0, x + side, side)).resize((720, 720), Image.LANCZOS)).astype(float)
    x0, y0, x1, y1 = [int(v / 1024 * 720) for v in (450, 600, 580, 700)]
    T, G = t[y0:y1, x0:x1], g[y0:y1, x0:x1]
    m = (T[..., 1] > T[..., 0] + 15) & (T[..., 1] > 120)
    old = json.loads(TONE.read_text())["lut"] if TONE.exists() else [list(range(256))] * 3
    new = []
    for k in range(3):
        # quantile match: the game's q-th value should be TARGET's
        qs = np.linspace(1, 99, 50)
        tq, gq = np.percentile(T[m, k], qs), np.percentile(G[m, k], qs)
        err = np.interp(np.arange(256), tq, tq - gq, left=0.0, right=0.0)
        lut = np.maximum.accumulate(np.clip(np.array(old[k], float) + 0.8 * err, 0, 255))
        new.append([round(v, 2) for v in lut])
    TONE.write_text(json.dumps({"note": "per-channel tone fix for the drawn Frog, from frog_cut.py <shot>", "lut": new}))
    print("frog_cut: tone fix written")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        measure(sys.argv[1])
    build()
