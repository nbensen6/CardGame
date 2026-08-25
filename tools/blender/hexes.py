"""The overworld map, in our own art.

The map between fights is the last obviously borrowed screen: Kenney hex tiles
with Kenney trees on them and Kenney buildings for every node. Now that all
fourteen fights have ground of their own it is the thing that looks least like
the rest of the game.

One script builds ALL of them, because a hex tile is thirty triangles and
launching Blender seventeen times to make seventeen of those is silly:

    blender --background --python tools/blender/hexes.py -- <out_dir>

**The footprint is not ours to choose.** Both map views lay tiles out on a fixed
grid (HEX_W 1.0, HEX_D 1.154701), so every tile has to be a pointy-top hexagon
exactly 1.0 across in X and 1.1547 in Y, sitting on z=0. Kenney's are, and the
grid was written against them. Get this wrong and the map has gaps.

Landmarks sit on the same footprint and are allowed to be tall — the node
buildings run to about 0.77 in Kenney's set and the camera looks down at them.
"""
import bpy, math, os, random, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, BUDGET, point, aim, GREEN, MINT, BROWN, UMBER, CLAY,
                    TAN, SAND, WHEAT, CREAM, LINEN, STONE, PEWTER, SLATE,
                    GRAPHITE, CHARCOAL, SILVER, STEEL, NAVY, INDIGO, SKY, ICE,
                    WHITE, GOLD, AMBER, ORANGE, RED, CORAL, ROSE, VIOLET,
                    ORCHID, LILAC, IRIS, MIDNIGHT, PERIWINKLE, RUST)

## The grid the two map views already use. Not negotiable — see the docstring.
HEX_R = 0.57735            # circumradius: 1.0 across the flats in X
TOP = 0.20                 # how thick a plain tile is

BUDGET["tile"] = 460
BUDGET["landmark"] = 900


class Tile(Build):
    """One hex. Same vocabulary as Build; no rescaling at the end."""

    def __init__(self, seed=0):
        super().__init__()
        self.rng = random.Random(seed)

    def base(self, side, top, thick=TOP):
        """The hex prism, with a thin cap of a second colour on it.

        The cap is what makes a tile read as grass ON earth rather than as a
        solid green block, and it is one extra face per tile.
        """
        # No rotation. Blender's cone puts its first vertex at +Y already, which
        # is the pointy-top orientation the grid wants; turning it by a quarter
        # is what BREAKS it, and the tile comes out 1.155 wide and 1.0 deep.
        self.taper((0.0, 0.0, thick * 0.5), HEX_R, HEX_R, thick, side, seg=6)
        self.taper((0.0, 0.0, thick - 0.012), HEX_R * 0.995, HEX_R * 0.995,
                   0.05, top, seg=6)

    def dot(self, n, make, spread=0.40, z=TOP):
        """Scatter n small things on the tile face, inside the hexagon."""
        for i in range(n):
            a = self.rng.random() * math.tau
            d = math.sqrt(self.rng.random()) * spread
            make(math.cos(a) * d, math.sin(a) * d, z, self.rng)

    def conifer(self, x, y, z, size=1.0, trunk=BROWN, leaf=GREEN, tiers=3):
        self.taper((x, y, z + 0.03 * size), 0.022 * size, 0.018 * size,
                   0.09 * size, trunk, seg=5)
        for i in range(tiers):
            t = i / max(1.0, tiers - 1.0)
            self.taper((x, y, z + size * (0.10 + 0.085 * i)),
                       size * (0.085 - 0.028 * t), size * 0.006,
                       size * 0.13, leaf if i % 2 == 0 else MINT, seg=6)

    def hut(self, x, y, z, w=0.16, h=0.13, wall=CREAM, roof=RUST, rot=0.0):
        self.box((x, y, z + h * 0.5), (w, w * 0.82, h), wall, bevel=0.012,
                 rot=(0.0, 0.0, rot))
        self.taper((x, y, z + h + w * 0.42), w * 1.26, w * 0.06, w * 0.86, roof,
                   seg=4, rot=(0.0, 0.0, rot + math.pi / 4))

    def done(self, out, name, budget="tile"):
        self.finish(out, height=None, name=name, budget=budget)


# --------------------------------------------------------------------- tiles

