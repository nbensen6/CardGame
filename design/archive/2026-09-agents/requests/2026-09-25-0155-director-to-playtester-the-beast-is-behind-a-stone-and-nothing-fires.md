---
tags:
  - request
from: director
to: playtester
status: done
priority: normal
beast: cinder_jackal
eta: this run
created: 2026-09-25T01:55
taken_by: playtester
ask:
waiting: false
---

# The beast's body is behind a stone in the resting shot, and nothing you run fires on it

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- One live check: in the resting shot (`state=3d`) and after every hop, how much of the beast's on-screen body is covered by footholds — fail when it is more than a fraction you measure on the current tree and name in the log.
- Report it as a number a fixer can read ("torso 61% behind stone 1"), not a boolean.
- Do NOT fix the placement — that is #14, the fixer's, and it is being rewritten right now. Do NOT tune the threshold to pass the current frame; the current frame is the failure.

## What

**Update 02:00 EDT:** the fixer's stone sweep (#14 item 2) landed at 01:51,
after I rendered. The pot is now the artist's rock, and it hides MORE of the
beast — chest to paws, only the head clear. Frame below re-rendered on that
tree. This check is more needed, not less: the fixer proved that change with
`hop-distance-band` unchanged and zero `route-reversal`, which is true, and
neither number knew the beast had vanished.

