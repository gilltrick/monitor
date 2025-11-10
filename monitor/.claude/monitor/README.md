# Claude Code Context Monitor

A real-time context state monitor for Claude Code that displays token usage, file access, and session information.

## Features

- **Real-time updates**: Displays context state as Claude Code processes your requests
- **Token tracking**: Shows input/output token usage and context window breakdown
- **File context**: Lists files that Claude has accessed during the session
- **Session info**: Displays session ID, working directory, and permission mode
- **Event tracking**: Shows the last hook event and tool used
- **Tool usage summary**: Track which tools Claude is using most frequently

## Installation

### Option 1: Clone into your project

```bash
cd your-project-root
git clone https://github.com/gilltrick/monitor.git .claude/monitor
```

Or manually copy the `monitor` folder into your project's `.claude/` directory:
```
your-project/
└── .claude/
    └── monitor/    ← Place monitor files here
```

### Option 2: Manual setup

1. Create `.claude/monitor/` directory in your project root
2. Copy all monitor files into `.claude/monitor/`

## Quick Start

### 1. Enable the Monitor

From the **project root** directory, run:

**Windows:**
```cmd
.claude\monitor\setup-monitor.bat
```

**Linux/Mac:**
```bash
chmod +x .claude/monitor/setup-monitor.sh
.claude/monitor/setup-monitor.sh
```

This will configure Claude Code hooks to capture events automatically.

### 2. Start Claude Code

Start a **new** Claude Code session from the project root directory. The hooks only work in new sessions.

### 3. Run the Monitor

In a separate terminal, from the **project root** directory:

**Windows:**
```cmd
.claude\monitor\run-monitor.bat
```

**Linux/Mac:**
```bash
chmod +x .claude/monitor/run-monitor.sh
.claude/monitor/run-monitor.sh
```

### 4. Use Claude Code

Interact with Claude Code normally. The monitor will update in real-time showing:
- Context window usage
- Files being accessed
- Tools being used
- Session statistics

### 5. Stop the Monitor

Press `Ctrl+C` in the monitor terminal.

## Disable the Monitor

To disable the monitoring hooks, run the setup script again:

**Windows:**
```cmd
.claude\monitor\setup-monitor.bat
```

**Linux/Mac:**
```bash
.claude/monitor/setup-monitor.sh
```

Choose "Y" when asked to disable.

## Requirements

- Python 3.6 or higher
- Claude Code
- Windows Command Prompt (cmd.exe) or Linux/Mac terminal

## Display Information

The monitor shows:

```
================================================================================
  CLAUDE CODE CONTEXT MONITOR
================================================================================

Session ID:       536e40a3-5041-4051-8f50-3adc52446b6e
Working Directory: /home/coder/dev/mail-service
Permission Mode:  default
Last Updated:     2025-11-02 20:30:30

Last Event:       PostToolUse
Last Tool:        Read

--------------------------------------------------------------------------------
CONTEXT WINDOW USAGE
--------------------------------------------------------------------------------
[███░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 8.4%

Total Used:       12,994 / 200,000 tokens

  System Prompt:         2,400 tokens ( 1.2%)
  System Tools:         13,300 tokens ( 6.7%)
  Messages:             12,994 tokens ( 6.5%)
  ────────────────────────────────────────────────────────────
  Safe Space:           142,006 tokens (91.6% remaining)
  Danger Zone:          45,000 tokens (22.5%) ⚠

--------------------------------------------------------------------------------
SESSION STATISTICS
--------------------------------------------------------------------------------
Total Messages:   5
Tools Used:       1
Files Accessed:   1

--------------------------------------------------------------------------------
LAST REQUEST
--------------------------------------------------------------------------------
Input Tokens:     9
Cache Read:       12,985
Output Tokens:    2

--------------------------------------------------------------------------------
FILES ACCESSED (1)
--------------------------------------------------------------------------------
 1. SESSION_NOTES.md

--------------------------------------------------------------------------------
TOOL USAGE SUMMARY
--------------------------------------------------------------------------------
  Read                   1x

================================================================================
Press Ctrl+C to exit | Refreshes every 0.5s
================================================================================
```

