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
                    AMBER, CHARCOAL, WHITE, RUST)

b = Build()

# --------------------------------------------------------------------- body
# ONE mass, and everything else grows out of it. Wide, low, and deeper than it
# is tall so the back domes over. This is the whole silhouette from behind.
#
# Pass 5 (2026-09-23): narrowed in Y (0.60 -> 0.50). At 0.60 the trunk's
# front-to-back depth was close enough to its own width (0.64) that it read
# as a round mass rather than a body with a haunch bulging off it - the
# pass-4 diagnosis ("body is a single large round mass and the haunch merges
# into it"). Narrowing depth only, not width or height, keeps the "wide, low"
# read this comment already calls for.
b.ball((0.00, 0.06, 0.50), (0.64, 0.50, 0.42), MINT, 15, 10)

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
        # Pass 7 (2026-09-23): AMBER (luma 181) against the MINT foot pad
        # (luma 162) is an 19-point value gap - the weakest colour boundary
        # anywhere on this model (every other part boundary is 38+, most
        # 70-100+; measured off the atlas pixels, not eyeballed). Value
        # contrast, not hue, is what still separates two shapes once distance
        # or a desaturated read (a dim arena, a downsampled 34px portrait)
        # flattens colour - the standard "does it still read in greyscale"
        # test AAA character design leans on for exactly this reason. The
        # toes are the one feature this function's own docstring calls "most
        # of what a frog's foot reads as", so they're the wrong place to have
        # the model's weakest boundary. RUST (luma 120, a 43-point gap, more
        # than double) fixes it and doubles as this fight's own established
        # warm accent (the arena wall/scatter recolour already uses it) -
        # ties the frog's one accent colour to the ground it's fought on.
        b.ball((x + d.x * size * 0.95, y + d.y * size * 0.95, z - 0.016),
               (toe, toe * 1.25, toe * 0.58), RUST, 7, 5)


def foreleg(s):
    """Short and out to the side, propping the chest up. Starts INSIDE the body
    so the shoulder is a swell rather than a socket.

    Pass 8 (2026-09-23): the hindleg's own knee ball is a SEPARATE mass,
    pushed out past the trunk so it breaks the silhouette (pass 5), and it
    sits almost exactly WHERE the hindleg's own limb starts -- ball and limb
    are nearly coincident, so the two read as one lobe with a leg growing
    out of it. The foreleg had no equivalent: three things tried in order
    this pass, each looked at in a render before the next:

    1. Just widening the limb's own start radius barely cleared the head's
       measured local surface (0.64 vs 0.636) -- real but marginal (614px
       diff, mostly the foot).
    2. A dedicated shoulder ball placed WHERE #1's maths pointed (centre
       0.50*s) was still barely visible (331px diff) -- the compound
       silhouette from the scoring camera is not the same as one ellipsoid's
       local surface, so a graze-past calc undersells how much is actually
       hidden behind the rest of the head from that angle.
    3. Pushed the ball further out (0.60*s, radius 0.30) and it finally broke
       the silhouette clearly (2642px diff, visible in `_sil`, `_side` and
       `_front`) -- but placed 0.30 away in X from the limb's own start
       point (0.30*s), it read as a third ball glued to the cheek, not a
       shoulder, in the side render.

    Fixed by doing what the hindleg already does: put the ball where the
    limb starts, not off to the side of it. Moved the limb's own first point
    out to meet the ball (0.30*s -> 0.42*s) so the two are nearly coincident,
    the same relationship pass 5's knee/hindleg pair has.
    """
    start = (0.42 * s, -0.44, 0.42)
    b.ball(start, (0.26, 0.24, 0.20), MINT, 12, 8)
    end = (0.50 * s, -0.74, 0.085)
    b.limb([start,
            (0.46 * s, -0.62, 0.24),
            end],
           [0.185, 0.130, 0.105], MINT, seg=10)
    foot(s, end, 0.150, 0.060, 0.90)


