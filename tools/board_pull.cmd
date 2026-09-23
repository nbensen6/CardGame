@echo off
REM Bring the agents' latest work to this PC and make it playable: notes,
REM frames, code, assets - then Godot's import, which new .glb/.png files need
REM before the game will show them. Runs hourly (task "TitanSlayers BoardPull")
REM and is safe to double-click any time.
REM
REM Every run also writes "design\agents\Last sync.md", so Obsidian itself can
REM answer "how old is what I am reading". That note is gitignored: it is about
REM THIS PC, not about the repo, and the agents must never see it.
REM
REM Plain ASCII on purpose - an em-dash breaks cmd parsing under the OEM
REM codepage, and the failure reads as "'M' is not recognized".
setlocal
cd /d "%~dp0.."
for /f %%h in ('git rev-parse HEAD') do set "BEFORE=%%h"
REM --autostash: Nick may be mid-edit in Obsidian; set those edits aside for
REM the rebase and put them back after, instead of refusing to pull.
git pull --rebase --autostash || (echo PULL FAILED - tell Claude & exit /b 1)
for /f %%h in ('git rev-parse HEAD') do set "AFTER=%%h"
call :stamp
if "%BEFORE%"=="%AFTER%" (echo already up to date & exit /b 0)

git --no-pager log --oneline %BEFORE%..%AFTER%
REM Only reimport when something under game/ moved - the import costs ~20s and
REM a notes-only pull does not need it.
git diff --name-only %BEFORE% %AFTER% | findstr /B "game/" >nul || (echo notes only, no import needed & exit /b 0)
echo.
echo importing new assets...
"C:\Users\nbens\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe" --headless --path game --import >nul 2>&1
echo ready to play. Obsidian (G:\Co Op Game\design) has the write-ups.
exit /b 0

:stamp
set "NOTE=design\agents\Last sync.md"
for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH:mm"') do set "NOW=%%t"
set "NOW=%NOW:_= %"
> "%NOTE%" echo ---
>> "%NOTE%" echo tags:
>> "%NOTE%" echo   - agents
>> "%NOTE%" echo ---
>> "%NOTE%" echo.
>> "%NOTE%" echo # Last sync
>> "%NOTE%" echo.
>> "%NOTE%" echo Checked **%NOW%** on this PC's clock. The pull runs hourly at :35;
>> "%NOTE%" echo double-click `tools\board_pull.cmd` any time to do it now.
>> "%NOTE%" echo.
if "%BEFORE%"=="%AFTER%" (
	>> "%NOTE%" echo Nothing new came in on this check.
	goto :eof
)
>> "%NOTE%" echo What came in (times are this PC's, not the agents' UTC):
>> "%NOTE%" echo.
git --no-pager log --pretty=format:"- %%ad - %%s" --date=format-local:"%%Y-%%m-%%d %%H:%%M" %BEFORE%..%AFTER% >> "%NOTE%"
>> "%NOTE%" echo.
goto :eof
