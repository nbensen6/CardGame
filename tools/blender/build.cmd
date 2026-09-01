@echo off
REM Build models AND make the game actually see them.
REM
REM     tools\blender\build.cmd frog goblin_mech      one or more cast models
REM     tools\blender\build.cmd cast                  every hunter and beast
REM     tools\blender\build.cmd env crag_pup          one fight's ground
REM     tools\blender\build.cmd env                   every fight's ground
REM     tools\blender\build.cmd map                   the overworld tiles
REM     tools\blender\build.cmd all                   the lot
REM
REM The reimport at the end is the point. Godot caches every imported .glb as a
REM .scn and only notices a changed source when the EDITOR opens the project.
REM Running the game straight from the command line never reimports, so a
REM rebuilt model exports fine, passes every check, and the game keeps drawing
REM the old one — which looks exactly like the build silently failing.

setlocal enabledelayedexpansion
set BLENDER=C:\Program Files\Blender Foundation\Blender 4.1\blender.exe
set GODOT=C:\Users\nbens\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe
set HERE=%~dp0
set ROOT=%~dp0..\..
set CASTOUT=%ROOT%\game\assets\3d\cast
set ENVOUT=%ROOT%\game\assets\3d\env
set HEXOUT=%ROOT%\game\assets\3d\hexown
set ICONOUT=%ROOT%\game\assets\icons
set PORTOUT=%ROOT%\game\assets\portraits

REM The FOLDER is the list, for both. A hardcoded CAST went stale the moment
REM the cloud routine added fourteen beasts in two days: `build.cmd cast`
REM rebuilt nineteen models and said nothing about the fourteen it had never
REM heard of. INFRA names the scripts that are tooling rather than a model.
set INFRA= kenney beast env hexes icons portraits preview dissect edit look bmcp start_mcp palette frog_smooth rare3d 
set CAST=
for %%F in ("%HERE%*.py") do call :addcast %%~nF
set GROUNDS=
for %%F in ("%HERE%env\*.py") do call :addground %%~nF

if "%~1"=="" (
  echo usage: build.cmd ^<name...^> ^| cast ^| env [name...] ^| map ^| all
  exit /b 1
)

set MODE=%~1
if /i "%MODE%"=="env" goto :envmode
if /i "%MODE%"=="map" goto :mapmode
if /i "%MODE%"=="portraits" goto :portmode
if /i "%MODE%"=="icons" goto :iconmode
if /i "%MODE%"=="all" goto :allmode
if /i "%MODE%"=="cast" (set NAMES=%CAST%) else (set NAMES=%*)
goto :castmode

:allmode
set NAMES=%CAST%
call :buildcast
call :buildenv %GROUNDS%
call :buildmap
call :buildportraits
call :buildicons
goto :reimport

:castmode
call :buildcast
goto :reimport

:envmode
shift
set ENVNAMES=
:envargs
if not "%~1"=="" (set ENVNAMES=!ENVNAMES! %~1& shift& goto :envargs)
if "!ENVNAMES!"=="" set ENVNAMES=%GROUNDS%
call :buildenv !ENVNAMES!
goto :reimport

:mapmode
call :buildmap
goto :reimport

:portmode
call :buildportraits
goto :reimport

:iconmode
call :buildicons
goto :reimport

:buildcast
for %%N in (%NAMES%) do (
  if exist "%HERE%%%N.py" (
    echo === cast %%N
    "%BLENDER%" --background --python "%HERE%%%N.py" -- "%CASTOUT%\%%N.glb" ^
      | findstr /R "TRIS PARTS CLIMB HOLD ROOM SPAN GREW WARNING FAIL"
  ) else ( echo   SKIP %%N - no tools\blender\%%N.py )
)
exit /b 0

:buildenv
for %%N in (%*) do (
  if exist "%HERE%env\%%N.py" (
    echo === ground %%N
    "%BLENDER%" --background --python "%HERE%env\%%N.py" -- "%ENVOUT%\%%N.glb" ^
      | findstr /R "TRIS GROUND WARNING"
  ) else ( echo   SKIP %%N - no tools\blender\env\%%N.py )
)
exit /b 0

:buildmap
echo === overworld tiles
"%BLENDER%" --background --python "%HERE%hexes.py" -- "%HEXOUT%" ^
  | findstr /R "TRIS WARNING"
exit /b 0

:buildportraits
echo === portraits
"%BLENDER%" --background --python "%HERE%portraits.py" -- "%PORTOUT%" ^
  | findstr /R "PORTRAIT NO"
exit /b 0

:buildicons
echo === card icons
"%BLENDER%" --background --python "%HERE%icons.py" -- "%ICONOUT%" ^
  | findstr /R "ICON WARNING"
exit /b 0

:addcast
echo %INFRA% | findstr /C:" %~1 " >nul || set CAST=%CAST% %~1
exit /b 0

:addground
set GROUNDS=%GROUNDS% %~1
exit /b 0

:reimport
echo.
echo === reimporting so the game sees them ===
"%GODOT%" --headless --path "%ROOT%\game" --import >nul 2>&1
echo done.
endlocal
