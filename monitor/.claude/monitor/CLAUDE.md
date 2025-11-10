# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **real-time context state monitor** for Claude Code sessions. It displays token usage, file access, and session information by capturing hook events from Claude Code and presenting them in a live terminal dashboard.

The monitor is designed to be:
- Self-contained within `.claude/monitor/` to avoid conflicts with project files
- Cross-platform (Windows batch + Linux/Mac shell scripts)
- Easy to install into any Claude Code project

## Architecture

### Hook System
The monitor works by capturing Claude Code hook events through `.claude/settings.json`:
- **PostToolUse**: Captures tool usage (Read, Write, Edit, Bash, etc.)
- **UserPromptSubmit**: Captures when users submit prompts
- **SessionStart**: Captures session initialization
- **Stop**: Captures session termination

### Data Flow
1. Claude Code triggers a hook event → 2. Hook wrapper (`.bat`/`.sh`) calls Python handler → 3. Hook handler receives JSON via stdin → 4. Handler updates `.cache/monitor/claude_context_state.json` → 5. Monitor script polls state file → 6. Monitor parses transcript JSONL → 7. Display updates in real-time

### Key Components

**Python Scripts:**
- `context_monitor.py` - Main monitor that displays real-time context state by polling the state file
- `context_hook.py` - Hook handler that receives JSON events via stdin and updates state file
- `context_hook_debug.py` - Debug version with detailed logging to `.cache/monitor/hook_debug.log`

**Shell Wrappers:**
- `context_hook.{bat,sh}` - Wrapper scripts that invoke the appropriate Python handler (debug or normal based on `DEBUG_MONITOR` env var)
- `run-monitor.{bat,sh}` - Launcher scripts for the monitor display

**Setup/Installation:**
- `setup-monitor.{bat,sh}` - Configures hooks in `.claude/settings.json` (prompts to merge/overwrite if exists)
- `install-monitor.{bat,sh}` - One-click installer that clones from Git repo, copies to target project, and cleans up
- `cleanup-monitor.{bat,sh}` - Removes monitor from project

### File Locations

The monitor follows this structure when installed:
```
project-root/
├── .claude/
│   ├── settings.json          # Hook configuration (created by setup)
│   └── monitor/               # Monitor tool files (this directory)
└── .cache/
    └── monitor/
        ├── claude_context_state.json  # Live state file
        └── hook_debug.log            # Debug logs (if DEBUG_MONITOR=1)
```

### Transcript Parsing

The monitor reads the conversation transcript (JSONL format) to extract:
- **Context window usage**: Parses `usage` field from assistant messages to calculate token breakdown
- **Files accessed**: Scans tool uses for Read/Edit/Write/NotebookEdit and extracts file_path/notebook_path
- **Tool usage stats**: Counts frequency of each tool invocation
- **Session statistics**: Counts total messages, tools used, and files accessed

Token breakdown estimation:
- System overhead: ~15.7k tokens (system prompt ~2.4k + system tools ~13.3k)
- Messages: Total input - system overhead
- Free space: 200k - total used
- Autocompact buffer: Fixed at 45k tokens (22.5% of context window)

## Common Development Tasks

### Testing the Monitor Locally
From the monitor directory:
```bash
# Windows
run-monitor.bat

# Linux/Mac
./run-monitor.sh
```

### Running Setup Script
From project root (where .claude exists):
```bash
# Windows
.claude\monitor\setup-monitor.bat

# Linux/Mac
.claude/monitor/setup-monitor.sh
```

### Installing Into Another Project
```bash
# Option 1: Use one-click installer
./install-monitor.sh

# Option 2: Manual copy
cp -r monitor/.claude/monitor /path/to/project/.claude/
```

### Enabling Debug Mode
Set environment variable before starting Claude Code:
```bash
# Windows
set DEBUG_MONITOR=1

# Linux/Mac
export DEBUG_MONITOR=1
```

Debug logs appear in `.cache/monitor/hook_debug.log`

### Modifying Update Frequency
Edit `context_monitor.py:282` - change the sleep interval:
```python
time.sleep(0.5)  # Poll every 500ms
```

## Important Implementation Details

### Project Root Detection
Scripts use `find_project_root()` to locate the `.claude` directory by walking up from the current directory. This ensures the monitor works regardless of where it's run from.

### Cross-Platform Compatibility
- Python scripts use `os.name` checks and `Path` objects for portability
- Batch files use Windows-specific commands (`cls`, `%~dp0`, etc.)
- Shell scripts use portable bash constructs

### Hook Safety
Hook handlers wrap all operations in try-except blocks and silently fail to avoid interfering with Claude Code operations. The 5-second timeout in settings.json ensures hooks don't hang.

### State File Format
The state JSON contains:
```json
{
  "session_id": "...",
  "cwd": "...",
  "permission_mode": "...",
  "hook_event_name": "PostToolUse|UserPromptSubmit|SessionStart|Stop",
  "transcript_path": "...",
  "last_tool": "Read|Edit|Write|..."
}
```

## Installation Options

The repository provides two installation methods:
1. **One-click installer** (`install-monitor.sh/bat`) - Clones from GitHub, copies to target project, and cleans up
2. **Manual setup** - User clones/copies monitor folder into their project's `.claude/` directory

The installer auto-detects if running from within the `monitor` repo directory and defaults to the parent directory (where the user originally ran the clone).
