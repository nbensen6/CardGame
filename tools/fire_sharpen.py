"""Give the fist fire's flicker frames frame 0's crispness.

    python3 tools/fire_sharpen.py

game/assets/3d/cast/cinder_jackal_2d_fire.png is an 8-frame flicker strip.
Frame 0 is TARGET's own flame; frames 1-7 are warps of it, and the warp's
resampling left them at ~0.73 of frame 0's Laplacian sharpness, so a rest
frame caught mid-flicker drew soft, smeared tongues where TARGET's are crisp
(Matched check 2026-10-10 run 4, "Fist flame" item). Each of frames 1-7 gets
an unsharp mask, its amount found by bisection so its Laplacian over the
flame matches frame 0's. Safe to re-run: a frame already at frame 0's
sharpness gets an amount of ~0.
"""
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parent.parent
P = ROOT / "game/assets/3d/cast/cinder_jackal_2d_fire.png"
FRAMES = 8
RADIUS = 1.2


def lap(y):
    return np.abs(4 * y[1:-1, 1:-1] - y[:-2, 1:-1] - y[2:, 1:-1] - y[1:-1, :-2] - y[1:-1, 2:]).mean()


def sharpness(f):
    return lap(f[..., :3].mean(2) * f[..., 3] / 255.0)


def usm(f, amount):
    """Unsharp mask on premultiplied colour, alpha untouched."""
    a = f[..., 3:4] / 255.0
    pre = f[..., :3] * a
    blur = ndimage.gaussian_filter(pre, sigma=(RADIUS, RADIUS, 0))
    pre = np.clip(pre + amount * (pre - blur), 0.0, 255.0 * a)
    out = f.copy()
    out[..., :3] = np.where(a > 0.0, pre / np.maximum(a, 1e-6), f[..., :3])
    return out


def main():
    im = np.asarray(Image.open(P).convert("RGBA")).astype(np.float64)
    w = im.shape[1] // FRAMES
    goal = sharpness(im[:, :w])
    for i in range(1, FRAMES):
        f = im[:, i * w:(i + 1) * w]
        lo, hi = 0.0, 4.0
        if sharpness(f) >= goal * 0.995:
            print(i, "already", round(sharpness(f) / goal, 3))
            continue
        for _ in range(24):
            mid = (lo + hi) / 2
            if sharpness(usm(f, mid)) < goal:
                lo = mid
            else:
                hi = mid
        im[:, i * w:(i + 1) * w] = usm(f, (lo + hi) / 2)
        print(i, "amount %.3f" % ((lo + hi) / 2), "-> %.3f of frame 0" % (sharpness(im[:, i * w:(i + 1) * w]) / goal))
    Image.fromarray(np.clip(im.round(), 0, 255).astype(np.uint8), "RGBA").save(P)


if __name__ == "__main__":
    main()
