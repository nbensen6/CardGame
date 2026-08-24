"""The Mountain Climbers — "Roped: the ally climbs with you."

Stocky and wide, and the only hunter carrying gear: a rope across the chest and
a lamp on the helmet. The rope is the character — it is what the class does.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, BLUE, INDIGO, TAN, CREAM, PEACH, BROWN,
                    UMBER, AMBER, WHITE, CHARCOAL, CLAY)

b = Build()

for side in (-1, 1):
    b.ball((0.19 * side, -0.06, 0.075), (0.155, 0.235, 0.075), BROWN, 10, 6)   # boot
    b.ball((0.175 * side, 0.02, 0.30), (0.125, 0.135, 0.215), UMBER, 10, 6)    # leg
    b.ball((0.335 * side, -0.02, 0.80), (0.105, 0.105, 0.235), BLUE, 10, 6,
           (0.0, math.radians(11 * side), 0.0))                                 # arm
    b.ball((0.375 * side, -0.09, 0.58), (0.105, 0.115, 0.095), CREAM, 10, 6)   # mitt

b.ball((0.0, 0.0, 0.80), (0.335, 0.275, 0.335), BLUE, 12, 7)        # torso
b.ball((0.0, 0.30, 0.86), (0.235, 0.155, 0.265), CLAY, 10, 6)       # pack
b.slab((0.0, 0.40, 0.86), (0.105, 0.045, 0.155), UMBER)             # pack flap
b.ring((0.0, -0.055, 0.83), (0.315, 0.265, 0.075), TAN, 20, 5)      # coiled rope
b.ring((0.0, -0.055, 0.71), (0.295, 0.250, 0.070), TAN, 20, 5)
b.slab((0.0, -0.245, 0.77), (0.055, 0.045, 0.075), CHARCOAL)        # carabiner

b.ball((0.0, -0.035, 1.20), (0.225, 0.215, 0.215), PEACH, 12, 7)    # head
b.ball((0.0, -0.115, 1.13), (0.165, 0.135, 0.115), CREAM, 10, 6)    # beard
b.ball((0.0, -0.02, 1.33), (0.255, 0.245, 0.165), AMBER, 12, 7)     # helmet
b.slab((0.0, -0.22, 1.30), (0.115, 0.055, 0.035), AMBER)            # brim
b.ball((0.0, -0.235, 1.335), (0.062, 0.052, 0.062), WHITE, 8, 5)    # lamp
for side in (-1, 1):
    b.ball((0.085 * side, -0.185, 1.215), (0.040, 0.036, 0.040), CHARCOAL, 8, 5)
    b.slab((0.245 * side, -0.02, 1.28), (0.030, 0.115, 0.060), INDIGO)   # chin strap

b.finish(out_path(), name="MountainClimbers")
