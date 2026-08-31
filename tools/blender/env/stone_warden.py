"""Where the Stone Warden is fought: a quarry somebody stopped working.

The first Titan of a run and an animal made of rock, so the ground says where
that rock came from — cut faces, sawn blocks stacked and abandoned, spoil heaps,
and a half-worked block still lying on its side with the cut marks in it.

It reads against the Crag Pup's natural scree because everything here has a
STRAIGHT edge. Same stone, opposite hand.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, STONE, PEWTER, SLATE, GRAPHITE, CHARCOAL,
                    SILVER, SAND, WHEAT, TAN, CLAY, BROWN, UMBER, MINT, GREEN)

e = Env(seed=229)

e.ground(SAND, rim=GRAPHITE, dish=0.16)
e.apron(GRAPHITE, out=1.35, drop=0.68)

# The wall. Without one a fight happens on a disc in an open sky and reads
# as a diorama on a plate: the quarry that produced it.
e.enclose("cliff")

# The floor of a quarry: cut in benches, each a step lower than the last, and
# all of them straight. Nothing natural is this square.
for i, (y, w, h, col) in enumerate([(-3.9, 5.0, 0.10, PEWTER),
                                    (-2.5, 5.4, 0.16, SLATE),
                                    (2.6, 5.2, 0.14, PEWTER),
                                    (4.0, 4.6, 0.09, SLATE)]):
    e.box((0.0, y, h * 0.5), (w, 0.62, h), col, bevel=0.04)

# Sawn blocks, stacked where they were left. The stacks are the tall thing here,
# so they go behind — see env.BACK.
def stack(p, r, rng):
    n = rng.randint(2, 4)
    for i in range(n):
        e.box((p.x + rng.uniform(-0.1, 0.1) * r,
               p.y + rng.uniform(-0.1, 0.1) * r,
               r * (0.32 + i * 0.62)),
              (r * 0.62, r * 0.52, r * 0.30),
              SILVER if (i + rng.randint(0, 1)) % 2 else PEWTER,
              bevel=r * 0.05, rot=(0.0, 0.0, rng.uniform(-0.25, 0.25)))


e.scatter(8, stack, near=3.8, far=5.8, arc=BACK, size=0.62)
e.scatter(5, stack, near=2.7, far=5.5, arc=ANY, size=0.26)

# One block still half-worked, lying over with the cut marks in it.
e.box((-2.9, 1.5, 0.42), (1.30, 0.62, 0.42), SILVER, bevel=0.06, rot=(0.0, 0.10, 0.35))
for i in range(5):
    e.box((-2.9 + (i - 2) * 0.42, 1.5 - 0.22 * (i % 2), 0.86),
          (0.05, 0.55, 0.05), GRAPHITE, bevel=0.0, rot=(0.0, 0.0, 0.35))

# Spoil: chips and dust in drifts against everything straight.
e.scatter(30, lambda p, r, rng: e.box((p.x, p.y, 0.035),
                                      (r, r * 0.72, 0.035),
                                      TAN if rng.random() < 0.5 else WHEAT,
                                      bevel=0.0,
                                      rot=(0, 0, rng.random() * math.tau)),
          near=1.9, far=5.8, size=0.26)
e.scatter(11, lambda p, r, rng: e.rock(p, r, SLATE, sink=0.52),
          near=2.4, far=5.7, size=0.26)

# Weeds where nobody has worked for years — the only soft thing in the place.
e.scatter(9, lambda p, r, rng: e.ball((p.x, p.y, r * 0.24),
                                      (r, r * 0.85, r * 0.36),
                                      MINT if rng.random() < 0.4 else GREEN, 6, 4),
          near=2.5, far=5.7, size=0.19)

e.done(out_path(), name="StoneWardenGround")
