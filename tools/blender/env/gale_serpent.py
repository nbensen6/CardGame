"""Where the Gale Serpent is fought: a bare ridge with the weather on it.

The beast is a spiral, so the ground spirals: the bedding in the rock winds
round the middle rather than lying in courses, and the scoured grooves all run
the same way, as if the whole hilltop has been turned. Nothing tall except a few
wind-shaped stones — this is a high, open, empty place, and it should feel like
the only shelter for a mile is the creature.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, SLATE, PEWTER, STONE, GRAPHITE, CHARCOAL,
                    STEEL, SILVER, ICE, SKY, PERIWINKLE, WHITE, MINT, GREEN,
                    TAN, WHEAT)

e = Env(seed=167)

e.ground(SLATE, rim=CHARCOAL, dish=0.18)
e.apron(CHARCOAL, out=1.35, drop=0.64)

# The wall. Without one a fight happens on a disc in an open sky and reads
# as a diorama on a plate: a wind-scoured canyon.
e.enclose("cliff")

# The rock winds. Four spirals out of the middle, the same turn as the beast.
for k in range(4):
    pts = []
    rad = []
    for j in range(9):
        t = j / 8.0
        r = 1.3 + 4.3 * t
        a = k * math.tau / 4.0 + t * 1.45 * math.tau
        pts.append((math.cos(a) * r, math.sin(a) * r * 0.96, 0.035))
        rad.append(0.20 - 0.10 * t)
    e.limb(pts, rad, PEWTER if k % 2 else STEEL, seg=4, cap=False, flat=0.22)

# Scour: shallow grooves all running one way, cut across the spiral.
e.scatter(22, lambda p, r, rng: e.box((p.x, p.y, 0.045),
                                      (r, r * 0.075, 0.035), GRAPHITE, bevel=0.0,
                                      rot=(0.0, 0.0, 0.7)),
          near=2.0, far=5.8, size=0.60)

# Wind-shaped stones: wide at the top, undercut, leaning downwind. Back only.
def wind_stone(p, r, rng):
    e.taper((p.x, p.y, r * 0.55), r * 0.26, r * 0.62, r * 1.15, PEWTER, seg=7,
            rot=(0.10, -0.16, rng.random() * math.tau))
    e.ball((p.x, p.y, r * 0.06), (r * 0.44, r * 0.40, r * 0.16), SLATE, 6, 4)


e.scatter(9, wind_stone, near=4.1, far=5.9, arc=BACK, size=0.74)
e.scatter(7, lambda p, r, rng: e.rock(p, r, SLATE, sink=0.58),
          near=2.6, far=5.7, size=0.30)

# Rime in the lee of anything that stands up, and hard grass that survives it.
e.scatter(10, lambda p, r, rng: e.ball((p.x, p.y, r * 0.12),
                                       (r, r * 0.58, r * 0.16), ICE, 6, 4,
                                       rot=(0, 0, 0.7)),
          near=3.0, far=5.7, size=0.34)
e.scatter(9, lambda p, r, rng: e.reed(p, r, MINT if rng.random() < 0.5 else GREEN,
                                      n=4),
          near=2.5, far=5.6, size=0.20)

e.done(out_path(), name="GaleSerpentGround")
