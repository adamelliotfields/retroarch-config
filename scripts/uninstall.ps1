<#
.SYNOPSIS
Reverts `install.ps1`.

.DESCRIPTION
This script restores backup files, removes symbolic links, and purges empty directories created by
the `install.ps1` script.

.NOTES
Removing symlinks requires an elevated shell or developer mode.

.EXAMPLE
.\uninstall.ps1 C:\RetroArch
#>

# Support -WhatIf
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    # Require the path to the destination
    [Parameter(Position=0, Mandatory=$true)]
    [String]$Path
)

# Remove a symbolic link and restore backup if it exists
function Remove-SymlinkAndRestoreBackup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Position=0)]
        [String]$LinkPath
    )

    # Check if path exists and is a symlink
    if (Test-Path $LinkPath) {
        $item = Get-Item $LinkPath
        if ($item.LinkType -eq "SymbolicLink") {
            if ($PSCmdlet.ShouldProcess($LinkPath, "Remove symbolic link")) {
                Remove-Item $LinkPath -Force
            }
        }
    }

    # Check if backup exists
    $backupPath = "$LinkPath.bak"
    if (Test-Path $backupPath) {
        if ($PSCmdlet.ShouldProcess($backupPath, "Restore backup file")) {
            Move-Item $backupPath $LinkPath -Force
        }
    }
}

# Remove a directory if empty
function Remove-EmptyDirectory {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Position=0)]
        [String]$DirPath
    )

    # Check if directory exists
    if (Test-Path $DirPath) {
        # Check if directory is empty
        if (-not (Get-ChildItem $DirPath -Force -Recurse)) {
            if ($PSCmdlet.ShouldProcess($DirPath, "Remove empty directory")) {
                Remove-Item $DirPath -Force -Recurse
            }
        }
    }
}

# Terminate on error
$ErrorActionPreference = 'Stop'

# Base paths
$srcDir = Resolve-Path (Join-Path $PSScriptRoot "..\retroarch")
$destDir = Resolve-Path $Path

# Remove the main config symlink
$configFile = Join-Path $destDir "retroarch.cfg"
if (Test-Path $configFile) {
    $item = Get-Item $configFile -ErrorAction SilentlyContinue
    if ($item.LinkType -eq "SymbolicLink") {
        if ($PSCmdlet.ShouldProcess($configFile, "Remove symbolic link")) {
            Remove-Item $configFile -Force
        }
    }
}

# Restore the main config backup
$configFileBackup = Join-Path $destDir "retroarch.cfg.bak"
if (Test-Path $configFileBackup) {
    if ($PSCmdlet.ShouldProcess($configFileBackup, "Restore backup config file")) {
        Move-Item $configFileBackup (Join-Path $destDir "retroarch.cfg") -Force
    }
}

# Restore subfolders
$folders = Get-ChildItem $srcDir -Directory | Select-Object -ExpandProperty Name
foreach ($folder in $folders) {
    $srcFolder = Join-Path $srcDir $folder
    $destFolder = Join-Path $destDir $folder
    if (Test-Path $destFolder) {
        Get-ChildItem $destFolder -File -Recurse | ForEach-Object {
            Remove-SymlinkAndRestoreBackup $_.FullName
        }
        Get-ChildItem $srcFolder -Directory | ForEach-Object {
            Remove-EmptyDirectory (Join-Path $destFolder $_.Name)
        }
    }
}
