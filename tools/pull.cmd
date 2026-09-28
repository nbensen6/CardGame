@echo off
REM Bring the cloud builder's pushes into the checkout Nick plays and reads
REM Obsidian from. Safe to run any time: --autostash sets aside anything Nick
REM is mid-editing and puts it back. Registered as the scheduled task
REM "TitanSlayers Pull" every 15 minutes, launched hidden through hidden.vbs.
git -C "%~dp0.." pull --rebase --autostash --quiet origin main
