"""Where the Boulder Ram is fought: a boulder field it is indistinguishable from until it moves.

Generated to give every beast a place to stand — the fourteen the cloud routine
added had no ground of their own and were still fighting on the blank disc. Hand
edits are welcome and will not be overwritten; this file is the source now.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, SAND, TAN, WHEAT, CREAM, CLAY, BROWN, UMBER, STONE,
                    PEWTER, SLATE, GRAPHITE, CHARCOAL, ICE, MINT, GREEN)

e = Env(seed=48)

e.ground(STONE, rim=GRAPHITE, dish=0.20)
e.apron(GRAPHITE, out=2.50, drop=0.60)

# The wall. Without one a fight happens on a disc in an open sky and reads as a
# diorama on a plate.
e.enclose("crag")

e.scatter(12, lambda p, r, rng: e.rock(p, r, SLATE), near=2.8, far=5.6,
          arc=BACK, size=0.58)
e.scatter(14, lambda p, r, rng: e.rock(p, r, GRAPHITE), near=2.2, far=5.7,
          arc=ANY, size=0.22)
e.scatter(8, lambda p, r, rng: e.shard(p, r, SLATE, lean=0.26),
          near=3.8, far=5.8, arc=BACK, size=0.72)

e.done(out_path(), name="BoulderRamGround")
