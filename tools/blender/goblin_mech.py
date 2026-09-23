"""The Goblin Engineer - "Heavy hitter: builds gadgets to climb."

A small goblin under an oversized rig. The asymmetry IS the read: one ordinary
arm, one enormous mechanical one, so which class this is survives being 40px
tall at a Titan's foot.

Rebuilt on the wider vocabulary (see kenney.py). The first version was made of
ellipsoids, and a MACHINE made of ellipsoids is the worst case of that: the rig
was four soft grey eggs in a row, which reads as a boulder he is carrying rather
than as an arm he is wearing. Machinery is boxes, cylinders and pistons - hard
edges with a bevel on them, which is exactly what box() and taper() are for.

The organic half stays soft on purpose. Goblin round, rig square, and the two
halves of the silhouette disagree with each other, which is the character.
"""
import sys, os, math, mathutils
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, out_path, mirror, MINT, GREEN, GRAPHITE, PEWTER,
                    STONE, CHARCOAL, PUMPKIN, CARROT, GOLD, ICE, UMBER)

UP = 0.0                  # a cone already points +Z
FWD = math.pi / 2         # ... this turns it to face -Y

b = Build()

# ------------------------------------------------------------------ the goblin


def leg(s):
    """Short, bent, planted. One limb, not two stacked eggs."""
    b.limb([(0.150 * s,  0.030, 0.410),
            (0.158 * s,  0.000, 0.250),
            (0.152 * s, -0.030, 0.130)],
           [0.115, 0.098, 0.088], GRAPHITE, seg=6)
    b.wedge((0.158 * s, -0.048, 0.060), (0.112, 0.155, 0.060), CHARCOAL,
            narrow=(0.72, 0.62), bevel=0.024)                      # boot


mirror(leg)

# Body/head/snout dropped from the default seg=10,ring=6 (body/head) and 9,5
# (snout) to 8,5 to claw back budget (see "Budget" note below) - the biggest,
# gentlest-curved masses on the model, so fewer segments cost the least here;
# a _sil.png diff against the pre-cut render is pixel-identical at 64px.
b.ball((0.0, 0.0, 0.66), (0.275, 0.235, 0.255), MINT, 8, 5)        # body
b.box((0.0, -0.190, 0.605), (0.150, 0.038, 0.140), UMBER, bevel=0.024)  # apron

# ------------------------------------------------------------------- the rig
# Every piece here is a box or a cylinder. That is the whole difference: a
# bevelled box catches a bright line along each edge and reads as machined
# plate, where a sphere reads as a pebble.
#
# The trap, learned the expensive way: a box HALF-EXTENT is not a sphere RADIUS.
# Swapping the numbers straight across inflates every part by its corners, and
# the first pass came out as a stack of grey fridges the goblin was hiding
# behind. Multiply the old radii by about 0.72 and the volumes match.
#
# The compressor was centered at x=0.0 - dead on the goblin's own centerline,
# so it sat behind the head in every view instead of hung off the rig's
# shoulder. Shifted +0.30 in X, with the lid and exhaust it carries moving as
# one piece with it, so nothing mechanical crosses behind the head.
#
# GRAPHITE -> STONE (pass 5): in the actual Cinder Jackal fight, this box sat
# against the beast's own near-black body/wing (sampled in-game: rig pixel
# luminance 18.4 vs jackal-body 4.6, a 13.8-point gap - weaker than the
# weakest boundary the frog's own pass 7 found and fixed, 18.8, on the one
# model half whose whole job is to read as "an enormous rig", per this
# file's own header). GRAPHITE and CHARCOAL are this palette's two darkest
# greys (59.4/56.4 luminance, functionally the same value) and the toon
# shader's shadow band crushes both to near-black against a dark backdrop.
# STONE (114.1) is already this rig's own established colour (upper-arm
# limb, claw box) - no new hue, just moved the biggest box off the two
# darkest ties.
# Pass 7 (2026-09-23): pass 6 measured the rig's own limb radii at 1.3-1.6x
# the ordinary MINT arm's and confirmed that's real but "moderate" against the
# file's own "enormous" claim - Proportion held at 7, not a hidden defect but
# a real, if partial, miss. Pass 6 also declined to just scale the rig blind:
# every part here is an independent box()/limb()/taper() call at an absolute
# coordinate, not a single chain from one joint, so a naive mesh-level scale
# risks reopening the "orbiting blocks" read pass 2-4 spent three passes
# closing. The fix that avoids that risk: scale every rig coordinate AND size
# by the same factor from the same pivot, in the GENERATOR, before the
# geometry is built - not a post-hoc mesh transform. That preserves every
# rig-to-rig distance and overlap exactly (touching stays touching, by
# construction), the one thing a blind scale couldn't guarantee. RIG_P sits
# near the shoulder box, so the compressor cluster grows up/back and the
# claw/piston cluster grows down/forward from roughly where the rig meets the
# body - reading as the rig itself getting bigger, not the goblin sliding out
# from under it.
RIG_S = 1.18
RIG_P = (0.30, 0.05, 0.80)


