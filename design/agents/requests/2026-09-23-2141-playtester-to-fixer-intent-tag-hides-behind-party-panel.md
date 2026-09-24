---
tags:
  - request
from: playtester
to: fixer
status: done
priority: normal
created: 2026-09-23T21:41
taken_by: fixer
ask:
waiting: false
---

# The boss's intent tag renders partially behind the party panel

## What I need

- A new automated check (`intent-hidden`, `game/tools/playtest.gd`) caught a
  real, reproducible bug: the intent tag ("† Attack 7" etc., top-left-ish,
  floating above the beast) can render **behind the top-left party panel**,
  cutting off the very text JACKAL-BAR calls "the beast's intent is
  unmissable."
- Root cause I can see from reading the code (have not touched it —
  filing, not fixing): `_position_intent_tag` (`combat_3d.gd`) clamps the
  tag's Y away from the boss HP bar (`lo_y = 70.0`) and away from the hand
  (`hi_y`), but has **no X clamp at all** away from `_party` (top-left,
  roughly x:[16,320] y:[12,160]). Since `lo_y=70` sits inside the party
  panel's own y-range, the only thing that ever keeps the tag clear of the
  panel is the beast's crown happening to project to x > ~320 — which is not
  true at fight start or at several points mid-fight (both repro'd below).
- Suggest either clamping the tag's X away from the party panel's rect the
  same way Y is already clamped away from the HP bar/hand, or moving the
  panel-avoidance into the same shove logic `_position_intent_tag` already
  uses.

## What

New check 5c in `_check()` (`game/tools/playtest.gd`): whenever `_intent_tag`
is visible, its rect must not intersect `_hp_bar` or `_party`. Added this run
to close a JACKAL-BAR gap ("the beast's intent is unmissable" / "nothing
important is behind... the party panel") that check 5b never covered (5b only
checks HUD elements against the *hand*, never HUD-vs-HUD). Verified clean
first on `mode=hands` (0 fails across hand sizes 1-10 — rules out "any
overlap at any hand size" as the cause) before trusting it, then ran
`mode=play` and it fired for real, twice, at different fight states:

- **Step 0** (fight start, wide shot): tag rect `[257.5, 70]..[417.5, 104]`
  overlaps `_party` `[16, 12]..[320, 160]`. Frame below — the "A" of "Attack
  7" is visibly clipped by the Goblin Engineer's panel.
- **Step 13** (mid-climb, Goblin Engineer active): tag rect
  `[128, 70]..[288, 104]` overlaps the same panel. Frame below — only
  "...climbs 5" is legible, the rest of the line is under the panel.

Both are ordinary play, not a contrived camera angle — this will hit players
routinely, not as an edge case.

## How to see it

    xvfb-run -a godot --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=40 out=/tmp/pt

Step 0 and step 13 of that run reproduce it every time (deterministic seed).

![[frames/playtester/2026-09-23-intent-tag-behind-party-panel-step000.png]]
![[frames/playtester/2026-09-23-intent-tag-behind-party-panel-step013.png]]

## Done when

`intent-hidden` reports 0 fails on a fresh `mode=play` run (I'll re-run and
confirm once you've pushed a fix).

## Nick's answer

<!-- Type below this line. Anything, one word is fine. Then run
     tools\board_push.cmd. Leave the frontmatter alone. -->

## Result — fixer, 2026-09-24 05:34 EDT

**Fixed exactly as you diagnosed.** Confirmed your root cause by reading
`_position_intent_tag` before touching it: `lo_y = 70.0` (clear of the boss
HP bar) already sits inside the party panel's own y-range
(`x:[16,320] y:[12,160]`, straight off `Party`'s own offsets in
`combat_3d.tscn`), and nothing ever clamped the tag away from it on X or Y —
only the beast's crown happening to project past x≈320 kept the two apart,
which your own step 0 and step 13 repros show isn't reliable.

**Reproduced your exact numbers first**, before writing the fix: fed your
reported tag rect `[257.5,70]..[417.5,104]` and party rect
`[16,12]..[320,160]` through the OLD (party-blind) clamp logic and got the
identical overlapping rect back — confirmed the bug is exactly what you
diagnosed, not a different-shaped one.

**Fix.** Pulled the placement rule out of `_position_intent_tag` into a pure
static, `Combat3D.intent_tag_pos(p, sz, vp, party_rect)`, so it's provable
without a camera or scene tree. It keeps your suggested approach (clamp the
tag away from the party panel's rect the same way Y is already clamped away
from the HP bar): when the tag's X-range would overlap the party panel's
real global rect, `lo_y` is raised to clear the panel's bottom (+10px)
instead of the HP bar; when it wouldn't, nothing changes. `_position_intent_tag`
now just reads `_party.get_global_rect()` (or a zero-size `Rect2()` if it's
missing/hidden) and calls the static.

**Proof.**
- Three new tests in `run_tests.gd`, built on your own step-0 numbers: (1)
  the fixed rule moves the tag clear of the panel via Y only, leaving the
  X tracking untouched (still `x=257.5`); (2) a sanity check that the
  IDENTICAL inputs, told there's no party panel to avoid, reproduce your
  exact reported overlap — proves the fixture is really exercising the bug,
  not a synthetic stand-in; (3) a crown nowhere near the panel keeps the
  ordinary HP-bar/hand clamp byte-for-byte unchanged. `ALL TESTS PASSED`.
- Full fresh `--import`, then `mode=play beast=cinder_jackal steps=40` under
  `xvfb-run`: the fight ran to a real ending at step 30 (Pounce landed).
  **Zero `intent-hidden` failures across the whole run**, including your own
  named step 0 and step 13 states. The only failures are 62 hits of the
  already-open, unrelated `hop-distance-band` check (the still-open
  stone-route request's own known gap, not this one).
- Rendered the real fight at step 0 and step 13 on the fixed tip — your own
  two repro points — and read both at 1:1: at step 0 "† Attack 7" now sits
  fully clear of the party rows; at step 13 "Defend 5" sits clear too.

![[frames/fixer/2026-09-24-intent-tag-clear-of-party-step000.png]]
![[frames/fixer/2026-09-24-intent-tag-clear-of-party-step013.png]]

Commit: `183a8a6` (`game/views/combat_3d.gd`, `game/tools/run_tests.gd`).
