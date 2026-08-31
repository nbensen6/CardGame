"""Where the Shifting Idol is fought: a plaza somebody built, and then left.

The Idol is the only made thing in the roster — stacked, carved, deliberate — so
it gets the only made GROUND: cut flagstones in courses, the stumps of a
colonnade, and a step ring around the middle where it stands. Everything is
square, and everything has come out of true, which is the same joke the beast is.

The flagstones run in rings rather than rows, so the eye is led to the middle
even in a still frame.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, STONE, PEWTER, SLATE, GRAPHITE, CHARCOAL,
                    SILVER, SAND, WHEAT, TAN, CLAY, MINT, GREEN, VIOLET, ORCHID,
                    AMBER)

e = Env(seed=131)

e.ground(STONE, rim=GRAPHITE, dish=0.0)
e.apron(GRAPHITE, out=2.50, drop=0.62)

# The wall. Without one a fight happens on a disc in an open sky and reads
# as a diorama on a plate: the courtyard it was built in.
e.enclose("ruin")

# Flagstones in concentric courses, each ring turned a little off the last, so
# the floor reads as laid rather than as a texture.
for ring, (r, n, col) in enumerate([(2.15, 10, PEWTER), (3.15, 13, SLATE),
                                    (4.15, 16, PEWTER), (5.20, 18, GRAPHITE)]):
    for i in range(n):
        a = i * math.tau / n + ring * 0.11
        e.box((math.cos(a) * r, math.sin(a) * r, 0.035),
              (0.34, 0.28, 0.045), col, bevel=0.0, rot=(0.0, 0.0, a))

# The step ring: two low courses the Idol is standing on.
e.taper((0.0, 0.0, 0.09), 2.05, 2.00, 0.18, PEWTER, seg=20)
e.taper((0.0, 0.0, 0.22), 1.72, 1.68, 0.16, SILVER, seg=20)

# The colonnade, broken off at different heights. Back only — a standing pillar
# on the near rim is a post through the middle of the fight.
e.scatter(9, lambda p, r, rng: e.pillar(p, r, SILVER, cap=PEWTER),
          near=4.3, far=5.9, arc=BACK, size=0.62)
e.scatter(5, lambda p, r, rng: e.pillar(p, r, PEWTER, cap=None),
          near=3.3, far=4.6, arc=BACK, size=0.34)

# Fallen drums and blocks from the pillars that went first.
e.scatter(10, lambda p, r, rng: e.taper((p.x, p.y, r * 0.20), r * 0.62, r * 0.58,
                                        r * 0.42, SILVER, seg=8,
                                        rot=(1.57, 0.0, rng.random() * math.tau)),
          near=2.6, far=5.6, size=0.34)

# Violet light in the joints, the same colour that holds the beast together.
e.scatter(12, lambda p, r, rng: e.box((p.x, p.y, 0.055),
                                      (r, r * 0.10, 0.035), VIOLET, bevel=0.0,
                                      rot=(0, 0, rng.random() * math.tau)),
          near=2.3, far=5.5, size=0.42)

# Weeds through the cracks: the only thing here that was not put here.
e.scatter(9, lambda p, r, rng: e.ball((p.x, p.y, r * 0.22),
                                      (r, r * 0.85, r * 0.34),
                                      MINT if rng.random() < 0.4 else GREEN, 6, 4),
          near=2.6, far=5.7, size=0.18)

e.done(out_path(), name="ShiftingIdolGround")