def hindleg(s):
    """Knee up beside the body, foot splayed out behind it.

    The knee ball is deliberately large and buried halfway in the trunk: in the
    reference the haunch is not a separate limb segment, it is a bulge in the
    body's own outline.

    Pass 5 (2026-09-23): pushed 0.08 further out in X (0.50 -> 0.58 * s), the
    other half of the pass-4 diagnosis. At 0.50 the knee's own bulge (it
    already reached x=0.80 against the body's x=0.64) sat so close behind the
    body's rounded flank, and so deep in Y, that it read as part of the same
    swell rather than a break in the outline. The limb's own start point
    moves the same 0.08 so it still seats inside the ball, not the trunk.
    """
    b.ball((0.58 * s, 0.10, 0.50), (0.30, 0.36, 0.32), MINT, 12, 8)
    end = (0.68 * s, -0.26, 0.085)
    b.limb([(0.60 * s, 0.12, 0.48),
            (0.66 * s, -0.06, 0.26),
            end],
           [0.200, 0.140, 0.110], MINT, seg=10)
    foot(s, end, 0.180, 0.070, 0.95)


mirror(eye)
mirror(foreleg)
mirror(hindleg)

# A dorsal saddle: GREEN pressed up into the body's own back so only a
# shallow cap shows, from just behind the eyes to just short of the haunches.
#
# Pass 6 (2026-09-23): the docstring above has always promised this -
# "GREEN now does what a darker shade should: the eyelids and the back
# markings, reading as shading on a lighter animal" - but no back marking
# ever existed in the code. Every MINT mass (head, body, both leg pairs, the
# haunch) was one flat colour, so the masses separated only by the pass-5
# geometry notch, not by colour at all; a monochrome animal is what "Colour &
# read" scored 7 for. Sized and positioned so it pokes through only along the
# centre ridge (checked against both the body's own surface equation and the
# haunch ball's footprint before building, not eyeballed) - it stops short of
# the haunch in X so it does not paint over the notch pass 5 just cut.
b.ball((0.00, 0.10, 0.80), (0.24, 0.28, 0.15), GREEN, 10, 6)

# Two nostrils, small and set into the snout. The only other feature on the
# face, exactly as in the reference.
#
# Pass 6 (2026-09-23): these never showed. At y=-0.80 the ball's own front
# edge (-0.828) sat 0.04-0.07 short of the head ellipsoid's own front surface
# at this x/z (-0.864 to -0.874, worst case at the ball's own lower edge) -
# checked against the head's surface equation, not assumed - so the whole
# part rendered fully submerged: tris spent on a feature with zero pixels.
# Pushed to -0.87 so the ball's front edge (-0.898) clears the head surface
# by a margin at every z it covers, not just at its centre.
mirror(lambda s: b.ball((0.085 * s, -0.87, 0.62), (0.028, 0.028, 0.024),
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
# Fitted SHORTER than the common eye level, and deliberately.
#
# Nick, 2026-09-08: "the frog is too big and should be scaled down to the
# relative size for a frog." Measured, the problem is not height -- every hunter
# is fitted to TARGET_HEIGHT 1.85 and the frog obeyed it. It is FOOTPRINT: at
# that height the frog came out 2.77 x 2.51 against the Vine-Weaver's
# 1.34 x 0.80. A squat animal fitted by height becomes enormous in volume,
# because height is the one dimension a frog does not have much of.
#
# This is also why its portrait was a close-up of one eye and nothing else: the
# portrait camera frames on height, and a body nearly twice as wide as any other
# hunter overflows the frame in the axis nobody measured.
#
# 1.15 puts its footprint at roughly 1.7 wide -- still the broadest of the cast,
# which is right for a frog, without being twice everyone else. The common eye
# level stays the rule for everyone with a normal body plan.
b.finish(out_path(), height=1.15, name="Frog", budget="hunter")
