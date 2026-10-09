"""Measure what the fight does to a drawn beast's colours, in 3D, and write
the table that undoes it.

    python3 tools/drawn_lut3d.py            # shoots, fits, writes the LUT
    python3 tools/drawn_lut3d.py --reuse    # refit from the last shots
    python3 tools/drawn_lut3d.py --seed     # write the old 1D curve as a 3D table

Why 3D (2026-10-08, queue "Cracks: wide hot cores and a long sternum
seam"): the fight's Environment runs ACES, contrast 1.10 and saturation
1.18, which mix the channels. tools/drawn_lut.py inverted the grey ramp
only, so a saturated orange such as TARGET's crack glow (247, 161, 23)
reached the screen as red (255, 117, 44), and the table stopped at linear
1.0, which the scene shows as grey 232: TARGET's yellow-hot cores (254,
243, 48) could not be drawn at all.

How: drawn_sprite.gdshader's `cal_grid` mode paints N^3 emission samples
(emission = E0 + (EMAX - E0) * u^GAMMA on a u grid), four blue slices per shot, on the
jackal's quad drawn over everything; a grey shot (`cal_grid` 99) finds the
cells something 2D still covers, and every grid is shot twice, the second
time turned 180 degrees (`cal_flip`), so each sample is read where nothing
covers it. The forward map (u -> screen sRGB) is then inverted on a grid of
screen colours by Gauss-Newton on its trilinear interpolant, clamped to
u in [0, 1] where a colour lies outside what the scene can show.

Writes game/assets/3d/drawn_sprite_lut3d.gdshaderinc. Re-run whenever
combat_3d.tscn's Environment changes. Linux, via tools/shot.sh; needs
Pillow and numpy.
"""
import os
import subprocess
import sys

import numpy as np
from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
TSCN = "game/assets/3d/cast/cinder_jackal_2d.tscn"
SHADER = "game/assets/3d/drawn_sprite.gdshader"
LUT = "game/assets/3d/drawn_sprite_lut3d.gdshaderinc"
LUT1 = "game/assets/3d/drawn_sprite_lut.gdshaderinc"
SHOTS = "/tmp/drawn_lut3d"
N = 17
EMAX = 2.4
GAMMA = 1.7
# Emission under ~0.15 linear is black on screen (ACES' toe), so the grid
# starts there: emission = E0 + (EMAX - E0) * u^GAMMA.
E0 = 0.12
BORDER = 0.04
FRAME = np.array([135.0, 252.0, 61.0])   # emission (0, 1, 0) as the fight shows it


def shot_path(g, flip):
    return os.path.join(SHOTS, "g%02d_%d.png" % (g, int(flip)))


