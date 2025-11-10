#!/usr/bin/env python3
"""
Claude Code Context Hook Script
Receives hook events and updates the state file for the monitor
"""

import json
import sys
import os
from pathlib import Path

# Find project root (where .claude directory is located)
def find_project_root():
    """Find the project root by looking for .claude directory"""
    current = Path(os.getcwd())

    # Check current directory and all parents
    for path in [current] + list(current.parents):
        if (path / '.claude').exists():
            return path

    # Fallback to current directory
    return current

# State file location in project root cache directory
PROJECT_ROOT = find_project_root()
STATE_FILE = PROJECT_ROOT / '.cache' / 'monitor' / 'claude_context_state.json'

def update_state(hook_data):
    """Update the state file with hook data"""
    try:
        # Read existing state if it exists
        state = {}
        if STATE_FILE.exists():
            try:
                with open(STATE_FILE, 'r', encoding='utf-8') as f:
                    state = json.load(f)
            except (json.JSONDecodeError, IOError):
                state = {}

        # Update state with new data
        state['session_id'] = hook_data.get('session_id', 'N/A')
        state['cwd'] = hook_data.get('cwd', 'N/A')
        state['permission_mode'] = hook_data.get('permission_mode', 'N/A')
        state['hook_event_name'] = hook_data.get('hook_event_name', 'N/A')
        state['transcript_path'] = hook_data.get('transcript_path', '')

        # For PostToolUse events, capture the tool name
        if hook_data.get('hook_event_name') == 'PostToolUse':
            state['last_tool'] = hook_data.get('tool_name', 'N/A')

        # Write updated state
        STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(STATE_FILE, 'w', encoding='utf-8') as f:
            json.dump(state, f, indent=2)

    except Exception as e:
        # Silently fail - hooks should not interfere with Claude Code
        pass

def main():
    """Main hook handler"""
    try:
        # Read JSON from stdin
        hook_data = json.load(sys.stdin)

        # Update state file
        update_state(hook_data)

    except Exception as e:
        # Silently fail - hooks should not interfere with Claude Code
        pass

if __name__ == '__main__':
    main()
