@echo off
setlocal EnableExtensions
title TravelMate - Local App
rem Fresh Git clones use app/.env.example to set up the shared catalog automatically.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\run-app.ps1" %*
set "TRAVELMATE_EXIT=%ERRORLEVEL%"
if not "%TRAVELMATE_EXIT%"=="0" (
    echo.
    echo TravelMate could not start. Review the message above.
    if /i not "%~1"=="-Check" pause
)
exit /b %TRAVELMATE_EXIT%
