"""The Flicker Stag - the elite-pool beast whose bent rule turns "hurt" into
"the plan you already made no longer applies."

Ledges at Height 2 and 4, sigil at 6. Its bent rule is `hurt_pct`/`hurt_moves`
(backlog #44), spent before this by five other beasts (Crag Pup, Mire Snapper,
Gale Serpent, Cinder Jackal all get MORE dangerous below the line; Clot Toad
scabs back over it with `regen`). None of them change WHERE the fight is won.
This one does: below 40% HP its pattern starts firing `shift_sigil`, so the
rune you have been climbing toward relocates mid-fight while it keeps
attacking - the puzzle stops being "survive the enrage" and becomes "the hold
you spent three turns reaching is not the hold that matters any more." The
same field every hurt-beast reads, bent to move the GOAL rather than the
threat.

A tall, proud stag rather than a low quadruped - the first beast in the cast
built to read as elegant, so the antler crown (where the sigil actually sits,
and where it visibly hops between tines once the fight turns) has real height
above everything else to hop across. Long slender tapered legs, an arched
climbing neck, and a branching bone-coloured rack kept firmly OFF the
GOLD/AMBER palette `mark()` itself uses - a sigil that shares its wearer's own
colour is a sigil that blends in, the same lesson every other elite's palette
choice already avoided (Mire Snapper's clay, Frost Sentinel's ice, Grove
Bear's forest green, Shifting Idol's stone grey, Gloom Moth's slate purple,
Bog Leech's pond murk, Silk Widow's charcoal web, Brine Urchin's coral, Clot
Toad's sand). Autumn rust and umber instead.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, RUST, BROWN, UMBER, CREAM, \
                   WHEAT, SAND, GRAPHITE


def _seg(b, start, end, r0, r1, uv, seg=8, bevel=0.0):
    """A taper spanning two explicit endpoints.

    taper()'s `loc` is the CONE'S OWN CENTRE, not one end - the primitive
    Blender builds is symmetric about it along the rotated axis. Aiming a
    taper "from" a point by passing that point straight through as `loc`
    only reaches halfway to wherever it looks like it should end, which is
    exactly why the antler tines first came back as two floating islands:
    their base sat at the beam's own tip, but the tine geometry was centred
    THERE rather than starting there, so it never touched the beam at all.
    """
    sx, sy, sz = start
    ex, ey, ez = end
    mid = ((sx + ex) / 2.0, (sy + ey) / 2.0, (sz + ez) / 2.0)
    length = math.sqrt((ex - sx) ** 2 + (ey - sy) ** 2 + (ez - sz) ** 2)
    return b.taper(mid, r0, r1, length, uv, seg=seg,
                   rot=point((ex - sx, ey - sy, ez - sz)), bevel=bevel)


b = Beast("flicker_stag", height=3.6, span=(0.00, 3.86))

# ------------------------------------------------------------------- the legs
# Long and slender - a stag stands TALL on its legs, unlike the low, wide
# quadrupeds already in the cast (Thrasher, Clot Toad). Hip -> knee -> hoof,
# with the knee pulled slightly outward and forward so the leg reads as
# jointed rather than a straight post.
for sx in (-1, 1):
    for sy, ly, kfy in ((-1, -0.58, -0.70), (1, 0.52, 0.62)):
        b.limb([(0.44 * sx, ly, 1.80), (0.52 * sx, kfy, 0.95),
               (0.46 * sx, ly * 0.92, 0.06)], [0.19, 0.13, 0.07],
               BROWN, seg=7)
        b.taper((0.46 * sx, ly * 0.92, 0.05), 0.075, 0.025, 0.11, UMBER,
                seg=6, rot=point((0.0, 0.0, -1.0)))

# ------------------------------------------------------------------ the mass
b.ball((0.0, 0.0, 2.05), (0.56, 0.92, 0.60), RUST, 13, 7)            # torso
b.ball((0.0, -0.05, 1.80), (0.44, 0.78, 0.34), CREAM, 11, 6)         # pale chest/belly, lower

# Neck: arches up and forward, carrying a hunter's climb from the shoulders
# to the head the same way a real stag's neck is the tall middle of it.
b.limb([(0.0, -0.78, 2.15), (0.0, -1.22, 2.60), (0.0, -1.52, 2.92)],
       [0.34, 0.28, 0.21], RUST, seg=9)
b.box((0.0, -1.35, 2.40), (0.10, 0.42, 0.06), CREAM, bevel=0.03)     # throat flash

# Head, forward and up at the top of the neck.
b.ball((0.0, -1.66, 3.02), (0.22, 0.30, 0.20), BROWN, 11, 6)
b.wedge((0.0, -1.96, 2.96), (0.14, 0.20, 0.11), UMBER, narrow=(0.45, 0.55))
mirror(lambda s: b.ball((0.14 * s, -1.80, 3.10), (0.045, 0.04, 0.045),
                        GRAPHITE, 7, 4))                              # eye
mirror(lambda s: b.taper((0.20 * s, -1.60, 3.16), 0.05, 0.01, 0.16, BROWN,
                         seg=6, rot=point((0.55 * s, 0.10, 0.55))))   # ear

# --------------------------------------------------------------------- rack
# Branching antlers, off the crown of the head. `point()` is what makes a
# straight taper read as a beam angled up and back rather than a spike stuck
# straight out - the same trick every other beast's horn/claw uses, just with
# more of them. Bone colour, deliberately never GOLD/AMBER (see module doc) so
# the sigil that hops between the tines below 40% HP always stands out against
# them rather than blending in.
def _rack(s):
    base = (0.10 * s, -1.55, 3.16)
    beam_end = (0.34 * s, -1.05, 3.62)
    _seg(b, base, beam_end, 0.055, 0.020, WHEAT, seg=7, bevel=0.008)
    _seg(b, beam_end, (0.30 * s, -1.30, 3.86), 0.026, 0.007, SAND,
         seg=6, bevel=0.005)                                        # forward tine
    _seg(b, beam_end, (0.55 * s, -0.85, 3.75), 0.024, 0.006, SAND,
         seg=6, bevel=0.005)                                        # side tine
mirror(_rack)

# A small crown mount, off the head's own CENTRELINE rather than on it - at
# x=0 the sigil's Height sits inside the head ball's own z-span, and the
# head's front surface there bulges forward past anything reasonably placed
# in front of it, burying the mark 100% no matter how far it was pushed
# forward (caught by Godot's own occlusion check, not the Blender-side reach
# test, which only wants SOME body nearby and does not care what is in
# front). Off to one side, level with an antler root, the head's own bulge
# in that column is much shallower.
b.ball((0.26, -1.65, b.z_for(6)), (0.16, 0.17, 0.12), BROWN, 8, 5)

# --------------------------------------------------------------- the ledges
# Two mane ridges stepping up the neck's own spine, offset from the
# centreline - a centred anchor on a long, roughly symmetric neck gives
# beast.py's auto-placement no clear "outward" side to prefer and drags the
# hold out along the neck's own length instead of across it, the same failure
# Thrasher's and Clot Toad's builds both already hit and fixed the same way.
#
# Both ridge balls sit AT b.z_for(h), not at a hand-guessed height - z_for()
# is the one authority for where Height 2 and Height 4 actually land in this
# body's own span, and guessing produced a ridge more than half a unit above
# where the shelf plate it was supposed to carry actually sat, which is why
# the first build here shipped a shelf floating clear of its own mound.
b.ball((0.34, -0.30, b.z_for(2)), (0.34, 0.38, 0.28), UMBER, 10, 6)  # shoulder ridge
b.shelf(2, (0.32, -0.34), (0.24, 0.21), UMBER, thickness=0.11, bevel=0.04)

# The neck ridge sits on the OPPOSITE flank from the shoulder ridge above,
# not the same one - four climb points (H0/H1/H2 near the shoulder, H4/H5/H6
# near the crown) stacked on a single side reads as one long ladder bolted to
# one flank; splitting the route across both sides at least breaks that into
# two shorter, more plausible-looking runs.
b.ball((-0.26, -0.85, b.z_for(4)), (0.30, 0.32, 0.24), UMBER, 9, 5)  # neck ridge
b.shelf(4, (-0.25, -0.88), (0.21, 0.18), UMBER, thickness=0.10, bevel=0.04,
        drop=0.02)

b.foot((0.46, -0.58, 0.10))                                     # onto a foreleg
# Height 5 falls between the neck ridge and the sigil with no anchor of its
# own, so _rungs() interpolated it near the centreline where the neck is
# thinnest and the auto-push came back nearly seven hunter-widths out. This
# names a real point ON the neck's own surface instead, on the same flank as
# the H4 ridge it sits between.
b.anchor(5, (-0.20, -1.13, b.z_for(5)))

# The sigil, pulled forward off the crown mount's own surface rather than
# sitting at its edge, same trick every other beast's mark() placement uses.
b.mark(at=(0.26, -1.98, b.z_for(6)), size=0.12, facing=(0.10, -0.98, 0.05))

b.done(out_path(), name="FlickerStag")
