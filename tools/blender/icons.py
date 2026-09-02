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
    i.slabf(-0.10, -0.44, 0.42, 0.10, STONE)    # two steps
    i.slabf(0.14, -0.16, 0.30, 0.10, STONE)
    i.spike(0.0, 0.26, 0.30, 0.02, 0.44, WHEAT, seg=3)   # the arrow up
    i.slabf(0.0, -0.02, 0.10, 0.26, WHEAT)


def bomb(i):                                    # a big one-off blast
    i.ball((0.0, 0.0, -0.14), (0.36, 0.26, 0.36), GRAPHITE, 10, 6)
    i.slabf(0.0, 0.26, 0.10, 0.10, CHARCOAL)
    i.limb([(0.02, 0.0, 0.34), (0.16, 0.0, 0.50), (0.30, 0.0, 0.56)],
           [0.030, 0.024, 0.018], TAN, seg=4)
    i.ball((0.34, 0.0, 0.58), (0.10, 0.08, 0.10), ORANGE, 7, 4)
    i.ball((0.34, -0.04, 0.58), (0.055, 0.05, 0.055), GOLD, 6, 4)


def gadget(i):                                  # the Engineer builds something
    i.slabf(0.0, -0.34, 0.40, 0.14, PEWTER)
    i.slabf(0.0, -0.02, 0.26, 0.20, STEEL)
    i.slabf(0.0, 0.30, 0.32, 0.10, PEWTER)
    for s in (-1, 1):
        i.spike(0.30 * s, 0.44, 0.055, 0.02, 0.22, CARROT, ang=0.4 * s, seg=4)
    i.ball((0.0, -0.10, -0.02), (0.09, 0.06, 0.09), CARROT, 7, 4)


def draw(i):                                    # draw a card
    i.slabf(-0.16, -0.10, 0.24, 0.34, WHEAT, rot=0.18)
    i.slabf(0.06, 0.06, 0.24, 0.34, CREAM, rot=-0.10)
    i.spike(0.34, 0.30, 0.16, 0.02, 0.26, GOLD, seg=3)
    i.slabf(0.34, 0.06, 0.055, 0.16, GOLD)


def expose(i):                                  # mark a weak point
    i.ring((0.0, 0.0, 0.0), (0.42, 0.42, 0.42), AMBER, 18, 5, thickness=0.16)
    i.ring((0.0, 0.0, 0.0), (0.22, 0.22, 0.22), GOLD, 14, 5, thickness=0.24)
    i.ball((0.0, -0.06, 0.0), (0.09, 0.06, 0.09), BRICK, 7, 4)
    for s in (-1, 1):
        i.slabf(0.56 * s, 0.0, 0.09, 0.030, AMBER, bevel=0.0)
        i.slabf(0.0, 0.56 * s, 0.030, 0.09, AMBER, bevel=0.0)


def taunt(i):                                   # pull the beast's attention
    i.spike(-0.30, -0.10, 0.055, 0.045, 0.90, UMBER, seg=4)   # the pole
    for k, (w, z, c) in enumerate([(0.44, 0.30, ORANGE), (0.34, 0.06, TANGERINE),
                                   (0.22, -0.14, ORANGE)]):
        i.slabf(-0.26 + w * 0.5, z, w * 0.5, 0.085, c)
    i.ball((-0.30, 0.0, 0.44), (0.075, 0.06, 0.075), GOLD, 7, 4)


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
    i.limb([(-0.50, 0.0, -0.30), (-0.16, 0.0, -0.36), (0.16, 0.0, -0.16)],
           [0.070, 0.095, 0.130], AMBER, seg=6)
    i.taper((0.25, 0.0, -0.004), 0.12, 0.36, 0.36, GOLD, seg=8,
            rot=point((0.50, 0.0, 0.87)))
    i.ball((-0.54, 0.0, -0.28), (0.075, 0.06, 0.075), UMBER, 7, 4)
    # The call coming out of it: arcs, not rings, so nothing has to be hidden.
    # Pulled up clear of the bell and shrunk to sit inside the frame -- at the
    # old centre/radius they fell past the right edge and never rendered.
    for k, r in enumerate((0.14, 0.20)):
        pts = [(0.30 + math.cos(a) * r, 0.0, 0.42 + math.sin(a) * r)
               for a in (-0.75, -0.15, 0.45)]
        i.limb(pts, [0.055] * 3, ICE if k else WHITE, seg=4, cap=False)


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
    for row, (z, off) in enumerate([(-0.42, 0.0), (-0.16, 0.16), (0.10, 0.0),
                                    (0.36, 0.16)]):
        for k in (-1, 0, 1):
            i.slabf(k * 0.32 + off, z, 0.145, 0.105,
                    PEWTER if (row + k) % 2 else STONE)


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
    for k in range(5):
        z = -0.42 + k * 0.21
        i.ring((0.0, 0.0, z), (0.34 - abs(k - 2) * 0.03,
                               0.34 - abs(k - 2) * 0.03, 0.16), TAN, 14, 4,
               rot=(0.0, 0.0, 0.0), thickness=0.22)
    i.ring((0.30, 0.0, 0.50), (0.16, 0.16, 0.16), SILVER, 12, 4, thickness=0.30)


