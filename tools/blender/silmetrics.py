"""Objective silhouette metrics for the whole cast, from committed renders.

    python tools/blender/silmetrics.py              # every asset with a _sil.png
    python tools/blender/silmetrics.py cinder_jackal gale_serpent

Plain Pillow. No Blender, no screen, no game. **Both lanes can run this** — the
cloud included, which is the point: it turns "does this look blocky" from an
opinion into a number that the lane without a display can read.

Reads the newest `design/renders/<asset>_pass<N>_sil.png` for each asset.

WHAT IT MEASURES

  solidity  filled area / convex-hull area.
            A box with cylinders for legs sits at 0.90+. A creature with real
            negative space — gaps between limbs, a head clear of the mass, a
            tail that leaves the body — sits far lower. This is the direct
            measure of the thing Nick called "a blocky mess" on 2026-09-07,
            and nothing in the rubric had ever measured it.

  fill      filled area / bounding-box area. Cruder version of the same idea;
            kept because it is the one a human can verify by eye.

  distinct  1 - (highest silhouette IoU against any OTHER asset, both
            normalised into a common square). LOW IS BAD: it means something
            else in the cast has nearly the same outline. The nearest twin is
            printed beside it so the pair can be looked at together.

WHAT IT DOES NOT MEASURE

  Whether the thing reads as the creature it is NAMED after. No metric can do
  that; that is what the eye and the rubric are for. A model can score
  perfectly here and still be unrecognisable. Use this to find the assets that
  are provably wrong, not to certify the ones that are not.

Thresholds are in design/art-target.md and are gates in design/asset-loop.md.
"""
import os
import re
import sys
import glob
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RENDERS = os.path.join(ROOT, "design", "renders")

# Icons and portraits are 2D and judged flat; the compare/control shots are
# scratch pairs from a single pass, not assets.
SKIP = ("icon", "portrait", "compare", "control", "_old", "_new")

BLOCKY = 0.80   # solidity at or above this fails the gate
TWINNED = 0.25  # distinctness at or below this fails the gate


def newest_sils(only=None):
    best = {}
    for p in glob.glob(os.path.join(RENDERS, "*_sil.png")):
        b = os.path.basename(p)
        if any(s in b for s in SKIP):
            continue
        m = re.match(r"(.+?)_pass(\d+)_sil\.png$", b)
        if not m:
            continue
        name, n = m.group(1), int(m.group(2))
        if only and name not in only:
            continue
        if name not in best or n > best[name][0]:
            best[name] = (n, p)
    return {k: v[1] for k, v in sorted(best.items())}


def mask(path):
    """Solid-black-on-transparent -> set of filled pixels."""
    im = Image.open(path).convert("RGBA")
    px = im.load()
    w, h = im.size
    return {(x, y) for y in range(h) for x in range(w)
            if px[x, y][3] > 128 and sum(px[x, y][:3]) < 200}, (w, h)


def hull(pts):
    """Monotone chain. Avoids a scipy dependency for ~30 assets."""
    P = sorted(pts)
    if len(P) < 3:
        return P

    def half(ps):
        out = []
        for p in ps:
            while len(out) >= 2:
                (x1, y1), (x2, y2) = out[-2], out[-1]
                if (x2 - x1) * (p[1] - y1) - (y2 - y1) * (p[0] - x1) <= 0:
                    out.pop()
                else:
                    break
            out.append(p)
        return out
    return half(P)[:-1] + half(P[::-1])[:-1]


def normalised(pts, size=128):
    """Crop to the silhouette and scale into a common square, so distinctness
    compares SHAPE rather than how much of the frame the render happened to
    use."""
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    x0, y0 = min(xs), min(ys)
    w, h = max(xs) - x0 + 1, max(ys) - y0 + 1
    im = Image.new("L", (w, h), 0)
    px = im.load()
    for x, y in pts:
        px[x - x0, y - y0] = 255
    return im.resize((size, size), Image.NEAREST)


def main(argv):
    only = set(argv) or None
    sils = newest_sils(only)
    if not sils:
        print("no silhouette renders found under design/renders/")
        return 1

    rows, norms = [], {}
    for name, path in sils.items():
        pts, (w, h) = mask(path)
        if len(pts) < 50:
            print(f"{name}: silhouette is empty or nearly so ({len(pts)} px) — "
                  f"check the render before trusting anything else about it")
            continue
        hm = Image.new("L", (w, h), 0)
        ImageDraw.Draw(hm).polygon(hull(pts), fill=255)
        harea = sum(1 for v in hm.getdata() if v > 127)
        xs = [q[0] for q in pts]
        ys = [q[1] for q in pts]
        bbox = (max(xs) - min(xs) + 1) * (max(ys) - min(ys) + 1)
        rows.append([name, len(pts) / harea if harea else 0.0, len(pts) / bbox])
        norms[name] = list(normalised(pts).getdata())

    for r in rows:
        a = norms[r[0]]
        worst, twin = 0.0, "-"
        for other, b in norms.items():
            if other == r[0]:
                continue
            inter = sum(1 for i, j in zip(a, b) if i > 127 and j > 127)
            union = sum(1 for i, j in zip(a, b) if i > 127 or j > 127)
            iou = inter / union if union else 0.0
            if iou > worst:
                worst, twin = iou, other
        r += [1.0 - worst, twin]

    rows.sort(key=lambda r: -r[1])
    print(f"{'asset':22}{'solidity':>9}{'fill':>7}{'distinct':>10}  nearest twin")
    print("-" * 74)
    for name, sol, fil, dis, twin in rows:
        flags = []
        if sol >= BLOCKY:
            flags.append("BLOCKY")
        if dis <= TWINNED:
            flags.append(f"TWIN OF {twin.upper()}")
        tail = ("   <-- " + ", ".join(flags)) if flags else ""
        print(f"{name:22}{sol:9.2f}{fil:7.2f}{dis:10.2f}  {twin}{tail}")

    bad = [r for r in rows if r[1] >= BLOCKY or r[3] <= TWINNED]
    print(f"\n{len(bad)} of {len(rows)} fail a gate "
          f"(solidity >= {BLOCKY:.2f} or distinctness <= {TWINNED:.2f})")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
