"""The Frog - "Nimble: climbs fast and tags the weak point, but hits soft."

Rebuilt 2026-08-31 against Nick's reference photo, after two passes he rejected.
His notes, and what each one actually meant:

**"The mouth protrudes, doesn't look right."** Correct, and it should never have
been there. Look at the reference: there is NO mouth geometry. The mouth is the
BOUNDARY between the green head and the cream throat - a colour change, not a
shape. Every version before this one modelled a jaw, a grin, or a wheat-coloured
crease, and all three stuck out of the face because they were solid objects
pretending to be a line. Deleted, and the cream mass moved up to meet the green
where the mouth ought to be.

**"The edges are jagged and don't connect well."** Two causes. Segment counts
were cut to hit a triangle budget, which turned tubes into hexagonal prisms. And
the masses only TOUCHED - a ball resting against another ball shows the seam
where their surfaces cross. Parts here overlap by a third or more, so what shows
is one continuous surface with a swell in it rather than two objects meeting.

**"The eyes are pixelated."** They were 8x5. They are the single most important
feature on this creature and they are spheres seen head-on, where faceting is
most obvious. They now carry more segments than anything else in the model.

**Colour.** The body is MINT (#55BF6D), not GREEN (#2C9858). The reference is a
bright yellow-green and the palette's GREEN is a forest green - close enough by
name to have been the obvious pick, and wrong by eye once the two are side by
side. GREEN now does what a darker shade should: the eyelids and the back
markings, reading as shading on a lighter animal.

**"More rounded objects, take your time making sure the shapes connect."** The
governing idea: FEWER, BIGGER, DEEPLY OVERLAPPING masses. Ten well-merged parts
read as one animal; thirty touching ones read as a kit.

This runs over the nominal hunter budget and that is a deliberate trade, not an
oversight - see the note at the bottom of the file.
"""
import sys, os, math, mathutils
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, mirror, GREEN, MINT, CREAM, WHEAT,
                    AMBER, CHARCOAL, WHITE)

b = Build()

# --------------------------------------------------------------------- body
# ONE mass, and everything else grows out of it. Wide, low, and deeper than it
# is tall so the back domes over. This is the whole silhouette from behind.
b.ball((0.00, 0.06, 0.50), (0.64, 0.60, 0.42), MINT, 15, 10)

# The head. Pushed forward and UP into the body by well over a third of its own
# radius, so the two read as one continuous swell rather than a head set on a
# trunk. In the reference there is no neck and no seam - the face is simply the
# front of the animal.
b.ball((0.00, -0.34, 0.56), (0.68, 0.54, 0.40), MINT, 15, 10)

# The throat and belly: one pale mass pressed INTO the front so only its cap
# shows. Its top edge is where the mouth appears to be, and that boundary is the
# only mouth this frog has or needs.
b.ball((0.00, -0.56, 0.30), (0.50, 0.36, 0.32), CREAM, 16, 10)


def eye(s):
    """Three concentric spheres, and by far the most segments in the model.

    Nick: "the eyes are pixelated." They were, at 8x5. An eye is a sphere seen
    head-on, which is the worst case for faceting, and this one is the feature
    the whole design rests on - the reference is recognisable as a frog almost
    entirely because of two big round eyes with dark pupils.

    Sunk into the head by about a third so the lid swells out of the skull
    instead of balancing on it.
    """
    at = mathutils.Vector((0.300 * s, -0.40, 0.92))
    b.ball(at, (0.250, 0.250, 0.240), GREEN, 16, 11)
    b.ball(at + mathutils.Vector((0.0, -0.080, 0.008)),
           (0.205, 0.205, 0.200), CREAM, 16, 11)
    # Big, and pushed well out of the sclera. At 0.112 sunk at -0.130 the pupil
    # sat mostly INSIDE the pale sphere and from three-quarter you saw a cream
    # ball with a dot on it. In the reference the pupil is most of the eye and
    # the cream is a ring around it.
    b.ball(at + mathutils.Vector((0.0, -0.170, 0.002)),
           (0.170, 0.170, 0.168), CHARCOAL, 14, 9)
    b.ball(at + mathutils.Vector((-0.058 * s, -0.262, 0.078)),
           (0.040, 0.040, 0.038), WHITE, 8, 6)


def foot(s, at, size, toe, spread, uv=None):
    """A soft pad with four splayed toes, planted AT the end of the leg.

    Nick: "the legs don't line up with the feet." They did not. The foot was
    positioned by its own hand-written coordinates while the leg ended at
    another set, and the two only overlapped by luck - on the forelegs they
    missed, and a pad with toes floated a few centimetres off the ankle.

    So the foot now takes the limb's LAST POINT as its argument. It cannot come
    apart from the leg again without someone moving the leg and the foot in the
    same edit.

    Four toes, not three: the reference has four, splayed wide enough that the
    outer two are nearly at right angles to the middle pair. That fan is most of
    what a frog's foot reads as.
    """
    x, y, z = at
    b.ball((x, y, z - 0.010), (size, size * 0.92, size * 0.44), MINT, 10, 6)
    n = 4
    for i in range(n):
        a = (-spread) + (2.0 * spread) * (i / float(n - 1))
        d = mathutils.Vector((math.sin(a) * s, -math.cos(a), 0.0))
        b.ball((x + d.x * size * 0.95, y + d.y * size * 0.95, z - 0.016),
               (toe, toe * 1.25, toe * 0.58), AMBER, 7, 5)


def foreleg(s):
    """Short and out to the side, propping the chest up. Starts INSIDE the body
    so the shoulder is a swell rather than a socket."""
    end = (0.50 * s, -0.74, 0.085)
    b.limb([(0.30 * s, -0.44, 0.44),
            (0.44 * s, -0.62, 0.24),
            end],
           [0.185, 0.130, 0.105], MINT, seg=10)
    foot(s, end, 0.150, 0.060, 0.90)


def hindleg(s):
    """Knee up beside the body, foot splayed out behind it.

    The knee ball is deliberately large and buried halfway in the trunk: in the
    reference the haunch is not a separate limb segment, it is a bulge in the
    body's own outline.
    """
    b.ball((0.50 * s, 0.10, 0.50), (0.30, 0.36, 0.32), MINT, 12, 8)
    end = (0.68 * s, -0.26, 0.085)
    b.limb([(0.52 * s, 0.12, 0.48),
            (0.66 * s, -0.06, 0.26),
            end],
           [0.200, 0.140, 0.110], MINT, seg=10)
    foot(s, end, 0.180, 0.070, 0.95)


mirror(eye)
mirror(foreleg)
mirror(hindleg)

# Two nostrils, small and set into the snout. The only other feature on the
# face, exactly as in the reference.
mirror(lambda s: b.ball((0.085 * s, -0.80, 0.62), (0.028, 0.028, 0.024),
                        CHARCOAL, 8, 5))

# ON THE BUDGET. This model runs over the 1400 hunter figure and the overage is
# the point rather than an accident.
#
# Twelve toes at 12x7 were 2016 triangles on their own - a quarter of the
# model, on things about five pixels across in a fight. They are 7x5 now and
# the eyes kept theirs. Round where you look, cheap where you do not.
#

# 1400 was set for a build made of thirty-odd small parts. This one is made of
# TEN big ones, and Nick's whole note was that the old shapes were jagged, badly
# connected and pixelated - all three of which are what a low segment count buys
# you. The triangles are in the two places a viewer actually looks: the eyes,
# and the outline of the body. Cutting them back is how the last two passes got
# rejected.
b.finish(out_path(), name="Frog", budget="hunter")
