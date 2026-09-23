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

# Body/head/snout dropped from the default seg=10,ring=6 (body/head) and 9,5
# (snout) to 8,5 to claw back budget (see "Budget" note below) - the biggest,
# gentlest-curved masses on the model, so fewer segments cost the least here;
# a _sil.png diff against the pre-cut render is pixel-identical at 64px.
b.ball((0.0, 0.0, 0.66), (0.275, 0.235, 0.255), MINT, 8, 5)        # body
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
#
# The compressor was centered at x=0.0 - dead on the goblin's own centerline,
# so it sat behind the head in every view instead of hung off the rig's
# shoulder. Shifted +0.30 in X, with the lid and exhaust it carries moving as
# one piece with it, so nothing mechanical crosses behind the head.
#
# GRAPHITE -> STONE (pass 5): in the actual Cinder Jackal fight, this box sat
# against the beast's own near-black body/wing (sampled in-game: rig pixel
# luminance 18.4 vs jackal-body 4.6, a 13.8-point gap - weaker than the
# weakest boundary the frog's own pass 7 found and fixed, 18.8, on the one
# model half whose whole job is to read as "an enormous rig", per this
# file's own header). GRAPHITE and CHARCOAL are this palette's two darkest
# greys (59.4/56.4 luminance, functionally the same value) and the toon
# shader's shadow band crushes both to near-black against a dark backdrop.
# STONE (114.1) is already this rig's own established colour (upper-arm
# limb, claw box) - no new hue, just moved the biggest box off the two
# darkest ties.
b.box((0.30, 0.278, 0.800), (0.145, 0.098, 0.152), STONE, bevel=0.026)
b.box((0.30, 0.278, 0.960), (0.106, 0.078, 0.030), PEWTER, bevel=0.013)   # lid
b.limb([(0.412, 0.330, 0.880), (0.422, 0.398, 0.995), (0.440, 0.392, 1.088)],
       [0.044, 0.040, 0.036], PUMPKIN, seg=5)  # exhaust; seg 6->5, pass 4 budget
b.taper((0.442, 0.392, 1.128), 0.057, 0.046, 0.078, CARROT, seg=6, bevel=0.010)

b.box((0.346, 0.030, 0.812), (0.122, 0.126, 0.134), PEWTER, bevel=0.024,
      rot=(0.0, 0.10, 0.0))
# Upper arm and wrist limbs were 0.086-0.098 radius bridging boxes with
# 0.12-0.15 half-extents - thin enough that the joints vanished between the
# bigger masses and the rig read as loose boxes rather than one jointed arm.
# Thickened ~1.4x so the limb reads as continuous with the boxes it connects.
#
# seg 6->10 on both (pass 4): the real cause of three passes' "reads as
# scattered blocks" - each limb's hex end-cap pokes out right where it
# meets its box (a box's rotated face never sits parallel to the cap, so no
# amount of embedding the waypoint deeper hides it), and each of the 6
# flat facets caught its own toon-shading band, reading as a sharp zigzag
# crown. Confirmed with a diagnostic recolour - see goblin_mech.md pass 4 -
# and it was NOT the CHARCOAL ring a few lines down, which was the first
# suspect. More segments round the cap into a shallow seam instead.
b.limb([(0.350, 0.020, 0.766), (0.392, -0.030, 0.652), (0.414, -0.062, 0.580)],
       [0.137, 0.120, 0.112], STONE, seg=10)                             # upper arm
b.box((0.416, -0.068, 0.548), (0.086, 0.090, 0.106), PEWTER, bevel=0.020,
      rot=(0.12, 0.14, 0.0))
b.limb([(0.420, -0.076, 0.500), (0.438, -0.100, 0.430), (0.450, -0.118, 0.378)],
       [0.095, 0.106, 0.115], PEWTER, seg=10)                            # wrist
