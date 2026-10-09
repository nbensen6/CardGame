"""TARGET's scene behind its climb gauge, recovered from the panel over it.

TARGET's gauge is a see-through dark panel: what lies behind it (the right
cliff, the haze, the lava band, the floor's seams) reads through at about a
third of its strength. The fight draws its own panel at the same face colour
and alpha (combat_3d.GAUGE_FACE), so if the backdrop and the floor carry the
scene un-blended, panel over scene lands back on TARGET's pixels
(builder 2026-10-09 run 15, queue "Climb gauge panel: see-through").

    scene = (TARGET - alpha * face) / (1 - alpha)

The gauge's own marks (the rail, its ticks and bars, the burning sigil, the
"+5" and the hunters' pips) are not scene: those pixels are filled along
their row from the panel's clean pixels either side.

Coordinates are TARGET.png's 1024 px.
"""
import numpy as np
from scipy import ndimage as ndi

# Must match combat_3d.GAUGE_FACE (sRGB 0..255 and alpha).
FACE = np.array([0.06, 0.055, 0.07]) * 255.0
ALPHA = 0.64
# The panel's inside (inset from its border), TARGET px (x0, y0, x1, y1).
PANEL = (917, 313, 1003, 722)
# Its outer edge with the border line (x0, y0, x1, y1): the line is TARGET's
# own panel, not scene; the fight draws its own.
OUTER = (910, 306, 1010, 730)
# The gauge's marks: (x0, y0, x1, y1) boxes, and the sigil's disc.
MARKS = [
    (950, 311, 970, 727),    # the rail
    (935, 320, 985, 342),    # "+5"
    (932, 424, 988, 452),    # top bar and its glow
    (932, 547, 988, 575),    # lower bar and its glow
    (944, 495, 976, 505),    # tick
    (944, 620, 976, 630),    # tick
    (944, 655, 976, 675),    # tick
    (910, 668, 1010, 730),   # the hunters' pips and "S UP", edge to edge
]
SIGIL = ((959.0, 376.0), 44.0)
# Rows above this inside the panel are cliff, carried across from its sides.
UPPER_END = 468


def marks_mask(shape):
    m = np.zeros(shape, bool)
    for x0, y0, x1, y1 in MARKS:
        m[y0:y1, x0:x1] = True
    yy, xx = np.mgrid[0:shape[0], 0:shape[1]]
    (cx, cy), r = SIGIL
    m |= (xx - cx) ** 2 + (yy - cy) ** 2 < r * r
    return m


def unblend(T: np.ndarray) -> np.ndarray:
    """TARGET (H x W x 3, full 1024 rows) with the scene behind the panel."""
    out = T.astype(float).copy()
    x0, y0, x1, y1 = PANEL
    reg = out[y0:y1, x0:x1]
    scene = np.clip((reg - ALPHA * FACE) / (1.0 - ALPHA), 0, 255)
    m = marks_mask(T.shape[:2])[y0:y1, x0:x1]
    m = ndi.binary_dilation(m, iterations=2)
    xs = np.arange(x1 - x0, dtype=float)
    full = []
    for y in range(y1 - y0):
        bad = m[y]
        if not bad.any():
            continue
        good = ~bad
        if good.sum() < 2:
            full.append(y)
            continue
        for k in range(3):
            scene[y, bad, k] = np.interp(xs[bad], xs[good], scene[y, good, k])
    # A light vertical smooth over the filled marks: the fill is per row.
    sm = ndi.gaussian_filter(scene, (2.0, 0.0, 0.0))
    scene = np.where(m[..., None], sm, scene)
    # Rows the marks fill edge to edge (the pips and "S UP"): the clean rows
    # above them mirrored down (un-blended, the marks drew a bright ghost).
    runs = []
    for y in full:
        if runs and y == runs[-1][1] + 1:
            runs[-1][1] = y
        else:
            runs.append([y, y])
    n = scene.shape[0]
    for a, b in runs:
        for y in range(a, b + 1):
            up = 2 * a - 1 - y
            down = 2 * b + 1 - y
            if up >= 0 and (a > 0):
                scene[y] = scene[up]
            elif down < n:
                scene[y] = scene[down]
    # Above the haze the scene behind is the right cliff's dark face, and
    # the sigil's wide glow, un-blended, left bands and smears there: those
    # rows are the cliff carried across from either side of the panel.
    ox0, oy0, ox1, oy1 = OUTER
    t = np.linspace(0.0, 1.0, x1 - x0)[:, None]
    for y in range(y0, UPPER_END):
        lft, rgt = out[y, ox0 - 1], out[y, ox1]
        scene[y - y0] = lft[None, :] * (1 - t) + rgt[None, :] * t
    out[y0:y1, x0:x1] = scene
    # The border ring: each side carried in from the scene next to it (the
    # recovered inside for the top and bottom, TARGET outside for the sides).
    for y in range(oy0, oy1):
        if y < y0:
            out[y, ox0:ox1] = out[y0, ox0:ox1]
        elif y >= y1:
            out[y, ox0:ox1] = out[y1 - 1, ox0:ox1]
    for x in range(ox0, x0):
        out[oy0:oy1, x] = out[oy0:oy1, ox0 - 1]
    for x in range(x1, ox1):
        out[oy0:oy1, x] = out[oy0:oy1, ox1]
    return out
