#!/usr/bin/env bash
# One-click installer for Claude Code Context Monitor
# This script handles: clone -> copy -> cleanup -> setup

set -e  # Exit on error

echo "================================================================================"
echo "  Claude Code Context Monitor - One-Click Installer"
echo "================================================================================"
echo

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "[ERROR] Git is not installed or not in PATH."
    echo "[ERROR] Please install Git first."
    echo
    exit 1
fi

# Store the directory where the script is run from
SCRIPT_START_DIR="$(pwd)"

# Detect if we're running from inside monitor repo
# If so, default to parent directory (where user originally was)
CURRENT_DIR="$(pwd)"
if [[ "$CURRENT_DIR" == */monitor ]] || [[ "$CURRENT_DIR" == */monitor/* ]]; then
    # We're inside monitor repo, use parent directory as default
    DEFAULT_TARGET="$(cd .. && pwd)"
    DEFAULT_MSG="parent directory (where you ran git clone)"
else
    # Normal case: use current directory
    DEFAULT_TARGET="$(pwd)"
    DEFAULT_MSG="current directory"
fi

# Check if we're already in a project with .claude
if [ -d ".claude" ]; then
    echo "[INFO] Found .claude directory in current location."
    echo "[INFO] This appears to be a Claude Code project."
    echo
    TARGET_DIR="$(pwd)"
else
    echo "[INFO] No .claude directory found in current location."
    echo
    read -p "Enter target project path (or press Enter to use ${DEFAULT_MSG}): " TARGET_DIR
    if [ -z "$TARGET_DIR" ]; then
        TARGET_DIR="$DEFAULT_TARGET"
    fi
    # Expand relative paths to absolute
    TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"
fi

echo
echo "[INFO] Target directory: $TARGET_DIR"
echo

# Create a temporary directory for cloning
TEMP_DIR="${SCRIPT_START_DIR}/monitor-temp"

# Check if monitor-temp already exists
if [ -d "$TEMP_DIR" ]; then
    echo "[WARNING] monitor-temp directory already exists."
    read -p "Do you want to remove it and continue? (y/n): " CLEANUP
    if [[ "$CLEANUP" =~ ^[Yy]$ ]]; then
        echo "[INFO] Removing existing monitor-temp..."
        rm -rf "$TEMP_DIR" 2>/dev/null
        if [ -d "$TEMP_DIR" ]; then
            echo "[ERROR] Failed to remove existing monitor-temp. Please remove it manually."
            exit 1
        fi
    else
        echo "[INFO] Installation cancelled."
        exit 0
    fi
fi

echo "[1/3] Cloning monitor tool from repository..."
echo
git clone --depth 1 https://github.com/gilltrick/monitor.git "$TEMP_DIR"
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to clone repository."
    echo
    exit 1
fi

# Verify the files were cloned
if [ ! -d "$TEMP_DIR/monitor/.claude/monitor" ]; then
    echo "[ERROR] Monitor files not found after clone."
    echo "[DEBUG] Contents of monitor-temp:"
    ls -la "$TEMP_DIR"
    exit 1
fi

echo
echo "[2/3] Copying monitor to target directory..."
echo

# Create .claude directory if it doesn't exist
if [ ! -d "$TARGET_DIR/.claude" ]; then
    mkdir -p "$TARGET_DIR/.claude"
    echo "[INFO] Created .claude directory"
fi

# Copy monitor directory
echo "[DEBUG] Copying from: $TEMP_DIR/monitor/.claude/monitor"
echo "[DEBUG] Copying to: $TARGET_DIR/.claude/monitor"

cp -r "$TEMP_DIR/monitor/.claude/monitor" "$TARGET_DIR/.claude/"
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to copy monitor files."
    exit 1
fi

# Make scripts executable
chmod +x "$TARGET_DIR/.claude/monitor"/*.sh 2>/dev/null
chmod +x "$TARGET_DIR/.claude/monitor"/*.py 2>/dev/null

echo "[SUCCESS] Monitor files copied successfully!"

echo
echo "[3/3] Cleaning up monitor-temp directory..."
echo

# Cleanup monitor-temp
if [ -d "$TEMP_DIR/.git" ]; then
    (cd "$TEMP_DIR" && git gc --prune=now &> /dev/null)
    (cd "$TEMP_DIR" && git clean -fdx &> /dev/null)
fi

rm -rf "$TEMP_DIR" 2>/dev/null
if [ -d "$TEMP_DIR" ]; then
    echo "[WARNING] Could not fully remove monitor-temp. You may need to delete it manually."
else
    echo "[SUCCESS] Cleanup complete!"
fi

echo
echo "================================================================================"
echo "  Installation Complete!"
echo "================================================================================"
echo
echo "Monitor files have been installed to:"
echo "  $TARGET_DIR/.claude/monitor"
echo
echo "Next steps:"
echo
echo "  1. Run setup to configure hooks:"
echo "     cd \"$TARGET_DIR\" && ./.claude/monitor/setup-monitor.sh"
echo
echo "  2. Start the monitor (in a separate terminal):"
echo "     cd \"$TARGET_DIR\" && ./.claude/monitor/run-monitor.sh"
echo
echo "  3. Start using Claude Code in your project!"
echo

# Ask if user wants to run setup now
read -p "Do you want to run setup now? (y/n): " RUN_SETUP
if [[ "$RUN_SETUP" =~ ^[Yy]$ ]]; then
    echo
    echo "Running setup..."
    echo
    cd "$TARGET_DIR" && bash ./.claude/monitor/setup-monitor.sh
fi

echo
exit 0
