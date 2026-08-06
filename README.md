# Co-Op Roguelike Deckbuilder

A cooperative, roguelike **deckbuilder** where **two players team up against a boss**.
Each player has a private hand; the boss and battlefield are shared. PC-first (Steam),
architected so a mobile / "phones-as-hands, TV-as-boss" casting mode is a later
rendering target, not a rewrite.

**Start here: [`design/GDD.md`](design/GDD.md)** — the game design document. What the
game is, every system, current content counts, and a map of every other design doc
(including which ones are now history).

See [`CLAUDE.md`](./CLAUDE.md) for the architecture rules and build conventions,
and [`design/ROADMAP.md`](design/ROADMAP.md) for milestones and Early Access scope.

## Engine

Godot **4.7.1** (GDScript). The engine is portable — no install needed.

Local editor path (this machine):
`%LOCALAPPDATA%\Programs\Godot\Godot_v4.7.1-stable_win64.exe`

## Repo layout

```
/                 CLAUDE.md, README, .gitignore
/game             Godot project (project.godot lives here)
  /core           game rules & state — NO rendering, input, or net deps
                  (Combat, Combatant, Boss, Card, PlayerState, Run, Content)
  /net            Transport interface + LocalTransport (in-process) + EnetTransport
                  (online, via NetLink RPC)
  /session        authoritative host + client proxy + Session handoff
  /views          menu (lobby) + combat view — presentation only
  /input          pointer-first input abstraction
  /data           cards / bosses / relics as data files, not hard-coded
  /ui             theme, CardView, silhouette icons, SFX hook stub
  /tools          run_tests, net_smoke (ENet), balance_sim (autoplay)
/design           direction, balance notes, tuning knobs
```

`/session` is an engine-fit addition to the brief's structure (CLAUDE.md §8
says "adjust to engine"): `GameHost` owns the only real state and depends on
both `/core` and `/net`; `GameClient` is what a view talks to. `/core` still
depends on nothing.

**Key rule:** `/core` must not depend on `/views`, `/input`, or `/net`
(CLAUDE.md §8). Game rules take inputs and produce state; views render state;
the network moves state.

## Play online co-op (two players)

Each player runs the game; one hosts, the other joins by IP. **On one machine,
open the game twice** — one window clicks **Host Game**, the other keeps
`127.0.0.1` and clicks **Join**. Authoritative-host (listen-server) model: the
host also plays.

Launch the game:

```bash
"$LOCALAPPDATA/Programs/Godot/Godot_v4.7.1-stable_win64.exe" --path "game"
```

## Run the tests (headless)

Unit tests (`/core` + `/session`, 23 tests):

```bash
"$LOCALAPPDATA/Programs/Godot/Godot_v4.7.1-stable_win64_console.exe" --headless --path "game" --script res://tools/run_tests.gd
```

Networked smoke test (real ENet on 127.0.0.1) — run each line in its own shell:

```bash
"$LOCALAPPDATA/Programs/Godot/Godot_v4.7.1-stable_win64_console.exe" --headless --path "game" res://tools/net_smoke.tscn -- host
"$LOCALAPPDATA/Programs/Godot/Godot_v4.7.1-stable_win64_console.exe" --headless --path "game" res://tools/net_smoke.tscn -- client
```

Exit code 0 = passed. (Use the `_console.exe` on Windows so stdout is captured.)

## Current status

**Build steps 1–4 done, plus an autonomous deepening pass (balance, climb loop,
3-Titan runs + relics, disconnect handling, polish).**

- **Step 1** — single-player combat loop: deterministic, unit-tested `/core`
  engine; data-driven cards + boss; tap-friendly view.
- **Step 2** — client/server split (CLAUDE.md §2): authoritative `GameHost`,
  pure `GameClient` views, snapshots split into **shared** board vs **private**
  hand, all behind the `Transport` interface.
- **Step 3** — two-player online co-op (CLAUDE.md §6):
  - `/core` supports N players — own hands/energy, ally-targeting cards
    (**Assist** shields your ally), a boss that telegraphs *which* player it will
    hit, and shared-fate loss (any death = defeat).
  - **Real networking**: `EnetTransport` (ENet + RPC) is a drop-in for
    `LocalTransport` — `/core`, host, client, and views are unchanged. A Host/Join
    lobby wires it up (listen-server / authoritative host).

- **Step 4** — content, deeper combos & meta-progression (theme: **Titan-slayers**,
  two hunters vs colossal bosses — chosen from market research, CLAUDE.md §4.3):
  - New co-op combos: **Rally** (give ally energy), **Expose** (Titan takes bonus
    damage — set up focus-fire), **Draw Aggro** (taunt a telegraphed hit off your
    ally), plus **Cover** (shield ally).
  - New Titan moves: **attack_all** (sweeps both) and **enrage** (escalates) — a
    second Titan, The Gale Serpent, uses them.
  - **Runs** (`Run`): fight Titans in sequence; after each win every hunter picks
    a reward card (persistent deck), HP carries over. Win = all Titans felled;
    any hunter's death = the run is lost.

- **Autonomous deepening pass** (theme: **Titan-slayers**, Shadow-of-the-Colossus
  inspired — see [`design/titan-design.md`](design/titan-design.md)):
  - **Balance** (sim-driven): tuned so coordination decides — naive AI 8% / a
    coordinated AI 96% over a full run ([`design/balance-notes.md`](design/balance-notes.md)).
  - **Climb loop**: shared **Foothold** + high weak points → *climb → reveal →
    strike* (Grip, Sunlight Blade, Bowshot).
  - **3-Titan runs + relics**: a 3rd Titan (Drowned Colossus, new `regen` move) and
    persistent team **relics** (energy/attack/block/heal) picked between fights.
  - **Robustness**: a dropped hunter pauses the run cleanly (Return to Menu);
    seamless reconnect still TODO.
  - **Look & feel**: SotC theme + reusable `CardView`; danger colours (HP bar,
    targeted hunter, intent); silent SFX hooks wired.

**61 unit tests pass** (`tools/run_tests.gd`) + a **two-process ENet smoke test**
(`tools/net_smoke.tscn`). A **balance simulator** (`tools/balance_sim.gd`) plays
hundreds of full runs to measure difficulty.

**To fine-tune** (difficulty, cards, Titans, relics): see
[`design/tuning-knobs.md`](design/tuning-knobs.md).

Open / needs you: whether the difficulty & combos *feel* right (playtest),
real cross-machine network test, seamless reconnect, real art, and the §4
monetization decision.
