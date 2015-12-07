@echo off
REM Check for CONDA_ENVS_PATH environment variable
REM It it doesn't exist, look inside the Anaconda install tree
IF "%CONDA_ENVS_PATH%" == "" (
    REM turn relative path into absolute path
    FOR /F %%i IN ("%~dp0..\envs") DO SET "CONDA_ENVS_PATH=%~dp0..\envs"
)

set "CONDA_NEW_NAME=%~1"

IF "%~2" == "" GOTO skiptoomanyargs
    ECHO ERROR: Too many arguments provided
    GOTO usage
:skiptoomanyargs

IF "%CONDA_NEW_NAME%" == "" set "CONDA_NEW_NAME=%~dp0..\"

REM Search through paths in CONDA_ENVS_PATH
REM First match will be the one used

FOR %%F IN ("%CONDA_ENVS_PATH:;=" "%") DO (
    IF EXIST "%%~F\%CONDA_NEW_NAME%\conda-meta" (
       SET "CONDA_NEW_PATH=%%~F\%CONDA_NEW_NAME%"
       GOTO found_env
    )
)

IF EXIST "%CONDA_NEW_NAME%\conda-meta" (
    SET "CONDA_NEW_PATH=%CONDA_NEW_NAME%"
    ) ELSE (
    ECHO No environment named "%CONDA_NEW_NAME%" exists in %CONDA_ENVS_PATH%, or is not a valid conda installation directory.
    SET CONDA_NEW_NAME=
    SET CONDA_NEW_PATH=
    EXIT /b 1
)

:found_env

FOR /F "tokens=* delims=\" %%i IN ("%CONDA_NEW_PATH%") DO SET "CONDA_NEW_NAME=%%~ni"

REM Deactivate a previous activation if it is live
IF "%CONDA_DEFAULT_ENV%" == "" GOTO skipdeactivate
    REM This search/replace removes the previous env from the path
    ECHO Deactivating environment "%CONDA_DEFAULT_ENV%"...

    REM Run any deactivate scripts
    IF NOT EXIST "%CONDA_DEFAULT_ENV%\etc\conda\deactivate.d" GOTO nodeactivate
        PUSHD "%CONDA_DEFAULT_ENV%\etc\conda\deactivate.d"
        FOR %%g IN (*.bat) DO CALL "%%g"
        POPD
    :nodeactivate

    SET "CONDACTIVATE_PATH=%CONDA_DEFAULT_ENV%;%CONDA_DEFAULT_ENV%\Scripts;%CONDA_DEFAULT_ENV%\Library\bin;"
    CALL SET "PATH=%%PATH:%CONDACTIVATE_PATH%=%%"
    SET CONDA_DEFAULT_ENV=
    SET CONDACTIVATE_PATH=
    SET "PROMPT=%CONDA_OLD_PROMPT%"
    SET CONDA_OLD_PROMPT=
:skipdeactivate

CALL :NORMALIZEPATH CONDA_DEFAULT_ENV "%CONDA_NEW_PATH%"

ECHO Activating environment "%CONDA_DEFAULT_ENV%"...
SET "PATH=%CONDA_DEFAULT_ENV%;%CONDA_DEFAULT_ENV%\Scripts;%CONDA_DEFAULT_ENV%\Library\bin;%PATH%"
IF "%CONDA_NEW_NAME%"=="" (
   REM Clear CONDA_DEFAULT_ENV so that this is truly a "root" environment, not an environment pointed at root
   SET CONDA_DEFAULT_ENV=
   ) ELSE (
   SET "CONDA_OLD_PROMPT=%PROMPT%"
   SET "PROMPT=[%CONDA_NEW_NAME%] %PROMPT%"
)
SET CONDA_NEW_NAME=
SET CONDA_NEW_PATH=

REM Make sure that root's Scripts dir is on PATH, for sake of keeping activate/deactivate available.
CALL SET "PATH_NO_SCRIPTS=%%PATH:%~dp0;=%%"
IF "%PATH_NO_SCRIPTS%"=="%PATH%" SET "PATH=%PATH%;%~dp0;"

REM Run any activate scripts
IF NOT EXIST "%CONDA_DEFAULT_ENV%\etc\conda\activate.d" GOTO noactivate
    PUSHD "%CONDA_DEFAULT_ENV%\etc\conda\activate.d"
    FOR %%g IN (*.bat) DO CALL "%%g"
    POPD
:noactivate

EXIT /B

:NORMALIZEPATH
    SET "%1=%~dpfn2"
    EXIT /B
