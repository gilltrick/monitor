#!/usr/bin/env python3
"""
Claude Code Context Hook Script - Debug Version
Logs errors to help troubleshoot
"""

import json
import sys
import os
from pathlib import Path
from datetime import datetime

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
LOG_FILE = PROJECT_ROOT / '.cache' / 'monitor' / 'hook_debug.log'

def log_message(msg):
    """Log debug messages"""
    try:
        LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(LOG_FILE, 'a', encoding='utf-8') as f:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            f.write(f"[{timestamp}] {msg}\n")
    except Exception as e:
        pass

def update_state(hook_data):
    """Update the state file with hook data"""
    try:
        log_message(f"Updating state with data: {json.dumps(hook_data, indent=2)}")

        # Read existing state if it exists
        state = {}
        if STATE_FILE.exists():
            try:
                with open(STATE_FILE, 'r', encoding='utf-8') as f:
                    state = json.load(f)
            except (json.JSONDecodeError, IOError) as e:
                log_message(f"Error reading existing state: {e}")
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

        log_message("State file updated successfully")

    except Exception as e:
        log_message(f"Error in update_state: {e}")
        raise

def main():
    """Main hook handler"""
    try:
        log_message("Hook script started")
        log_message(f"Python version: {sys.version}")
        log_message(f"CWD: {os.getcwd()}")
        log_message(f"STATE_FILE: {STATE_FILE}")

        # Read JSON from stdin
        log_message("Reading from stdin...")
        stdin_data = sys.stdin.read()
        log_message(f"Received stdin data (length {len(stdin_data)}): {stdin_data[:500]}")

        hook_data = json.loads(stdin_data)
        log_message(f"Parsed JSON successfully")

        # Update state file
        update_state(hook_data)
        log_message("Hook completed successfully")

    except Exception as e:
        log_message(f"ERROR in main: {type(e).__name__}: {e}")
        import traceback
        log_message(f"Traceback: {traceback.format_exc()}")

if __name__ == '__main__':
    main()
