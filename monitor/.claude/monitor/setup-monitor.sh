#!/usr/bin/env bash
# Setup script for Claude Code Context Monitor
# This script configures hooks in .claude/settings.json

echo "================================================================================"
echo "  Claude Code Context Monitor - Setup"
echo "================================================================================"
echo

# Find project root (where .claude directory is located)
MONITOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$MONITOR_DIR/../.." && pwd)"

echo "Project Root:  $PROJECT_ROOT"
echo "Monitor Dir:   $MONITOR_DIR"
echo

# Check if .claude directory exists
if [ ! -d "$PROJECT_ROOT/.claude" ]; then
    echo "Creating .claude directory..."
    mkdir -p "$PROJECT_ROOT/.claude"
fi

# Check if settings.json already exists
SETTINGS_FILE="$PROJECT_ROOT/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    echo
    echo "WARNING: $SETTINGS_FILE already exists."
    echo
    echo "Do you want to:"
    echo "  [1] Update/merge hooks (recommended)"
    echo "  [2] Overwrite completely"
    echo "  [3] Cancel"
    echo
    read -p "Enter choice (1-3): " choice

    if [ "$choice" = "3" ]; then
        echo
        echo "Setup cancelled."
        exit 0
    fi

    if [ "$choice" = "2" ]; then
        echo
        echo "Overwriting settings.json..."
    else
        echo
        echo "Merging hooks (not implemented yet - will overwrite)..."
    fi
fi

# Create settings.json with hook configuration
echo "Creating/updating settings.json..."

cat > "$SETTINGS_FILE" << EOF
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$MONITOR_DIR/context_hook.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$MONITOR_DIR/context_hook.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$MONITOR_DIR/context_hook.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$MONITOR_DIR/context_hook.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
EOF

# Make hook scripts executable
chmod +x "$MONITOR_DIR/context_hook.sh"
chmod +x "$MONITOR_DIR/run-monitor.sh"

echo
echo "================================================================================"
echo "  Setup Complete!"
echo "================================================================================"
echo
echo "Configuration saved to: $SETTINGS_FILE"
echo
echo "NEXT STEPS:"
echo "  1. Start a NEW Claude Code session (hooks only work in new sessions)"
echo "  2. Run the monitor: .claude/monitor/run-monitor.sh"
echo "  3. Use Claude Code normally - the monitor will update in real-time"
echo
echo "To disable the monitor, delete or edit .claude/settings.json"
echo "================================================================================"
