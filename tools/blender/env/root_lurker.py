"""Where the Root Lurker is fought: a forest floor it is already part of.

The beast is a knot of roots with a mouth in it, and the whole point of an
ambusher is that you cannot tell which knot. So the ground grows the same roots
in the same brown, and one of them turns out to be alive.

Deep leaf mould, roots breaking the surface and going back under, mushrooms in
the damp, and old trees standing far enough back to be a wall rather than props.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, UMBER, BROWN, CLAY, TAN, GREEN, MINT,
                    CHARCOAL, LINEN, ROSE, CORAL)

e = Env(seed=41)

e.ground(UMBER, rim=CHARCOAL, dish=0.26)
e.apron(CHARCOAL, out=1.35, drop=0.66)

# The wall. Without one a fight happens on a disc in an open sky and reads
# as a diorama on a plate: old wood, too dense to see through.
e.enclose("forest")


def root(p, r, rng):
    """Up out of the mould and back under it. These are the decoys."""
    a = rng.random() * math.tau
    cx, cy = math.cos(a), math.sin(a)
    e.limb([(p.x - cx * r * 1.9, p.y - cy * r * 1.9, -r * 0.20),
            (p.x - cx * r * 0.7, p.y - cy * r * 0.7, r * 0.26),
            (p.x + cx * r * 0.7, p.y + cy * r * 0.7, r * 0.30),
            (p.x + cx * r * 1.9, p.y + cy * r * 1.9, -r * 0.18)],
           [r * 0.10, r * 0.24, r * 0.22, r * 0.09], BROWN, seg=5)


e.scatter(12, root, near=2.2, far=5.7, size=0.62)


def shroom(p, r, rng):
    e.taper((p.x, p.y, r * 0.30), r * 0.14, r * 0.20, r * 0.62, LINEN, seg=6)
    e.taper((p.x, p.y, r * 0.70), r * 0.62, r * 0.10, r * 0.34,
            ROSE if rng.random() < 0.4 else CORAL, seg=8)


e.scatter(11, shroom, near=2.6, far=5.6, size=0.30)

# Leaf mould, and the paler bones of older leaves under it.
e.scatter(26, lambda p, r, rng: e.box((p.x, p.y, 0.03),
                                      (r * 0.9, r * 0.7, 0.03),
                                      CLAY if rng.random() < 0.6 else TAN,
                                      bevel=0.0,
                                      rot=(0, 0, rng.random() * math.tau)),
          near=1.9, far=5.8, size=0.28)

# The wood itself: trunks close together and tall, right round the back.
e.scatter(13, lambda p, r, rng: e.tree(p, r, UMBER, GREEN, tiers=3),
          near=4.2, far=5.9, arc=BACK, size=0.78)
e.scatter(4, lambda p, r, rng: e.stump(p, r, UMBER, BROWN),
          near=2.9, far=5.2, size=0.44)
e.scatter(10, lambda p, r, rng: e.ball((p.x, p.y, r * 0.26),
                                       (r, r * 0.9, r * 0.5), MINT, 6, 4),
          near=2.4, far=5.6, size=0.24)

e.done(out_path(), name="RootLurkerGround")
