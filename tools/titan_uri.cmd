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
REM Fully-qualified AND quoted, matching how Obsidian registers its own
REM obsidian:// handler. A bare "wscript.exe" resolves from PowerShell but not
REM from every caller, which is exactly the shape of "works when Claude tests
REM it, Store dialog when Nick clicks it".
reg add "HKCU\Software\Classes\titan\shell\open\command" /ve /d "\"%SystemRoot%\System32\wscript.exe\" \"%~dp0titan_link.vbs\" \"%%1\"" /f >nul
REM Windows 11 resolves a link scheme through the Default Apps store as well as
REM the classic HKCR key, and some callers (Obsidian among them) get the "no app
REM can open this" dialog when only the classic key exists. So register the way
REM a real installed application does: a ProgId with the handler on it, a
REM Capabilities block claiming the scheme, and an entry in RegisteredApplications
REM so Windows lists it under Default Apps at all.
reg add "HKCU\Software\Classes\TitanSlayers.Link" /ve /d "Titan-Slayers fight link" /f >nul
reg add "HKCU\Software\Classes\TitanSlayers.Link\shell\open\command" /ve /d "\"%SystemRoot%\System32\wscript.exe\" \"%~dp0titan_link.vbs\" \"%%1\"" /f >nul
reg add "HKCU\Software\TitanSlayers\Capabilities" /v ApplicationName /d "Titan-Slayers" /f >nul
reg add "HKCU\Software\TitanSlayers\Capabilities" /v ApplicationDescription /d "Opens a Titan-Slayers fight from a link" /f >nul
reg add "HKCU\Software\TitanSlayers\Capabilities\URLAssociations" /v titan /d "TitanSlayers.Link" /f >nul
reg add "HKCU\Software\RegisteredApplications" /v "Titan-Slayers" /d "Software\TitanSlayers\Capabilities" /f >nul

echo installed. Links like titan://cinder_jackal now open the game into that fight.
echo.
echo RESTART OBSIDIAN if it is already open. A program looks up a link scheme
echo once and caches it, so an app that started before this ran will keep saying
echo "Get an app to open this titan link" however correct the registration is.
exit /b 0

:remove
reg delete "HKCU\Software\Classes\titan" /f >nul 2>&1
reg delete "HKCU\Software\Classes\TitanSlayers.Link" /f >nul 2>&1
reg delete "HKCU\Software\TitanSlayers" /f >nul 2>&1
reg delete "HKCU\Software\RegisteredApplications" /v "Titan-Slayers" /f >nul 2>&1
echo removed.
