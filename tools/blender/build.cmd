@echo off
REM Build one or more cast models AND make the game actually see them.
REM
REM     tools\blender\build.cmd frog goblin_mech
REM     tools\blender\build.cmd all
REM
REM The second half is the point. Godot caches every imported .glb as a .scn
REM under .godot/imported/, and it only notices a changed source file when the
REM EDITOR opens the project. Running the game straight from the command line
REM never reimports, so a rebuilt model exports fine, passes every check, and
REM the game keeps drawing the old one - which looks exactly like the build
REM silently failing. `--import` is the fix and it belongs here, not in a note
REM somebody has to remember.

setlocal
set BLENDER=C:\Program Files\Blender Foundation\Blender 4.1\blender.exe
set GODOT=C:\Users\nbens\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe
set ROOT=%~dp0..\..
set NAMES=%*
if "%NAMES%"=="" (
  echo usage: build.cmd ^<name^> [name ...]   ^|   build.cmd all
  exit /b 1
)
if /i "%NAMES%"=="all" set NAMES=frog vine_weaver mountain_climbers goblin_mech crag_pup riftling stone_warden

for %%N in (%NAMES%) do (
  if not exist "%~dp0%%N.py" (
    echo   SKIP %%N - no tools\blender\%%N.py
  ) else (
    echo.
    echo === %%N ===
    "%BLENDER%" --background --python "%~dp0%%N.py" -- "%ROOT%\game\assets\3d\cast\%%N.glb" ^
      | findstr /R "TRIS PARTS SIZE WARNING WROTE"
  )
)

echo.
echo === reimporting so the game sees them ===
"%GODOT%" --headless --path "%ROOT%\game" --import >nul 2>&1
echo done.
endlocal
