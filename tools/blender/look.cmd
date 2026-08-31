@echo off
REM Capture an asset so it can be judged. See design/asset-loop.md.
REM
REM   tools\blender\look.cmd frog              a hunter or a beast, pass 1
REM   tools\blender\look.cmd frog 2            the same asset, pass 2
REM   tools\blender\look.cmd env crag_pup 1    a fight's ground
REM   tools\blender\look.cmd map grass 1       an overworld tile
REM   tools\blender\look.cmd cast 1            every hunter and beast
REM
REM Writes six views per asset into design/renders/. Nothing here judges
REM anything — that is the part a person (or a session with a display) does by
REM opening the images. The whole reason this file exists separately from
REM assetcheck is that assetcheck can prove a model meets its contract and
REM cannot tell you it is a murky blob.

setlocal enabledelayedexpansion
set BLENDER=C:\Program Files\Blender Foundation\Blender 4.1\blender.exe
set HERE=%~dp0
set ROOT=%~dp0..\..
set OUT=%ROOT%\design\renders


if "%~1"=="" (
  echo usage: look.cmd ^<name^> [pass] ^| look.cmd cast [pass] ^| look.cmd env ^<name^> [pass]
  exit /b 1
)

set KIND=cast
set DIR=%ROOT%\game\assets\3d\cast
if /i "%~1"=="env" (
  set KIND=env& set DIR=%ROOT%\game\assets\3d\env
  shift
) else if /i "%~1"=="map" (
  set KIND=map& set DIR=%ROOT%\game\assets\3d\hexown
  shift
)

if /i "%~1"=="cast" (
  set PASS=%~2
  if "!PASS!"=="" set PASS=1
  REM The FOLDER is the list. Hardcoding one here went stale the moment the
  REM cloud routine added fourteen beasts in two days: this rendered nineteen
  REM models and said nothing at all about the fourteen it had not heard of.
  for %%F in ("%DIR%\*.glb") do call :one %%~nF !PASS!
  goto :done
)

set PASS=%~2
if "%PASS%"=="" set PASS=1
call :one %~1 %PASS%
goto :done

:one
if not exist "%DIR%\%~1.glb" (
  echo   SKIP %~1 - no %DIR%\%~1.glb
  exit /b 0
)
"%BLENDER%" --background --python "%HERE%look.py" -- "%DIR%\%~1.glb" "%OUT%" %~1 %~2 ^
  | findstr /R "LOOK SIZE Error"
exit /b 0

:done
echo.
echo Six views per asset in design\renders\. Now open them.
endlocal
