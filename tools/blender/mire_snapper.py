"""The Mire Snapper - most of it is jaw.

Holds at Height 3, sigil at 6.

The silhouette is a wedge lying on the ground with a hump behind it. Nothing
else in the roster is HORIZONTAL, which is the whole reason this one works: the
Bounder is legs, the Root Lurker is a cage, the Sentinel is spires, and this is
a long flat thing that opens.

The hold is inside the mouth - on the tongue ridge, behind the teeth. You climb
this beast by standing in it, which is either the best or the worst idea in the
roster and is worth Nick's opinion.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import (out_path, mirror, point, aim, CLAY, UMBER, BROWN, MINT,
                    GREEN, TAN, CREAM, CHARCOAL, AMBER, GRAPHITE, SLATE)

b = Beast("mire_snapper", height=3.4)

# ------------------------------------------------------------------- the body
b.ball((0.0, 1.05, 1.55), (1.02, 1.15, 0.92), CLAY, 12, 7)             # hump
b.ball((0.0, 1.62, 1.92), (0.78, 0.80, 0.62), UMBER, 10, 6)
b.limb([(0.0, 2.30, 1.65), (0.0, 3.05, 1.28), (0.0, 3.60, 0.82), (0.0, 3.92, 0.48)],
       [0.52, 0.38, 0.26, 0.16], CLAY, seg=8)                          # tail
for sx in (-1, 1):
    b.limb([(0.92 * sx, 1.30, 1.28), (1.28 * sx, 1.42, 0.72), (1.30 * sx, 1.36, 0.22)],
           [0.30, 0.24, 0.20], UMBER, seg=6)
    b.wedge((1.30 * sx, 1.10, 0.16), (0.30, 0.44, 0.16), BROWN,
            narrow=(0.70, 0.60), bevel=0.05)
    b.limb([(0.90 * sx, -0.05, 1.18), (1.22 * sx, -0.25, 0.66), (1.24 * sx, -0.34, 0.20)],
           [0.28, 0.23, 0.19], UMBER, seg=6)
    b.wedge((1.24 * sx, -0.62, 0.15), (0.28, 0.42, 0.15), BROWN,
            narrow=(0.70, 0.60), bevel=0.05)

# ------------------------------------------------------------------- the jaws
# The lower jaw is a long shallow trough and the upper is a lid over it, hinged
# at the back and propped open. Built as one closed wedge it read as a doorstop.
b.wedge((0.0, -0.95, 0.72), (0.92, 1.30, 0.24), CLAY,
        narrow=(0.48, 0.62), bevel=0.07)                               # lower jaw
b.wedge((0.0, -0.90, 0.98), (0.72, 1.10, 0.12), TAN,
        narrow=(0.46, 0.70), bevel=0.04)                               # tongue ridge
b.wedge((0.0, -0.78, 1.62), (0.90, 1.22, 0.26), UMBER,
        narrow=(0.50, 0.60), bevel=0.07, rot=(-0.30, 0, 0))            # upper jaw
mirror(lambda s: b.ball((0.62 * s, 0.28, 1.42), (0.22, 0.24, 0.30), CLAY, 8, 5))

for i in range(7):                                                     # teeth
    t = i / 6.0
    y = -0.20 - 1.85 * t
    w = 0.86 - 0.42 * t
    for s in (-1, 1):
        b.taper((w * s, y, 1.06), 0.062, 0.010, 0.30, CREAM, seg=4,
                rot=point((0.15 * s, 0.0, 1.0)))
        b.taper((w * s * 0.96, y + 0.10, 1.44), 0.058, 0.010, 0.28, CREAM, seg=4,
                rot=point((0.15 * s, 0.0, -1.0)))

mirror(lambda s: b.ball((0.52 * s, 0.10, 1.94), (0.17, 0.15, 0.16), CHARCOAL, 8, 5))
mirror(lambda s: b.ball((0.54 * s, -0.02, 1.98), (0.098, 0.075, 0.088), AMBER, 7, 4))

# ------------------------------------------------------------------- the hold
# On the tongue ridge, behind the teeth.
b.shelf(3, (0.0, -0.72), (0.60, 0.72), GRAPHITE, thickness=0.10)
mirror(lambda s: b.ball((0.78 * s, 0.85, 2.05), (0.32, 0.40, 0.22), MINT, 8, 5))
b.ball((0.0, 1.15, 2.42), (0.66, 0.72, 0.34), GREEN, 10, 6)            # weed on the back
for i in range(5):
    a = 0.7 + i * 0.9
    b.taper((math.cos(a) * 0.60, 1.10 + math.sin(a) * 0.55, 2.55), 0.10, 0.02,
            0.44, SLATE, seg=5, rot=point((math.cos(a) * 0.4, math.sin(a) * 0.4, 1.0)))

b.mark(at=(0.0, 0.86, 2.52), size=0.32, facing=(0.0, -0.55, 0.84))

b.done(out_path(), name="MireSnapper")
