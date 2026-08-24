"""The Frog — "Nimble: climbs fast and tags the weak point, but hits soft."

Squat and wide-mouthed. The mouth is a RING, not a line: a frog's jaw wraps most
of the way round its head, so the back of the ring buries itself in the body and
only the grin shows.
"""
import sys, os, math, mathutils
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import Build, out_path, GREEN, MINT, CREAM, GOLD, CHARCOAL

b = Build()

b.ball((0.00,  0.00, 0.72), (0.44, 0.40, 0.46), GREEN, 10, 6)   # body
b.ball((0.00, -0.05, 1.26), (0.44, 0.42, 0.34), GREEN, 10, 6)   # head
b.ball((0.00, -0.24, 0.62), (0.30, 0.24, 0.32), CREAM,  8, 5)   # belly
b.ring((0.0, -0.05, 1.10), (0.400, 0.381, 0.55), CHARCOAL, 14, 4,
       thickness=0.052)                                          # mouth

for sx in (-1, 1):
    eye = mathutils.Vector((0.235 * sx, -0.120, 1.520))
    look = mathutils.Vector((0.34 * sx, -0.86, 0.38)).normalized()
    b.ball(eye, (0.160, 0.160, 0.160), GOLD, 8, 5)
    b.ball(eye + look * 0.105, (0.078, 0.078, 0.052), CHARCOAL, 6, 4)   # slit pupil
    b.ball((0.360 * sx,  0.090, 0.420), (0.180, 0.280, 0.260), GREEN, 7, 4)  # haunch
    b.ball((0.310 * sx, -0.045, 0.235), (0.135, 0.150, 0.185), GREEN, 6, 4)  # shin
    b.ball((0.265 * sx, -0.210, 0.095), (0.185, 0.300, 0.095), MINT,  6, 4)  # foot
    b.ball((0.345 * sx, -0.160, 0.760), (0.105, 0.105, 0.235), GREEN, 6, 4)  # arm

b.finish(out_path(), name="Frog")
