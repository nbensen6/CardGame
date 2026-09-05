"""Card icons, built rather than borrowed.

164 cards share 28 icons, and all 28 are Kenney glyphs recoloured by a tint
table — grey shapes drawn for a board-game asset pack, doing duty as the art on
every card in the game. They are the last borrowed thing on screen.

    blender --background --python tools/blender/icons.py -- <out_dir>

Each icon is a tiny 3D scene in the shared palette, rendered ORTHOGRAPHIC and
HEAD-ON. Head-on matters: an icon is read at 42 pixels as a silhouette, and a
three-quarter view of a small object turns into a smudge. Everything here is
built flat in X and Z with just enough depth in Y to catch the light.

Because they carry their own colour, `card_view.gd` stops tinting them. The tint
table existed to tell 28 grey glyphs apart; these are already different.

The brief for each one is the comment beside it in `card_view.ICONS` — what the
card actually DOES. An icon that shows the flavour instead of the mechanic is
worse than no icon, because a hand of cards is read by shape, fast.
"""
import bpy, math, os, sys
from mathutils import Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import math
from kenney import (Build, BUDGET, point, aim, RED, RUST, ORANGE, TANGERINE,
                    BLUE, INDIGO, ICE, SKY, LILAC, VIOLET, PINK, ORCHID,
                    STEEL, SLATE, WHITE, SILVER, PEACH, CLAY, BROWN, UMBER,
                    SAND, TAN, CREAM, WHEAT, MINT, GREEN, GOLD, AMBER,
                    BLUSH, ROSE, PERIWINKLE, IRIS, LINEN, BISQUE, PUMPKIN,
                    CARROT, CORAL, BRICK, CHARCOAL, GRAPHITE, PEWTER, STONE,
                    NAVY, MIDNIGHT)

SIZE = 256
FRAME = 1.15          # world units across the render
BUDGET["icon"] = 700

D = 0.10              # how deep an icon is; enough to shade, not enough to read


class Icon(Build):
    """One card icon. Built flat in X/Z, seen head-on."""

    def slabf(self, x, z, w, h, uv, rot=0.0, bevel=0.020, d=D):
        """A flat plate on the face of the icon. The workhorse."""
        return self.box((x, 0.0, z), (w, d, h), uv, bevel=bevel,
                        rot=(0.0, rot, 0.0))

    def spike(self, x, z, r0, r1, length, uv, ang=0.0, seg=6, d=None):
        """A taper lying in the icon's plane, pointing `ang` from straight up."""
        return self.taper((x, 0.0, z), r0, r1, length, uv, seg=seg,
                          rot=point((math.sin(ang), 0.0, math.cos(ang))))

    def ring(self, loc, scale, uv, major=16, minor=5, rot=(0, 0, 0),
             thickness=0.16, smooth=None):
        """Face-on by default — a torus in the icon plane, not lying flat."""
        return Build.ring(self, loc, scale, uv, major, minor,
                          (math.pi / 2, 0.0, 0.0) if rot == (0, 0, 0) else rot,
                          thickness, smooth)

    def _islands(self):
        """Suppressed, like env.Env's — and for the same reason.

        The island check exists to catch a limb left in mid-air on a CHARACTER,
        where every part is meant to be one body. An icon is the opposite: a
        wall icon IS separate bricks, a gadget icon IS a few loose pieces, and
        the shape reads because they are apart. Reporting six warnings for one
        wall is noise, and noise is how a real warning gets missed.
        """
        return [list(range(len(self.parts)))]

    def done(self, out, name):
        self.finish(out, height=None, name=name, budget="icon")


# ----------------------------------------------------------------- the icons

def sword(i):                                   # a plain attack
    i.slabf(0.0, 0.08, 0.075, 0.40, SILVER)
    i.spike(0.0, 0.52, 0.075, 0.006, 0.20, SILVER, seg=4)
    i.slabf(0.0, -0.34, 0.26, 0.045, RUST)      # crossguard
    i.slabf(0.0, -0.48, 0.045, 0.12, UMBER)     # grip
    i.ball((0.0, 0.0, -0.62), (0.075, 0.06, 0.075), GOLD, 8, 5)


def shield(i):                                  # block
    i.slabf(0.0, 0.16, 0.34, 0.30, STEEL, bevel=0.05)
    # A forked base: shield_icon.md's Family-distinction finding was that this
    # single point-and-plate kite matches guard's own body almost exactly --
    # guard was told apart with shoulder flares (batch 15 pass 2); a split
    # tail differs by outer silhouette the same way, without copying that fix.
    for s in (-1, 1):
        i.spike(0.09 * s, -0.30, 0.15, 0.02, 0.46, STEEL,
                ang=math.pi + 0.30 * s, seg=4)
    i.slabf(0.0, 0.40, 0.34, 0.055, SILVER)
    # A raised centre boss, not the old cross (a vertical bar plus a
    # horizontal one): shield_icon.md's Mechanic-match finding was that a
    # plain plus reads as "heal" elsewhere in the genre; a domed stud reads
    # as "shield" without borrowing that glyph.
    i.ball((0.0, -0.12, 0.02), (0.12, 0.06, 0.12), SILVER, 8, 5)


def bow(i):                                     # a ranged strike
    for s in (-1, 1):
        i.limb([(-0.30, 0.0, 0.52 * s), (0.16, 0.0, 0.34 * s),
                (0.26, 0.0, 0.0)], [0.035, 0.055, 0.06], BROWN, seg=5)
    i.limb([(-0.28, 0.0, 0.52), (-0.20, 0.0, 0.0), (-0.28, 0.0, -0.52)],
           [0.016, 0.016, 0.016], CREAM, seg=4, cap=False)
    i.slabf(0.06, 0.0, 0.34, 0.022, WHEAT)      # the arrow
    i.spike(0.46, 0.0, 0.075, 0.006, 0.16, SILVER, ang=math.pi / 2, seg=4)


