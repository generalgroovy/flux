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

# FLUX intentionally targets the compatibility renderer. Make the interactive
# Windows source launch explicit as well so a machine-specific default renderer
# cannot silently select a different backend from project.godot.
& $godotBin `
    --path $repoRoot `
    --rendering-method gl_compatibility `
    --rendering-driver opengl3 `
    -- `
    "--tick-rate=$TickRate" `
    @GameArguments

if ($LASTEXITCODE -ne 0) {
    throw "FLUX 2 exited with code $LASTEXITCODE. Review the Godot output above and .godot\run\preflight.log."
}
