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

Scaffold complete: runnable window + isolated, tested `/core`.
Next: **build step 1** — the single-player core loop (one character, starter
deck, one boss, turn-based combat, win/lose). Prove it's fun solo before
networking (CLAUDE.md §7).
