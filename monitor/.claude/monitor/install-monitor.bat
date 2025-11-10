@echo off
REM One-click installer for Claude Code Context Monitor
REM This script handles: clone -> copy -> cleanup -> setup

setlocal enabledelayedexpansion

echo ================================================================================
echo   Claude Code Context Monitor - One-Click Installer
echo ================================================================================
echo.

REM Check if git is installed
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed or not in PATH.
    echo [ERROR] Please install Git from: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

REM Detect if we're running from inside monitor repo
REM If so, default to parent directory (where user originally was)
set "CURRENT_DIR=%CD%"
echo %CURRENT_DIR% | findstr /C:"monitor" >nul
if %errorlevel% equ 0 (
    REM We're inside monitor repo, use parent directory as default
    set "DEFAULT_TARGET=%CD%\.."
    set "DEFAULT_MSG=parent directory (where you ran git clone)"
) else (
    REM Normal case: use current directory
    set "DEFAULT_TARGET=%CD%"
    set "DEFAULT_MSG=current directory"
)

REM Check if we're already in a project with .claude
if exist ".claude" (
    echo [INFO] Found .claude directory in current location.
    echo [INFO] This appears to be a Claude Code project.
    echo.
    set "TARGET_DIR=%CD%"
) else (
    echo [INFO] No .claude directory found in current location.
    echo.
    set /p "TARGET_DIR=Enter target project path (or press Enter to use !DEFAULT_MSG!): "
    if "!TARGET_DIR!"=="" set "TARGET_DIR=!DEFAULT_TARGET!"
)

echo.
echo [INFO] Target directory: !TARGET_DIR!
echo.

REM Check if monitor-temp already exists
if exist "monitor-temp" (
    echo [WARNING] monitor-temp directory already exists.
    set /p "CLEANUP=Do you want to remove it and continue? (y/n): "
    if /i "!CLEANUP!"=="y" (
        echo [INFO] Removing existing monitor-temp...
        rd /s /q "monitor-temp" >nul 2>&1
        if exist "monitor-temp" (
            echo [ERROR] Failed to remove existing monitor-temp. Please remove it manually.
            pause
            exit /b 1
        )
    ) else (
        echo [INFO] Installation cancelled.
        pause
        exit /b 0
    )
)

echo [1/3] Cloning monitor tool from repository...
echo.
git clone --depth 1 https://github.com/gilltrick/monitor.git monitor-temp
if %errorlevel% neq 0 (
    echo [ERROR] Failed to clone repository.
    echo.
    pause
    exit /b 1
)

echo.
echo [2/3] Copying monitor to target directory...
echo.

REM Create .claude directory if it doesn't exist
if not exist "!TARGET_DIR!\.claude" (
    mkdir "!TARGET_DIR!\.claude"
    echo [INFO] Created .claude directory
)

REM Copy monitor directory
xcopy /E /I /Y "monitor-temp\monitor\.claude\monitor" "!TARGET_DIR!\.claude\monitor" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Failed to copy monitor files.
    pause
    exit /b 1
)

echo [SUCCESS] Monitor files copied successfully!

echo.
echo [3/3] Cleaning up monitor-temp directory...
echo.

REM Cleanup monitor-temp using the cleanup logic
attrib -r "monitor-temp\*.*" /s /d >nul 2>&1
cd monitor-temp >nul 2>&1
if exist ".git" (
    git gc --prune=now >nul 2>&1
    git clean -fdx >nul 2>&1
)
cd .. >nul 2>&1

rd /s /q "monitor-temp" >nul 2>&1
if exist "monitor-temp" (
    powershell -Command "Remove-Item -Path 'monitor-temp' -Recurse -Force -ErrorAction SilentlyContinue" >nul 2>&1
)

if exist "monitor-temp" (
    echo [WARNING] Could not fully remove monitor-temp. You may need to delete it manually.
) else (
    echo [SUCCESS] Cleanup complete!
)

echo.
echo ================================================================================
echo   Installation Complete!
echo ================================================================================
echo.
echo Monitor files have been installed to:
echo   !TARGET_DIR!\.claude\monitor
echo.
echo Next steps:
echo.
echo   1. Run setup to configure hooks:
echo      !TARGET_DIR!\.claude\monitor\setup-monitor.bat
echo.
echo   2. Start the monitor (in a separate terminal):
echo      !TARGET_DIR!\.claude\monitor\run-monitor.bat
echo.
echo   3. Start using Claude Code in your project!
echo.

REM Ask if user wants to run setup now
set /p "RUN_SETUP=Do you want to run setup now? (y/n): "
if /i "!RUN_SETUP!"=="y" (
    echo.
    echo Running setup...
    echo.
    call "!TARGET_DIR!\.claude\monitor\setup-monitor.bat"
)

echo.
pause
exit /b 0
