"""Where the Riptide Eel is fought: tidal flats, cut through with channels.

Generated to give every beast a place to stand — the fourteen the cloud routine
added had no ground of their own and were still fighting on the blank disc. Hand
edits are welcome and will not be overwritten; this file is the source now.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, SAND, TAN, WHEAT, CREAM, CLAY, BROWN, UMBER, STONE,
                    PEWTER, SLATE, GRAPHITE, CHARCOAL, ICE, MINT, GREEN)

e = Env(seed=111)

e.ground(SLATE, rim=GRAPHITE, dish=0.20)
e.apron(GRAPHITE, out=1.35, drop=0.60)

# The wall. Without one a fight happens on a disc in an open sky and reads as a
# diorama on a plate.
e.enclose("reed")

e.pool((0.0, 1.5, 0.0), 2.4, ICE, rim=UMBER)
e.scatter(18, lambda p, r, rng: e.reed(p, r), near=2.6, far=5.8, arc=ANY, size=0.62)
e.scatter(9, lambda p, r, rng: e.rock(p, r, SLATE), near=2.4, far=5.5,
          arc=ANY, size=0.26)

e.done(out_path(), name="RiptideEelGround")
