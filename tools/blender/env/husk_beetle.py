"""Where the Husk Beetle is fought: a granary floor, long emptied.

Generated to give every beast a place to stand — the fourteen the cloud routine
added had no ground of their own and were still fighting on the blank disc. Hand
edits are welcome and will not be overwritten; this file is the source now.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, SAND, TAN, WHEAT, CREAM, CLAY, BROWN, UMBER, STONE,
                    PEWTER, SLATE, GRAPHITE, CHARCOAL, ICE, MINT, GREEN)

e = Env(seed=104)

e.ground(TAN, rim=CLAY, dish=0.20)
e.apron(CLAY, out=1.35, drop=0.60)

# The wall. Without one a fight happens on a disc in an open sky and reads as a
# diorama on a plate.
e.enclose("ruin")

e.scatter(9, lambda p, r, rng: e.pillar(p, r, PEWTER, cap=STONE),
          near=3.2, far=5.7, arc=BACK, size=0.46)
e.scatter(20, lambda p, r, rng: e.slabs(p, r, STONE, n=3), near=1.9, far=5.5,
          arc=ANY, size=0.50)
e.scatter(10, lambda p, r, rng: e.rock(p, r, GRAPHITE), near=2.4, far=5.6,
          arc=ANY, size=0.24)

e.done(out_path(), name="HuskBeetleGround")
