"""Where the Bramble Hog is fought: a thicket floor, trodden flat in the middle.

The beast IS the brambles, so the ground has to be the same thing at rest. The
environment and the creature share a vocabulary and the fight reads as something
rising out of its own habitat rather than standing on a rug.

Dark leaf litter, bramble mounds around the edge with thorns on them, fallen
logs rotted into the ground, and the odd sapling that got through.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, UMBER, BROWN, CLAY, TAN, GREEN, MINT,
                    CHARCOAL, PUMPKIN)

e = Env(seed=23)

# Leaf litter, trodden into a hollow where the thing sleeps.
e.ground(UMBER, rim=CHARCOAL, dish=0.30)
e.apron(CHARCOAL, out=1.35, drop=0.60)

# Fallen leaves: flat chips in browns and one dying orange in twenty.
e.scatter(30, lambda p, r, rng: e.box((p.x, p.y, 0.03),
                                      (r * 0.9, r * 0.7, 0.03),
                                      PUMPKIN if rng.random() < 0.16 else
                                      (BROWN if rng.random() < 0.5 else CLAY),
                                      bevel=0.0,
                                      rot=(0, 0, rng.random() * math.tau)),
          near=1.8, far=5.8, size=0.30)


def thicket(p, r, rng):
    """A bramble mound: the same shape as the beast, asleep."""
    e.ball((p.x, p.y, r * 0.28), (r, r * 0.86, r * 0.62), BROWN, 7, 4)
    for _ in range(5):
        a = rng.random() * math.tau
        d = rng.random() * r * 0.7
        lean = rng.uniform(0.3, 0.8)
        b = rng.random() * math.tau
        e.taper((p.x + math.cos(a) * d, p.y + math.sin(a) * d, r * 0.62),
                r * 0.055, r * 0.008, r * 0.75, CHARCOAL, seg=4,
                rot=point((math.cos(b) * lean, math.sin(b) * lean, 1.0)))


e.scatter(7, thicket, near=3.4, far=5.7, arc=BACK, size=0.62)
e.scatter(5, thicket, near=2.6, far=5.6, arc=ANY, size=0.26)


def log(p, r, rng):
    """Rotted DOWN into the litter rather than lying on top of it."""
    a = rng.random() * math.tau
    e.limb([(p.x - math.cos(a) * r * 1.5, p.y - math.sin(a) * r * 1.5, r * 0.18),
            (p.x, p.y, r * 0.22),
            (p.x + math.cos(a) * r * 1.5, p.y + math.sin(a) * r * 1.5, r * 0.16)],
           [r * 0.30, r * 0.34, r * 0.26], UMBER, seg=6)
    e.ball((p.x + math.cos(a) * r * 0.6, p.y + math.sin(a) * r * 0.6, r * 0.42),
           (r * 0.36, r * 0.30, r * 0.10), MINT, 6, 4)


e.scatter(5, log, near=2.8, far=5.4, size=0.50)

# Saplings that got through the tangle, and low green in the light at the edge.
e.scatter(6, lambda p, r, rng: e.tree(p, r, BROWN, GREEN, tiers=2),
          near=3.8, far=5.8, arc=BACK, size=0.52)
e.scatter(12, lambda p, r, rng: e.ball((p.x, p.y, r * 0.3),
                                       (r, r * 0.9, r * 0.55),
                                       MINT if rng.random() < 0.35 else GREEN, 6, 4),
          near=2.4, far=5.7, size=0.22)

e.done(out_path(), name="BrambleHogGround")
