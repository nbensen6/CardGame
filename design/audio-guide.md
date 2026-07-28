# Getting higher-quality sound

The game already plays sound — `tools/gen_sfx.gd` synthesizes the whole palette to
`game/audio/*.wav`. Those are decent placeholders. Here's how to move up in quality,
easiest → most involved. **The drop-in system does the heavy lifting:** put a file at
`game/audio/<event>.wav` (or `.ogg`) and it *automatically* overrides the synth —
no code, no rebuild. So upgrading is mostly "find a better file, name it right."

## The events you can replace (drop-in filenames)
`card` · `attack` · `block` · `end_turn` · `reward` · `nail` (timing hit) ·
`slip` (timing miss) · `win` · `lose` · `climb` · `reach_sigil` · `shake` ·
`strike_weakpoint`

(Want per-card or per-titan sounds too? Ask — it's a small wiring change.)

## Level 1 — free, high-quality libraries (fastest win)
All royalty-free, usable commercially (check each item's license — see
`design/cards-and-classes.md`… actually the itch note in chat: prefer **CC0**):
- **Kenney.nl** — CC0 game-audio packs (impacts, UI, whooshes). Zero attribution.
  Grab "Impact Sounds", "UI Audio", "RPG Audio". Best starting point.
- **Sonniss "GDC Game Audio Bundle"** — free every year, tens of GB of *pro*,
  royalty-free source recordings. Overkill quality; great for beast/impact layers.
- **Freesound.org** — huge; filter to **CC0**. Real recordings (rocks, thuds, cloth).
- **ZapSplat / Mixkit** — free with simple terms; good UI/impact SFX.

Workflow: find a sound → trim/convert to WAV or OGG → rename to the event →
drop in `game/audio/`. Reopen the project so Godot imports it. Done.

## Level 2 — better procedural tools (still free, more control)
- **jsfxr (sfxr.me)** / **Bfxr** — retro blips/zaps; export WAV. Good for `card`,
  `nail`, `slip`, `reward`.
- **ChipTone** (SFBGames) — richer than jsfxr, more waveform/enveloping control.
- Our own `gen_sfx.gd` — I can keep improving the synth (layering, filters) if you
  want to stay 100% procedural and license-free.

## Level 3 — craft a cohesive set (the real quality jump)
Real game sounds are **layered**: e.g. `strike_weakpoint` = a low "body" tone + a
noisy "crack" transient + a short tail. Tools: **Audacity** (free) to layer/trim,
or a DAW (Reaper is cheap, LMMS free). Pick a palette and build every sound to it —
for us: *small charming climbers vs. a huge, heavy, weighty beast*. Little sounds
are light/wooden/quick; beast sounds are low, slow, and big.

## Level 4 — commission (later, once the game's proven)
Hire a sound designer for a unified pass (Fiverr, r/gameDevClassifieds,
game-audio freelancers). Not worth it until the core loop is locked — a cohesive
pro set is a few hundred dollars and dates fast if the design shifts.

## Recommendation
Start at **Level 1 with Kenney (CC0)** — swap the 5–6 highest-impact events first
(`strike_weakpoint`, `shake`, `nail`, `slip`, `climb`, `win`). That alone lifts the
feel a lot for ~an hour of sourcing, and needs zero code. Bring me any files and
I'll wire/convert them; tell me which events feel weakest and I'll prioritize.