def fire(i):                                    # burning damage
    # pass 3 (design/progress/fire_icon.md): the three main bodies used to be
    # straight spike() cones, which read as a rigid triangle cluster -- the
    # same silhouette family as peak()'s mountain spikes, and the reason
    # scoring capped both Family distinction and Mechanic match. A real flame
    # licks and curls; a mountain does not. Each body is now a limb() bent
    # through three points instead of a single straight taper, same base and
    # tip heights as before so the cluster's footprint and reach are unchanged.
    for pts, r, c in [
        ([(-0.22, 0.0, -0.41), (-0.28, 0.0, -0.05), (-0.14, 0.0, 0.21)],
         [0.16, 0.09, 0.01], ORANGE),
        ([(0.22, 0.0, -0.40), (0.30, 0.0, -0.14), (0.12, 0.0, 0.12)],
         [0.14, 0.08, 0.01], RUST),
        ([(0.0, 0.0, -0.41), (0.09, 0.0, 0.02), (-0.06, 0.0, 0.45)],
         [0.22, 0.13, 0.01], TANGERINE),
    ]:
        i.limb(pts, r, c, seg=6)
    # The hot core used to sit centred inside the TANGERINE cone's own radius
    # for its whole height, so it never had a chance to render -- one cone
    # fully enclosed inside a bigger one. Raised and lengthened so its tip
    # clears the TANGERINE tip (z=0.45) and pokes into open frame space.
    i.spike(0.0, 0.125, 0.16, 0.01, 0.85, GOLD, seg=6)


def skull(i):                                   # poison, wound, death
    i.slabf(0.0, 0.10, 0.32, 0.30, MINT, bevel=0.10)
    i.slabf(0.0, -0.30, 0.20, 0.14, MINT, bevel=0.05)
    for s in (-1, 1):
        i.ball((0.15 * s, -0.06, 0.14), (0.10, 0.09, 0.11), CHARCOAL, 7, 4)
    i.slabf(0.0, -0.14, 0.045, 0.06, CHARCOAL, bevel=0.0)
    for s in (-1, 0, 1):
        i.slabf(0.11 * s, -0.36, 0.030, 0.055, CHARCOAL, bevel=0.0)


def flask(i):                                   # a potion
    i.ball((0.0, 0.0, -0.16), (0.34, 0.22, 0.32), LILAC, 10, 6)
    i.slabf(0.0, 0.30, 0.10, 0.22, LILAC)
    i.slabf(0.0, 0.52, 0.15, 0.075, UMBER)      # cork
    i.ball((0.0, -0.10, -0.22), (0.24, 0.14, 0.20), VIOLET, 9, 5)
    i.ball((0.10, -0.14, 0.02), (0.055, 0.04, 0.055), ORCHID, 6, 4)


def climb(i):                                   # gain Height
    # pass 2 (design/progress/climb_icon.md): the old arrow-on-post shared
    # ascend's own outer silhouette almost exactly, and an up-arrow doesn't
    # say "climb" any more than it says "a big climb" -- the two cards need
    # different verb shapes, not two arrows of different size. Rebuilt as a
    # literal three-step staircase rising left to right, with a small marker
    # peg on the top step standing in for the climber, instead of a chevron.
    i.slabf(-0.32, -0.42, 0.20, 0.10, STONE)     # bottom step
    i.slabf(-0.06, -0.18, 0.20, 0.10, STONE)     # middle step
    i.slabf(0.20, 0.06, 0.20, 0.10, WHEAT)       # top step, lit to draw the eye up
    i.slabf(0.20, 0.28, 0.045, 0.14, WHEAT)      # a marker peg standing on the top step


def bomb(i):                                    # a big one-off blast
    i.ball((0.0, 0.0, -0.14), (0.36, 0.26, 0.36), GRAPHITE, 10, 6)
    i.slabf(0.0, 0.26, 0.10, 0.10, CHARCOAL)
    i.limb([(0.02, 0.0, 0.34), (0.16, 0.0, 0.50), (0.30, 0.0, 0.56)],
           [0.030, 0.024, 0.018], TAN, seg=4)
    i.ball((0.34, 0.0, 0.58), (0.10, 0.08, 0.10), ORANGE, 7, 4)
    i.ball((0.34, -0.04, 0.58), (0.055, 0.05, 0.055), GOLD, 6, 4)


def gadget(i):                                  # the Engineer builds something
    # pass 2 (design/progress/gadget_icon.md): two named lowest lines, one
    # cause. Mechanic match (5/10) -- three grey plates and one plain rivet
    # read as a totem or trophy, nothing in the shape says *assembled*.
    # Silhouette@42px (7/10) -- the same cause from the outline: the bottom
    # and middle slabs actually OVERLAPPED (bottom top -0.20 vs middle
    # bottom -0.22) and the middle/top gap was a bare 0.02, so at a real
    # downsample the three plates fused into one solid mass. Fixed the way
    # `plated_armour` fixed the identical symptom -- a real ~0.07-0.10
    # world-space gap between plates, not a shading trick -- plus a toothed
    # rivet (six small nubs around the ball, the same radial idea `cog`
    # already uses for its own gear teeth) so the one fastener reads as
    # hardware instead of a decorative dot.
    i.slabf(0.0, -0.36, 0.40, 0.11, PEWTER)
    i.slabf(0.0, -0.02, 0.26, 0.15, STEEL)
    i.slabf(0.0, 0.32, 0.32, 0.09, PEWTER)
    for s in (-1, 1):
        i.spike(0.30 * s, 0.44, 0.055, 0.02, 0.22, CARROT, ang=0.4 * s, seg=4)
    i.ball((0.0, -0.10, -0.02), (0.09, 0.06, 0.09), CARROT, 7, 4)
    for k in range(6):
        a = k * math.tau / 6.0
        i.ball((math.cos(a) * 0.12, -0.10, -0.02 + math.sin(a) * 0.12),
               (0.028, 0.045, 0.028), CARROT, 5, 3)


def draw(i):                                    # draw a card
    i.slabf(-0.16, -0.10, 0.24, 0.34, WHEAT, rot=0.18)
    i.slabf(0.06, 0.06, 0.24, 0.34, CREAM, rot=-0.10)
    # pass 2 (design/progress/draw_icon.md): base radius widened 0.16 -> 0.21
    # (+31%) so the arrowhead's triangular point survives a 42px downsample
    # instead of rounding off into a blunt wedge.
    i.spike(0.34, 0.30, 0.21, 0.02, 0.26, GOLD, seg=3)
    i.slabf(0.34, 0.06, 0.055, 0.16, GOLD)


