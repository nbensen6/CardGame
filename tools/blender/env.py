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
    ground, and detail is better spent on the ring the camera actually frames
    than on the far edge.
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

## The enclosing wall: how far out it stands and how tall it is, both as
## multiples of the floor radius.
##
## Every fight until now happened on a disc floating in an open procedural sky,
## which is why they read as a diorama on a plate rather than a place. The wall
## fills the HORIZON BAND — you should still see sky when you tilt up, the way
## you do at the bottom of a canyon, but never a clean edge where the world runs
## out.
##
## Both numbers are set by the CAMERA, not by eye, and the first pass had them
## backwards. 1.85 was picked hoping the lens could be pulled inside a tight
## wall; clamping it there put the camera 17 units from a beast that needs 30 to
## frame, so the shot ended up inside the Crag Pup with both hunters off the
## bottom of the screen. The wall has to move out, not the camera in.
##
## The pair are solved together against one requirement: a beast needs about 30
## units of standoff to frame, and the smallest arena is 12.9 across. At
## ENCLOSE_OUT * CAMERA_REACH = 2.90 * 0.85 the camera may reach 31.8 units,
## which clears 30 — so the framing is never squeezed, and the lens still stops
## short of the wall.
##
## Height 1.90 was measured, not guessed. At radius 2.90 the far wall stands
## about 67 units from a camera 30 out and 6 up; a top at 1.90 * 12.9 = 24.5
## sits 15.4 degrees above that camera's eyeline against a 24-degree half-frame,
## so it fills roughly two thirds of the upper half of the shot and the side
## walls fill nearly all of it. A first pass at 1.15 left a broad band of open
## sky over the top, which is the thing this whole feature exists to remove. combat_3d holds the camera at
## a fraction of the arena radius (see CAMERA_REACH there), so the wall has to
## stand outside the furthest the camera can get and still be inside the frame.
## Measured before it was picked: the camera used to sit 1.5-2.4x further out
## than the ground was WIDE, which is the real reason no amount of scenery ever
## enclosed anything — it was all behind the lens.
## The GUARANTEED empty radius: nothing enclose() builds comes inside this, ever.
##
## This is a contract, not a coincidence, and it exists because the first version
## was a coincidence and got it wrong. The wall ring sat at 2.90 R with pieces
## jittered inward by up to 6% and up to 0.58 R wide, so its innermost face
## landed at 2.15 R — while combat_3d let the camera out to 2.46 R. The camera
## could stand four world units INSIDE the rock (Nick: "make sure the camera
## doesnt collide with the environment").
##
## Now every piece is placed at CLEAR + its own half-width, and jitter only ever
## pushes it further out. combat_3d clamps the lens to CAMERA_MAX_R, which is
## below this number with room to spare, and the two cannot drift apart without
## someone editing both.
ENCLOSE_CLEAR = 2.55
## An upper bound on how wide any wall piece is, in floor radii. Placement adds
## this to CLEAR so even the widest style keeps its inner face outside.
ENCLOSE_HALF = 0.62
ENCLOSE_HIGH = 2.10

