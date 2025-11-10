#!/usr/bin/env bash
# Run the Claude Code Context Monitor from .claude/monitor directory

# Get the directory where this script is located
MONITOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the monitor directory
cd "$MONITOR_DIR"

echo "================================================================================"
echo "  Claude Code Context Monitor"
echo "================================================================================"
echo
echo "Starting monitor..."
echo "Press Ctrl+C to stop"
echo

# Try python3 first, then python
if command -v python3 &> /dev/null; then
    python3 context_monitor.py
elif command -v python &> /dev/null; then
    python context_monitor.py
else
    echo "ERROR: Python not found. Please install Python 3.6 or higher."
    exit 1
fi
