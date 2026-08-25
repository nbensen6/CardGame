"""The Lightbearer - "Banks Light, mends an ally, then cashes it in for a burst."

Added by the cloud on 2026-08-25 (#47) with no model, so it was wearing the
bunny. This is its body.

The class banks a resource and spends it in one go, so the read is a VESSEL: a
lantern held high on a staff, and a second light already caught in the chest.
Two lights, one stored and one carried, which is the mechanic said in shapes.

Against the rest of the cast it is the silhouette nobody had: a tall narrow
triangle. The Frog is squat, the Ent is a trunk with a canopy, the Climbers are
stocky and wide, the Engineer is small under a big rig - and this one is a robe
flaring to the floor with a point on top and a lamp above that. It is also the
only hunter whose highest point is not part of its body.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, mirror, aim, point, LINEN, CREAM, WHEAT,
                    SAND, TAN, GOLD, AMBER, ORANGE, CHARCOAL, GRAPHITE, UMBER)

UP = (0, 0, 1)

b = Build()

# ------------------------------------------------------------------- the robe
# One cone to the floor. No legs: the flare IS the base, which is what makes the
# silhouette a triangle instead of a stick.
b.taper((0.0, 0.0, 0.44), 0.42, 0.20, 0.88, LINEN, seg=12)
b.taper((0.0, 0.0, 0.055), 0.455, 0.425, 0.11, WHEAT, seg=12)          # hem
# Folds lie ALONG the robe, not out of it. Aimed radially they stuck out 15cm
# each and read as five fins bolted round a cone - the wedge's long axis follows
# `aim`, so the axis that has to point down the robe is the one to aim.
for i in range(5):
    a = -1.25 + i * 0.62
    b.wedge((math.cos(a) * 0.295, math.sin(a) * 0.285, 0.46),
            (0.085, 0.34, 0.030), CREAM, narrow=(0.30, 0.85), bevel=0.0,
            rot=aim((math.cos(a) * 0.24, math.sin(a) * 0.24, -1.0),
                    up=(math.cos(a), math.sin(a), 0.0)))
b.ball((0.0, -0.10, 0.10), (0.115, 0.135, 0.055), TAN, 7, 4)           # one boot

# ------------------------------------------------------------------ the torso
b.ball((0.0, 0.0, 1.02), (0.225, 0.195, 0.215), LINEN, 10, 6)
b.wedge((0.0, 0.075, 1.175), (0.285, 0.215, 0.075), WHEAT,
        narrow=(0.78, 0.70), bevel=0.025)                              # shoulder yoke

# The banked light, sunk INTO the chest. A disc on the surface would read as a
# badge; set back behind a dark rim it reads as something held inside.
b.taper((0.0, -0.155, 1.005), 0.115, 0.098, 0.075, CHARCOAL, seg=10,
        rot=point((0, -1, 0)))
b.taper((0.0, -0.185, 1.005), 0.082, 0.072, 0.045, AMBER, seg=10,
        rot=point((0, -1, 0)))
b.ball((0.0, -0.205, 1.005), (0.048, 0.022, 0.048), GOLD, 8, 5)

# ------------------------------------------------------------------- the hood
# A cone with the face in shadow under it. The dark is doing the work - a face
# modelled in cream would flatten the whole head.
b.taper((0.0, -0.020, 1.395), 0.255, 0.045, 0.42, LINEN, seg=10,
        rot=point((0.0, -0.22, 1.0)))
b.ball((0.0, -0.055, 1.255), (0.190, 0.180, 0.155), CHARCOAL, 9, 5)
mirror(lambda s: b.ball((0.070 * s, -0.185, 1.275), (0.042, 0.030, 0.036),
                        GOLD, 7, 4))
b.wedge((0.0, -0.155, 1.165), (0.175, 0.115, 0.048), CREAM,
        narrow=(0.70, 0.65), bevel=0.020)                              # collar

# ------------------------------------------------------------------- the staff
# Held out from the body, so the lamp is clear of the silhouette rather than
# tangled in it.
b.limb([(0.0, -0.030, 1.145),
        (-0.175, -0.115, 1.070),
        (-0.245, -0.150, 0.960)],
       [0.062, 0.052, 0.046], LINEN, seg=6)                            # arm
b.ball((-0.255, -0.160, 0.925), (0.058, 0.058, 0.052), CREAM, 7, 4)    # hand
b.taper((-0.285, -0.165, 1.020), 0.028, 0.024, 1.24, UMBER, seg=6,
        rot=point((0.0, 0.0, 1.0)))                                    # shaft
b.ring((-0.285, -0.165, 0.955), (0.055, 0.055, 0.030), GOLD, 10, 4, thickness=0.30)

# ------------------------------------------------------------------ the lamp
# A cage, not a blob: four uprights with the light visible between them. It is
# the highest point on the model and the only thing above the hood.
b.box((-0.285, -0.165, 1.585), (0.075, 0.070, 0.022), GOLD, bevel=0.010)
b.box((-0.285, -0.165, 1.800), (0.082, 0.078, 0.026), GOLD, bevel=0.012)
for i in range(4):
    a = math.pi / 4.0 + i * math.pi / 2.0
    b.taper((-0.285 + math.cos(a) * 0.060, -0.165 + math.sin(a) * 0.056, 1.695),
            0.011, 0.011, 0.215, GOLD, seg=4, rot=point(UP))
b.ball((-0.285, -0.165, 1.690), (0.058, 0.055, 0.062), AMBER, 8, 5)
b.ball((-0.285, -0.165, 1.690), (0.030, 0.028, 0.034), ORANGE, 7, 4)
b.taper((-0.285, -0.165, 1.852), 0.030, 0.006, 0.075, GOLD, seg=5, rot=point(UP))

# --------------------------------------------------------------- the free hand
# Open, palm up, with the second light already sitting in it.
b.limb([(0.165, -0.040, 1.145),
        (0.320, -0.150, 1.030),
        (0.372, -0.255, 0.955)],
       [0.060, 0.050, 0.045], LINEN, seg=6)
b.ball((0.378, -0.278, 0.940), (0.066, 0.074, 0.040), CREAM, 7, 4)
b.ball((0.378, -0.282, 0.998), (0.050, 0.050, 0.048), AMBER, 8, 5)
for i in range(3):
    a = 0.5 + i * 2.09
    b.taper((0.378 + math.cos(a) * 0.030, -0.282 + math.sin(a) * 0.028, 1.052),
            0.014, 0.004, 0.085, GOLD, seg=4,
            rot=point((math.cos(a) * 0.45, math.sin(a) * 0.45, 1.0)))

b.finish(out_path(), name="Lightbearer", budget="hunter")
