"""The ground a fight happens on.

Every Titan has been standing on the same blank grey disc. A beast reads as
colossal only next to something, and "something" has so far been one hunter and
a circle — so the fights all look like the same fight in a different costume.

An environment here is one model per beast, built the same way the beasts are:
one mesh, one material, the shared palette atlas, exported to
`game/assets/3d/env/<beast_id>.glb`. `combat_3d.gd` loads it by that filename,
so making one is exporting a file and nothing else.

    from env import Env
    e = Env(seed=4)
    e.ground(SAND, rim=CLAY)
    e.scatter(14, lambda p, r, s: e.rock(p, r), near=2.4, far=5.6)
    e.done(out_path(), name="CragPupGround")

**Every environment is built to RADIUS 6.0.** combat_3d scales it to sit under
whatever beast it is hosting, and it can only do that arithmetic if the number
is the same every time. `done()` measures and complains if a script drifts.

Two things worth knowing before adding one:

  * **The middle is not yours.** The beast stands at the origin and its feet
    sprawl; anything inside `near` ends up inside the creature. `scatter()`
    keeps out of it for you.
  * **Cheap.** The camera shows a slice of world, so most of an environment is
    off-screen most of the time. The budget is 2200 triangles for the whole
    ground — about one beast — and detail is better spent on the ring the
    camera actually frames than on the far edge.
"""
import bpy, math, os, random, sys
from mathutils import Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import (Build, BUDGET, out_path, point, aim, SAND, TAN, CLAY, BROWN,
                    UMBER, STONE, PEWTER, SLATE, GRAPHITE, CHARCOAL, GREEN,
                    MINT, ICE, WHITE, SILVER, STEEL)

## Every environment is this wide. See the module docstring.
RADIUS = 6.0

## Beasts face -Y, so the camera watches from -Y and everything tall belongs on
## the far side of the creature. This is not a style preference: the camera sits
## about as far from the beast as the ground is wide, so a standing stone out on
## the front rim is not scenery, it is a wall between you and the fight — the
## first environment built without this rule filled the screen with the inside
## of a boulder.
##
## So: BACK for anything with height, ANY for anything that lies flat.
BACK = (0.30, math.pi - 0.30)
SIDES = (-0.55, 0.55)
ANY = (0.0, math.tau)

BUDGET["ground"] = 2200


