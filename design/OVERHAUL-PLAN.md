# The Big Overhaul — plan

Triggered 2026-07-28: Nathan bought the **Kenney All-in-1 bundle** (extracted into
the project root as an asset SOURCE — gitignored; we copy what we use into
`game/assets/**`). Mandate: overhaul visuals with the assets, redesign every
character's cards, and add new mechanics — a long autonomous run. Tone stays
**whimsical & charming** (small climbers vs. big goofy-but-weighty beasts), per
earlier direction and what the Kenney art supports.

## Hard constraint driving the method
Godot `--headless` **cannot render** — so I can't screenshot to check how visuals
look. Therefore:
- **Content & mechanics** (card effects, new systems) → fully verified by unit tests.
- **Visuals** (icons, fonts, UI, art) → I wire them so they provably *load* (headless
  load-check), but **Nathan judges the actual look on his next run** and I adjust.
- I front-load the aesthetic forks I can't preview as questions.

## Asset inventory (what we have to work with)
- **Icons/Board Game Icons** — 255+ clean icons (sword, shield, bow, fire, skull,
  flask, pouch, exploding, campfire, cards, dice, structures, resources, arrows).
  Best fit for **card art**.
- **Icons/Game Icons (+expansions)** — UI/generic (arrows, sliders) + a Fighter set.
- **UI assets** — UI Pack, **Fantasy UI Borders**, UI Adventure Pack, Pixel packs,
  Cursors, Mobile Controls. For the **interface reskin** (panels, buttons, frames).
- **Other/Fonts** — Kenney Blocks / Bold / Future (Narrow/Square). **Typography.**
- **2D assets** — many sprite packs (platformer, shooter, fish, etc.). Possible
  **creature/boss** art, though fit is uncertain (mostly platformer-y).
- **Audio** — Kenney SFX packs (still extracting at time of writing). For the
  **sound overhaul** (drop-in `game/audio/<event>.wav`).

## Progress (2026-07-28 autonomous run)
- ✅ **P1** icons + repo guard (whitelist .gitignore) — commit 38394e8
- ✅ **P2a** Frog + Rhythm combo — 6bc813e
- ✅ **P2b/c** Vine-Weaver (poison_lift, damage_per_wound) + Mountain Climbers
  (damage_per_ally_foothold) — 1e362ac
- ✅ **P5** audio: 13 Kenney SFX wired — 218a06c
- ⏳ **P4** UI reskin (font + Kenney panels/borders) — fonts copied+imported;
  font wiring DEFERRED (readability/taste — needs Nathan's eye or a preview).
- ⏳ **P6** boss/creature art — needs curation from the 2D packs (taste-risk).

## Phases (each self-verifies + commits independently)

### P1 — Visual foundation: fonts + card icons  ⬅ starting here
Copy Kenney fonts + a curated Board-Game-Icon set into `game/assets/`. Wire the
font into `ui/theme.tres`; give cards a data-driven `icon` and load the real PNGs
in `CardView`. Verifiable: assets load, every card resolves an icon.

### P2 — Character card overhauls (content)
Redesign each class's kit like the Goblin Engineer — distinct identity, timing
lean, new mechanics — one class per pass, test-covered:
- **Frog** (nimble precision / tongue) · **Vine-Weaver** (vines, poison, growth) ·
  **Mountain Climbers** (roped two-hand coordination) · (Goblin already done).

### P3 — New mechanics (as they fit the redesigns)
Candidates: status effects (poison tick already exists; add **weakness/frost**,
**momentum/combo**), **card upgrades** between fights, **per-character grip**
(Frog clings longer), titan **phase/gimmick** moves, more **relics**. Add fields to
`core` + tests as each lands.

### P4 — UI reskin (interface)
Theme the panels/buttons/HP bars/frames with the Kenney UI + Fantasy UI Borders;
apply the font everywhere; nicer card frames; reward/select/over screens.

### P5 — Audio overhaul
Once `Audio/` finishes extracting: map Kenney SFX to the 13 events (+ maybe
per-card/per-titan), copy into `game/audio/`, replacing the synth.

### P6 — Boss / creature visuals
Find or assemble whimsical beast art from the 2D packs (or keep silhouettes if
nothing fits) — the highest-taste-risk phase, likely needs Nathan's eye.

## What needs Nathan (answer from phone; I proceed on defaults meanwhile)
1. **How far to commit to the Kenney look** — full reskin as the game's style, or
   UI+icons only with art direction kept open for later commission?
2. **Card icon feel** — the clean Board-Game-Icon style is my default; OK, or want
   something more illustrative?
3. **Priority** — visuals first, content/mechanics first, or a balanced sweep?

Defaults if unanswered: whimsical tone, balanced sweep, Kenney for UI+icons+fonts
now (boss/hero art stays open). I'll adjust when you reply.
