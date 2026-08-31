"""Where the Drowned Colossus is fought: a tidal flat at low water.

It walked out of the sea and did not dry, so the ground is the place it walked
out of — wet sand with the tide still in the low spots, kelp left stranded, and
the ribs of something that did not make it back out.

The tide pools are the detail that carries this one. They are the only bright
thing on a brown floor and they read as water because they sit BELOW it.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, CLAY, UMBER, BROWN, TAN, SAND, WHEAT,
                    STEEL, SKY, ICE, PERIWINKLE, SLATE, GRAPHITE, CHARCOAL,
                    PEWTER, GREEN, MINT, LINEN, CREAM)

e = Env(seed=181)

e.ground(TAN, rim=UMBER, dish=0.20)
e.apron(SLATE, out=2.50, drop=0.60)

# The wall. Without one a fight happens on a disc in an open sky and reads
# as a diorama on a plate: a flooded hall with its roof gone.
e.enclose("ruin")

# Ripple marks in the sand, in arcs, the way a retreating tide leaves them.
for k in range(7):
    r = 2.0 + k * 0.55
    pts = []
    for j in range(9):
        a = -0.9 + 1.8 * j / 8.0
        pts.append((math.cos(a) * r, math.sin(a) * r * 0.92 - 0.4, 0.03))
    e.limb(pts, [0.11] * 9, SAND, seg=4, cap=False, flat=0.18)

# Tide pools. Below the sand, or they read as puddles painted on.
for x, y, s in [(-2.9, 1.4, 1.15), (3.1, -0.6, 0.95), (0.8, 3.6, 1.05),
                (-3.6, -2.2, 0.80), (2.2, 3.0, 0.70)]:
    e.pool((x, y, -0.06), s, STEEL, rim=UMBER)

# Barnacled rocks, dark and wet at the base, pale where they dry.
def wet_rock(p, r, rng):
    e.rock(p, r, GRAPHITE, sink=0.50)
    e.ball((p.x, p.y, r * 0.34), (r * 0.80, r * 0.68, r * 0.22), PEWTER, 6, 4)


e.scatter(9, wet_rock, near=3.3, far=5.8, arc=BACK, size=0.58)
e.scatter(10, lambda p, r, rng: e.rock(p, r, SLATE, sink=0.62),
          near=2.3, far=5.7, size=0.24)

# Stranded kelp: long, limp, lying in the direction the water went.
def kelp(p, r, rng):
    a = 0.7 + rng.uniform(-0.3, 0.3)
    pts, rad = [], []
    for j in range(5):
        t = j / 4.0
        pts.append((p.x + math.cos(a) * r * 3.0 * (t - 0.5) + math.sin(t * 6.0) * r * 0.3,
                    p.y + math.sin(a) * r * 3.0 * (t - 0.5), 0.05))
        rad.append(r * (0.16 - 0.09 * t))
    e.limb(pts, rad, GREEN if rng.random() < 0.6 else MINT, seg=4, cap=False,
           flat=0.4)


e.scatter(11, kelp, near=2.4, far=5.7, size=0.40)

# The ribs of something that did not get back out to sea.
RIB = (-2.4, 3.2)
for i in range(7):
    t = i / 6.0
    for s in (-1, 1):
        e.limb([(RIB[0] + (t - 0.5) * 2.2, RIB[1], 0.05),
                (RIB[0] + (t - 0.5) * 2.2, RIB[1] + s * 0.55, 0.55 - abs(t - 0.5) * 0.7),
                (RIB[0] + (t - 0.5) * 2.2, RIB[1] + s * 0.95, 0.20)],
               [0.075, 0.055, 0.035], LINEN, seg=4)
e.limb([(RIB[0] - 1.25, RIB[1], 0.10), (RIB[0], RIB[1], 0.16),
        (RIB[0] + 1.25, RIB[1], 0.10)], [0.09, 0.11, 0.08], CREAM, seg=5)

e.done(out_path(), name="DrownedColossusGround")
