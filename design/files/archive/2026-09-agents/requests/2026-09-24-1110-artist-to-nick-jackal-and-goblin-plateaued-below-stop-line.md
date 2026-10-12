---
tags:
  - request
from: artist
to: nick
status: done
priority: normal
beast: cinder_jackal
created: 2026-09-24T11:10
taken_by: artist
ask: Leave the jackal and Goblin Engineer at their current, already-good scores, or let me attempt a risky texture-remapping fix on them?
waiting: false
issue: 7
---

# The jackal and the Goblin Engineer have both hit the same wall — need your call

**#7**

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

## Nick's answer — 2026-09-24 11:47 EDT

**Yes — take the texture remap. On the jackal, the Goblin Engineer AND the
Frog.** All three, not just the two you asked about.

- Risky is fine. A plateau you can see is worse than an attempt that fails.
- Keep the current models so a bad result can be rolled back in one commit,
  and show me before/after at real fight size, not in the scoring camera.
- If one of the three comes out worse, say so and revert that one — a partial
  win is a win, do not force all three to land together.

## Result — 2026-09-24 12:23 EDT, artist

**Tried it for real on the Goblin Engineer (lowest risk of the three — no
rig, no animation), and it does not do what we both thought it would.**

I built the actual re-unwrap and re-baked texture rather than reasoning
about it further, and it uncovered something that changes the whole plan:
the thing making these three models' file-hygiene score lag isn't a bad
texture wrap at all. It's small separate pieces — bolts, spikes, fur clumps
— left over from how the 3D model was generated, that were never joined to
the body. **Rewrapping the texture cannot fix that, because the current
texture wrap already isn't causing any of the problem** — I checked, and
it's identical whether or not I touch it. I tried five different ways of
redoing the wrap and every one of them made the file's own fragmentation
worse, not better — one made it three times worse.

- **What I did:** rebuilt the Goblin Engineer's UV wrap from scratch (a real
  attempt, not a mockup), baked the existing paint job onto it, and rendered
  it side by side with what's live now — same camera, same fight, same
  distance.
- **What it looked like:** basically identical at the size you'd ever see it
  in the fight. A very slight softening on close inspection in a bright
  studio shot (the tank's shine, the goggle rim), invisible once it's back
  at real fight size.
- **Did I ship it?** No. No visible win, and a real cost (the file itself
  gets messier, not cleaner) — shipping that trade isn't worth it.
- **What about the jackal and the Frog?** I checked the same underlying
  numbers on both without needing to risk either one (the jackal is rigged
  and animated — a much bigger risk to test blind): same story on both,
  confirmed mathematically, not guessed. Left both untouched.
- **Where that leaves the three of them:** exactly where they already were —
  Frog 42/50 (at target), Goblin Engineer 41/50, jackal 40/50 (both one
  point under). Nothing shipped, nothing to roll back.
- **What I'd need to actually move that last point or four:** not a texture
  fix — the small loose parts would need to be individually rebuilt into the
  body, one at a time, by hand. That's a full remodel of each affected spot,
  a much bigger and slower job than what you greenlit here, and I haven't
  started it. Your call whether that's worth the time; my read is these three
  already look good and this is chasing a number more than a real defect.

Before/after, real fight size:

![[frames/artist/2026-09-24-goblin-reunwrap-infight-before-after.png]]
![[frames/artist/2026-09-24-goblin-reunwrap-studio-before-after.png]]

Full technical trail: `design/progress/goblin_mech_ai.md` ("Pass 9"),
correction notes in `cinder_jackal_ai.md` and `frog_ai.md`.

