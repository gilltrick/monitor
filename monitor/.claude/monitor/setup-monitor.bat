@echo off
REM Setup script for Claude Code Context Monitor
REM This script configures hooks in .claude/settings.json

echo ================================================================================
echo   Claude Code Context Monitor - Setup
echo ================================================================================
echo.

REM Find project root (where .claude directory is located)
set "PROJECT_ROOT=%CD%"
set "MONITOR_DIR=%~dp0"
set "MONITOR_DIR=%MONITOR_DIR:~0,-1%"

REM Remove the .claude\monitor part to get project root
for %%I in ("%MONITOR_DIR%\..\..") do set "PROJECT_ROOT=%%~fI"


echo Project Root:  %PROJECT_ROOT%
echo Monitor Dir:   %MONITOR_DIR%
echo.

REM Convert backslashes to forward slashes for JSON
set "MONITOR_DIR_JSON=%MONITOR_DIR:\=/%"

REM Check if .claude directory exists
if not exist "%PROJECT_ROOT%\.claude" (
    echo Creating .claude directory
    mkdir "%PROJECT_ROOT%\.claude"
)

REM Check if settings.json already exists
set "SETTINGS_FILE=%PROJECT_ROOT%\.claude\settings.json"
set "choice="
if exist "%SETTINGS_FILE%" (
    echo.
    echo WARNING: %SETTINGS_FILE% already exists.
    echo.
    echo Do you want to:
    echo   [1] Update/merge hooks (recommended)
    echo   [2] Overwrite completely
    echo   [3] Cancel
    echo.
    set /p "choice=Enter choice (1-3): "
)

REM Handle choice outside the if block
if "%choice%"=="3" (
    echo.
    echo Setup cancelled.
    exit /b 0
)

if "%choice%"=="2" (
    echo.
    echo Overwriting settings.json
) else if not "%choice%"=="" (
    echo.
    echo Merging hooks (not implemented yet - will overwrite)
)

REM Create settings.json with hook configuration
echo Creating/updating settings.json

REM Build the command path with proper JSON escaping
set "CMD_PATH=%MONITOR_DIR_JSON%/context_hook.bat"

REM Write JSON file line by line
echo {> "%SETTINGS_FILE%"
echo   "hooks": {>> "%SETTINGS_FILE%"
echo     "PostToolUse": [>> "%SETTINGS_FILE%"
echo       {>> "%SETTINGS_FILE%"
echo         "matcher": "*",>> "%SETTINGS_FILE%"
echo         "hooks": [>> "%SETTINGS_FILE%"
echo           {>> "%SETTINGS_FILE%"
echo             "type": "command",>> "%SETTINGS_FILE%"
echo             "command": "%CMD_PATH%">> "%SETTINGS_FILE%"
echo             "timeout": 5>> "%SETTINGS_FILE%"
echo           }>> "%SETTINGS_FILE%"
echo         ]>> "%SETTINGS_FILE%"
echo       }>> "%SETTINGS_FILE%"
echo     ],>> "%SETTINGS_FILE%"
echo     "UserPromptSubmit": [>> "%SETTINGS_FILE%"
echo       {>> "%SETTINGS_FILE%"
echo         "matcher": "*",>> "%SETTINGS_FILE%"
echo         "hooks": [>> "%SETTINGS_FILE%"
echo           {>> "%SETTINGS_FILE%"
echo             "type": "command",>> "%SETTINGS_FILE%"
echo             "command": "%CMD_PATH%">> "%SETTINGS_FILE%"
echo             "timeout": 5>> "%SETTINGS_FILE%"
echo           }>> "%SETTINGS_FILE%"
echo         ]>> "%SETTINGS_FILE%"
echo       }>> "%SETTINGS_FILE%"
echo     ],>> "%SETTINGS_FILE%"
echo     "SessionStart": [>> "%SETTINGS_FILE%"
echo       {>> "%SETTINGS_FILE%"
echo         "matcher": "*",>> "%SETTINGS_FILE%"
echo         "hooks": [>> "%SETTINGS_FILE%"
echo           {>> "%SETTINGS_FILE%"
echo             "type": "command",>> "%SETTINGS_FILE%"
echo             "command": "%CMD_PATH%">> "%SETTINGS_FILE%"
echo             "timeout": 5>> "%SETTINGS_FILE%"
echo           }>> "%SETTINGS_FILE%"
echo         ]>> "%SETTINGS_FILE%"
echo       }>> "%SETTINGS_FILE%"
echo     ],>> "%SETTINGS_FILE%"
echo     "Stop": [>> "%SETTINGS_FILE%"
echo       {>> "%SETTINGS_FILE%"
echo         "matcher": "*",>> "%SETTINGS_FILE%"
echo         "hooks": [>> "%SETTINGS_FILE%"
echo           {>> "%SETTINGS_FILE%"
echo             "type": "command",>> "%SETTINGS_FILE%"
echo             "command": "%CMD_PATH%">> "%SETTINGS_FILE%"
echo             "timeout": 5>> "%SETTINGS_FILE%"
echo           }>> "%SETTINGS_FILE%"
echo         ]>> "%SETTINGS_FILE%"
echo       }>> "%SETTINGS_FILE%"
echo     ]>> "%SETTINGS_FILE%"
echo   }>> "%SETTINGS_FILE%"
echo }>> "%SETTINGS_FILE%"

echo.
echo ================================================================================
echo   Setup Complete!
echo ================================================================================
echo.
echo Configuration saved to: %SETTINGS_FILE%
echo.
echo NEXT STEPS:
echo   1. Start a NEW Claude Code session (hooks only work in new sessions)
echo   2. Run the monitor: .claude\monitor\run-monitor.bat
echo   3. Use Claude Code normally - the monitor will update in real-time
echo.
echo To disable the monitor, delete or edit .claude\settings.json
echo ================================================================================
pause
