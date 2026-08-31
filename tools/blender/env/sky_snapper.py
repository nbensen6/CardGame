"""Where the Sky Snapper is fought: a cliff top with nothing growing on it.

The beast is top-heavy and perched, so the ground is the opposite: bare, wind-
scoured rock with the wind's direction visible in everything on it. No trees, no
water, nothing soft — this is the highest place in the game and it should feel
like there is a long way down just off frame.

The one detail that carries it is the nest: a ring of dragged branches with the
picked-over bones of things it has carried up here.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, STONE, PEWTER, SLATE, GRAPHITE, CHARCOAL,
                    STEEL, SILVER, CREAM, LINEN, WHEAT, TAN, UMBER, BROWN,
                    MINT, GREEN, SKY)

e = Env(seed=113)

e.ground(PEWTER, rim=GRAPHITE, dish=0.14)
e.apron(GRAPHITE, out=1.35, drop=0.70)

# The wall. Without one a fight happens on a disc in an open sky and reads
# as a diorama on a plate: a col between two peaks.
e.enclose("crag")

# Bedding planes: long flat steps in the rock, all running the same way, which
# is what says "this was laid down" rather than "this was piled up".
for i in range(6):
    y = -4.4 + i * 1.75
    e.box((0.0, y, 0.04), (5.2 - abs(y) * 0.35, 0.30, 0.05), SLATE, bevel=0.03)

# Loose flakes, all leaning downwind — the wind is the only weather up here.
e.scatter(24, lambda p, r, rng: e.box((p.x, p.y, 0.05),
                                      (r, r * 0.62, 0.045),
                                      STONE if rng.random() < 0.5 else SLATE,
                                      bevel=0.0, rot=(0.0, 0.0, 0.55)),
          near=1.9, far=5.8, size=0.30)

# The nest: dragged branches in a rough ring, off to one side of the perch.
NEST = (2.5, 2.2)
for i in range(14):
    a = i * math.tau / 14.0 + 0.3
    e.limb([(NEST[0] + math.cos(a) * 1.05, NEST[1] + math.sin(a) * 0.95, 0.06),
            (NEST[0] + math.cos(a + 0.6) * 0.95, NEST[1] + math.sin(a + 0.6) * 0.86,
             0.20),
            (NEST[0] + math.cos(a + 1.1) * 1.02, NEST[1] + math.sin(a + 1.1) * 0.92,
             0.08)],
           [0.045, 0.055, 0.040], UMBER if i % 2 else BROWN, seg=4)
for i in range(5):
    a = i * 1.3
    e.taper((NEST[0] + math.cos(a) * 0.45, NEST[1] + math.sin(a) * 0.40, 0.10),
            0.045, 0.020, 0.42, LINEN, seg=4,
            rot=point((math.cos(a) * 0.9, math.sin(a) * 0.9, 0.25)))

# Crags at the back: tall, thin, leaning off the edge.
e.scatter(11, lambda p, r, rng: e.shard(p, r, SLATE, lean=0.30),
          near=4.2, far=5.9, arc=BACK, size=0.90)
e.scatter(6, lambda p, r, rng: e.shard(p, r, GRAPHITE, lean=0.42),
          near=3.2, far=4.8, arc=BACK, size=0.44)

# The only green: moss in the cracks, on the sheltered side.
e.scatter(7, lambda p, r, rng: e.ball((p.x, p.y, r * 0.18),
                                      (r, r * 0.8, r * 0.22), MINT, 6, 4),
          near=2.6, far=5.6, size=0.20)

e.done(out_path(), name="SkySnapperGround")
