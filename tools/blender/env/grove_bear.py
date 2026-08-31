"""Where the Grove Bear is fought: a clearing in old woodland.

The beast is a hill with a forest on its back, so the ground is the forest it
took that from — the same greens, the same mossy stone, the same trees. When it
stands still you should half lose it against the treeline, which is the whole
reason to fight it here rather than anywhere else.

Deep moss, ferns, mossy boulders, and a wall of old trunks close behind.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, GREEN, MINT, UMBER, BROWN, CLAY, TAN,
                    STONE, PEWTER, SLATE, GRAPHITE, CHARCOAL, WHEAT, LINEN)

e = Env(seed=149)

e.ground(GREEN, rim=UMBER, dish=0.24)
e.apron(CHARCOAL, out=2.50, drop=0.66)

# The wall. Without one a fight happens on a disc in an open sky and reads
# as a diorama on a plate: a clearing, and the trees own the rest.
e.enclose("forest")

# Moss over everything, in two greens so the floor is not one flat colour.
e.scatter(22, lambda p, r, rng: e.ball((p.x, p.y, 0.03),
                                       (r, r * 0.8, r * 0.10),
                                       MINT if rng.random() < 0.45 else GREEN, 6, 4,
                                       rot=(0, 0, rng.random() * math.tau)),
          near=1.8, far=5.8, size=0.62)

# Mossy boulders: grey rock with a green cap, the same two-tone as the beast.
def mossy(p, r, rng):
    e.rock(p, r, PEWTER if rng.random() < 0.5 else SLATE, sink=0.42)
    e.ball((p.x, p.y * 1.02, r * 0.42), (r * 0.86, r * 0.74, r * 0.20),
           MINT if rng.random() < 0.4 else GREEN, 6, 4)


e.scatter(9, mossy, near=3.2, far=5.7, arc=BACK, size=0.60)
e.scatter(8, mossy, near=2.5, far=5.6, arc=ANY, size=0.26)


def fern(p, r, rng):
    """Fronds out of one point, low and wide — a shape nothing else here has."""
    for i in range(6):
        a = i * math.tau / 6.0 + rng.random() * 0.4
        e.wedge((p.x + math.cos(a) * r * 0.45, p.y + math.sin(a) * r * 0.45,
                 r * 0.30),
                (r * 0.16, r * 0.55, r * 0.05), GREEN if i % 2 else MINT,
                narrow=(0.25, 0.70), bevel=0.0,
                rot=point((math.cos(a) * 0.9, math.sin(a) * 0.9, 0.55)))


e.scatter(9, fern, near=2.4, far=5.7, size=0.34)

# The treeline: close together and tall, so the back of the shot is a wall.
e.scatter(11, lambda p, r, rng: e.tree(p, r, UMBER, GREEN, tiers=3),
          near=4.3, far=5.9, arc=BACK, size=0.86)
e.scatter(5, lambda p, r, rng: e.stump(p, r, UMBER, BROWN),
          near=2.9, far=5.3, size=0.42)

e.done(out_path(), name="GroveBearGround")
