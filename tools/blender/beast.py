"""Building a Titan, with the hold contract satisfied by construction.

A beast is not just a shape: it is a shape you CLIMB. `bosses.json` says where
the holds are and where the sigil is, and `game/tools/assetcheck.gd` checks that
the model actually has somewhere to stand at each of them - because a beast whose
body has no shelf where its data says there is one is a beast you climb by
floating.

Doing that arithmetic by hand in eleven scripts is eleven chances to get it
wrong, and the failure is invisible until a hunter is standing in mid-air. So
this module reads the same JSON the game reads, works out the heights, and gives
you `shelf()`, which puts a ledge exactly where the contract wants one.

    from beast import Beast
    b = Beast("frost_sentinel", height=4.0)
    b.ball((0, 0, 1.2), (0.9, 0.8, 1.1), ICE)
    b.shelf(2, (0, -0.5), (0.75, 0.55), STEEL)     # the hold at Height 2
    b.mark()                                       # the sigil, at its Height
    b.done(out_path(), name="FrostSentinel")

`done()` then runs the SAME area test Godot runs, in Blender, before the file is
written - so a bad hold is a message in the build log rather than a hunter
standing on air three days later.

The model's own height does not matter to the game: combat_3d.gd rescales every
beast to BEAST_BASE_HEIGHT + BEAST_HEIGHT_PER_CLIMB * sigil. Only proportions
survive. `height` here is just a convenient unit to build in.
"""
import bpy, bmesh, json, math, os, sys, mathutils
from mathutils import Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kenney import Build, GOLD, AMBER

## Where a hunter stands, as a fraction of the model's height, for a hold at the
## bottom and at the sigil. Straight out of combat_3d.gd via assetcheck.gd; if
## that view ever changes these, this file has to follow.
FOOT_LOW, FOOT_HIGH = 0.18, 0.80

## Every climb point is exported as an empty with this prefix, so the game can
## find them by name without a manifest that can drift out of date.
CLIMB_PREFIX = "climb_"

## The band a hold is measured in, and how much upward-facing surface it wants,
## as a fraction of the model's footprint. Both mirror assetcheck.gd exactly.
BAND = 0.055
WANT = 0.020


def boss_data(beast_id):
    """The beast's entry from the same bosses.json the game loads."""
    here = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(here, "..", "..", "game", "data", "bosses.json")
    with open(os.path.normpath(path), encoding="utf-8") as f:
        all_of_them = json.load(f)["bosses"]
    if beast_id not in all_of_them:
        raise SystemExit("no beast '%s' in bosses.json. Have: %s"
                         % (beast_id, ", ".join(sorted(all_of_them))))
    return all_of_them[beast_id]


def _height_of(hold):
    """A ledge is a bare int or {height, safe, exposed_to} - see Boss.hold_height."""
    return int(hold["height"]) if isinstance(hold, dict) else int(hold)