def expose(i):                                  # mark a weak point
    i.ring((0.0, 0.0, 0.0), (0.42, 0.42, 0.42), AMBER, 18, 5, thickness=0.16)
    i.ring((0.0, 0.0, 0.0), (0.22, 0.22, 0.22), GOLD, 14, 5, thickness=0.24)
    # The centre mark is an angular shard, not `target`'s round ball, and the
    # corona is three uneven crack-lines instead of four symmetric ticks — a
    # weak point reads as a fracture, not a reticle, and the silhouette no
    # longer matches `target` at a glance.
    i.spike(0.0, 0.02, 0.11, 0.02, 0.20, BRICK, seg=5)
    i.spike(0.0, -0.02, 0.11, 0.02, 0.20, BRICK, ang=math.pi, seg=5)
    for ang, length in ((0.35, 1.10), (2.05, 1.04), (-1.15, 1.00)):
        i.spike(0.0, 0.0, 0.012, 0.03, length, BRICK, ang=ang, seg=4)


def taunt(i):                                   # pull the beast's attention
    i.spike(-0.30, -0.10, 0.055, 0.045, 0.90, UMBER, seg=4)   # the pole
    for k, (w, z, c) in enumerate([(0.44, 0.30, ORANGE), (0.34, 0.06, TANGERINE),
                                   (0.22, -0.14, ORANGE)]):
        i.slabf(-0.26 + w * 0.5, z, w * 0.5, 0.085, c)
    i.ball((-0.30, 0.0, 0.46), (0.095, 0.075, 0.095), GOLD, 7, 4)


def support(i):                                 # help the ally
    i.slabf(0.0, -0.16, 0.30, 0.20, MINT, bevel=0.07)
    for k, s in enumerate((-1.0, -0.33, 0.33, 1.0)):
        i.slabf(0.20 * s, 0.16, 0.055, 0.20 - abs(s) * 0.045, MINT)
    i.spike(-0.34, -0.02, 0.06, 0.05, 0.24, MINT, ang=-0.9, seg=4)
    i.ball((0.0, -0.10, 0.34), (0.12, 0.08, 0.12), GREEN, 7, 4)


def relic(i):                                   # a lasting boon
    i.spike(0.0, 0.16, 0.30, 0.02, 0.52, VIOLET, seg=6)
    i.spike(0.0, -0.02, 0.30, 0.02, 0.44, ORCHID, ang=math.pi, seg=6)
    i.ring((0.0, 0.10, 0.06), (0.34, 0.34, 0.34), GOLD, 16, 5, thickness=0.12)
    i.ball((0.0, -0.10, 0.06), (0.09, 0.055, 0.09), LILAC, 7, 4)


def rally(i):                                   # lift the whole party
    # A horn, not a crown. The first attempt was three flames over a bar and read
    # as a crown at 42px, which is a different card entirely. The second put a
    # backing plate in FRONT of everything: the camera sits at -Y, so a slab
    # centred on y=0 with any depth is nearer the lens than the icon it was
    # meant to sit behind. The third's bell sat clear of the limb with a visible
    # gap between them, and its call arcs, out past the frame's right edge,
    # never rendered at all.
    # rally_icon.md pass 3: the limb's shaded underside (measured off the
    # actual render, not the flat swatch) came out ~(181,127,57), a weak or
    # reversed gap against the (139,105,74) card standin on two of three
    # channels -- the same "flat swatch reads fine, shaded surface doesn't"
    # trap rope_icon.md's TAN->SAND swap fixed. SAND's own shaded value
    # keeps a real positive gap on all three channels.
    i.limb([(-0.50, 0.0, -0.30), (-0.16, 0.0, -0.36), (0.16, 0.0, -0.16)],
           [0.070, 0.095, 0.130], SAND, seg=6)
    i.taper((0.25, 0.0, -0.004), 0.12, 0.36, 0.36, GOLD, seg=8,
            rot=point((0.50, 0.0, 0.87)))
    i.ball((-0.54, 0.0, -0.28), (0.075, 0.06, 0.075), UMBER, 7, 4)
    # The call coming out of it: arcs, not rings, so nothing has to be hidden.
    # Pulled up clear of the bell and shrunk to sit inside the frame -- at the
    # old centre/radius they fell past the right edge and never rendered.
    # pass 3: radii 0.14/0.20 with a 0.055 tube radius meant the two arcs'
    # own thickness (0.11 combined) exceeded their 0.06 radius gap -- they
    # were touching, which is why they blurred into one pale accent at 42px
    # (rally_icon.md pass 2's own honest read). Widened the gap to 0.12 by
    # pulling the inner arc in, and thinned the tube so the two no longer
    # overlap; the outer radius (already confirmed in-frame) is untouched.
    for k, r in enumerate((0.08, 0.20)):
        pts = [(0.30 + math.cos(a) * r, 0.0, 0.42 + math.sin(a) * r)
               for a in (-0.75, -0.15, 0.45)]
        i.limb(pts, [0.040] * 3, ICE if k else WHITE, seg=4, cap=False)


def volley(i):                                  # several hits at once
    # Three separated marks along one diagonal, each capped by its own SILVER
    # spike touching the mark's own leading tip. The old version butted the
    # three RUST segments end to end -- they fused into one streak at 42px
    # (design/progress/volley_icon.md) -- and set the spikes at a fixed
    # offset that floated clear of all three rather than tracking them.
    rot = 0.5
    dx, dz = math.cos(rot), -math.sin(rot)        # the diagonal the marks run along
    hw, gap, spike_len = 0.11, 0.14, 0.13
    step = hw * 2 + gap
    ang = math.atan2(dx, dz)
    for k in (-1, 0, 1):
        cx, cz = dx * step * k, dz * step * k
        i.slabf(cx, cz, hw, 0.032, RUST, rot=rot)
        reach = hw + spike_len / 2
        i.spike(cx - dx * reach, cz - dz * reach, 0.075, 0.006, spike_len,
                SILVER, ang=ang, seg=4)


