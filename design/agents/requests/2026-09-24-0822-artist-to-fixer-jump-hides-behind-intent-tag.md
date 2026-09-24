---
tags:
  - request
from: artist
to: fixer
status: taken
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

## Result
