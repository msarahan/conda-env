@echo off

for /f "delims=" %%i in ("%~dp0..\envs") do (
    set "ANACONDA_ENVS=%%~fi"
)

if "%1" == "" goto skipmissingarg
    echo Usage: deactivate
    echo.
    echo Deactivates previously activated Conda
    echo environment.
    exit /b 1
:skipmissingarg


REM Deactivate a previous activation if it is live
if "%CONDA_DEFAULT_ENV%" == "" goto skipdeactivate
    REM This search/replace removes the previous env from the path
    echo Deactivating environment "%CONDA_DEFAULT_ENV%"...

    REM Run any deactivate scripts
    if not exist "%CONDA_DEFAULT_ENV%\etc\conda\deactivate.d" goto nodeactivate
        pushd "%CONDA_DEFAULT_ENV%\etc\conda\deactivate.d"
        for %%g in (*.bat) do call "%%g"
        popd
    :nodeactivate

    set "CONDACTIVATE_PATH=%CONDA_DEFAULT_ENV%;%CONDA_DEFAULT_ENV%\Scripts;%CONDA_DEFAULT_ENV%\Library\bin;"
    call set "PATH=%%PATH:%CONDACTIVATE_PATH%=%%"
    set CONDA_DEFAULT_ENV=
    set CONDA_ENV_PATH=
    set CONDACTIVATE_PATH=
:skipdeactivate

REM Make sure that root's Scripts dir is on PATH, for sake of keeping activate/deactivate available.
call set "PATH_NO_SCRIPTS=%%PATH:%~dp0;=%%"
if "%PATH_NO_SCRIPTS%"=="%PATH%" set "PATH=%PATH%;%~dp0;"

set "PROMPT=%CONDA_OLD_PROMPT%"
set CONDA_OLD_PROMPT=