def grass(t):
    t.base(UMBER, GREEN)
    t.dot(5, lambda x, y, z, r: t.ball((x, y, z + 0.01), (0.045, 0.038, 0.014),
                                       MINT if r.random() < 0.4 else GREEN, 5, 3))
    t.dot(2, lambda x, y, z, r: t.ball((x, y, z + 0.012), (0.030, 0.026, 0.016),
                                       PEWTER, 5, 3))


def grass_forest(t):
    t.base(UMBER, GREEN)
    for x, y, s in [(-0.16, 0.10, 1.0), (0.14, 0.16, 0.82), (0.05, -0.16, 0.92),
                    (-0.12, -0.22, 0.72)]:
        t.conifer(x, y, TOP, s)
    t.dot(3, lambda x, y, z, r: t.ball((x, y, z + 0.01), (0.04, 0.034, 0.013),
                                       MINT, 5, 3), spread=0.44)


def grass_hill(t):
    t.base(UMBER, GREEN)
    t.ball((0.02, -0.02, TOP - 0.02), (0.34, 0.30, 0.20), BROWN, 8, 5)
    t.ball((0.02, -0.02, TOP + 0.05), (0.31, 0.27, 0.14), GREEN, 8, 5)
    t.conifer(-0.18, 0.16, TOP, 0.72)
    t.dot(3, lambda x, y, z, r: t.ball((x, y, z), (0.035, 0.030, 0.014),
                                       MINT, 5, 3), spread=0.44)


def stone(t):
    t.base(GRAPHITE, PEWTER)
    t.dot(4, lambda x, y, z, r: t.ball((x, y, z + 0.01),
                                       (0.055, 0.046, 0.030), SLATE, 6, 4,
                                       rot=(0, 0, r.random() * math.tau)))
    t.dot(2, lambda x, y, z, r: t.ball((x, y, z), (0.035, 0.030, 0.012), MINT, 5, 3))


def stone_hill(t):
    t.base(GRAPHITE, PEWTER)
    t.ball((0.0, 0.0, TOP - 0.03), (0.33, 0.29, 0.22), SLATE, 8, 5)
    t.box((0.10, -0.10, TOP + 0.16), (0.09, 0.075, 0.10), PEWTER, bevel=0.014,
          rot=(0.10, 0.06, 0.5))
    t.box((-0.12, 0.08, TOP + 0.12), (0.07, 0.06, 0.08), SLATE, bevel=0.012,
          rot=(0.0, -0.12, 1.1))


def stone_mountain(t):
    t.base(GRAPHITE, PEWTER)
    t.taper((0.0, 0.0, TOP + 0.26), 0.36, 0.055, 0.56, SLATE, seg=7)
    t.taper((0.0, 0.0, TOP + 0.50), 0.10, 0.020, 0.12, WHITE, seg=7)
    t.taper((0.20, 0.14, TOP + 0.15), 0.16, 0.03, 0.34, PEWTER, seg=6,
            rot=(0.14, 0.10, 0.0))
    t.taper((-0.19, -0.12, TOP + 0.12), 0.13, 0.025, 0.28, PEWTER, seg=6,
            rot=(-0.10, -0.12, 0.0))


def sand(t):
    t.base(TAN, SAND)
    t.dot(4, lambda x, y, z, r: t.ball((x, y, z - 0.01), (0.12, 0.06, 0.022),
                                       WHEAT, 6, 4,
                                       rot=(0, 0, 0.6 + r.random() * 0.4)))
    t.dot(2, lambda x, y, z, r: t.ball((x, y, z + 0.01), (0.03, 0.026, 0.014),
                                       CLAY, 5, 3))


def dirt(t):
    t.base(CHARCOAL, UMBER)
    for i in range(3):
        t.box((0.0, -0.22 + i * 0.22, TOP + 0.005), (0.40, 0.030, 0.012), CLAY,
              bevel=0.0, rot=(0.0, 0.0, 0.12 * (i - 1)))
    t.dot(3, lambda x, y, z, r: t.ball((x, y, z), (0.028, 0.024, 0.012),
                                       PEWTER, 5, 3))


def water(t):
    t.base(MIDNIGHT, NAVY)
    t.taper((0.0, 0.0, TOP + 0.005), HEX_R * 0.93, HEX_R * 0.93, 0.045, STEEL,
            seg=6)
    for i, (y, w) in enumerate([(-0.20, 0.28), (0.02, 0.34), (0.24, 0.24)]):
        t.box((0.0, y, TOP + 0.030), (w, 0.020, 0.010), ICE, bevel=0.0)


