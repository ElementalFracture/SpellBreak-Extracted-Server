@echo off
setlocal

rem Get the directory of the currently running script
set "SCRIPT_DIR=%~dp0"

REM Change to the parent directory of the script
cd /d %SCRIPT_DIR%..

set "PARENT_DIR=%SCRIPT_DIR%.."

REM Define source and destination directories relative to the parent directory
set "SOURCE_DIR=%PARENT_DIR%\setup\hooks"
set "DEST_DIR=%PARENT_DIR%\.git\hooks"

REM Check if the source directory exists
if not exist "%SOURCE_DIR%" (
    echo Source directory "%SOURCE_DIR%" does not exist.
    goto :eof
)

REM Check if the destination directory exists
if not exist "%DEST_DIR%" (
    echo Destination directory "%DEST_DIR%" does not exist.
    goto :eof
)

REM Copy files from source to destination
xcopy "%SOURCE_DIR%\*" "%DEST_DIR%\" /Y

echo Files copied from "%SOURCE_DIR%" to "%DEST_DIR%".

:end
endlocal