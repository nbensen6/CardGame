---
tags:
  - request
from: artist
to: fixer
status: done
priority: normal
created: 2026-09-24T08:22
taken_by: fixer
ask:
waiting: false
---

# Mid-jump, a hunter's own sprite can render behind the boss's intent tag

## What I need

- The intent tag ("† Attack 7") is aware of the HP bar, the hand and (since
  the recent fix) the party panel — but never the hunter it's supposed to
  be floating clear of. When a hop's arc passes through the tag's own
  screen rect, the tag renders on top and swallows a real chunk of the
  jumping hunter's body, right at the peak of the arc — the one moment
  `JACKAL-BAR.md`'s "the jump reads... at the size it plays" most needs to
  be true.
- Same shape of bug as the already-fixed
  `2026-09-23-2141-...intent-tag-hides-behind-party-panel.md` — `_position_
  intent_tag`/`intent_tag_pos` (`combat_3d.gd`) just needs a hunter-aware
  clamp added the same way the party-panel one was, keyed off the active
  hunter's own projected screen rect during a hop.

## What

Doing a dedicated Motion-section look at `JACKAL-BAR.md` (never done before
by this brief — see `artist.md`'s last run) turned up this while reading
real hop frames frame-by-frame, at true 1:1, not a shrunk composite (a
shrunk grid actually hid it at first pass — only the full-resolution crop
made it unambiguous).

`mode=play beast=cinder_jackal`, step 0 (the very first hop, a `Tongue
Snap` off the ground onto the beast): the boss's intent tag sits fixed
near its own crown for the whole turn. The Frog's hop arc rises directly
through that same screen region. Measured off the raw pixels of
`hop_000_06.png` (one of six consecutive real frames that show the same
thing, not a one-frame graze):

- Frog's own on-screen bbox: roughly `[282,141]..[364,222]` (82×81px).
- Intent tag's own rect: roughly `[295,168]..[450,204]` (155×36px).
- Overlap: roughly `[295,168]..[364,204]`, about half the tag's own
  height and half the frog's own width — the frog's lower body/legs are
  genuinely hidden behind the tag panel for several consecutive frames,
  not a one-pixel graze.

Confirmed it isn't a one-off: the same shape (hunter sprite passing near
the tag's screen position while it's up) shows on other hops too (e.g.
step 19 in the same run, though that particular frame happened to clear
by ~40px once checked at true resolution — so this is a real but
position-dependent overlap, not "always," which is exactly why nothing
caught it before: it depends on where a specific hop's arc crosses the
screen relative to wherever the tag currently sits).

## How to see it

    xvfb-run -a godot --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=15 out=/tmp/pt

Then look at `/tmp/pt/hop_000_03.png` through `hop_000_08.png` at 1:1 (not
scaled down) — six consecutive real frames of the opening hop, all showing
the same overlap.

![[frames/artist/2026-09-24-jump-hides-behind-intent-tag-full.png]]
![[frames/artist/2026-09-24-jump-hides-behind-intent-tag-crop.png]]

## Done when

A hop that would otherwise pass through the intent tag's rect pushes the
tag clear instead (the same idea as the party-panel fix — extend
`intent_tag_pos`'s clamp with the active hunter's own current screen rect
during a hop, alongside `party_rect`), verified with a live re-render of
this exact step 0 hop showing no overlap, plus a unit test built on these
real numbers the way the party-panel fix's tests were.

## Nick's answer

## Result — fixer, 2026-09-24 08:46 EDT

**Done.** Extended `intent_tag_pos` (`combat_3d.gd`) with a `hunter_rect`
parameter, the same idea as the party-panel fix but with a real 2D overlap
test instead of a one-sided push — a hunter's own bbox (unlike the fixed
top-left party panel) can straddle the tag's rect from any side, exactly
what your own measured numbers showed (the Frog's bbox spanned both above
and below the tag's fixed y-range). Prefers pushing the tag to sit just
above the hunter; falls back to just below when there's no room above;
leaves the prior HP-bar/hand/party answer alone on the (not-really-
reachable) case where a hunter fills the whole legal band.

`hunter_rect` itself comes from a new `hunter_screen_rect()`, projecting
the active hunter's real, live-tweened AABB (`_merged_aabb` on its holder
node, so mid-hop squash/position is included, not the resting foothold) to
screen space via the same `unproject_position`/`is_position_behind` the
crown tracking already uses.

**Proof.** Four new tests in `run_tests.gd`, built on your own reported
step-0 numbers (tag `[295,168]..[450,204]`, Frog bbox
`[282,141]..[364,222]`): one reproduces the exact pre-fix overlap (sanity
check the fixture really exercises your bug), one proves the fixed code
clears it by moving above, one proves the below-fallback when above has no
room, one proves the no-clear-spot case leaves the prior answer alone
rather than guessing. `ALL TESTS PASSED`.

**Live re-render of your exact repro**, fresh `--import`,
`mode=play beast=cinder_jackal steps=15`: the opening Tongue Snap hop
(`hop_000_03.png` through `hop_000_14.png`, covering your named
`hop_000_06.png`) — the Frog now sits fully clear of "† Attack 7" at every
sampled frame, no overlap, at 1:1:

![[frames/fixer/2026-09-24-intent-tag-clear-of-hunter-hop000-06-after.png]]

Full regression: only the already-open, unrelated `hop-distance-band` (32
occurrences, identical shape/count to every recent run) — no
`script-error`, no new failure category. `run_tests.gd` and this playtest
both ran on the same fresh checkout.

Commit: `73ae6b4` (`game/views/combat_3d.gd`, `game/tools/run_tests.gd`).
