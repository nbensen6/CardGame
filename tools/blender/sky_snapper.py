"""The Sky Snapper - a beak with a storm folded behind it.

Holds at Height 3, sigil at 5.

Perched, not flying. The read is TOP-HEAVY: a huge downward-hooked beak and two
folded wing-plates carried high, on legs too thin to explain any of it, so the
whole thing looks like it is about to fall forward and doesn't.

Not a bird. There are no feathers and no eyes in the usual place - the beak runs
straight into the body with no neck, and the lights are set into the plate above
it. It is a weather system that happens to have a beak.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import (out_path, mirror, point, aim, INDIGO, BLUE, NAVY, SKY, ICE,
                    SILVER, STEEL, SLATE, CHARCOAL, AMBER, GOLD, GRAPHITE)

b = Beast("sky_snapper", height=3.4)

# ------------------------------------------------------------------- the legs
def leg(s):
    b.limb([(0.42 * s, 0.16, 1.42),
            (0.56 * s, 0.06, 0.86),
            (0.52 * s, -0.10, 0.30)],
           [0.19, 0.15, 0.13], STEEL, seg=6)
    for spread, reach in ((-0.75, 0.34), (0.0, 0.40), (0.75, 0.34)):
        b.taper((0.52 * s, -0.14, 0.24), 0.075, 0.016, reach, SLATE, seg=4,
                rot=point((spread * s, -0.85, -0.55)))
    b.taper((0.52 * s, 0.14, 0.24), 0.065, 0.014, 0.30, SLATE, seg=4,
            rot=point((0.0, 0.85, -0.55)))                          # back talon


mirror(leg)

# ------------------------------------------------------------------- the body
b.ball((0.0, 0.10, 1.86), (0.72, 0.66, 0.78), INDIGO, 12, 7)
b.ball((0.0, 0.52, 2.10), (0.60, 0.52, 0.60), NAVY, 10, 6)             # mantle

# ------------------------------------------------------------------- the beak
# Straight into the body, no neck. Upper hooks down past the lower.
b.wedge((0.0, -0.58, 2.02), (0.46, 0.66, 0.30), SILVER,
        narrow=(0.30, 0.34), bevel=0.05)                               # upper
b.taper((0.0, -1.18, 1.86), 0.24, 0.05, 0.52, SILVER, seg=8,
        rot=point((0.0, -0.55, -1.0)))                                 # the hook
b.wedge((0.0, -0.50, 1.70), (0.36, 0.50, 0.14), STEEL,
        narrow=(0.34, 0.55), bevel=0.04)                               # lower
b.box((0.0, -0.20, 1.86), (0.30, 0.14, 0.030), CHARCOAL, bevel=0.010)  # the line

# Lights set INTO the plate above the beak, not eyes on a face.
b.wedge((0.0, -0.30, 2.34), (0.52, 0.42, 0.14), NAVY,
        narrow=(0.60, 0.55), bevel=0.045)                              # brow plate
mirror(lambda s: b.ball((0.26 * s, -0.52, 2.30), (0.105, 0.080, 0.075),
                        CHARCOAL, 8, 5))
mirror(lambda s: b.ball((0.27 * s, -0.60, 2.30), (0.060, 0.045, 0.045), AMBER, 7, 4))

# ------------------------------------------------------------------- the wings
# Folded plates carried HIGH, so the top of the silhouette is wide.
def wing(s):
    b.wedge((0.86 * s, 0.34, 2.42), (0.20, 0.62, 0.46), BLUE,
            narrow=(0.55, 0.30), bevel=0.05, rot=(0.0, -0.42 * s, 0.22 * s))
    b.wedge((1.16 * s, 0.62, 2.00), (0.14, 0.50, 0.38), SKY,
            narrow=(0.50, 0.28), bevel=0.04, rot=(0.0, -0.60 * s, 0.30 * s))
    for i, drop in enumerate((0.0, 0.26, 0.52)):
        b.taper((1.10 * s + 0.10 * s * i, 0.88 + 0.10 * i, 2.36 - drop),
                0.075, 0.014, 0.62, ICE, seg=4,
                rot=point((0.42 * s, 1.0, -0.30)))                     # trailing quills
    b.limb([(0.56 * s, 0.30, 2.30), (0.92 * s, 0.36, 2.52), (1.16 * s, 0.30, 2.60)],
           [0.13, 0.105, 0.085], STEEL, seg=5)                         # the spar


mirror(wing)

# ------------------------------------------------------------------- the hold
# The shoulder spar, flattened where the two wings meet the back.
b.shelf(3, (0.0, 0.38), (0.62, 0.44), STEEL, thickness=0.10)
b.ball((0.0, 0.42, 1.78), (0.60, 0.46, 0.16), STEEL, 9, 5)

b.mark(at=(0.0, -0.46, 2.38), size=0.28, facing=(0.0, -0.80, 0.60))
mirror(lambda s: b.taper((0.30 * s, 0.30, 2.76), 0.10, 0.018, 0.46, ICE, seg=5,
                         rot=point((0.30 * s, 0.55, 1.0))))            # crest

b.done(out_path(), name="SkySnapper")
