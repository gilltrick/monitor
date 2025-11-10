#!/bin/bash
# Claude Code Context Hook - Shell Wrapper
# This wrapper calls the Python hook script

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Use debug version if DEBUG_MONITOR environment variable is set
if [ -n "$DEBUG_MONITOR" ]; then
    python3 "$SCRIPT_DIR/context_hook_debug.py"
else
    python3 "$SCRIPT_DIR/context_hook.py"
fi
