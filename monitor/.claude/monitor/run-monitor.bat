@echo off
REM Run the Claude Code Context Monitor from .claude/monitor directory

REM Get the directory where this script is located
set "MONITOR_DIR=%~dp0"

REM Change to the monitor directory
cd /d "%MONITOR_DIR%"

echo ================================================================================
echo   Claude Code Context Monitor
echo ================================================================================
echo.
echo Starting monitor...
echo Press Ctrl+C to stop
echo.

REM Run the monitor
python context_monitor.py
