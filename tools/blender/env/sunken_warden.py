"""Where the Sunken Warden is fought: a drowned temple, still underwater.

The last fight in a run, so it gets the only place that is not outdoors and not
dry. Everything is a shade of deep blue, the light is coming from above through
water, and the architecture is the same coral-crusted vertical stack the Warden
itself is — because the Warden never left, and this is what it grew into.

Two things do the work: a colonnade close enough behind to enclose the fight, so
the last fight is the only one with walls; and coral, the one warm colour in the
game's coldest palette.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, MIDNIGHT, NAVY, INDIGO, IRIS, VIOLET,
                    PERIWINKLE, ICE, STEEL, SILVER, SLATE, GRAPHITE, CHARCOAL,
                    CORAL, ROSE, BLUSH, MINT, GREEN, GOLD, AMBER, STONE)

e = Env(seed=199)

# Fix A. The floor was NAVY and the ruin wall is PEWTER — near enough in
# value that the whole ground read as one dark mass with a ring of
# monoliths in it. STONE lifts the temple floor off the colonnade so the
# place has a floor rather than a shadow.
e.ground(STONE, rim=MIDNIGHT, dish=0.16)
e.apron(MIDNIGHT, out=2.50, drop=0.68)

# The wall. Without one a fight happens on a disc in an open sky and reads
# as a diorama on a plate: deeper in the same drowned city.
e.enclose("ruin")

# The temple floor: big square slabs in courses, most still seated, some lifted.
for ring, (r, n) in enumerate([(2.4, 9), (3.5, 12), (4.6, 14), (5.5, 16)]):
    for i in range(n):
        a = i * math.tau / n + ring * 0.09
        lift = 0.04 if (i + ring) % 7 else 0.14
        e.box((math.cos(a) * r, math.sin(a) * r, lift),
              (0.44, 0.36, 0.05), INDIGO if (i + ring) % 3 else MIDNIGHT,
              bevel=0.0, rot=(0.0, 0.0, a + (0.10 if lift > 0.1 else 0.0)))

# Steps up to where it stands — the middle was the altar.
e.taper((0.0, 0.0, 0.10), 2.15, 2.10, 0.20, INDIGO, seg=20)
e.taper((0.0, 0.0, 0.26), 1.80, 1.76, 0.18, IRIS, seg=20)

# The colonnade. Closer in than any other environment's, because this is the
# only fight that should feel enclosed rather than exposed.
e.scatter(10, lambda p, r, rng: e.pillar(p, r, INDIGO, cap=IRIS, broken=rng.random() < 0.5),
          near=3.9, far=5.8, arc=BACK, size=0.80)
e.scatter(6, lambda p, r, rng: e.pillar(p, r, MIDNIGHT, cap=None),
          near=3.0, far=4.4, arc=BACK, size=0.40)


def coral(p, r, rng):
    """Three branches out of one foot. The only warm colour down here."""
    col = CORAL if rng.random() < 0.55 else ROSE
    for i in range(3):
        a = i * math.tau / 3.0 + rng.random() * 0.5
        e.limb([(p.x, p.y, 0.04),
                (p.x + math.cos(a) * r * 0.42, p.y + math.sin(a) * r * 0.38,
                 r * 0.55),
                (p.x + math.cos(a) * r * 0.80, p.y + math.sin(a) * r * 0.72,
                 r * 1.05)],
               [r * 0.14, r * 0.10, r * 0.06], col, seg=4)
        e.ball((p.x + math.cos(a) * r * 0.84, p.y + math.sin(a) * r * 0.76,
                r * 1.12), (r * 0.13, r * 0.13, r * 0.12), BLUSH, 5, 3)


# Fix B. The docstring calls coral "the one warm colour in the game's
# coldest palette", and at ten pieces of size 0.44 it was too small to
# register at all — the cloud's review looked straight at it and read the
# ground as entirely cool. An accent nobody can see is not an accent.
# 14, not 16: at 16 this ground came to 7628 against a 7400 budget. The
# budget is shared by every ground and moving it to suit one is exactly
# what the fixer's brief forbids, so the count comes down instead.
e.scatter(14, coral, near=2.4, far=5.7, size=0.66)

# Weed off the slabs, and a scatter of gold where the offerings went.
e.scatter(12, lambda p, r, rng: e.reed(p, r, MINT if rng.random() < 0.5 else GREEN,
                                       n=4),
          near=2.6, far=5.7, size=0.26)
e.scatter(9, lambda p, r, rng: e.ball((p.x, p.y, 0.07),
                                      (r, r * 0.9, r * 0.30),
                                      GOLD if rng.random() < 0.6 else AMBER, 6, 4),
          near=2.2, far=4.6, size=0.11)

e.done(out_path(), name="SunkenWardenGround")
