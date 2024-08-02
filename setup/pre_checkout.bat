@echo off
setlocal

set "TRACKER_FILE=large_files.tracker"

REM Check if the tracker file exists
if exist "%TRACKER_FILE%" (
    for /f "usebackq delims=" %%A in ("%TRACKER_FILE%") do (
        set "parts_file=%%A"
        call :process_file
    )
)

goto :eof

:process_file
REM Extract the base file name by removing the _parts suffix
set "base_file=%parts_file:_parts=%"

REM Check if the base file exists and delete it
if exist "%base_file%" (
    del /f "%base_file%"
    echo Deleted file: %base_file%
)
goto :eof