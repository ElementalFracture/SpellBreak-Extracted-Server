@echo off
setlocal enabledelayedexpansion

rem Get the directory of the currently running script
set "SCRIPT_DIR=%~dp0"

REM Change to the parent directory of the script
cd /d %SCRIPT_DIR%..

rem Set the tracker file path relative to the script directory
set "TRACKER_FILE=large_files.tracker"

rem Check if the tracker file exists
if not exist "%TRACKER_FILE%" (
    echo Tracker file does not exist at %TRACKER_FILE%. Exiting.
    exit /b 1
)

rem Read each folder path from the tracker file and process it
for /f "tokens=*" %%a in (%TRACKER_FILE%) do (
    set "folder=%%a"
    echo Folder path from tracker file: !folder!

    rem Resolve the folder path to an absolute path
    for %%b in ("!folder!") do set "folder=%%~fb"
    echo Resolved folder path: !folder!

    rem Derive the file name by removing the _parts suffix
    set "file_name=%%~nxa"
    set "file_name=!file_name:_parts=!"
    echo Derived file name: !file_name!

    rem Initialize the reassembled file in the parent folder of the current folder
    for %%i in ("!folder!\..") do set "file=%%~fi\!file_name!"
    echo Reassembling file "!file!" ...

    rem Check if the folder exists
    if not exist "!folder!" (
        echo The folder "!folder!" does not exist. Skipping.
        exit /b 1
    )

    rem Concatenate all part files in the folder into the reassembled file
    (
        for /f "tokens=*" %%f in ('dir /b /a-d /on "!folder!\*"') do @echo "!folder!\%%f"
    ) > filelist.txt

    echo Contents of filelist.txt:
    type filelist.txt

    rem Use the copy command to concatenate the files
    set "filelist="
    for /f "tokens=*" %%f in (filelist.txt) do (
        set "filelist=!filelist!+%%f"
    )
    set "filelist=!filelist:~1!"

    echo Copying files: !filelist!
    copy /b !filelist! "!file!"

    rem Check if the reassembly was successful
    if not errorlevel 1 (
        echo File reassembled successfully: !file!
    ) else (
        echo Error reassembling file !file!
        exit /b 1
    )

    rem Mark all files in filelist.txt as unchanged in git
    if exist filelist.txt (
        for /f "delims=" %%f in (filelist.txt) do (
            pause
            git update-index --assume-unchanged "%%f"
            
        )
        echo Marked !folder! as unchanged in git.
        rmdir /s /q !folder!
        echo Deleted !folder!.
    ) else (
        echo filelist.txt not found.
    )

    rem Clean up
    del filelist.txt
)