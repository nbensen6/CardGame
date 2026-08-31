"""Where the Flicker Stag is fought: old woodland, the light coming through in pieces.

Generated to give every beast a place to stand — the fourteen the cloud routine
added had no ground of their own and were still fighting on the blank disc. Hand
edits are welcome and will not be overwritten; this file is the source now.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, SAND, TAN, WHEAT, CREAM, CLAY, BROWN, UMBER, STONE,
                    PEWTER, SLATE, GRAPHITE, CHARCOAL, ICE, MINT, GREEN)

e = Env(seed=83)

e.ground(BROWN, rim=UMBER, dish=0.20)
e.apron(UMBER, out=2.50, drop=0.60)

# The wall. Without one a fight happens on a disc in an open sky and reads as a
# diorama on a plate.
e.enclose("forest")

e.scatter(11, lambda p, r, rng: e.tree(p, r, BROWN, GREEN), near=3.4, far=5.8,
          arc=BACK, size=0.80)
e.scatter(8, lambda p, r, rng: e.stump(p, r), near=2.3, far=5.2, arc=ANY, size=0.34)
e.scatter(16, lambda p, r, rng: e.ball((p.x, p.y, r * 0.28),
                                       (r * 0.9, r * 0.8, r * 0.5),
                                       MINT if rng.random() < 0.4 else GREEN, 6, 4),
          near=2.1, far=5.6, size=0.26)

e.done(out_path(), name="FlickerStagGround")
