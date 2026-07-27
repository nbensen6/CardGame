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
  /net            transport-agnostic messaging (Transport interface + LocalTransport)
  /session        authoritative host + client proxy — binds /core to /net
  /views          private (hand) view + shared (board) view — presentation only
  /input          pointer-first input abstraction
  /data           cards / bosses / relics as data files, not hard-coded
  /ui             anchor-based, scalable UI components
  /tools          headless test runner, build/content scripts
/design           design docs, card lists, balance sheets
```

`/session` is an engine-fit addition to the brief's structure (CLAUDE.md §8
says "adjust to engine"): `GameHost` owns the only real state and depends on
both `/core` and `/net`; `GameClient` is what a view talks to. `/core` still
depends on nothing.

**Key rule:** `/core` must not depend on `/views`, `/input`, or `/net`
(CLAUDE.md §8). Game rules take inputs and produce state; views render state;
the network moves state.

## Run the game (editor)

Open `game/project.godot` in the Godot editor and press Play, or from a shell:

```bash
"$LOCALAPPDATA/Programs/Godot/Godot_v4.7.1-stable_win64.exe" --path "game"
```

The boot scene runs a `/core` self-check and confirms the toolchain is wired up.

## Run the core tests (headless)

```bash
"$LOCALAPPDATA/Programs/Godot/Godot_v4.7.1-stable_win64.exe" --headless --path "game" --script res://tools/run_tests.gd
```

Exit code 0 = all passed.

## Current status

**Build steps 1 & 2 done.**

Step 1 — playable single-player combat loop: deterministic, unit-tested `/core`
engine (`Combat`, `Combatant`, `Boss`, `Card`); data-driven cards + boss;
tap-friendly `combat_view` with telegraphed boss intent and win/lose overlay.

Step 2 — the client/server split (CLAUDE.md §2, §7): game state is authoritative
in `GameHost`; the view is a pure `GameClient` that sends intents and renders
snapshots split into **shared** (the board everyone sees) and **private** (only
that player's hand). All messaging goes through the `Transport` interface —
today an in-process `LocalTransport`, swappable for real networking in step 3
with no changes to `/core`, the host, the client, or the view.

**16 headless tests pass** (`tools/run_tests.gd`), covering combat rules and the
session layer (command flow, snapshot shape, per-peer private isolation).

Play it: open the project and press Play, or run the CLI command above.

Next: **build step 3** — two-player online co-op. Swap `LocalTransport` for a
networked transport, map two peers to two hands, and add co-op *combo*
mechanics (the `assist` card is already seeded in `data/cards.json`).
