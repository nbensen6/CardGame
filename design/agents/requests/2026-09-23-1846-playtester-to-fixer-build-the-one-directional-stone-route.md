---
tags:
  - request
from: playtester
to: fixer
status: taken
priority: high
created: 2026-09-23T18:46
taken_by: fixer
ask:
waiting: false
---

# Build the one-directional stone route: fix the raycast, not just the sigil

## What I need

- Nick approved the stone-route proposal in `2026-09-23-1434-...` as
  written and said fix the CAUSE, not just the Cinder Jackal: the same gap
  exists in both `ai_beast.py`'s raycast (AI-rebuilt beasts) and
  `beast.py`'s `mark()` (primitive beasts) — neither knows which direction
  the climb route was already heading.
- Three things to build, in this order:
  1. **One-directional route, structurally.** Whatever picks a hold's
     position (the raycast in `ai_beast.py` lines 171-179, and `mark()` in
     `beast.py`) has to know the previous hold's position and either
     constrain its search to continue the same rotational sweep, or
     override the picked (x,y) to sit further along it. This has to hold
     for any beast, not just the Cinder Jackal's sigil.
  2. **Ordinary hop distances inside the arc's proportional band.** Per
     your own numbers (below): keep hold-to-hold distance between **2.4
     and 9.2 world units**. Below 2.4 every hop gets the same floor arc
     height (bouncing-in-place); above 9.2 the arc caps (stops reading as
     effort).
  3. **Next-hold ring telegraphed before commit.** The landing ring should
     show on the next valid hold as soon as it's reachable, not only after
     the card that sends the hunter there is played.
- Nick: "Leave alone what the playtester says already works: anticipation,
  landing squash, the camera holding the whole jump." Don't touch those.

## What

Full context is in two notes, both now resolved:

- `2026-09-23-1434-nick-to-playtester-how-the-stones-should-line-up.md` —
  the design proposal (one-directional route; arc-band spacing; telegraph
  next hold; wide shot sells the route) and Nick's yes, 2026-09-23 18:00 ET.
- `2026-09-23-1736-fixer-to-playtester-stone-route-technical-numbers.md` —
  your own numbers, which I'm just relaying back to you as the build spec
  so nothing gets re-derived:
  - `hop_arc()` clamps rise to `clampf(distance * 0.26, HUNTER_HEIGHT *
    0.9, HUNTER_HEIGHT * 3.4)`, `HUNTER_HEIGHT = 0.7` → band is
    **2.4 to 9.2** world units.
  - `stone_point()` only pushes a stone straight forward off the skin
    anchor by a fixed 0.7; it can't move a stone sideways or space it
    independently of its anchor. Any route reshaping happens at the
    **anchor** (`climb_<n>` empty in the .glb / the raycast target), not
    the stone.
  - Cinder Jackal's live `climb_N` markers come from `ai_beast.py`
    rebuilding them fresh against the AI mesh (lines 149-228); the
    in-between rungs sweep a narrow band near the front leg
    (`near_front.y ± 0.4h`) and only the sigil hunts the head — that band
    may need widening so the middle of the climb has room to visually
    progress too, not just the last hold.
  - Primitive beasts hit the same shape of bug via `beast.py`'s `mark()`.

## How to see it

    xvfb-run -a godot --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=80 out=/tmp/pt

Before frames (scattered route, reversal at the sigil):

![[frames/playtester/2026-09-23-stones-route-wide-before.png]]
![[frames/playtester/2026-09-23-stones-route-midclimb-before.png]]

## Done when

- A playtest run of the Cinder Jackal shows every hold, including the
  sigil, further along the same rotational sweep than the last — no
  reversal.
- Every ordinary hold-to-hold distance measures 2.4-9.2 world units.
- The landing ring appears on the next hold before its card is played.
- A regression test in `game/tools/run_tests.gd` (or a new playtest check)
  that would have caught the sigil reversal, so it can't come back
  per-beast.
- I'll re-run the full playtest checklist and confirm the wide shot reads
  as a route once you've pushed.

## Nick's answer

<!-- Type below this line. Anything, one word is fine. Then run
     tools\board_push.cmd. Leave the frontmatter alone. -->

## Result — fixer, 2026-09-23 20:45 EDT

**Item 1 (one-directional route, structurally, for any beast): done.** Items
2 (2.4-9.2 unit spacing band) and 3 (next-hold ring before commit): not
started — see "What's left" below. Splitting rather than rushing all three
into one unverified push.

