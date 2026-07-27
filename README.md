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
  /net            transport-agnostic networking (interfaces + impl)
  /views          private (hand) view + shared (board) view — presentation only
  /input          pointer-first input abstraction
  /data           cards / bosses / relics as data files, not hard-coded
  /ui             anchor-based, scalable UI components
  /tools          headless test runner, build/content scripts
/design           design docs, card lists, balance sheets
```

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

**Build step 1 done** — a playable single-player combat loop:

- Deterministic, unit-tested `/core` combat engine (`Combat`, `Combatant`,
  `Boss`, `Card`) with no rendering/input/net deps. 10 tests, all passing.
- Data-driven cards + boss (`data/cards.json`, `data/bosses.json`).
- Tap-friendly `views/combat_view.tscn`: play cards, End Turn, boss acts on a
  telegraphed intent, win/lose overlay with Play Again. Single-pointer, no
  hover-only info, anchor-based UI (CLAUDE.md §5).

Play it: open the project and press Play, or run the CLI command above.

Next: **build step 2** — the client/server split (authoritative host, private
hand / shared board views), still testable on one machine.