# ----------------------------------------------------------------- landmarks

def building_cabin(t):
    """Rest. A hut with a fire outside it — the fire is the read at map size."""
    grass(t)
    t.hut(-0.08, 0.06, TOP, w=0.20, h=0.16, wall=LINEN, roof=RUST, rot=0.25)
    t.box((-0.08, -0.10, TOP + 0.30), (0.035, 0.035, 0.06), GRAPHITE, bevel=0.01)
    for i in range(5):
        a = i * math.tau / 5.0
        t.taper((0.20 + math.cos(a) * 0.055, -0.16 + math.sin(a) * 0.050,
                 TOP + 0.035), 0.014, 0.005, 0.10, BROWN, seg=4,
                rot=point((math.cos(a) * 0.55, math.sin(a) * 0.55, 1.0)))
    t.taper((0.20, -0.16, TOP + 0.09), 0.055, 0.008, 0.13, ORANGE, seg=6)
    t.ball((0.20, -0.16, TOP + 0.05), (0.045, 0.045, 0.03), GOLD, 6, 4)


def building_market(t):
    """Shop. A stall with a striped awning: the stripes are what carry it."""
    grass(t)
    t.box((0.0, 0.02, TOP + 0.075), (0.24, 0.16, 0.075), UMBER, bevel=0.014)
    for sx in (-1, 1):
        for sy in (-1, 1):
            t.taper((0.22 * sx, 0.16 * sy, TOP + 0.13), 0.016, 0.014, 0.26,
                    BROWN, seg=4)
    for i in range(5):
        t.box((-0.20 + i * 0.10, 0.02, TOP + 0.28), (0.05, 0.19, 0.014),
              CORAL if i % 2 else CREAM, bevel=0.0, rot=(0.16, 0.0, 0.0))
    t.box((-0.10, -0.16, TOP + 0.045), (0.055, 0.048, 0.045), CLAY, bevel=0.012,
          rot=(0, 0, 0.4))
    t.box((0.02, -0.18, TOP + 0.035), (0.045, 0.040, 0.035), TAN, bevel=0.010,
          rot=(0, 0, -0.3))
    t.ball((0.16, -0.14, TOP + 0.035), (0.035, 0.035, 0.035), GOLD, 6, 4)


def building_tower(t):
    """A fight. A watchtower: one straight vertical, which nothing else has."""
    grass(t)
    t.taper((0.0, 0.0, TOP + 0.22), 0.16, 0.125, 0.44, PEWTER, seg=8)
    t.taper((0.0, 0.0, TOP + 0.46), 0.185, 0.175, 0.07, SLATE, seg=8)
    for i in range(6):
        a = i * math.tau / 6.0 + 0.2
        t.box((math.cos(a) * 0.155, math.sin(a) * 0.155, TOP + 0.535),
              (0.035, 0.035, 0.045), SLATE, bevel=0.008,
              rot=(0.0, 0.0, a))
    t.box((0.0, -0.13, TOP + 0.12), (0.035, 0.02, 0.055), CHARCOAL, bevel=0.0)
    t.ball((0.0, -0.14, TOP + 0.36), (0.028, 0.020, 0.028), AMBER, 5, 3)


def building_castle(t):
    """An elite. Bigger, squarer, and the only thing on the map with a banner."""
    stone(t)
    t.box((0.0, 0.02, TOP + 0.16), (0.26, 0.20, 0.16), SILVER, bevel=0.018)
    for sx in (-1, 1):
        t.taper((0.24 * sx, 0.16, TOP + 0.24), 0.085, 0.075, 0.48, PEWTER, seg=7)
        t.taper((0.24 * sx, 0.16, TOP + 0.52), 0.105, 0.010, 0.14, RED, seg=7)
    for i in range(5):
        t.box((-0.20 + i * 0.10, -0.17, TOP + 0.355), (0.035, 0.035, 0.045),
              SILVER, bevel=0.008)
    t.box((0.0, -0.19, TOP + 0.10), (0.05, 0.02, 0.075), GRAPHITE, bevel=0.0)
    t.taper((-0.02, 0.30, TOP + 0.22), 0.012, 0.010, 0.44, BROWN, seg=4)
    t.box((0.06, 0.30, TOP + 0.38), (0.075, 0.008, 0.045), RED, bevel=0.0)


