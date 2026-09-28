@echo off
REM Open the game in the EXACT scenario a ticket was tested in, and hand it
REM to Nick. Nick clicks "Test this now" on a ticket; the link carries the
REM harness arguments the builder used for its after frame.
REM
REM     tools\test_scenario.cmd state=3dclimb slot=1 console=climb+5
REM
REM Same setup path as tools\shot.cmd (screenshot.gd's states), plus `play`:
REM no capture, no quit, a normal focused window on the main screen. '+' in
REM a value stands for a space so the arguments survive an obsidian:// URL.
setlocal
set "ROOT=%~dp0.."
set "GODOT=C:\Users\nbens\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe"
REM A harness run killed mid-shot leaves game\override.cfg behind (no_focus):
REM clear it, or the keyboard never reaches the window.
del "%ROOT%\game\override.cfg" 2>nul
git -C "%ROOT%" pull --rebase --autostash --quiet origin main
"%GODOT%" --headless --path "%ROOT%\game" --import >nul 2>&1
"%GODOT%" --path "%ROOT%\game" --script res://tools/screenshot.gd -- play %*