def guard(i):                                   # block, but timed
    i.slabf(0.0, 0.14, 0.30, 0.26, ICE, bevel=0.05)
    i.spike(0.0, -0.28, 0.30, 0.02, 0.46, ICE, ang=math.pi, seg=4)
    # Flared shoulder wings: `shield`'s outline is a plain kite, so a pair of
    # pointed flares at the shoulders separates `guard` by silhouette alone,
    # not just by the internal mark.
    for s in (-1, 1):
        i.spike(0.3675 * s, 0.2387, 0.045, 0.006, 0.14, ICE, ang=s * 1.3, seg=3)
    # The ring used to sit at y=-0.05, inside the body's own -0.10..0.10 depth
    # -- entirely behind the body's front face and invisible in every render,
    # which is the real reason no clock ever read here. Pulled to y=-0.12, in
    # front of that face, so it actually shows.
    i.ring((0.0, -0.12, 0.10), (0.20, 0.20, 0.20), STEEL, 14, 5, thickness=0.18)
    # Two hands from the ring's own centre, at a clear off-12 angle, replacing
    # the old pair of disconnected slabs that read as a letter "L" rather than
    # a clock. Kept short of the ring's tube (inner edge ~0.164) so neither
    # hand hides behind the rim, and pulled forward the same way the ring was.
    for x, z, length, ang in [(0.0336, 0.1614, 0.14, 0.5), (0.0206, 0.0657, 0.08, 2.6)]:
        i.spike(x, z, 0.016, 0.005, length, STEEL, ang=ang, seg=4).location.y = -0.12


def wall(i):                                    # block that scales
    # pass 2 (design/progress/wall_icon.md): two named fixes.
    # Silhouette @ 42px (6): off alternated 0.0/0.16 -- an uncentred
    # half-brick stagger whose rightmost column (x=0.48) cleared the ortho
    # frame's own +-0.575 half-extent and was clipped flush at the canvas
    # edge (bbox right = 256). Recentred to +-0.08 -- still a 0.16 relative
    # stagger row to row, the same running-bond offset -- so the widest
    # column now sits at 0.545, inside the frame on both sides.
    # Mechanic match / Colour & contrast (tied 6): PEWTER/STONE alternated
    # brick to brick with no row-to-row trend, so nothing suggested a wall
    # being built up. One shade per row now, darkest at the bottom rising to
    # lightest at the top -- a real gradient at 42px instead of a two-tone
    # flicker, with a bigger value gap between rows than the old checker had
    # between neighbours.
    for row, (z, off, uv) in enumerate([
        (-0.42, -0.08, STONE), (-0.16, 0.08, PEWTER),
        (0.10, -0.08, SLATE), (0.36, 0.08, STEEL)]):
        for k in (-1, 0, 1):
            i.slabf(k * 0.32 + off, z, 0.145, 0.105, uv)


def ascend(i):                                  # a big climb
    # Two arrowheads stacked with a visible gap between them, not one --
    # `climb`'s silhouette is a single triangle-on-post, and at 42px the two
    # shared almost the same outline, differing only in the small base
    # attachments (design/progress/ascend_icon.md, design/progress/
    # climb_icon.md name the same problem from opposite sides). Doubling the
    # chevron changes the outer shape instead of only its colour.
    i.spike(0.0, 0.42, 0.24, 0.02, 0.26, GOLD, seg=3)     # upper head, the tip
    i.spike(0.0, 0.06, 0.40, 0.06, 0.30, WHEAT, seg=3)    # lower head, blunt
    i.slabf(0.0, -0.24, 0.11, 0.20, WHEAT)                # the post below both
    for s in (-1, 1):
        i.spike(0.34 * s, -0.30, 0.075, 0.01, 0.34, GOLD, ang=0.3 * s, seg=4)
    # Darkened off the card-face brown standin -- the old TAN slab sat close
    # enough in value to nearly merge with it at 42px. Also pulled up clear
    # of the bottom edge: the old slab's low edge at z=-0.635 sat outside the
    # render frame (ortho half-extent 0.575) and was clipped.
    i.slabf(0.0, -0.48, 0.40, 0.07, CHARCOAL)


def rope(i):                                    # both hunters climb
    # pass 2 (design/progress/rope_icon.md): two named fixes. Colour &
    # contrast (3/10) -- TAN(217,152,111) against the brown card standin
    # RGB(139,105,74) sampled a weak per-channel gap; SAND(244,191,151) gives
    # a real one (+105/+86/+77) instead. Top/bottom edge clipping -- the old
    # stack's outer ring (radius 0.34 at z=+-0.42) reached z=+-0.76, well past
    # the camera's ortho half-extent of 0.575, so the coil ran off both the
    # top and bottom of the frame. Every ring's centre, radius and thickness
    # (and the carabiner's, at the same ratio) is scaled by one factor so the
    # coil keeps its proportions instead of being squashed on one axis; the
    # tallest ring now tops out at z=0.52, inside the frame with margin.
    for k in range(5):
        z = -0.23 + k * 0.115
        r = 0.289 - abs(k - 2) * 0.0255
        i.ring((0.0, 0.0, z), (r, r, 0.136), SAND, 14, 4,
               rot=(0.0, 0.0, 0.0), thickness=0.22)
    i.ring((0.255, 0.0, 0.274), (0.136, 0.136, 0.136), SILVER, 12, 4,
           thickness=0.255)


def lift(i):                                    # haul the ally to you
    # TWO of you, one hauling the other up. The first attempt was two offset
    # plates and read as a letter Z. Against its neighbours it has to be clearly
    # not `support` (one open hand) and not `rope` (a coil).
    #
    # pass 2 (design/progress/lift_icon.md): two named fixes. Colour & contrast
    # (6/10) -- GREEN and MINT sit in the same organic-green family and read as
    # one colour at both 256px and the 42px downsample; the upper-right figure
    # (the one being hauled up) is now TAN, matching the grip and arrow, so
    # "hauler" and "hauled" separate by colour as well as position. Mechanic
    # match (7/10) -- two identical upright blobs read as a static diagram, not
    # an action; the lower-left figure (doing the hauling) now leans into the
    # pull, the upper-right figure (already hauled) stays upright.
    for x, z, c, rot in [(-0.26, -0.34, GREEN, 0.35), (0.26, 0.24, TAN, 0.0)]:
        i.ball((x, 0.0, z + 0.20), (0.14, 0.10, 0.14), c, 8, 5)     # head
        i.slabf(x, z - 0.06, 0.15, 0.16, c, rot=rot, bevel=0.06)    # body
    i.limb([(-0.18, 0.0, -0.16), (0.0, 0.0, 0.02), (0.18, 0.0, 0.20)],
           [0.045, 0.045, 0.045], TAN, seg=5)                       # the grip
    i.spike(0.0, 0.44, 0.22, 0.02, 0.30, GOLD, seg=3)               # going up
    i.slabf(0.0, 0.20, 0.075, 0.14, GOLD)


