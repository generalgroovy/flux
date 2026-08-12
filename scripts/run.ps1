param(
    [ValidateSet(60, 120)][int]$TickRate = 120,
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$GameArguments
)
. (Join-Path $PSScriptRoot 'flux2-common.ps1')

$repoRoot = Get-FluxRepoRoot
$godotBin = Get-FluxGodot
Assert-FluxGodotVersion $godotBin | Out-Null
& $godotBin --path $repoRoot -- "--tick-rate=$TickRate" @GameArguments