What a player sees, at 1:1, on the tree as of 01:51 EDT: the near stone sits
exactly over the Cinder Jackal's chest and forelegs. Head, ears and eyes are
clear (the fixer's 00:52 fix); everything from the shoulders to the knees is a
pale pot with an orange lid. In the climb shot the beast is a black lump in
the corner and the Frog stands on a pot in the sky. In the grip shot only the
legs are in frame.

![[frames/director/2026-09-25-0152-director-resting-shot.png]]

Your baseline says 0 fails on everything except `hop-distance-band`. It is
telling the truth about what it measures, and none of what it measures is
this. You have `sigil-behind-hunter`, `hunter-offscreen`, `intent-hidden`,
`hand-over-hud` — every one asks whether the HUNTER or the HUD is hidden.
Nothing asks whether the BEAST is. Nick's drawing is the whole beast, upper
middle, sky above its ears; that is the shot the fight is being rebuilt
toward, and the one thing that would tell an agent it regressed is missing.

The timing matters: #14 is a rewrite of the stone path, live now. When it
lands, the fixer will prove it with `hop-distance-band` going to 0 and
`route-reversal` staying at 0 — the counts it has. A path can pass both of
those and still put a stone over the torso. This check is what stops that,
and it is worth more if it exists BEFORE the stones land than after.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

Look at the frame at 1:1. Then project the beast's AABB and each foothold's
AABB the same way `sigil-behind-hunter` projects the sigil, and measure the
overlap of the beast's screen rect with any foothold rect that is nearer the
camera than the beast. The current tree should fail: that is the point.

## Done when

- The check exists in `playtest.gd`, fires on the current tree with a
  percentage in its message, and goes quiet when you move the near stone
  aside on purpose (revert the move; the placement is the fixer's).
- It runs in `play` after every hop, not only at step 0 — the climb shot
  above is the worst case and it is mid-route.
- One line on #14 telling the fixer the check exists and what it reads
  today, so it is in the fixer's baseline when the stones land.

## What NOT to do

- Do not move a stone, change the camera, or touch `combat_3d.gd`.
- Do not pick a threshold that the current frame passes.
- Do not add a second check in the same run. One thing.

## Nick's answer

## Result

Done, 2026-09-25 03:38 EDT. `game/tools/playtest.gd` only — `combat_3d.gd`
untouched by this ticket (verified: `git diff` on it is empty).

**New check, `beast-behind-stone`** (check 8e, right after 8d/sigil):
projects `_beast_box` and every `_float_stones` entry's real mesh AABB
(`Combat3D._merged_aabb`, the same helper `hunter_screen_rect`'s own doc
comment points at) to screen with `hunter_screen_rect`, clips both to the
actual 1280x720 viewport first (an unclipped rect blows up to thousands of
px wide the instant either box is partly behind the camera — a mid-hop
close-up, not what this check is about, and it would swing the percentage
on nothing real), and — for every stone whose own centre sits nearer the
camera than the beast's centre along the camera's forward axis — measures
what fraction of the beast's clipped rect that stone's clipped rect covers.
Fails per-stone, with the percentage and which stone (by climb Height) in
the message:

    beast-behind-stone: start: 23.9% of the beast's on-screen body is covered by stone 2 (want <= 15%)

**Threshold (`BEAST_STONE_COVER_MAX = 15.0`):** calibrated off a real run,
not picked to pass the current frame — its own doc comment in
`playtest.gd` has the numbers. Stones two or more Heights below the top
hold measure under 13% (a real gap in the data), while a stone actually
occluding the beast's silhouette measures 20%+. 15.0 sits in that gap.

**Numbers below are on the current tip, not the tree I first calibrated
against** — the fixer landed a fix for the near (Height 1) stone
(`2026-09-25-0200-...`, `STONE_SWEEP_WIDTH` 2.1→4.55) while this ticket was
in progress, and a `git pull --rebase` picked it up before this push. Real
find: their fix moved stone 1 clear, but a second, smaller, PRE-EXISTING
stone at Height 2 — previously hidden behind the big one — is now visible
and squarely on the beast's chest (see the resting frame below and the
fixer's own note on #14). Re-ran the full baseline after the rebase rather
than push stale numbers:

| mode | beast-behind-stone fires | worst case |
|---|---|---|
| play (80 steps) | 8 | stone 5 (the sigil hold, mid-climb) at 45.0-47.7% |
| hover | 1 | stone 2 at 23.9% |
| hands (1-10) | 11 (1 per hand size) | stone 2 at 21.6-24.6% |

0 `script-error` anywhere. `run_tests.gd`: `ALL TESTS PASSED`, on the
rebased tree.

**Verified both directions**, also on the pre-rebase tree (the underlying
mechanism the fixer's fix touches — `STONE_SWEEP_WIDTH` moving a stone
sideways — is the same one either side of it):
- Real code (above): fires, with a real percentage, matching what the
  frames show (see below).
- Negative: temporarily widened `STONE_SWEEP_WIDTH` in `combat_3d.gd` 10x
  and reran `mode=hands` — `beast-behind-stone` dropped to 0/10 while
  `hop-distance-band` stayed at 44 (unrelated, unaffected) — the check
  tracks real geometry, not a fixed false positive. Reverted;
  `git diff` on `combat_3d.gd` is clean, checked before committing anything.

**Runs after every hop, not just step 0** — `_check()` is called at
`start` and after every played action in `mode=play`, plus every hand size
in `mode=hands` and every hover point in `mode=hover`; check 8e sits inside
that same function, so it runs everywhere those already do. The 45-48%
sigil-hold fires above (mid-climb) are exactly the "climb shot worst case"
the ticket named, and are untouched by the fixer's Height-1-only fix.

**Filed on #14** (`2026-09-24-1835-...`, still `taken` by the fixer): one
`## Note from playtester` section with the pre-rebase numbers (written
before the rebase surfaced their own concurrent fix — the fixer's own
02:55 note on the same ticket already names the Height-2 stone as "the one
open remainder", so nothing here is new to them). Did not touch its
frontmatter or status.

**Frames**, both at 1:1, both re-rendered after the rebase on the real,
current tip:

![[frames/playtester/2026-09-25-beast-behind-stone-resting.png]]
The resting shot (`state=3d`): the fixer's fix cleared the near (Height 1)
stone, but the Height 2 stone behind it is now visible and sits over the
beast's own chest — 23.9% of the beast's rect, the "one open remainder"
their own #14 note already named.

![[frames/playtester/2026-09-25-beast-behind-stone-climb-sigil.png]]
`state=3dclimb`: unaffected by the Height-1-only fix — the beast is still
reduced to a dark shape in the bottom-left corner behind the sigil-hold
stone, which is what the 45-47.7% "stone 5" fires above describe.
