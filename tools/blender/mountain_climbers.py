"""The Mountain Climbers - "Roped: the ally climbs with you."

Stocky and wide, and the only hunter carrying gear. The rope is the character -
it is what the class does - so it gets built as an actual rope: one limb wound
twice round the chest on a helix that follows the torso's own curve, instead of
the two floating tori the first version used. Two horizontal hoops read as a
barrel, not as something a person put on.

Rebuilt on the wider vocabulary (see kenney.py). What changed besides the rope:
boots and beard are tapers and wedges rather than beans, the arms and legs are
limbs that bend, the pack is a bevelled box because a pack is a box, and the
carabiner is a torus you can see through instead of a black chip.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, mirror, aim, point, BLUE, INDIGO, TAN,
                    CREAM, PEACH, BROWN, UMBER, AMBER, WHITE, CHARCOAL, CLAY)

DOWN = (0, 0, -1)

b = Build()

# ------------------------------------------------------------------- the legs
def leg(s):
    # Down to 0.105, not 0.175: a limb's radius spreads PERPENDICULAR to its
    # path, so a vertical tube stops dead at its last point and does not bulge
    # below it. Ending at the ankle left the boots hanging in space, which is
    # exactly what finish()'s island check said and what the front view did not.
    b.limb([(0.170 * s,  0.020, 0.470),
            (0.178 * s,  0.000, 0.300),
            (0.172 * s, -0.020, 0.105)],
           [0.128, 0.112, 0.100], UMBER, seg=6)
    b.wedge((0.180 * s, -0.070, 0.072), (0.140, 0.215, 0.072), BROWN,
            narrow=(0.74, 0.66), bevel=0.030)


mirror(leg)

# ------------------------------------------------------------------ the torso
b.ball((0.0, 0.0, 0.80), (0.335, 0.275, 0.335), BLUE, 10, 6)
b.box((0.0, -0.245, 0.760), (0.105, 0.045, 0.190), INDIGO, bevel=0.028)  # placket


def arm(s):
    b.limb([(0.290 * s, -0.010, 0.955),
            (0.352 * s, -0.055, 0.800),
            (0.368 * s, -0.115, 0.660),
            (0.352 * s, -0.150, 0.585)],
           [0.115, 0.100, 0.092, 0.086], BLUE, seg=6)
    b.ball((0.348 * s, -0.170, 0.545), (0.104, 0.112, 0.096), CREAM, 8, 5)  # mitt


mirror(arm)

# ------------------------------------------------------------------- the pack
b.box((0.0, 0.315, 0.855), (0.208, 0.115, 0.235), CLAY, bevel=0.038)
b.box((0.0, 0.395, 0.905), (0.150, 0.048, 0.115), UMBER, bevel=0.024)   # flap
mirror(lambda s: b.box((0.180 * s, 0.055, 0.905), (0.038, 0.230, 0.030), UMBER,
                       bevel=0.012, rot=(0.22, 0, 0)))                  # straps

# ------------------------------------------------------------------- the rope
# A helix that follows the torso's own curve, so it lies ON him. The horizontal
# radius has to shrink toward the shoulders or the rope floats off the chest at
# the top and cuts into it at the bottom - which is the whole reason two flat
# hoops never looked worn.
CZ, RZ = 0.80, 0.345
coil = []
for i in range(25):
    t = i / 24.0
    z = 0.985 - 0.370 * t
    f = math.sqrt(max(0.06, 1.0 - ((z - CZ) / RZ) ** 2))
    a = -0.6 + t * 2.15 * math.tau
    coil.append((math.cos(a) * 0.360 * f, math.sin(a) * 0.302 * f, z))
b.limb(coil, 0.030, TAN, seg=4, cap=False)
b.ring((0.115, -0.315, 0.640), (0.070, 0.070, 0.070), CHARCOAL, 10, 4,
       thickness=0.30, rot=(0.0, 0.35, 0.0))                           # carabiner

# ------------------------------------------------------------------- the head
b.ball((0.0, -0.035, 1.195), (0.222, 0.212, 0.212), PEACH, 10, 6)
b.taper((0.0, -0.115, 1.090), 0.170, 0.052, 0.230, CREAM, seg=8,
        rot=point((0.0, -0.30, -1.0)))                                 # beard
mirror(lambda s: b.ball((0.088 * s, -0.192, 1.232), (0.036, 0.030, 0.036),
                        CHARCOAL, 6, 4))

b.ball((0.0, -0.020, 1.320), (0.252, 0.242, 0.170), AMBER, 10, 6)      # helmet
b.wedge((0.0, -0.215, 1.300), (0.150, 0.090, 0.028), AMBER,
        narrow=(0.66, 0.80), bevel=0.014)                              # brim
b.taper((0.0, -0.225, 1.352), 0.062, 0.055, 0.075, CHARCOAL, seg=8,
        rot=point((0, -1, 0)))                                         # lamp barrel
b.ball((0.0, -0.268, 1.352), (0.050, 0.022, 0.050), WHITE, 8, 5)       # lens
mirror(lambda s: b.limb([(0.215 * s, -0.030, 1.290),
                         (0.190 * s, -0.110, 1.155),
                         (0.090 * s, -0.150, 1.075)],
                        [0.022, 0.020, 0.018], INDIGO, seg=4))         # chin strap

b.finish(out_path(), name="MountainClimbers", budget="hunter")
