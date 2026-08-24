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

# The stalk runs all the way to the floor FIRST, so the coil reads as wound
# around something. Three separate hoops over empty air read as three hoops.
b.ball((0.0, 0.0, 0.50), (0.155, 0.155, 0.52), GREEN, 12, 7)      # stalk
for z, r in [(0.045, 0.40), (0.125, 0.335), (0.205, 0.275), (0.285, 0.220)]:
    b.ring((0.0, 0.0, z), (r, r * 0.92, 0.085), GREEN, 18, 5)
b.ball((0.0, -0.02, 0.92), (0.245, 0.225, 0.235), MINT, 12, 7)    # seed pod
for side in (-1, 1):                                              # thorns
    for z in (0.52, 0.72):
        b.slab((0.145 * side, 0.0, z), (0.075, 0.030, 0.026), CHARCOAL,
               (0.0, math.radians(28 * side), 0.0))

# The bloom. Petals sit BEHIND and above the head as a halo — ringed at head
# height they stuck out level with the face and read as ears.
for i in range(7):
    a = math.pi * (0.15 + 0.70 * i / 6.0)
    b.ball((math.cos(a) * 0.285, 0.075 + math.sin(a) * 0.10, 1.36 + math.sin(a) * 0.16),
           (0.125, 0.075, 0.135), LILAC, 8, 5, (math.radians(-30.0), 0.0, 0.0))
b.ball((0.0, -0.03, 1.30), (0.245, 0.235, 0.255), VIOLET, 12, 7)
b.ball((0.0, -0.20, 1.32), (0.115, 0.115, 0.100), ORCHID, 10, 6)  # pollen sac
for side in (-1, 1):
    b.ball((0.115 * side, -0.185, 1.375), (0.058, 0.058, 0.058), GOLD, 8, 5)
    b.ball((0.128 * side, -0.235, 1.383), (0.026, 0.026, 0.020), CHARCOAL, 6, 4)
    # Tendril arms — long, thin, and drooping, so the silhouette is all verticals.
    b.ball((0.235 * side, -0.04, 0.90), (0.058, 0.058, 0.215), GREEN, 8, 5,
           (0.0, math.radians(26 * side), 0.0))
    b.ball((0.335 * side, -0.05, 0.66), (0.050, 0.050, 0.175), MINT, 8, 5,
           (0.0, math.radians(12 * side), 0.0))
    b.ball((0.375 * side, -0.06, 0.50), (0.054, 0.054, 0.054), LILAC, 8, 5)

b.finish(out_path(), name="VineWeaver")
