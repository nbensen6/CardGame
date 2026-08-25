"""The Goblin Engineer - "Heavy hitter: builds gadgets to climb."

A small goblin under an oversized rig. The asymmetry IS the read: one ordinary
arm, one enormous mechanical one, so which class this is survives being 40px
tall at a Titan's foot.

Rebuilt on the wider vocabulary (see kenney.py). The first version was made of
ellipsoids, and a MACHINE made of ellipsoids is the worst case of that: the rig
was four soft grey eggs in a row, which reads as a boulder he is carrying rather
than as an arm he is wearing. Machinery is boxes, cylinders and pistons - hard
edges with a bevel on them, which is exactly what box() and taper() are for.

The organic half stays soft on purpose. Goblin round, rig square, and the two
halves of the silhouette disagree with each other, which is the character.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, mirror, MINT, GREEN, GRAPHITE, PEWTER,
                    STONE, CHARCOAL, PUMPKIN, CARROT, GOLD, ICE, UMBER)

UP = 0.0                  # a cone already points +Z
FWD = math.pi / 2         # ... this turns it to face -Y

b = Build()

# ------------------------------------------------------------------ the goblin


def leg(s):
    """Short, bent, planted. One limb, not two stacked eggs."""
    b.limb([(0.150 * s,  0.030, 0.410),
            (0.158 * s,  0.000, 0.250),
            (0.152 * s, -0.030, 0.130)],
           [0.115, 0.098, 0.088], GRAPHITE, seg=6)
    b.wedge((0.158 * s, -0.048, 0.060), (0.112, 0.155, 0.060), CHARCOAL,
            narrow=(0.72, 0.62), bevel=0.024)                      # boot


mirror(leg)

b.ball((0.0, 0.0, 0.66), (0.275, 0.235, 0.255), MINT, 10, 6)       # body
b.box((0.0, -0.190, 0.605), (0.150, 0.038, 0.140), UMBER, bevel=0.024)  # apron

# ------------------------------------------------------------------- the rig
# Every piece here is a box or a cylinder. That is the whole difference: a
# bevelled box catches a bright line along each edge and reads as machined
# plate, where a sphere reads as a pebble.
#
# The trap, learned the expensive way: a box HALF-EXTENT is not a sphere RADIUS.
# Swapping the numbers straight across inflates every part by its corners, and
# the first pass came out as a stack of grey fridges the goblin was hiding
# behind. Multiply the old radii by about 0.72 and the volumes match.
b.box((0.0, 0.278, 0.800), (0.145, 0.098, 0.152), GRAPHITE, bevel=0.026)
b.box((0.0, 0.278, 0.960), (0.106, 0.078, 0.030), PEWTER, bevel=0.013)   # lid
b.limb([(0.112, 0.330, 0.880), (0.122, 0.398, 0.995), (0.140, 0.392, 1.088)],
       [0.044, 0.040, 0.036], PUMPKIN, seg=6)                           # exhaust
b.taper((0.142, 0.392, 1.128), 0.057, 0.046, 0.078, CARROT, seg=6, bevel=0.010)

b.box((0.346, 0.030, 0.812), (0.122, 0.126, 0.134), PEWTER, bevel=0.024,
      rot=(0.0, 0.10, 0.0))
b.limb([(0.350, 0.020, 0.766), (0.392, -0.030, 0.652), (0.414, -0.062, 0.580)],
       [0.098, 0.086, 0.080], STONE, seg=6)                             # upper arm
b.box((0.416, -0.068, 0.548), (0.086, 0.090, 0.106), PEWTER, bevel=0.020,
      rot=(0.12, 0.14, 0.0))
b.limb([(0.420, -0.076, 0.500), (0.438, -0.100, 0.430), (0.450, -0.118, 0.378)],
       [0.068, 0.076, 0.082], PEWTER, seg=6)                            # wrist
b.box((0.454, -0.128, 0.298), (0.132, 0.138, 0.112), STONE, bevel=0.026,
      rot=(0.18, 0.20, 0.0))
b.taper((0.454, -0.268, 0.298), 0.072, 0.058, 0.130, CARROT, seg=6, rot=(FWD, 0, 0))
for dz in (-0.048, 0.048):                                              # piston rods
    b.taper((0.454, -0.208, 0.298 + dz), 0.016, 0.016, 0.190, CHARCOAL, seg=5,
            rot=(FWD, 0, 0))
b.ring((0.384, -0.020, 0.690), (0.158, 0.158, 0.042), CHARCOAL, 12, 4,
       rot=(0.10, 0.0, 0.0))

b.limb([(-0.290, -0.010, 0.830),
        (-0.335, -0.055, 0.660),
        (-0.330, -0.100, 0.530)],
       [0.086, 0.074, 0.068], MINT, seg=6)                              # ordinary arm
b.ball((-0.330, -0.130, 0.487), (0.090, 0.098, 0.082), GREEN, 8, 5)     # hand

# ------------------------------------------------------------------- the head
b.ball((0.0, -0.045, 1.030), (0.235, 0.215, 0.205), MINT, 10, 6)

# Goblin ears are CONES. Two flattened spheres was the single most obvious
# ellipsoid tell on the whole model - they read as fins glued to his temples.
mirror(lambda s: b.taper((0.236 * s, 0.025, 1.100), 0.086, 0.014, 0.215, GREEN,
                         seg=6, rot=(-0.22, 0.86 * s, 0.0)))

b.ball((0.0, -0.150, 1.005), (0.128, 0.090, 0.072), GREEN, 9, 5)     # snout
b.box((0.0, -0.212, 0.947), (0.062, 0.022, 0.016), CHARCOAL, bevel=0.006)  # grin
mirror(lambda s: b.taper((0.030 * s, -0.205, 0.962), 0.012, 0.003, 0.045,
                         ICE, seg=4, rot=(-0.5, 0, 0)))             # tusks

b.ring((0.0, -0.110, 1.105), (0.228, 0.198, 0.048), GOLD, 14, 4)    # goggle strap
mirror(lambda s: b.taper((0.108 * s, -0.180, 1.105), 0.078, 0.066, 0.082, GOLD,
                         seg=6, rot=(FWD, 0, 0)))                  # goggle barrel
mirror(lambda s: b.ball((0.108 * s, -0.228, 1.105), (0.055, 0.024, 0.055), ICE, 8, 5))

b.finish(out_path(), name="GoblinEngineer", budget="hunter")
