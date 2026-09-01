@echo off
REM Turn one card's art into a 3D window (backlog #84).
REM
REM     tools\blender\rare3d.cmd grand_leap
REM     tools\blender\rare3d.cmd grand_leap fg
REM
REM Reads  game\assets\cardart\<id>.png          the painting, 620x870
REM  and   game\assets\cardart\<id>_fg.png       optional, with alpha, if you
REM                                              pass "fg" as the second word
REM Writes game\assets\cardart3d\<id>.png        the sprite sheet
REM        game\assets\cardart3d\<id>.json       its grid
REM
REM Then reimports, because Godot caches every PNG and running the game from
REM the command line never notices a new one on its own.
REM
REM The card picks it up with no code change: a sheet exists, so CardView uses
REM it instead of the flat painting, on the framed AND the borderless
REM treatment. Delete the two files and the flat painting comes back.
REM
REM ART NOTES, and they matter more here than on a normal card:
REM   - keep the subject inside the middle 80 percent. The painting hangs
REM     BEHIND the window and slides, so its outer edges are off-screen by
REM     construction.
REM   - a foreground plate (the "fg" option) is where this stops looking like a
REM     wobbling picture. Leaves, a rope, a rim of rock - anything with a hard
REM     silhouette and a lot of transparent space around it.
REM
REM This file is deliberately plain ASCII. An em-dash in a comment breaks cmd
REM parsing under the OEM codepage and the failure reads as "'M' is not
REM recognized", which took half a dozen runs to pin down in tools\fixer.

setlocal
set "BLENDER=C:\Program Files\Blender Foundation\Blender 4.1\blender.exe"
set "GODOT=C:\Users\nbens\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe"
set "ROOT=%~dp0..\.."
set "ID=%~1"

if "%ID%"=="" (
  echo usage: rare3d.cmd all ^| ^<card id^> [fg]
  exit /b 1
)

if /i "%ID%"=="all" (
  echo === rendering every rare that has art
  "%BLENDER%" --background --python "%~dp0rare3d.py" -- ^
    --all --out "%ROOT%\game\assets\cardart3d"
  echo === reimporting
  "%GODOT%" --headless --path "%ROOT%\game" --import
  echo === done
  exit /b 0
)

set "ART=%ROOT%\game\assets\cardart\%ID%.png"
if not exist "%ART%" (
  echo no art at %ART%
  echo Upload it in the Card Lab first, or drop a 620x870 PNG there by hand.
  exit /b 1
)

set "FGARG="
if /i "%~2"=="fg" (
  set "FGART=%ROOT%\game\assets\cardart\%ID%_fg.png"
  if exist "%ROOT%\game\assets\cardart\%ID%_fg.png" (
    set "FGARG=--fg %ROOT%\game\assets\cardart\%ID%_fg.png"
  ) else (
    echo no foreground plate at %ROOT%\game\assets\cardart\%ID%_fg.png - carrying on without one
  )
)

echo === rendering the window for %ID%
"%BLENDER%" --background --python "%~dp0rare3d.py" -- ^
  --art "%ART%" --out "%ROOT%\game\assets\cardart3d" --name "%ID%" %FGARG%

echo === reimporting
"%GODOT%" --headless --path "%ROOT%\game" --import

echo.
echo === done. Look at it with:
echo   %%GODOT%% --path game --script res://tools/screenshot.gd -- out=C:\shot.png state=3d slot=0 hand=%ID% hover=0 turn=-1
echo (turn= pins the view, -1 to +1; leave it off and it follows the pointer)
endlocal