def target(i):                                  # scales off Exposed
    i.ring((0.0, 0.0, 0.0), (0.48, 0.48, 0.48), GOLD, 18, 5, thickness=0.13)
    i.ring((0.0, 0.0, 0.0), (0.28, 0.28, 0.28), AMBER, 14, 5, thickness=0.20)
    i.ball((0.0, -0.06, 0.0), (0.10, 0.07, 0.10), BRICK, 7, 4)
    # pass 2 (design/progress/target_icon.md): the old shaft ran from almost
    # dead centre out to one edge, so the silhouette was still "two rings plus
    # one centre mark" -- the same family as expose's own double ring. Centred
    # on the ball and lengthened so it crosses the whole frame on both sides,
    # with the arrowhead moved out to the true outer tip instead of buried
    # near the centre, this reads as one diagonal line piercing straight
    # through the bullseye, a silhouette expose's shard-and-crack build
    # doesn't share.
    i.slabf(0.0, 0.0, 0.58, 0.028, SILVER, rot=-0.79)
    i.spike(0.39, 0.39, 0.075, 0.006, 0.22, BRICK, ang=0.79, seg=4)


def rhythm(i):                                  # the Frog's combo counter
    pts, rad = [], []
    for k in range(9):
        x = -0.52 + k * 0.13
        pts.append((x, 0.0, math.sin(k * math.pi / 2) * 0.30))
        rad.append(0.045)
    i.limb(pts, rad, SKY, seg=5, cap=False)
    for s in (-1, 1):
        i.ball((0.52 * s, 0.0, math.sin((8 if s > 0 else 0) * math.pi / 2) * 0.30),
               (0.09, 0.07, 0.09), ICE, 7, 4)
    i.slabf(0.0, -0.52, 0.44, 0.045, PERIWINKLE)


def timer(i):                                   # timed, nothing else
    i.slabf(0.0, 0.52, 0.34, 0.060, AMBER)
    i.slabf(0.0, -0.52, 0.34, 0.060, AMBER)
    i.spike(0.0, 0.20, 0.28, 0.03, 0.42, GOLD, ang=math.pi, seg=6)
    i.spike(0.0, -0.20, 0.28, 0.03, 0.42, GOLD, seg=6)
    i.ball((0.0, -0.04, -0.20), (0.16, 0.10, 0.10), WHEAT, 8, 5)


def cog(i):                                     # meld / fuse
    # pass 2 (design/progress/cog_icon.md): two named lowest lines.
    # Colour & contrast (5/10) pixel-sampled CLAY at a weak 29/5/9-per-channel
    # gap against the standin -- the smallest colour separation measured for
    # any icon under this item. PUMPKIN sits in the same warm-orange family
    # (this set's own palette.py, not a new swatch) but is both lighter and
    # more saturated, widening every channel's gap.
    # Silhouette@42px (7/10) named the seam where the two rings cross as the
    # one place teeth lose their square shape at a real downsample. Both
    # gears started their 6 teeth at k*tau/6 from angle zero, so a tooth
    # sits at the same absolute angle on both rings; offsetting the smaller
    # ring's teeth by half a step (tau/12) interleaves them with the larger
    # ring's teeth in the overlap zone instead of colliding with them --
    # the way two real meshing gears actually mesh.
    for cx, cz, r, c, phase in [(-0.16, 0.10, 0.30, PUMPKIN, 0.0),
                                 (0.24, -0.18, 0.22, PEWTER, math.tau / 12.0)]:
        i.ring((cx, 0.0, cz), (r, r, r), c, 14, 5, thickness=0.34)
        for k in range(6):
            a = phase + k * math.tau / 6.0
            i.slabf(cx + math.cos(a) * r * 1.12, cz + math.sin(a) * r * 1.12,
                    r * 0.20, r * 0.20, c, rot=0.0, bevel=0.012)
        i.ball((cx, -0.04, cz), (r * 0.28, r * 0.20, r * 0.28), UMBER, 6, 4)


def burn(i):                                    # exhaust a card
    i.slabf(-0.10, -0.06, 0.26, 0.38, LINEN, rot=0.12)
    i.slabf(-0.10, 0.16, 0.22, 0.10, CHARCOAL, rot=0.12)
    for x, z, h in [(0.22, 0.10, 0.44), (0.36, -0.06, 0.32), (0.10, 0.26, 0.30)]:
        i.spike(x, z, 0.10, 0.008, h, TANGERINE, seg=5)
    # pass 2 (design/progress/burn_icon.md): Family distinction (5/10) named
    # `draw` and this batch's own `stack` as the same base rectangle -- a
    # plain card slab plus one extra element, three times over. Biting a
    # jagged charred notch into the card's own top-right corner, right where
    # the flame already licks it, breaks the rectangle silhouette itself
    # instead of relying only on what sits behind it.
    for x, z, s in [(0.14, 0.30, 0.09), (0.20, 0.18, 0.07), (0.10, 0.36, 0.06),
                    (0.02, 0.32, 0.07), (0.16, 0.06, 0.05)]:
        i.spike(x, z, s, 0.01, s * 1.6, CHARCOAL, ang=0.9, seg=3)
    # Mechanic match (6/10): the three flame bodies pixel-sampled as one flat,
    # uniformly-lit brick/orange band with no brighter core -- the same
    # enclosed-hot-core trap `fire_icon.md` pass 2 found and fixed the same
    # way. A thin GOLD tip layered on the tallest cone, based low enough in
    # its body to emerge from inside it and tipped high enough to clear the
    # cone's own tip (z=0.10+0.22=0.32), reads as a glowing core rather than
    # a flat spike.
    i.spike(0.22, 0.22, 0.045, 0.006, 0.30, GOLD, seg=5)
    # pass 3 (#86 duty 1): Family (7/10) named the card BODY itself as still
    # the same plain LINEN slab `draw`/`stack` use, only one small corner
    # broken up by pass 2's three flecks. Two more CHARCOAL flecks spread the
    # jagged edge further along the top and down the right side, so the
    # charred silhouette reads as a bigger burnt bite out of the card rather
    # than a single small nick. Colour (7/10) named the BRICK/ORANGE cone
    # bodies as the icon's weakest-separated element against the brown card
    # standin; swapped both to TANGERINE, the same saturated flame tone
    # `fire()` already uses, for a stronger measured gap.


