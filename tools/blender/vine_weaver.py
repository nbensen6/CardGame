"""The Vine-Weaver — "Poison feeds the vines; every Wound lifts the ally."

Tall and slender, and rooted rather than standing: a coil of vine for a base, a
stalk for a body, a poison bloom for a head. Read against the other three at a
glance — the Climbers are wide, the Engineer is small under a big rig, and this
one is a line.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, GREEN, MINT, VIOLET, LILAC, GOLD,
                    CHARCOAL, ORCHID)

b = Build()

# A root bulb ON the floor. The first pass stood a tapering stalk on its own
# bottom pole, so she balanced on a spike with three hoops floating round it —
# a plant on a spring rather than a plant in the ground.
b.ball((0.0, 0.0, 0.14), (0.46, 0.44, 0.17), GREEN, 14, 7)
b.ball((0.0, 0.0, 0.30), (0.36, 0.35, 0.20), MINT, 12, 7)
for z, r in [(0.10, 0.44), (0.24, 0.365), (0.37, 0.29)]:
    b.ring((0.0, 0.0, z), (r, r * 0.94, 0.075), GREEN, 20, 5)   # coil, hugging it
for a_i in range(5):                                            # roots gripping
    a = a_i * math.tau / 5.0 + 0.3
    b.ball((math.cos(a) * 0.42, math.sin(a) * 0.40, 0.055),
           (0.115, 0.185, 0.055), GREEN, 8, 5, (0.0, 0.0, -a))

b.ball((0.0, 0.0, 0.62), (0.185, 0.185, 0.30), GREEN, 12, 7)     # stalk
b.ball((0.0, -0.02, 0.95), (0.30, 0.275, 0.30), MINT, 14, 8)     # seed pod
for side in (-1, 1):
    b.slab((0.165 * side, 0.0, 0.60), (0.075, 0.030, 0.026), CHARCOAL,
           (0.0, math.radians(28 * side), 0.0))                  # thorns

    # Vines that leave the POD and curve down, instead of leaf shapes hanging in
    # the air beside her.
    for i, (dx, dz, sc) in enumerate([(0.26, 0.94, 0.075), (0.40, 0.76, 0.068),
                                      (0.46, 0.56, 0.060), (0.44, 0.40, 0.052)]):
        b.ball((dx * side, -0.03, dz), (sc, sc, sc * 1.5), GREEN if i % 2 else MINT, 8, 5)
    b.ball((0.42 * side, -0.04, 0.29), (0.058, 0.058, 0.058), LILAC, 8, 5)

# The bloom, its petals set BACK so the face reads as a face rather than as the
# middle of a flower.
for i in range(7):
    a = math.pi * (0.18 + 0.64 * i / 6.0)
    b.ball((math.cos(a) * 0.275, 0.115 + math.sin(a) * 0.085, 1.30 + math.sin(a) * 0.145),
           (0.125, 0.080, 0.140), LILAC, 8, 5, (math.radians(-34.0), 0.0, 0.0))
b.ball((0.0, -0.05, 1.28), (0.265, 0.255, 0.265), VIOLET, 14, 8)
b.ball((0.0, -0.235, 1.28), (0.115, 0.115, 0.100), ORCHID, 10, 6)  # pollen sac
for side in (-1, 1):
    b.ball((0.125 * side, -0.205, 1.335), (0.062, 0.062, 0.062), GOLD, 8, 5)
    b.ball((0.138 * side, -0.255, 1.343), (0.028, 0.028, 0.022), CHARCOAL, 6, 4)

b.finish(out_path(), name="VineWeaver")