class Beast(Build):
    """One Titan. Same vocabulary as Build, plus the climb."""

    def __init__(self, beast_id, height, span=None):
        super().__init__()
        self.id = beast_id
        self.data = boss_data(beast_id)
        self.sigil_height = int(self.data["weak_point_height"])
        self.ledges = [_height_of(h) for h in self.data.get("ledges", [])]
        self.H = float(height)
        # The build-space z range the body ACTUALLY occupies. finish() rescales
        # whatever it finds to `height`, so a script whose geometry stops short
        # of H has every contract height it computed slide upward with the
        # rescale — which is how the Crag Pup's shoulder shelf sat at 61% of its
        # body while its data said 49%, for months, with nothing complaining.
        # Author across the full 0..H and this can stay None.
        self.span = (0.0, self.H) if span is None else (float(span[0]), float(span[1]))
        self._promised = []
        self._anchors = {}
        self._fit_k, self._fit_mid = 1.0, Vector((0, 0, 0))

    # ------------------------------------------------------------- the climb

    def z_for(self, game_height):
        """Model z where a hunter at that game Height puts their feet."""
        t = min(1.0, max(0.0, float(game_height) / float(self.sigil_height)))
        lo, hi = self.span
        return lo + (hi - lo) * (FOOT_LOW + (FOOT_HIGH - FOOT_LOW) * t)

    @property
    def sigil_z(self):
        return self.z_for(self.sigil_height)

    def brief(self):
        """One line naming what this body has to provide, for the build log."""
        lo, hi = self.span
        parts = ["hold %d at %.0f%% (z %.2f)"
                 % (h, 100.0 * (self.z_for(h) - lo) / (hi - lo), self.z_for(h))
                 for h in self.ledges]
        parts.append("sigil %d at %.0f%% (z %.2f)"
                     % (self.sigil_height, 100.0 * FOOT_HIGH, self.sigil_z))
        print("CLIMB %s: %s" % (self.id, "; ".join(parts)))

    def shelf(self, game_height, at, size, uv, thickness=0.09, bevel=0.03,
              rot=(0, 0, 0), drop=0.0):
        """A ledge whose TOP surface lands where a hunter's feet go.

        `at` is (x, y) and `size` is (half-width, half-depth). `drop` nudges the
        top below the foot line for a hold that should sit in a hollow rather
        than jut out - the band is +/-5.5% of the model's height, so there is
        room to move without breaking the contract.
        """
        top = self.z_for(game_height) - drop
        self._promised.append(game_height)
        # Where a hunter actually STANDS. The game used to derive this from the
        # bounding box, which put climbers in front of the beast rather than on
        # it; now the model says, and the ledge and the standing place are the
        # same fact by construction.
        self.anchor(game_height, (at[0], at[1], top))
        return self.box((at[0], at[1], top - thickness),
                        (size[0], size[1], thickness), uv, rot=rot, bevel=bevel)

    def anchor(self, game_height, at):
        """Name a climb point by hand, for a hold the body provides itself.

        Exported into the .glb as an empty called `climb_<height>`, so the model
        carries its own route and nothing in the game has to guess.
        """
        self._anchors[int(game_height)] = Vector((at[0], at[1], at[2]))

    def foot(self, at):
        """Where the climb STARTS - the ankle, the root, the lowest thing worth
        grabbing. Height 0. Without it a hunter leaving the ground cuts a
        straight line to the first ledge, through the body."""
        self._anchors[0] = Vector((at[0], at[1], at[2]))

    def mark(self, at, size=None, facing=(0, -1, 0)):
        """The sigil: the same gold mark every beast wears, at its Height.

        `at` is (x, y) or (x, y, z); z defaults to the sigil Height. `facing` is
        the direction it looks out of the body, so a mark on a chest and a mark
        on a shoulder are the same call.

        Two things this got wrong before it was a helper. It built the disc as a
        sphere squashed on Z, which lays it FLAT - every sigil in the game was a
        gold pancake balanced on the beast rather than a mark facing the person
        climbing toward it. And nothing checked it had landed on the body, so it
        could hang in mid air beside a shoulder and still pass every test.
        """
        x, y = at[0], at[1]
        z = at[2] if len(at) > 2 else self.sigil_z
        w = size if size is not None else self.H * 0.115
        d = Vector(facing).normalized()
        here = Vector((x, y, z))

        self._sigil_lands(here, w)
        # Standing ON the sigil is the end of the climb, so the anchor sits just
        # off its face rather than inside it.
        self._anchors[self.sigil_height] = here + d * (w * 0.55)

        from kenney import point
        self.taper((here - d * w * 0.10)[:], w, w * 0.94, w * 0.30, GOLD,
                   seg=14, rot=point(d), bevel=w * 0.06)
        self.taper((here + d * w * 0.16)[:], w * 0.56, w * 0.48, w * 0.26, AMBER,
                   seg=12, rot=point(d))
        self.ring((here - d * w * 0.06)[:], (w * 1.22, w * 1.22, w * 0.30), AMBER,
                  16, 5, rot=point(d), thickness=0.16)

    def _sigil_lands(self, here, w):
        """Is there any body under the sigil, or is it hanging in the air?

        Called from mark() so it sees only what was built BEFORE it - which is
        the whole point, since the sigil's own geometry would otherwise answer
        the question yes every time. Put mark() last, which every script does.
        """
        reach = w * 2.0
        for o in self.parts:
            m = o.matrix_world
            for v in o.data.vertices:
                if ((m @ v.co) - here).length <= reach:
                    return
        print("WARNING: the sigil at (%.2f, %.2f, %.2f) has no body within %.2f "
              "of it - it is floating. The sigil is what a hunter climbs TO; put "
              "it on a surface." % (here.x, here.y, here.z, reach))

    # ------------------------------------------------------------ the check

    def _decorate(self, k, mid):
        """Drop an empty at every climb point, in the finished model's space.

        glTF carries empties through as plain nodes and Godot imports them as
        Node3D, so the route travels WITH the art: rebuild a beast with its
        shoulder 20cm higher and the hunter who stands there moves too, with no
        code change and nothing to keep in sync.
        """
        if not self._anchors:
            return
        self._fit_k, self._fit_mid = k, mid
        for h in sorted(self._anchors):
            p = (self._anchors[h] - mid) * k
            e = bpy.data.objects.new(CLIMB_PREFIX + str(h), None)
            e.empty_display_type = "PLAIN_AXES"
            e.empty_display_size = 0.25
            e.location = p
            bpy.context.collection.objects.link(e)
        print("CLIMB POINTS %s" % ", ".join(
            "%d@z%.2f" % (h, ((self._anchors[h] - mid) * k).z)
            for h in sorted(self._anchors)))

    def _measure_span(self, name):
        """What z range the body ACTUALLY occupies, against what span assumed.

        z_for() has to answer "what height is Height 3" while the script is still
        being written, so it works from a span it is told. Told wrong, every
        ledge and the sigil slide by the same fraction and the beast still passes
        every check — which is exactly what the Crag Pup did for months.

        So measure it at the end and print the line to paste back. One rebuild
        and the script is honest.
        """
        zs = [(o.matrix_world @ v.co).z for o in self.parts for v in o.data.vertices]
        if not zs:
            return
        lo, hi = min(zs), max(zs)
        want_lo, want_hi = self.span
        drift = max(abs(lo - want_lo), abs(hi - want_hi)) / max(1e-6, hi - lo)
        if drift <= 0.02:
            return
        print("SPAN %s: body is z %.2f..%.2f but span says %.2f..%.2f. Every hold "
              "is off by up to %.0f%% of the body. Paste this into the Beast(): "
              "span=(%.2f, %.2f)"
              % (name, lo, hi, want_lo, want_hi, drift * 100, lo, hi))

    def done(self, out, name="Beast", budget="beast"):
        """finish(), then prove the climb before anyone has to look at it."""
        self.brief()
        self._measure_span(name)
        missing = [h for h in self.ledges + [self.sigil_height]
                   if h not in self._promised]
        if missing:
            # Not fatal - a hold can be body rather than a placed shelf, and the
            # measurement below is the real judge. But it is worth saying.
            print("NOTE %s: no shelf() call for Height(s) %s - relying on the "
                  "body to provide them." % (name, missing))
        want = set(self.ledges + [self.sigil_height])
        blank = sorted(want - set(self._anchors))
        if blank:
            print("NOTE %s: no climb point for Height(s) %s - the game will fall "
                  "back to the bounding box there, which puts a hunter in front "
                  "of the beast rather than on it." % (name, blank))
        if 0 not in self._anchors:
            print("NOTE %s: no foot() - the climb off the ground will cut a "
                  "straight line to the first ledge." % name)
        self.finish(out, height=self.H, name=name, budget=budget)
        self._prove(name)

    def _prove(self, name):
        """Godot's hold test, run here, on the finished mesh.

        Deliberately a copy of assetcheck.gd rather than a clever shared thing:
        it has to keep agreeing with the game, and a copy that disagrees is
        caught the moment both are run, where a shared abstraction would just be
        wrong in both places at once.
        """
        me = bpy.context.object.data
        me.calc_loop_triangles()
        co = [v.co for v in me.vertices]
        lo = Vector((min(c.x for c in co), min(c.y for c in co), min(c.z for c in co)))
        hi = Vector((max(c.x for c in co), max(c.y for c in co), max(c.z for c in co)))
        size = hi - lo
        want = size.x * size.y * WANT          # Blender x/y is Godot x/z

        tris = []
        for t in me.loop_triangles:
            a, b_, c = (me.vertices[i].co for i in t.vertices)
            tris.append((a, b_, c))

        bad = []
        for h in self.ledges + [self.sigil_height]:
            z = lo.z + size.z * (FOOT_LOW + (FOOT_HIGH - FOOT_LOW)
                                 * min(1.0, float(h) / float(self.sigil_height)))
            band = size.z * BAND
            flat = 0.0
            for a, b_, c in tris:
                mid = (a + b_ + c) / 3.0
                if abs(mid.z - z) > band:
                    continue
                cross = (b_ - a).cross(c - a)
                area = cross.length * 0.5
                if area <= 0.0:
                    continue
                if abs(cross.normalized().z) > 0.55:
                    flat += area
            what = "sigil" if h == self.sigil_height else "hold"
            ok = flat >= want
            print("  HOLD %-5s Height %-3d z %.2f  shelf %.3f / %.3f  %s"
                  % (what, h, z, flat, want, "ok" if ok else "TOO SMALL"))
            if not ok:
                bad.append(h)
        # And where the climb points ACTUALLY ended up. z_for() assumes the
        # script authors the body across the full 0..H it asked for; a script
        # whose geometry stops short gets rescaled by finish() and every
        # contract height it computed slides with it. The three beasts written
        # before this helper existed all did exactly that, and their shelves
        # were at the wrong fraction of the body for months without anything
        # noticing - the hold check passed on the body's own curvature instead.
        for h in sorted(self._anchors):
            p = (self._anchors[h] - self._fit_mid) * self._fit_k
            got = (p.z - lo.z) / max(1e-6, size.z)
            if h == 0:
                print("  CLIMB ground        at %.0f%% of the body" % (got * 100))
                continue
            t = min(1.0, max(0.0, float(h) / float(self.sigil_height)))
            wants = FOOT_LOW + (FOOT_HIGH - FOOT_LOW) * t
            off = abs(got - wants)
            print("  CLIMB Height %-3d    at %.0f%%, contract says %.0f%%  %s"
                  % (h, got * 100, wants * 100,
                     "ok" if off <= BAND else "OFF by %.0f%%" % (off * 100)))
            if off > BAND:
                bad.append(h)

        if bad:
            print("FAIL %s: nowhere to stand at Height(s) %s. Widen the shelf or "
                  "move it - the band is +/-%.0f%% of the body's height, so it "
                  "does not have to be exactly on the line."
                  % (name, bad, BAND * 100))
        else:
            print("HOLDS ok: every hold and the sigil have a shelf at their Height")
