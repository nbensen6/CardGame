"""Cut the card cost gem from TARGET.png (Nick, 2026-10-08: "build the concept 1:1").

    python3 tools/costdisc_target.py

TARGET draws five cost gems on the hand. Each is sampled in polar bins round
its centre; the digit (bright white strokes and their dark outline, inside
0.5 of the radius) is masked out, and the per-bin median over the five gems
gives a digit-free face: the raised rim, its lit lower-right crescent, the
groove inside it and the face's top-left sheen, as TARGET paints them. The
result is re-drawn at 128 px with the same layout card_view.gd's procedural
gem had (face radius 0.45 of the texture, a soft shadow outside it).

Writes game/assets/ui/cost_disc_t.png.
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "design/art/targets/TARGET.png"
OUT = ROOT / "game/assets/ui/cost_disc_t.png"
N = 128
FACE = 0.45          # face radius, of N
NR, NA = 48, 96      # polar bins


def centres(t):
    from scipy import ndimage
    r, g, b = t[..., 0], t[..., 1], t[..., 2]
    m = (g > 110) & (g > r * 1.6) & (g > b * 1.4)
    m[:700] = False
    lab, n = ndimage.label(m)
    out = []
    for i in range(1, n + 1):
        ys, xs = np.nonzero(lab == i)
        if len(ys) > 800:
            out.append((xs.mean(), ys.mean(), (xs.max() - xs.min() + ys.max() - ys.min()) / 4.0 + 1.0))
    return out


def sample(t, x, y):
    h, w = t.shape[:2]
    x0, y0 = int(np.floor(x)), int(np.floor(y))
    fx, fy = x - x0, y - y0
    a = t[y0, x0] * (1 - fx) + t[y0, x0 + 1] * fx
    b = t[y0 + 1, x0] * (1 - fx) + t[y0 + 1, x0 + 1] * fx
    return a * (1 - fy) + b * fy


def main():
    t = np.asarray(Image.open(SRC).convert("RGB")).astype(float)
    cs = centres(t)
    assert len(cs) >= 4, cs
    polar = np.full((len(cs), NR, NA, 3), np.nan)
    for k, (cx, cy, rad) in enumerate(cs):
        for i in range(NR):
            rr = (i + 0.5) / NR * 1.0
            for j in range(NA):
                ang = (j + 0.5) / NA * 2 * np.pi
                p = sample(t, cx + np.cos(ang) * rr * rad, cy + np.sin(ang) * rr * rad)
                lum = p.mean()
                green = p[1] > p[0] * 1.25 and p[1] > p[2] * 1.15
                if rr < 0.62 and (lum > 150 or not green or lum < 55):
                    continue   # the digit or its outline
                polar[k, i, j] = p
    with np.errstate(all="ignore"):
        import warnings
        warnings.simplefilter("ignore")
        med = np.nanmedian(polar, axis=0)
    # bins every gem lost to its digit: fill from the same radius' median
    for i in range(NR):
        row = med[i]
        bad = np.isnan(row[:, 0])
        if bad.any():
            fill = np.nanmedian(row, axis=0) if (~bad).any() else np.nanmedian(med[:i + 1].reshape(-1, 3), axis=0)
            row[bad] = fill
    # Inside 0.62 every gem carries its digit, so the face there is a plane
    # fitted to the ring just outside it: TARGET's flat face with its
    # top-left sheen, without any digit's ghost.
    rs = (np.arange(NR) + 0.5) / NR
    an = (np.arange(NA) + 0.5) / NA * 2 * np.pi
    RR, AA = np.meshgrid(rs, an, indexing="ij")
    X, Y = RR * np.cos(AA), RR * np.sin(AA)
    ring = (RR >= 0.62) & (RR < 0.72)
    A = np.stack([np.ones(ring.sum()), X[ring], Y[ring]], 1)
    coef, *_ = np.linalg.lstsq(A, med[ring], rcond=None)
    inner = RR < 0.62
    plane = (np.stack([np.ones(RR.size), X.ravel(), Y.ravel()], 1) @ coef).reshape(med.shape)
    w = np.clip((RR - 0.62) / 0.12, 0.0, 1.0)[..., None]
    med[:] = np.where(inner[..., None], plane, plane * (1 - w) + med * w)
    img = np.zeros((N, N, 4))
    c = (N - 1) * 0.5
    R = N * FACE
    for y in range(N):
        for x in range(N):
            dx, dy = (x - c) / R, (y - c) / R
            d = np.hypot(dx, dy)
            ang = np.arctan2(dy, dx) % (2 * np.pi)
            j = int(ang / (2 * np.pi) * NA) % NA
            i = min(NR - 1, int(d * NR))
            col = med[i, j] / 255.0
            a = np.clip((1.0 - d) * R * 0.5 + 0.5, 0.0, 1.0)
            if d > 1.0:
                sh = np.clip(1.0 - (d - 1.0) / 0.10, 0.0, 1.0) * 0.45
                col = np.array([0.02, 0.06, 0.03])
                a = max(a, sh)
            img[y, x, :3] = col
            img[y, x, 3] = a
    Image.fromarray((img * 255).round().astype(np.uint8), "RGBA").save(OUT)
    print("wrote", OUT.name, "from", len(cs), "gems")


if __name__ == "__main__":
    main()
