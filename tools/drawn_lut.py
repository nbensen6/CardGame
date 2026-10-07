"""Measure what the fight does to a drawn beast's colours, and write the
table that undoes it.

    python3 tools/drawn_lut.py            # shoots, fits, writes the LUT

The fight's Environment (ACES, exposure, contrast, saturation) is right for
the lit 3D scene and wrong for a finished illustration: it drops everything
under about 0.14 linear to black, so the jackal's red-brown plates (sRGB
~42) reached the screen as ~13 and its facets merged (grader, 2026-10-07).
Rather than re-derive Godot's post chain, this measures it: the drawn
sprite's shader is put in `calibrate` mode, which paints a linear ramp
(top 40% of the quad: 0..1; bottom 40%: 0..0.25 for the dark end) and a
white bar between them, the fight is shot, and the ramp is read back.

Writes game/assets/3d/drawn_sprite_lut.gdshaderinc: for each sRGB value
the sprite wants on screen (0..255), the linear value to emit. A shader
constant, not a texture, so no import setting can compress it. Re-run it whenever
combat_3d.tscn's Environment changes; run_tests pins the numbers it was made
against. Needs Pillow and numpy; Linux, via tools/shot.sh.
"""
import os
import subprocess
import sys

import numpy as np
from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
TSCN = "game/assets/3d/cast/cinder_jackal_2d.tscn"
LUT = "game/assets/3d/drawn_sprite_lut.gdshaderinc"
SHOT = "/tmp/drawn_lut_ramp.png"


def shoot():
    path = os.path.join(ROOT, TSCN)
    src = open(path).read()
    key = 'shader_parameter/tex = ExtResource("1")'
    assert key in src, "run tools/beast_sprite.py first"
    open(path, "w").write(src.replace(key, key + "\nshader_parameter/calibrate = true"))
    try:
        subprocess.run(["bash", "tools/shot.sh", "out=" + SHOT, "state=3d",
                        "beast=cinder_jackal"], cwd=ROOT, check=True,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    finally:
        open(path, "w").write(src)


def curve(shot):
    a = np.asarray(Image.open(shot).convert("RGB")).astype(float)
    grey = a[..., 0]
    # The white bar: the longest run of bright neutral grey is the quad
    # (the lava is as bright, but never grey).
    bright = (np.ptp(a, axis=2) < 3) & (grey > 200)
    rows = np.where(bright.sum(1) > 150)[0]
    bar0, bar1 = int(rows.min()), int(rows.max())
    xs = np.where(bright[rows].any(0))[0]
    x0, x1 = int(xs.min()), int(xs.max()) + 1
    # The bar is 20% of the quad; a bar's height above and below it is
    # well inside each ramp, clear of the stones in front of the beast.
    h = bar1 - bar0
    y_hi = max(bar0 - h, 0)
    y_lo = bar1 + h
    L, O = [], []
    for x in range(x0 + 3, x1 - 3):
        u = (x + 0.5 - x0) / (x1 - x0)
        L += [u, u * 0.25]
        O += [grey[y_hi, x], grey[y_lo, x]]
    L, O = np.array(L), np.array(O)
    i = np.argsort(L)
    return L[i], np.maximum.accumulate(O[i])


def main():
    os.chdir(ROOT)
    if "--reuse" not in sys.argv:
        shoot()
    L, O = curve(SHOT)
    top = O.max()
    vals = []
    for t in range(256):
        # The darkest input that reaches t; past the curve's top, the top.
        v = 1.0 if t >= top else float(np.interp(t, O + np.arange(len(O)) * 1e-6, L))
        vals.append("%.5f" % v)
    rows = [", ".join(vals[i:i + 8]) for i in range(0, 256, 8)]
    with open(LUT, "w") as f:
        f.write("// Written by tools/drawn_lut.py -- do not edit by hand.\n"
                "// Screen sRGB value (index) -> linear value to emit.\n"
                "const float DRAWN_LUT[256] = float[](\n\t" + ",\n\t".join(rows) + ");\n")
    print("%s: screen 0..%d from linear %.3f..1.0" % (LUT, top, float(L[np.argmax(O > 0)])))


if __name__ == "__main__":
    main()
