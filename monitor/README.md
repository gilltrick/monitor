# Monitor - Real-time Context Monitor for Claude Code

A real-time context monitor for Claude Code that displays:
- **Context window usage** - Track token consumption and available space
- **File access** - See which files Claude is reading/writing
- **Tool usage** - Monitor which tools are being used
- **Session statistics** - View message count and activity

---

## Installation

### Option 1: Automated Install (Recommended)

Clone this repository and run the installer:

```bash
# Clone the repository
git clone https://github.com/gilltrick/monitor.git
cd monitor

# Windows: Run the installer
monitor\.claude\monitor\install-monitor.bat

# Linux/Mac: Run the installer
bash monitor/.claude/monitor/install-monitor.sh
```

The install script will:
1. Copy `.claude/monitor` to your project
2. Clean up temporary files automatically
3. Optionally run the setup wizard

### Option 2: Quick Install via curl

Download and run the installer directly:

```cmd
# Windows - Run from your project root
curl -o install-monitor.bat https://raw.githubusercontent.com/gilltrick/monitor/main/monitor/.claude/monitor/install-monitor.bat && install-monitor.bat
```

```bash
# Linux/Mac - Run from your project root
curl -o install-monitor.sh https://raw.githubusercontent.com/gilltrick/monitor/main/monitor/.claude/monitor/install-monitor.sh && chmod +x install-monitor.sh && ./install-monitor.sh
```

### Option 3: Manual Installation

If you prefer manual control:

```bash
# 1. Clone the repository
git clone https://github.com/gilltrick/monitor.git
cd monitor

# 2. Copy to your project (adjust path as needed)
# Windows:
xcopy /E /I monitor\.claude\monitor <YOUR_PROJECT_PATH>\.claude\monitor

# Linux/Mac:
cp -r monitor/.claude/monitor <YOUR_PROJECT_PATH>/.claude/

# 3. Clean up
cd ..
rm -rf monitor  # Or manually delete the cloned folder

# 4. Run setup from your project
# Windows:
.\.claude\monitor\setup-monitor.bat

# Linux/Mac:
./.claude/monitor/setup-monitor.sh
```

---

## Usage

### 1. Run Setup (First Time Only)

Configure the monitoring hooks:

```cmd
# Windows
.\.claude\monitor\setup-monitor.bat

# Linux/Mac
./.claude/monitor/setup-monitor.sh
```

This creates/updates `.claude/settings.json` with the necessary hooks.

### 2. Start the Monitor

Open a separate terminal and run:

```cmd
# Windows
.\.claude\monitor\run-monitor.bat

# Linux/Mac
./.claude/monitor/run-monitor.sh
```

### 3. Use Claude Code

Start using Claude Code in your project. The monitor will automatically update in real-time showing:
- Token usage (input, output, cache)
- Context window breakdown
- Files being accessed
- Tools being used
- Session statistics

---

## Uninstalling

To remove the monitor from your project:

```bash
# Simply delete the monitor directory
# Windows:
rmdir /S /Q .claude\monitor

# Linux/Mac:
rm -rf .claude/monitor
```

You may also want to remove the hooks from `.claude/settings.json` if you're not using other hooks.

---

## Troubleshooting

### Monitor not updating:
- Ensure hooks are properly configured (run setup again)
- Check that Claude Code is running in the same project
- Verify `.cache/monitor/claude_context_state.json` exists

### Setup fails:
- Ensure you're in a Claude Code project (has `.claude` folder)
- Check write permissions
- Verify Python is installed (required for hooks)

### Debug mode:
```cmd
# Windows
set DEBUG_MONITOR=1
# Then use Claude Code

# Linux/Mac
export DEBUG_MONITOR=1
# Then use Claude Code

# Check logs at: .cache/monitor/hook_debug.log
```

---

## Advanced Configuration

For detailed documentation and advanced configuration options, see the files in `.claude/monitor/`.
