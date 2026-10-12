---
tags:
  - request
from: nick
to: nick
status: done
priority: high
created: 2026-09-23T14:34
taken_by: playtester
ask: Do you want the one-directional-route rule (re-place the sigil hold so the sweep never reverses), the arc-system spacing band, and the always-visible-next-ring rule the playtester proposed below — yes, no, or try something else?
waiting: false
---

# How should the floating stones line up in front of a beast, and what makes climbing them feel good?

## What I want

Work out **how the stones should be arranged** in front of a beast, and **what
would make climbing them a smooth experience**. This is a design question, not
a bug — I want your judgement, with reasons, not a patch.

Two halves:

1. **The arrangement.** Where do the stones go, how many, how far apart, at
   what heights, in what shape, so that a player looks at the fight and
   immediately understands "I go up THERE to reach the sigil". Today they are
   placed off the climb points and it reads as scattered rocks rather than a
   route.
2. **The feel of climbing them.** What has to be true of a hop for the whole
   climb to feel continuous rather than a series of disconnected jumps —
   spacing, rhythm, what the camera does, what tells you where you can go next,
   what tells you you have arrived.

**Reference other games whose whole point is climbing**, and say what you took
from each. Shadow of the Colossus is the obvious one — it is the fight we are
making — but look wider: how Breath of the Wild reads a climbable surface at a
glance, how Jusant and Only Up handle a route made of discrete holds, how
Celeste telegraphs the next place your feet land, how Sekiro's grapple points
advertise themselves before you need them. **Describe them in words. Do not
put screenshots of other games in this repo.**

Then say what OUR route should be, concretely enough for the fixer and the
artist to build it.

## The fixer is sending you its view — use it

Nick, 2026-09-23 14:40 EDT. The fixer has the matching request
(`2026-09-23-1423-nick-to-fixer-stones-camera-and-hunter-spacing.md`) and has
been told to write down what IT thinks the placement should come out as and
send it to you, in numbers.

Take that seriously rather than designing around it: it can tell you where a
stone can actually go, what the jump arc reaches, and what the placement code
cannot currently express — the constraints your proposal has to live inside.
Your half is whether the result reads as a route. Converge on one rule, and if
you cannot agree, say so and file `to: nick` rather than each shipping half of
it.

## How to see it

Click **Fight this now** on the Cinder Jackal and try to climb to the sigil.

## Done when

- A written proposal I can read and say yes or no to: the arrangement (with
  numbers — how many stones, spacing, heights) and the rules for what makes a
  climb feel continuous.
- Frames showing the problem today, and — if you can fake it in the harness —
  what the proposal would look like.
- Each named reference has one line saying what we are taking from it, and why
  it applies to a hunter climbing a beast rather than a wall.
- Filed on from here: whatever the proposal needs built goes to the fixer
  (placement, camera, jump rules) and the artist (how a stone should look and
  read) as its own request, once I have said yes.

## Result — playtester, 2026-09-23 14:50 EDT

**The fixer hasn't sent its numbers yet** (checked `requests/` — its matching
note is still open, untaken, no reply to me). Rather than wait on it, I read
the placement code myself (`stone_point`, `foothold_anchor`, `stand_offset_x`
in the 3D view, plus how a beast's climb points are authored in Blender) and
played the fight, so this proposal has real numbers in it and the fixer has
something concrete to react to instead of a blank page. If its numbers say a
stone can't physically go where I ask, that's the convergence step — not a
disagreement to hide.

### Why it reads as scattered today

Today's frame, right at the start of the fight:

![[frames/playtester/2026-09-23-stones-route-wide-before.png]]

Four little pebbles hover in a loose vertical smear right in front of the
jackal's face. There's no sense of "a path up the body" — they could be
floating there for any reason. Mid-climb it's the same story, just moved up:

![[frames/playtester/2026-09-23-stones-route-midclimb-before.png]]

I found the actual cause in the beast's own build script, not just the
placement code. Each hold on the Cinder Jackal is hand-placed at a spot on
its body, and walking those spots in order: the paw, up onto the shoulder,
back onto the haunch — that part is one smooth sweep backward along the
spine, which is actually fine. Then the LAST hold, the sigil, is placed back
up near the face — the climb reverses hard and jumps back past where it
started. That one reversal is doing most of the damage: four holds build a
route, and the fifth breaks it. It's a per-beast authoring mistake, not
something the game engine gets wrong on its own — which is good news, it
means the fix is "place the last hold better," not "rebuild the system."

### 1. The arrangement — the rule I'd set

**A route only ever goes one way.** From the ground to the sigil, each hold
should be further along the climb than the last in the same rotational
sense — think of it as one **continuous sweep up and around the body**,
never a hold that requires looking back past a hold you already used. Right
now the Cinder Jackal's climb almost does this (paw → shoulder → haunch is
one smooth backward sweep) and then throws it away on the last hop. Fixing
just that one hold's placement — keep it moving in the same direction the
rest of the climb was already going, instead of snapping back to the front —
would go a long way on its own, with no new system needed.

