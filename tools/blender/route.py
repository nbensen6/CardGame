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
