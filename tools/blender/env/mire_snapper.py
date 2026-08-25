"""Where the Mire Snapper is fought: shallow water over a silt bed.

The only horizontal beast in the roster, lying in the only place where lying
down is normal. Standing water broken by reed islands, silt bars showing
through, half-sunk logs — and the trick of the place is that at a glance the
beast is one more log.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, CLAY, UMBER, BROWN, TAN, GREEN, MINT,
                    CHARCOAL, GRAPHITE, STEEL)

e = Env(seed=57)

# Silt, dished so the water pools in the middle where the beast lies.
e.ground(CLAY, rim=UMBER, dish=0.34)
e.apron(UMBER, out=1.8, drop=0.58)

# The water: broad flat sheets just above the silt, overlapping so the edges
# read as a waterline rather than as one clean disc laid on another.
for i, (x, y, s) in enumerate([(0.0, 0.6, 4.6), (-2.6, -2.2, 2.4),
                               (2.9, -1.9, 2.1), (1.4, 3.4, 2.0),
                               (-3.2, 2.6, 1.7)]):
    e.taper((x, y, 0.05 + i * 0.006), s, s * 0.94, 0.09, STEEL, seg=14)

# Silt bars showing through it.
e.scatter(9, lambda p, r, rng: e.ball((p.x, p.y, 0.06),
                                      (r, r * 0.72, r * 0.16), TAN, 7, 4,
                                      rot=(0, 0, rng.random() * math.tau)),
          near=2.4, far=5.6, size=0.75)

# Reed islands. The tall ones go behind, or they stand between you and the fight.
e.scatter(9, lambda p, r, rng: e.reed(p, r, GREEN if rng.random() < 0.6 else MINT,
                                      n=7),
          near=3.4, far=5.8, arc=BACK, size=0.72)
e.scatter(7, lambda p, r, rng: e.reed(p, r, GREEN, n=4),
          near=2.6, far=5.7, arc=ANY, size=0.30)


def sunk_log(p, r, rng):
    """What the beast is pretending to be until it opens."""
    a = rng.random() * math.tau
    e.limb([(p.x - math.cos(a) * r * 1.8, p.y - math.sin(a) * r * 1.8, -r * 0.1),
            (p.x, p.y, r * 0.16),
            (p.x + math.cos(a) * r * 1.8, p.y + math.sin(a) * r * 1.8, -r * 0.12)],
           [r * 0.22, r * 0.30, r * 0.20], UMBER, seg=6)


e.scatter(6, sunk_log, near=2.8, far=5.5, size=0.55)


def snag(p, r, rng):
    """A dead tree standing in the water, bare."""
    e.limb([(p.x, p.y, 0.0), (p.x + r * 0.1, p.y, r * 1.4),
            (p.x + r * 0.14, p.y, r * 2.3)],
           [r * 0.16, r * 0.11, r * 0.06], GRAPHITE, seg=5)
    for _ in range(2):
        b = rng.random() * math.tau
        e.taper((p.x + r * 0.12, p.y, r * (1.5 + rng.random() * 0.6)),
                r * 0.055, r * 0.01, r * 0.8, GRAPHITE, seg=4,
                rot=point((math.cos(b), math.sin(b), 0.55)))


e.scatter(6, snag, near=4.3, far=5.9, arc=BACK, size=0.72)

e.done(out_path(), name="MireSnapperGround")