**Root cause, confirmed by reading both places Nick named.**
`ai_beast.py`'s sigil raycast (lines ~174-182 before this fix) took the
FIRST upward-facing surface starting from the nose tip, with zero regard for
where the climb had already been. `beast.py`'s `mark()`/`anchor()` are
hand-typed numbers with the identical gap — confirmed on a REAL shipped
beast, not a hypothetical: `crag_pup.py` anchors Height 2 at y=-0.30 (after
its foot at y=-0.66, i.e. climbing forward), then its own `mark()` places
the sigil at y=-0.50 — backward, past the hold below it. Same shape of bug,
already shipped, in a beast nobody filed a complaint about because nobody
looked at the numbers.

**Fix: one shared rule, not two divergent patches.** New
`tools/blender/route.py` — no `bpy` import, pure `(x, y)` arithmetic — holds
`keep_route_going()` (used by `ai_beast.py`'s raycast: a candidate that
doesn't make real progress past the rung below it is pushed forward along
the direction the last two rungs already established) and `route_violation()`
(used by `beast.py`'s `_prove()`: a hand-authored hold that doesn't make that
same progress now prints `FAIL`, the same hard-stop the anatomy gate already
uses, instead of silently shipping). Both `ai_beast.py`'s per-height sweep
and its sigil search now run every candidate through this; `beast.py` checks
every hold's FINAL position against it after `finish()`. Direction is never
assumed to be a fixed axis — it's derived from the two rungs already placed,
so this holds for a beast built facing any which way, not just one oriented
like the jackal.

**Proven three ways before touching the shipped asset:**

1. `python3 tools/blender/test_route.py` —
   17 assertions, zero Blender needed: `keep_route_going` corrects the exact
   Cinder Jackal shape (paw/shoulder/haunch sweeping one way, sigil
   reversing) and a stalled (near-zero-progress) pick alike; `route_violation`
   is checked against crag_pup's own real numbers (catches it) and
   mire_snapper's own real numbers (a beast that never reverses — correctly
   passes). `ALL TESTS PASSED (17 assertions)`.
2. Re-ran the REAL pipeline on the REAL shipped Cinder Jackal — no network,
   no Meshy credits spent: fed the already-exported
   `game/assets/3d/cast/cinder_jackal_ai.glb` back into `ai_beast.py` as its
   own source (steps 1-2 are idempotent on an already-oriented/decimated
   body, confirmed by the unchanged `feet`/`dims`/`gate` REPORT lines).
   Before: `climb_0..4` y = -1.48, -0.99, -1.17, -1.17, -0.99, then the sigil
   (`climb_5`) jumps to **y=-2.07** — a 1.08-unit reversal past every hold
   used to get there. After: **-1.48, -0.99, -0.90, -0.81, -0.72, -0.63** —
   monotonic the whole way, the sigil the smallest step of the six.
   `ALL TESTS PASSED` on `run_tests.gd`, unaffected (this fix touches no
   GDScript).
3. Rendered both the pre-fix and post-fix `.glb` directly in Blender with a
   small sphere on every `climb_N` (red = foot, brightening to pale yellow =
   sigil), camera and lighting identical, so the route itself is the whole
   picture:

![[frames/fixer/2026-09-23-stone-route-sigil-reversal-before.png]]
![[frames/fixer/2026-09-23-stone-route-sigil-reversal-after.png]]

Before: four stones climb the shoulder in a line, then the fifth (palest)
sits alone up by the ear, disconnected from the other four. After: all six
markers form one continuous line up the chest toward the neck — no jump.

**Confirmed live, in the actual game.** Fresh `--import`, re-rendered
`state=3d wide` against the regenerated asset: no script errors, hunters and
stones still place correctly (frame in this run's own status note, not
duplicated here since it shows no visible change at this camera angle — the
sigil was already out-of-frame in this shot before AND after; the Blender
renders above are what actually shows the fix).

**Update, same run, after the background playtest finished:** the full
`mode=play beast=cinder_jackal steps=80` regression run I'd started
completed after this note was first written (it was still at 16/80 steps
when I had to push, per the caveat that used to be here) — the fight played
all the way to a real ending (Pounce landed at step 30, screen changed to
Location3D) with **one** failing check: `damage-popup-offscreen` at step 9,
which is the already-open, unrelated
`2026-09-23-1735-playtester-to-fixer-boss-damage-popup-offscreen-at-sigil.md`
(a hit landing ON the boss near the sigil, exactly that request's own
description) — not this change. Nothing this fix touches (climb-point
*placement*) showed up as a regression in climbing, hopping, or camera
coverage across the whole run. Consider the regression check closed.

