"""The Crag Pup — the first thing you ever climb.

sigil 4, one hold at Height 2. Hunters are placed at lerp(0.18, 0.80) of the
body's bounding box, so a hold at Height 2 of 4 lands at 49% of the model and
the sigil at 80% — those two numbers are the brief. A beast whose body has no
shelf THERE is a beast you climb by floating.

A boulder cub: stubby, blunt, and mossy, with a slab across its back you can
plainly stand on and a lit crack across the crown to strike.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, STONE, PEWTER, GRAPHITE, CHARCOAL,
                    MINT, GREEN, GOLD, AMBER)

b = Build()
H = 3.0
SHELF = 0.49 * H      # the hold at Height 2
SIGIL = 0.80 * H      # the weak point at Height 4

for sx in (-1, 1):
    for sy, ly in ((-1, -0.62), (1, 0.62)):          # four stubby legs
        b.ball((0.66 * sx, ly, 0.30), (0.30, 0.30, 0.30), PEWTER, 10, 6)
        b.ball((0.72 * sx, ly, 0.10), (0.34, 0.36, 0.11), CHARCOAL, 10, 6)

b.ball((0.0, 0.0, 0.95), (0.98, 1.12, 0.72), STONE, 14, 8)        # boulder body
b.ball((0.0, -0.95, 1.02), (0.62, 0.52, 0.50), PEWTER, 12, 7)     # blunt head
b.ball((0.0, -1.30, 0.86), (0.42, 0.26, 0.28), GRAPHITE, 10, 6)   # snout
for sx in (-1, 1):
    b.ball((0.30 * sx, -1.24, 1.14), (0.14, 0.12, 0.14), AMBER, 10, 6)   # eye
    b.ball((0.30 * sx, -1.32, 1.16), (0.07, 0.06, 0.07), CHARCOAL, 8, 5)

# The hold: a slab shelf across the shoulders, wide enough to read as standable
# from the front, with a lip so it does not look like a painted stripe.
b.slab((0.0, -0.16, SHELF), (0.86, 0.50, 0.075), GRAPHITE)
b.slab((0.0, -0.62, SHELF + 0.06), (0.80, 0.06, 0.10), CHARCOAL)
for sx in (-1, 1):
    b.slab((0.80 * sx, -0.16, SHELF - 0.02), (0.11, 0.44, 0.16), GRAPHITE,
           (0.0, math.radians(14 * sx), 0.0))

b.ball((0.0, 0.34, 1.72), (0.72, 0.78, 0.52), STONE, 12, 7)       # back hump
for sx, sy, r in ((-0.36, 0.62, 0.26), (0.40, 0.20, 0.30), (-0.10, -0.10, 0.22)):
    b.ball((sx, sy, 2.06), (r, r * 1.15, r * 0.42), MINT, 8, 5)   # moss patches
b.ball((0.30, 0.86, 1.86), (0.20, 0.24, 0.16), GREEN, 8, 5)

# The sigil: one gold mark, the same language on every beast, at its Height.
b.ball((0.0, 0.10, SIGIL), (0.40, 0.44, 0.14), GOLD, 12, 7)
b.ball((0.0, 0.10, SIGIL + 0.06), (0.22, 0.24, 0.10), AMBER, 10, 6)

b.finish(out_path(), height=H, name="CragPup")
