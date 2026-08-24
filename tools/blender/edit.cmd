@echo off
REM Open one cast model in Blender to fine-tune by hand.
REM   tools\blender\edit.cmd goblin_mech
if "%~1"=="" (
  echo Usage: edit.cmd ^<name^>   e.g. edit.cmd frog ^| vine_weaver ^| mountain_climbers ^| goblin_mech
  exit /b 1
)
start "" "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --python "%~dp0edit.py" -- %1
