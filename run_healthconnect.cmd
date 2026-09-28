@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_healthconnect.ps1"
set EXITCODE=%ERRORLEVEL%
echo.
if not "%EXITCODE%"=="0" (
    echo HealthConnect pipeline FAILED. Exit code: %EXITCODE%
) else (
    echo HealthConnect pipeline completed successfully.
)
exit /b %EXITCODE%
