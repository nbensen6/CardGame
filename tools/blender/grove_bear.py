"""The Grove Bear - a hill that stood up and kept the forest on its back.

Holds at Heights 3 and 5, sigil at 7.

Not a bear and not an animal: a hunched mass of moss-covered stone with long
stone forelimbs it leans on, and no head - only a hollow in the shoulders with
two lights far back inside it. The read is WEIGHT. It is the widest thing in the
roster and the only one whose silhouette is broader than it is tall until the
crown of trees on its back is counted.

The holds are the two boulder shoulders. You climb it the way you would climb a
rockslide, which is the point of it standing next to the Sentinel's clean shards.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import (out_path, mirror, point, STONE, PEWTER, SLATE, GRAPHITE,
                    UMBER, BROWN, GREEN, MINT, CHARCOAL, AMBER)

b = Beast("grove_bear", height=4.0)

# ------------------------------------------------------------- the forelimbs
# Long, planted forward, knuckles down. It leans on these and the whole mass
# hangs behind them.
def foreleg(s):
    b.limb([(1.12 * s, 0.30, 2.30),
            (1.34 * s, -0.30, 1.60),
            (1.40 * s, -0.62, 0.80),
            (1.36 * s, -0.72, 0.30)],
           [0.46, 0.38, 0.33, 0.30], PEWTER, seg=8)
    b.ball((1.36 * s, -0.80, 0.26), (0.42, 0.50, 0.24), GRAPHITE, 9, 5)
    for spread in (-0.6, 0.0, 0.6):
        b.taper((1.36 * s, -1.14, 0.20), 0.11, 0.025, 0.40, CHARCOAL, seg=5,
                rot=point((spread * s, -1.0, -0.35)))


def hindleg(s):
    b.limb([(0.96 * s, 1.30, 1.70),
            (1.10 * s, 1.48, 1.00),
            (1.06 * s, 1.40, 0.34)],
           [0.42, 0.34, 0.30], PEWTER, seg=7)
    b.ball((1.06 * s, 1.24, 0.26), (0.38, 0.46, 0.24), GRAPHITE, 9, 5)


mirror(foreleg)
mirror(hindleg)

# ------------------------------------------------------------------- the mass
b.ball((0.0, 0.62, 1.72), (1.42, 1.55, 1.00), STONE, 12, 7)
b.ball((0.0, -0.35, 1.95), (1.12, 0.90, 0.86), PEWTER, 10, 6)          # chest
b.ball((0.0, 1.45, 2.05), (1.10, 0.95, 0.82), SLATE, 10, 6)            # rump
for i, (a, r, z, w) in enumerate([(0.6, 1.05, 1.30, 0.34), (2.5, 1.15, 1.62, 0.40),
                                  (4.1, 1.10, 1.20, 0.30), (5.6, 1.00, 1.70, 0.36)]):
    b.box((math.cos(a) * r, 0.55 + math.sin(a) * r, z), (w, 0.14, w * 0.62),
          GRAPHITE, bevel=0.04, rot=(0.0, 0.0, a + math.pi / 2))       # rock plates

# ----------------------------------------------------------------- the hollow
# No head. A cave in the shoulders with the lights set deep inside it.
b.taper((0.0, -0.86, 2.42), 0.60, 0.44, 0.46, CHARCOAL, seg=10,
        rot=point((0.0, -1.0, 0.18)))
mirror(lambda s: b.ball((0.24 * s, -0.92, 2.44), (0.100, 0.075, 0.100), AMBER, 7, 4))
mirror(lambda s: b.taper((0.72 * s, -0.62, 2.72), 0.20, 0.035, 0.62, SLATE, seg=5,
                         rot=point((0.42 * s, -0.28, 1.0))))            # brow horns

# ------------------------------------------------------------------ the holds
b.shelf(3, (0.0, -0.52), (0.78, 0.46), PEWTER, thickness=0.085, bevel=0.05)
b.ball((0.0, -0.30, 1.72), (1.02, 0.62, 0.22), MINT, 10, 6)            # moss on it
b.shelf(5, (0.0, -0.05), (0.70, 0.46), PEWTER, thickness=0.080, bevel=0.05)

# ------------------------------------------------------------------ the grove
b.ball((0.0, 0.85, 2.85), (1.15, 1.25, 0.44), GREEN, 12, 7)            # moss bed
for i, (x, y, z, r) in enumerate([(-0.55, 0.60, 3.20, 0.42), (0.50, 1.05, 3.30, 0.46),
                                  (0.05, 1.62, 3.14, 0.38), (0.62, 0.35, 3.06, 0.32)]):
    b.limb([(x, y, 2.90), (x * 1.05, y * 1.02, 3.20), (x * 1.08, y * 1.04, 3.42)],
           [0.11, 0.085, 0.070], BROWN, seg=5)
    b.ball((x * 1.08, y * 1.04, 3.52 + r * 0.30), (r, r * 0.92, r * 0.62),
           MINT if i % 2 else GREEN, 7, 4)

b.foot((1.30, -0.92, 0.40))          # onto a knuckle

# A crest between the shoulders to carry the sigil - the hollow is below it and
# the moss bed behind, and without this the mark hung in the gap between them.
b.wedge((0.0, -0.50, 3.02), (0.74, 0.40, 0.42), PEWTER,
        narrow=(0.64, 0.70), bevel=0.06)
b.mark(at=(0.0, -0.84, 3.10), size=0.36, facing=(0.0, -0.94, 0.34))

b.done(out_path(), name="GroveBear")
