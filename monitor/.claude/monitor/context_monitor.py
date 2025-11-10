#!/usr/bin/env python3
"""
Claude Code Context Monitor
Displays real-time context state in Windows terminal
"""

import json
import os
import time
import sys
from datetime import datetime
from pathlib import Path

# ANSI color codes for terminal output
class Colors:
    RED = '\033[91m'
    YELLOW = '\033[93m'
    GREEN = '\033[92m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

    @staticmethod
    def is_supported():
        """Check if terminal supports colors"""
        # Windows 10+ supports ANSI, older versions might not
        if os.name == 'nt':
            import platform
            return platform.release() != '7'  # Disable on Win7
        return True  # Unix terminals support ANSI

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

def clear_screen():
    """Clear the terminal screen"""
    # Use 'cls' on Windows, 'clear' on Unix-like systems
    os.system('cls' if os.name == 'nt' else 'clear')

def format_timestamp(ts=None):
    """Format timestamp for display"""
    if ts is None:
        ts = datetime.now()
    return ts.strftime("%Y-%m-%d %H:%M:%S")

def create_progress_bar(used, safe_max, danger_zone, width=50):
    """Create a visual progress bar showing used/safe/danger zones

    Args:
        used: Tokens currently used
        safe_max: Maximum safe tokens (before danger zone)
        danger_zone: Size of danger zone
        width: Width of the progress bar in characters
    """
    colors_enabled = Colors.is_supported()
    total = safe_max + danger_zone

    # Calculate proportions
    used_width = int((used / total) * width)
    safe_width = int((safe_max / total) * width)
    danger_width = width - safe_width

    # Build the bar
    if used <= safe_max:
        # Still in safe zone
        filled = min(used_width, safe_width)
        bar = '█' * filled + '░' * (safe_width - filled)
        if colors_enabled:
            bar = Colors.GREEN + bar + Colors.RESET
            danger_bar = Colors.RED + '░' * danger_width + Colors.RESET
        else:
            danger_bar = '░' * danger_width
        return '[' + bar + danger_bar + ']'
    else:
        # Entered danger zone
        bar = '█' * safe_width
        danger_used = used - safe_max
        danger_filled = int((danger_used / danger_zone) * danger_width)
        danger_bar = '█' * danger_filled + '░' * (danger_width - danger_filled)

        if colors_enabled:
            bar = Colors.GREEN + bar + Colors.RESET
            danger_bar = Colors.RED + danger_bar + Colors.RESET
        else:
            bar = bar
            danger_bar = danger_bar

        return '[' + bar + danger_bar + ']'

def parse_transcript(transcript_path):
    """Parse transcript JSONL file to get context usage, files, and tools used"""
    try:
        if not transcript_path or not os.path.exists(transcript_path):
            return None, [], [], 0, None

        # Parse JSONL format (one JSON object per line)
        entries = []
        with open(transcript_path, 'r', encoding='utf-8') as f:
            for line in f:
                try:
                    entries.append(json.loads(line))
                except json.JSONDecodeError:
                    continue

        # Calculate context window usage from last message with usage data
        context_info = None
        last_usage = None

        for entry in reversed(entries):
            if entry.get('type') == 'assistant':
                msg_usage = entry.get('message', {}).get('usage')
                if msg_usage:
                    last_usage = msg_usage

                    # Calculate context breakdown
                    input_tokens = msg_usage.get('input_tokens', 0)
                    cache_read = msg_usage.get('cache_read_input_tokens', 0)
                    output_tokens = msg_usage.get('output_tokens', 0)

                    # Total tokens in this request
                    total_input = input_tokens + cache_read

                    # Estimate context window breakdown
                    # System prompt + tools are usually cached (from cache_read)
                    # These are fixed overhead, estimate ~15-16k tokens
                    system_overhead = 15700  # Approximate: system prompt + tools

                    # Messages = remaining tokens
                    message_tokens = total_input - system_overhead if total_input > system_overhead else total_input

                    # Context window is 200k for Sonnet
                    max_tokens = 200000
                    used_tokens = total_input

                    # Autocompact buffer (usually ~22.5% of max, 45k tokens)
                    autocompact_buffer = 45000

                    # Safe space = max - autocompact buffer
                    safe_max = max_tokens - autocompact_buffer  # 155k
                    safe_remaining = safe_max - used_tokens

                    context_info = {
                        'total_used': used_tokens,
                        'max_tokens': max_tokens,
                        'system_prompt': 2400,  # Approximate
                        'system_tools': 13300,   # Approximate
                        'messages': message_tokens,
                        'safe_max': safe_max,
                        'safe_remaining': safe_remaining,
                        'autocompact_buffer': autocompact_buffer,
                        'in_danger_zone': used_tokens > safe_max,
                        'last_request': {
                            'input': input_tokens,
                            'cache_read': cache_read,
                            'output': output_tokens
                        }
                    }
                    break

        # Get list of files accessed (from Read/Edit/Write tools)
        # Store as tuples: (file_path, operation_type)
        files_accessed = []  # Keep chronological order
        files_seen = {}  # Track which files we've seen to avoid duplicates
        tools_used = []  # Track all tool uses

        for entry in entries:
            if entry.get('type') == 'assistant':
                content = entry.get('message', {}).get('content', [])
                for item in content:
                    if isinstance(item, dict) and item.get('type') == 'tool_use':
                        tool_name = item.get('name', '')
                        params = item.get('input', {})

                        # Track tool usage
                        tools_used.append(tool_name)

                        # Track file access with operation type
                        if tool_name in ['Read', 'Edit', 'Write']:
                            file_path = params.get('file_path')
                            if file_path and file_path not in files_seen:
                                files_accessed.append((file_path, tool_name))
                                files_seen[file_path] = True
                        elif tool_name == 'NotebookEdit':
                            notebook_path = params.get('notebook_path')
                            if notebook_path and notebook_path not in files_seen:
                                files_accessed.append((notebook_path, 'NotebookEdit'))
                                files_seen[notebook_path] = True

        # Count total messages
        message_count = sum(1 for e in entries if e.get('type') in ['user', 'assistant'])

        return context_info, files_accessed, tools_used, message_count, last_usage
    except Exception as e:
        print(f"Error parsing transcript: {e}")
        return None, [], [], 0, None

