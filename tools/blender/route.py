"""A beast's climb only ever sweeps one way -- the rule both authoring paths
share, and the one place that rule lives.

Nick, 2026-09-23: the Cinder Jackal's climb goes paw -> shoulder -> haunch,
one smooth sweep backward along the spine, then the LAST hold -- the sigil --
jumps back to the head, past every hold the climb already used. Root cause
was `tools/blender/ai_beast.py`'s sigil raycast, which picks any upward-facing
surface near the head with zero awareness of which direction the route was
already heading; `tools/blender/beast.py`'s hand-authored `mark()`/`anchor()`
calls can make the identical mistake (confirmed live: `crag_pup.py` anchors
Height 2 at y=-0.30, then its own `mark()` places the sigil at y=-0.50 --
backward toward the foot at y=-0.66, the same shape of bug from a human
picking the number instead of a raycast).

Deliberately no `bpy` import: this is pure (x, y) arithmetic, so
`python3 tools/blender/test_route.py` proves the rule with no Blender install
at all, and both `ai_beast.py` (which raycasts a body for a hold and can
choose among several candidate surfaces) and `beast.py` (which trusts a
number a person typed) import the same two functions rather than each
growing its own copy that can drift out of agreement with the other.

The direction of "forward" is never assumed (a beast is not guaranteed to be
built facing any particular axis -- see beast.py's own `_clearance`, which
falls back to -Y only when a hold sits exactly on the body's centre and
there is nothing else to go on). Instead it is DERIVED from the two rungs
already placed below the one being checked, so this holds for a route that
curves gradually around a body, not only a straight line.
"""
import math

## How much a rung has to move past the one below it, in the model's own
## height units, to count as real forward progress rather than noise in a
## raycast search or a rounding error in a hand-typed number. Small on
## purpose: this only has to catch a genuine reversal, not flatten the
## alternating side-to-side jitter every climb already uses on purpose (see
## ai_beast.py's own "alternate a little either side so the route zigzags
## instead of stacking").
MIN_STEP_FRAC = 0.03


def route_direction(anchor_before_last, last_anchor):
    """The (dx, dy) the climb was moving between the last two rungs placed.

    `(0.0, 0.0)` when there is no direction yet -- fewer than two rungs
    placed so far -- which is a real, valid state: a route's first hold
    cannot contradict a direction that does not exist yet.
    """
    if anchor_before_last is None or last_anchor is None:
        return (0.0, 0.0)
    return (last_anchor[0] - anchor_before_last[0], last_anchor[1] - anchor_before_last[1])


def route_progress(last_anchor, candidate, direction):
    """How far `candidate` continues `direction` from `last_anchor`.

    A plain dot product: positive is further along the sweep the climb was
    already making, zero or negative is stalled or reversed. With no
    established direction yet, everything continues it (there is nothing to
    contradict), reported as a progress of exactly `1.0` so a caller
    comparing against a positive `min_step` still passes.
    """
    if direction == (0.0, 0.0):
        return 1.0
    return ((candidate[0] - last_anchor[0]) * direction[0]
             + (candidate[1] - last_anchor[1]) * direction[1])


def keep_route_going(anchor_before_last, last_anchor, candidate, min_step):
    """Where this rung should actually land, given the two rungs below it.

    `candidate` -- a raycast search's own pick -- is used unchanged as long
    as it makes at least `min_step` of progress along the direction the
    previous two rungs already established. When it does not (it stalls, or
    it reverses), it is pushed forward along that same direction by
    `min_step` instead, so a climb can never double back on itself: "a
    route only ever goes one way" (Nick, 2026-09-23). With fewer than two
    rungs placed so far, or a degenerate (zero-length) direction, the
    candidate always passes through unchanged -- a route's first hold
    defines the sweep, it cannot break it.
    """
    direction = route_direction(anchor_before_last, last_anchor)
    if direction == (0.0, 0.0):
        return candidate
    if route_progress(last_anchor, candidate, direction) >= min_step:
        return candidate
    dlen = math.hypot(direction[0], direction[1])
    if dlen == 0.0:
        return candidate
    ux, uy = direction[0] / dlen, direction[1] / dlen
    return (last_anchor[0] + ux * min_step, last_anchor[1] + uy * min_step)


def route_violation(anchor_before_last, last_anchor, candidate, min_step):
    """True when `candidate` fails to make `min_step` of progress along the
    direction the last two rungs already established.

    The same rule `keep_route_going` silently corrects for a raycast
    search; here it is surfaced instead, so a HAND-authored mistake
    (`beast.py`'s `mark()`/`anchor()`) stops the build the same way the
    anatomy gate already does, rather than quietly moving a point an artist
    placed on purpose to a spot they never chose.
    """
    direction = route_direction(anchor_before_last, last_anchor)
    if direction == (0.0, 0.0):
        return False
    return route_progress(last_anchor, candidate, direction) < min_step


