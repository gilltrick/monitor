@echo off
REM Claude Code Context Hook - Batch Wrapper
REM This wrapper calls the Python hook script

REM Use debug version if DEBUG_MONITOR environment variable is set
if defined DEBUG_MONITOR (
    python "%~dp0context_hook_debug.py"
) else (
    python "%~dp0context_hook.py"
)
