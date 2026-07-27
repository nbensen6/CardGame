# Co-Op Roguelike Deckbuilder

A cooperative, roguelike **deckbuilder** where **two players team up against a boss**.
Each player has a private hand; the boss and battlefield are shared. PC-first (Steam),
architected so a mobile / "phones-as-hands, TV-as-boss" casting mode is a later
rendering target, not a rewrite.

See [`CLAUDE.md`](./CLAUDE.md) for the full brief, architecture rules, and build order.

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
  /ui             anchor-based, scalable UI components
  /tools          headless test runner, networked smoke test
/design           design docs, card lists, balance sheets
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

**Build steps 1–3 done.**

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

**40 unit tests pass** (`tools/run_tests.gd`) + a **two-process ENet smoke test**
(`tools/net_smoke.tscn`) confirms real cross-process connectivity on localhost.

Next: more content depth (relics, more Titans/cards, longer runs), balance
tuning, disconnect/reconnect handling, and the remaining §4 decisions
(monetization; art production now that the theme is set).
