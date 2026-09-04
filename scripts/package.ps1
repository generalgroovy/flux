param([ValidateSet('Windows', 'Linux', 'All')][string]$Target = 'All')
. (Join-Path $PSScriptRoot 'flux2-common.ps1')

$repoRoot = Get-FluxRepoRoot
$godotBin = Get-FluxGodot
& (Join-Path $PSScriptRoot 'doctor.ps1') -RequireExportTemplates -ExportTarget $Target
$exportRoot = Join-Path $repoRoot 'exports'
New-Item -ItemType Directory -Path $exportRoot -Force | Out-Null
$packageLogRoot = Join-Path $repoRoot '.godot\package'
New-Item -ItemType Directory -Path $packageLogRoot -Force | Out-Null
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
    $logName = $preset.Name.ToLowerInvariant().Replace(' ', '-') + '.log'
    Invoke-FluxGodotChecked $godotBin @('--headless', '--path', $repoRoot, '--export-release', $preset.Name, $output) (Join-Path $packageLogRoot $logName)
    if (-not (Test-Path -LiteralPath $output -PathType Leaf)) { throw "Export failed: $($preset.Name)" }
    if ($preset.Name -eq 'Windows x86_64') {
        # Read the exported payload, not the checkout, before bundling its identity.
        $packPath = [System.IO.Path]::ChangeExtension($output, '.pck')
        & (Join-Path $PSScriptRoot 'runtime-state.ps1') -PackPath $packPath -OutputPath (Join-Path (Split-Path -Parent $output) 'BUILD-STATE.json')
    }
}
$manifest = Join-Path $exportRoot 'SHA256SUMS.txt'
$lines = Get-ChildItem -LiteralPath $exportRoot -Recurse -File | Where-Object { $_.FullName -ne $manifest } | Sort-Object FullName | ForEach-Object {
    $relative = $_.FullName.Substring($exportRoot.Length + 1).Replace('\', '/')
    "$(Get-FluxFileSha256 $_.FullName)  $relative"
}
[System.IO.File]::WriteAllLines($manifest, [string[]]$lines, [System.Text.UTF8Encoding]::new($false))
& (Join-Path $PSScriptRoot 'bundle-release.ps1') -Target $Target -ExportRoot $exportRoot -ReleaseRoot (Join-Path $exportRoot 'release')
if ($Target -in @('Windows', 'All')) {
    & (Join-Path $PSScriptRoot 'build-windows-bootstrap.ps1')
}
Write-Output "PASS: release exports, portable archives and checksums written to $exportRoot"
