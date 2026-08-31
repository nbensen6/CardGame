"""Where the Bounder is fought: a dry riverbed full of the stones it came from.

Distinct from the Crag Pup's scree on purpose, because both are grey beasts on
stony ground and the two fights must not read as the same room. The Pup gets an
angular hollow ringed with standing slabs; the Bounder gets a flat pale wash of
ROUNDED cobbles — water-worn, not broken — with dry channels cut through it and
almost nothing standing up at all.

The flatness is the point: this thing jumps, and a floor with nothing on it is a
floor you can see it land on.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, SAND, WHEAT, TAN, CREAM, CLAY, BROWN,
                    UMBER, STONE, PEWTER, SLATE, GRAPHITE, MINT, GREEN)

e = Env(seed=91)

e.ground(WHEAT, rim=TAN, dish=0.12)
e.apron(TAN, out=2.50, drop=0.58)

# The wall. Without one a fight happens on a disc in an open sky and reads
# as a diorama on a plate: a quarry pit with nowhere to bounce out to.
e.enclose("cliff")

# Dry channels: shallow braids where the water used to run, darker than the bed.
for i in range(4):
    a = 0.6 + i * 1.5
    pts = []
    for j in range(5):
        t = -1.0 + 2.0 * j / 4.0
        wob = math.sin(t * 3.0 + i) * 0.5
        pts.append((math.cos(a + wob * 0.2) * e.R * t,
                    math.sin(a + wob * 0.2) * e.R * t, 0.02))
    e.limb(pts, [0.30, 0.44, 0.50, 0.42, 0.28], SAND, seg=4, cap=False, flat=0.16)

# Cobbles. Rounded, sunk, densest in the channels — the whole floor texture.
e.scatter(26, lambda p, r, rng: e.rock(p, r, STONE if rng.random() < 0.6 else PEWTER,
                                       sink=0.62),
          near=1.9, far=5.8, size=0.24)
e.scatter(12, lambda p, r, rng: e.rock(p, r, SLATE, sink=0.55),
          near=2.6, far=5.7, size=0.36)

# A few boulders it has bounced off, cracked where it landed. Behind only.
e.scatter(7, lambda p, r, rng: e.rock(p, r, PEWTER, sink=0.34),
          near=3.6, far=5.8, arc=BACK, size=0.66)
e.scatter(5, lambda p, r, rng: e.shard(p, r, GRAPHITE, lean=0.45),
          near=4.0, far=5.9, arc=BACK, size=0.46)

# Dry scrub in the cracks, and nothing else alive.
e.scatter(9, lambda p, r, rng: e.ball((p.x, p.y, r * 0.22),
                                      (r, r * 0.8, r * 0.34),
                                      MINT if rng.random() < 0.3 else GREEN, 6, 4),
          near=2.4, far=5.7, size=0.18)

e.done(out_path(), name="BounderGround")
