"""Where the Crag Pup is fought: a scree slope below a broken ridge.

The first beast in a run, so the ground has to say "outdoors, high up, stony"
without competing with the creature. Everything here is the same grey family as
the Pup itself, because it IS the same rock — the joke of the beast is that it
is a piece of this hillside that got up.

Read at a glance: a pale gravel floor, boulders sunk into it, and a ring of
taller slabs at the back that the camera catches behind the beast's shoulders.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, SAND, TAN, WHEAT, CLAY, BROWN, UMBER, STONE,
                    PEWTER, SLATE, GRAPHITE, MINT, GREEN)

e = Env(seed=11)

# The floor, dished so the fight happens in a hollow rather than on a plate.
e.ground(CLAY, rim=UMBER, dish=0.22)
e.apron(UMBER, out=2.50, drop=0.62)

# The wall. Without one a fight happens on a disc in an open sky and reads
# as a diorama on a plate: the ridge this hillside broke off.
e.enclose("crag")

# Gravel: flat chips lying in drifts, densest where the ground dips.
e.scatter(26, lambda p, r, rng: e.box((p.x, p.y, 0.03),
                                      (r * 0.30, r * 0.24, 0.035),
                                      BROWN if rng.random() < 0.5 else UMBER,
                                      bevel=0.0,
                                      rot=(0, 0, rng.random() * math.tau)),
          near=1.9, far=5.7, size=0.26)

# Boulders. Anything with height goes BEHIND the beast — see env.BACK. On the
# front rim it is not scenery, it is a wall between the camera and the fight.
e.scatter(10, lambda p, r, rng: e.rock(p, r, SLATE), near=3.1, far=5.6,
          arc=BACK, size=0.62)
e.scatter(10, lambda p, r, rng: e.rock(p, r, GRAPHITE), near=2.4, far=5.6,
          arc=ANY, size=0.22)

# The broken ridge: slabs on end, all leaning the same way, as if something
# shoved them. A ring of upright stones at even angles reads as a monument.
e.scatter(10, lambda p, r, rng: e.shard(p, r, SLATE, lean=0.22),
          near=4.2, far=5.9, arc=BACK, size=0.85)
e.scatter(5, lambda p, r, rng: e.shard(p, r, GRAPHITE, lean=0.30),
          near=3.2, far=4.8, arc=BACK, size=0.5)

# The only living things up here: scrub in the lee of the bigger rocks.
e.scatter(9, lambda p, r, rng: e.ball((p.x, p.y, r * 0.30),
                                      (r * 0.9, r * 0.8, r * 0.5),
                                      MINT if rng.random() < 0.4 else GREEN, 6, 4),
          near=2.6, far=5.5, size=0.24)

e.done(out_path(), name="CragPupGround")
