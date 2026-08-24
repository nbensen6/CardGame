"""The Riftling — the one that is not an animal.

Nick, 2026-08-24: non-animal. It is the only beast whose sigil MOVES
(shift_sigil), and it tears rifts rather than swinging at you, so a body with
legs and a face would be a lie about what it does. Instead: broken stone held
apart in a field, with a core drifting between the pieces.

sigil 6, holds at 2 and 4 -> shards at 39% and 59% of the body, core at 80%.
The shards ARE the holds: there is nothing else to stand on, which is the whole
read.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, STONE, PEWTER, GRAPHITE, MIDNIGHT, NAVY,
                    VIOLET, LILAC, IRIS, GOLD, ICE)

b = Build()
H = 3.4
LOW = 0.387 * H       # hold at Height 2
HIGH = 0.593 * H      # hold at Height 4
CORE = 0.80 * H       # the sigil

# Base: a shattered plinth, half sunk, nothing that could be a foot.
b.ball((0.0, 0.0, 0.16), (1.02, 0.94, 0.20), MIDNIGHT, 12, 7)
for i in range(7):
    a = i * math.tau / 7.0
    b.slab((math.cos(a) * 0.74, math.sin(a) * 0.68, 0.30 + (i % 3) * 0.14),
           (0.20, 0.18, 0.30 + (i % 3) * 0.10), NAVY,
           (math.radians(12 * (i % 3 - 1)), 0.0, -a))

# Two floating slabs, the only places a hunter can stand. Tilted, so they read
# as debris held in place rather than as a staircase someone built.
b.slab((0.10, -0.06, LOW), (0.82, 0.66, 0.085), STONE, (math.radians(-5), 0.0, math.radians(9)))
b.slab((0.10, -0.06, LOW - 0.10), (0.62, 0.50, 0.075), GRAPHITE, (0.0, 0.0, math.radians(9)))
b.slab((-0.14, 0.08, HIGH), (0.70, 0.58, 0.080), PEWTER, (math.radians(6), 0.0, math.radians(-13)))
b.slab((-0.14, 0.08, HIGH - 0.09), (0.52, 0.44, 0.070), GRAPHITE, (0.0, 0.0, math.radians(-13)))

# Smaller shards orbiting between them: the field is doing the holding.
for i in range(9):
    a = i * math.tau / 9.0 + 0.4
    z = 0.70 + (i / 9.0) * (CORE - 0.95)
    r = 0.86 - (i / 9.0) * 0.22
    b.slab((math.cos(a) * r, math.sin(a) * r * 0.9, z),
           (0.15, 0.13, 0.19), STONE if i % 2 else PEWTER,
           (math.radians(18 * math.sin(a)), math.radians(16 * math.cos(a)), -a))
    b.ball((math.cos(a) * r, math.sin(a) * r * 0.9, z - 0.20),
           (0.045, 0.045, 0.045), VIOLET, 6, 4)

# The rift itself: rings of torn space, edge-on, stacked through the middle.
for z, s, uv in ((1.05, 0.70, VIOLET), (1.72, 0.58, IRIS), (2.32, 0.46, LILAC)):
    b.ring((0.0, 0.0, z), (s, s * 0.92, 0.10), uv, 20, 5, thickness=0.10)

# The core: it is the sigil, and shift_sigil means it does not stay put.
b.ball((0.0, 0.0, CORE), (0.40, 0.40, 0.46), IRIS, 12, 7)
b.ball((0.0, 0.0, CORE), (0.28, 0.28, 0.33), LILAC, 10, 6)
b.ball((0.0, 0.0, CORE), (0.16, 0.16, 0.19), ICE, 10, 6)
b.ring((0.0, 0.0, CORE), (0.62, 0.62, 0.12), GOLD, 18, 5, thickness=0.08)
b.ring((0.0, 0.0, CORE + 0.02), (0.50, 0.50, 0.10), GOLD, 18, 5,
       thickness=0.07, rot=(math.radians(64), 0.0, 0.0))

b.finish(out_path(), height=H, name="Riftling")
