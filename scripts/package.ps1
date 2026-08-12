param([ValidateSet('Windows', 'Linux', 'All')][string]$Target = 'All')
. (Join-Path $PSScriptRoot 'flux2-common.ps1')

$repoRoot = Get-FluxRepoRoot
$godotBin = Get-FluxGodot
& (Join-Path $PSScriptRoot 'doctor.ps1') -RequireExportTemplates -ExportTarget $Target
$exportRoot = Join-Path $repoRoot 'exports'
New-Item -ItemType Directory -Path $exportRoot -Force | Out-Null
$presets = @()
if ($Target -in @('Windows', 'All')) {
    $presets += [pscustomobject]@{ Name = 'Windows x86_64'; RelativePath = 'windows\flux2.exe' }
}
if ($Target -in @('Linux', 'All')) {
    $presets += [pscustomobject]@{ Name = 'Linux x86_64'; RelativePath = 'linux\flux2.x86_64' }
}
foreach ($preset in $presets) {
    $output = Join-Path $exportRoot $preset.RelativePath
    New-Item -ItemType Directory -Path (Split-Path -Parent $output) -Force | Out-Null
    & $godotBin --headless --path $repoRoot --export-release $preset.Name $output
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $output -PathType Leaf)) { throw "Export failed: $($preset.Name)" }
}
$manifest = Join-Path $exportRoot 'SHA256SUMS.txt'
$lines = Get-ChildItem -LiteralPath $exportRoot -Recurse -File | Where-Object { $_.FullName -ne $manifest } | Sort-Object FullName | ForEach-Object {
    $relative = $_.FullName.Substring($exportRoot.Length + 1).Replace('\', '/')
    "$((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())  $relative"
}
[System.IO.File]::WriteAllLines($manifest, [string[]]$lines, [System.Text.UTF8Encoding]::new($false))
Write-Output "PASS: release exports and checksums written to $exportRoot"
