"""The Frog - "Nimble: climbs fast and tags the weak point, but hits soft."

Rebuilt on the wider vocabulary (see kenney.py). The first version was sixteen
ellipsoids, and it classified as sixteen ellipsoids: no part of it tapered, so
the legs were sausages, the feet were beans and the muzzle was a ball.

What carries a frog is the stuff spheres cannot say:

  * a **jaw with a floor under it**, so the grin has depth instead of being a
    line painted on a ball;
  * **eyes that bulge THROUGH the skull** - a frog's eyes sit above its head
    line, half-buried, with a lid over them, not beads stuck on the front;
  * **legs that bend**, one limb() each, folded at the knee the way a frog folds;
  * **toes**, splayed. Three per foot is the cheapest read in the whole model.

This model runs about 4% over the hunter budget and that is deliberate. The 56
triangles were taken back once, off the brow and belly balls, and both went
faceted enough to show: the brows turned into hard green cubes poking out of the
eyes at fight distance. A boxy nub on the face costs more than 4% of a budget.
"""
import sys, os, math, mathutils
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import Build, out_path, mirror, GREEN, MINT, CREAM, GOLD, CHARCOAL

FWD = math.pi / 2        # a cone points +Z; this turns it to face -Y

b = Build()

# ---------------------------------------------------------------- the body
b.ball((0.00,  0.00, 0.70), (0.475, 0.425, 0.455), GREEN, 10, 6)   # trunk
b.ball((0.00, -0.205, 0.640), (0.290, 0.240, 0.330), CREAM, 8, 5)   # belly
b.ball((0.00,  0.11, 1.005), (0.365, 0.310, 0.240), GREEN, 8, 5)   # shoulders

# ---------------------------------------------------------------- the head
# A frog's head is not a ball with a nose stuck on it - it is one broad wedge,
# widest at the ears and narrowing to a blunt snout, split across the middle by
# a mouth that runs the whole width. Built as a ball plus a muzzle block it read
# as a brick bolted to a face, so the wedge IS the head and a heavy bevel does
# the rounding.
b.wedge((0.00, -0.10, 1.305), (0.428, 0.400, 0.175), GREEN,
        narrow=(0.58, 0.63), bevel=0.10, seg=2)
# Back of skull. Was (0, 0.19, 1.275) r(0.375, 0.245, 0.250), which reached
# back to y 0.435 — over the whole torso — and topped out at 1.525. Between
# that and the shoulders there was no dip anywhere along the topline, so the
# 64px silhouette came out as one hump and the frog read as a boar. Smaller
# and further forward: it now stops at y 0.265 and tops out at 1.460, under
# the eyes at 1.601, which is the notch.
b.ball((0.00,  0.10, 1.255), (0.360, 0.165, 0.205), GREEN, 8, 5)

# The lower jaw, a shade lighter, slightly inside the upper so the mouth line
# sits in shadow rather than on the silhouette.
b.wedge((0.00, -0.09, 1.148), (0.362, 0.352, 0.068), MINT,
        narrow=(0.64, 0.80), bevel=0.05, seg=2)
b.wedge((0.00, -0.09, 1.212), (0.372, 0.358, 0.014), CHARCOAL,
        narrow=(0.63, 0.90), bevel=0.006)                            # the grin

# Nostrils. Two 2cm dots, and the snout stops being a blank ramp.
mirror(lambda s: b.ball((0.068 * s, -0.462, 1.352), (0.026, 0.026, 0.020),
                        CHARCOAL, 5, 3))


def eye(s):
    """A bulge through the skull, not a bead on it.

    Half the eyeball is inside the head and a green brow caps the BACK of it, so
    the gold still faces you. Capping the top instead buried the eye and the
    frog came out squinting.
    """
    # Out from 0.205 and up from 1.455. At 0.205 the two domes left 0.084 of
    # gap between their inner edges — about 2px at 64 — and the brow balls
    # bridged most of that, so the pair merged into one bump. At 0.250 the
    # gap is 0.224, and the outer edge is 0.413 against a 0.428 skull, so
    # the head is no wider than it was.
    at = mathutils.Vector((0.250 * s, -0.135, 1.485))
    look = mathutils.Vector((0.30 * s, -0.90, 0.31)).normalized()
    b.ball(at, (0.163, 0.163, 0.146), GOLD, 8, 5)
    b.ball(at + mathutils.Vector((0.030 * s, 0.078, 0.062)),
           (0.140, 0.136, 0.112), GREEN, 7, 4)                       # brow
    b.ball(at + look * 0.112, (0.090, 0.090, 0.038), CHARCOAL, 6, 4,
           rot=(0, 0, 0))                                            # wide pupil


def back_leg(s):
    """Haunch, then one bent limb, then three toes.

    The old leg was three spheres in a row and read as a string of beads. A limb
    is one surface: it narrows from thigh to ankle and the knee is a bend in it
    rather than a gap between two lumps.
    """
    b.ball((0.375 * s, 0.10, 0.47), (0.185, 0.30, 0.28), GREEN, 8, 5)   # haunch
    b.limb([(0.365 * s,  0.135, 0.545),
            (0.345 * s, -0.020, 0.285),
            (0.305 * s, -0.150, 0.155),
            (0.285 * s, -0.235, 0.100)],
           [0.150, 0.108, 0.082, 0.072], GREEN, seg=6)
    for i, spread in enumerate((-0.42, 0.0, 0.42)):
        b.taper((0.285 * s, -0.255, 0.075), 0.060, 0.018, 0.30, MINT, seg=5,
                rot=(FWD - 0.16, 0.0, spread * s))


def arm(s):
    """Thin, held ready, three toes. A climber's hand, not a stump."""
    b.limb([(0.300 * s, -0.010, 0.955),
            (0.375 * s, -0.115, 0.790),
            (0.360 * s, -0.235, 0.630),
            (0.335 * s, -0.290, 0.560)],
           [0.098, 0.079, 0.066, 0.060], GREEN, seg=6)
    for spread in (-0.40, 0.0, 0.40):
        b.taper((0.335 * s, -0.305, 0.545), 0.048, 0.015, 0.235, MINT, seg=5,
                rot=(FWD + 0.55, 0.0, spread * s))


mirror(eye)
mirror(back_leg)
mirror(arm)

# Two dark spots on the back. Flat swatches cannot make a texture, but a pair of
# sunk discs in the dark green reads as markings from fight distance.
mirror(lambda s: b.ball((0.175 * s, 0.135, 1.00), (0.105, 0.135, 0.055),
                        MINT, 7, 4))

b.finish(out_path(), name="Frog", budget="hunter")