def building_wizard_tower(t):
    """An event. It LEANS, and its roof is lit — the only violet on the map."""
    grass(t)
    t.taper((0.03, 0.0, TOP + 0.26), 0.13, 0.095, 0.52, INDIGO, seg=8,
            rot=(0.0, -0.09, 0.0))
    t.taper((0.075, 0.0, TOP + 0.60), 0.155, 0.008, 0.30, VIOLET, seg=8,
            rot=(0.0, -0.09, 0.0))
    t.ball((0.085, 0.0, TOP + 0.78), (0.035, 0.035, 0.040), ORCHID, 6, 4)
    for i, (z, s) in enumerate([(0.14, 1.0), (0.34, 0.9), (0.50, 0.8)]):
        t.ball((0.03 + z * 0.09, -0.10 * s, TOP + z), (0.026, 0.018, 0.026),
               LILAC if i % 2 else IRIS, 5, 3)
    t.conifer(-0.26, 0.18, TOP, 0.62, BROWN, GREEN)


def building_mine(t):
    """Treasure. A cut into the hillside with something bright inside it."""
    stone_hill(t)
    t.box((0.0, -0.22, TOP + 0.10), (0.115, 0.075, 0.10), CHARCOAL, bevel=0.0)
    for sx in (-1, 1):
        t.box((0.115 * sx, -0.24, TOP + 0.11), (0.022, 0.022, 0.115), BROWN,
              bevel=0.006)
    t.box((0.0, -0.24, TOP + 0.235), (0.145, 0.024, 0.022), BROWN, bevel=0.006)
    t.ball((0.0, -0.19, TOP + 0.055), (0.055, 0.035, 0.035), GOLD, 6, 4)
    t.box((0.20, -0.10, TOP + 0.045), (0.055, 0.040, 0.040), UMBER, bevel=0.010,
          rot=(0, 0, 0.5))
    t.ball((0.20, -0.10, TOP + 0.095), (0.040, 0.030, 0.020), AMBER, 5, 3)


def building_village(t):
    grass(t)
    t.hut(-0.16, 0.10, TOP, w=0.13, h=0.10, wall=LINEN, roof=RUST, rot=0.3)
    t.hut(0.14, 0.14, TOP, w=0.11, h=0.09, wall=CREAM, roof=CLAY, rot=-0.4)
    t.hut(0.04, -0.16, TOP, w=0.14, h=0.11, wall=LINEN, roof=RUST, rot=0.1)
    t.conifer(-0.24, -0.18, TOP, 0.60)


def unit_tree(t):
    """The loose prop the location screen dots around its plot. No hex under it."""
    t.conifer(0.0, 0.0, 0.0, 1.9, BROWN, GREEN, tiers=3)


TILES = [
    ("grass", grass, "tile"), ("grass-forest", grass_forest, "tile"),
    ("grass-hill", grass_hill, "tile"), ("stone", stone, "tile"),
    ("stone-hill", stone_hill, "tile"), ("stone-mountain", stone_mountain, "tile"),
    ("sand", sand, "tile"), ("dirt", dirt, "tile"), ("water", water, "tile"),
    ("building-cabin", building_cabin, "landmark"),
    ("building-market", building_market, "landmark"),
    ("building-tower", building_tower, "landmark"),
    ("building-castle", building_castle, "landmark"),
    ("building-wizard-tower", building_wizard_tower, "landmark"),
    ("building-mine", building_mine, "landmark"),
    ("building-village", building_village, "landmark"),
    ("unit-tree", unit_tree, "tile"),
]


def main():
    out_dir = sys.argv[sys.argv.index("--") + 1]
    for i, (name, build, budget) in enumerate(TILES):
        t = Tile(seed=100 + i * 7)
        build(t)
        t.done(os.path.join(out_dir, name + ".glb"),
               name.replace("-", "_"), budget=budget)
        # The grid is the one thing that cannot be got wrong quietly: a tile a
        # few millimetres off leaves a seam on every edge of every map.
        me = bpy.context.object.data
        xs = [v.co.x for v in me.vertices]
        ys = [v.co.y for v in me.vertices]
        if budget == "tile" and name != "unit-tree":
            w, d = max(xs) - min(xs), max(ys) - min(ys)
            if abs(w - 1.0) > 0.02 or abs(d - 1.1547) > 0.02:
                print("WARNING: %s is %.3f x %.3f, the grid wants 1.000 x 1.155 "
                      "— the map will have seams" % (name, w, d))


main()
