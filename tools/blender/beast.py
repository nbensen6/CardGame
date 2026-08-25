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

    def __init__(self, beast_id, height):
        super().__init__()
        self.id = beast_id
        self.data = boss_data(beast_id)
        self.sigil_height = int(self.data["weak_point_height"])
        self.ledges = [_height_of(h) for h in self.data.get("ledges", [])]
        self.H = float(height)
        self._promised = []

    # ------------------------------------------------------------- the climb

    def z_for(self, game_height):
        """Model z where a hunter at that game Height puts their feet."""
        t = min(1.0, max(0.0, float(game_height) / float(self.sigil_height)))
        return self.H * (FOOT_LOW + (FOOT_HIGH - FOOT_LOW) * t)

    @property
    def sigil_z(self):
        return self.z_for(self.sigil_height)

    def brief(self):
        """One line naming what this body has to provide, for the build log."""
        parts = ["hold %d at %.0f%% (z %.2f)"
                 % (h, 100.0 * self.z_for(h) / self.H, self.z_for(h))
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
        return self.box((at[0], at[1], top - thickness),
                        (size[0], size[1], thickness), uv, rot=rot, bevel=bevel)

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

    def done(self, out, name="Beast", budget="beast"):
        """finish(), then prove the climb before anyone has to look at it."""
        self.brief()
        missing = [h for h in self.ledges + [self.sigil_height]
                   if h not in self._promised]
        if missing:
            # Not fatal - a hold can be body rather than a placed shelf, and the
            # measurement below is the real judge. But it is worth saying.
            print("NOTE %s: no shelf() call for Height(s) %s - relying on the "
                  "body to provide them." % (name, missing))
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
        if bad:
            print("FAIL %s: nowhere to stand at Height(s) %s. Widen the shelf or "
                  "move it - the band is +/-%.0f%% of the body's height, so it "
                  "does not have to be exactly on the line."
                  % (name, bad, BAND * 100))
        else:
            print("HOLDS ok: every hold and the sigil have a shelf at their Height")
