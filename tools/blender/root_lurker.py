"""The Root Lurker - a knot of roots with a mouth in the middle of it.

Holds at Height 2, sigil at 5.

An ambusher: most of it is still in the ground. What is above the surface is a
crown of roots curling up out of the soil and, in the hollow between them, a
vertical split lined with pale teeth. There is no head - the mouth is the middle
of the knot, and the eyes are two lights deep inside it.

The silhouette is a CAGE: open, with gaps you can see through, which is the
opposite of every other beast and the reason it reads at a glance.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import (out_path, mirror, point, BROWN, UMBER, CLAY, TAN, GREEN,
                    MINT, CHARCOAL, AMBER, GRAPHITE)

b = Beast("root_lurker", height=3.2)

# ------------------------------------------------------------------- the mound
b.ball((0.0, 0.0, 0.30), (1.28, 1.18, 0.44), UMBER, 12, 7)
b.ball((0.0, 0.0, 0.66), (0.98, 0.92, 0.46), BROWN, 10, 6)
for i in range(7):                                                # surface roots
    a = i * math.tau / 7.0 + 0.4
    b.limb([(math.cos(a) * 0.30, math.sin(a) * 0.28, 0.62),
            (math.cos(a) * 0.86, math.sin(a) * 0.80, 0.34),
            (math.cos(a) * 1.34, math.sin(a) * 1.24, 0.12)],
           [0.17, 0.13, 0.075], BROWN, seg=5)

# --------------------------------------------------------------- the root cage
# Six roots that leave the mound, arch OUT and come back IN over the mouth. The
# gaps between them are the point: a beast you can see daylight through is the
# only one in the roster.
for i in range(6):
    a = i * math.tau / 6.0 + 0.28
    cx, cy = math.cos(a), math.sin(a)
    b.limb([(cx * 0.60, cy * 0.56, 0.70),
            (cx * 1.02, cy * 0.95, 1.30),
            (cx * 0.92, cy * 0.86, 2.05),
            (cx * 0.52, cy * 0.48, 2.62),
            (cx * 0.26, cy * 0.24, 2.92)],
           [0.24, 0.20, 0.165, 0.125, 0.085], BROWN, seg=6)
    b.ball((cx * 0.98, cy * 0.91, 1.62), (0.19, 0.19, 0.24), UMBER, 8, 5)  # burl

# ------------------------------------------------------------------ the mouth
b.limb([(0.0, -0.10, 0.85), (0.0, -0.16, 1.55), (0.0, -0.20, 2.15)],
       [0.52, 0.46, 0.34], CHARCOAL, seg=8)                        # the throat
for i in range(9):                                                 # teeth
    a = i * math.tau / 9.0 + 0.2
    z = 1.15 + 0.85 * ((i * 0.41) % 1.0)
    r = 0.44 - 0.10 * (z - 1.15)
    b.taper((math.cos(a) * r, math.sin(a) * r - 0.16, z), 0.055, 0.008, 0.30,
            TAN, seg=4, rot=point((-math.cos(a) * 0.9, -math.sin(a) * 0.9, 0.35)))
mirror(lambda s: b.ball((0.20 * s, -0.24, 1.86), (0.075, 0.060, 0.075), AMBER, 7, 4))

# ------------------------------------------------------------------- the hold
# A root that flattened out where it crosses the front - the one place on a cage
# that is a floor rather than a bar.
b.shelf(2, (0.0, -0.72), (0.66, 0.40), CLAY, thickness=0.11)
b.ball((0.0, -0.78, 1.22), (0.58, 0.30, 0.17), MINT, 9, 5)          # moss on it
mirror(lambda s: b.ball((0.72 * s, 0.42, 1.44), (0.30, 0.32, 0.20), GREEN, 8, 5))
b.ball((0.0, 0.68, 2.30), (0.42, 0.34, 0.30), GREEN, 8, 5)          # leaf clump

# On the front pair of cage roots, where they lean in over the mouth.
b.wedge((0.0, -0.62, 2.46), (0.42, 0.26, 0.30), UMBER,
        narrow=(0.60, 0.70), bevel=0.06)
b.mark(at=(0.0, -0.72, 2.46), size=0.30, facing=(0.0, -0.94, 0.34))

b.done(out_path(), name="RootLurker")
