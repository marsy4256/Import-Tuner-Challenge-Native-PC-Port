@echo off
REM ITC-Recomp - Import Tuner Challenge PC Port
REM Double-click this to launch the game

cd /d "%~dp0"

REM Game data path (relative to this folder)
set GAME_ROOT=%~dp0game

REM Check if game data exists
if not exist "%GAME_ROOT%\default.xex" (
    echo ERROR: Game data not found in the "game" subfolder.
    echo Please copy the Import Tuner Challenge game files to: %~dp0game
    echo Or edit GAME_ROOT in this batch file to point to your game folder.
    pause
    exit /b 1
)

echo Launching ITC-Recomp...
echo Game data: %GAME_ROOT%
echo.

.\bin\itc_recomp.exe --game_data_root "%GAME_ROOT%" --gpu_plugin=xenos --mnk_mode=true --keybind_right_trigger=E,O,W --keybind_left_trigger=Q,I,S

echo Game exited.