## combat_3d.gd's own hop_arc(): `hop = clampf(distance * 0.26, HUNTER_HEIGHT *
## 0.9, HUNTER_HEIGHT * 3.4)` -- `distance` is the hold-to-hold gap itself
## (`from.distance_to(to)`), `hop` is the resulting arc's RISE, not the gap.
## Below the floor every hop gets the identical minimum rise regardless of how
## close the holds really are (bouncing in place); above the cap the rise
## stops growing with distance (stops reading as effort) -- Nick's approval of
## the stone-route proposal, 2026-09-23: "ordinary hops inside the arc
## system's proportional band, not at its floor." Solving the clamp's own
## edges for `distance` (not `hop`) gives the band a hold-to-hold GAP has to
## sit inside: 0.9*0.7/0.26 = 2.42, 3.4*0.7/0.26 = 9.15 -- the 2.4/9.2 world
## units the playtester's own numbers already named. HUNTER_HEIGHT and
## ARC_DISTANCE_SCALE are combat_3d.gd's own constants, mirrored here the same
## way beast.py's hunter_size() already mirrors BEAST_BASE_HEIGHT/
## BEAST_HEIGHT_PER_CLIMB -- this file cannot import a .gd script, so the
## numbers are typed once, here, and nowhere else in Python.
HUNTER_HEIGHT = 0.7
ARC_DISTANCE_SCALE = 0.26                              # hop_arc()'s own `* 0.26`
HOP_MIN_WORLD = (HUNTER_HEIGHT * 0.9) / ARC_DISTANCE_SCALE   # hop_arc()'s clamp floor, solved for distance
HOP_MAX_WORLD = (HUNTER_HEIGHT * 3.4) / ARC_DISTANCE_SCALE   # hop_arc()'s clamp ceiling, solved for distance


def hop_world_distance(mesh_distance, hunter_size):
    """`mesh_distance` (a beast's own build units) converted to the world
    units hop_arc() actually measures and clamps against.

    `hunter_size` is `Beast.hunter_size()` -- the mesh-space size that
    combat_3d.gd's runtime rescale (`_fit_height`, `want = BEAST_BASE_HEIGHT
    + BEAST_HEIGHT_PER_CLIMB * sigil`) turns into one HUNTER_HEIGHT of real
    world space. A beast's own build height (and so its own rescale factor)
    is never the same number twice, so this ratio -- not a flat constant --
    is what turns a model's own units into the ones hop_arc() clamps.
    """
    if hunter_size <= 0.0:
        return 0.0
    return mesh_distance * (HUNTER_HEIGHT / hunter_size)


def hop_distance_violation(mesh_distance, hunter_size):
    """None when the hold-to-hold hop `mesh_distance` lands inside
    hop_arc()'s proportional band once rescaled to world units; otherwise
    "short" (below the floor -- every such hop gets the same bounce-in-place
    arc) or "long" (past the cap -- the arc stops growing, so it stops
    reading as effort), naming which side it missed on.
    """
    world = hop_world_distance(mesh_distance, hunter_size)
    if world < HOP_MIN_WORLD:
        return "short"
    if world > HOP_MAX_WORLD:
        return "long"
    return None


def enforce_hop_floor(last_xy, dz, candidate_xy, min_mesh_dist, fallback_direction=(0.0, 0.0)):
    """Push `candidate_xy` further from `last_xy` until the full hop --
    (x, y) movement combined with the climb's own fixed vertical step `dz`
    between the two rungs' Heights -- reaches `min_mesh_dist` (a beast's own
    mesh-unit equivalent of hop_arc()'s floor; see hop_distance_violation).

    Confirmed live on the shipped Cinder Jackal AI rebuild, 2026-09-23: every
    middle rung already gets pushed forward by `keep_route_going` (the
    anti-reversal rule) whenever the raycast search stalls near the top of
    the climb, where the body narrows -- but that push is sized only to
    prove *some* forward progress, not to clear hop_arc()'s actual distance
    floor, so two real rungs (Height 3->4, 4->5) landed a genuine hop_arc()
    bounce-in-place distance apart. Only the (x, y) half of a hop is ever
    adjusted here -- `dz` is the climb's own per-Height contract (see
    `ref_marks` in ai_beast.py / FOOT_LOW..FOOT_HIGH in beast.py) and is
    never something a route rule should move.

    Extends along the line `candidate_xy` already sits on relative to
    `last_xy` (a real raycast pick keeps its own direction) unless the two
    coincide, in which case `fallback_direction` (typically the route's own
    established sweep, from route_direction) is used instead. Like
    `keep_route_going`, this returns a POINT, not a verdict -- the caller is
    expected to re-snap it onto the body's real surface with its own
    raycast, the same way a moved sigil pick already does.
    """
    need_xy_sq = min_mesh_dist * min_mesh_dist - dz * dz
    if need_xy_sq <= 0.0:
        return candidate_xy       # the Height step alone already clears the floor
    need_xy = math.sqrt(need_xy_sq)
    dx, dy = candidate_xy[0] - last_xy[0], candidate_xy[1] - last_xy[1]
    have_xy = math.hypot(dx, dy)
    if have_xy >= need_xy:
        return candidate_xy
    if have_xy > 1e-6:
        ux, uy = dx / have_xy, dy / have_xy
    else:
        fx, fy = fallback_direction
        flen = math.hypot(fx, fy)
        if flen < 1e-6:
            return candidate_xy   # nothing to extend along -- leave it as found
        ux, uy = fx / flen, fy / flen
    return (last_xy[0] + ux * need_xy, last_xy[1] + uy * need_xy)
