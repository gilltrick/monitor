@echo off
REM Cleanup script to safely remove monitor-temp folder after monitor installation
REM This script handles git objects and locked files properly

setlocal enabledelayedexpansion

echo ================================================================================
echo   Monitor Tool Cleanup Utility
echo ================================================================================
echo.

REM Check if monitor-temp directory exists
if not exist "monitor-temp" (
    echo [INFO] No monitor-temp directory found. Nothing to clean up.
    echo.
    pause
    exit /b 0
)

echo [INFO] Found monitor-temp directory.
echo.

REM Option to remove read-only attributes from all files
echo Removing read-only attributes from all files...
attrib -r "monitor-temp\*.*" /s /d >nul 2>&1

REM If git is available, try to clean git objects first
where git >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Git found. Cleaning git repository...
    cd monitor-temp >nul 2>&1
    if exist ".git" (
        git gc --prune=now >nul 2>&1
        git clean -fdx >nul 2>&1
    )
    cd .. >nul 2>&1
)

REM Try to remove the directory
echo [INFO] Removing monitor-temp directory...
rd /s /q "monitor-temp" >nul 2>&1

REM Check if removal was successful
if exist "monitor-temp" (
    echo [WARNING] Standard removal failed. Attempting force removal...

    REM Force remove using rmdir with multiple attempts
    for /l %%i in (1,1,3) do (
        rd /s /q "monitor-temp" >nul 2>&1
        if not exist "monitor-temp" goto :success
        timeout /t 1 /nobreak >nul 2>&1
    )

    REM If still exists, try PowerShell removal
    where powershell >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] Using PowerShell for removal...
        powershell -Command "Remove-Item -Path 'monitor-temp' -Recurse -Force -ErrorAction SilentlyContinue" >nul 2>&1
    )

    REM Final check
    if exist "monitor-temp" (
        echo [ERROR] Failed to remove monitor-temp directory.
        echo [ERROR] You may need to:
        echo   1. Close any programs using files in monitor-temp
        echo   2. Manually delete the directory
        echo   3. Run this script as administrator
        echo.
        pause
        exit /b 1
    )
)

:success
echo [SUCCESS] monitor-temp directory removed successfully!
echo.
echo Cleanup complete.
echo.
pause
exit /b 0
