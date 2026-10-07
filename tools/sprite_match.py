"""Measure the game's beast sprite against the concept art it came from.

"Make it match" is not reviewable and "is the line thick enough?" is not a
question for Nick (2026-10-06: "The builder shouldnt have to ask me thickness
you should see if it matches the concept and get it it to 1:1"). So the things
that can be counted get counted, every run, and the answer is a number with a
tolerance rather than an opinion.

    python tools/sprite_match.py                     # cinder_jackal
    python tools/sprite_match.py --sprite a.png --concept b.png

Prints one line per measure and exits non-zero if any is out of tolerance, so
it can gate a builder run the way run_tests.gd does.

What each measure is for:
  body tone      the concept's body is dark red-brown rock. If the sprite's
                 body is brighter, the inking has washed it out -- the fault
                 on 2026-10-06, where the whole figure glowed.
  body hue       same, for colour drift (orange vs red-brown).
  crack cover    how much of the figure is hot cracks. Too high means the
                 glow has bled into the body.
  detail         edge density inside the figure: the concept's facet planes.
                 Posterising or blurring the ink drops this first.
  outline        the pale rim's width as a share of figure height. The
                 concept has no outline, so the target comes from TARGET.png,
                 measured once: a thin warm line, about 0.5% of the figure.
"""

import argparse
import os
import sys

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage as ndi

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
SPRITE = "game/assets/3d/cast/%s_2d.png"
CONCEPT = "design/art/targets/2026-10-04-jackal-concept.png"

# share of figure height; measured off TARGET.png's jackal, which is the only
# reference that HAS an outline
OUTLINE_TARGET = 0.005
OUTLINE_TOL = 0.004

# how far each measure may sit from the concept's own value
TOL = {"body tone": 14.0, "body hue": 12.0, "crack cover": 0.06, "detail": 0.025}


def figure(im):
    """The beast's pixels: alpha where there is one, else anything that is not
    the concept's flat grey card."""
    a = np.asarray(im.convert("RGBA"), dtype=np.float32)
    rgb, alpha = a[..., :3], a[..., 3]
    if alpha.min() < 250:
        return rgb, alpha > 40
    light = rgb.min(axis=2) > 200
    flat = np.ptp(rgb, axis=2) < 18
    return rgb, ~(light & flat)


def hot(rgb):
    """The glowing cracks: bright and saturated."""
    mx = rgb.max(axis=2)
    mn = rgb.min(axis=2)
    sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1), 0)
    return (mx > 150) & (sat > 0.45)


def measures(im):
    rgb, fig = figure(im)
    if fig.sum() < 100:
        raise SystemExit("no figure found")
    # The concept has no outline, so the body measures are taken inside the
    # sprite's: strip a band as wide as its measured rim off the silhouette.
    # The cream line is bright and saturated enough to pass for a crack, and
    # counted as one it doubled "crack cover" with the body's cracks exactly
    # the concept's (2026-10-07). The rim itself is the "outline" measure.
    w = rim_px(im)
    if w:
        fig = fig & (ndi.distance_transform_edt(fig) > w)
    cracks = hot(rgb) & fig
    body = fig & ~cracks
    lum = rgb @ np.array([0.299, 0.587, 0.114], dtype=np.float32)

    # hue of the body, in degrees, via the usual max-channel formula
    b = rgb[body]
    mx, mn = b.max(axis=1), b.min(axis=1)
    d = np.maximum(mx - mn, 1e-6)
    r, g, bl = b[:, 0], b[:, 1], b[:, 2]
    h = np.where(mx == r, ((g - bl) / d) % 6,
                 np.where(mx == g, (bl - r) / d + 2, (r - g) / d + 4)) * 60.0

    edges = np.asarray(Image.fromarray(lum.astype(np.uint8))
                       .filter(ImageFilter.FIND_EDGES), dtype=np.float32)
    return {
        "body tone": float(np.median(lum[body])),
        "body hue": float(np.median(h)),
        "crack cover": float(cracks.sum()) / float(fig.sum()),
        "detail": float((edges[body] > 18).mean()),
    }


def rim_px(im):
    """Median width in px of the pale rim, walking in from the silhouette."""
    rgb, fig = figure(im)
    lum = rgb @ np.array([0.299, 0.587, 0.114], dtype=np.float32)
    body_tone = float(np.median(lum[fig & ~hot(rgb)]))
    pale = lum > body_tone + 55
    rows = np.where(fig.any(axis=1))[0]
    if rows.size == 0:
        return 0.0
    widths = []
    for y in rows[::max(1, len(rows) // 120)]:
        xs = np.where(fig[y])[0]
        for x0, step in ((xs[0], 1), (xs[-1], -1)):
            n, x = 0, x0
            while 0 <= x < fig.shape[1] and fig[y, x] and pale[y, x] and n < 60:
                n += 1
                x += step
            widths.append(n)
    return float(np.median(widths))


def outline_share(im):
    """Width of the pale rim as a share of the figure's height.

    Walks in from the silhouette on every row and counts how many pixels are
    much brighter than the body before normal body tone starts.
    """
    _, fig = figure(im)
    rows = np.where(fig.any(axis=1))[0]
    if rows.size == 0:
        return 0.0
    return rim_px(im) / float(rows[-1] - rows[0] + 1)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--beast", default="cinder_jackal")
    p.add_argument("--sprite")
    p.add_argument("--concept")
    a = p.parse_args()
    os.chdir(ROOT)
    sprite = Image.open(a.sprite or (SPRITE % a.beast))
    concept = Image.open(a.concept or CONCEPT)

    got, want = measures(sprite), measures(concept)
    bad = 0
    print("%-12s %>10s %>10s %>8s  %s" .replace(">", "") %
          ("measure", "concept", "game", "diff", ""))
    for k in TOL:
        d = got[k] - want[k]
        ok = abs(d) <= TOL[k]
        bad += 0 if ok else 1
        fmt = "%10.3f" if k in ("crack cover", "detail") else "%10.1f"
        print(("%-12s " + fmt + fmt + "  %+7.3f  %s") %
              (k, want[k], got[k], d, "ok" if ok else "OFF"))

    o = outline_share(sprite)
    ok = abs(o - OUTLINE_TARGET) <= OUTLINE_TOL
    bad += 0 if ok else 1
    print("%-12s %10s %10.4f  %+7.4f  %s" %
          ("outline", "%.4f" % OUTLINE_TARGET, o, o - OUTLINE_TARGET,
           "ok" if ok else "OFF"))
    print("\n%d of %d off" % (bad, len(TOL) + 1))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
