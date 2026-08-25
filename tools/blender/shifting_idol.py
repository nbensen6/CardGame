"""The Shifting Idol - a stack of stones that does not agree with itself.

Holds at Heights 2 and 4, sigil at 6.

Six blocks stacked and each turned a different way, so the whole thing is a
column that never lines up. That misalignment IS the design: the overhang where
one block juts past the one under it is the ledge you stand on, so the climb and
the silhouette are the same fact. Nothing else here has that.

A mask on the front, and a violet glow in every gap between the blocks - the
light is what says the stack is held together by something rather than balanced.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import (out_path, mirror, point, STONE, SLATE, PEWTER, GRAPHITE,
                    CHARCOAL, VIOLET, ORCHID, GOLD, AMBER, SILVER)

b = Beast("shifting_idol", height=3.8, span=(0.00, 3.93))

# The stack: (z, half-size, turn, colour). Each block turned off the last.
BLOCKS = [(0.36, (1.10, 1.02, 0.36),  0.00, PEWTER),
          (0.92, (0.94, 0.98, 0.28),  0.46, STONE),
          (1.34, (1.02, 0.90, 0.30), -0.34, SLATE),
          (1.96, (0.86, 0.92, 0.36),  0.62, PEWTER),
          (2.52, (0.94, 0.86, 0.30), -0.20, STONE),
          (3.04, (0.78, 0.80, 0.34),  0.38, SLATE),
          (3.54, (0.58, 0.60, 0.26), -0.52, PEWTER)]
for z, size, turn, col in BLOCKS:
    b.box((0.0, 0.0, z), size, col, bevel=0.07, rot=(0.0, 0.0, turn))

# The glow in every seam. Slightly wider than the blocks, so it shows as a lit
# line all the way round rather than only where two corners happen to align.
for (z0, s0, _, _), (z1, s1, _, _) in zip(BLOCKS, BLOCKS[1:]):
    mid = (z0 + s0[2] + z1 - s1[2]) * 0.5
    w = min(s0[0], s1[0]) * 0.94
    b.box((0.0, 0.0, mid), (w, w * 0.96, 0.045), VIOLET, bevel=0.012)

# The holds: the overhang where a block juts past the one below it. The shelf
# goes ON the block's own top, at the turn it is already sitting at.
b.shelf(2, (0.0, -0.44), (0.76, 0.44), GRAPHITE, thickness=0.075, bevel=0.04,
        rot=(0, 0, -0.34))
b.shelf(4, (0.0, -0.40), (0.66, 0.40), GRAPHITE, thickness=0.070, bevel=0.04,
        rot=(0, 0, -0.20))

# ------------------------------------------------------------------- the mask
b.wedge((0.0, -0.84, 2.60), (0.60, 0.30, 0.44), SILVER,
        narrow=(0.66, 0.72), bevel=0.05)
mirror(lambda s: b.taper((0.26 * s, -1.05, 2.72), 0.115, 0.02, 0.20, CHARCOAL,
                         seg=6, rot=point((0.0, -1.0, 0.10))))          # eye holes
mirror(lambda s: b.ball((0.26 * s, -1.08, 2.72), (0.070, 0.045, 0.070), ORCHID, 7, 4))
b.box((0.0, -1.06, 2.36), (0.28, 0.06, 0.055), CHARCOAL, bevel=0.014)   # mouth slot
mirror(lambda s: b.taper((0.44 * s, -0.55, 3.02), 0.16, 0.03, 0.52, SLATE, seg=5,
                         rot=point((0.34 * s, -0.30, 1.0))))            # mask horns

# ------------------------------------------------------------------ the crown
for i in range(4):
    a = i * math.tau / 4.0 + 0.5
    b.taper((math.cos(a) * 0.34, math.sin(a) * 0.34, 3.72), 0.13, 0.02, 0.42,
            AMBER, seg=5, rot=point((math.cos(a) * 0.28, math.sin(a) * 0.28, 1.0)))

b.foot((0.0, -0.96, 0.70))           # onto the bottom block

b.mark(at=(0.0, -0.72, 3.10), size=0.30, facing=(0.0, -0.96, 0.28))

b.done(out_path(), name="ShiftingIdol")
