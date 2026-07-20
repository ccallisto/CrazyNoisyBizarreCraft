@echo off
rem Updates the pack from git.
rem
rem   update.bat              double-clicked by a player, chatty, waits for a key
rem   update.bat --prelaunch  run by PrismLauncher before the game starts
rem
rem In --prelaunch mode this script must NEVER exit non-zero. Prism aborts the
rem launch on any non-zero exit from a pre-launch command, so a flaky network
rem would otherwise leave someone unable to start the game at all. Being one
rem update behind is a far smaller problem than being unable to play.
setlocal enabledelayedexpansion
cd /d "%~dp0"

set PRELAUNCH=0
if "%~1"=="--prelaunch" set PRELAUNCH=1

echo === Updating CrazyNoisyBizarreCraft ===
echo.

where git >nul 2>nul
if errorlevel 1 (
    set "MSG1=git is not installed."
    set "MSG2=Run setup.bat first."
    goto :give_up
)

rem Client config that belongs to you and your machine rather than to the pack:
rem video settings, shader choice, HUD layout, chat ping words. The game rewrites
rem these on every launch, so they are not tracked in git (see .gitignore). They
rem are copied aside here and put back afterwards, so updating never costs you
rem your settings.
set BACKUP=.update-personal-backup
if exist "%BACKUP%" rmdir /s /q "%BACKUP%"

set PERSONAL=^
minecraft/config/iris.properties ^
minecraft/config/iris-excluded.json ^
minecraft/config/sodium-options.json ^
minecraft/config/sodium-extra-options.json ^
minecraft/config/sodium-extra.properties ^
minecraft/config/sodium-fingerprint.json ^
minecraft/config/sodium-mixins.properties ^
minecraft/config/sodium-shadowy-path-blocks-options.json ^
minecraft/config/fabric/indigo-renderer.properties ^
minecraft/config/euphoria_patcher/.data.json ^
minecraft/config/sounds/chat.json ^
minecraft/config/constructionwand-client.toml ^
minecraft/config/jade

for %%f in (%PERSONAL%) do call :backup "%%f"
for %%s in (minecraft\shaderpacks\*.zip.txt) do call :backup "minecraft/shaderpacks/%%~nxs"

rem Drop local edits to those same paths so the update can never be blocked by
rem them. Safe, because the copies taken above are restored on every exit path.
for %%f in (%PERSONAL%) do git checkout -- "%%f" >nul 2>nul
git checkout -- minecraft/shaderpacks >nul 2>nul

git fetch origin
if errorlevel 1 (
    set "MSG1=Couldn't reach GitHub to check for updates."
    set "MSG2=Check your internet connection and try again."
    goto :give_up
)

rem merge rather than pull: "git pull --ff-only" still errors out for anyone who
rem has pull.rebase=true in their global git config, which some people do.
git merge --ff-only origin/main
if errorlevel 1 (
    set "MSG1=Update didn't apply cleanly ^(something local conflicts with it^)."
    set "MSG2=Ask for help before changing anything else, don't run git commands blind."
    goto :give_up
)

rem Settings go back before anything else that can fail, so a later problem can
rem never strand them in the backup folder.
call :restore_personal

git lfs pull
if errorlevel 1 (
    echo.
    echo Warning: couldn't download some large mod files.
    echo The rest of the update applied and your settings are intact.
    echo Run this again later to finish fetching them.
)

call :seed_defaults

rem Wire up automatic updating on launch, unless the player has set their own
rem pre-launch command. Only done in the interactive path: Prism reads
rem instance.cfg while launching, so --prelaunch must not rewrite it mid-launch.
if "%PRELAUNCH%"=="0" if exist instance.cfg (
    findstr /b /r /c:"PreLaunchCommand=..*" instance.cfg >nul 2>nul
    if errorlevel 1 (
        call :set_cfg OverrideCommands true
        call :set_cfg PreLaunchCommand "$INST_DIR\update.bat --prelaunch"
        call :set_cfg OverrideConsole true
        call :set_cfg LogPrePostOutput true
        call :set_cfg ShowConsole false
        call :set_cfg ShowConsoleOnError true
        echo.
        echo Automatic updates are now on: the pack refreshes itself each time
        echo you press Play, so you shouldn't need to run this by hand again.
    )
)

echo.
echo Pack updated! Restart PrismLauncher if it was already open.
if "%PRELAUNCH%"=="0" pause
exit /b 0

:give_up
call :restore_personal
call :seed_defaults
echo.
echo !MSG1!
if "%PRELAUNCH%"=="1" (
    echo Starting the game with the pack you already have.
    exit /b 0
)
echo !MSG2!
pause
exit /b 1

:restore_personal
if exist "%BACKUP%\minecraft" xcopy "%BACKUP%\minecraft" "minecraft" /e /i /q /y >nul
if exist "%BACKUP%" rmdir /s /q "%BACKUP%"
goto :eof

:seed_defaults
for /r "minecraft" %%e in (*.example) do (
    set "EX=%%e"
    set "TARGET=!EX:.example=!"
    if not exist "!TARGET!" copy "!EX!" "!TARGET!" >nul
)
if not exist instance.cfg if exist instance.cfg.example copy instance.cfg.example instance.cfg >nul
goto :eof

:set_cfg
rem Replace the "KEY=" line in instance.cfg, or add it if absent.
findstr /v /b /c:"%~1=" instance.cfg > instance.cfg.tmp
>>instance.cfg.tmp echo %~1=%~2
move /y instance.cfg.tmp instance.cfg >nul
goto :eof

:backup
set "SRC=%~1"
set "DST=%BACKUP%\%SRC:/=\%"
if exist "%SRC%\" (
    xcopy "%SRC%" "%DST%" /e /i /q /y >nul
) else if exist "%SRC%" (
    for %%p in ("%DST%") do if not exist "%%~dpp" mkdir "%%~dpp"
    copy "%SRC%" "%DST%" >nul
)
goto :eof
