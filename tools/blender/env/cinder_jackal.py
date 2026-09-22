"""Where the Cinder Jackal is fought: burnt ground, still smoking where it has walked.

Generated to give every beast a place to stand — the fourteen the cloud routine
added had no ground of their own and were still fighting on the blank disc. Hand
edits are welcome and will not be overwritten; this file is the source now.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, SAND, TAN, WHEAT, CREAM, CLAY, BROWN, UMBER,
                    SLATE, GRAPHITE, CHARCOAL, ICE, MINT, GREEN, RUST)

e = Env(seed=62)

e.ground(UMBER, rim=CHARCOAL, dish=0.20)
e.apron(CHARCOAL, out=2.50, drop=0.60)

# The wall. Without one a fight happens on a disc in an open sky and reads as a
# diorama on a plate.
#
# Default "cliff" is SLATE/PEWTER - a cool blue-grey built for a generic
# canyon. It fills nearly the whole fight-camera frame (see
# design/progress/cinder_jackal_ground.md pass 1), which made this read as
# any other quarry: the wall showed no trace of "burnt ground, still
# smoking" while the UMBER floor it hides tried to say exactly that. CHARCOAL
# matches the apron/rim already in use, so the wall and the ground it
# encloses are finally the same material family; RUST on the accent band -
# the same hot row as the jackal's own TANGERINE/AMBER (design/adding-
# detail.md) - reads as a smouldering lip across the top of each charred
# block instead of a cold stone one.
e.enclose("cliff", uv=CHARCOAL, accent=RUST)

# PEWTER and STONE are the other half of the same cool-grey mismatch the wall
# had: a ring of blue-grey boulders and flagstones sitting between the warm
# UMBER floor and the now-CHARCOAL wall, undoing the point of recolouring
# either. BROWN and CLAY sit on the same warm row as UMBER (kenney.py's
# peach/clay/brown/umber gradient) so the boulders and slabs read as the
# same scorched rock as the ground and wall, just a shade lighter where the
# light catches them, rather than a different material dropped in from a
# colder biome.
e.scatter(10, lambda p, r, rng: e.rock(p, r, BROWN), near=2.9, far=5.6,
          arc=BACK, size=0.54)
e.scatter(16, lambda p, r, rng: e.slabs(p, r, CLAY, n=2), near=2.0, far=5.4,
          arc=ANY, size=0.42)
e.scatter(9, lambda p, r, rng: e.rock(p, r, CHARCOAL), near=2.4, far=5.7,
          arc=ANY, size=0.20)

e.done(out_path(), name="CinderJackalGround")
