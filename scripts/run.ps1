param(
    [ValidateSet(120)][int]$TickRate = 120,
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$GameArguments
)
. (Join-Path $PSScriptRoot 'flux2-common.ps1')

$repoRoot = Get-FluxRepoRoot
$godotBin = Get-FluxGodot
Assert-FluxGodotVersion $godotBin | Out-Null

# A fresh clone may not have a complete .godot import cache yet. Starting the
# interactive window while imports/scripts are still unresolved can otherwise
# produce an unhelpful blank/grey debug window. Import headlessly first and fail
# visibly if Godot reports a parse/import/runtime error.
$runLogRoot = Join-Path $repoRoot '.godot\run'
New-Item -ItemType Directory -Path $runLogRoot -Force | Out-Null
Invoke-FluxGodotChecked $godotBin @(
    '--headless',
    '--editor',
    '--path', $repoRoot,
    '--import'
) (Join-Path $runLogRoot 'preflight.log')

# FLUX uses Godot's Compatibility renderer. Do not force native OpenGL on
# Windows: project.godot prefers ANGLE (OpenGL ES over Direct3D 11) there and
# falls back to native OpenGL when needed. This avoids grey/blank windows on
# systems whose Windows OpenGL driver is incomplete or unreliable.
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
