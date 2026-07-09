@echo off
setlocal enabledelayedexpansion

set REPO_URL=https://github.com/ccallisto/CrazyNoisyBizarreCraft.git
set INSTANCE_NAME=CrazyNoisyBizarreCraft

echo === CrazyNoisyBizarreCraft pack setup ===
echo.

where git >nul 2>nul
if errorlevel 1 (
    echo git is not installed. Download it from https://git-scm.com/download/win
    echo During install, make sure "Git LFS" is checked ^(or install separately from https://git-lfs.com^)
    pause
    exit /b 1
)

git lfs version >nul 2>nul
if errorlevel 1 (
    echo git-lfs is not installed. Get it from https://git-lfs.com then run this again.
    pause
    exit /b 1
)

set TARGET_DIR=%APPDATA%\PrismLauncher\instances
if not exist "%TARGET_DIR%" (
    echo Couldn't auto-find your PrismLauncher instances folder.
    echo ^(In PrismLauncher: Settings -^> the folder icon next to "Instance Dir" shows the path.^)
    set /p TARGET_DIR="Paste the full path to it: "
)

set DEST=%TARGET_DIR%\%INSTANCE_NAME%

if exist "%DEST%" (
    echo.
    echo A folder already exists at: %DEST%
    echo If you're trying to get updates, run update.bat inside that folder instead.
    pause
    exit /b 1
)

echo.
echo Cloning pack into: %DEST%
git clone %REPO_URL% "%DEST%"
if errorlevel 1 (
    echo Clone failed - check the error above.
    pause
    exit /b 1
)

cd /d "%DEST%"
git lfs pull

if not exist instance.cfg (
    copy instance.cfg.example instance.cfg >nul
)

echo.
echo Done! Open PrismLauncher - the instance should appear automatically.
echo If it doesn't, restart PrismLauncher.
pause