def display_state(state):
    """Display the current context state"""
    clear_screen()

    print("=" * 80)
    print("  CLAUDE CODE CONTEXT MONITOR")
    print("=" * 80)
    print()

    # Basic session info
    print(f"Session ID:       {state.get('session_id', 'N/A')[:36]}")  # Truncate UUID
    print(f"Working Directory: {state.get('cwd', 'N/A')}")
    print(f"Permission Mode:  {state.get('permission_mode', 'N/A')}")
    print(f"Last Updated:     {state.get('timestamp', 'N/A')}")
    print()

    # Last event
    print(f"Last Event:       {state.get('hook_event_name', 'N/A')}")
    if state.get('last_tool'):
        print(f"Last Tool:        {state.get('last_tool', 'N/A')}")
    print()

    # Parse transcript for detailed info
    transcript_path = state.get('transcript_path')
    if transcript_path:
        context_info, files_accessed, tools_used, message_count, last_usage = parse_transcript(transcript_path)

        # Context window usage (like /context command)
        if context_info:
            colors_enabled = Colors.is_supported()
            total = context_info['total_used']
            max_tokens = context_info['max_tokens']
            safe_max = context_info['safe_max']
            safe_remaining = context_info['safe_remaining']
            autocompact = context_info['autocompact_buffer']
            in_danger = context_info['in_danger_zone']

            # Calculate percentages
            safe_percent = (total / safe_max) * 100 if not in_danger else 100.0
            danger_percent = ((total - safe_max) / autocompact) * 100 if in_danger else 0.0

            print("-" * 80)
            print("CONTEXT WINDOW USAGE")
            print("-" * 80)

            # Progress bar
            bar = create_progress_bar(total, safe_max, autocompact, width=50)
            print(f"{bar} {safe_percent:.1f}%")
            print()

            # Status and warning
            if in_danger:
                if colors_enabled:
                    print(f"{Colors.RED}{Colors.BOLD}⚠ WARNING: IN DANGER ZONE! ({total - safe_max:,} tokens over safe limit){Colors.RESET}")
                else:
                    print(f"!!! WARNING: IN DANGER ZONE! ({total - safe_max:,} tokens over safe limit)")
                print()
            elif safe_remaining <= safe_max * 0.15:  # ≤15% safe space remaining
                if colors_enabled:
                    print(f"{Colors.YELLOW}{Colors.BOLD}⚠ WARNING: Low safe space! Only {safe_remaining:,} tokens remaining ({safe_remaining/safe_max*100:.1f}%){Colors.RESET}")
                else:
                    print(f"!!! WARNING: Low safe space! Only {safe_remaining:,} tokens remaining ({safe_remaining/safe_max*100:.1f}%)")
                print()

            # Current usage
            print(f"Total Used:       {total:,} / {max_tokens:,} tokens")
            print()

            # Breakdown
            sys_prompt = context_info['system_prompt']
            sys_tools = context_info['system_tools']
            messages = context_info['messages']

            print(f"  System Prompt:        {sys_prompt:>6,} tokens ({sys_prompt/max_tokens*100:>4.1f}%)")
            print(f"  System Tools:         {sys_tools:>6,} tokens ({sys_tools/max_tokens*100:>4.1f}%)")
            print(f"  Context:              {messages:>6,} tokens ({messages/max_tokens*100:>4.1f}%)")
            print("  " + "─" * 60)

            # Safe space vs danger zone
            if not in_danger:
                print(f"  Safe Space:           {safe_remaining:>6,} tokens ({safe_remaining/safe_max*100:>4.1f}% remaining)")
            else:
                if colors_enabled:
                    print(f"  {Colors.RED}Safe Space:           {0:>6,} tokens (EXCEEDED by {total-safe_max:,}){Colors.RESET}")
                else:
                    print(f"  Safe Space:           {0:>6,} tokens (EXCEEDED by {total-safe_max:,})")

            if colors_enabled:
                print(f"  {Colors.RED}Danger Zone:          {autocompact:>6,} tokens ({autocompact/max_tokens*100:>4.1f}%) ⚠{Colors.RESET}")
            else:
                print(f"  Danger Zone:          {autocompact:>6,} tokens ({autocompact/max_tokens*100:>4.1f}%) !!!")
            print()

        # Session stats
        print("-" * 80)
        print("SESSION STATISTICS")
        print("-" * 80)
        print(f"Total Messages:   {message_count}")
        print(f"Tools Used:       {len(tools_used)}")
        print(f"Files Accessed:   {len(files_accessed)}")
        print()

        # Last request details
        if context_info and context_info.get('last_request'):
            req = context_info['last_request']
            print("-" * 80)
            print("LAST REQUEST")
            print("-" * 80)
            print(f"Input Tokens:     {req['input']:,}")
            print(f"Cache Read:       {req['cache_read']:,}")
            print(f"Output Tokens:    {req['output']:,}")
            print()

        # Files accessed
        if files_accessed:
            # Count files that are in context (Read operations)
            in_context_count = sum(1 for _, op in files_accessed if op == 'Read')

            print("-" * 80)
            print(f"FILES ACCESSED ({len(files_accessed)}) | {in_context_count} in context")
            print("-" * 80)

            # Icon mapping
            icons = {
                'Read': '📖',
                'Edit': '✏️',
                'Write': '➕',
                'NotebookEdit': '📓'
            }

            # Show all files in chronological order
            for i, (file_path, operation) in enumerate(files_accessed, 1):
                # Show relative path if in current directory
                display_path = file_path
                cwd = state.get('cwd', '')
                if cwd and file_path.startswith(cwd):
                    display_path = file_path[len(cwd):].lstrip('\\/')

                icon = icons.get(operation, '📄')
                in_context_note = " (in context)" if operation == 'Read' else ""

                print(f"{i:2}. {icon} {display_path}{in_context_note}")

                # Limit display to 15 files
                if i >= 15 and len(files_accessed) > 15:
                    print(f"    ... and {len(files_accessed) - 15} more")
                    break
            print()

        # Recent tools
        if tools_used:
            # Count tool usage
            from collections import Counter
            tool_counts = Counter(tools_used)

            print("-" * 80)
            print("TOOL USAGE SUMMARY")
            print("-" * 80)
            for tool, count in tool_counts.most_common(10):
                print(f"  {tool:20} {count:>3}x")
            print()

    print("=" * 80)
    print("Press Ctrl+C to exit | Refreshes every 0.5s")
    print("=" * 80)

def monitor_state():
    """Monitor the state file and update display"""
    print("Claude Code Context Monitor")
    print(f"Monitoring state file: {STATE_FILE}")
    print("Waiting for context updates...")
    print()

    last_modified = 0
    last_state = None

    try:
        while True:
            if STATE_FILE.exists():
                current_modified = STATE_FILE.stat().st_mtime

                if current_modified != last_modified:
                    try:
                        with open(STATE_FILE, 'r', encoding='utf-8') as f:
                            state = json.load(f)

                        # Add timestamp to state
                        state['timestamp'] = format_timestamp()

                        display_state(state)
                        last_modified = current_modified
                        last_state = state
                    except (json.JSONDecodeError, IOError) as e:
                        # File might be being written, try again
                        time.sleep(0.1)
                        continue

            time.sleep(0.5)  # Poll every 500ms

    except KeyboardInterrupt:
        print("\n\nMonitoring stopped.")
        sys.exit(0)

if __name__ == '__main__':
    monitor_state()