**Spacing.** The game already has a formula for how tall a jump's arc gets
based on how far it travels, and it's tuned around a "sweet spot" distance —
below it, every short hop gets the same minimum pop no matter how close the
two stones are (which is what makes tightly-packed stones look like bouncing
in place instead of traveling); above it, the arc gets capped so a long haul
doesn't rocket absurdly high. I'd keep ordinary, one-rung-to-the-next hops
comfortably inside that sweet-spot band rather than bunched at the bottom of
it — enough distance that the jump clearly reads as "going somewhere," not so
much that it looks like a leap of faith. The fixer knows the exact in-game
units (it owns the beast's scale factor); the rule to hand it is: **every
ordinary hold-to-hold distance should sit inside the arc system's own
proportional range, not down at its floor.**

**Height and count.** Five or six rungs (what the Cinder Jackal already has)
is the right number — enough to feel like a climb, not so many it's a
slog. Keep the vertical spacing between rungs even, which the model already
does. Where I'd change things: every rung, including the very top one,
should sit visibly further "into" the route than the last when you look at
the beast from the fight's own camera — not just technically higher.

### 2. What makes the climbing itself feel continuous

- **You can always see where you're going before you commit.** The game
  already draws a ring on a landing spot once it's a valid target — that
  should always be the very NEXT hold, visible before you play the card that
  sends you there, not just after.
- **The wide establishing shot has to sell the whole route**, not just the
  beast. Right now the wide shot is where the "four scattered pebbles" problem
  is most visible — that's the shot a player sees first, and first
  impressions of "is this climbable and does it make sense" get set right
  there, before a single card is played.
- **Landings need weight, launches need anticipation** — the game already
  does this (a crouch before takeoff, a lean into the arc, a squash on
  landing) and it reads well in the frames I've checked. That part doesn't
  need touching.
- **The camera should hold the whole jump in frame**, start to landing — also
  already true in the code I read. Good, leave it.
- **Arrival should feel different from mid-air.** The game already
  distinguishes a real ledge (a place with footing) from a point on the skin
  a hunter passes through mid-fall — keep that distinction, and make sure a
  ledge always LOOKS like a shelf, not just a marker floating at the right
  height.

### References — one line each

- **Shadow of the Colossus.** Every hold on a colossus lies along one
  continuous path around its silhouette — you're never sent back past a hold
  you already used to reach the next one. That's the core rule above:
  monotonic, one-directional routes, taken directly from the game whose
  climb we're building.
- **Breath of the Wild.** A climbable surface reads as climbable from far
  away, by its material and lighting, before you're anywhere near it. We
  take: the stones need to read as "the path" in the wide establishing shot,
  not just up close — today they don't.
- **Jusant.** Holds are sparse but every one sits at a confident, consistent
  reach from the last, and the camera stays wide enough to preview a couple
  of holds ahead. We take: cap the hold-to-hold distance to a comfortable,
  consistent range (see the arc-system band above) instead of letting
  per-beast authoring drift wide or narrow by accident.
- **Only Up!** — the cautionary example, not one to copy. Platforms with
  inconsistent spacing, size and direction read exactly as "random junk you
  happen to be able to stand on," which is the exact complaint here. We take:
  this is the failure mode to steer away from, and it's useful as a name for
  what "scattered" means.
- **Celeste.** The very next foothold is always unambiguous before you commit
  to reaching it, and the jump arc is tuned so your eye predicts the landing
  before the animation finishes. We take: always show the ring on the NEXT
  hold, not just the one you're standing on.
- **Sekiro.** Grapple points advertise themselves with a readable icon well
  before you're in range, from a wide shot. We take: the ledge marker has to
  read from the wide establishing shot, the same shot that currently shows
  the scattered-stones problem — if the marker only reads up close, the wide
  shot still looks like loose rocks.

### What I need

- **Say yes or no** to the rule above (one-directional route; ordinary hops
  kept inside the arc system's proportional distance band; next-hold always
  telegraphed; wide shot has to sell the route). If yes, I'll file the build
  requests to the fixer (re-author the Cinder Jackal's last hold so the sweep
  keeps going the same direction, plus the spacing rule for future beasts)
  and the artist (make the stone material read as "the path" from the wide
  shot, not just up close) once you've said so.
- If the fixer's own numbers land before you answer, I'll fold them in rather
  than ship two disagreeing halves.

## Nick's answer

<!-- Type below this line. Anything, one word is fine. Then run
     tools\board_push.cmd. Leave the frontmatter alone. -->

## Nick's answer — 2026-09-23 18:00 EDT

**Approved, as written.** Build it.

- The one-directional route rule: yes.
- Ordinary hops inside the arc system's proportional band, not at its floor: yes.
- The ring on the NEXT hold before the card is played: yes.
- The wide establishing shot has to sell the route: yes.
- A ledge looks like a shelf, not a floating marker: yes — artist's, file it.

Fix the CAUSE, not just the Cinder Jackal's sigil: `ai_beast.py`'s raycast
picks any upward-facing surface near the head with no idea where the route was
heading, and `beast.py`'s `mark()` has the same gap. A per-beast patch that
leaves the next beast broken is not done.

Leave alone what the playtester says already works: anticipation, landing
squash, the camera holding the whole jump.

Split the build from here — placement, jump rules and the next-hold ring to the
fixer; how a ledge reads to the artist. Come back to me only if the two of you
disagree.

## Filed on — playtester, 2026-09-23 18:46 EDT

No disagreement with the fixer's technical numbers (`2026-09-23-1736-...`) —
they confirm the proposal is buildable and give exact code locations. Filed
both build requests per "Done when":

- `2026-09-23-1846-playtester-to-fixer-build-the-one-directional-stone-route.md`
  — the raycast/mark() root-cause fix, the 2.4-9.2 unit spacing band, the
  next-hold ring.
- `2026-09-23-1846-playtester-to-artist-make-ledges-read-as-shelves.md` —
  the shelf-vs-floating-marker material pass.

Marking this `status: done`: the design question is answered and the build
work is now tracked in those two notes.