def shoot():
    os.makedirs(SHOTS, exist_ok=True)
    tscn = os.path.join(ROOT, TSCN)
    shader = os.path.join(ROOT, SHADER)
    src_t = open(tscn).read()
    src_s = open(shader).read()
    key = 'shader_parameter/tex = ExtResource("rest")'
    assert key in src_t, "the jackal scene's material moved; update drawn_lut3d.py"
    mode = "render_mode unshaded, fog_disabled, cull_back, depth_prepass_alpha;"
    assert mode in src_s, "drawn_sprite.gdshader's render_mode moved; update drawn_lut3d.py"
    # Glow off while measuring: a flat patch blooms into itself, so with it on
    # the table learnt that a hot emission shows brighter than it does as a
    # thin crack, and drew the cracks ~10% dark (2026-10-08). The fight's
    # bloom then adds only the halo round each line, as TARGET draws it.
    # (2026-10-09: the fight itself now runs with glow off, because the bloom
    # also lifted the hot cores' blue from 51 to 100 and turned them cream;
    # this keeps working if it is ever turned back on.)
    env = os.path.join(ROOT, "game/views/combat_3d.tscn")
    src_e = open(env).read()
    assert "glow_enabled = " in src_e
    jobs = [(99, False)] + [(g, f) for g in range((N + 3) // 4) for f in (False, True)]
    try:
        open(env, "w").write(src_e.replace("glow_enabled = true", "glow_enabled = false", 1))
        open(shader, "w").write(src_s.replace(
            mode, "render_mode unshaded, fog_disabled, cull_disabled, depth_test_disabled;"))
        for g, f in jobs:
            extra = "\nshader_parameter/calibrate = true\nshader_parameter/cal_grid = %d\n" \
                    "shader_parameter/cal_flip = %s\nrender_priority = 127" % (g, "true" if f else "false")
            open(tscn, "w").write(src_t.replace(key, key + extra))
            out = shot_path(g, f)
            subprocess.run(["timeout", "300", "bash", "tools/shot.sh", "out=" + out, "state=3d",
                            "beast=cinder_jackal"], cwd=ROOT, check=True,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            print("shot", out, flush=True)
    finally:
        open(env, "w").write(src_e)
        open(tscn, "w").write(src_t)
        open(shader, "w").write(src_s)


def _fit(t, v):
    """Line v = m t + c through edge points, by RANSAC: the HUD can hide
    part of an edge, and there the scan finds a cell instead."""
    rng = np.random.default_rng(0)
    best = None
    for _ in range(400):
        i, j = rng.choice(len(t), 2, replace=False)
        if t[i] == t[j]:
            continue
        m = (v[j] - v[i]) / (t[j] - t[i])
        c = v[i] - m * t[i]
        inl = np.abs(v - (m * t + c)) < 2.0
        if best is None or inl.sum() > best.sum():
            best = inl
    return np.polyfit(t[best], v[best], 1)


def quad_map(a):
    """Homography from UV (0..1, y down) to screen pixels, from the green
    frame's outer edges (the HUD may hide a corner, so fit lines, not
    corners)."""
    import cv2
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    green = np.abs(a - FRAME).max(-1) < 30   # the frame's own colour on screen
    rows = np.where(green.sum(1) > 20)[0]
    cols = np.where(green.sum(0) > 20)[0]
    L = np.array([(y, np.argmax(green[y])) for y in rows], float)
    R = np.array([(y, green.shape[1] - 1 - np.argmax(green[y, ::-1])) for y in rows], float)
    T = np.array([(x, np.argmax(green[:, x])) for x in cols], float)
    B = np.array([(x, green.shape[0] - 1 - np.argmax(green[::-1, x])) for x in cols], float)
    lm, lc = _fit(L[:, 0], L[:, 1])   # x = lm y + lc
    rm, rc = _fit(R[:, 0], R[:, 1])
    tm, tc = _fit(T[:, 0], T[:, 1])   # y = tm x + tc
    bm, bc = _fit(B[:, 0], B[:, 1])

    def meet(xm, xc, ym, yc):         # x = xm y + xc, y = ym x + yc
        y = (ym * xc + yc) / (1 - ym * xm)
        return xm * y + xc, y
    src = np.float32([[0, 0], [1, 0], [1, 1], [0, 1]])
    dst = np.float32([meet(lm, lc, tm, tc), meet(rm, rc, tm, tc),
                      meet(rm, rc, bm, bc), meet(lm, lc, bm, bc)])
    return cv2.getPerspectiveTransform(src, dst)


def _to_screen(H, u, v):
    p = H @ np.array([u, v, 1.0])
    return p[0] / p[2], p[1] / p[2]


def read_cells(path):
    """screen sRGB per (blue-in-shot, j, i) cell, in shader cell order."""
    a = np.asarray(Image.open(path).convert("RGB")).astype(float)
    H = quad_map(a)
    out = np.zeros((4, N, N, 3))
    k = 1 - 2 * BORDER
    for s in range(4):
        bx, by = s % 2, s // 2
        for j in range(N):
            for i in range(N):
                qx = (bx + (i + 0.5) / N) / 2
                qy = (by + (j + 0.5) / N) / 2
                cx, cy = _to_screen(H, BORDER + qx * k, BORDER + qy * k)
                hx, hy = _to_screen(H, BORDER + (qx + 0.5 / N) * k, BORDER + (qy + 0.5 / N) * k)
                wx = max(1, int(abs(hx - cx) * 0.4))
                wy = max(1, int(abs(hy - cy) * 0.4))
                x, y = int(round(cx)), int(round(cy))
                patch = a[y - wy:y + wy + 1, x - wx:x + wx + 1].reshape(-1, 3)
                out[s, j, i] = np.median(patch, axis=0)
    return out


def forward():
    """F[b, g, r] = screen sRGB for u = (r, g, b) / (N - 1)."""
    grey = read_cells(shot_path(99, False))
    med = np.median(grey.reshape(-1, 3), axis=0)
    bad = np.abs(grey - med).max(-1) > 6          # (4, N, N): covered cell positions
    print("covered cells: %d of %d" % (bad.sum(), bad.size))
    F = np.full((N, N, N, 3), np.nan)
    for g in range((N + 3) // 4):
        A = read_cells(shot_path(g, False))
        B = read_cells(shot_path(g, True))
        # In the flipped shot the sample (s, j, i) sits at position (3-s, N-1-j, N-1-i).
        Bp = B[::-1, ::-1, ::-1]  # flipped q: block s -> 3-s, cell -> N-1-cell
        badB = bad[::-1, ::-1, ::-1]
        for s in range(4):
            k = g * 4 + s
            if k >= N:
                continue
            v = np.where(bad[s][..., None], Bp[s], A[s])
            both = bad[s] & badB[s]
            v[both] = np.nan
            F[k] = v
    miss = np.isnan(F[..., 0])
    if miss.any():
        print("filling %d samples covered in both shots" % miss.sum())
        idx = np.argwhere(~miss)
        for p in np.argwhere(miss):
            d = np.abs(idx - p).sum(1)
            near = idx[d == d.min()]
            F[tuple(p)] = np.mean([F[tuple(q)] for q in near], axis=0)
    return F


def interp(F, u):
    """Trilinear F at u (M, 3) in [0, 1]; F indexed [b, g, r]."""
    f = np.clip(u, 0, 1) * (N - 1)
    lo = np.minimum(np.floor(f).astype(int), N - 2)
    w = f - lo
    out = 0
    for dr in (0, 1):
        for dg in (0, 1):
            for db in (0, 1):
                wt = (w[:, 0] if dr else 1 - w[:, 0]) * (w[:, 1] if dg else 1 - w[:, 1]) \
                     * (w[:, 2] if db else 1 - w[:, 2])
                out = out + wt[:, None] * F[lo[:, 2] + db, lo[:, 1] + dg, lo[:, 0] + dr]
    return out


def invert(F):
    g = np.linspace(0, 255, N)
    tb, tg, tr = np.meshgrid(g, g, g, indexing="ij")
    want = np.stack([tr, tg, tb], -1).reshape(-1, 3)        # index r + N*(g + N*b)
    # start: the grey curve per channel (F's diagonal)
    diag = np.array([F[k, k, k].mean() for k in range(N)])
    diag = np.maximum.accumulate(diag + np.arange(N) * 1e-4)
    us = np.linspace(0, 1, N)
    u = np.stack([np.interp(want[:, c], diag, us) for c in range(3)], -1)
    eps = 1e-3
    for it in range(60):
        r = interp(F, u) - want
        J = np.zeros((len(u), 3, 3))
        for c in range(3):
            d = np.zeros(3)
            d[c] = eps
            up = np.clip(u + d, 0, 1)
            dn = np.clip(u - d, 0, 1)
            J[:, :, c] = (interp(F, up) - interp(F, dn)) / np.maximum(up[:, c] - dn[:, c], 1e-9)[:, None]
        JtJ = np.einsum("mki,mkj->mij", J, J) + np.eye(3) * 1e-2
        step = np.linalg.solve(JtJ, np.einsum("mki,mk->mi", J, r)[..., None])[..., 0]
        u = np.clip(u - np.clip(step, -0.1, 0.1), 0, 1)
    err = np.abs(interp(F, u) - want).max(1)
    return u, want, err


def write(u, note):
    rows = ["vec3(%.4f, %.4f, %.4f)" % tuple(x) for x in u]
    body = ",\n\t".join(", ".join(rows[i:i + 4]) for i in range(0, len(rows), 4))
    with open(os.path.join(ROOT, LUT), "w") as f:
        f.write("// Written by tools/drawn_lut3d.py -- do not edit by hand. %s\n"
                "// Screen sRGB (r + N*(g + N*b) on an N-grid) -> u; emit E0 + (EMAX - E0) * u^GAMMA.\n"
                "const int LUT3_N = %d;\nconst float LUT3_E0 = %.3f;\nconst float LUT3_EMAX = %.3f;\nconst float LUT3_GAMMA = %.3f;\n"
                "const vec3 LUT3[%d] = vec3[](\n\t%s);\n" % (note, N, E0, EMAX, GAMMA, N ** 3, body))


def seed():
    import re
    t = open(os.path.join(ROOT, LUT1)).read().split("float[](")[1]
    v = np.array([float(x) for x in re.findall(r"\d+\.\d+", t)])
    g = np.linspace(0, 255, N)
    e = np.interp(g, np.arange(256), v)
    uc = (np.clip(e - E0, 0, None) / (EMAX - E0)) ** (1 / GAMMA)
    tb, tg, tr = np.meshgrid(uc, uc, uc, indexing="ij")
    write(np.stack([tr, tg, tb], -1).reshape(-1, 3), "Seeded from the 1D curve.")


def main():
    os.chdir(ROOT)
    if "--seed" in sys.argv:
        seed()
        return
    if "--reuse" not in sys.argv:
        shoot()
    F = forward()
    np.save(os.path.join(SHOTS, "F.npy"), F)
    print("grey ramp on screen:", [int(F[k, k, k].mean()) for k in range(N)])
    print("top reachable:", F.reshape(-1, 3).max(0))
    u, want, err = invert(F)
    _CACHE["u"] = (u, want, err)
    print("fit error (screen sRGB): median %.1f, 90%% %.1f, max %.1f" % (
        np.median(err), np.percentile(err, 90), err.max()))
    for c in [(247, 161, 23), (254, 243, 48), (255, 221, 152), (42, 20, 14), (108, 43, 24)]:
        uu, _, e = invert_one(F, c)
        print("  want", c, "-> u", np.round(uu, 3), "err %.1f" % e)
    write(u, "Measured %s on combat_3d.tscn's Environment." % __import__("datetime").date.today())
    print("wrote", LUT)


def invert_one(F, c):
    # nearest grid point of the full inversion is enough for a printout
    u, want, err = invert_cache(F)
    i = np.argmin(np.abs(want - np.array(c)).sum(1))
    return u[i], want[i], err[i]


_CACHE = {}


def invert_cache(F):
    if "u" not in _CACHE:
        _CACHE["u"] = invert(F)
    return _CACHE["u"]


if __name__ == "__main__":
    main()