## How It Works

1. **Setup Script**: Creates `.claude/settings.json` with hook configurations
2. **Hook Events**: When Claude Code performs actions (tool use, user prompts, etc.), hooks are triggered
3. **State File**: Hook scripts receive JSON data via stdin and write it to `.cache/monitor/claude_context_state.json`
4. **Monitor**: The monitor script polls the state file and updates the display when changes are detected
5. **Transcript Parsing**: The monitor reads the conversation transcript to extract detailed token usage and file context

## Advanced Usage

### Debug Mode

To enable detailed debug logging, set the `DEBUG_MONITOR` environment variable before starting Claude Code:

**Windows:**
```cmd
set DEBUG_MONITOR=1
```

**Linux/Mac:**
```bash
export DEBUG_MONITOR=1
```

Debug logs will be written to `.cache/monitor/hook_debug.log`

### Customize Update Frequency

Edit `.claude/monitor/context_monitor.py` line 268 and modify the sleep interval:
```python
time.sleep(0.5)  # Poll every 500ms (change to desired interval)
```

### Change State File Location

The state file is automatically stored in `.cache/monitor/` at the project root (where `.claude` directory exists). The scripts automatically find the project root.

## Project Structure

Everything is contained within `.claude/monitor/` to avoid conflicts with existing project files:

```
your-project/                    # Project root
├── .claude/                     # Claude Code configuration
│   ├── settings.json           # Hook configuration (created by setup)
│   └── monitor/                # Monitor tool (clone/copy here)
│       ├── context_monitor.py  # Main monitor script
│       ├── context_hook.py     # Hook handler
│       ├── context_hook_debug.py  # Debug hook handler
│       ├── context_hook.bat    # Hook wrapper (Windows)
│       ├── context_hook.sh     # Hook wrapper (Linux/Mac)
│       ├── setup-monitor.bat   # Setup script (Windows)
│       ├── setup-monitor.sh    # Setup script (Linux/Mac)
│       ├── run-monitor.bat     # Monitor launcher (Windows)
│       ├── run-monitor.sh      # Monitor launcher (Linux/Mac)
│       ├── README.md           # This file
│       └── temp/               # Temporary files (hidden here)
└── .cache/                      # Created automatically
    └── monitor/                # Monitor state files
        ├── claude_context_state.json
        └── hook_debug.log      # (if debug mode enabled)
```

**Benefits:**
- No conflicts with project README.md, temp folders, or other files
- Self-contained in Claude Code's `.claude` directory
- Easy to clone/copy into any project
- Clean separation from project code

## Troubleshooting

### Monitor shows "Waiting for context updates..."

- Make sure you ran `.claude/monitor/setup-monitor` successfully
- Verify you started a **NEW** Claude Code session after setup
- Check that Claude Code is running from the project root directory
- Try running a command in Claude Code to trigger a hook

### Hooks not executing

- Check that Python is in your PATH: `python --version` or `python3 --version`
- Restart Claude Code after running setup
- Enable debug mode to see detailed logs

### Permission errors

- Make sure the `.cache` directory is writable
- Run terminal as administrator if needed (Windows)

### "Python is not installed" error

- Install Python 3.6 or higher from python.org
- Make sure Python is added to your system PATH

## Files

All files are located in `.claude/monitor/`:

- `context_monitor.py` - Main monitoring tool that displays the context state
- `context_hook.py` - Hook script that captures Claude Code events
- `context_hook_debug.py` - Debug version with detailed logging
- `context_hook.bat` - Windows batch wrapper for the hook script
- `context_hook.sh` - Linux/Mac shell wrapper for the hook script
- `setup-monitor.bat` / `setup-monitor.sh` - Setup scripts to configure hooks
- `run-monitor.bat` / `run-monitor.sh` - Launcher scripts to start the monitor
- `README.md` - This documentation
- `temp/` - Temporary files directory (won't conflict with project files)

## License

Free to use and modify.
