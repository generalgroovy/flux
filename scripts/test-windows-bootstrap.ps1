param(
    [string]$Installer = '',
    [string]$BaselineInstaller = ''
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'flux2-common.ps1')
$repoRoot = Get-FluxRepoRoot
$launcherTextFiles = @(
    (Join-Path $repoRoot 'packaging\PLAY-FLUX.cmd'),
    (Join-Path $repoRoot 'packaging\README-FIRST.txt'),
    (Join-Path $repoRoot 'packaging\windows-bootstrap\FluxBootstrap.cs')
)
foreach ($launcherTextFile in $launcherTextFiles) {
    $nonAscii = [System.IO.File]::ReadAllBytes($launcherTextFile) | Where-Object { $_ -gt 127 } | Select-Object -First 1
    if ($null -ne $nonAscii) {
        throw "Windows launcher source must stay ASCII-only to avoid code-page mojibake: $launcherTextFile"
    }
}
if (-not $Installer) { $Installer = Join-Path $repoRoot 'exports\release\FLUX2-Windows-Setup.exe' }
$Installer = [System.IO.Path]::GetFullPath($Installer)
if (-not (Test-Path -LiteralPath $Installer -PathType Leaf)) { throw "Missing installer: $Installer" }
if ($BaselineInstaller) {
    $BaselineInstaller = [System.IO.Path]::GetFullPath($BaselineInstaller)
    if (-not (Test-Path -LiteralPath $BaselineInstaller -PathType Leaf)) { throw "Missing baseline installer: $BaselineInstaller" }
    if ((Get-FluxFileSha256 $BaselineInstaller) -eq (Get-FluxFileSha256 $Installer)) {
        throw 'Baseline and current installers are identical; an update test requires two distinct payloads.'
    }
}

$testParent = [System.IO.Path]::GetFullPath((Join-Path $repoRoot '.godot\bootstrap-test'))
New-Item -ItemType Directory -Path $testParent -Force | Out-Null
$testRoot = [System.IO.Path]::GetFullPath((Join-Path $testParent ([guid]::NewGuid().ToString('N'))))
$safePrefix = $testParent.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $testRoot.StartsWith($safePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Unsafe bootstrap test root: $testRoot"
}
$installRoot = Join-Path $testRoot 'install'
New-Item -ItemType Directory -Path $testRoot -Force | Out-Null

try {
    $baselineVersion = ''
    if ($BaselineInstaller) {
        $baseline = Start-Process -FilePath $BaselineInstaller -ArgumentList @('--install-only', '--no-shortcuts', "--install-root=$installRoot") -PassThru -Wait
        if ($baseline.ExitCode -ne 0) { throw "Baseline installer run failed with exit code $($baseline.ExitCode)" }
        $baselineState = Join-Path $installRoot 'current.txt'
        if (-not (Test-Path -LiteralPath $baselineState -PathType Leaf)) { throw 'Baseline installer did not select a current version.' }
        $baselineVersion = (Get-Content -LiteralPath $baselineState | Select-Object -First 1).Trim()
        if (-not $baselineVersion) { throw 'Baseline installer wrote an empty current version.' }
    }

    $install = Start-Process -FilePath $Installer -ArgumentList @('--install-only', '--no-shortcuts', "--install-root=$installRoot") -PassThru -Wait
    if ($install.ExitCode -ne 0) { throw "Clean installer run failed with exit code $($install.ExitCode)" }

    $state = Join-Path $installRoot 'current.txt'
    if (-not (Test-Path -LiteralPath $state -PathType Leaf)) { throw 'Installer did not atomically select a current version.' }
    if (-not (Test-Path -LiteralPath (Join-Path $installRoot 'FLUX Launcher.exe') -PathType Leaf)) { throw 'Installer did not place the reusable per-user launcher.' }
    $version = (Get-Content -LiteralPath $state | Select-Object -First 1).Trim()
    if (-not $version) { throw 'Installer wrote an empty current version.' }
    if ($baselineVersion) {
        if ($version -eq $baselineVersion) { throw 'Current installer did not switch away from the baseline version.' }
        $retainedBaseline = Join-Path (Join-Path $installRoot 'versions') $baselineVersion
        if (-not (Test-Path -LiteralPath $retainedBaseline -PathType Container)) { throw 'Update removed the recoverable baseline version.' }
    }
    $versionRoot = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $installRoot 'versions') $version))
    $versionsPrefix = [System.IO.Path]::GetFullPath((Join-Path $installRoot 'versions')).TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $versionRoot.StartsWith($versionsPrefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Installer selected an unsafe version path.' }
    $game = Join-Path $versionRoot 'flux2.exe'
    $pack = Join-Path $versionRoot 'flux2.pck'
    foreach ($required in @($game, $pack, (Join-Path $versionRoot 'SHA256SUMS.txt'))) {
        if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Installed payload is incomplete: $required" }
    }

    $repair = Start-Process -FilePath $Installer -ArgumentList @('--install-only', '--no-shortcuts', '--repair', "--install-root=$installRoot") -PassThru -Wait
    if ($repair.ExitCode -ne 0) { throw "Repair run failed with exit code $($repair.ExitCode)" }

    $boot = Start-Process -FilePath $game -ArgumentList @('--headless', '--quit-after', '3', '--fixed-fps', '120', '--', '--tick-rate=120') -WorkingDirectory $versionRoot -PassThru -Wait
    if ($boot.ExitCode -ne 0) { throw "Installed game boot failed with exit code $($boot.ExitCode)" }

    $journey = if ($baselineVersion) { "baseline update ($baselineVersion -> $version), repair" } else { 'clean install, repair' }
    Write-Output "PASS: $journey and installed export boot"
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        $resolved = [System.IO.Path]::GetFullPath($testRoot)
        if (-not $resolved.StartsWith($safePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to clean unsafe bootstrap test root: $resolved"
        }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