## Higher than a beast's, on purpose. An environment is one static mesh in one
## draw call that never moves and never animates, and Nick asked for detail — a
## place should have more going on than the creature standing in it, because it
## is what tells you WHERE you are. The number is here to stop waste, not to
## keep grounds sparse.
## Raised again with the enclosure. A wall is not decoration any more — it
## is the thing that stops a fight reading as a plate in an open sky — and
## twenty-two pieces of it cost real triangles. Still one static mesh in
## one draw call that never moves.
BUDGET["ground"] = 7400


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

    def apron(self, uv, out=2.50, drop=0.55, seg=24):
        """Ground beyond the disc, lower and darker, so the world does not end
        at a clean circle.

        `out` was 1.35 and is now 2.50, and the reason is the wall. The
        enclosure moved out to ENCLOSE_CLEAR + ENCLOSE_HALF = 3.17 R on
        2026-08-31 so the camera could not clip into it — which left every
        ground as a 1.0 R floor with a 1.35 R apron sitting in the middle of a
        3.17 R ring, i.e. a coin on a table with a fence round the edge. The
        plan view of sunken_warden is the clearest picture of it, and it very
        likely explains why eight of the ten lowest-scoring assets under
        backlog #83 are grounds rather than creatures.

        2.50 tucks the apron just under the wall's inner face (2.55 R), so the
        ground runs all the way to the rock. Costs nothing: this is one taper of
        about 96 triangles whatever radius it is drawn at."""
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
            # A shade below the floor. A prop resting exactly ON it leaves a
            # hairline of daylight under one edge as soon as the ground dishes.
            p = Vector((math.cos(a) * r, math.sin(a) * r,
                        -0.035 + self.rng.uniform(-jitter, jitter)))
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
        """Standing water, sunk into the floor.

        Takes a plain (x, y, z) as happily as a scattered point, because a pool
        is usually placed by hand — you know where the low ground is.
        """
        at = Vector(at) if not hasattr(at, "x") else at
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

    # ------------------------------------------------------------- enclosure

    ## Each style's own palette, so a ground can call enclose("ice") and not
    ## have to import four more colour names to say something obvious. Passing
    ## uv/accent explicitly still wins.
    WALL_PALETTE = {
        "cliff":  (SLATE, PEWTER),
        "crag":   (GRAPHITE, SLATE),
        "forest": (UMBER, GREEN),
        "ice":    (ICE, WHITE),
        "ruin":   (PEWTER, STONE),
        "reed":   (GREEN, MINT),
    }

    def enclose(self, style="cliff", uv=None, accent=None, n=22, jag=0.34,
                out=None, high=None, gap=None):
        """Ring the arena so the world does not simply stop.

        `style` picks what the wall is made of; every style builds the same
        shape — a broken ring standing outside the floor, tall enough to fill
        the horizon from any angle the camera is allowed to reach.

        The ring is deliberately UNEVEN. A constant-height wall reads as a
        cylinder you are standing inside, which is worse than no wall at all;
        varying each segment and letting a few run tall turns the same triangles
        into a skyline.

        `gap` is an optional (from, to) arc left low, for a style that wants a
        way out on one side — a canyon mouth, a treeline break. The camera can
        still see sky through it, which is the point: one deliberate opening
        reads as a place, a full seal reads as a box.
        """
        # Far enough out that the widest piece still clears ENCLOSE_CLEAR.
        out = self.R * ((ENCLOSE_CLEAR + ENCLOSE_HALF) if out is None else out)
        high = self.R * (ENCLOSE_HIGH if high is None else high)
        pal = self.WALL_PALETTE.get(style, (STONE, None))
        uv = pal[0] if uv is None else uv
        accent = pal[1] if accent is None else accent
        piece = getattr(self, "_wall_" + style, None)
        if piece is None:
            raise ValueError("no enclosure style %r — have %s" % (
                style, ", ".join(sorted(k[6:] for k in dir(self)
                                        if k.startswith("_wall_")))))
        for i in range(n):
            a = math.tau * (i + self.rng.uniform(-0.14, 0.14)) / float(n)
            if gap is not None and gap[0] <= (a % math.tau) <= gap[1]:
                continue
            # Outward only. Jittering inward is what let a piece cross the
            # clearance line and put rock where the camera is allowed to be.
            r = out * self.rng.uniform(1.0, 1.12)
            # Every third piece runs tall, so the skyline has a rhythm rather
            # than a uniform noise floor.
            tall = high * (self.rng.uniform(1.10, 1.32) if i % 3 == 0
                           else self.rng.uniform(0.80, 1.04))
            piece(Vector((math.cos(a) * r, math.sin(a) * r, -0.2)), tall, a, jag,
                  uv, accent)

    ## One segment of wall, per style. Each takes (at, tall, angle, jag, uv,
    ## accent) and leaves the floor alone — the ring calls these, never the
    ## other way round.

    def _wall_cliff(self, at, tall, a, jag, uv, accent):
        """A sheer block, faces squared to the middle. Canyon, quarry, pit."""
        # Wide enough to overlap. At n=17 on a ring of 1.85R the gap between
        # centres is about 0.68R, so anything narrower than that leaves daylight
        # between every pair and the wall becomes a colonnade.
        w = self.R * self.rng.uniform(0.42, 0.58)
        self.box((at.x, at.y, at.z + tall * 0.5), (w, w * 0.7, tall * 0.5), uv,
                 bevel=self.R * 0.02, seg=2,
                 rot=(0.0, self.rng.uniform(-jag, jag) * 0.25, a + math.pi * 0.5))
        if accent is not None:
            self.box((at.x, at.y, at.z + tall * self.rng.uniform(0.75, 0.95)),
                     (w * 0.8, w * 0.5, tall * 0.10), accent,
                     bevel=self.R * 0.015,
                     rot=(0.0, 0.0, a + math.pi * 0.5))

    def _wall_crag(self, at, tall, a, jag, uv, accent):
        """Broken rock: a squat frustum, wide enough to touch its neighbours.

        This was a cone once, and seventeen cones in a circle read as a ring of
        traffic bollards. A wall is made of things WIDER than the gap between
        them, and it stops being a wall the moment the top comes to a point.
        """
        w = self.R * self.rng.uniform(0.40, 0.52)
        self.taper((at.x, at.y, at.z + tall * 0.45), w,
                   w * self.rng.uniform(0.55, 0.80), tall, uv, seg=6,
                   rot=point((math.cos(a) * -jag * 0.18,
                              math.sin(a) * -jag * 0.18, 1.0)))
        if accent is not None and self.rng.random() < 0.5:
            self.rock(Vector((at.x * 0.86, at.y * 0.86, at.z)),
                      self.R * 0.16, accent)

    def _wall_forest(self, at, tall, a, jag, uv, accent):
        """A treeline. The trunks are the wall; the canopy closes the top."""
        # 0.44, not 0.62. tree() spreads its lowest tier to 0.62 of its size, so
        # at 0.62 of a 12.6-unit wall the canopy reached 4.8 units INWARD and put
        # branches at 14.2 — inside the 15.3 the camera clamp relies on. The
        # Bramble Hog's clearing was the ground that reported it.
        # Derived, not guessed. tree() spreads its lowest tier to 0.62 of its
        # size, and nothing may reach further in than ENCLOSE_HALF, so the size
        # ceiling is ENCLOSE_HALF * R / 0.62. Two passes of eyeballing this
        # (0.62 then 0.44) both left branches inside the clearance; the third
        # asks the constraint what the number is.
        cap = (ENCLOSE_HALF * self.R) / 0.62
        self.tree(Vector((at.x, at.y, at.z)), min(tall * 0.44, cap),
                  trunk=uv, leaf=accent if accent is not None else GREEN,
                  tiers=3)

    def _wall_ice(self, at, tall, a, jag, uv, accent):
        self.taper((at.x, at.y, at.z + tall * 0.30), self.R * 0.26,
                   self.R * 0.02, tall * 1.5, uv, seg=5,
                   rot=point((math.cos(a) * -jag * 0.35,
                              math.sin(a) * -jag * 0.35, 1.0)))
        if accent is not None:
            self.taper((at.x * 0.9, at.y * 0.9, at.z + tall * 0.18),
                       self.R * 0.14, self.R * 0.01, tall * 0.8, accent, seg=4,
                       rot=point((math.cos(a + 1.0) * jag,
                                  math.sin(a + 1.0) * jag, 1.0)))

    def _wall_ruin(self, at, tall, a, jag, uv, accent):
        """A wall that was built once and is not finished being knocked down."""
        h = tall * self.rng.uniform(0.55, 1.0)
        self.box((at.x, at.y, at.z + h * 0.5),
                 (self.R * 0.40, self.R * 0.11, h * 0.5), uv,
                 bevel=self.R * 0.015, seg=2,
                 rot=(0.0, self.rng.uniform(-0.06, 0.06), a + math.pi * 0.5))
        if accent is not None and self.rng.random() < 0.6:
            self.pillar(Vector((at.x * 0.88, at.y * 0.88, at.z)), self.R * 0.20,
                        accent, broken=True)

    def _wall_reed(self, at, tall, a, jag, uv, accent):
        """Marsh growth so dense you cannot see through it. Cheap, and the only
        style that reads as soft."""
        # Spread ALONG the wall, and never inward past the clearance: the offsets
        # run tangentially (a + 1.57) so three clumps widen the wall rather than
        # thicken it toward the middle.
        for k in range(3):
            o = (k - 1) * self.R * 0.13
            self.reed(Vector((at.x + math.cos(a + 1.57) * o,
                              at.y + math.sin(a + 1.57) * o, at.z)),
                      tall * self.rng.uniform(0.42, 0.62),
                      uv if accent is None or k != 1 else accent, n=4)

    # ----------------------------------------------------------------- done

    def _islands(self):
        """Suppressed, on purpose.

        Build's island check exists to catch a limb placed in mid-air on a
        CHARACTER, where every part is meant to be one body. A ground is the
        opposite: it is a floor with a scatter of separate things standing on
        it, and half of them are meant to be separate — the Riftling's shards
        hang in the air because that is what the Riftling does to ground.

        Reporting "35 pieces do not touch" for a field of rocks is noise, and
        noise is how a real warning gets missed.
        """
        return [list(range(len(self.parts)))]

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
        # The camera clamp trusts this number. Prove it every build rather than
        # assuming it — a hand-placed prop is exactly the thing that would creep
        # into the lens's space without anyone noticing.
        clear = ENCLOSE_CLEAR * self.R
        # WALL-height geometry only. A boulder on the floor is inside the
        # clearance by design and the camera never goes near it — the first
        # version of this check flagged the Crag Pup's own scree at 6.01 and
        # would have cried wolf on every ground in the game. The wall stands
        # 2.10 R; nothing scattered on the floor comes near 0.6 R.
        tall = self.R * 0.6
        near = min((math.hypot(v.co.x, v.co.y) for v in me.vertices
                    if v.co.z > tall), default=0.0)
        if near and near < clear:
            print("WARNING: %s has standing geometry at %.2f, inside the %.2f "
                  "clearance the camera clamp relies on." % (name, near, clear))
        else:
            print("CLEAR %s keeps everything above the floor outside %.2f "
                  "(nearest standing geometry %.2f)" % (name, clear, near))


def env_out():
    """Where an environment script writes. Same argument convention as a beast."""
    return out_path()