class Env(Build):
    """One fight's ground. Same vocabulary as Build, plus a floor and scatter."""

    def __init__(self, seed=1):
        super().__init__()
        self.rng = random.Random(seed)
        self.R = RADIUS
        self._floor = False

    # ---------------------------------------------------------------- floor

    def ground(self, uv, rim=None, thickness=0.34, seg=28, dish=0.0):
        """The disc itself, with a rim of exposed edge under it.

        `dish` sinks the middle, which is what makes a fight read as happening
        IN a place rather than on a plate — a crater, a dry lake, a clearing.
        """
        self._floor = True
        self.taper((0.0, 0.0, -thickness * 0.5), self.R, self.R, thickness, uv,
                   seg=seg)
        if rim is not None:
            self.taper((0.0, 0.0, -thickness - 0.10), self.R * 0.985,
                       self.R * 0.90, 0.24, rim, seg=seg)
        if dish > 0.0:
            self.taper((0.0, 0.0, -dish * 0.5), self.R * 0.66, self.R * 0.20,
                       dish, uv, seg=seg)

    def apron(self, uv, out=1.7, drop=0.55, seg=24):
        """Ground beyond the disc, lower and darker, so the world does not end
        at a clean circle. The camera catches this at the edges of a wide shot
        and it is the difference between a stage and a place."""
        self.taper((0.0, 0.0, -drop), self.R * out, self.R * out * 0.86,
                   0.5, uv, seg=seg)

    # -------------------------------------------------------------- scatter

    def scatter(self, count, make, near=2.6, far=5.5, arc=(0.0, math.tau),
                jitter=0.0, size=0.5):
        """Place `count` things in a ring, avoiding the middle.

        `make(pos, size, rng)` builds one. The middle is where the beast stands
        and its feet sprawl, so anything inside `near` ends up inside it.

        On `size`: the floor is 6 units across and the game stretches it to about
        one and a half times the beast's depth, so a prop built 1.0 tall stands
        roughly a QUARTER of the beast. That is a cliff, not a boulder. 0.5 is a
        rock you would climb over; 0.2 is a stone you would kick.
        """
        for i in range(count):
            a = arc[0] + (arc[1] - arc[0]) * ((i + self.rng.random() * 0.8)
                                              / max(1.0, float(count)))
            r = near + (far - near) * math.sqrt(self.rng.random())
            p = Vector((math.cos(a) * r, math.sin(a) * r,
                        self.rng.uniform(-jitter, jitter)))
            make(p, size * (0.7 + self.rng.random() * 0.6), self.rng)

    # ---------------------------------------------------------------- parts

    def rock(self, at, size, uv=STONE, sink=0.45):
        """A boulder, half in the ground. Sitting one ON the floor reads as a
        prop dropped there; sinking it reads as something the ground grew."""
        self.ball((at.x, at.y, at.z + size * (0.5 - sink)),
                  (size, size * 0.88, size * 0.72), uv, 7, 4,
                  rot=(0.0, 0.0, self.rng.random() * math.tau))

    def shard(self, at, size, uv=SLATE, lean=0.35):
        """A slab standing on end, leaning. Reads as broken rather than placed."""
        a = self.rng.random() * math.tau
        self.box((at.x, at.y, at.z + size * 0.55),
                 (size * 0.34, size * 0.22, size * 0.95), uv, bevel=size * 0.06,
                 rot=(math.cos(a) * lean * self.rng.random(),
                      math.sin(a) * lean * self.rng.random(),
                      self.rng.random() * math.tau))

    def spike(self, at, size, uv=ICE, lean=0.30):
        a = self.rng.random() * math.tau
        self.taper((at.x, at.y, at.z + size * 0.30), size * 0.34, size * 0.03,
                   size * 1.9, uv, seg=5,
                   rot=point((math.cos(a) * lean, math.sin(a) * lean, 1.0)))

    def tree(self, at, size, trunk=BROWN, leaf=GREEN, tiers=3):
        self.limb([(at.x, at.y, at.z),
                   (at.x + size * 0.05, at.y, at.z + size * 0.7),
                   (at.x + size * 0.08, at.y, at.z + size * 1.35)],
                  [size * 0.13, size * 0.10, size * 0.08], trunk, seg=5)
        for i in range(tiers):
            t = i / max(1.0, float(tiers - 1))
            self.taper((at.x + size * 0.07, at.y, at.z + size * (0.95 + 0.55 * t)),
                       size * (0.62 - 0.30 * t), size * 0.02,
                       size * 0.75, leaf, seg=6)

    def stump(self, at, size, uv=UMBER, top=BROWN):
        self.taper((at.x, at.y, at.z + size * 0.28), size * 0.40, size * 0.34,
                   size * 0.62, uv, seg=8,
                   rot=(self.rng.uniform(-0.2, 0.2), self.rng.uniform(-0.2, 0.2), 0))
        self.taper((at.x, at.y, at.z + size * 0.60), size * 0.33, size * 0.33,
                   size * 0.08, top, seg=8)

    def reed(self, at, size, uv=GREEN, n=5):
        for _ in range(n):
            a = self.rng.random() * math.tau
            d = self.rng.random() * size * 0.35
            lean = self.rng.uniform(0.10, 0.42)
            b = self.rng.random() * math.tau
            self.taper((at.x + math.cos(a) * d, at.y + math.sin(a) * d,
                        at.z + size * 0.55),
                       size * 0.045, size * 0.008, size * 1.25, uv, seg=4,
                       rot=point((math.cos(b) * lean, math.sin(b) * lean, 1.0)))

    def pool(self, at, size, uv=ICE, rim=None):
        """Standing water, sunk into the floor."""
        if rim is not None:
            self.taper((at.x, at.y, at.z - 0.04), size * 1.16, size * 1.10,
                       0.16, rim, seg=10)
        self.taper((at.x, at.y, at.z + 0.02), size, size * 0.96, 0.10, uv, seg=10)

    def slabs(self, at, size, uv=STONE, n=3):
        """Flagstones, flat and overlapping — a floor that was made once."""
        for i in range(n):
            a = self.rng.random() * math.tau
            d = self.rng.random() * size * 0.6
            self.box((at.x + math.cos(a) * d, at.y + math.sin(a) * d,
                      at.z + 0.04 + i * 0.03),
                     (size * self.rng.uniform(0.4, 0.7),
                      size * self.rng.uniform(0.4, 0.7), 0.055), uv,
                     bevel=0.03, rot=(0, 0, self.rng.random() * math.tau))

    def pillar(self, at, size, uv=STONE, cap=None, broken=True):
        h = size * self.rng.uniform(1.2, 2.8) if broken else size * 3.0
        self.taper((at.x, at.y, at.z + h * 0.5), size * 0.30, size * 0.26, h,
                   uv, seg=8, rot=(self.rng.uniform(-0.12, 0.12),
                                   self.rng.uniform(-0.12, 0.12), 0))
        if cap is not None:
            self.box((at.x, at.y, at.z + h + size * 0.06),
                     (size * 0.34, size * 0.34, size * 0.07), cap, bevel=0.03)

    # ----------------------------------------------------------------- done

    def done(self, out, name="Ground"):
        """Export, and check the one number the game depends on.

        combat_3d scales an environment to fit whatever beast it is hosting, and
        it can only do that arithmetic if every environment is the same size to
        begin with — so a script that quietly grew its own props past the edge
        gets told, rather than the ground turning up the wrong size in a fight.
        """
        self.finish(out, height=None, name=name, budget="ground")
        # The FLOOR has to be RADIUS. Props overhang it and the apron runs well
        # past it on purpose — the world should not end at a clean circle — so
        # only the disc is measured, and the rest is reported for interest.
        if not self._floor:
            print("WARNING: %s never called ground(). combat_3d scales an "
                  "environment by its floor; without one there is nothing to "
                  "scale." % name)
            return
        me = bpy.context.object.data
        reach = max(math.hypot(v.co.x, v.co.y) for v in me.vertices)
        print("GROUND floor %.2f (every environment is built to %.2f), props and "
              "apron reach %.2f" % (self.R, RADIUS, reach))


def env_out():
    """Where an environment script writes. Same argument convention as a beast."""
    return out_path()
