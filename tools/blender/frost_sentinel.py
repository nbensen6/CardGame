"""The Frost Sentinel - ice that grew into a shape and stopped.

Holds at Heights 2 and 5, sigil at 7.

Every other beast in the roster is a rounded mass. This one is ANGULAR all the
way through - stacked shards with hard corners and nothing organic on it - so it
reads as different before you can make out a single detail.

It has no face and no limbs. What it has is a core: a lit shard suspended in a
gap in the middle of the column, with the mass held apart around it. The holds
are the flat tops of the shards it is built from, which is the tidiest fit
between the climb data and the shape in the whole set.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import (out_path, mirror, point, ICE, WHITE, SKY, PERIWINKLE,
                    SILVER, STEEL, SLATE, INDIGO, AMBER)

b = Beast("frost_sentinel", height=4.0)

# ------------------------------------------------------------------- the base
b.box((0.0, 0.0, 0.32), (1.15, 1.05, 0.32), STEEL, bevel=0.07, rot=(0, 0, 0.22))
b.box((0.0, 0.0, 0.78), (0.92, 0.86, 0.30), SILVER, bevel=0.06, rot=(0, 0, -0.30))
for i in range(7):                                              # rime spikes
    a = i * math.tau / 7.0 + 0.3
    b.taper((math.cos(a) * 1.02, math.sin(a) * 0.94, 0.40), 0.16, 0.03, 0.86,
            ICE, seg=5, rot=point((math.cos(a) * 0.42, math.sin(a) * 0.42, 1.0)))

# ------------------------------------------------------------- the lower shard
b.box((0.0, 0.0, 1.22), (0.74, 0.70, 0.34), SKY, bevel=0.06, rot=(0, 0, 0.42))
b.shelf(2, (0.0, 0.0), (0.82, 0.76), PERIWINKLE, thickness=0.13, bevel=0.05,
        rot=(0, 0, -0.18))

# --------------------------------------------------------------- the open core
# The column splits and the core hangs in the gap. Three struts hold it apart -
# without them the two halves float and the whole thing reads as two objects.
for i in range(3):
    a = i * math.tau / 3.0 + 0.5
    b.box((math.cos(a) * 0.62, math.sin(a) * 0.58, 1.94),
          (0.14, 0.14, 0.44), SILVER, bevel=0.035,
          rot=(0.0, 0.0, a + math.pi / 2))
b.ball((0.0, 0.0, 1.94), (0.42, 0.40, 0.46), INDIGO, 10, 6)
b.taper((0.0, 0.0, 1.94), 0.30, 0.02, 0.62, AMBER, seg=6, rot=point((0, -0.35, 1)))
b.taper((0.0, 0.0, 1.94), 0.30, 0.02, 0.62, AMBER, seg=6, rot=point((0, 0.35, -1)))

# ------------------------------------------------------------- the upper shard
b.box((0.0, 0.0, 2.42), (0.78, 0.74, 0.30), SKY, bevel=0.06, rot=(0, 0, -0.36))
b.shelf(5, (0.0, 0.0), (0.86, 0.80, ), PERIWINKLE, thickness=0.13, bevel=0.05,
        rot=(0, 0, 0.24))
b.box((0.0, -0.05, 2.98), (0.62, 0.60, 0.42), SILVER, bevel=0.055, rot=(0, 0, 0.14))

# ------------------------------------------------------------------ the crown
for i, (a, lean, tall) in enumerate([(0.4, 0.30, 1.30), (2.0, 0.22, 0.96),
                                     (3.5, 0.34, 1.14), (5.0, 0.20, 0.84)]):
    b.taper((math.cos(a) * 0.44, math.sin(a) * 0.40, 3.30), 0.22, 0.03, tall,
            ICE, seg=5, rot=point((math.cos(a) * lean, math.sin(a) * lean, 1.0)))
b.box((0.0, -0.02, 3.34), (0.50, 0.48, 0.26), WHITE, bevel=0.05, rot=(0, 0, -0.20))

b.foot((0.0, -0.92, 0.62))           # onto the plinth

b.mark(at=(0.0, -0.48, 3.24), size=0.34, facing=(0.0, -1.0, 0.10))

b.done(out_path(), name="FrostSentinel")
