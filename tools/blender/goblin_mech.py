"""The Goblin Engineer — "Heavy hitter: builds gadgets to climb."

A small goblin under an oversized rig. The asymmetry IS the read: one ordinary
arm, one enormous mechanical one, so which class this is survives being 40px
tall at a Titan's foot.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, MINT, GREEN, GRAPHITE, PEWTER, STONE,
                    CHARCOAL, PUMPKIN, CARROT, GOLD, ICE, UMBER)

b = Build()

for side in (-1, 1):
    b.ball((0.165 * side, -0.03, 0.070), (0.140, 0.215, 0.070), CHARCOAL, 10, 6)  # boot
    b.ball((0.155 * side, 0.01, 0.275), (0.110, 0.120, 0.195), GRAPHITE, 10, 6)   # leg

b.ball((0.0, 0.0, 0.66), (0.275, 0.235, 0.255), MINT, 12, 7)        # body
b.ball((0.0, -0.175, 0.60), (0.190, 0.075, 0.170), UMBER, 10, 6)    # work apron
b.ball((0.0, 0.29, 0.80), (0.225, 0.150, 0.235), GRAPHITE, 10, 6)   # backpack
b.ball((0.115, 0.375, 0.97), (0.048, 0.048, 0.140), PUMPKIN, 8, 5)  # exhaust pipe
b.ball((0.115, 0.40, 1.11), (0.062, 0.062, 0.045), CARROT, 8, 5)    # pipe cap

# The rig: one arm three times the other, ending in a piston fist. Each joint
# OVERLAPS the last — spaced out at arm's length they read as a rock beside him
# rather than as an arm on him.
b.ball((0.315, 0.02, 0.80), (0.185, 0.190, 0.205), PEWTER, 10, 6)   # shoulder
b.ball((0.375, -0.01, 0.56), (0.155, 0.160, 0.185), STONE, 10, 6)   # forearm
b.ball((0.400, -0.04, 0.32), (0.180, 0.190, 0.150), PEWTER, 10, 6)  # fist
b.ball((0.400, -0.19, 0.32), (0.110, 0.080, 0.095), CARROT, 8, 5)   # piston head
b.ring((0.350, -0.005, 0.685), (0.200, 0.200, 0.050), CHARCOAL, 14, 5)

b.ball((-0.315, -0.02, 0.74), (0.080, 0.080, 0.185), MINT, 8, 5)    # ordinary arm
b.ball((-0.335, -0.07, 0.55), (0.090, 0.100, 0.080), GREEN, 8, 5)   # hand

b.ball((0.0, -0.045, 1.03), (0.235, 0.215, 0.205), MINT, 12, 7)     # head
for side in (-1, 1):                                                 # ears
    b.ball((0.255 * side, 0.02, 1.09), (0.115, 0.040, 0.070), GREEN, 8, 5,
           (0.0, math.radians(-22 * side), 0.0))
b.ring((0.0, -0.13, 1.075), (0.225, 0.195, 0.055), GOLD, 16, 5)     # goggle strap
for side in (-1, 1):
    b.ball((0.105 * side, -0.205, 1.075), (0.078, 0.055, 0.078), GOLD, 10, 6)
    b.ball((0.105 * side, -0.245, 1.075), (0.056, 0.030, 0.056), ICE, 10, 6)
b.ball((0.0, -0.215, 0.945), (0.070, 0.030, 0.022), CHARCOAL, 8, 5)  # grin

b.finish(out_path(), name="GoblinEngineer")
