"""The Gloom Moth - the elite-pool beast that does not want to fight you, it
wants your DECK.

Ledges at Height 2 and 4, sigil at 5. Its bent rule is `curse`: rather than
hit hard, it dusts a hunter with two Bruised Grips a turn and chips Block with
`frail` between doses - so the fight is a race to end it before your own hand
clogs, not a race against a damage number. None of the other elites (Mire
Snapper, Frost Sentinel, Grove Bear, Shifting Idol) make curse their whole
idiom; here it's the entire pattern rather than one move among heavy hitters.

A big fuzzy-thorax moth standing on six thin legs, its folded wings stepping
up the back like a tent - the two wing-panels ARE the two ledges - antennae
and a dust-pale marking on the head where the sigil sits, the highest point
on the body.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, STONE, PEWTER, SLATE, GRAPHITE, \
                   CHARCOAL, LILAC, VIOLET, IRIS, ORCHID, CLAY

b = Beast("gloom_moth", height=3.2, span=(-0.01, 2.76))

# ------------------------------------------------------------------- the legs
# Three pairs, thin and insectile, planted wide for a low stance under a heavy
# thorax - a moth's legs are hair-thin, so these are the thinnest limbs in the
# cast on purpose, not an oversight.
for sx in (-1, 1):
    for ly, lh in ((-0.80, 0.72), (-0.06, 0.86), (0.66, 0.66)):
        b.limb([(0.44 * sx, ly, lh), (0.78 * sx, ly * 0.92, lh * 0.46),
               (0.70 * sx, ly * 0.86, 0.10)], [0.075, 0.05, 0.03],
               GRAPHITE, seg=5)
        b.taper((0.70 * sx, ly * 0.86, 0.06), 0.03, 0.008, 0.14, CHARCOAL,
                seg=4, rot=point((0.30 * sx, 0.08, -1.0)))

# ------------------------------------------------------------------ the mass
b.ball((0.0, -0.18, 1.28), (0.88, 1.02, 0.80), STONE, 12, 7)          # thorax
b.ball((0.0, 0.88, 1.02), (0.56, 0.62, 0.50), PEWTER, 10, 6)          # abdomen
b.ball((0.0, 1.42, 0.86), (0.32, 0.34, 0.30), SLATE, 9, 5)            # tail seg
b.ball((0.0, -1.16, 1.42), (0.40, 0.36, 0.38), GRAPHITE, 10, 6)       # head
b.ball((0.0, -1.02, 1.86), (0.22, 0.20, 0.24), PEWTER, 9, 5)          # forehead crest — hosts the sigil

# Compound eyes - big, glassy, the thing that reads a bug's face as a bug's
# face from across a room.
mirror(lambda s: b.ball((0.26 * s, -1.30, 1.44), (0.15, 0.14, 0.15), IRIS, 9, 5))
mirror(lambda s: b.ball((0.29 * s, -1.34, 1.46), (0.07, 0.06, 0.07), CHARCOAL, 7, 4))

# A short curled proboscis, tucked under the head rather than out in front,
# so it doesn't read as a weapon.
b.taper((0.0, -1.42, 1.20), 0.06, 0.015, 0.30, CLAY, seg=5,
        rot=point((0.10, -0.85, -0.55)))

# Feathery antennae, swept well up and back past the head's own width, curled
# at the tip - moth antennae are the single most identifying silhouette cue,
# so these are built big rather than modest.
mirror(lambda s: b.limb([(0.18 * s, -1.10, 1.72), (0.42 * s, -0.88, 2.10),
                         (0.58 * s, -0.60, 2.36), (0.62 * s, -0.34, 2.46)],
                        [0.05, 0.04, 0.026, 0.012], CHARCOAL, seg=5, cap=False))

# --------------------------------------------------------------- the wings
# One soft ridge of folded wings draped over the back - the same trick the
# Crag Pup uses for its own shoulder hold (a big rounded hump, THEN a small
# flat step on its front slope), rather than free-standing boxes. Two boxes
# out on their own read as scaffolding bolted to a ball, which is exactly the
# failure this file's own review notes warn about; a hump the shelf grows out
# of reads as part of the body because it IS the part of the body it steps off.
b.ball((0.0, 0.20, 1.95), (0.92, 1.05, 0.72), LILAC, 12, 7)     # the folded wings
b.ball((0.0, -0.05, 2.32), (0.60, 0.66, 0.44), VIOLET, 10, 6)   # the upper fold
# Eye-spot markings, the classic moth-wing pattern, pressed into the ridge's
# own surface rather than floating past its edge.
mirror(lambda s: b.ball((0.62 * s, 0.10, 1.86), (0.14, 0.15, 0.04), ORCHID,
                        9, 5))

# Two small flat steps on the ridge's own front slope, close to its surface so
# the push stays small and each reads as a foothold cut INTO the wings rather
# than a slab standing proud of them.
b.shelf(2, (0.0, -0.30), (0.46, 0.30), SLATE, thickness=0.12, bevel=0.04)
b.shelf(4, (0.0, -0.12), (0.40, 0.26), SLATE, thickness=0.12, bevel=0.04)
# Off to one side of the spine seam - a hunter stands ON one wing, not on the
# centreline between two - which also keeps the auto-push small: the
# centreline default points it toward the round head looming forward of it.
b.anchor(2, (0.50, -0.44, b.z_for(2)))
b.anchor(4, (0.42, -0.24, b.z_for(4)))

b.foot((0.70, -0.68, 0.30))                                    # onto a foreleg

# The sigil: a pale dust-marking on the head's forehead, facing -Y toward the
# camera, the same direction every other beast's mark faces. The head is the
# highest point of the body, which is where Height 5 - one above the top wing
# panel - naturally lands.
b.mark(at=(0.0, -1.02, b.z_for(5)), size=0.15, facing=(0.0, -0.94, 0.30))

b.done(out_path(), name="GloomMoth")
