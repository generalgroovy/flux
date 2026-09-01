param(
    [ValidateSet('Fast', 'Full', 'Release')][string]$Tier = 'Full',
    [switch]$SkipFullSuite
)
. (Join-Path $PSScriptRoot 'flux2-common.ps1')

if ($SkipFullSuite) {
    $Tier = 'Fast'
}

$repoRoot = Get-FluxRepoRoot
$godotBin = Get-FluxGodot
$logRoot = Join-Path $repoRoot '.godot\windows-tests'
New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
$importLog = Join-Path $logRoot 'import.log'
$suiteLog = Join-Path $logRoot 'suite.log'
$bootLog = Join-Path $logRoot 'boot-120.log'
$executedLogs = [System.Collections.Generic.List[string]]::new()
$executedLogs.Add($importLog)
$executedLogs.Add($bootLog)
if ($Tier -ne 'Fast') { $executedLogs.Add($suiteLog) }
$clock = [System.Diagnostics.Stopwatch]::StartNew()
try {
    & (Join-Path $PSScriptRoot 'doctor.ps1') -RequireExportTemplates:($Tier -eq 'Release') -ExportTarget Windows
    Invoke-FluxGodotChecked $godotBin @('--headless', '--editor', '--path', $repoRoot, '--quit') $importLog -RejectWarnings
    if ($Tier -ne 'Fast') {
        Invoke-FluxGodotChecked $godotBin @('--headless', '--path', $repoRoot, '--script', 'res://tests/run_all.gd') $suiteLog -RejectWarnings
    }
    Invoke-FluxGodotChecked $godotBin @('--headless', '--path', $repoRoot, '--quit-after', '3', '--fixed-fps', '120', '--', '--tick-rate=120') $bootLog -RejectWarnings
    if ($Tier -eq 'Release') {
        & (Join-Path $PSScriptRoot 'package.ps1') -Target Windows
        & (Join-Path $PSScriptRoot 'test-windows-bootstrap.ps1')
    }
}
finally {
    $clock.Stop()
}
$stderrBytes = 0
foreach ($logPath in $executedLogs) {
    $errorPath = "$logPath.err"
    if (Test-Path -LiteralPath $errorPath -PathType Leaf) {
        $stderrBytes += (Get-Item -LiteralPath $errorPath).Length
    }
}
Write-Output ("PASS: Windows {0} gate completed in {1} ms; stderr {2} bytes." -f $Tier.ToLowerInvariant(), $clock.ElapsedMilliseconds, $stderrBytes)
