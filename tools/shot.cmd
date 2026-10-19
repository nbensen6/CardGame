@echo off
REM Run the screenshot harness WITHOUT touching Nick's main screen.
REM
REM     tools\shot.cmd out=C:\shot.png state=3d beast=cinder_jackal
REM
REM Everything after the command goes straight to screenshot.gd.
REM
REM Why a wrapper: the window is created BEFORE any script runs, so the
REM harness's own _stay_out_of_the_way() is too late. It opened on the main
REM screen and took focus, tabbing Nick out of his game (2026-09-22). Moving it
REM to (-8000,-8000) didn't help either, because Godot clamps that back to the
REM main screen's corner. Only project settings apply at window creation, and
REM override.cfg is the one way to change them for a single run:
REM   no_focus               - the window is never activated, so no tab-out
REM   initial_position_type=3 (centre of screen N), initial_screen=0 - screen 0,
REM                            which on this machine is the SECOND monitor
REM game/override.cfg is now a PERMANENT local file (see its own header) so
REM every run stays off-screen, not just this harness. This only writes one if
REM it is missing, and only deletes the one it wrote.
setlocal
set "GODOT=C:\Users\nbens\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe"
set "OV=%~dp0..\game\override.cfg"
if not exist "%OV%" (
  > "%OV%" (
    echo [display]
    echo window/size/no_focus=true
    echo window/size/initial_position_type=3
    echo window/size/initial_screen=0
  )
  set "MADE_OV=1"
)
"%GODOT%" --path "%~dp0..\game" --script res://tools/screenshot.gd -- %*
set RC=%errorlevel%
if defined MADE_OV del "%OV%" 2>nul
exit /b %RC%
