@echo off
REM Register (or remove) the titan: link scheme, so a note in Obsidian can open
REM the game into a fight: [Fight it](titan://cinder_jackal)
REM
REM     tools\titan_uri.cmd install
REM     tools\titan_uri.cmd uninstall
REM
REM Writes under HKCU\Software\Classes only - this user, no admin rights, and
REM nothing outside the current account. `uninstall` removes every key it made.
setlocal
set "ROOT=%~dp0.."
if /I "%~1"=="uninstall" goto :remove
if /I not "%~1"=="install" (echo usage: tools\titan_uri.cmd install^|uninstall & exit /b 1)

reg add "HKCU\Software\Classes\titan" /ve /d "URL:Titan-Slayers" /f >nul
reg add "HKCU\Software\Classes\titan" /v "URL Protocol" /d "" /f >nul
REM wscript.exe, not play.cmd directly: Windows refuses a .cmd as a URL
REM handler and answers "Get an app to open this titan link" with a Store
REM button. A real executable is required, so the handler is wscript running
REM titan_link.vbs, which also keeps the console window from flashing.
reg add "HKCU\Software\Classes\titan\shell\open\command" /ve /d "wscript.exe \"%~dp0titan_link.vbs\" \"%%1\"" /f >nul
echo installed. Links like titan://cinder_jackal now open the game into that fight.
exit /b 0

:remove
reg delete "HKCU\Software\Classes\titan" /f >nul 2>&1
echo removed.
