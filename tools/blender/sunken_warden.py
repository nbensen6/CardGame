"""The Sunken Warden - the last Titan, and the tallest thing in the game.

Holds at Heights 3, 6, 9 and 11, sigil at 13. Four tiers, and the top two are
close together, so the climb tightens as it goes: long hauls at the bottom, then
two ledges almost on top of each other just under the sigil. The body has to say
that - wide steps low down, a narrow stack near the crown.

A drowned tower of a creature, crusted over. Where the Drowned Colossus is a
hunched body that walked out of the water, this one never left it: it is
vertical, symmetrical, and grown over with coral, and the four ledges are the
rings of growth that grew out of it rather than limbs it has.

The one asymmetry is deliberate: the left buttress arm is broken off at the
elbow. On the beast that ends a run, something should look like it has already
survived being fought.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import (out_path, mirror, point, aim, MIDNIGHT, NAVY, INDIGO,
                    PERIWINKLE, IRIS, VIOLET, ICE, SILVER, STEEL, SLATE,
                    CORAL, ROSE, MINT, CHARCOAL, AMBER, GOLD, GRAPHITE)

b = Beast("sunken_warden", height=6.0, span=(-0.04, 5.76))

# ------------------------------------------------------------------- the base
b.ball((0.0, 0.0, 0.42), (1.72, 1.58, 0.46), MIDNIGHT, 10, 6)
for i in range(7):                                                  # anchor roots
    a = i * math.tau / 7.0 + 0.2
    b.limb([(math.cos(a) * 0.55, math.sin(a) * 0.52, 0.72),
            (math.cos(a) * 1.25, math.sin(a) * 1.16, 0.42),
            (math.cos(a) * 1.85, math.sin(a) * 1.70, 0.10)],
           [0.24, 0.17, 0.085], MIDNIGHT, seg=5)

# ------------------------------------------------------------- the trunk tiers
# Each tier is a drum, each narrower than the one below, and the step between
# them is the ledge. A column with ledges bolted on would read as scaffolding.
TIERS = [(1.20, 1.30, 1.18, 0.46, NAVY),
         (2.15, 1.14, 1.04, 0.52, NAVY),
         (3.05, 0.98, 0.90, 0.48, INDIGO),
         (3.85, 0.84, 0.78, 0.42, INDIGO),
         (4.45, 0.72, 0.68, 0.34, IRIS)]
for z, rx, ry, h, col in TIERS:
    b.taper((0.0, 0.0, z), rx, rx * 0.90, h * 2.0, col, seg=12)
    b.ring((0.0, 0.0, z - h * 0.55), (rx * 1.02, ry * 1.02, h * 0.30), MIDNIGHT,
           10, 4, thickness=0.20)

# ------------------------------------------------------------------ the ledges
b.shelf(3, (0.0, -0.30), (1.34, 0.92), SLATE, thickness=0.16)
b.shelf(6, (0.0, -0.26), (1.16, 0.82), SLATE, thickness=0.15)
b.shelf(9, (0.0, -0.22), (0.98, 0.70), SLATE, thickness=0.14)
b.shelf(11, (0.0, -0.20), (0.84, 0.60), SLATE, thickness=0.13)

# Coral crusting the ledges, so a hold is visible from below.
for z, r, n, col in ((1.94, 1.24, 6, CORAL), (2.80, 1.08, 5, ROSE),
                     (3.66, 0.92, 4, CORAL), (4.23, 0.80, 4, ROSE)):
    for i in range(n):
        a = 0.3 + i * math.tau / n
        x, y = math.cos(a) * r, math.sin(a) * r * 0.94
        b.limb([(x * 0.86, y * 0.86, z - 0.14),
                (x * 1.10, y * 1.10, z - 0.02),
                (x * 1.24, y * 1.24, z + 0.22)],
               [0.10, 0.075, 0.045], col, seg=4)
        b.ball((x * 1.26, y * 1.26, z + 0.27), (0.090, 0.090, 0.080), MINT, 5, 3)

# ----------------------------------------------------------- the buttress arms
# Right one whole, left one broken off at the elbow.
def arm(s, whole):
    b.limb([(0.62 * s, 0.10, 3.90),
            (1.28 * s, -0.10, 3.30),
            (1.62 * s, -0.30, 2.50)],
           [0.34, 0.29, 0.26], INDIGO, seg=7)
    b.ball((1.62 * s, -0.32, 2.42), (0.30, 0.30, 0.28), NAVY, 9, 5)   # elbow
    if not whole:
        b.taper((1.62 * s, -0.34, 2.28), 0.26, 0.16, 0.26, CHARCOAL, seg=8,
                rot=point((0.0, 0.0, -1.0)))                          # the break
        return
    b.limb([(1.62 * s, -0.34, 2.36),
            (1.70 * s, -0.52, 1.60),
            (1.58 * s, -0.62, 0.92)],
           [0.25, 0.22, 0.20], INDIGO, seg=6)
    b.ball((1.56 * s, -0.66, 0.80), (0.30, 0.34, 0.24), NAVY, 9, 5)
    for spread in (-0.55, 0.0, 0.55):
        b.taper((1.56 * s, -0.80, 0.70), 0.085, 0.018, 0.36, CHARCOAL, seg=5,
                rot=point((spread * s, -0.70, -1.0)))


arm(1, True)
arm(-1, False)

# ------------------------------------------------------------------- the head
b.taper((0.0, -0.08, 4.92), 0.66, 0.50, 0.62, IRIS, seg=10)
b.wedge((0.0, -0.62, 4.86), (0.44, 0.34, 0.24), SILVER,
        narrow=(0.55, 0.60), bevel=0.05)                              # face plate
mirror(lambda s: b.ball((0.26 * s, -0.60, 5.02), (0.125, 0.100, 0.110),
                        CHARCOAL, 8, 5))
mirror(lambda s: b.ball((0.27 * s, -0.70, 5.02), (0.072, 0.052, 0.062), AMBER, 7, 4))
b.box((0.0, -0.74, 4.70), (0.20, 0.10, 0.035), CHARCOAL, bevel=0.010)

# ------------------------------------------------------------------ the crown
for i in range(6):
    a = i * math.tau / 6.0 + 0.4
    lean = 0.34 if i % 2 else 0.20
    b.taper((math.cos(a) * 0.46, math.sin(a) * 0.44, 5.34), 0.17, 0.025,
            0.86 if i % 2 else 0.62, PERIWINKLE, seg=5,
            rot=point((math.cos(a) * lean, math.sin(a) * lean, 1.0)))
b.ball((0.0, 0.0, 5.40), (0.46, 0.44, 0.26), VIOLET, 9, 5)

b.foot((0.0, -1.45, 0.58))           # onto the anchor roots

b.mark(at=(0.0, -0.80, 4.42), size=0.36, facing=(0.0, -1.0, 0.10))

b.done(out_path(), name="SunkenWarden")
