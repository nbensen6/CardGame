"""The Vine-Weaver - "Poison feeds the vines; every Wound lifts the ally."

An ENT. A walking tree: root feet planted wide, a trunk for a body, a face cut
into the wood, branch arms, and a canopy for a head. The vines stay - they wind
up the trunk and flower on it - so the name still means something, but the thing
carrying them is a tree rather than a stalk.

This replaces a flower-on-a-stalk that never earned its silhouette. Against the
rest of the cast an Ent reads instantly and from any distance: the Frog is squat,
the Climbers are stocky and wide, the Engineer is small under a big rig, and this
one is TALL with a broad crown and a wide-planted base. A stalk with a bloom on
top was a vertical line with a dot - the same silhouette as a lamp.

The Ent read comes from four things, in order of how much they carry:

  * **The face is IN the wood, not on it.** A heavy brow juts out, the eyes sit
    back under it in shadow, and the mouth is a vertical split in the trunk.
    Eyes stuck on the front of a log read as a puppet.
  * **Feet that grip.** Three root toes each, splayed, reaching the floor at
    different distances.
  * **Arms that fork.** A branch divides; a limb does not.
  * **A canopy wider than the trunk**, so the top of the silhouette is a mass
    and not a point.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, mirror, aim, point, BROWN, UMBER, CLAY,
                    TAN, GREEN, MINT, AMBER, GOLD, LILAC, CHARCOAL)

b = Build()

# ------------------------------------------------------------------- the feet
def leg(s):
    """A root leg, and three toes that reach the ground at different lengths.

    Even toes read as a plastic stand. Uneven ones read as a thing that has been
    standing there a long while.
    """
    b.limb([(0.150 * s,  0.040, 0.640),
            (0.192 * s,  0.010, 0.430),
            (0.205 * s, -0.020, 0.250),
            (0.208 * s, -0.030, 0.170)],
           [0.150, 0.128, 0.112, 0.108], BROWN, seg=6)
    for out, fwd, reach in ((0.85, -0.35, 0.32), (0.10, -1.00, 0.28),
                            (-0.55, 0.55, 0.24)):
        d = (out * s, fwd, -1.15)
        b.taper((0.208 * s + out * s * 0.050, -0.030 + fwd * 0.050, 0.155),
                0.092, 0.030, reach, BROWN, seg=5, rot=point(d))


mirror(leg)

# ------------------------------------------------------------------ the trunk
# Widest at the ground and narrowing as it climbs, with a lean forward at the
# top so he looks down at whatever he is standing over.
# The trunk profile: height, radius, and how far forward the trunk has leaned
# by then. Anything that sits on the trunk - the face, the bark, the vines - has
# to read this rather than carry its own copy, which is how the face ended up
# hanging off the front when the lean was tuned and the face was not.
TRUNK = [(0.480, 0.300,  0.055), (0.700, 0.268,  0.040),
         (0.930, 0.240,  0.010), (1.130, 0.238, -0.020),
         (1.310, 0.205, -0.045), (1.500, 0.150, -0.030)]


def _on_trunk(z):
    for (z0, r0, y0), (z1, r1, y1) in zip(TRUNK, TRUNK[1:]):
        if z <= z1 or (z1, r1, y1) == TRUNK[-1]:
            t = min(1.0, max(0.0, (z - z0) / (z1 - z0)))
            return r0 + (r1 - r0) * t, y0 + (y1 - y0) * t
    return TRUNK[-1][1], TRUNK[-1][2]


def trunk_r(z):
    """The trunk's radius at a height, so anything wound round it can follow.

    The vines were laid on a cone of their own and drifted through the trunk
    wall as they climbed - outside it low down, buried inside it up top - which
    came out as a row of disconnected green shelves rather than as a vine.
    """
    return _on_trunk(z)[0]


def trunk_y(z):
    """How far forward the trunk has leaned by that height."""
    return _on_trunk(z)[1]


b.limb([(0.000, y, z) for z, _, y in TRUNK], [r for _, r, _ in TRUNK],
       BROWN, seg=10)

# Bark. Thin slats down the trunk, each turned a little off true - the cheapest
# way to say "wood" when a flat swatch cannot carry a texture.
for i, (z, a, h) in enumerate([(0.60, 0.5, 0.155), (0.72, 4.3, 0.170),
                               (0.99, 3.6, 0.130)]):
    r = trunk_r(z) - 0.012
    b.box((math.cos(a) * r, math.sin(a) * r + trunk_y(z), z),
          (0.052, 0.030, h), UMBER, bevel=0.012,
          rot=(0.0, 0.0, a + math.pi / 2))

# ------------------------------------------------------------------- the arms
def arm(s):
    """A branch that FORKS. One tube is a limb; two tubes off one is a branch."""
    main = [(0.190 * s,  0.010, 1.060),
            (0.400 * s, -0.030, 1.030),
            (0.560 * s, -0.090, 0.900),
            (0.590 * s, -0.130, 0.740)]
    b.limb(main, [0.105, 0.082, 0.062, 0.050], BROWN, seg=6)
    b.limb([(0.400 * s, -0.030, 1.030),
            (0.520 * s, -0.020, 1.140),
            (0.575 * s, -0.030, 1.245)],
           [0.058, 0.044, 0.034], BROWN, seg=5)                     # upper fork
    for spread in (-0.5, 0.5):                                       # fingers
        b.taper((0.592 * s, -0.140, 0.712), 0.038, 0.008, 0.185, BROWN, seg=4,
                rot=point((spread * s, -0.45, -1.0)))
    # foliage where a branch would actually carry it
    b.ball((0.545 * s, -0.030, 1.295), (0.118, 0.108, 0.098), GREEN, 7, 4)
    b.ball((0.478 * s, -0.078, 0.960), (0.104, 0.096, 0.086), MINT, 7, 4)


mirror(arm)

# -------------------------------------------------------------------- the face
# Cut INTO the trunk. The brow is the whole trick: it juts out over the eyes so
# they sit in their own shadow, which is what makes a log look like it is
# looking at you.
b.wedge((0.000, -0.228, 1.212), (0.196, 0.100, 0.040), UMBER,
        narrow=(0.74, 0.50), bevel=0.018)                            # brow
mirror(lambda s: b.ball((0.096 * s, -0.196, 1.138), (0.070, 0.060, 0.058),
                        CHARCOAL, 7, 4))                             # socket
mirror(lambda s: b.ball((0.098 * s, -0.236, 1.136), (0.044, 0.034, 0.044),
                        AMBER, 7, 4))                                # eye
mirror(lambda s: b.ball((0.102 * s, -0.256, 1.138), (0.019, 0.014, 0.019),
                        GOLD, 6, 4))                                 # glint

# A split, not a slot. The first pass cut it 3cm wide and it vanished at any
# distance; a mouth has to survive the model being 40px tall.
b.box((0.000, -0.231, 0.995), (0.046, 0.030, 0.125), CHARCOAL, bevel=0.010)

# ------------------------------------------------------------------ the canopy
# Wider than the trunk, or the silhouette comes to a point and he reads as a
# post. Uneven sizes and heights - a hedge is a shape, a tree is a mass.
for x, y, z, rx, ry, rz, col in [
        (0.000, -0.020, 1.600, 0.305, 0.270, 0.172, GREEN),
        (-0.235, -0.055, 1.522, 0.200, 0.180, 0.132, MINT),
        (0.245, -0.040, 1.538, 0.210, 0.184, 0.136, GREEN),
        (0.050,  0.175, 1.515, 0.192, 0.172, 0.126, MINT),
        (0.000, -0.030, 1.722, 0.186, 0.166, 0.110, MINT)]:
    b.ball((x, y, z), (rx, ry, rz), col, 6, 4)
for i, a in enumerate((0.7, 4.1)):                              # bare twigs
    b.taper((math.cos(a) * 0.150, math.sin(a) * 0.135 - 0.03, 1.620), 0.026,
            0.006, 0.230, BROWN, seg=4,
            rot=point((math.cos(a) * 0.55, math.sin(a) * 0.55, 1.0)))

# ------------------------------------------------------------------ the vines
# Still the Vine-Weaver. Two vines wind up the trunk on a helix that follows its
# taper, and flower where they reach.
for turn, lift, col in ((0.35, 0.0, GREEN), (math.pi + 0.35, 0.05, MINT)):
    path = []
    for i in range(9):
        t = i / 8.0
        z = 0.500 + 0.360 * t + lift
        r = trunk_r(z) + 0.030                  # ON the wall, not through it
        a = turn + t * 1.65 * math.tau
        path.append((math.cos(a) * r, math.sin(a) * r * 0.94 + trunk_y(z), z))
    # seg=6, not 4. A four-sided tube this thin catches light on one facet at a
    # time as the helix turns, and the vine reads as a row of flat green plates.
    # Thickening it instead made it worse - a fat helix reads as diagonal bands.
    # A thin cord with leaves ON it is what says vine.
    b.limb(path, [0.040 - 0.013 * (i / 8.0) for i in range(9)], col, seg=6,
           cap=False)
    for at in (1, 4, 7):
        px, py, pz = path[at]
        b.ball((px * 1.16, py * 1.16, pz + 0.030), (0.062, 0.058, 0.026),
               col, 5, 3)
    b.ball(path[-1], (0.055, 0.052, 0.046), LILAC, 6, 4)

b.finish(out_path(), name="VineWeaver", budget="hunter")
