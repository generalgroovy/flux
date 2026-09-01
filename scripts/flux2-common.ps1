Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-FluxRepoRoot {
    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
}

function Get-FluxFileSha256([string]$Path) {
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "Cannot hash missing file: $fullPath"
    }
    $stream = [System.IO.File]::OpenRead($fullPath)
    try {
        $algorithm = [System.Security.Cryptography.SHA256]::Create()
        try {
            $bytes = $algorithm.ComputeHash($stream)
            return ([System.BitConverter]::ToString($bytes)).Replace('-', '').ToLowerInvariant()
        }
        finally {
            $algorithm.Dispose()
        }
    }
    finally {
        $stream.Dispose()
    }
}

function Get-FluxGodot {
    if ($env:FLUX2_GODOT_BIN) {
        $candidate = [System.IO.Path]::GetFullPath($env:FLUX2_GODOT_BIN)
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
        throw "FLUX2_GODOT_BIN does not name a file: $candidate"
    }
    $bundled = Join-Path $env:LOCALAPPDATA 'FLUX-dev\godot-4.7.1\Godot_v4.7.1-stable_win64.exe'
    if (Test-Path -LiteralPath $bundled -PathType Leaf) { return $bundled }
    foreach ($commandName in @('godot4', 'godot')) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
    }
    throw 'Godot 4.7.1 is missing. Set FLUX2_GODOT_BIN or install the pinned engine.'
}

function Assert-FluxGodotVersion([string]$GodotBin) {
    $actual = (& $GodotBin --version | Select-Object -First 1).Trim()
    $expected = '4.7.1.stable.official.a13da4feb'
    if ($actual -ne $expected) { throw "Expected Godot $expected, found $actual" }
    return $actual
}

function Invoke-FluxGodotChecked {
    param(
        [string]$GodotBin,
        [string[]]$Arguments,
        [string]$LogPath,
        [switch]$RejectWarnings
    )
    $errorPath = "$LogPath.err"
    foreach ($path in @($LogPath, $errorPath)) {
        if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
    }
    # Start-Process joins ArgumentList values into one command line on Windows.
    # Quote every value so clones living below a path with spaces remain valid.
    $quotedArguments = $Arguments | ForEach-Object { '"' + $_.Replace('"', '\"') + '"' }
    $process = Start-Process -FilePath $GodotBin -ArgumentList $quotedArguments -RedirectStandardOutput $LogPath -RedirectStandardError $errorPath -WindowStyle Hidden -PassThru -Wait
    $combined = @()
    if (Test-Path -LiteralPath $LogPath) { $combined += Get-Content -LiteralPath $LogPath }
    if (Test-Path -LiteralPath $errorPath) { $combined += Get-Content -LiteralPath $errorPath }
    $combined | Write-Output
    if ($process.ExitCode -ne 0) { throw "Godot exited with code $($process.ExitCode)" }
    $bad = $combined | Select-String -Pattern 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Invalid call'
    if ($bad) { throw 'Godot emitted a script/import/runtime error.' }
    if ($RejectWarnings) {
        $warnings = $combined | Select-String -Pattern '^(WARNING|ERROR):'
        if ($warnings) { throw "Godot emitted $($warnings.Count) unexpected warning/error line(s)." }
    }
}

function Get-FluxTickRate([int]$Requested) {
    if ($Requested -ne 120) { throw 'TickRate must be 120.' }
    return $Requested
}

function Get-FluxExportTemplateRoot {
    if ($env:GODOT_EXPORT_TEMPLATE_ROOT) {
        return [System.IO.Path]::GetFullPath($env:GODOT_EXPORT_TEMPLATE_ROOT)
    }
    return Join-Path $env:APPDATA 'Godot\export_templates\4.7.1.stable'
}

function Assert-FluxExportTemplates([string]$Target) {
    $templateRoot = Get-FluxExportTemplateRoot
    $required = @()
    if ($Target -in @('Windows', 'All')) { $required += 'windows_release_x86_64.exe' }
    if ($Target -in @('Linux', 'All')) { $required += 'linux_release.x86_64' }
    $missing = @($required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $templateRoot $_) -PathType Leaf) })
    if ($missing.Count -gt 0) {
        throw "Godot 4.7.1 $Target release templates are missing at $templateRoot ($($missing -join ', ')). Open the pinned editor, choose Editor > Manage Export Templates, install 4.7.1.stable once, then rerun."
    }
    return $templateRoot
}
