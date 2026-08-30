"""The Eyrie Hawk - the elite-pool beast whose bent rule is "the higher you
climb, the more it feeds on you."

Ledges at Height 2 and 4, sigil at 6. Its bent rule pairs `min_height`
(backlog #40, spent before only by Frost Sentinel, and there only paired with
`attack_all`) with `leech` for the first time: once a hunter is at Height 5 or
above - within striking range of its own crest, where it actually nests - its
attack switches from a flat hit to a drain that heals it back for what it
takes. Every other beast that punishes height either sweeps you off it
(Frost Sentinel's `attack_all`) or ignores it; this one turns your own climb
into its food source, so the sigil you are climbing toward is guarded by the
exact act of getting close to it. The puzzle is not "should I climb" but
"time the last few Heights so the drain doesn't just refill what you spent
three turns opening up."

A perched raptor, not a flying one - the cast already has one bird
(`sky_snapper`, a storm given a beak, all indigo/navy/sky) so this one is
built to read as the opposite: grounded, cold steel-grey plumage rather than
warm colour, a real head and eyes rather than lights in a plate, and folded
wings that build the SPINE'S two ledges rather than its own single shoulder
shelf. Steel/graphite/charcoal instead of Flicker Stag's rust/umber and Sky
Snapper's indigo/navy, so three "tall, elegant" elites in a row don't share a
palette either.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, STEEL, SLATE, GRAPHITE, CHARCOAL, \
                   CREAM, SAND, TAN, PEWTER


b = Beast("eyrie_hawk", height=3.4, span=(0.12, 3.16))

# ------------------------------------------------------------------- the legs
# Bent like a perched raptor's - hip back and up, ankle forward and down, the
# whole leg reading as a spring rather than a post (unlike Flicker Stag's
# straight stilts, the other tall elite in the cast).
def leg(s):
    b.limb([(0.34 * s, -0.10, 1.55), (0.42 * s, 0.22, 0.95),
           (0.36 * s, -0.06, 0.30)], [0.16, 0.135, 0.10], STEEL, seg=7)
    for spread, reach in ((-0.7, 0.30), (0.0, 0.34), (0.7, 0.30)):
        b.taper((0.36 * s, -0.10, 0.22), 0.06, 0.012, reach, GRAPHITE, seg=4,
               rot=point((spread * s, -0.85, -0.55)))
    b.taper((0.36 * s, 0.16, 0.22), 0.05, 0.011, 0.24, GRAPHITE, seg=4,
           rot=point((0.0, 0.85, -0.55)))                            # back talon


mirror(leg)

# ------------------------------------------------------------------ the mass
b.ball((0.0, -0.05, 1.86), (0.50, 0.62, 0.66), STEEL, 12, 7)         # torso
b.ball((0.0, -0.30, 1.72), (0.36, 0.46, 0.40), CREAM, 10, 6)         # pale breast, forward/low

# ---------------------------------------------------------------- the wings
# Folded flat along the flank - a slim mass tapering from the shoulder down
# toward the hip, pointed BACK rather than sticking out sideways. The first
# build used two wide wedges thrown out at the shoulder and read as a shark
# fin bolted to the back (caught by looking at the render, not by any
# contract - a "wing" this size and this squared-off has no bird in it).
# Pulled in tight against the body and re-cut as a single taper instead.
def wing(s):
    b.taper((0.42 * s, 0.10, 2.10), 0.30, 0.09, 1.05, SLATE, seg=8,
           rot=point((0.28 * s, 1.0, -0.35)))                        # folded mass
    for i, spread in enumerate((-0.16, 0.02, 0.20)):
        b.taper((0.50 * s, 0.78 + i * 0.05, 1.80 - i * 0.10), 0.045, 0.009, 0.48,
               CHARCOAL, seg=4,
               rot=point((0.14 * s + spread * s, 1.0, -0.22)))       # trailing primaries
    b.limb([(0.30 * s, 0.05, 2.02), (0.44 * s, 0.32, 1.92), (0.50 * s, 0.68, 1.72)],
           [0.08, 0.065, 0.05], STEEL, seg=5)                         # the spar


mirror(wing)

# ------------------------------------------------------------------- the neck
b.limb([(0.0, -0.42, 2.10), (0.0, -0.62, 2.42), (0.0, -0.72, 2.72)],
       [0.22, 0.19, 0.15], STEEL, seg=8)

# -------------------------------------------------------------------- the head
b.ball((0.0, -0.82, 2.94), (0.20, 0.24, 0.19), TAN, 10, 6)
mirror(lambda s: b.ball((0.13 * s, -0.98, 2.98), (0.045, 0.04, 0.045),
                        GRAPHITE, 7, 4))                              # eye
mirror(lambda s: b.taper((0.14 * s, -0.86, 3.10), 0.05, 0.01, 0.13, TAN,
                         seg=5, rot=point((0.4 * s, 0.10, 0.60))))    # ear-tuft

# Hooked beak, curving down and forward off the head.
b.wedge((0.0, -1.04, 2.90), (0.10, 0.16, 0.09), SAND,
        narrow=(0.35, 0.40), bevel=0.02)
b.taper((0.0, -1.20, 2.80), 0.065, 0.012, 0.18, SAND, seg=6,
        rot=point((0.0, -0.55, -1.0)))

# -------------------------------------------------------------------- the ledges
# Shoulder ridge (Height 2) sits low, at the wing root; the back ridge
# (Height 4) sits higher, between the trailing wingtips - two real steps up
# the spine rather than one shelf shared by both ledges, avoiding the "one
# shelf, two Heights" trap a flat back would invite.
b.ball((0.0, 0.30, b.z_for(2)), (0.30, 0.30, 0.22), PEWTER, 9, 5)
b.shelf(2, (0.0, 0.34), (0.24, 0.20), PEWTER, thickness=0.10, bevel=0.04)

b.ball((0.0, 0.62, b.z_for(4)), (0.26, 0.28, 0.20), PEWTER, 9, 5)
b.shelf(4, (0.0, 0.66), (0.22, 0.18), PEWTER, thickness=0.10, bevel=0.04,
        drop=0.02)

b.foot((0.40, -0.06, 0.15))                                          # onto a talon

# Height 1 falls between the foot and the H2 shelf with no body directly in
# that column (the breast and torso balls both sit higher), so the first
# build's auto-push reached forward for the nearest surface and came back as
# a horizontal spike near the throat - the same "antenna" failure named in
# this file's own write-ups on other beasts. Naming a point on the thigh,
# where a hunter would actually be standing at this Height, fixes it.
b.anchor(1, (0.38, 0.14, b.z_for(1)))

# Height 5 falls on the bare neck, between the back ridge and the head, with
# no anchor of its own - _rungs() interpolated it near the centreline where
# the neck is narrow and the auto-push came back nearly a body-unit out
# (the same trap Flicker Stag's own build notes named). Naming a real point
# on the neck's own surface keeps the step small instead of floating.
# Height 3 falls on the torso between the two shelves, interpolated straight
# toward the tail (both shelf anchors sit at positive y), which pushed a
# large step out behind the beast. A point out along the torso's own flank
# instead keeps the push small, the same trick used for Height 1 and 5 above.
b.anchor(3, (0.40, 0.10, b.z_for(3)))

b.anchor(5, (0.17, -0.48, b.z_for(5)))

# The crest, off the head's own centreline - the same fix every recent beast's
# HOLDS and marks both need: a mark at x=0 on a head this size sits inside the
# head's own front bulge and gets buried regardless of how far forward it is
# pushed, so the mount (and the sigil that sits on it) live off to one side.
b.ball((0.16, -0.90, b.z_for(6)), (0.13, 0.14, 0.10), TAN, 8, 5)
b.mark(at=(0.16, -1.10, b.z_for(6)), size=0.12, facing=(0.10, -0.98, 0.05))

b.done(out_path(), name="EyrieHawk")
