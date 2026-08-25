"""The Bounder - a boulder that learned to jump.

Holds at Height 2, sigil at 4: a short climb, so it is a small beast and the
whole body has to read at once.

Not an animal (Nick, 2026-08-25: the beasts should be creatures, not animals).
This one is a mass of stone slung between two enormous folded legs, with no head
to speak of - just a lit seam where a face would be. The silhouette is the joke:
almost all of it is legs, coiled, and the body hangs between them like something
about to be launched.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import (out_path, mirror, point, aim, STONE, PEWTER, SLATE,
                    GRAPHITE, CHARCOAL, AMBER, GOLD, MINT)

b = Beast("bounder", height=3.0)


def leg(s):
    """Folded like a grasshopper's: knee ABOVE the body, ankle below it."""
    b.limb([(0.72 * s,  0.30, 1.62),
            (1.05 * s,  0.46, 2.15),
            (1.16 * s,  0.18, 1.55),
            (1.02 * s, -0.14, 0.85),
            (0.94 * s, -0.34, 0.26)],
           [0.42, 0.36, 0.30, 0.25, 0.22], PEWTER, seg=8)
    b.ball((1.05 * s, 0.44, 2.16), (0.40, 0.40, 0.35), SLATE, 9, 5)     # knee cap
    b.wedge((0.92 * s, -0.52, 0.16), (0.30, 0.52, 0.16), GRAPHITE,
            narrow=(0.72, 0.55), bevel=0.05)                            # foot
    for spread in (-0.5, 0.0, 0.5):                                     # claws
        b.taper((0.92 * s, -0.96, 0.14), 0.085, 0.020, 0.34, CHARCOAL, seg=5,
                rot=point((spread * s, -1.0, -0.30)))


mirror(leg)

# The body: one big stone mass slung between the legs, cracked across the front.
b.ball((0.0, 0.0, 1.95), (0.90, 0.82, 0.92), STONE, 12, 7)
b.ball((0.0, 0.30, 2.10), (0.72, 0.60, 0.66), PEWTER, 10, 6)            # back hump
for a, z, w in ((1.5, 1.70, 0.26), (3.0, 2.30, 0.22), (4.7, 1.86, 0.28)):
    b.box((math.cos(a) * 0.82, math.sin(a) * 0.76, z), (w, 0.11, w * 0.50),
          SLATE, bevel=0.035, rot=(0.0, 0.0, a + math.pi / 2))          # plates

# The hold at Height 2 - a slab of the body's own stone, jutting where the legs
# meet it, which is the only place on this creature anything could stand.
b.shelf(2, (0.0, -0.62), (0.76, 0.46), SLATE, thickness=0.11)
b.wedge((0.0, -0.98, 1.30), (0.58, 0.34, 0.22), PEWTER,
        narrow=(0.66, 0.40), bevel=0.05)                                # underhang

# No head. A lit seam across the front, and the sigil above it.
mirror(lambda s: b.ball((0.31 * s, -0.755, 1.985), (0.135, 0.095, 0.105),
                        CHARCOAL, 8, 5))
mirror(lambda s: b.ball((0.31 * s, -0.815, 1.985), (0.082, 0.055, 0.062),
                        AMBER, 7, 4))
mirror(lambda s: b.taper((0.62 * s, 0.10, 2.72), 0.16, 0.03, 0.52, SLATE, seg=6,
                         rot=point((0.34 * s, 0.30, 1.0))))             # crown spurs
b.ball((0.0, 0.06, 2.72), (0.44, 0.40, 0.26), MINT, 9, 5)               # moss cap

# Where the climb starts: the top of a foot, which is the only thing on this
# beast low enough to step onto.
b.foot((0.86, -0.58, 0.32))

b.mark(at=(0.0, -0.66, 2.36), size=0.32)

b.done(out_path(), name="Bounder")