def rp(x, y, z):
    return (RIG_P[0] + RIG_S * (x - RIG_P[0]),
            RIG_P[1] + RIG_S * (y - RIG_P[1]),
            RIG_P[2] + RIG_S * (z - RIG_P[2]))


def rs(*vs):
    return tuple(RIG_S * v for v in vs) if len(vs) > 1 else RIG_S * vs[0]


def mount(box_loc, box_rot, delta, own_rot=(0.0, 0.0, 0.0)):
    """Where a part rigidly bolted to a rotated box's face actually sits.

    A part placed at a raw axis-aligned offset from a box's center, with its
    own fixed rot=, ignores the box's own tilt entirely - it points wherever
    its own rot says, from wherever the offset says, in WORLD axes, no matter
    how the box itself is rotated. The claw/piston cluster (pass 9) was
    exactly this: mounted on the claw box's face with a world-axis-aligned
    offset and a world-axis-aligned rot=(FWD,0,0), while the box itself
    carries rot=(0.18, 0.20, 0.0) - so the claw did not emerge from the box's
    actual (tilted) front face, it emerged from a point and heading that were
    only correct for an unrotated box. That reads as a peg glued to a corner,
    not a claw mounted on a face. Rotate both the offset and the part's own
    orientation by the box's rotation so the mount follows the tilt, the same
    way a bolt follows the panel it's bolted to.
    """
    bm = mathutils.Euler(box_rot, 'XYZ').to_matrix()
    loc = tuple(mathutils.Vector(box_loc) + bm @ mathutils.Vector(delta))
    rot = tuple((bm @ mathutils.Euler(own_rot, 'XYZ').to_matrix()).to_euler('XYZ'))
    return loc, rot


b.box(rp(0.30, 0.278, 0.800), rs(0.145, 0.098, 0.152), STONE, bevel=rs(0.026))
b.box(rp(0.30, 0.278, 0.960), rs(0.106, 0.078, 0.030), PEWTER, bevel=rs(0.013))   # lid
b.limb([rp(0.412, 0.330, 0.880), rp(0.422, 0.398, 0.995), rp(0.440, 0.392, 1.088)],
       [rs(0.044), rs(0.040), rs(0.036)], PUMPKIN, seg=5)  # exhaust; seg 6->5, pass 4 budget
b.taper(rp(0.442, 0.392, 1.128), rs(0.057), rs(0.046), rs(0.078), CARROT, seg=6,
        bevel=rs(0.010))

b.box(rp(0.346, 0.030, 0.812), rs(0.122, 0.126, 0.134), PEWTER, bevel=rs(0.024),
      rot=(0.0, 0.10, 0.0))
