---
tags:
  - request
from: artist
to: nick
status: done
priority: normal
created: 2026-09-23
taken_by: nick
---

# Pick a direction for the rest of the Goblin/Frog card art before it scales

## What

Item 4 of the artist brief (`design/art/card-face-vs-sts.md` §2.5) has been
untouched all thread: only 4 of the Frog's 41 pool cards are painted, and the
Goblin Engineer — this fight's other hunter — has **zero**. Painted art needs
Canva work from you (`tools/artprep.py`'s `--card` flow), which is the actual
blocker (`design/plan/BACKLOG.md` #82: "the blocker is now ART, not code").

I tried a different source for it instead of asking you to paint 33 more
cards: **render the card's art from the hunter's own 3D model**, the same
move `tools/blender/portraits.py` already made for the party-panel
portraits ("rendered from the models rather than borrowed... a portrait can
just BE the character"). Built it for one card — `Piston Punch`, the Goblin
Engineer's signature attack — end to end:

- `tools/blender/cardart.py` — loads `goblin_mech.glb`, frames it full-body
  (not the portrait's head-and-shoulders crop) at the card's real 620×870
  aspect, renders on transparency.
- `tools/cardbg.py` — composites a backdrop sampled from this fight's own
  palette (CHARCOAL/RUST, the same swatches the arena pass used), a
  contained ember glow rather than a flat fill.
- Wrote the result to `game/assets/cardart/piston_punch.png` — `CardView`
  picks it up automatically, no code change (same `art_path` convention as
  every painted card).

## How to see it

    xvfb-run -a /tmp/Godot_v4.7.1-stable_linux.x86_64 --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/hand.png state=3d beast=cinder_jackal hand=piston_punch,slash,brace

Or just look at the frame already committed:
`design/agents/frames/artist/2026-09-23-piston-punch-before-after.png` —
Piston Punch next to Satchel Charge (same slot, still a bare icon).

## The actual ask

This is real art, made a genuinely different way from every other card in
the game, and whether that's the right look for 30+ more cards is a taste
call, not a code one. Three things I'd want your read on before I run this
across the rest of the Frog/Goblin decks:

1. **Does a "hero shot" of the hunter's own model, lit with the fight's own
   palette, feel right as card art** — or does it read as "portrait,
   stretched," next to the four Canva paintings the Frog already has (which
   are illustrated scenes, not character renders)?
2. **Mixing the two styles in one deck** — the Frog would end up with 4
   painted cards and ~35 rendered ones. Worth it, or should rendered art
   replace the 4 paintings too for consistency?
3. If this is a yes: every Goblin/Frog card needs its own framing entry in
   `cardart.py`'s `CARDS` table (pose is whatever the model's resting stance
   already is — there's no rig to re-pose off, so an attack card and a skill
   card from the same hunter will look similar unless the camera angle or
   crop does the differentiating work. Worth flagging now rather than
   after 30 of them are built the same way).

Not blocking on this — it's one card, proven and pushed. Just don't want to
burn the Meshy-free, code-free part of the cards item on a direction you'd
rather I not scale.

## Done when

Nick says "yes, keep going" (with any adjustment to style/framing), "no,
paintings only," or "mix them, here's how to decide which cards get which."

## Result

(filled in by nick)

## Nick's answer (2026-09-23) — NO, and card art is parked

Rolled back: `game/assets/cardart/piston_punch.png` is removed and Piston
Punch shows its icon again. `tools/blender/cardart.py` and `tools/cardbg.py`
stay in the tree, unused.

The card art will be HIS: he paints a card in Canva, and the artist recreates
that style across the deck. `game/assets/cardart/leap.png` is the reference
he has already made. One proof-of-workflow run on Leap is requested
separately; after that, no card art until he says go.

The artist's next runs are **characters and environment**, made clean, with
inspiration taken from fully developed and AAA games. Restyling the existing
hunters is allowed.
