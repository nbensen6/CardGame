@echo off
title Card Lab - titan-slayer
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js was not found on PATH.
  echo The Card Lab is a small Node script - install Node and run this again.
  echo.
  pause
  exit /b 1
)

echo Starting the Card Lab...
echo It rebuilds from game/data every time you refresh the page.
echo.
node serve.js --open
echo.
echo Card Lab stopped.
pause
