@echo off
REM Bring the agents' latest work to this PC and make it playable: notes,
REM frames, code, assets — then Godot's import, which new .glb/.png files need
REM before the game will show them. Runs hourly (task "TitanSlayers BoardPull")
REM and is safe to double-click any time.
setlocal
cd /d "%~dp0.."
for /f %%h in ('git rev-parse HEAD') do set "BEFORE=%%h"
REM --autostash: Nick may be mid-edit in Obsidian; set those edits aside for
REM the rebase and put them back after, instead of refusing to pull.
git pull --rebase --autostash || (echo PULL FAILED - tell Claude & exit /b 1)
for /f %%h in ('git rev-parse HEAD') do set "AFTER=%%h"
if "%BEFORE%"=="%AFTER%" (echo already up to date & exit /b 0)

git --no-pager log --oneline %BEFORE%..%AFTER%
REM Only reimport when something under game/ moved — the import costs ~20s and
REM a notes-only pull does not need it.
git diff --name-only %BEFORE% %AFTER% | findstr /B "game/" >nul || (echo notes only, no import needed & exit /b 0)
echo.
echo importing new assets...
"C:\Users\nbens\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe" --headless --path game --import >nul 2>&1
echo ready to play. Obsidian (G:\Co Op Game\design) has the write-ups.