def stack(i):                                   # draw / hand size
    for k, (x, z, rot, c) in enumerate([(-0.26, -0.16, 0.30, WHEAT),
                                        (0.0, -0.06, 0.0, CREAM),
                                        (0.26, -0.16, -0.30, WHEAT)]):
        i.slabf(x, z, 0.20, 0.32, c, rot=rot)
    # pass 2 (design/progress/stack_icon.md): Family distinction (5/10) named
    # the plain TAN bar as the same "card slab plus one accent" gestalt as
    # draw's arrow and burn's flame, and Colour (6/10) named the same bar as
    # a near-miss against the brown card standin. Three GOLD pips in a
    # shallow arc replace the flat bar -- a "count" badge that differs in
    # silhouette from both siblings' single accent shapes, and GOLD carries a
    # far wider gap against the standin than TAN did.
    for x, z in [(-0.14, 0.30), (0.0, 0.38), (0.14, 0.30)]:
        i.ball((x, 0.0, z), (0.065, 0.05, 0.065), GOLD, 7, 4)


def peak(i):                                    # a strike that scales with Height
    # pass 2 (design/progress/peak_icon.md): two lowest lines.
    # Silhouette@42px (8) named real edge clipping at full size (alpha bbox
    # (4, 0, 256, 238) touched both the top and right edges before this pass)
    # -- the flagpole/flag reached z=0.67/0.675 and the back peak's own base
    # radius reached x=0.64, both past the frame's own +-0.575 half-extent
    # (FRAME=1.15). Pulled the back peak (and its snow cap, same x offset)
    # left by 0.09 so its base tops out at x=0.55, and shortened+lowered the
    # pole/flag so their top edge sits at z<=0.555 -- both now sit inside the
    # canvas with a real margin instead of relying on the 42px downsample to
    # hide the crop.
    # Mechanic match (6) named the icon as "a mountain" (terrain) rather than
    # "a strike" (the card's actual effect) -- added a small crack-burst at
    # the summit, same thin-to-wide radiating-spike vocabulary `expose()`
    # already uses for a fracture, so the peak reads as a point of impact.
    i.spike(-0.06, -0.06, 0.52, 0.02, 0.86, SLATE, seg=5)
    i.spike(0.25, -0.24, 0.30, 0.02, 0.50, PEWTER, seg=5)
    i.spike(-0.06, 0.30, 0.15, 0.02, 0.22, WHITE, seg=5)
    i.spike(0.21, 0.02, 0.075, 0.01, 0.12, WHITE, seg=5)
    i.spike(-0.06, 0.46, 0.020, 0.016, 0.18, UMBER, seg=4)
    i.slabf(0.10, 0.48, 0.16, 0.075, RED)
    for ang, length in ((-0.55, 0.16), (0.0, 0.20), (0.55, 0.16)):
        i.spike(-0.06, 0.34, 0.014, 0.035, length, BRICK, ang=ang, seg=4)


# ------------------------------------------------------- backlog #76, batch 2
#
# Four cards (ghost_step, overhang, hardshell, barbed_hide) grant Intangible,
# Buffer, Plated Armour and Thorns and were wearing `shield` — the Block icon
# — despite none of them granting Block. That is not crowding, it is a card
# telling the player the wrong thing about what it does. Each gets its own
# icon, built to differ from `shield`/`guard`/`wall` (the actual Block family)
# in silhouette, not just colour.

def intangible(i):                              # a hit past Block is capped at 1
    # A fading diagonal trail of the same diamond, three deep — one foot in
    # this world and one not, rather than a shield that isn't there.
    #
    # Pass 2 (design/progress/intangible_icon.md): the three diamonds
    # overlapped along their shared diagonal by up to 0.065 world units, so
    # they fused into one shaded bar at 42px instead of reading as three
    # separate steps. Pulled each tile further out along the same diagonal
    # so neighbours clear each other by a real ~0.09 units (Silhouette@42px,
    # scored 6). Separately, the nearest and palest tile (WHITE) was the one
    # scored closest to fading into the brown card face at 42px (Colour &
    # contrast, scored 5) — gave it a STEEL backing plate, pushed behind it
    # in depth (this scene's camera sits at -Y, so a larger Y is further
    # from the lens — see `rally()`'s note on the same trick), slightly
    # larger than the white diamond itself, so it shows only as a thin
    # contrasting rim around WHITE's own edge rather than a colour change to
    # WHITE.
    i.slabf(0.32, -0.32, 0.175, 0.175, STEEL, rot=0.785, bevel=0.02).location.y = 0.05
    i.slabf(0.32, -0.32, 0.13, 0.13, WHITE, rot=0.785, bevel=0.02)
    i.slabf(0.05, -0.05, 0.155, 0.155, ICE, rot=0.785, bevel=0.025)
    i.slabf(-0.25, 0.25, 0.18, 0.18, IRIS, rot=0.785, bevel=0.03)


def buffer(i):                                  # the next hit is cancelled outright
    # A hex-faceted energy bubble (low-segment ring, not the round `guard`
    # ring) with the stopped hit shown bouncing off it rather than landing.
    # pass 2 (design/progress/buffer_icon.md): Silhouette@42px (8) named the
    # ring's line weight thinning enough at 42px to round the six corners
    # toward an octagon. Thickened the outer ring by ~1/5 (0.11 -> 0.13) per
    # that pass's own concrete fix -- a thicker tube keeps more of each facet
    # flat before the downsample blurs it round.
    i.ring((0.0, 0.0, 0.0), (0.40, 0.40, 0.40), SKY, 6, 4, thickness=0.13)
    i.ring((0.0, 0.02, 0.0), (0.20, 0.20, 0.20), ICE, 6, 4, thickness=0.07)
    i.spike(0.32, 0.32, 0.02, 0.10, 0.24, BRICK, ang=2.36, seg=4)
    i.ball((0.0, -0.02, 0.0), (0.06, 0.05, 0.06), WHITE, 6, 4)