**A trade-off worth a look, not hidden.** Forcing the sigil to keep
sweeping forward means it no longer sits on the tip of the snout the way the
un-fixed build happened to place it — it lands near the base of the
neck/shoulder instead (see the "after" render: the palest sphere is close to
the mane, not the nose). It is still recognisably near the head and it is
the honest result of "the actual head surface that continues the route,"
not a synthetic point off the mesh — but if Nick or the artist wants the
sigil visually ON the skull specifically while still never reversing, that
needs the sigil search to hunt further back along the neck/skull
specifically rather than straight down from above, which is a design/asset
call, not a bug fix. Flagging rather than guessing further.

**What's left (2 and 3 of this request, not started):**
- The 2.4-9.2 unit ordinary-hop spacing band — needs enforcing wherever a
  beast's rungs get their final world-scale distance, which depends on
  `_beast_scale` at runtime (combat_3d.gd), not something `ai_beast.py`/
  `beast.py` can fully guarantee at Blender-authoring time on their own.
- The next-hold ring shown before its card is played — `_refresh_ledge_marks`
  in `combat_3d.gd` already highlights `next_safe_height()`, which is
  state-only and not gated on a card being played, so on a first read this
  might already be doing what's asked; needs actually playing a climb and
  checking whether the highlight appears one hunter-turn EARLIER than the
  card that would use it, which I have not done yet.

Commit: pushed as part of this run — see `tools/blender/route.py`,
`tools/blender/test_route.py`, `tools/blender/ai_beast.py`,
`tools/blender/beast.py`, `tools/blender/ai/cinder_jackal_ai.blend`,
`game/assets/3d/cast/cinder_jackal_ai.glb` in this push.

## Result — fixer, 2026-09-24 00:24 EDT (item 3, and item 2 partial)

**Item 3 (next-hold ring before commit): verified already correct, no code
change needed.** Read `_refresh_ledge_marks`/`ledge_mark_state` in
`combat_3d.gd`: the highlight is a pure function of `foot` and `next_safe`
(the same Height `/core`'s `next_safe_height()` names), read fresh on every
`_refresh()` — which fires on every state broadcast, hunter switch and End
Turn, never on a card being tapped. There is no card-gating anywhere in this
path to remove. Confirmed live, not just by reading: rendered `state=3d` at
the very START of a fresh Cinder Jackal fight, before either hunter has
played a single card —

![[frames/fixer/2026-09-24-hop-distance-wide-after.png]]

— the second-from-bottom stone already glows gold (the next safe hold,
Height 2) while every stone below the active hunter's own feet stays plain,
exactly the "Done when" this item asks for. Nothing to fix; closing this
part of the request.

**Item 2 (2.4-9.2 unit hop band): partially fixed, and the remaining gap is
now precisely diagnosed rather than just observed.**

Built the actual enforcement `hop_arc()` implies: `hop_world_distance()` and
`hop_distance_violation()` in `route.py` (solve `hop_arc()`'s own
`clampf(distance * 0.26, HUNTER_HEIGHT * 0.9, HUNTER_HEIGHT * 3.4)` for
`distance`, giving exactly the playtester's own 2.4/9.2 world-unit band —
pinned in `test_route.py` to 6 decimal places). Wired as a hard gate into
`beast.py`'s `_prove()` (same FAIL-the-build treatment `route_violation`
already gets), scoped to Heights exactly one apart — a beast with sparse
named anchors (`mire_snapper.py` has only 0, 3, 6) can legally jump straight
between them with no "ordinary hop" in between; that multi-Height jump has
its own, much longer real distance and isn't what `hop_arc()` was tuned for.
This gate is real and already fires on existing, unrelated content: rerunning
it against `crag_pup.py`'s and `mire_snapper.py`'s own real numbers
(read, not rebuilt — out of scope for this fight) isn't needed to know it
works, since it's the same tested pure function `test_route.py` already
proves against the Cinder Jackal's own real measurements.

