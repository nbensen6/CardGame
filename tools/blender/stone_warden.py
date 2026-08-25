"""The Stone Warden — the first Titan, and a creature rather than a building.

Nick, 2026-08-24: Titans are creatures. So this is an animal made of rock, not
a walking wall: a hunched four-limbed brute, knuckles down, with a head it can
turn to look at you.

Its limiter is `height_split`, which punishes the party for being at different
Heights — so the body is deliberately TWO ZONES with a hard seam: a dark, rough
lower mass and a paler, plated upper one. When the rule bites, the reason is
already on screen.

sigil 6, holds at 2 and 4 -> shelves at 39% and 59% of the body, sigil at 80%.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, STONE, PEWTER, GRAPHITE, CHARCOAL,
                    MIDNIGHT, GREEN, MINT, GOLD, AMBER, SLATE, SILVER)

b = Build()
H = 4.2
HIP = 0.387 * H       # hold at Height 2
SHOULDER = 0.593 * H  # hold at Height 4
SIGIL = 0.80 * H

# --- lower zone: dark, rough, heavy -----------------------------------------
for sx in (-1, 1):
    b.ball((0.92 * sx, 0.72, 0.44), (0.40, 0.42, 0.44), PEWTER, 10, 6)    # haunch
    b.ball((0.96 * sx, 0.70, 0.13), (0.44, 0.50, 0.14), GRAPHITE, 10, 6)  # hind foot
    # knuckle-walking forelimbs: the weight is forward, like a gorilla
    b.ball((1.16 * sx, -0.66, 1.16), (0.42, 0.44, 0.66), PEWTER, 10, 6)
    b.ball((1.22 * sx, -0.78, 0.42), (0.40, 0.42, 0.44), STONE, 10, 6)
    b.ball((1.26 * sx, -0.92, 0.14), (0.46, 0.52, 0.15), GRAPHITE, 10, 6)

b.ball((0.0, 0.36, 1.02), (1.06, 1.02, 0.72), PEWTER, 14, 8)     # hips
b.ball((0.0, -0.10, 1.34), (1.14, 1.10, 0.62), GRAPHITE, 14, 8)  # gut

# The seam. One hard line where the rock changes, so "you two are on different
# halves of this thing" is a thing you can SEE before the limiter says it.
b.ring((0.0, 0.0, HIP + 0.16), (1.24, 1.20, 0.10), CHARCOAL, 22, 5, thickness=0.11)

# The hip shelf: hold at Height 2.
b.slab((0.0, -0.54, HIP), (0.96, 0.44, 0.085), SLATE)
b.slab((0.0, -0.92, HIP + 0.07), (0.90, 0.07, 0.11), GRAPHITE)

# --- upper zone: paler, plated ----------------------------------------------
b.ball((0.0, 0.06, 2.06), (1.10, 1.00, 0.66), STONE, 14, 8)      # chest
b.ball((0.0, 0.52, 2.28), (0.96, 0.72, 0.60), SLATE, 12, 7)      # back plate
for sx in (-1, 1):
    b.ball((0.98 * sx, 0.02, 2.34), (0.44, 0.46, 0.40), SLATE, 10, 6)   # shoulder

# The shoulder shelf: hold at Height 4.
b.slab((0.0, -0.46, SHOULDER), (0.76, 0.40, 0.080), SLATE)
b.slab((0.0, -0.80, SHOULDER + 0.07), (0.72, 0.07, 0.10), GRAPHITE)

# Moss on the weather side, so the thing reads as old and outdoors.
for x, y, z, r in ((-0.52, 0.66, 2.62, 0.30), (0.44, 0.72, 2.40, 0.26),
                   (-0.20, 0.80, 2.02, 0.22), (0.66, 0.40, 1.62, 0.20)):
    b.ball((x, y, z), (r, r * 1.2, r * 0.40), MINT, 8, 5)
b.ball((-0.30, 0.86, 2.80), (0.24, 0.20, 0.14), GREEN, 8, 5)

# --- head: low, forward, and turned toward you ------------------------------
b.ball((0.0, -1.12, 2.86), (0.78, 0.80, 0.64), STONE, 12, 7)
b.ball((0.0, -1.70, 2.72), (0.54, 0.38, 0.38), SILVER, 10, 6)    # brow
b.ball((0.0, -1.84, 2.40), (0.46, 0.30, 0.30), SLATE, 10, 6)     # jaw
for sx in (-1, 1):
    b.ball((0.30 * sx, -1.72, 2.88), (0.16, 0.13, 0.16), AMBER, 10, 6)
    b.ball((0.30 * sx, -1.84, 2.90), (0.080, 0.065, 0.080), CHARCOAL, 8, 5)
    b.ball((0.66 * sx, -0.86, 3.12), (0.15, 0.26, 0.32), SLATE, 8, 5,
           (0.0, math.radians(-22 * sx), 0.0))                   # horns

# The sigil, at its Height: the same gold mark every beast wears.
b.ball((0.0, -1.18, SIGIL), (0.48, 0.44, 0.20), GOLD, 12, 7)
b.ball((0.0, -1.42, SIGIL - 0.04), (0.30, 0.26, 0.14), AMBER, 10, 6)
b.ring((0.0, -1.10, SIGIL - 0.02), (0.60, 0.52, 0.10), AMBER, 18, 5, thickness=0.09)

b.finish(out_path(), height=H, name="StoneWarden")
