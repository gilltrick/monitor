#!/usr/bin/env bash
# Cleanup script to safely remove monitor-temp folder after monitor installation

echo "================================================================================"
echo "  Monitor Tool Cleanup Utility"
echo "================================================================================"
echo

# Get the directory where the script is run from
SCRIPT_DIR="$(pwd)"
TEMP_DIR="${SCRIPT_DIR}/monitor-temp"

# Check if monitor-temp directory exists
if [ ! -d "$TEMP_DIR" ]; then
    echo "[INFO] No monitor-temp directory found at: $TEMP_DIR"
    echo "[INFO] Nothing to clean up."
    echo
    exit 0
fi

echo "[INFO] Found monitor-temp directory at: $TEMP_DIR"
echo

# If git is available, try to clean git objects first
if command -v git &> /dev/null; then
    echo "[INFO] Git found. Cleaning git repository..."
    if [ -d "$TEMP_DIR/.git" ]; then
        (cd "$TEMP_DIR" && git gc --prune=now &> /dev/null)
        (cd "$TEMP_DIR" && git clean -fdx &> /dev/null)
    fi
fi

# Remove write protection
echo "[INFO] Removing write protection..."
chmod -R u+w "$TEMP_DIR" 2>/dev/null

# Try to remove the directory
echo "[INFO] Removing monitor-temp directory..."
rm -rf "$TEMP_DIR" 2>/dev/null

# Check if removal was successful
if [ -d "$TEMP_DIR" ]; then
    echo "[ERROR] Failed to remove monitor-temp directory."
    echo "[ERROR] You may need to:"
    echo "  1. Close any programs using files in monitor-temp"
    echo "  2. Check file permissions"
    echo "  3. Try running with sudo: sudo $0"
    echo
    exit 1
fi

echo "[SUCCESS] monitor-temp directory removed successfully!"
echo
echo "Cleanup complete."
echo
exit 0
