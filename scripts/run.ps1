param(
    [ValidateSet(120)][int]$TickRate = 120,
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$GameArguments
)
. (Join-Path $PSScriptRoot 'flux2-common.ps1')

$repoRoot = Get-FluxRepoRoot
$godotBin = Get-FluxGodot
Assert-FluxGodotVersion $godotBin | Out-Null

$runLogRoot = Join-Path $repoRoot '.godot\run'
New-Item -ItemType Directory -Path $runLogRoot -Force | Out-Null

# Only perform the editor import on a genuinely fresh project cache. The old
# launcher ran this hidden on every start, making a healthy first import look
# like the launcher had frozen after "STARTING FLUX".
$importedRoot = Join-Path $repoRoot '.godot\imported'
$hasImportedResources = $false
if (Test-Path -LiteralPath $importedRoot -PathType Container) {
    $hasImportedResources = $null -ne (Get-ChildItem -LiteralPath $importedRoot -File -ErrorAction SilentlyContinue | Select-Object -First 1)
}

if (-not $hasImportedResources) {
    $preflightLog = Join-Path $runLogRoot 'preflight.log'
    Write-Host ''
    Write-Host 'Preparing FLUX resources for first launch...' -ForegroundColor Cyan
    Write-Host 'Godot import output will appear below. This step is skipped on later launches.' -ForegroundColor DarkGray
    Write-Host ''

    # Stream import output live to the tester and save the same output to a log.
    # Tee-Object -Variable also retains the lines for the error scan below.
    $preflightOutput = @()
    & $godotBin `
        --headless `
        --editor `
        --verbose `
        --path $repoRoot `
        --import 2>&1 |
        Tee-Object -Variable preflightOutput -FilePath $preflightLog |
        Write-Output
    $preflightExitCode = $LASTEXITCODE

    if ($preflightExitCode -ne 0) {
        throw "FLUX resource preparation failed with code $preflightExitCode. Review .godot\run\preflight.log."
    }

    $bad = $preflightOutput | Select-String -Pattern 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Invalid call'
    if ($bad) {
        throw 'FLUX resource preparation reported a script/import/runtime error. Review .godot\run\preflight.log.'
    }

    Write-Host ''
    Write-Host 'FLUX resources ready. Opening game...' -ForegroundColor Green
    Write-Host ''
}
else {
    Write-Host 'FLUX resources already prepared. Opening game...' -ForegroundColor Green
}

# FLUX uses Godot's Compatibility renderer. Do not force native OpenGL on
# Windows: project.godot prefers ANGLE (OpenGL ES over Direct3D 11) there and
# falls back to native OpenGL when needed.
$runArgs = @(
    '--path', $repoRoot,
    '--rendering-method', 'gl_compatibility',
    '--verbose',
    '--log-file', (Join-Path $runLogRoot 'game.log'),
    '--',
    "--tick-rate=$TickRate"
) + $GameArguments

& $godotBin @runArgs

if ($LASTEXITCODE -ne 0) {
    throw "FLUX 2 exited with code $LASTEXITCODE. Review .godot\run\preflight.log and .godot\run\game.log."
}
