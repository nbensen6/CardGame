@echo off
REM Open Blender with the MCP server already running, so Claude can drive it.
start "" "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --python "%~dp0start_mcp.py"
