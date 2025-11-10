# Monitor - Real-time Context Monitor for Claude Code

A real-time context monitor for Claude Code that displays:
- **Context window usage** - Track token consumption and available space
- **File access** - See which files Claude is reading/writing
- **Tool usage** - Monitor which tools are being used
- **Session statistics** - View message count and activity

## Quick Start

```bash
# Clone the repository
git clone https://github.com/gilltrick/monitor.git
cd monitor

# Windows: Run the installer
monitor\.claude\monitor\install-monitor.bat

# Linux/Mac: Run the installer
bash monitor/.claude/monitor/install-monitor.sh
```

For detailed installation instructions, usage guide, and troubleshooting, see [monitor/README.md](monitor/README.md).

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

## License

Monitor is dual-licensed:

- **Free for personal and educational use** - Licensed under the Polyform Noncommercial License 1.0.0
- **Commercial license available** - Required for business/commercial use

See [LICENSE](LICENSE) for details.
