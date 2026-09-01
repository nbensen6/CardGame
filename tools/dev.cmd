@echo off
REM Launch the game with the dev switches on.
REM
REM     tools\dev.cmd                          just the game
REM     tools\dev.cmd borderless               every card borderless
REM     tools\dev.cmd borderless foil          and every card foil
REM     tools\dev.cmd hand=crescendo,leap      deal these cards every fight
REM     tools\dev.cmd borderless foil hand=crescendo
REM     tools\dev.cmd turn=0.6                 pin the 3D window to one view
REM
REM Why this exists: borderless and foil are RARE PULLS. Borderless rolls at 4
REM to 13 percent and foil at 6 to 14, both decided when a reward is taken, so
REM seeing a borderless foil of one particular card meant playing for a very
REM long time. These force it.
REM
REM Once you are in a fight, F9 cycles the treatment live:
REM   framed -^> borderless -^> borderless foil -^> foil
REM That is the useful one. The question is never "does borderless look good",
REM it is "does it look better than framed", and you can only answer that by
REM flipping between them on the same card a second apart.
REM
REM The 3D window is NOT a switch. Every rare that has art wears it in normal
REM play - so `hand=crescendo` is enough to look at one. Move the mouse across
REM the card and the picture parallaxes behind the frame.
REM
REM Plain ASCII on purpose: an em-dash in a comment breaks cmd parsing under the
REM OEM codepage, and the failure reads as "'M' is not recognized".

setlocal
set "GODOT=C:\Users\nbens\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe"
set "ROOT=%~dp0.."

REM Reimport first. Godot caches imported assets AND the global class-name
REM table, and neither is refreshed by running the game from a command line.
REM On 2026-09-01 a new class_name went in without a reimport: menu.gd could not
REM resolve it, failed to compile, and the main menu came up with dead buttons -
REM which looks exactly like a broken game and was one missing scan.
echo === reimporting
"%GODOT%" --headless --path "%ROOT%\game" --import >nul 2>&1

echo === launching  %*
"%GODOT%" --path "%ROOT%\game" -- %*
endlocal
