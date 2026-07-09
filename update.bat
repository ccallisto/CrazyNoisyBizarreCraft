@echo off
cd /d "%~dp0"

echo === Updating CrazyNoisyBizarreCraft ===
echo.

where git >nul 2>nul
if errorlevel 1 (
    echo git is not installed. Run setup.bat first.
    pause
    exit /b 1
)

git fetch origin

git pull --ff-only origin main
if errorlevel 1 (
    echo.
    echo Update didn't apply cleanly ^(local changes conflict with the update^).
    echo Ask for help before changing anything else - don't run git commands blind.
    pause
    exit /b 1
)

git lfs pull

if not exist instance.cfg (
    copy instance.cfg.example instance.cfg >nul
)

echo.
echo Pack updated! Restart PrismLauncher if it was already open.
pause
