@echo off
REM The builder: one local Claude Code run that makes a SYSTEM-level change.
REM
REM   tools\builder\run.cmd            do a build now
REM   tools\builder\run.cmd --dry      plan it, change nothing
REM
REM Reads tools\builder\BRIEF.md, takes one item from design\BUILDER-QUEUE.md,
REM and changes a PIPELINE rather than an asset - a shader, a build step, a
REM layout rule, a tool. Pushes a BRANCH for Nick to look at. Never main.
REM
REM Why this lane exists, 2026-09-08. Nick, after a week of the other two:
REM "it does not feel like the cloud/fixer are making good progress."
REM He was right, and the numbers are stark. Everything that visibly moved the
REM game came from changing a SYSTEM:
REM
REM   creature.gdshader      1 file      every beast and hunter
REM   union + remesh         1 script    the ceiling for every beast
REM   the ember channel      1 file      every beast that opts in
REM   ~20 hourly asset passes            nothing anyone could see
REM
REM The other two lanes are structurally barred from that work - "two fixes per
REM run, one asset per run, stop after one" is a good safety rule and it caps
REM every possible improvement at cosmetic. So this lane gets the opposite
REM shape: fewer runs, bigger scope, and a human gate instead of a size limit.
REM
REM To run it by itself every four hours:
REM
REM   schtasks /create /tn "TitanSlayers Builder" /sc hourly /mo 4 ^
REM     /tr "\"%~f0\"" /rl LIMITED /f
REM
REM Delete it with:  schtasks /delete /tn "TitanSlayers Builder" /f
REM
REM Left for Nick to register rather than done automatically, same as the fixer:
REM a task that edits a repo and pushes on a schedule is his call.

setlocal
set "ROOT=%~dp0..\.."
set "LOG=%~dp0last-run.log"
cd /d "%ROOT%"

REM Log opened FIRST, before anything that can bail. The fixer spent two
REM separate outages invisible because its early exits ran before this line and
REM left the previous run's file looking current. See tools\fixer\run.cmd for
REM the full account.
echo === builder run %DATE% %TIME% > "%LOG%"

REM Share the fixer's own copy of claude.exe rather than keeping a second one.
REM It lives on G: because the scheduled task cannot read the user's AppData on
REM this machine - the reasoning, and everything that was tried, is written out
REM at length in tools\fixer\run.cmd. Refreshing it is the fixer's job; this
REM lane just uses whatever is there.
set "CLAUDE=G:\fixer-bin\claude.exe"
if not exist "%CLAUDE%" (
  echo === no claude.exe at %CLAUDE%
  echo === FAILED: no claude.exe at %CLAUDE%. Run tools\fixer\run.cmd once to populate it. >> "%LOG%"
  endlocal
  exit /b 1
)

REM The CLI's token, read explicitly if this process did not inherit it.
REM
REM Without this the run dies with "OAuth session expired and could not be
REM refreshed", which names the wrong cause and has cost this project days
REM before: the token is not expired, it is simply absent from the environment.
REM CLAUDE_CODE_OAUTH_TOKEN is set at USER scope, which lives in the registry
REM and only reaches a process that was started after it was set — a scheduled
REM task, or any shell opened earlier, has never heard of it.
REM The PowerShell lives in token.ps1, not inline: cmd counts parentheses
REM naively inside a for /f block and GetEnvironmentVariable('NAME','User') is
REM full of them, quoted or not. Inlined, it printed "operable program or batch
REM file" and left every SET after it unassigned — which surfaced as an empty
REM claude.exe path rather than as a parse error. Same lesson as
REM tools\fixer\newest-claude.ps1.
if not defined CLAUDE_CODE_OAUTH_TOKEN (
  for /f "usebackq delims=" %%T in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0token.ps1"`) do set "CLAUDE_CODE_OAUTH_TOKEN=%%T"
)
if not defined CLAUDE_CODE_OAUTH_TOKEN (
  echo === no CLAUDE_CODE_OAUTH_TOKEN in the environment or at User scope
  echo === FAILED: no CLAUDE_CODE_OAUTH_TOKEN. Run `claude` once in a terminal and sign in. >> "%LOG%"
  endlocal
  exit /b 1
)

set "MODE=Make the change."
if /i "%~1"=="--dry" set "MODE=DRY RUN. Plan it and report what you WOULD change, but do not edit, build, commit or push anything."

echo === builder starting in %ROOT%
echo === %MODE%
echo === launching, mode: %MODE% >> "%LOG%"

REM acceptEdits, not bypassPermissions: this lane touches shaders, build scripts
REM and shared tooling with nobody watching. It gets to write files without a
REM prompt; it does not get to run arbitrary commands.
"%CLAUDE%" -p "Read tools/builder/BRIEF.md and follow it exactly for ONE queue item. %MODE%" ^
  --permission-mode acceptEdits ^
  --allowedTools "Read,Edit,Write,Glob,Grep,Bash" >> "%LOG%" 2>&1
echo exit code: %ERRORLEVEL% >> "%LOG%"

echo.
echo === builder done. Check: git branch -a, then git log origin/main..^<branch^>
endlocal
