@echo off
REM The fixer: one local, headless Claude Code run that applies ONE art fix.
REM
REM   tools\fixer\run.cmd            do a pass now
REM   tools\fixer\run.cmd --dry      think it through, change nothing
REM
REM Reads tools\fixer\BRIEF.md, picks the lowest-scoring asset the cloud has
REM scored, applies the two fixes it proposed, rebuilds, LOOKS at the render,
REM keeps it or reverts it, tests, commits, pushes.
REM
REM Runs as a separate process with its own context - not this chat. That is the
REM point: the cloud reports, this repairs, and the session stays free for
REM whatever Nick is actually asking for.
REM
REM To have it run by itself, hourly, from Task Scheduler:
REM
REM   schtasks /create /tn "TitanSlayers Fixer" /sc hourly /mo 1 ^
REM     /tr "\"%~f0\"" /rl LIMITED /f
REM
REM Delete it again with:  schtasks /delete /tn "TitanSlayers Fixer" /f
REM
REM Left for Nick to run rather than done automatically: registering a task that
REM edits a repo and pushes to GitHub every hour is his call, not a side effect
REM of asking how it would work.

REM FIRST TIME: the CLI needs its own login, separate from the desktop app.
REM If this prints "OAuth session expired", run `claude` once in a terminal,
REM sign in, then close it. The token is reused after that.

setlocal
set "ROOT=%~dp0..\.."
cd /d "%ROOT%"

REM RUN OUR OWN COPY OF claude.exe, never the app's.
REM
REM This used to launch claude.exe straight out of
REM %APPDATA%\Claude\claude-code\<version>\, which is the desktop app's OWN
REM auto-updating install directory. On 2026-09-01 the app went to update
REM 2.1.247 to 2.1.255 while a fixer run was eight minutes into holding that
REM exe open. Windows will not replace a file a process has open, so the swap
REM failed, Nick got "this app is being used", and the app went down.
REM
REM The first attempt at fixing this was to skip the run while the desktop app
REM was open. That was the wrong shape: it stopped the fixer running at exactly
REM the times Nick is at the machine, it did not actually close the hole (the
REM update lands when the app RESTARTS, which is when the app is closed, which
REM is when the fixer runs), and it implied the two cannot run at once. They
REM can. They always could - two claude.exe processes coexist fine. The problem
REM was never concurrency, it was a FILE LOCK against an updater.
REM
REM So: keep our own copy somewhere the app never looks, and refresh it only
REM when the version changes. Most runs touch the app's directory not at all;
REM the refresh reads it for a couple of seconds rather than holding it open
REM for the length of a whole run.
set "CCROOT=%APPDATA%\Claude\claude-code"
set "MYBIN=%LOCALAPPDATA%\TitanSlayersFixer"
REM Which version to copy. See newest-claude.ps1 - a real [version] sort, in
REM its own file because cmd's caret escaping mangles PowerShell pipes.
set "NEWEST="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0newest-claude.ps1"`) do (
  set "NEWEST=%%V"
)
if not defined NEWEST (
  echo === cannot find %CCROOT% - is Claude Code installed?
  endlocal
  exit /b 1
)
if not exist "%MYBIN%" mkdir "%MYBIN%"
set "HAVE="
if exist "%MYBIN%\version.txt" set /p HAVE=<"%MYBIN%\version.txt"
if not "%HAVE%"=="%NEWEST%" (
  echo === refreshing the fixer's own claude.exe to %NEWEST%
  copy /y "%CCROOT%\%NEWEST%\claude.exe" "%MYBIN%\claude.exe" >nul
  if errorlevel 1 (
    echo === copy failed; leaving the existing copy in place
  ) else (
    echo %NEWEST%>"%MYBIN%\version.txt"
  )
)
REM THE TOKEN, READ EXPLICITLY. Do not trust the inherited environment.
REM
REM setx wrote CLAUDE_CODE_OAUTH_TOKEN to the USER environment, and an
REM interactive shell gets it. A scheduled task does not reliably: Task
REM Scheduler builds a child environment that does not always carry user
REM variables set after the session started, so run.cmd inherited nothing and
REM claude.exe reported "OAuth session expired and could not be refreshed".
REM
REM That is a misleading error - the token was fine the whole time, it simply
REM was not there. It cost two days: the task ran every hour from 2026-09-03 to
REM -05, exited 1 every time, and committed nothing, and nobody noticed until
REM Nick asked how the lanes were doing.
if not defined CLAUDE_CODE_OAUTH_TOKEN (
  for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command ^
    "[Environment]::GetEnvironmentVariable('CLAUDE_CODE_OAUTH_TOKEN','User')"`) do (
    set "CLAUDE_CODE_OAUTH_TOKEN=%%T"
  )
)
if not defined CLAUDE_CODE_OAUTH_TOKEN (
  echo === no CLAUDE_CODE_OAUTH_TOKEN in this process OR the user environment.
  echo === run `claude setup-token` in a terminal, then setx it. Nothing was run.
  echo === fixer FAILED %DATE% %TIME%: no OAuth token > "%~dp0last-run.log"
  endlocal
  exit /b 1
)

set "CLAUDE=%MYBIN%\claude.exe"
if not exist "%CLAUDE%" (
  echo === no usable claude.exe at %CLAUDE%
  endlocal
  exit /b 1
)

REM Quoted form: set "VAR=value", not set VAR=value.
REM
REM MODE is also a real Windows command (mode.com), and unquoted SET
REM leaves cmd able to reach it - invoked from PowerShell this file
REM printed "'M' is not recognized" half a dozen times before doing its
REM job. Quoting the assignment also stops a trailing space or a comma in
REM the value from being parsed as anything.
set "MODE=Apply the fixes."
if /i "%~1"=="--dry" set "MODE=DRY RUN. Read, decide and report what you WOULD change, but do not edit, build, commit or push anything."

echo === fixer starting in %ROOT%
echo === %MODE%

REM --permission-mode acceptEdits, not bypassPermissions: this thing edits build
REM scripts and pushes to main with nobody watching, so it gets to write files
REM without a prompt but not to run whatever it likes.
REM Everything below is logged, because the scheduled task failed overnight
REM with exit 0x1 and there was NOTHING to read - no way to tell a usage
REM limit from a bad token from a crash. One file, overwritten each run:
REM the last run is the only one anyone ever asks about.
echo === fixer run %DATE% %TIME% === > "%~dp0last-run.log"
"%CLAUDE%" -p "Read tools/fixer/BRIEF.md and follow it exactly for ONE asset. %MODE%" ^
  --permission-mode acceptEdits ^
  --allowedTools "Read,Edit,Write,Glob,Grep,Bash" >> "%~dp0last-run.log" 2>&1
echo exit code: %ERRORLEVEL% >> "%~dp0last-run.log"

echo.
echo === fixer done. Check: git log -3
endlocal
