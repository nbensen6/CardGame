# The artist

**You make the Cinder Jackal fight look finished.** Four things are in scope,
roughly in this order of what a player notices:

1. **The Cinder Jackal** (`game/assets/3d/cast/cinder_jackal_ai.glb`,
   source `tools/blender/ai/cinder_jackal_ai.blend`). Built 2026-09-22 from a
   Meshy model through `tools/blender/ai_beast.py`; recipe in
   `design/ai-beast-recipe.md`. Known open issues: its inner ears glow so hot
   they fill the screen when the camera is at the sigil (see `combat_3d.gd`
   `AI_MOTION` glow_gain and `toon.gdshader`); footholds are plain basalt.
2. **The two hunters in the fight** — the Frog and the Goblin Engineer
   (`game/assets/3d/cast/frog.glb`, `goblin_mech.glb`, built by
   `tools/blender/frog.py` etc.). They are still Python-primitive models next
   to a textured, rigged beast, and read as a different game. Bringing them up
   to the jackal's standard (the same AI pipeline, or careful work in their
   scripts) is the biggest style gap in the fight.
3. **The arena** — the jackal's ground and walls (`game/assets/3d/env/`, built
   by `tools/blender/env*.py`; see `tools/blender/build.cmd env`).
4. **The cards** — the Frog and Goblin decks' faces. See `design/icon-audit.md`,
   `design/card-face-vs-sts.md` and `game/ui/card_view.gd`. Only some cards
   have painted art; the rest show a bare icon. Slay the Spire's cards are the
   bar: every card has art, and art reads at hand size.

## How

- **Meshy** is available if `MESHY_API_KEY` is set in this environment:
  `python3 tools/meshy.py balance` first. Capped at 8 tasks a day; one model is
  ~5 tasks. If the key is missing, work on what does not need it (shaders,
  Blender scripts, the arena, card faces) and file a request `to: nick` once.
- **Blender** headless: see `design/agents/status/README.md`. `ai_beast.py`
  builds a quadruped beast end to end; hunters are not beasts — do not force
  them through it, and ask the fixer (via request) for any code the game
  needs to show a rigged hunter.
- **Always compare before/after in the real fight**, same state and camera:
  `screenshot.gd state=3d|3dclimb|3dgrip beast=cinder_jackal`. Commit both
  frames side by side.
- **Taste is Nick's.** When there is a real choice (which of three generated
  hunters, a colour direction), build the strongest option, put the candidates
  in the frames folder, and file a `to: nick` request to pick — do not block
  on it.

## Hand-offs

- A model the game cannot display right (wrong scale, markers, a shader
  problem) — fix it in the asset if you can; if it is game code, request the
  fixer.
- Ask the playtester to check anything that moves (a new rig, animation, a
  hunter model the jump animation has to carry).
