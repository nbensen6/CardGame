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

- **The fight never draws `cinder_jackal_2d.png`.** `drawn_rig.gd` swaps the
  Body's texture for the Rig viewport, which composites the seven
  `cinder_jackal_2d_<part>.png` layers. Three sessions "cleaned the jackal" in
  the composite (destone, dehalo, a Meshy regeneration) and none of it reached
  the screen; the layers were still TARGET.png's pixels from 2026-10-10,
  cliff pockets and painted slabs included. Cut the layers (`beast_recut.py`
  from a clean composite, `beast_rig.py` from TARGET) and look at the PART
  PNGs, not the composite, when the drawing looks wrong in the fight.
- **A constant declared is not a constant applied.** `DRAWN_PUSH_BACK` sat in
  the file for a day with Nick asking twice for the beast to move; grep the
  name for a use before calling a knob done. `_process` also rewrites
  `_beast.position.z` every frame for the lunge, so a one-time offset there
  lasted one frame.
- **"Into the lava" is a picture, not a distance.** The first pass moved the
  beast 18 units back and called it done; it stood on dark floor 20 units
  short of the ring, because the arena disc is centred on the beast and its
  radius is sized by the hunters' standoff. Measure where the ring actually
  is (`lava_ring * _arena_r`), then check the shot against Nick's sentence.
- **The Godot MCP admits one client.** A second session gets "Another client is
  already connected" forever. `tools\shot.cmd` needs no editor and renders the
  fight off-screen (`out=... state=3d|3dclimb beast=cinder_jackal`); it was
  enough to verify today's pass.

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

- **The editor must be running** for the MCP to reach the project, and it takes
  a few seconds after launch to hand-shake -- the first `get_state` can fail
  while `netstat` already shows 6550 ESTABLISHED. Try again before concluding
  anything. Claude can start it:
  `"<godot>" --path "G:/Co Op Game/game" -e` in the background.
- **Verify a fix THROUGH the MCP, not with a fresh shot.** Diagnosing live and
  then confirming from a PNG is how a week went on the slab outline: the
  before/after that "proved" one fix was two frames of a bob.

- **Both MCP servers need the editor open** on the project; the server process
  running is not enough. `godot_editor_read get_state` returns "Not connected"
  until it is.
- `godot_editor_edit run` with `frozen: true` boots the game with game time
  held at frame 0, so it cannot race ahead between tool calls. Then
  `godot_game_time step` advances a bounded slice.
- **Tune the fight live.** `game/core/feel.gd` holds the grip bar and the
  sweep window as `static var`, and nothing caches them, so
  `godot_exec: Feel.SWEEP_SPEED = 1.2` takes effect on the next frame. Values
  reset to the file's defaults on relaunch; edit the file to keep one.
- A new `class_name` means **`--import` before anything will compile** — `Feel`
  was no exception.
- Prefer `godot_runtime_state digest` (text, ~free) over `screenshot_game`.
  Screenshots never decay — every frame stays in context for the rest of the
  session.
- `combat_3d.gd` has **`_mcp_state()`** (2026-10-19), so `digest select="method"`
  returns the whole fight as text: boss hp/intent, both hunters' energy,
  foothold, grip and secure, the hand, and the timing block with its own rules
  (grip seconds, miss threshold, zone bonus).
- **The digest truncates a state dict at about a kilobyte** and gives no error
  beyond `_truncated: true` — five cards' rules text alone cut the timing block
  off the end. Keep `_mcp_state()` terse; static data belongs in the json.
- **A sprite with ALPHA_CUT_OPAQUE_PREPASS writes depth.** The beast's Body
  does, so any transparent quad that INTERSECTS its flat billboard is half
  drawn and half depth-killed. That is what hollowed the climb slabs into rims
  for a week -- they are tilted quads crossing the beast's plane. `no_depth_test`
  on the slabs says what is actually true: the climb is up the near face, so a
  slab is always in front.
- There is **no harness scene** to run. To reach the fight through the MCP:
  `run frozen=true`, then `godot_exec` builds a LocalTransport + GameHost +
  GameClient, picks map nodes to the first fight, optionally
  `Content.build_boss("cinder_jackal")`, broadcasts, and
  `change_scene_to_file("res://views/combat_3d.tscn")`.
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
