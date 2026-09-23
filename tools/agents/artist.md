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
4. **The cards — PARKED (Nick, 2026-09-23).** Do not spend runs on card art.
   When it restarts, the flow is NICK'S: he paints a card in Canva and you
   RECREATE that style for the rest. `game/assets/cardart/leap.png` (the
   Frog's Leap — a flat painted forest, layered depth, soft palette, the
   subject tiny in a big scene) is the reference. The model-rendered route
   was tried and rolled back; `tools/blender/cardart.py` and `tools/cardbg.py`
   stay in the tree, unused, for whenever he says go.
   (Original scope, for when it returns:) — the Frog and Goblin decks' faces. See `design/icon-audit.md`,
   `design/card-face-vs-sts.md` and `game/ui/card_view.gd`. Only some cards
   have painted art; the rest show a bare icon. Slay the Spire's cards are the
   bar: every card has art, and art reads at hand size.

## What Nick wants now (2026-09-23)

**Make the characters and the environment look CLEAN.** Those two, until he
says otherwise. You may **change the style of the existing characters** —
this is not a polish-what-is-there brief; if the Frog and the Goblin read
better rebuilt in a different style, rebuild them.

**Pull from fully developed games, including AAA.** Name the reference in
your write-up and say what you took: silhouette, palette discipline, how
they light a character, how they keep a small character readable at
distance, how their environments frame the fight rather than compete with
it. Describe the reference in words — never put screenshots of other games
in this repo.

**No bought asset packs.** Everything generated (Meshy) or built here.

## How

- **Meshy**: the key is an API credential on the cloud environment — the proxy
  adds it to requests for api.meshy.ai; you will never see it and need not.
  Run `python3 tools/meshy.py balance` first; a 401 means the credential is
  not set up. **Downloads work now** — `assets.meshy.ai` was allowed on
  2026-09-23 and a cloud probe fetched a real 754KB `glTF`
  (`MESHY_FETCH_OK 754932`); the old proxy-403 wall is gone. The 3 previews
  generated 2026-09-23 are still fetchable by their ledger ids — fetch those
  before spending new tasks. Capped at 8 tasks a day; one model is
  ~5 tasks. If `balance` fails, work on what does not need it (shaders,
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

## The bar

`design/agents/JACKAL-BAR.md` is the definition of done for this fight and
your queue when no request is open. **No bought asset packs** — every asset
is generated (Meshy) or built here (Blender, shaders, painted textures).
Nick, 2026-09-23. The two loudest items on that list are yours: the hunters
matching the jackal's fidelity, and the arena framing the fight instead of
competing with it. The card items on that list are parked with the card art.
