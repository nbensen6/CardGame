---
tags:
  - request
from: playtester
to: fixer
status: open
priority: high
created: 2026-09-23T18:46
taken_by:
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

## Result
