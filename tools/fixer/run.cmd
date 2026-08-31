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
claude -p "Read tools/fixer/BRIEF.md and follow it exactly for ONE asset. %MODE%" ^
  --permission-mode acceptEdits ^
  --allowedTools "Read,Edit,Write,Glob,Grep,Bash"

echo.
echo === fixer done. Check: git log -3
endlocal
