@echo off
setlocal enabledelayedexpansion

set "TRACKER_FILE=large_files.tracker"

rem Check if the tracker file exists
if not exist %TRACKER_FILE% (
    echo Tracker file does not exist. Exiting.
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

    rem Initialize the reassembled file in the root folder
    set "file=%cd%\!file_name!"
    echo Reassembling file "!file!" ...

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