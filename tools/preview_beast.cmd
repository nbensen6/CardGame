@echo off
REM Refresh a beast's previews in design/art/previews, so Nick can look at it
REM in Obsidian (or any image viewer) without booting the game.
REM
REM     tools\preview_beast.cmd cinder_jackal
REM
REM Writes two kinds of picture, because they answer different questions:
REM   <id>_0/1/2.png      Blender turnaround (three-quarter, front, side) of the
REM                       model file itself - shape and texture, no game lighting
REM   <id>_game_*.png     the real game: toon shader, outline, arena, hunters.
REM                       wide = opening shot, climb = hunters on the footholds,
REM                       attack = mid-bite (only if the beast is rigged)
REM
REM The game shots go through tools\shot.cmd, so the window opens on the second
REM monitor without taking focus.
setlocal
if "%~1"=="" (echo usage: tools\preview_beast.cmd ^<beast_id^> & exit /b 1)
set "ID=%~1"
set "ROOT=%~dp0.."
set "OUT=%ROOT%\design\art-previews"
set "BLENDER=C:\Program Files\Blender Foundation\Blender 4.1\blender.exe"

REM AI-rebuilt beasts ship as <id>_ai.glb (combat_3d.AI_ART); prefer that.
set "GLB=%ROOT%\game\assets\3d\cast\%ID%_ai.glb"
if not exist "%GLB%" set "GLB=%ROOT%\game\assets\3d\cast\%ID%.glb"
if not exist "%GLB%" (echo no model for %ID% & exit /b 1)

"%BLENDER%" --background --python "%ROOT%\tools\blender\preview.py" -- "%GLB%" "%OUT%\%ID%.png" >nul 2>&1
call "%ROOT%\tools\shot.cmd" out="%OUT%\%ID%_game_wide.png" state=3d beast=%ID% size=1280x720 wide >nul 2>&1
call "%ROOT%\tools\shot.cmd" out="%OUT%\%ID%_game_climb.png" state=3dclimb beast=%ID% size=1280x720 >nul 2>&1
call "%ROOT%\tools\shot.cmd" out="%OUT%\%ID%_game_attack.png" state=3d beast=%ID% size=1280x720 wide anim=attack@0.53 >nul 2>&1
echo previews for %ID% written to design\art-previews
