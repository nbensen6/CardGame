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
REM Reimport first, same reason tools\dev.cmd does it: a new .glb or class_name
REM that the cache has not seen fails to compile and looks like a broken game.
"%GODOT%" --headless --path "%ROOT%\game" --import >nul 2>&1
if "%ID%"=="" (
  "%GODOT%" --path "%ROOT%\game"
) else (
  "%GODOT%" --path "%ROOT%\game" -- fight=%ID%
)
