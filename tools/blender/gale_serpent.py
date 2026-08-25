"""The Gale Serpent - a storm that coiled up and stayed.

Holds at Heights 3 and 6, sigil at 9. Its limiter is `sigil_fatigue`: it chips
a hunter who camps at the sigil, so the sigil sits under a hood that is visibly
about to close - the reason the rule bites is on screen before it does.

The silhouette is a SPIRAL. Nothing else in the roster turns, and a coil is the
one shape that says "you climb around this, not up it". The holds are the flat
tops of two coils, worn smooth.

There is no body under the coil. The coil is the body: one limb on a helix,
narrowing all the way from the floor to the throat, which is what limb() exists
for and what a stack of spheres could never say.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import (out_path, mirror, point, aim, SKY, ICE, WHITE, SILVER,
                    STEEL, INDIGO, BLUE, PERIWINKLE, CHARCOAL, AMBER, SLATE)

b = Beast("gale_serpent", height=5.0)

# ------------------------------------------------------------------ the coil
# 2.7 turns from the floor to the throat, the radius closing as it climbs, so
# the tower tapers and the top of the spiral is the narrowest part.
coil = []
radii = []
N = 46
for i in range(N):
    t = i / (N - 1.0)
    z = 0.42 + 3.05 * t
    r = 1.42 - 0.95 * t
    a = -0.9 + t * 2.70 * math.tau
    coil.append((math.cos(a) * r, math.sin(a) * r * 0.94, z))
    radii.append(0.52 - 0.20 * t)
b.limb(coil, radii, SKY, seg=8, cap=False)

# The underside, a paler belly band following the same path a little inside it.
belly = [(x * 0.88, y * 0.88, z - 0.22) for x, y, z in coil[::3]]
b.limb(belly, [0.16 - 0.06 * (i / max(1.0, len(belly) - 1.0))
               for i in range(len(belly))], ICE, seg=5, cap=False)

# Fins along the spine, laid back, thinning as they climb.
for i in range(9, N - 4, 5):
    x, y, z = coil[i]
    t = i / (N - 1.0)
    b.wedge((x * 1.05, y * 1.05, z + 0.34 - 0.10 * t), (0.10, 0.30 - 0.10 * t,
            0.34 - 0.13 * t), PERIWINKLE, narrow=(0.35, 0.30), bevel=0.0,
            rot=aim((x, y, 1.35)))

# ------------------------------------------------------------------ the holds
# Two coils worn flat where something has stood on them before. WHERE the coil
# is at a given height is a fact about the helix, so ask the helix - placed by
# hand the ledges came out hanging in the air beside it, because the spiral had
# moved on by the time it reached that height.
def on_coil(z):
    best = min(coil, key=lambda p: abs(p[2] - z))
    return (best[0], best[1])


b.shelf(3, on_coil(b.z_for(3)), (0.62, 0.52), SILVER, thickness=0.12)
b.shelf(6, on_coil(b.z_for(6)), (0.54, 0.46), SILVER, thickness=0.12)

# ------------------------------------------------------------------- the neck
neck = [coil[-1],
        (coil[-1][0] * 0.4, coil[-1][1] * 0.4 - 0.35, 3.86),
        (0.0, -0.62, 4.24),
        (0.0, -0.78, 4.56)]
b.limb(neck, [0.32, 0.28, 0.26, 0.28], SKY, seg=8, cap=False)

# ------------------------------------------------------------------- the hood
# Two plates flaring off the skull, angled forward. They are what makes the
# sigil sit in a mouth that is about to shut.
b.ball((0.0, -0.86, 4.62), (0.42, 0.50, 0.34), INDIGO, 10, 6)
mirror(lambda s: b.wedge((0.52 * s, -0.68, 4.60), (0.16, 0.56, 0.50), BLUE,
                         narrow=(0.55, 0.34), bevel=0.05,
                         rot=(0.0, -0.55 * s, 0.30 * s)))
mirror(lambda s: b.taper((0.72 * s, -0.30, 4.86), 0.13, 0.02, 0.66, ICE, seg=5,
                         rot=point((0.55 * s, 0.35, 1.0))))
b.wedge((0.0, -1.26, 4.52), (0.30, 0.40, 0.18), SILVER,
        narrow=(0.40, 0.55), bevel=0.04)                              # snout
mirror(lambda s: b.ball((0.22 * s, -1.12, 4.72), (0.115, 0.095, 0.100),
                        CHARCOAL, 8, 5))
mirror(lambda s: b.ball((0.23 * s, -1.20, 4.72), (0.066, 0.048, 0.058), AMBER, 7, 4))
b.box((0.0, -1.36, 4.40), (0.16, 0.10, 0.030), CHARCOAL, bevel=0.008)

b.mark(at=(0.0, -0.72, 4.02), size=0.34, facing=(0.0, -1.0, 0.0))

b.done(out_path(), name="GaleSerpent")
