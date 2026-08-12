param([switch]$SkipFullSuite)
. (Join-Path $PSScriptRoot 'flux2-common.ps1')

$repoRoot = Get-FluxRepoRoot
$godotBin = Get-FluxGodot
& (Join-Path $PSScriptRoot 'doctor.ps1')
$logRoot = Join-Path $repoRoot '.godot\windows-tests'
New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
Invoke-FluxGodotChecked $godotBin @('--headless', '--editor', '--path', $repoRoot, '--quit') (Join-Path $logRoot 'import.log')
if (-not $SkipFullSuite) {
    Invoke-FluxGodotChecked $godotBin @('--headless', '--path', $repoRoot, '--script', 'res://tests/run_all.gd') (Join-Path $logRoot 'suite.log')
}
foreach ($tickRate in @(60, 120)) {
    Invoke-FluxGodotChecked $godotBin @('--headless', '--path', $repoRoot, '--quit-after', '3', '--fixed-fps', "$tickRate", '--', "--tick-rate=$tickRate") (Join-Path $logRoot "boot-$tickRate.log")
}
Write-Output 'PASS: Windows source gates completed.'
