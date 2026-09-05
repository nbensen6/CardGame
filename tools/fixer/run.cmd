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
set "LOG=%~dp0last-run.log"
cd /d "%ROOT%"

REM OPEN THE LOG BEFORE ANYTHING THAT CAN BAIL.
REM
REM Twice now this script has failed in a way nobody could see, because the
REM early exits ran before the log was opened and left the PREVIOUS run's file
REM sitting there looking current. On 2026-09-05 the scheduled task exited 1
REM every hour while last-run.log still showed a successful manual run from
REM earlier that morning - so the evidence said "fine" while the lane was dead.
REM Every exit path below appends its reason to this file.
echo === fixer run %DATE% %TIME% > "%LOG%"

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
REM ON G:, NOT IN %LOCALAPPDATA%.
REM
REM The scheduled task cannot read the user's AppData. Not "the path is wrong"
REM - the paths expand correctly and whoami reports the same
REM desktop-qkugefc\nbensen this shell runs as - but `dir` on
REM %LOCALAPPDATA%\TitanSlayersFixer answers "File Not Found" (the directory
REM exists, its CONTENTS are invisible) while two other tools on this machine
REM list a 217MB claude.exe sitting in it. The same blindness hides every
REM version folder under %APPDATA%\Claude\claude-code, which is why version
REM detection returns nothing under the scheduler and works fine by hand.
REM
REM I did not get to the bottom of WHY, and chasing it further was costing more
REM than it was worth. What is certain is that the task reads run.cmd and
REM writes last-run.log on G: without trouble, so the binary lives there. That
REM sidesteps the question entirely.
REM
REM The cost, stated: version detection still cannot see the app's install
REM directory from the task, so the copy will not refresh itself on a scheduled
REM run. It goes stale until someone runs the fixer by hand. That is a much
REM smaller problem than a lane that does not run at all, and the refresh is
REM best-effort by design now.
set "MYBIN=G:\fixer-bin"
REM Refreshing our copy is BEST EFFORT. Having one is what matters.
REM
REM This block used to `exit /b 1` when it could not work out the newest
REM version, which is how the lane spent 2026-09-03 to -05 dead: the detection
REM failed under Task Scheduler (it works fine from an interactive shell), and
REM the script killed itself even though a perfectly good claude.exe was
REM already sitting in %MYBIN% from the previous run.
REM
REM That is the wrong dependency. An optional optimisation - "run the newest
REM build" - must never be able to stop the job. Detect if we can, copy if it
REM is new, and carry on regardless with whatever copy we already have. The
REM only fatal case is having no copy at all.
set "NEWEST="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0newest-claude.ps1" 2^>^>"%LOG%"`) do (
  set "NEWEST=%%V"
)
if not defined NEWEST (
  echo === could not detect the newest Claude Code; using the copy we have
  echo === NOTE: version detect found nothing under %CCROOT% ^(APPDATA=%APPDATA%^) >> "%LOG%"
) else (
  if not exist "%MYBIN%" mkdir "%MYBIN%"
  set "HAVE="
  if exist "%MYBIN%\version.txt" set /p HAVE=<"%MYBIN%\version.txt"
  call :refresh
)
goto :afterrefresh

:refresh
if "%HAVE%"=="%NEWEST%" goto :eof
echo === refreshing the fixer's own claude.exe to %NEWEST%
echo === refreshing claude.exe to %NEWEST% >> "%LOG%"
copy /y "%CCROOT%\%NEWEST%\claude.exe" "%MYBIN%\claude.exe" >nul
if errorlevel 1 (
  echo === copy failed; leaving the existing copy in place >> "%LOG%"
) else (
  echo %NEWEST%>"%MYBIN%\version.txt"
)
goto :eof

:afterrefresh
set "CLAUDE=%MYBIN%\claude.exe"
if not exist "%CLAUDE%" (
  echo === no usable claude.exe at %CLAUDE% and none could be copied
  echo === FAILED: no claude.exe at %CLAUDE%, and version detect found none to copy >> "%LOG%"
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
echo === launching, mode: %MODE% >> "%LOG%"
"%CLAUDE%" -p "Read tools/fixer/BRIEF.md and follow it exactly for ONE asset. %MODE%" ^
  --permission-mode acceptEdits ^
  --allowedTools "Read,Edit,Write,Glob,Grep,Bash" >> "%LOG%" 2>&1
echo exit code: %ERRORLEVEL% >> "%LOG%"

echo.
echo === fixer done. Check: git log -3
endlocal
