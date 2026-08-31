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
from kenney import Build, GOLD, AMBER, SLATE

## Where a hunter stands, as a fraction of the model's height, for a hold at the
## bottom and at the sigil. Straight out of combat_3d.gd via assetcheck.gd; if
## that view ever changes these, this file has to follow.
FOOT_LOW, FOOT_HIGH = 0.18, 0.80

## Every climb point is exported as an empty with this prefix, so the game can
## find them by name without a manifest that can drift out of date.
CLIMB_PREFIX = "climb_"
## A second empty, only for Heights that have a real SHELF under them.
##
## Every Height gets a climb_ point so a hunter knocked off half way has
## somewhere to be that is not inside the chest (see _rungs). But most of those
## are just a spot on the skin — no flat ground, nothing to stand on. The game
## was jumping hunters onto them as if they were ledges, which is Nick's
## "it jumps to random places ... there should be clear places for the character
## to land, IE the shelf of the Crag Pup on its shoulders at climb point 2".
##
## So the two are told apart in the export: climb_<h> is where a hunter may BE,
## ledge_<h> is where a hunter may LAND.
LEDGE_PREFIX = "ledge_"

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
        self._final = {}
        self._ledge_uv = {}
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
              rot=(0, 0, 0), drop=0.0, lip=0.72):
        """A ledge whose TOP surface lands where a hunter's feet go.

        `at` is (x, y) and `size` is (half-width, half-depth). `drop` nudges the
        top below the foot line for a hold that should sit in a hollow rather
        than jut out - the band is +/-5.5% of the model's height, so there is
        room to move without breaking the contract.
        """
        top = self.z_for(game_height) - drop
        self._promised.append(game_height)
        # Where a hunter actually STANDS: out at the ledge's front LIP, not in
        # the middle of it. The middle of a ledge is inside the creature — a
        # shelf is a step OUT of a body, so its centre is level with the chest
        # it grew from and a hunter placed there is inside the chest. Standing
        # at the lip is also what a person climbing would actually do.
        self.anchor(game_height, (at[0], at[1] - size[1] * lip, top))
        self._ledge_uv[int(game_height)] = uv
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

        This is also where a climb point is pushed OUT to the body's surface. A
        shelf is a step out of a torso that keeps bulging past it, so the middle
        of a ledge is level with the chest it grew from — and a hunter placed
        there is inside the chest. Measuring the reach needs the whole body, and
        the whole body only exists here, once everything is joined.
        """
        if not self._anchors:
            return
        me = bpy.context.object.data
        me.calc_loop_triangles()
        tris = [tuple(me.vertices[i].co.copy() for i in t.vertices)
                for t in me.loop_triangles]
        co = [v.co for v in me.vertices]
        axis = Vector(((min(c.x for c in co) + max(c.x for c in co)) * 0.5,
                       (min(c.y for c in co) + max(c.y for c in co)) * 0.5, 0.0))
        hs = self.hunter_size()

        self._final = {}
        moved = []
        steps = []
        for h in sorted(self._rungs()):
            p = (self._rung(h) - mid) * k
            out = Vector((p.x - axis.x, p.y - axis.y, 0.0))
            if out.length < 1e-4:
                out = Vector((0.0, -1.0, 0.0))            # beasts face -Y
            out.normalize()
            reach = self._reach(tris, axis, p, out, hs)
            if reach is not None:
                here = (p - axis).x * out.x + (p - axis).y * out.y
                push = (reach + hs * 0.80) - here
                if push > 0.0:
                    p = p + out * push
                    moved.append((h, push))
                    if push > hs * 0.8:
                        # The ledge stopped short of the body, so the hunter
                        # would now stand correctly and on nothing. Grow a step
                        # from the body out to where they stand. Cheaper and
                        # more reliable than hand-tuning forty shelf depths, and
                        # it cannot drift when a body is reshaped.
                        steps.append((h, p.copy(), out.copy(), push))
            self._final[h] = p

            e = bpy.data.objects.new(CLIMB_PREFIX + str(h), None)
            e.empty_display_type = "PLAIN_AXES"
            e.empty_display_size = 0.25
            e.location = p
            bpy.context.collection.objects.link(e)
            # A shelf() built real flat ground at this Height, or _grow_steps is
            # about to. Either way there is somewhere to put your feet, so say
            # so — the game only jumps a hunter onto a Height it can land on.
            if int(h) in self._ledge_uv or any(st[0] == h for st in steps):
                g = bpy.data.objects.new(LEDGE_PREFIX + str(h), None)
                g.empty_display_type = "CUBE"
                g.empty_display_size = 0.3
                g.location = p
                bpy.context.collection.objects.link(g)

        if steps:
            self._grow_steps(steps, hs)

        print("CLIMB POINTS %d (every Height 0-%d): %s"
              % (len(self._final), self.sigil_height,
                 ", ".join("%d@z%.2f" % (h, self._final[h].z)
                           for h in sorted(self._final))))
        if moved:
            # Worth reading rather than ignoring: a big push means the LEDGE does
            # not reach the front of the beast, so the hunter now stands correctly
            # but on nothing visible. Extend that shelf forward in the script.
            print("PUSHED OUT %s  (a hunter is %.2f wide here; a push much bigger "
                  "than that means the ledge stops short of the body and wants "
                  "extending forward)"
                  % (", ".join("H%d by %.2f" % (h, d) for h, d in moved), hs))

    def _grow_steps(self, steps, hs):
        """A ledge under every climb point that ended up off the body.

        Small, and in the colour the script gave that ledge, so it reads as the
        same step rather than as a grey plank appearing from nowhere.
        """
        body = bpy.context.object
        made = []
        for h, p, out, push in steps:
            depth = push * 0.5 + hs * 0.55
            bpy.ops.mesh.primitive_cube_add(location=(0, 0, 0))
            o = bpy.context.object
            o.scale = (hs * 1.15, depth, hs * 0.16)
            o.rotation_euler = (0.0, 0.0, math.atan2(-out.x, out.y))
            bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
            o.location = p - out * (depth - hs * 0.5) - Vector((0, 0, hs * 0.16))
            self._paint(o, self._ledge_uv.get(h, SLATE))
            made.append(o)

        bpy.ops.object.select_all(action="DESELECT")
        for o in made:
            o.select_set(True)
        body.select_set(True)
        bpy.context.view_layer.objects.active = body
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        bpy.ops.object.join()
        # finish() counted and printed TRIS before this ran, so say what the
        # steps added rather than leaving a number in the log that is quietly
        # short of what actually shipped.
        me = bpy.context.object.data
        me.calc_loop_triangles()
        print("GREW %d step(s) out to climb points the ledges did not reach: %s "
              "— TRIS is now %d"
              % (len(made), ", ".join("H%d" % h for h, _, _, _ in steps),
                 len(me.loop_triangles)))

    def _rungs(self):
        """Every Height a hunter can be at, not just the ones with ledges.

        Nick, 2026-08-25: "often time while I'm playing I will get stuck inside
        the boss when I get knocked down half way." That is this. A hunter shaken
        off a ledge lands on some Height BETWEEN two of them, and with only the
        ledges anchored the view had to interpolate — along the straight line
        between two points on a body that bulges outward in between. The line
        goes through the chest.

        So anchor all of them. A Height with no ledge still gets a place to
        stand, pushed out to the surface like every other, and the view never has
        to guess.
        """
        return list(range(0, self.sigil_height + 1))

    def _rung(self, h):
        """Where Height `h` sits in BUILD space, authored or worked out.

        The height comes from the contract; the way round the body comes from
        the two authored points either side, so a climb that spirals keeps
        spiralling between its ledges instead of cutting the corner.
        """
        if h in self._anchors:
            return self._anchors[h]
        known = sorted(self._anchors)
        below = [k for k in known if k < h]
        above = [k for k in known if k > h]
        z = self.z_for(h)
        if not below:
            a = self._anchors[above[0]]
            return Vector((a.x, a.y, z))
        if not above:
            a = self._anchors[below[-1]]
            return Vector((a.x, a.y, z))
        lo, hi = below[-1], above[0]
        t = float(h - lo) / float(hi - lo)
        a, b = self._anchors[lo], self._anchors[hi]
        return Vector((a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, z))

    @staticmethod
    def _reach(tris, axis, p, out, hs):
        """How far the body reaches outward in the column around this point."""
        side = Vector((-out.y, out.x, 0.0))
        best = None
        for t in tris:
            m = (t[0] + t[1] + t[2]) / 3.0
            if abs(m.z - p.z) > hs * 1.6:
                continue
            rel = m - axis
            if abs(rel.x * side.x + rel.y * side.y) > hs * 2.0:
                continue
            d = rel.x * out.x + rel.y * out.y
            if best is None or d > best:
                best = d
        return best

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

    def hunter_size(self):
        """How big a hunter is, in this model's units.

        combat_3d scales every beast to BEAST_BASE_HEIGHT + PER_CLIMB * sigil and
        every hunter to a flat HUNTER_HEIGHT, so the ratio is knowable here — and
        it has to be, because "is there room to stand" is a question about the
        hunter's size, not the beast's.
        """
        want = 12.0 + 1.6 * float(self.sigil_height)     # combat_3d.gd
        return 0.7 * self.H / want                        # HUNTER_HEIGHT

    def _clearance(self, tris, lo, hi, name):
        """Is each climb point out where the body ends, or behind it?

        Nick, 2026-08-25: "the models of the climbers are meshing inside the
        bosses as they climb." A climb point can be exactly on its contract
        height, on a real shelf, and still be buried — because a shelf is a step
        OUT of a torso that keeps bulging past it, and the middle of that shelf
        is level with the chest it grew from.

        Counting geometry near the hunter does not catch it: a hunter is about a
        thirtieth of a beast, so the sphere it occupies is smaller than one of
        the beast's triangles. What does catch it is asking how far out the body
        reaches at that height, and comparing.
        """
        axis = Vector(((lo.x + hi.x) * 0.5, (lo.y + hi.y) * 0.5, 0.0))
        hs = self.hunter_size()
        bad = []
        for h in sorted(getattr(self, "_final", self._anchors)):
            a = self._final[h]
            out = Vector((a.x - axis.x, a.y - axis.y, 0.0))
            if out.length < 1e-4:
                out = Vector((0.0, -1.0, 0.0))            # beasts face -Y
            out.normalize()
            side = Vector((-out.y, out.x, 0.0))

            reach = None
            for t in tris:
                m = (t[0] + t[1] + t[2]) / 3.0
                if abs(m.z - a.z) > hs * 1.6:
                    continue
                rel = m - axis
                if abs(rel.x * side.x + rel.y * side.y) > hs * 2.0:
                    continue                              # not in this column
                d = rel.x * out.x + rel.y * out.y
                if reach is None or d > reach:
                    reach = d
            if reach is None:
                continue
            here = (a - axis).x * out.x + (a - axis).y * out.y
            deep = reach - here
            # A full hunter-width of slack, because by the time this runs the
            # model has GROWN a step at the climb point, and that step is body
            # too — so a point can read as marginally behind its own ledge. The
            # failure worth catching is a point deep inside a torso, not one a
            # few centimetres back from the lip it is standing on.
            ok = deep <= hs * 1.05
            print("  ROOM  %-10s %s"
                  % ("ground" if h == 0 else "Height %d" % h,
                     "clear" if ok else
                     "BURIED %.2f behind the body (a hunter is %.2f wide)"
                     % (deep, hs)))
            if not ok:
                bad.append(h)
        if bad:
            print("FAIL %s: climb point(s) %s sit inside the silhouette. Move "
                  "them out along the front — a hunter standing there is inside "
                  "the beast." % (name, bad))

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

        self._clearance(tris, lo, hi, name)

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
        for h in sorted(getattr(self, "_final", self._anchors)):
            p = self._final[h]
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
