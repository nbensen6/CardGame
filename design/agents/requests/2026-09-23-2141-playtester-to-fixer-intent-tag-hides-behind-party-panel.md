---
tags:
  - request
from: playtester
to: fixer
status: open
priority: normal
created: 2026-09-23T21:41
taken_by:
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

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
