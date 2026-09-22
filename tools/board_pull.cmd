@echo off
REM Bring the agents' latest work to this PC: notes, frames and the game itself.
REM Double-click before reading the board in Obsidian or playing the game.
cd /d "%~dp0.."
git pull --rebase || (echo PULL FAILED - tell Claude & exit /b 1)
git log --oneline -8
echo.
echo Open Obsidian (G:\Co Op Game\design) - Home - the agent board.
