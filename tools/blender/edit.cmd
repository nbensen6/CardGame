@echo off
REM Open a model in Blender to look at or tweak by hand.
REM
REM   tools\blender\edit.cmd frog             a hunter or a beast
REM   tools\blender\edit.cmd env crag_pup     a fight's ground
REM   tools\blender\edit.cmd map grass        an overworld tile
REM   tools\blender\edit.cmd blends           write .blend files for ALL of them
REM
REM Blender cannot File > Open a .glb — glTF is an import format, and there is no
REM .blend in this project because the scripts here are the source. So this
REM imports the right file for you, frames it, and turns on material preview.
REM
REM `blends` writes a real .blend beside every model in tools\blender\blends\,
REM which you CAN double-click. Those are a scratch copy: rebuilding replaces the
REM .glb and leaves them alone.

set BLENDER=C:\Program Files\Blender Foundation\Blender 4.1\blender.exe

if /i "%~1"=="blends" (
  "%BLENDER%" --background --python "%~dp0edit.py" -- blends
  echo.
  echo Open any of them from tools\blender\blends\ — double-click works on these.
  exit /b 0
)

if "%~1"=="" (
  echo Usage: edit.cmd ^<name^> ^| edit.cmd env ^<name^> ^| edit.cmd map ^<name^> ^| edit.cmd blends
  exit /b 1
)

start "" "%BLENDER%" --python "%~dp0edit.py" -- %1 %2
