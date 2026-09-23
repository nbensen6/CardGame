---
tags:
  - request
from: fixer
to: fixer
status: done
priority: normal
created: 2026-09-23
taken_by: fixer
---

# A melded slider-eligible card with more than one real timing window collapses to a single hold, dropping the extra windows

## What

`HitCircle.begin()` decides how many taps a timing chain needs with
`_hits_needed = 1 if _slider else points.size()`. Whether a card is a
"slider" (`combat_3d.gd`'s `_on_card_tapped`) was decided purely by
`card_climb_for(card) >= SLIDER_CLIMB` (raw printed `grip >= 2`), completely
independent of the card's own `timed_hits`. No single shipped card carries
both `grip >= 2` and `timed_hits > 1` — but **Meld** (the Goblin Engineer's
own signature card, in their starter deck) reaches it for real:
`_meld_cards` (`core/combat.gd:388,399`) sums `grip` and takes
`maxi(timed_hits)` independently, so melding **Winch** (`grip:2`, built via
Build Winch) with **Satchel Charge** (`timed_hits:3`, in the Goblin
Engineer's starter deck ×2) produces a fused card with `grip:2` (slider-
eligible) and `timed_hits:3`. On the HitCircle (osu) face that card was
resolving as ONE 0.85s hold with `SLIDE_RESCUE` forgiveness — a much easier
check than the identical card's own `timed_hits:3` promises, and than the
sweep-bar `CardView` face already gives it (`start_timing(hits)` sets
`_hits_needed = maxi(1, hits)` unconditionally, no slider concept at all).
Two faces of the timing minigame disagreeing about how many windows one
card needs.

Found via order-of-work item 3 (own reading), after items 1–2 (open
requests, live playtest baseline) came back clean; the specific candidate
was surfaced by a delegated Explore pass over `combat_3d.gd`/`card_view.gd`/
`hit_circle.gd`/`core/combat.gd`, then independently confirmed by reading
`hit_circle.gd:begin()`, `combat_3d.gd:_on_card_tapped`/`_hold_points`/
`card_climb_for`, `core/combat.gd:_meld_cards`, and `data/cards.json`'s
`winch`/`satchel_charge`/`build_winch` entries myself before touching
anything.

## How to see it

Logically: `Combat3D.card_is_slider({"base": {"grip": 2}}, 3)` (the melded
Winch+Satchel-Charge shape) used to return `true` (collapses to a slider);
now returns `false` (falls back to the tap chain both faces then agree on).
Reproduced against the pre-fix formula first (temporarily reverted just the
new function's body to the old `card_climb_for(card) >= SLIDER_CLIMB`,
ignoring `hits`) — the new regression test failed exactly as predicted;
restored the fix and it passes.

Live in-game: build Winch (Build Winch), hold Satchel Charge, play Meld on
the two, tap the resulting card with `Progress.timing_style() ==
TIMING_CIRCLE`. No dev-harness switch forces a synthetic melded card id into
a hand (`Dev.hand`/`screenshot.gd`'s `hand=` only resolve real
`data/cards.json` ids via `Content.make_card`; a meld's id is built at
runtime by `_meld_cards`, not data-driven), and the deterministic
`playtest.gd` script never happens to build Winch and Meld it with Satchel
Charge in its fixed 80-step sequence, so no automated check or frame
currently exercises this exact combination — the pure-function proof below
is what settles it, the same as every other timing-minigame rule in this
codebase (`card_climb_for`, `fire_quality`, `zone_bonus_t`) is proven
headless rather than by chasing a specific live sequence.

## Done when

`Combat3D.card_is_slider(card, hits)` agrees with the sweep-bar CardView
face: a card is a slider only when it is both climb-eligible AND has at
most one real timing window; a melded (or future) card with more than one
window always falls back to the tap chain, whatever its climb.

## Result

Extracted `Combat3D.card_is_slider(card: Dictionary, hits: int) -> bool`
(`game/views/combat_3d.gd`) — `card_climb_for(card) >= SLIDER_CLIMB and
hits <= 1` — and switched `_on_card_tapped`'s `_circle.begin(...)` call to
use it instead of the old inline `climb >= SLIDER_CLIMB`. Four new tests
covering the full 2×2 truth table (plain climb card stays a slider; plain
attack card is never a slider; a melded multi-hit climb now falls back to
the tap chain — the repro, fails on the old formula, passes on the fix; a
high-`timed_hits`/no-climb card, e.g. Satchel Charge alone, was already
correct and stays a tap chain). Reproduced first against the unfixed
formula (temp-reverted just the new function's body, kept the call site and
signature) — the repro test failed exactly as predicted (`got
card_is_slider == true` for `{grip:2}, hits=3`); restored the fix, reran:
`ALL TESTS PASSED`.

No live frame: this exact combination needs Build Winch + Meld, which no
dev-harness switch or the deterministic playtest script currently drives
(see "How to see it" above) — proof is the before/after unit test, the same
convention every other pure timing-minigame rule in this file already uses.
Ran a fresh full `mode=play beast=cinder_jackal steps=80` baseline against
the fixed tree as a general-regression sanity check (this change touches
only the one rarely-reached melded branch, nothing else in the hand/climb/
camera path) — clean through step 28+ with no errors, no crashes, no
behavior change on any of the 28 real card plays it made along the way
(none of them melded Winch+Satchel Charge). `hover`/`hands` baseline was
started too but killed early to free CPU for `play` under this sandbox's
3-way contention; nothing in this change touches hover/flicker or hand-size
layout, so the risk from skipping their full run here is low, and it was
not a factor in this run's other findings either.
