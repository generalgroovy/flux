param(
    [Parameter(Mandatory = $true)][ValidatePattern('^[a-z0-9][a-z0-9-]{0,47}$')][string]$Name,
    [ValidateSet('1280x720', '1920x1080')][string]$Resolution = '1280x720',
    [ValidateSet(60, 120)][int]$TickRate = 60,
    [ValidateRange(2, 120)][int]$Frames = 4,
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$GameArguments
)

. (Join-Path $PSScriptRoot 'flux2-common.ps1')

$repoRoot = Get-FluxRepoRoot
$godotBin = Get-FluxGodot
Assert-FluxGodotVersion $godotBin | Out-Null
$parts = $Resolution.Split('x')
$width = [int]$parts[0]
$height = [int]$parts[1]
$outputRoot = [System.IO.Path]::GetFullPath((Join-Path $repoRoot ".godot\visual-captures\$Name"))
$allowedOutputRoot = [System.IO.Path]::GetFullPath((Join-Path $repoRoot '.godot\visual-captures'))
if (-not $outputRoot.StartsWith($allowedOutputRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Capture output escaped the ignored visual-capture root.'
}
if (Test-Path -LiteralPath $outputRoot) {
    throw "Capture already exists; choose a new name: $outputRoot"
}
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

$temporaryRoot = [System.IO.Path]::GetFullPath((Join-Path ([System.IO.Path]::GetTempPath()) ("flux2-visual-capture-" + [guid]::NewGuid().ToString('N'))))
$systemTemporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
if (-not $temporaryRoot.StartsWith($systemTemporaryRoot, [System.StringComparison]::OrdinalIgnoreCase) -or -not ([System.IO.Path]::GetFileName($temporaryRoot)).StartsWith('flux2-visual-capture-')) {
    throw 'Temporary capture project did not resolve below the system temporary directory.'
}

try {
    New-Item -ItemType Directory -Path $temporaryRoot -Force | Out-Null
    & robocopy.exe $repoRoot $temporaryRoot /E /NFL /NDL /NJH /NJS /NP /XD .git .godot dist node_modules /XF firewall.ps1 | Out-Null
    if ($LASTEXITCODE -gt 7) { throw "Temporary project copy failed with robocopy code $LASTEXITCODE" }
    $sourceGodotCache = Join-Path $repoRoot '.godot'
    $temporaryGodotCache = Join-Path $temporaryRoot '.godot'
    New-Item -ItemType Directory -Path $temporaryGodotCache -Force | Out-Null
    foreach ($cacheFileName in @('global_script_class_cache.cfg', 'uid_cache.bin')) {
        $sourceCacheFile = Join-Path $sourceGodotCache $cacheFileName
        if (Test-Path -LiteralPath $sourceCacheFile -PathType Leaf) {
            Copy-Item -LiteralPath $sourceCacheFile -Destination (Join-Path $temporaryGodotCache $cacheFileName)
        }
    }
    $sourceImportedCache = Join-Path $sourceGodotCache 'imported'
    if (Test-Path -LiteralPath $sourceImportedCache -PathType Container) {
        & robocopy.exe $sourceImportedCache (Join-Path $temporaryGodotCache 'imported') /E /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -gt 7) { throw "Temporary Godot import-cache copy failed with robocopy code $LASTEXITCODE" }
    }

    $temporaryProject = Join-Path $temporaryRoot 'project.godot'
    $projectText = [System.IO.File]::ReadAllText($temporaryProject)
    $projectText = [regex]::Replace($projectText, 'window/size/viewport_width=\d+', "window/size/viewport_width=$width")
    $projectText = [regex]::Replace($projectText, 'window/size/viewport_height=\d+', "window/size/viewport_height=$height")
    $projectText = [regex]::Replace($projectText, 'window/size/window_width_override=\d+', "window/size/window_width_override=$width")
    $projectText = [regex]::Replace($projectText, 'window/size/window_height_override=\d+', "window/size/window_height_override=$height")
    [System.IO.File]::WriteAllText($temporaryProject, $projectText, [System.Text.UTF8Encoding]::new($false))

    $importLogPath = Join-Path $outputRoot 'import.log'
    Invoke-FluxGodotChecked $godotBin @('--headless', '--editor', '--path', $temporaryRoot, '--quit') $importLogPath | Out-Null

    $moviePath = Join-Path $outputRoot 'frame.png'
    $logPath = Join-Path $outputRoot 'capture.log'
    $arguments = @(
        '--path', $temporaryRoot,
        '--windowed', '--resolution', $Resolution,
        '--write-movie', $moviePath,
        '--quit-after', "$Frames", '--fixed-fps', "$TickRate",
        '--', "--tick-rate=$TickRate"
    ) + $GameArguments
    Invoke-FluxGodotChecked $godotBin $arguments $logPath | Out-Null

    $frameFiles = @(Get-ChildItem -LiteralPath $outputRoot -Filter 'frame*.png' -File)
    if ($frameFiles.Count -ne $Frames) { throw "Expected $Frames movie frames, found $($frameFiles.Count)." }
    Add-Type -AssemblyName System.Drawing
    foreach ($frame in $frameFiles) {
        $image = [System.Drawing.Image]::FromFile($frame.FullName)
        try {
            if ($image.Width -ne $width -or $image.Height -ne $height) {
                throw "Capture $($frame.Name) is $($image.Width)x$($image.Height), expected $Resolution."
            }
        }
        finally { $image.Dispose() }
    }
    Write-Output "PASS: $($frameFiles.Count) truthful $Resolution frames at $outputRoot"
}
finally {
    if (Test-Path -LiteralPath $temporaryRoot) {
        $resolvedTemporaryRoot = [System.IO.Path]::GetFullPath($temporaryRoot)
        if ($resolvedTemporaryRoot.StartsWith($systemTemporaryRoot, [System.StringComparison]::OrdinalIgnoreCase) -and ([System.IO.Path]::GetFileName($resolvedTemporaryRoot)).StartsWith('flux2-visual-capture-')) {
            Remove-Item -LiteralPath $resolvedTemporaryRoot -Recurse -Force
        }
    }
}
