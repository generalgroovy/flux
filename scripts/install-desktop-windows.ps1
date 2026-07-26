param(
  [string]$RepositoryDirectory = (Resolve-Path (Join-Path $PSScriptRoot "..")),
  [string]$Branch = $(if ($env:FLUX_BRANCH) { $env:FLUX_BRANCH } elseif ($env:DIFF_BRANCH) { $env:DIFF_BRANCH } else { (& git -C $RepositoryDirectory branch --show-current) })
)

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($Branch)) { throw "Cannot install from a detached Git checkout." }
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "FLUX Arena.lnk"
$launcherPath = Join-Path $RepositoryDirectory "scripts\pull-and-run.ps1"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$launcherPath`" -RepositoryDirectory `"$RepositoryDirectory`" -Branch `"$Branch`""
$shortcut.WorkingDirectory = $RepositoryDirectory
$shortcut.Description = "Update, verify, and launch FLUX"
$shortcut.Save()
Write-Host "Installed FLUX desktop launcher: $shortcutPath"
