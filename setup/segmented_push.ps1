# Get the directory of the script
$scriptDir = Split-Path -Parent $PSScriptRoot

# Change to the parent directory of the script
Set-Location $scriptDir

# Define the directory containing the files
$directory = Get-Location

# Initialize variables
$totalSize = 0
$filesToAdd = @()
$commitCount = 1
$maxSize = 2GB

# Function to commit and push files
function Commit-Files {
    param (
        [string[]]$files,
        [int]$commitNumber
    )
    if ($files.Count -gt 0) {
        Write-Host "Committing files for commit #$commitNumber"
        try {
            # Write the list of files to a temporary file
            $tempFile = [System.IO.Path]::GetTempFileName()
            [IO.File]::WriteAllLines($tempFile, $files)

            Write-Host "Temp file path: $tempFile"

            # Use git add with --pathspec-from-file
            git add -v --pathspec-from-file=$tempFile
            git commit -v -m "Commit #$commitNumber"
            # Remove the temporary file
            Remove-Item -Path $tempFile

            # Push the commit
            git push -v

            Write-Host "Successfully committed and pushed files for commit #$commitNumber"
        } catch {
            Write-Host "Error committing and pushing files for commit #$commitNumber : $_"
        }
    }
}

# Convert $maxSize to bytes for comparison
$maxSizeInBytes = [math]::Floor($maxSize / 1MB * 1024 * 1024)

# Get all untracked files in the directory and subdirectories
$untrackedFiles = git ls-files --others --exclude-standard

# Total number of untracked files for progress calculation
$totalFiles = $untrackedFiles.Count
$currentFileIndex = 0

foreach ($file in $untrackedFiles) {
    $currentFileIndex++
    Write-Progress -Activity "Processing files" -Status "Processing $currentFileIndex of $totalFiles" -PercentComplete (($currentFileIndex / $totalFiles) * 100)
    
    $fileInfo = Get-Item -Path $file
    $fileSize = $fileInfo.Length
    $totalSize += $fileSize
    $filesToAdd += $file

    if ($totalSize -ge $maxSizeInBytes) {
        Commit-Files -files $filesToAdd -commitNumber $commitCount
        $commitCount++
        $totalSize = 0
        $filesToAdd = @()
    }
}

# Commit any remaining files
Commit-Files -files $filesToAdd -commitNumber $commitCount

# Clear the progress bar
Write-Progress -Activity "Processing files" -Status "Complete" -PercentComplete 100 -Completed