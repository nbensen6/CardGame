@echo off
REM Open the game straight into a fight. Nick clicks these from Obsidian.
REM
REM     tools\play.cmd cinder_jackal
REM     tools\play.cmd titan://cinder_jackal/      (what the titan: scheme hands us)
REM     tools\play.cmd                             (no beast - the normal menu)
REM
REM Windows appends a trailing slash to a bare scheme URL, so both forms are
REM accepted and normalised here rather than in the game.
REM
REM This one deliberately opens on the main screen WITH focus: Nick asked for
REM it by clicking. tools\shot.cmd is the opposite case (a harness that must
REM never steal his screen) and writes an override.cfg to stay away.
setlocal
set "ROOT=%~dp0.."
set "ID=%~1"
if "%ID%"=="" goto :launch
set "ID=%ID:titan://=%"
if "%ID:~-1%"=="/" set "ID=%ID:~0,-1%"
set "ID=%ID:/=%"

:launch
set "GODOT=C:\Users\nbens\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe"
REM game\override.cfg keeps AGENT-driven runs off Nick's screen, unfocused and
REM silent. For a run he asked for by clicking, all three are wrong: no_focus
REM makes the game ignore the keyboard (2026-09-28, "all my keyboard inputs are
REM not being recorded"), it opens on the wrong monitor, and the Dummy audio
REM driver means no sound. So it is moved aside for the length of the game and
REM put straight back -- deleting it would quietly disarm every agent run after.
set "OV=%ROOT%\game\override.cfg"
set "OVSAVE=%ROOT%\game\override.cfg.playing"
if exist "%OV%" move /y "%OV%" "%OVSAVE%" >nul
REM Pull first: the cloud builder pushes to main and cannot reach this PC.
git -C "%ROOT%" pull --rebase --autostash --quiet origin main
REM Reimport first, same reason tools\dev.cmd does it: a new .glb or class_name
REM that the cache has not seen fails to compile and looks like a broken game.
"%GODOT%" --headless --path "%ROOT%\game" --import >nul 2>&1
if "%ID%"=="" (
  "%GODOT%" --path "%ROOT%\game"
) else (
  "%GODOT%" --path "%ROOT%\game" -- fight=%ID%
)
if exist "%OVSAVE%" move /y "%OVSAVE%" "%OV%" >nul
