<#
.SYNOPSIS
Mirrors the contents of a source directory to a destination directory.

.DESCRIPTION
This script uses Robocopy to mirror a source directory to a destination directory:
- Files and folders in the source that are not in the destination will be copied.
- Files and folders in the destination that are not in the source will be deleted.
- Files that are different will be updated from the source.

.PARAMETER SourcePath
The path to the source directory. This path must exist.

.PARAMETER DestinationPath
The path to the destination directory. If it does not exist, Robocopy will attempt to create it.

.EXAMPLE
.\mirror.ps1 -SourcePath D:\roms -DestinationPath C:\retroarch-win64\downloads

.NOTES
Robocopy was added in Windows Vista.
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$SourcePath,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$DestinationPath
)

Begin {
    # Terminate on error
    $ErrorActionPreference = 'Stop'

    # Resolve source path to ensure it is absolute and exists
    $ResolvedSourcePath = Resolve-Path -Path $SourcePath
}

Process {
    $robocopyArgs = @(
        "$ResolvedSourcePath",
        "$DestinationPath",
        "/MIR", # Mirror the directory (copy AND delete)
        "/R:0", # No retries
        "/NJH", # No job header
        "/NJS", # No job summary
        "/NP"   # No progress
    )

    # List only (aka dry run)
    if ($WhatIfPreference) {
        $robocopyArgs += "/L"
    }

    # Robocopy exit codes 0-7 are success
    robocopy @robocopyArgs
}
