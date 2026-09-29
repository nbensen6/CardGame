@echo off
REM Two-way sync between this PC and the cloud builder, every 15 minutes as
REM the scheduled task "TitanSlayers Pull" (hidden, via hidden.vbs).
REM
REM needs_nick.py does all of it, in this order:
REM   1. stand exactly on origin/main (abort a half-done rebase, set local
REM      edits aside, never rebase);
REM   2. write Nick's ticks, answers and requests from design\Needs Nick.md
REM      into the queue, commit, push, retrying on the remote's newest queue;
REM   3. only after the push lands, regenerate the page. If the push fails,
REM      the page is left alone: it is the only copy of what he typed.
REM
REM There is deliberately no `git pull --rebase` here any more. On 2026-09-29
REM one jammed half-way and every sync after it failed for four hours.
python "%~dp0needs_nick.py" >> "%~dp0builder\sync.log" 2>&1
