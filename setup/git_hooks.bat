@echo off
setlocal

REM Define source and destination directories
set "SOURCE_DIR=hooks"
set "DEST_DIR=.git\hooks"

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