# Upper arm and wrist limbs were 0.086-0.098 radius bridging boxes with
# 0.12-0.15 half-extents - thin enough that the joints vanished between the
# bigger masses and the rig read as loose boxes rather than one jointed arm.
# Thickened ~1.4x so the limb reads as continuous with the boxes it connects.
#
# seg 6->10 on both (pass 4): the real cause of three passes' "reads as
# scattered blocks" - each limb's hex end-cap pokes out right where it
# meets its box (a box's rotated face never sits parallel to the cap, so no
# amount of embedding the waypoint deeper hides it), and each of the 6
# flat facets caught its own toon-shading band, reading as a sharp zigzag
# crown. Confirmed with a diagnostic recolour - see goblin_mech.md pass 4 -
# and it was NOT the CHARCOAL ring a few lines down, which was the first
# suspect. More segments round the cap into a shallow seam instead.
b.limb([rp(0.350, 0.020, 0.766), rp(0.392, -0.030, 0.652), rp(0.414, -0.062, 0.580)],
       [rs(0.137), rs(0.120), rs(0.112)], STONE, seg=10)                 # upper arm
b.box(rp(0.416, -0.068, 0.548), rs(0.086, 0.090, 0.106), PEWTER, bevel=rs(0.020),
      rot=(0.12, 0.14, 0.0))
b.limb([rp(0.420, -0.076, 0.500), rp(0.438, -0.100, 0.430), rp(0.450, -0.118, 0.378)],
       [rs(0.095), rs(0.106), rs(0.115)], PEWTER, seg=10)                # wrist
# Pass 9: the claw box's own rot=(0.18, 0.20, 0.0) tilts its face, but the
# claw taper and both piston rods below were placed at a raw axis-aligned
# offset with a raw axis-aligned rot=(FWD,0,0) - correct for an UNROTATED
# box, so on this (tilted) box they emerged from a point and heading that
# don't match the face they're meant to sit on. Six-view look confirmed the
# read this causes: the claw hangs off the box's corner with a visible gap
# beneath it (`_34.png`, `_side.png`), not flush against the face - see
# goblin_mech.md pass 9. mount() rotates the offset and the part's own
# orientation by the box's own rotation so both actually land on its face.
CLAW_BOX_LOC = rp(0.454, -0.128, 0.298)
CLAW_BOX_ROT = (0.18, 0.20, 0.0)
b.box(CLAW_BOX_LOC, rs(0.132, 0.138, 0.112), STONE, bevel=rs(0.026), rot=CLAW_BOX_ROT)
_claw_loc, _claw_rot = mount(CLAW_BOX_LOC, CLAW_BOX_ROT, (0.0, rs(-0.140), 0.0), (FWD, 0, 0))
b.taper(_claw_loc, rs(0.072), rs(0.058), rs(0.130), CARROT, seg=6, rot=_claw_rot)
# Pass 10: pass 9's own diagnostic recolour found these functionally
# invisible at every angle, even highlighted - measured why instead of just
# widening blind. A diagnostic-ICE rebuild showed almost the whole rod
# buried inside the claw box and the claw taper's own cone: the old dz
# offset (+-0.048, ~0.057 world) sat well inside the taper's 0.085 base
# radius, so the rods ran coincident with the taper's volume, not beside it.
# Pushed dz out to +-0.110 (clears the taper's radius with margin) and
# widened the radius 0.016->0.030 (seg unchanged, zero tri cost - a bigger
# cone from the same 4 verts). CHARCOAL -> STONE too: pass 5 already found
# CHARCOAL/GRAPHITE are this rig's two darkest, near-tied tones that the toon
# shader's shadow band crushes near-black, the same fix already applied to
# the compressor box and the wrist ring.
for dz in (-0.110, 0.110):                                              # piston rods
    _p_loc, _p_rot = mount(CLAW_BOX_LOC, CLAW_BOX_ROT, (0.0, rs(-0.090), rs(dz)), (FWD, 0, 0))
    b.taper(_p_loc, rs(0.030), rs(0.030), rs(0.190), STONE, seg=4, rot=_p_rot)
