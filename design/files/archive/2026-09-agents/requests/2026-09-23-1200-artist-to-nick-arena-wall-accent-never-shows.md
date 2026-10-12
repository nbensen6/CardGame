---
tags:
  - request
from: artist
to: nick
status: done
priority: normal
created: 2026-09-23
taken_by: artist
ask: The arena walls have a glowing band you never see. Leave it, move it lower, or fix the whole wall system?
waiting: false
---

# The Cinder Jackal arena's RUST wall accent scores well but a player never sees it

## What I need

- The arena walls have a glowing rust-coloured band near the top, meant to echo
  the jackal's own heat. **You never see it** — it sits above the top of the
  frame in every camera the fight actually uses.
- Which one:
  - **Leave it.** Recommended for now — it costs nothing, and the camera is
    still moving around. Revisit once the shot settles.
  - **Move the band lower** so it lands in frame. Changes every cliff-walled
    arena in the game, not just this one.
  - **Bundle it** with the older "the wall eats the frame" finding and fix the
    whole wall system once.
- The frame below shows it side by side: obvious in the artist's own render,
  absent in all five in-game cameras.

## What

`tools/blender/env/cinder_jackal.py`'s wall recolour (`e.enclose("cliff",
uv=CHARCOAL, accent=RUST)`, landed 2026-09-22) put a RUST "smouldering lip"
band near the top of each wall piece, matching the jackal's own hot
palette. It reads clearly in the loop's own scoring camera
(`design/renders/cinder_jackal_env_pass3_34.png`) and was credited toward
this ground's Colour/Style score (3→6).

Checked today across every 3D camera state the fight actually uses — `3d`,
`3dclimb` (sigil close-up), `3dgrip`, `3dstrike`, and a pulled-back `wide`
framing — and the accent **never appears in any of them**. The wall's own
visible top edge runs off the top of the frame before reaching the band's
placement height (`env.py`'s `_wall_cliff`: `tall * uniform(0.75, 0.95)`).
Side-by-side, scoring camera vs. all five in-game framings, in the frame
below.

This isn't this ground's own script's problem to fix: the accent's
placement fraction and the wall's overall height (`ENCLOSE_HIGH`) both live
in the shared `env.py` `enclose()`/`_wall_cliff`, used by every
"cliff"-style ground in the game (`crag_pup_ground.md` and
`stone_warden_ground.md` already flagged the same wall system for a
related but distinct reason — the wall filling the whole frame and hiding
the floor). Changing either would affect every other "cliff" ground, not
just this one, which is why nothing was touched.

## How to see it

    export GODOT=/tmp/Godot_v4.7.1-stable_linux.x86_64
    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game \
      --script res://tools/screenshot.gd -- out=/tmp/s.png state=3dclimb beast=cinder_jackal size=1280x720

Compare against `design/renders/cinder_jackal_env_pass3_34.png` (the
isolated scoring render, where the RUST caps are obvious).

## Done when

Nick picks one:

1. **Leave it.** The accent is real, cheap, and does no harm — it's just
   not doing the job its own comment claims. Score stays as is; the
   comment in `cinder_jackal.py` gets a one-line correction that it's
   confirmed invisible in play.
2. **Lower the accent's placement fraction** in `env.py`'s `_wall_cliff`
   (currently 0.75–0.95 of each piece's height) so it has a chance of
   landing inside the camera-visible portion of the wall — affects every
   "cliff" ground, so it's a call about the whole shared system, not just
   this fight.
3. **Bundle with the standing wall-height finding** from
   `crag_pup_ground.md`/`stone_warden_ground.md` — if `ENCLOSE_HIGH` or the
   camera framing ever gets revisited for the "wall eats the frame" reason,
   this is the same root cause and worth fixing together.

## Nick's answer

<!-- Type below this line. Anything, one word is fine. Then run
     tools\board_push.cmd. Leave the frontmatter alone. -->

the environment needs a rehaul. use meshy to create an environment to replace the one created in blender. 
## Result

**Done, 2026-09-23 18:25 UTC.** Replaced the enclosing wall with a
Meshy-generated crater rim; the floor (`env.py`'s `ground()`/`apron()`) was
never the flagged problem and stayed as-is. 2 Meshy tasks (1 preview, 1
refine) — well under the 8/day cap. New file
`game/assets/3d/env/cinder_jackal_ai.glb`, picked up over the old
`cinder_jackal.glb` by `ENV_AI_ART := {"cinder_jackal": "_ai"}` in
`combat_3d.gd` (same shape as `AI_ART`/`HUNTER_AI_ART` for the cast — the
old wall stays on disk, one dictionary entry from coming back). Full recipe:
`tools/blender/ai/cinder_jackal_env_ai.py`. Full write-up, scoring and the
before/after renders: `design/progress/cinder_jackal_ground.md` pass 6.

This directly answers the request's own question: the sigil close-up
(`3dclimb`, the exact camera the invisible RUST band was measured against)
now shows real ember cracks in frame, because they are baked into the
wall's own jagged form and texture instead of riding a flat band placed
above where any in-game camera looks.

![[frames/artist/2026-09-23-cinder-jackal-arena-rehaul-3dclimb-before-after.png]]
![[frames/artist/2026-09-23-cinder-jackal-arena-rehaul-wide-before-after.png]]

`ALL TESTS PASSED`. An 80-step playtest was running as this was written;
see the status note's `## Now` for the result.