b.box((0.454, -0.128, 0.298), (0.132, 0.138, 0.112), STONE, bevel=0.026,
      rot=(0.18, 0.20, 0.0))
b.taper((0.454, -0.268, 0.298), 0.072, 0.058, 0.130, CARROT, seg=6, rot=(FWD, 0, 0))
for dz in (-0.048, 0.048):                                              # piston rods
    # seg 5->4: at 0.016 radius (a thin rod, not a silhouette-defining mass)
    # the facet is invisible; this and the three balls above claw back the
    # 84-tri budget overage pass 2 didn't touch (goblin_mech.md pass 2).
    b.taper((0.454, -0.208, 0.298 + dz), 0.016, 0.016, 0.190, CHARCOAL, seg=4,
            rot=(FWD, 0, 0))
# minor 4->3 (pass 4): ruled out as the zigzag's cause by the same
# diagnostic recolour above, so its own roundness costs nothing that was
# scored; freed 24 tris toward the two limb caps' seg 6->10 above.
#
# CHARCOAL -> STONE (pass 5): same dark-tie-against-the-jackal fix as the
# compressor box above - this ring is the rig's other big CHARCOAL mass, and
# the same near-black-on-near-black loss applies to it in-fight.
b.ring((0.384, -0.020, 0.690), (0.158, 0.158, 0.042), STONE, 12, 3,
       rot=(0.10, 0.0, 0.0))

b.limb([(-0.290, -0.010, 0.830),
        (-0.335, -0.055, 0.660),
        (-0.330, -0.100, 0.530)],
       [0.086, 0.074, 0.068], MINT, seg=5)             # ordinary arm; pass 4 budget
b.ball((-0.330, -0.130, 0.487), (0.090, 0.098, 0.082), GREEN, 7, 4)     # hand, same

# ------------------------------------------------------------------- the head
b.ball((0.0, -0.045, 1.030), (0.235, 0.215, 0.205), MINT, 8, 5)

# Goblin ears are CONES. Two flattened spheres was the single most obvious
# ellipsoid tell on the whole model - they read as fins glued to his temples.
mirror(lambda s: b.taper((0.236 * s, 0.025, 1.100), 0.086, 0.014, 0.215, GREEN,
                         seg=6, rot=(-0.22, 0.86 * s, 0.0)))

b.ball((0.0, -0.150, 1.005), (0.128, 0.090, 0.072), GREEN, 8, 5)     # snout
b.box((0.0, -0.212, 0.947), (0.062, 0.022, 0.016), CHARCOAL, bevel=0.006)  # grin
mirror(lambda s: b.taper((0.030 * s, -0.205, 0.962), 0.012, 0.003, 0.045,
                         ICE, seg=4, rot=(-0.5, 0, 0)))             # tusks

# Was a near-flat disc (thickness 0.16 default squashed further by the 0.048
# z-scale): reads as a strap only face-on; `_side.png` shows it as a thin gold
# blade jutting well past the ear, since a flat disc viewed edge-on is just its
# rim. Thickened the tube (thickness 0.16 -> 0.26) and un-flattened it in Z
# (0.048 -> 0.075) so there is a band to see from any angle, and pulled the
# major radius in a touch (0.228/0.198 -> 0.205/0.180) so less of it clears the
# head silhouette. Same 14x4 segments, so no tri cost.
b.ring((0.0, -0.110, 1.105), (0.205, 0.180, 0.075), GOLD, 14, 4,
       thickness=0.26)                                              # goggle strap
mirror(lambda s: b.taper((0.108 * s, -0.180, 1.105), 0.078, 0.066, 0.082, GOLD,
                         seg=5, rot=(FWD, 0, 0)))  # goggle barrel; seg 6->5, pass 4 budget
mirror(lambda s: b.ball((0.108 * s, -0.228, 1.105), (0.055, 0.024, 0.055), ICE, 8, 5))

b.finish(out_path(), name="GoblinEngineer", budget="hunter")
