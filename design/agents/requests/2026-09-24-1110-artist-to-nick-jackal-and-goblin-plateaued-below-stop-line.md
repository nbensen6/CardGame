---
tags:
  - request
from: artist
to: nick
status: taken
priority: normal
beast: cinder_jackal
created: 2026-09-24T11:10
taken_by: artist
ask: Leave the jackal and Goblin Engineer at their current, already-good scores, or let me attempt a risky texture-remapping fix on them?
waiting: false
issue: 7
---

# The jackal and the Goblin Engineer have both hit the same wall — need your call

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- Both the Cinder Jackal (the boss) and the Goblin Engineer (one of your two
  hunters) have stopped improving. I checked the jackal's score three times
  and the goblin's twice, and it came back exactly the same every time — our
  own rule for this says that means "stop trying the same thing and ask,"
  not "try a fourth time."
- **My recommendation: leave both as they are.** Neither looks bad — the
  shape, proportions and colours are already good on both (I checked this
  specifically, more than once). What's actually holding the number down is
  a technical limit in how the 3D file itself is built, not anything you'd
  point at on screen and call ugly.
- The one thing that could still move the number is risky: redo how the
  surface texture is wrapped onto the model, from scratch. Both models are
  already rigged, animated, and live in the fight, with paint and outline
  work already done on top — that kind of change could easily break the
  look they already have, and I don't think it's safe to try unsupervised.
- If you'd rather I attempt it anyway, say so and I'll treat it as its own
  careful, separate job with a way to undo it if it goes wrong. Otherwise,
  say "leave them" and I'll move on to other work — nothing about the fight
  is blocked either way.
- (The Frog is fine — it already hit its target and needs nothing here.)

## What

Both assets are Meshy-built rebuilds. Full technical detail is written up
in their own progress notes, but in short: they're built at a much higher
level of surface detail than this project's budget for their size (the
jackal especially — over four times the intended amount), and cutting that
down without hurting the look has been tried three different ways across
both models and none of them worked. The one thing that would actually fix
it — starting the texture wrapping over from scratch — has never been
attempted, on purpose, because it's the kind of change that's easy to get
wrong on a model that's already finished and shipped.

## How to see it

`design/progress/cinder_jackal_ai.md` and `design/progress/goblin_mech_ai.md`
each now open with a "VERDICT: REBUILD" section explaining this in full,
including exactly what was tried and ruled out. `JACKAL-BAR.md`'s creature
and hunter-fidelity lines point at the same two files.

## Done when

You've told me which way to go — leave them where they are, or greenlight
the risky redo as its own dedicated pass.

## Nick's answer

## Result

## Nick's answer — 2026-09-24 11:47 EDT

**Yes — take the texture remap. On the jackal, the Goblin Engineer AND the
Frog.** All three, not just the two you asked about.

- Risky is fine. A plateau you can see is worse than an attempt that fails.
- Keep the current models so a bad result can be rolled back in one commit,
  and show me before/after at real fight size, not in the scoring camera.
- If one of the three comes out worse, say so and revert that one — a partial
  win is a win, do not force all three to land together.

