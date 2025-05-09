<#
.SYNOPSIS
Symlinks RetroArch configuration files.

.DESCRIPTION
This script creates symbolic links for RetroArch configuration files from `../retroarch` to a
RetroArch installation. If destination folders don't exist, they will be created. If a file exists,
it will be renamed to <filename>.bak before creating the symlink. Existing symlinks will be replaced.

.NOTES
Creating symlinks requires an elevated shell or developer mode.

.EXAMPLE
.\install.ps1 C:\RetroArch
#>

# Support -WhatIf
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    # Require the path to the destination
    [Alias("FullName", "PSPath")]
    [Parameter(
        Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true
    )]
    [String[]]$Path,

    [Alias("q")]
    [Parameter()]
    [Switch]$Quiet
)

Begin {
    # Terminate on error
    $ErrorActionPreference = 'Stop'

    # Silence output if quiet
    function Out-NullQuiet {
        [CmdletBinding()]
        param(
            [Parameter(ValueFromPipeline=$true)]
            [Object]$InputObject
        )
        Process {
            if ($Script:Quiet) {
                $InputObject | Out-Null
            } else {
                $InputObject
            }
        }
    }

    # Create a symbolic link with backup
    function New-SymlinkWithBackup {
        [CmdletBinding(SupportsShouldProcess=$true)]
        param(
            [Parameter(Position=0)]
            [String]$Source,

            [Parameter(Position=1)]
            [String]$Destination
        )

        # Create parent directory if it doesn't exist
        $parentDir = Split-Path -Parent $Destination
        if (-not (Test-Path $parentDir)) {
            if ($PSCmdlet.ShouldProcess($parentDir, "Create directory")) {
                New-Item $parentDir -ItemType Directory | Out-NullQuiet
            }
        }

        # Backup if the destination exists and is not a symlink
        if (Test-Path $Destination) {
            if (-not (Get-Item $Destination).LinkType) {
                if ($PSCmdlet.ShouldProcess($Destination, "Backup existing file")) {
                    # Pass through to show the renamed file in the output
                    Move-Item $Destination "$Destination.bak" -Force -PassThru | Out-NullQuiet
                }
            }
        }

        # Create symlink if it doesn't exist
        if (-not (Get-Item $Destination -ErrorAction SilentlyContinue).LinkType) {
            if ($PSCmdlet.ShouldProcess($Destination, "Create symbolic link")) {
                New-Item $Destination -Force -Target $Source -ItemType SymbolicLink | Out-NullQuiet
            }
        }
    }
}

Process {
    foreach ($dest in $Path) {
        # Base paths
        $srcDir = Resolve-Path (Join-Path $PSScriptRoot "..\retroarch")
        $destDir = Resolve-Path $dest

        # Link main config
        $srcConfigFile = Join-Path $srcDir "retroarch.cfg"
        $destConfigFile = Join-Path $destDir "retroarch.cfg"
        New-SymlinkWithBackup $srcConfigFile $destConfigFile

        # Link subfolders
        $folders = Get-ChildItem $srcDir -Directory | Select-Object -ExpandProperty Name
        foreach ($folder in $folders) {
            $srcFolder = Join-Path $srcDir $folder
            $destFolder = Join-Path $destDir $folder
            Get-ChildItem $srcFolder -File -Recurse | ForEach-Object {
                $srcPath = $_.FullName
                $destPath = Resolve-Path $srcPath -Relative -RelativeBasePath $srcFolder
                $destPath = Join-Path $destFolder $destPath.TrimStart('.', '/', '\')
                New-SymlinkWithBackup $srcPath $destPath
            }
        }
    }
}
