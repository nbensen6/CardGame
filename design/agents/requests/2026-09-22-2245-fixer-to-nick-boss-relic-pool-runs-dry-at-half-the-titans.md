---
tags:
  - request
from: fixer
to: nick
status: open
priority: normal
created: 2026-09-22
taken_by:
---

# In 2-player co-op, the boss-relic pool is empty for the last two Titans — the reward screen shows nothing to tap, and the prompt still says to tap one

## What I need

- There are 4 boss relics and 4 Titans, but in 2-player co-op **both** hunters
  take one each — so the pool is empty after the 2nd Titan and the last two
  reward screens have nothing in them.
- The part that was plainly broken is already fixed: the screen no longer tells
  you to tap something that isn't there.
- What's left is yours: **is 2 relics per Titan the cadence you want?**
  - **Add 4 more boss relics** (8 total) so every Titan can pay both hunters.
    Recommended — it's the only option that keeps the last two Titans feeling
    like rewards, and it's content, not a rule change.
  - **Let both hunters pick the same relic** — no new content, but the two of
    you stop making a real choice against each other.
  - **Leave it** — the last two Titans deliberately give nothing, and the
    hunters are meant to Skip.
- Not urgent: this is outside the Cinder Jackal fight.

## What

Found while hunting bugs per the fixer brief (no open `to: fixer` request
this run) — outside the Cinder Jackal fight itself, so filing rather than
fixing (board rule: "Work outside the Cinder Jackal fight unless a request
asks you to").

`relics.json` has exactly 4 `tier: "boss"` relics (`warlords_girdle`,
`bottomless_quiver`, `fortress_ward`, `adrenal_surge`) — sized, per
`design/BACKLOG.md`'s 2026-08-25 #48 entry, for the 4-Titan ladder
(`Run.ENCOUNTERS`). But `Run._begin_reward()` gives BOTH hunters their own
independent roll from that same shared, team-wide pool, and a relic either
one picks is struck from both lists (`pick_reward`, run.gd:989-997) — so a
2-player run spends relics from the pool **twice as fast as Titans are
felled**. With both hunters taking a relic every boss (the normal, greedy
play a "choose a lasting boon" screen invites), the pool is down to 0 after
just the 2nd Titan, and the 3rd and 4th Titans' reward screens offer
**nothing**: an empty card row, "Lock In Reward" permanently disabled
(needs `_selected >= 0`, and nothing is ever selectable), and the header
prompt still reads "**Tap a relic to select**" — which is impossible. The
only way through is the "Skip" button, which the prompt never mentions.

This isn't a screenshot-harness artifact — I first hit it because
`screenshot.gd`'s `state=3dwon` driver (which auto-plays `pick_reward(sl,
0)` for both hunters at every reward) got stuck spinning 400 iterations at
the 3rd Titan's reward and never reached WON, because index 0 never exists
once `reward_choices[slot]` is empty (`pick_reward` silently no-ops when
`choice >= choices.size()`, run.gd:975). A real 2-player team hits the same
empty screen live, just with a Skip button they have to find on their own
rather than a driver that gets stuck.

Two separable things here, in case only one is actually wrong:
1. **Possibly a genuine content gap:** 4 boss relics for a 4-Titan ladder
   only works out if relics are meant to be taken roughly once every two
   Titans in 2-player co-op (or if hunters are expected to Skip often) —
   worth checking whether that's the intended cadence, or whether the pool
   should be sized for 2 relics/Titan (8) or refilled/scaled by player
   count.
2. **Definitely a bug regardless of (1):** the prompt text
   (`reward_header_text()`, `location_3d.gd`) doesn't handle the
   zero-choices case at all — it always says "Tap a %s to select" once
   nothing is picked yet, even when there is nothing to tap. At minimum
   this should say something like "Nothing left to take — Skip to
   continue" when `reward.choices` is empty, the same way the campfire's
   "Sharpen — nothing left to sharpen" button already tells the player
   *why* an option isn't there instead of just failing silently.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3dwon beast=cinder_jackal size=1280x720

Prints `RUN ended in phase 5` (`Run.Phase.REWARD`, not WON — the driver gave
up after 400 stuck iterations) and the saved frame is the 3rd Titan's
"Titan felled! (3/4)" reward screen: no cards in the row, "Tap a relic to
select" showing, "Lock In Reward" greyed out. Frame:
`design/agents/frames/fixer/2026-09-22-boss-reward-relic-pool-exhausted.png`.

The underlying math (not tied to the screenshot tool): `Run._begin_reward()`
(run.gd:1167), `Content.boss_relic_pool()` (content.gd:137, 4 ids),
`pick_reward()`'s cross-hunter strike (run.gd:989-997).

## Done when

Your call on (1) — whether the pool/cadence should change, or 2-per-Titan
co-op depletion is fine as is. Either way, (2): the reward screen never
again tells a player to tap something that isn't there.

## Nick's answer

<!-- Type below this line. Anything, one word is fine. Then run
     toolsoard_push.cmd. Leave the frontmatter alone. -->
Do not worry about relics at this time. 


## Result

**Item (2) is fixed, item (1) is still yours.** #86 duty 3 this run (`git
log` — the same commit as the duty-3 write-up in `design/BACKLOG.md`) added
a `has_choices` parameter to `reward_header_text()`: with zero choices left,
not picked, no selection, the prompt now reads "Nothing left to take — Skip
to continue" instead of "Tap a relic to select". Three new unit tests in
`run_tests.gd` (one proves the message, one proves "tap" never appears with
an empty row, one proves a locked-in player still sees "locked in" even if
the pool happened to run dry on their own pick) — all three fail on the
pre-fix code (`got "Tap a relic to select"`) and pass on the fix. Rendered
`state=3dreward` with `reward_choices` forced empty both hunters:
`design/agents/frames/fixer/2026-09-23-reward-empty-choices-prompt.png` —
row empty, "Lock In Reward" correctly disabled, prompt now honest, "Skip —
keep the deck lean" visible and unambiguous.

Left open: whether the 4-relic boss pool should be resized or refilled for
2-player co-op (item 1) — that's still a content/balance call, not touched.




