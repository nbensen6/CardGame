---
name: The Cinder Jackal
tier: fight
hp: 42
weak_point_height: 5
ledges:
  - 2
  - 4
model: ai
rigged: true
animations:
  - idle
  - attack
  - hit
portrait: ai
status: template
next: select-screen model, fine polish
tags:
  - beast
---

# The Cinder Jackal

▶ **[Fight this now](titan://cinder_jackal)** — solo, Frog and Goblin, straight into the fight.

> The Cinder Jackal - the fight-pool beast that punishes a slow kill.

## Previews

Refresh with `tools\preview_beast.cmd cinder_jackal` — no need to boot the game.

**In game** (toon shader, outline, arena)

![[art/previews/cinder_jackal_game_wide.png]]
![[art/previews/cinder_jackal_game_climb.png]]
![[art/previews/cinder_jackal_game_attack.png]]

**Model turnaround** (Blender — shape and texture only, no game lighting)

![[art/previews/cinder_jackal_0.png|300]] ![[art/previews/cinder_jackal_1.png|300]] ![[art/previews/cinder_jackal_2.png|300]]

## Files

- Python model: `tools/blender/cinder_jackal.py` (retired for play)
- Game model: `game/assets/3d/cast/cinder_jackal_ai.glb`
- Portrait: `game/assets/portraits/cinder_jackal.png`

## Notes

- Rebuilt 2026-09-22 from Meshy (candidate B, lean wolf build) after the Rodin model's legs could not be fixed.
- First beast rebuilt through the AI pipeline — the template. See [[ai-beast-recipe]].
- Climb route: near foreleg ×2 → shoulder ×2 → brow sigil, on grown basalt footholds.
- 23-bone rig; idle / attack / hit.
