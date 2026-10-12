---
tags:
  - agents
---

# How the cloud agents run things

Every run starts on a fresh Ubuntu 24.04 sandbox (root, 4 cores, Xvfb and Mesa
software OpenGL already installed). Set up once per run:

    git fetch --prune origin main && git checkout -B main FETCH_HEAD
    curl -sL -o /tmp/g.zip https://github.com/godotengine/godot/releases/download/4.7.1-stable/Godot_v4.7.1-stable_linux.x86_64.zip
    unzip -o -q /tmp/g.zip -d /tmp && chmod +x /tmp/Godot_v4.7.1-stable_linux.x86_64
    export GODOT=/tmp/Godot_v4.7.1-stable_linux.x86_64
    $GODOT --headless --path game --import        # REQUIRED on a fresh clone

Render (real pixels, not headless) by wrapping in a virtual display:

    R="xvfb-run -a -s '-screen 0 1280x720x24'"
    eval $R $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720
    eval $R $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=80 out=/tmp/pt

Tests (headless is fine): `$GODOT --headless --path game --script res://tools/run_tests.gd` must print `ALL TESTS PASSED`.

Blender (artist): `curl -sL -o /tmp/b.tar.xz https://download.blender.org/release/Blender4.1/blender-4.1.1-linux-x64.tar.xz && tar -xJf /tmp/b.tar.xz -C /tmp && ln -sf /tmp/blender-4.1.1-linux-x64/blender /tmp/blender`

## Looking at what you made

You CAN read a PNG. Look at every frame you claim something about, at 1:1 —
never judge from a zoomed crop (see `tools/builder/BRIEF.md` for why). For
motion, render several frames (`anim=attack@0.3` etc. in screenshot.gd, or the
per-step frames from playtest.gd) and tile them into one sheet with PIL.

## Useful harness switches

- `screenshot.gd`: `state=3d|3dclimb|3dgrip|3dstrike|3dreward`, `wide`,
  `anim=<name>@<seconds>`, `endturn=N`, `hover=N`, `hand=a,b,c`, `classic`.
  Prints `HANDGEO`, `HUNTER`, `VIS`, `CAM` lines — read them.
- `playtest.gd`: `mode=play|hover|hands`. Prints `FAIL [step N] <check>: …`
  and writes `report.md` + `step_NNN.png`.
- `tools/preview_beast.cmd` is Windows-only; on Linux run the three commands
  inside it by hand.