# minor 4->3 (pass 4): ruled out as the zigzag's cause by the same
# diagnostic recolour above, so its own roundness costs nothing that was
# scored; freed 24 tris toward the two limb caps' seg 6->10 above.
#
# CHARCOAL -> STONE (pass 5): same dark-tie-against-the-jackal fix as the
# compressor box above - this ring is the rig's other big CHARCOAL mass, and
# the same near-black-on-near-black loss applies to it in-fight.
b.ring(rp(0.384, -0.020, 0.690), rs(0.158, 0.158, 0.042), STONE, 12, 3,
       rot=(0.10, 0.0, 0.0), thickness=rs(0.16))

b.limb([(-0.290, -0.010, 0.830),
        (-0.335, -0.055, 0.660),
        (-0.330, -0.100, 0.530)],
       [0.086, 0.074, 0.068], MINT, seg=5)             # ordinary arm; pass 4 budget
b.ball((-0.330, -0.130, 0.487), (0.090, 0.098, 0.082), GREEN, 7, 4)     # hand, same

# ------------------------------------------------------------------- the head
b.ball((0.0, -0.045, 1.030), (0.235, 0.215, 0.205), MINT, 8, 5)

# Goblin ears are CONES. Two flattened spheres was the single most obvious
# ellipsoid tell on the whole model - they read as fins glued to his temples.
mirror(lambda s: b.taper((0.236 * s, 0.025, 1.100), 0.086, 0.014, 0.215, GREEN,
                         seg=6, rot=(-0.22, 0.86 * s, 0.0)))

b.ball((0.0, -0.150, 1.005), (0.128, 0.090, 0.072), GREEN, 8, 5)     # snout
b.box((0.0, -0.212, 0.947), (0.062, 0.022, 0.016), CHARCOAL, bevel=0.006)  # grin
mirror(lambda s: b.taper((0.030 * s, -0.205, 0.962), 0.012, 0.003, 0.045,
                         ICE, seg=4, rot=(-0.5, 0, 0)))             # tusks

# Was a near-flat disc (thickness 0.16 default squashed further by the 0.048
# z-scale): reads as a strap only face-on; `_side.png` shows it as a thin gold
# blade jutting well past the ear, since a flat disc viewed edge-on is just its
# rim. Thickened the tube (thickness 0.16 -> 0.26) and un-flattened it in Z
# (0.048 -> 0.075) so there is a band to see from any angle, and pulled the
# major radius in a touch (0.228/0.198 -> 0.205/0.180) so less of it clears the
# head silhouette. Same 14x4 segments, so no tri cost.
#
# Pass 8: that fix rounded the tube but never checked whether the ring's own
# Y-radius put its FRONT EDGE somewhere sane. It didn't - measured against the
# goggle barrel/lens this ring is meant to carry: strap front at
# y=-0.110-0.180=-0.290, barrel tip at y=-0.180-0.082=-0.262, lens centre at
# y=-0.228. The "strap" sat in front of the goggles it supposedly straps on,
# which is exactly the blade/beak `_side.png` and `_34.png` (the fight-camera
# angle) both show at oblique angles - pass 4 fixed the tube's cross-section,
# not this. Pulled Y-radius 0.180 -> 0.105 (front edge -0.110-0.105=-0.215,
# now behind the barrel tip and roughly level with the lens) so the loop reads
# as wrapping the head instead of projecting past the face. X-radius (head
# width, already correct) untouched.
b.ring((0.0, -0.110, 1.105), (0.205, 0.105, 0.075), GOLD, 14, 4,
       thickness=0.26)                                              # goggle strap
mirror(lambda s: b.taper((0.108 * s, -0.180, 1.105), 0.078, 0.066, 0.082, GOLD,
                         seg=5, rot=(FWD, 0, 0)))  # goggle barrel; seg 6->5, pass 4 budget
mirror(lambda s: b.ball((0.108 * s, -0.228, 1.105), (0.055, 0.024, 0.055), ICE, 8, 5))

b.finish(out_path(), name="GoblinEngineer", budget="hunter")