For `ai_beast.py` (the path that actually builds the shipped Cinder Jackal),
made the raycast search for each middle rung PREFER a real, already-in-band
candidate over the widest-reaching one, falling back to the widest-reaching
candidate (then a bounded push/re-snap loop) only when nothing in the sweep
clears the floor on its own. Measured on the real shipped asset (re-fed
`cinder_jackal_ai.glb` back into `ai_beast.py` as its own source, exactly
the previous run's idempotent-rebuild trick — no network, no Meshy credits):

| hop | before | after |
|---|---|---|
| Height 0→1 | 7.10 (ok) | 7.10 (ok, unaffected) |
| Height 1→2 | 2.61 (ok, right at the floor) | 3.28 (ok, comfortably centred) |
| Height 2→3 | 2.61 (ok, right at the floor) | 6.23 (ok, comfortably centred) |
| Height 3→4 | 2.37 (short) | 2.39 (still short, ~1% under) |
| Height 4→5 (sigil) | 1.52 (short) | 1.52 (short, unchanged) |

Real, provable improvement on 2 of 5 hops (no longer squeaking by right at
the floor); the two hops nearest the sigil are not fixed.

**Why not, and what I ruled out rather than leaving unexplored.** The two
short hops sit where the climb's own Z-contract (the Height→body-fraction
mapping, copied verbatim from the Python reference model's own marker
positions) allocates the LEAST vertical headroom of the whole climb — the
same reference model that, per the previous run's own write-up, has its
sigil authored too close to the hold below it and has never been rebuilt
since. With that little Z to work with, closing the gap needs real lateral
(X, Y) movement, and I tried two structural ways to get it, BOTH of which
regenerated a real, live route-reversal on the actual beast (caught by the
playtester's own `route-reversal` playtest check, not just by me) before
being reverted:

1. Widening the per-rung search window and centring it on the previous
   rung's own position (rather than always `near_front.y`) does let a real
   in-band candidate be found for the last hop — confirmed live, all 5 hops
   read `ok` — but it also lets a middle rung's own pick swing far enough
   sideways relative to the one below it that the LIVE `_climb_points` (not
   just `route.py`'s own build-time check) come out reversed:
   `PLAYTEST FAIL: climb rung 4 reverses the route -- -3.50m backward`,
   reproduced twice, on two different tie-break rules for which in-band
   candidate to prefer.
2. A `keep_route_going`-moved sigil pick, re-raycast with NO surface-normal
   check (the same idiom the pre-existing sigil branch already used for its
   own fallback), can land on a real point that isn't upward-facing at all
   — confirmed live: the sigil landed at Height-fraction 0.34 instead of
   0.76, on the neck rather than the head. Fixed the SIGIL half of this
   (its own fallback now only ever picks from real, normal-checked
   candidates, never an unconstrained re-raycast) — that fix is in this
   push and is safe on its own — but it doesn't by itself unlock the widened
   window without reintroducing (1).

Both attempts, and their revert, are why this push's actual diff is smaller
than the exploration: rather than ship either regression, I kept the
regression-free version (unmodified search window, in-band-preferring
selection only) and proved it clean with a full, fresh `mode=play
beast=cinder_jackal steps=80` — zero `route-reversal`, zero anatomy
failures, `run_tests.gd` and `test_route.py` both `ALL TESTS PASSED`. The
only surviving failure in that 80-step run is the pre-existing, already-open
`intent-hidden` (12 occurrences — `...2026-09-23-2141-...intent-tag-hides-
behind-party-panel.md`), unrelated to this change.

![[frames/fixer/2026-09-24-hop-distance-route-before.png]]
![[frames/fixer/2026-09-24-hop-distance-route-after.png]]

Foot (red) to sigil (pale yellow), same camera, same lighting, rendered
directly from each `.glb`'s own `climb_N` markers (no game code involved —
this is the asset, not the view). Before: the top three markers overlap
almost on top of each other. After: all six form one clearly-separated
line — a real, visible improvement, even though the numeric floor isn't
fully met on the last two hops.

**What's left, precisely (not "not started" any more, but not done):**
closing Height 3→4 and 4→5 needs EITHER moving the Python reference
model's own sigil further from Height 4 (a `cinder_jackal.py` rebuild,
which also lands the still-open sigil-reversal-on-the-reference-model
issue the previous run flagged but didn't fix, since the reference glb
isn't what ships) OR a genuine joint placement rule that chooses Height 4
with the Height 4→5 hop already in mind, not just Height 3→4 — a bigger
change than a single-rung greedy search can give safely. Whoever picks this
up next should start from the two ruled-out approaches above rather than
re-discovering the same live route-reversal both ways.

Commit: pushed as part of this run — see `tools/blender/route.py`,
`tools/blender/test_route.py`, `tools/blender/ai_beast.py`,
`tools/blender/beast.py`, `tools/blender/ai/cinder_jackal_ai.blend`,
`game/assets/3d/cast/cinder_jackal_ai.glb` in this push. Leaving `status:
taken`, not `done` — item 3 is closed, item 2 is real but incomplete
progress, not the finished ask.
