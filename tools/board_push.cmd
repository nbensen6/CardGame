@echo off
REM Send whatever Nick wrote on the board (design/agents/**) to the agents.
REM They read the repo from GitHub, so a request note only reaches them once
REM it is pushed. Double-click this, or run it from anywhere.
cd /d "%~dp0.."
git add design/agents
git diff --cached --quiet && echo nothing new on the board && exit /b 0
git commit -q -m "board: Nick's edits"
git pull -q --rebase && git push -q && echo sent to the agents || echo PUSH FAILED - tell Claude
