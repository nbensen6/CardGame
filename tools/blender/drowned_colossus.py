"""The Drowned Colossus - something that walked out of deep water and did not dry.

Holds at Heights 3, 6 and 9, sigil at 11. Three tiers, so it has to be legible
as a CLIMB and not just as a big shape: shoulder, chest, hip, each a real ledge
with the body stepping back above it, the way a cliff has terraces.

Hunched, waterlogged, and open down the front - the chest has burst and there is
light in the cavity. The kelp is not decoration: it hangs off every ledge, so
from below you can see where the holds are before you can see the holds.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import (out_path, mirror, point, aim, SLATE, STEEL, NAVY, INDIGO,
                    MIDNIGHT, PERIWINKLE, MINT, GREEN, ICE, CHARCOAL, AMBER,
                    SILVER, GRAPHITE)

b = Beast("drowned_colossus", height=5.4)

# -------------------------------------------------------------------- the legs
def leg(s):
    b.limb([(0.86 * s, 0.34, 2.30),
            (1.00 * s, 0.20, 1.50),
            (0.96 * s, -0.05, 0.70),
            (0.92 * s, -0.18, 0.24)],
           [0.52, 0.44, 0.38, 0.34], MIDNIGHT, seg=8)
    b.wedge((0.92 * s, -0.42, 0.20), (0.42, 0.62, 0.20), GRAPHITE,
            narrow=(0.74, 0.60), bevel=0.06)
    for spread in (-0.55, 0.0, 0.55):
        b.taper((0.92 * s, -0.94, 0.16), 0.10, 0.022, 0.36, CHARCOAL, seg=5,
                rot=point((spread * s, -1.0, -0.30)))


mirror(leg)

# ------------------------------------------------------------- hip  (Height 3)
b.ball((0.0, 0.20, 2.32), (1.18, 1.02, 0.66), MIDNIGHT, 12, 7)
b.shelf(3, (0.0, -0.62), (0.98, 0.56), SLATE, thickness=0.14)

# ----------------------------------------------------------- chest  (Height 6)
b.ball((0.0, 0.32, 3.10), (1.10, 0.98, 0.78), NAVY, 12, 7)
# The cavity: a dark well with a light at the bottom of it, cut into the front.
b.taper((0.0, -0.72, 3.10), 0.56, 0.40, 0.52, CHARCOAL, seg=10,
        rot=point((0.0, -1.0, 0.0)))
b.ball((0.0, -0.52, 3.10), (0.26, 0.26, 0.30), AMBER, 9, 5)
mirror(lambda s: b.box((0.58 * s, -0.66, 3.12), (0.10, 0.20, 0.46), STEEL,
                       bevel=0.03, rot=(0.0, 0.0, -0.30 * s)))          # broken ribs
b.shelf(6, (0.0, -0.50), (0.86, 0.48), SLATE, thickness=0.14)

# -------------------------------------------------------- shoulder  (Height 9)
b.ball((0.0, 0.30, 3.86), (1.02, 0.88, 0.52), INDIGO, 10, 6)
b.shelf(9, (0.0, -0.36), (0.80, 0.44), SLATE, thickness=0.14)


def arm(s):
    """Long, hanging, knuckles near the knee. Weight, not reach."""
    b.limb([(0.92 * s, 0.26, 3.90),
            (1.24 * s, 0.02, 3.10),
            (1.30 * s, -0.22, 2.30),
            (1.22 * s, -0.34, 1.72)],
           [0.40, 0.33, 0.29, 0.27], NAVY, seg=8)
    b.ball((1.20 * s, -0.42, 1.52), (0.34, 0.34, 0.30), MIDNIGHT, 9, 5)
    for spread in (-0.5, 0.5):
        b.taper((1.20 * s, -0.56, 1.38), 0.10, 0.02, 0.40, CHARCOAL, seg=5,
                rot=point((spread * s, -0.55, -1.0)))
    b.box((1.08 * s, 0.16, 3.72), (0.30, 0.26, 0.16), STEEL, bevel=0.04)  # pauldron


mirror(arm)

# ------------------------------------------------------------------- the head
b.limb([(0.0, 0.10, 4.20), (0.0, -0.10, 4.44), (0.0, -0.22, 4.62)],
       [0.30, 0.27, 0.29], INDIGO, seg=7)
b.ball((0.0, -0.30, 4.76), (0.52, 0.54, 0.44), NAVY, 10, 6)
b.wedge((0.0, -0.80, 4.66), (0.34, 0.36, 0.20), STEEL,
        narrow=(0.50, 0.55), bevel=0.05)
mirror(lambda s: b.ball((0.24 * s, -0.66, 4.86), (0.115, 0.090, 0.100),
                        CHARCOAL, 8, 5))
mirror(lambda s: b.ball((0.25 * s, -0.74, 4.86), (0.066, 0.048, 0.058), AMBER, 7, 4))
mirror(lambda s: b.taper((0.44 * s, -0.10, 5.02), 0.16, 0.03, 0.62, ICE, seg=5,
                         rot=point((0.42 * s, 0.24, 1.0))))

# ------------------------------------------------------------------- the kelp
# Hanging off every ledge, so the holds are visible from underneath.
for z, r, n in ((2.32 - 0.10, 1.05, 7), (3.10 - 0.10, 0.98, 6), (3.86 - 0.08, 0.90, 5)):
    for i in range(n):
        a = -0.4 + i * (math.pi * 1.35) / max(1, n - 1)
        x, y = math.cos(a) * r, math.sin(a) * r * 0.9 + 0.2
        drop = 0.42 + 0.30 * ((i * 0.37) % 1.0)
        b.limb([(x, y, z), (x * 1.06, y * 1.04, z - drop * 0.6),
                (x * 1.02, y * 1.02, z - drop)],
               [0.075, 0.055, 0.030], GREEN if i % 2 else MINT, seg=4, cap=False)

b.foot((0.90, -0.50, 0.42))          # onto the top of a foot

# A collar between the shoulders, so the sigil has a surface to sit on. Placed
# at the sigil Height first and shaped around it, not the other way round.
b.wedge((0.0, -0.50, 4.26), (0.62, 0.42, 0.30), INDIGO,
        narrow=(0.62, 0.66), bevel=0.06)
b.mark(at=(0.0, -0.84, 4.30), size=0.38, facing=(0.0, -0.98, 0.20))

b.done(out_path(), name="DrownedColossus")
