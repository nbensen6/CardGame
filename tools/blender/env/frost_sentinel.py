"""Where the Frost Sentinel is fought: a frozen lake under a scoured shore.

Its body is the only angular thing in the roster, so its ground is the flattest
— a sheet of ice with the cracks running out from where it stands. Everything
else is drifts and shards in the same cold whites, and the beast is the one
shape among them that looks deliberate.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, ICE, WHITE, SILVER, SKY, PERIWINKLE, STEEL,
                    SLATE, GRAPHITE, CHARCOAL)

e = Env(seed=73)

# Barely dished. A frozen lake is the flattest thing there is, and that is the
# whole reason this beast gets one.
e.ground(ICE, rim=STEEL, dish=0.10)
e.apron(SLATE, out=2.50, drop=0.62)

# The wall. Without one a fight happens on a disc in an open sky and reads
# as a diorama on a plate: a crevasse with walls of blue ice.
e.enclose("ice")

# Cracks radiating from the middle, where the weight is. They wander, because a
# crack that runs straight reads as a drawn line.
for i in range(11):
    a = i * math.tau / 11.0 + 0.2
    pts = []
    for j in range(4):
        t = 0.22 + 0.72 * j / 3.0
        wob = (j % 2 - 0.5) * 0.22
        pts.append((math.cos(a + wob) * e.R * t, math.sin(a + wob) * e.R * t, 0.04))
    e.limb(pts, [0.055, 0.040, 0.030, 0.018], STEEL, seg=4, cap=False)

# Snow, banked against whatever stands up out of the ice.
e.scatter(14, lambda p, r, rng: e.ball((p.x, p.y, r * 0.18),
                                       (r, r * 0.76, r * 0.30), WHITE, 7, 4,
                                       rot=(0, 0, rng.random() * math.tau)),
          near=2.3, far=5.8, size=0.70)

# Shards where the sheet buckled. Tall behind, small anywhere.
e.scatter(12, lambda p, r, rng: e.spike(p, r, ICE, lean=0.26),
          near=3.8, far=5.9, arc=BACK, size=0.74)
e.scatter(9, lambda p, r, rng: e.spike(p, r, PERIWINKLE, lean=0.40),
          near=2.5, far=5.6, arc=ANY, size=0.24)

# Dark rock where the wind has scoured the ice bare — the only warm-dark thing
# here, and what stops the whole floor reading as one white sheet.
e.scatter(8, lambda p, r, rng: e.rock(p, r, SLATE, sink=0.62),
          near=3.2, far=5.7, arc=BACK, size=0.50)
e.scatter(10, lambda p, r, rng: e.box((p.x, p.y, 0.03),
                                      (r, r * 0.8, 0.03), SILVER, bevel=0.0,
                                      rot=(0, 0, rng.random() * math.tau)),
          near=2.0, far=5.7, size=0.34)

e.done(out_path(), name="FrostSentinelGround")
