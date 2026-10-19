# Learnings

Traps that have cost real time. Read before changing the thing they name.

## Godot

- **Run `--import` after new assets AND after any new `class_name`.** Skip it
  and scripts silently fail to compile, buttons go dead, and nothing in any log
  says why.

      "C:/Users/nbens/AppData/Local/Programs/Godot/Godot_v4.7.1-stable_win64_console.exe" --path game --import --headless

- **Use the `_console.exe` build on Windows** for anything run from a shell;
  the normal one detaches and you get no output.
- **Procedurally built meshes are often silently corrupt** (winding, dropped
  triangles, bad tangents). If 3D looks wrong with nothing in any log, validate
  the meshes before touching lights or materials.
- `game/views/combat_3d.gd` is **~4000 lines** — past the size where an agent
  can hold the whole file, and the point at which cross-file regressions start.
  Splitting it is on [[TASKS]].

## This machine

- **A local loop stashes every tracked edit and resets to `origin/main` at
  :14, :29, :44 and :59.** Commit inside the window or the work is gone.
- `shot.cmd` writes a temporary `override.cfg` so the window opens off-screen
  and never takes focus. Don't "simplify" it away — it tabbed Nick out of his
  game on 2026-09-22.
- **`game/override.cfg` is permanent now.** It is what keeps every launched
  game off Nick's main screen, unfocused and silent — project settings are the
  only thing that applies at window *creation*, so no script can fix it after
  the fact. It covers the MCP's `run`, `shot.cmd` and F5 alike. `shot.cmd` used
  to write and delete it; it now only deletes one it wrote. Gitignored; delete
  it to play with sound and focus.
- The builder leaves untracked files and a modified `tools/builder/sync.log`
  that block a rebase. Move them aside, stash the log, rebase, restore.

## Godot MCP

- **Both MCP servers need the editor open** on the project; the server process
  running is not enough. `godot_editor_read get_state` returns "Not connected"
  until it is.
- `godot_editor_edit run` with `frozen: true` boots the game with game time
  held at frame 0, so it cannot race ahead between tool calls. Then
  `godot_game_time step` advances a bounded slice.
- Prefer `godot_runtime_state digest` (text, ~free) over `screenshot_game`.
  Screenshots never decay — every frame stays in context for the rest of the
  session.
- Richer digests need the game's own nodes to implement `_mcp_state()` or join
  the `mcp_watch` group. Without that it falls back to walking visible nodes.

## Agents

- **A still frame cannot judge a fight.** The builder's grader received only
  before/after frames, TARGET.png and crops — so it optimised pixels for weeks
  and never saw a bad turn. Any loop that is meant to improve play has to run
  the game, not screenshot it.
- **Statistics pass while the look fails.** `sprite_match.py` read `0 of 5 off`
  on a sprite whose cracks were 1px lines with no hot core and whose facets had
  no tonal separation. Coverage counts pixels, not width; edge density counts
  edges, not contrast. Evidence, never a verdict.
- **A loop needs a failure exit.** 25 iterations ranked a ruled-out item first
  every time and kept fixing #8. It could not win and would not stop.
- **Give a critic the picture and nothing else.** A critic told what you were
  trying to do will tell you that you did it.

## Cloud sandboxes

- **No numpy** in the image. `tools/cloud_setup.sh` installs numpy, pillow and
  scipy; anything running `beast_sprite.py` or `sprite_match.py` needs it.
- **GraphQL is blocked.** `gh api repos/...` REST reads only, and `gh` is not
  preinstalled. Anything outward-facing runs on Nick's PC instead.
- **External writes are refused.** Agents write to the repo; the repo is the
  only channel out.

## Shell

- **Bash heredocs eat backslashes.** Writing Python inside `<<'PY'` mangles
  `\n`, `\b`, `\t` — it has produced a literal backspace in a file path and
  broken selftests more than once. Use the Write/Edit tools, or `chr(92)`, or
  `"\n".join([...])`.
- PowerShell here: no `&&`, no ternary, no `??`. `A; if ($?) { B }`.