def plated_armour(i):                           # Block that survives the round
    # Three overlapping plates, widest and darkest at the bottom, narrowest
    # and palest at the top — lamellar scale rather than one kite shield, so
    # it can't be mistaken for `shield`, `guard` or the brick-grid `wall`.
    # pass 2 (design/progress/plated_armour_icon.md): the two lowest lines,
    # Mechanic match (5) and Silhouette@42px (7), traced to one cause -- the
    # old centres (-0.30/-0.02/0.26, step 0.28) at half-height 0.15 touched
    # with a 0.02 overlap, so nothing but a shading change told the plates
    # apart and they read as one tapered mass at 42px. Same fix `ascend` and
    # `intangible` already used for the same symptom: a real world-space gap,
    # not a colour cue. Widened the step to 0.31 and shrank half-height to
    # 0.12, opening a measured ~0.06-0.08 unit clearance on each seam.
    plates = [(-0.32, 0.44, PEWTER), (0.0, 0.38, STEEL), (0.30, 0.30, SILVER)]
    for z, w, c in plates:
        i.slabf(0.0, z, w * 0.5, 0.12, c, bevel=0.045)
    for x, z in [(-0.12, -0.32), (0.12, 0.0), (0.0, 0.30)]:
        i.ball((x, -0.07, z), (0.028, 0.02, 0.028), CHARCOAL, 5, 3)


def thorns(i):                                  # a landed attack reflects damage back
    # A thorn-ball, not a target ring or a blade: a core with spikes fanned
    # in every direction, two tipped red for the damage that comes back.
    # spike() centres its length on its base point, so a spike based AT the
    # core's own centre is half buried and never clears the surface — every
    # spike here is based out at the core's radius instead, so the visible
    # half is the half that actually pokes free of the ball.
    R, L = 0.15, 0.36
    i.ball((0.0, 0.0, 0.0), (0.20, 0.17, 0.20), GREEN, 8, 5)
    angs = [k * math.tau / 6.0 + 0.35 for k in range(6)]
    for a in angs:
        i.spike(math.sin(a) * R, math.cos(a) * R, 0.09, 0.006, L, UMBER, ang=a, seg=4)
    tip = R + L * 0.5
    for a in (angs[0], angs[3]):
        i.ball((math.sin(a) * tip, -0.02, math.cos(a) * tip),
               (0.05, 0.045, 0.05), BRICK, 6, 4)


# ------------------------------------------------------- backlog #76, batch 3
#
# `spark` (0-cost, "Gain 2 Light.", nothing else) wore `flask` — the potion
# icon — because `flask` was the closest "self-buff" glyph on hand when the
# Lightbearer's cards were first stamped. It is not a potion in any sense; the
# card doesn't touch Strength or Dexterity or a flask at all. The other seven
# Light cards (warm_glow, kindled_strike, beacon, guiding_light, steady_flame,
# flare, sunburst) all pair Light with a second effect — heal, block, damage —
# that IS their primary read, so `support`/`shield`/`sword` still tell the
# truth about them and are left alone. Only the pure-Light card was lying.

def light(i):                                   # generate Light (Lightbearer)
    # A warm radiant burst — straight rays from a bright core — so it can't be
    # mistaken for `fire`'s curved flame tongues or `expose`'s rings-and-ticks.
    # taper() centres a spike's length on its base point (the same trap
    # thorns' own comment names): a ray based AT the ball's centre only pokes
    # out by half its length, and half of that half is still buried inside
    # the ball. Basing each ray out at the ball's own radius, the way thorns
    # does, is what actually clears the surface.
    R = 0.15
    i.ball((0.0, 0.0, 0.0), (0.16, 0.13, 0.16), CREAM, 8, 5)
    for k in range(4):
        a = k * math.tau / 4.0
        i.spike(math.sin(a) * R, math.cos(a) * R, 0.05, 0.006, 0.74, GOLD, ang=a, seg=4)
    for k in range(4):
        a = k * math.tau / 4.0 + math.tau / 8.0
        i.spike(math.sin(a) * R, math.cos(a) * R, 0.038, 0.006, 0.34, AMBER, ang=a, seg=4)


# ------------------------------------------------------- backlog #76, batch 4
#
# `crippling_blow` ("Deal 5 damage. Frail 2.") wore `sword` — not wrong,
# exactly, since it IS a damage card, but `sword` is also worn by every plain
# hit with no second effect at all, so the one card that debuffs Block itself
# looked identical to one that doesn't. The four block-adjacent debuffs
# (Intangible, Buffer, Plated Armour, Thorns) already got this treatment in
# batch 2 because they wore `shield` while granting no Block; Frail is the
# same family — a Block-adjacent status — and the only card that grants it
# was still unmarked. Kept `sword` alone for every OTHER plain-damage card,
# same call batch 3 made for the seven Light cards that pair Light with a
# second effect already visible in their icon.

def frail(i):                # Block gained is reduced while this is stacked
    # A shield broken in two, not a whole one: `shield`/`guard`/`wall`/
    # `plated_armour` are all a single intact silhouette, so a split shield
    # with a jagged crack bridging the gap and a chip already fallen free
    # reads as "weakened" rather than "protected" even at card size.
    i.slabf(-0.20, 0.20, 0.24, 0.30, STEEL, bevel=0.045, rot=-0.12)
    i.spike(-0.20, -0.16, 0.24, 0.02, 0.34, STEEL, ang=math.pi - 0.20, seg=4)
    i.slabf(-0.20, 0.44, 0.24, 0.05, SILVER, rot=-0.12)
    # The right half used to mirror the left exactly -- its own rounded top
    # and its own clean taper to a point -- so it read as a second, complete
    # miniature shield rather than half of one broken shield (frail_icon.md's
    # scoring: two whole silhouettes side by side risk reading as MORE
    # protection, not less). Recut its bottom into an uneven jagged edge
    # instead of a point, and recoloured the whole half a cooler, darker
    # NAVY -- STEEL's near-zero red-channel gap against the warm card
    # standin was this icon's weakest measured contrast.
    i.slabf(0.22, 0.10, 0.24, 0.28, NAVY, bevel=0.045, rot=0.16)
    i.slabf(0.14, -0.24, 0.15, 0.16, NAVY, rot=0.62, bevel=0.02)
    i.slabf(0.27, -0.34, 0.11, 0.15, NAVY, rot=-0.40, bevel=0.02)
    i.slabf(0.19, -0.44, 0.09, 0.11, NAVY, rot=0.85, bevel=0.02)
    i.slabf(0.22, 0.34, 0.24, 0.05, SILVER, rot=0.16)
    for x, z, rot in [(0.0, 0.34, 0.30), (0.03, 0.14, -0.35),
                      (-0.02, -0.06, 0.35), (0.02, -0.26, -0.30)]:
        i.slabf(x, z, 0.028, 0.16, CHARCOAL, rot=rot, bevel=0.0)
    i.slabf(0.36, -0.56, 0.10, 0.11, SILVER, rot=0.55, bevel=0.02)


