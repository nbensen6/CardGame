"""The Bramble Hog - a thicket that got up and started rooting around.

Holds at Height 2, sigil at 5.

Not an animal: there is no creature under the brambles, the brambles ARE the
creature. A low broad tangle on four stubby root-legs, quills laid back along it
like a hedge growing in one direction, and a blunt snout that is just where the
thorns get densest. The one flat thing on it is the hold, which is a matted patch
on its back where the thorns have been worn down.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import (out_path, mirror, point, GREEN, MINT, UMBER, BROWN,
                    CHARCOAL, AMBER, GRAPHITE, SLATE)

b = Beast("bramble_hog", height=3.2)

# ------------------------------------------------------------------- the legs
for sx in (-1, 1):
    for sy, lift in ((-1, 0.0), (1, 0.06)):
        b.limb([(0.86 * sx, 0.62 * sy, 1.05 + lift),
                (0.94 * sx, 0.70 * sy, 0.62),
                (0.90 * sx, 0.66 * sy, 0.22)],
               [0.22, 0.18, 0.16], BROWN, seg=6)
        for spread in (-0.55, 0.55):
            b.taper((0.90 * sx, 0.66 * sy, 0.20), 0.085, 0.022, 0.28, UMBER,
                    seg=5, rot=point((spread * sx, 0.30 * sy, -1.0)))

# ------------------------------------------------------------------ the mass
b.ball((0.0,  0.15, 1.55), (1.05, 1.12, 0.78), UMBER, 12, 7)
b.ball((0.0,  0.62, 1.90), (0.84, 0.72, 0.66), BROWN, 10, 6)          # shoulder hump
b.ball((0.0, -0.72, 1.42), (0.72, 0.58, 0.56), BROWN, 10, 6)          # snout mass
b.wedge((0.0, -1.22, 1.28), (0.44, 0.36, 0.26), UMBER,
        narrow=(0.52, 0.46), bevel=0.06)                              # blunt end

# Quills, all laid back the same way - a hedge grows in one direction and a ball
# of spikes in every direction reads as a mine, not as a thicket.
for i in range(26):
    a = (i * 2.399) % math.tau                       # golden angle: no rosette
    t = 0.25 + 0.72 * ((i * 0.37) % 1.0)
    x = math.cos(a) * 0.92 * (1.0 - 0.35 * t)
    y = -0.55 + 1.55 * t
    z = 1.55 + 0.72 * math.sin(1.1 + 1.6 * t)
    b.taper((x, y, z), 0.070, 0.010, 0.52 + 0.24 * t, CHARCOAL, seg=4,
            rot=point((x * 0.5, 0.85, 0.75)))

# ------------------------------------------------------------------ the hold
# A worn patch on its back, sunk into the tangle rather than bolted onto it.
b.shelf(2, (0.0, -0.26), (0.62, 0.46), SLATE, thickness=0.10, drop=0.05)
b.ball((0.0, -0.30, 1.30), (0.68, 0.58, 0.20), MINT, 10, 6)           # matted moss

# ------------------------------------------------------------------ the face
mirror(lambda s: b.ball((0.30 * s, -1.05, 1.62), (0.115, 0.090, 0.100),
                        CHARCOAL, 8, 5))
mirror(lambda s: b.ball((0.31 * s, -1.14, 1.62), (0.066, 0.048, 0.055), AMBER, 7, 4))
b.ball((0.0, 0.05, 2.28), (0.66, 0.72, 0.42), GREEN, 10, 6)           # leaf mat
b.ball((0.0, 0.42, 2.52), (0.44, 0.46, 0.34), MINT, 9, 5)

b.mark(at=(0.0, -0.46, 2.40), size=0.32,
       facing=(0.0, -0.86, 0.50))

b.done(out_path(), name="BrambleHog")
