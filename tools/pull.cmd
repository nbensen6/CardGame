@echo off
REM Two-way sync between this PC and the cloud builder, every 15 minutes as
REM the scheduled task "TitanSlayers Pull" (hidden, via hidden.vbs):
REM
REM   1. needs_nick.py: Nick's ticks and answers on design\Needs Nick.md go
REM      into the queue, get committed and pushed.
REM   2. pull: the cloud builder's pushes come down. --autostash sets aside
REM      anything Nick is mid-editing and puts it back.
REM   3. needs_nick.py again: regenerate the page from the queue that just
REM      arrived. The page is gitignored, so it can never conflict.
python "%~dp0needs_nick.py" >> "%~dp0builder\sync.log" 2>&1
git -C "%~dp0.." pull --rebase --autostash --quiet origin main >> "%~dp0builder\sync.log" 2>&1
python "%~dp0needs_nick.py" >> "%~dp0builder\sync.log" 2>&1