# ------------------------------------------------------- backlog #76, batch 5
#
# `sharpen`, `oil_can`, `alpine_focus` and `old_grudge` grant Strength, and
# `sure_footing` grants Dexterity — five cards, and every one of them wore
# `flask`, the potion icon, though none touches a potion at all. Batch 3's own
# comment already named this ("the card doesn't touch Strength or Dexterity or
# a flask at all") as a separate, un-fixed oddity, and `design/ART-REVIEW.md`'s
# batch 2 block left it explicitly for "a future one if it's worth it." Two
# icons, not one: Strength and Dexterity are already distinct keywords with
# their own tooltip text in `keywords.json`, and folding both into one
# generic "buff" glyph would just trade one wrong answer (potion) for another
# vague one.

def strength(i):                              # gain Strength (adds to every attack)
    # A dumbbell — two weight plates joined by a bar. Nothing else in the set
    # is symmetric plates-on-a-bar, so it can't be mistaken for `sword` (one
    # blade) or `bomb` (one central ball) even as a silhouette.
    i.slabf(0.0, 0.0, 0.34, 0.060, RUST, bevel=0.02)            # the bar
    for s in (-1, 1):
        i.ring((0.40 * s, 0.0, 0.0), (0.20, 0.20, 0.20), CHARCOAL, 14, 5,
               thickness=0.34)
        i.ring((0.40 * s, 0.03, 0.0), (0.11, 0.11, 0.11), GRAPHITE, 12, 4,
               thickness=0.30)
    i.slabf(0.0, 0.0, 0.09, 0.16, GOLD, bevel=0.02)             # the grip wrap


def dexterity(i):                             # gain Dexterity (adds to Block gained)
    # A single feather, kept to shapes this file already knows read cleanly.
    # Two earlier attempts (a column of flat plates, then two wide tapered
    # blades) both rendered wrong — a fir tree, then a tent with the barbs
    # floating clear of it — caught only by looking at the render, since
    # icons have no assetcheck. This one is one soft-edged vane (two
    # overlapping balls, the way `flask`'s body gets its two-tone shading),
    # capped with a straight-sided taper so the top comes to an actual point
    # instead of an ellipsoid's rounded dome, and a quill that runs the
    # full height and pokes past both the point and the vane's base rather
    # than clipping off-canvas below it, plus a few thin grooves across it
    # for barb texture, small enough to read as detail rather than define
    # the outline.
    i.ball((0.0, 0.0, 0.02), (0.30, 0.16, 0.364), SKY, 12, 8)          # the vane
    i.ball((-0.08, -0.05, 0.02), (0.20, 0.14, 0.338), ICE, 12, 8)      # its lit half
    i.spike(0.0, 0.40, 0.21, 0.01, 0.24, SKY, seg=6)                   # its pointed tip
    i.spike(0.0, 0.04, 0.020, 0.006, 1.00, TAN, seg=4)                 # the quill
    for k in range(4):                          # barb grooves, pulled in front of
        z = -0.18 + k * 0.16                    # both balls (y=-0.22) or they'd be
        i.box((0.0, -0.22, z), (0.15, 0.03, 0.012), WHITE, rot=(0.0, 0.4, 0.0))


ICONS = [
    ("sword", sword), ("shield", shield), ("bow", bow), ("fire", fire),
    ("skull", skull), ("flask", flask), ("climb", climb), ("bomb", bomb),
    ("gadget", gadget), ("draw", draw), ("expose", expose), ("taunt", taunt),
    ("support", support), ("relic", relic), ("rally", rally), ("volley", volley),
    ("guard", guard), ("wall", wall), ("ascend", ascend), ("rope", rope),
    ("lift", lift), ("target", target), ("rhythm", rhythm), ("timer", timer),
    ("cog", cog), ("burn", burn), ("stack", stack), ("peak", peak),
    ("intangible", intangible), ("buffer", buffer),
    ("plated_armour", plated_armour), ("thorns", thorns),
    ("light", light), ("frail", frail),
    ("strength", strength), ("dexterity", dexterity),
]


def render(out_path):
    sc = bpy.context.scene
    sc.render.engine = "BLENDER_WORKBENCH"
    sc.display.shading.light = "STUDIO"
    sc.display.shading.color_type = "TEXTURE"
    sc.display.shading.show_shadows = False
    sc.display.shading.show_cavity = True
    sc.render.film_transparent = True
    sc.view_settings.exposure = 0.85     # read at 42 pixels, not at 256
    sc.render.resolution_x = sc.render.resolution_y = SIZE
    sc.render.image_settings.file_format = "PNG"
    sc.render.image_settings.color_mode = "RGBA"

    # Head-on, from -Y. An icon is a silhouette; a three-quarter view of a small
    # object is a smudge.
    bpy.ops.object.camera_add(location=(0.0, -8.0, 0.0))
    cam = bpy.context.object
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = FRAME
    cam.rotation_euler = Vector((0.0, 1.0, 0.0)).to_track_quat("-Z", "Y").to_euler()
    sc.camera = cam
    sc.render.filepath = out_path
    bpy.ops.render.render(write_still=True)


def main():
    out_dir = sys.argv[sys.argv.index("--") + 1]
    for name, build in ICONS:
        icon = Icon()
        build(icon)
        icon.done(os.path.join(out_dir, "tmp_" + name + ".glb"), name)
        render(os.path.join(out_dir, name + ".png"))
        os.remove(os.path.join(out_dir, "tmp_" + name + ".glb"))
        print("ICON", name)


main()