def lift(i):                                    # haul the ally to you
    # TWO of you, one hauling the other up. The first attempt was two offset
    # plates and read as a letter Z. Against its neighbours it has to be clearly
    # not `support` (one open hand) and not `rope` (a coil).
    for x, z, c in [(-0.26, -0.34, GREEN), (0.26, 0.24, MINT)]:
        i.ball((x, 0.0, z + 0.20), (0.14, 0.10, 0.14), c, 8, 5)     # head
        i.slabf(x, z - 0.06, 0.15, 0.16, c, bevel=0.06)             # body
    i.limb([(-0.18, 0.0, -0.16), (0.0, 0.0, 0.02), (0.18, 0.0, 0.20)],
           [0.045, 0.045, 0.045], TAN, seg=5)                       # the grip
    i.spike(0.0, 0.44, 0.22, 0.02, 0.30, GOLD, seg=3)               # going up
    i.slabf(0.0, 0.20, 0.075, 0.14, GOLD)


def target(i):                                  # scales off Exposed
    i.ring((0.0, 0.0, 0.0), (0.48, 0.48, 0.48), GOLD, 18, 5, thickness=0.13)
    i.ring((0.0, 0.0, 0.0), (0.28, 0.28, 0.28), AMBER, 14, 5, thickness=0.20)
    i.ball((0.0, -0.06, 0.0), (0.10, 0.07, 0.10), BRICK, 7, 4)
    i.slabf(0.22, 0.22, 0.30, 0.028, SILVER, rot=-0.79)
    i.spike(0.06, 0.06, 0.075, 0.006, 0.16, BRICK, ang=-2.36, seg=4)


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
    for cx, cz, r, c in [(-0.16, 0.10, 0.30, CLAY), (0.24, -0.18, 0.22, PEWTER)]:
        i.ring((cx, 0.0, cz), (r, r, r), c, 14, 5, thickness=0.34)
        for k in range(6):
            a = k * math.tau / 6.0
            i.slabf(cx + math.cos(a) * r * 1.12, cz + math.sin(a) * r * 1.12,
                    r * 0.20, r * 0.20, c, rot=0.0, bevel=0.012)
        i.ball((cx, -0.04, cz), (r * 0.28, r * 0.20, r * 0.28), UMBER, 6, 4)


def burn(i):                                    # exhaust a card
    i.slabf(-0.10, -0.06, 0.26, 0.38, LINEN, rot=0.12)
    i.slabf(-0.10, 0.16, 0.22, 0.10, CHARCOAL, rot=0.12)
    for x, z, h in [(0.22, 0.10, 0.44), (0.36, -0.06, 0.32), (0.10, 0.26, 0.30)]:
        i.spike(x, z, 0.10, 0.008, h, BRICK if x > 0.2 else ORANGE, seg=5)


def stack(i):                                   # draw / hand size
    for k, (x, z, rot, c) in enumerate([(-0.26, -0.16, 0.30, WHEAT),
                                        (0.0, -0.06, 0.0, CREAM),
                                        (0.26, -0.16, -0.30, WHEAT)]):
        i.slabf(x, z, 0.20, 0.32, c, rot=rot)
    i.slabf(0.0, 0.34, 0.30, 0.055, TAN)


def peak(i):                                    # a strike that scales with Height
    i.spike(-0.06, -0.06, 0.52, 0.02, 0.86, SLATE, seg=5)
    i.spike(0.34, -0.24, 0.30, 0.02, 0.50, PEWTER, seg=5)
    i.spike(-0.06, 0.30, 0.15, 0.02, 0.22, WHITE, seg=5)
    i.spike(0.30, 0.02, 0.075, 0.01, 0.12, WHITE, seg=5)
    i.spike(-0.06, 0.52, 0.020, 0.016, 0.30, UMBER, seg=4)
    i.slabf(0.10, 0.60, 0.16, 0.075, RED)


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
    i.slabf(0.26, -0.26, 0.15, 0.15, WHITE, rot=0.785, bevel=0.02)
    i.slabf(0.08, -0.08, 0.17, 0.17, ICE, rot=0.785, bevel=0.025)
    i.slabf(-0.14, 0.14, 0.19, 0.19, IRIS, rot=0.785, bevel=0.03)


def buffer(i):                                  # the next hit is cancelled outright
    # A hex-faceted energy bubble (low-segment ring, not the round `guard`
    # ring) with the stopped hit shown bouncing off it rather than landing.
    i.ring((0.0, 0.0, 0.0), (0.40, 0.40, 0.40), SKY, 6, 4, thickness=0.11)
    i.ring((0.0, 0.02, 0.0), (0.20, 0.20, 0.20), ICE, 6, 4, thickness=0.07)
    i.spike(0.32, 0.32, 0.02, 0.10, 0.24, BRICK, ang=2.36, seg=4)
    i.ball((0.0, -0.02, 0.0), (0.06, 0.05, 0.06), WHITE, 6, 4)


def plated_armour(i):                           # Block that survives the round
    # Three overlapping plates, widest and darkest at the bottom, narrowest
    # and palest at the top — lamellar scale rather than one kite shield, so
    # it can't be mistaken for `shield`, `guard` or the brick-grid `wall`.
    for z, w, c in [(-0.30, 0.44, PEWTER), (-0.02, 0.38, STEEL), (0.26, 0.30, SILVER)]:
        i.slabf(0.0, z, w * 0.5, 0.15, c, bevel=0.045)
    for x, z in [(-0.12, -0.30), (0.12, -0.02), (0.0, 0.26)]:
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
    # overlapping balls, the way `flask`'s body gets its two-tone shading)
    # with the quill poking through both ends and it, and a few thin grooves
    # across it for barb texture, small enough to read as detail rather than
    # define the outline.
    i.ball((0.0, 0.0, 0.02), (0.30, 0.16, 0.56), SKY, 12, 8)          # the vane
    i.ball((-0.08, -0.05, 0.02), (0.20, 0.14, 0.52), ICE, 12, 8)      # its lit half
    i.spike(0.0, -0.58, 0.020, 0.006, 1.20, TAN, seg=4)                # the quill
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
