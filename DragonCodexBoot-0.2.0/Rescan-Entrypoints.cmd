@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\integrate-entrypoints.ps1" -Action Install -AppRoot "%~dp0."
echo.
pause
