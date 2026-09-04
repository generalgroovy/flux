param(
    [switch]$Check,
    [switch]$Json,
    [switch]$Quiet,
    [string]$OutputPath = ''
)

. (Join-Path $PSScriptRoot 'flux2-common.ps1')

$repoRoot = Get-FluxRepoRoot
if (-not $OutputPath) {
    $OutputPath = Join-Path $repoRoot '.godot\reports\current-state.json'
} elseif (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath = Join-Path $repoRoot $OutputPath
}
$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)
$issues = [System.Collections.Generic.List[string]]::new()

function Read-FluxJson([string]$RelativePath) {
    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required current-state input is missing: $RelativePath"
    }
    return Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
}

function Read-FluxText([string]$RelativePath) {
    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required current-state input is missing: $RelativePath"
    }
    return Get-Content -Raw -LiteralPath $path
}

function Get-FluxSourceInteger([string]$RelativePath, [string]$ConstantName) {
    $text = Read-FluxText $RelativePath
    $pattern = 'const\s+' + [regex]::Escape($ConstantName) + '\s*:\s*int\s*=\s*([0-9_]+)'
    $match = [regex]::Match($text, $pattern)
    if (-not $match.Success) {
        throw "Cannot resolve integer constant $ConstantName from $RelativePath"
    }
    return [int]($match.Groups[1].Value.Replace('_', ''))
}

function Get-FluxProjectInteger([string]$SettingName) {
    $text = Read-FluxText 'project.godot'
    $match = [regex]::Match($text, '(?m)^' + [regex]::Escape($SettingName) + '=([0-9]+)[ \t]*\r?$')
    if (-not $match.Success) {
        throw "Cannot resolve project setting $SettingName"
    }
    return [int]$match.Groups[1].Value
}

function Get-FluxGitValue([string[]]$Arguments) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return $null }
    $value = & git -C $repoRoot @Arguments 2>$null
    if ($LASTEXITCODE -ne 0) { return $null }
    return (($value | Out-String).Trim())
}

function Add-FluxIssue([bool]$Condition, [string]$Message) {
    if (-not $Condition) { $issues.Add($Message) }
}

function Get-FluxDocumentStatuses {
    $result = [ordered]@{}
    $docsRoot = Join-Path $repoRoot 'docs'
    foreach ($file in Get-ChildItem -LiteralPath $docsRoot -Filter '*.md' -File | Sort-Object Name) {
        $head = (Get-Content -LiteralPath $file.FullName -TotalCount 10) -join "`n"
        $match = [regex]::Match($head, '(?m)^Status:\s*(.+)$')
        $relative = 'docs/' + $file.Name
        if ($match.Success) {
            $result[$relative] = $match.Groups[1].Value.Trim()
        } else {
            $result[$relative] = 'MISSING'
            $issues.Add("Current documentation lacks an explicit status: $relative")
        }
    }
    return $result
}

$projectText = Read-FluxText 'project.godot'
$abilityPath = 'content/abilities/foundation_abilities_v1.json'
$reactionPath = 'content/reactions/first_eight_element_reactions_v1.json'
$playableChampionPath = 'content/champions/foundation_champions_v1.json'
$plannedAffinityPath = 'content/champions/champion_affinities_first_eight_v1.json'
$rosterPlanPath = 'content/champions/champion_roster_plan_v1.json'
$bodyPath = 'content/champions/body_type_profiles_v1.json'
$campusPath = 'content/maps/sanctum_campus_g2_v1.json'
$wellspringPath = 'content/maps/wellspring_hub_v2.json'
$motionPath = 'content/visual/minimal_champion_motion_v1.json'

$abilities = Read-FluxJson $abilityPath
$reactions = Read-FluxJson $reactionPath
$playableChampions = Read-FluxJson $playableChampionPath
$plannedAffinities = Read-FluxJson $plannedAffinityPath
$rosterPlan = Read-FluxJson $rosterPlanPath
$bodyProfiles = Read-FluxJson $bodyPath
$campus = Read-FluxJson $campusPath
$wellspring = Read-FluxJson $wellspringPath
$motion = Read-FluxJson $motionPath

$protocolVersion = Get-FluxSourceInteger 'src/sim/core/sim_config.gd' 'PROTOCOL_VERSION'
$simulationHz = Get-FluxSourceInteger 'src/sim/core/sim_config.gd' 'TICK_RATE'
$snapshotSchema = Get-FluxSourceInteger 'src/net/session_snapshot.gd' 'SCHEMA_VERSION'
$preferencesSchema = Get-FluxSourceInteger 'src/app/player_preferences.gd' 'SCHEMA_VERSION'
$snapshotHz = Get-FluxSourceInteger 'src/app/bootstrap.gd' 'SNAPSHOT_RATE'
$maximumPlayers = Get-FluxSourceInteger 'src/net/session_transport.gd' 'MAX_PLAYERS'
$projectPhysicsHz = Get-FluxProjectInteger 'common/physics_ticks_per_second'
$projectMaximumFps = Get-FluxProjectInteger 'run/max_fps'
$presentationBaseHz = [int]$motion.base_hz
$runtimeWireIds = @($abilities.runtime_wire_ids | ForEach-Object { [int]$_ })
$abilityWireIds = @($abilities.abilities | ForEach-Object { [int]$_.wire_id })
$bodyRoleIds = @($bodyProfiles.profiles.PSObject.Properties.Name)
$playableIds = @($playableChampions.champions | ForEach-Object { [string]$_.id })
$plannedIds = @($rosterPlan.champions | ForEach-Object { [string]$_.id })
$affinityIds = @($plannedAffinities.champions | ForEach-Object { [string]$_.id })
$documentStatuses = Get-FluxDocumentStatuses

Add-FluxIssue ($simulationHz -eq 120) "Simulation rate is $simulationHz Hz; current authority requires 120 Hz"
Add-FluxIssue ($projectPhysicsHz -eq $simulationHz) "Project physics rate $projectPhysicsHz disagrees with simulation rate $simulationHz"
Add-FluxIssue ($projectMaximumFps -eq 120) "Project frame cap is $projectMaximumFps; current Windows target requires 120"
Add-FluxIssue ($projectText -match 'simulation/supported_tick_rates=PackedInt32Array\(120\)') 'Project exposes a gameplay tick rate other than the single supported 120 Hz cadence'
Add-FluxIssue ($protocolVersion -eq 33) "Protocol is $protocolVersion; current documentation requires 33"
Add-FluxIssue ($snapshotSchema -eq 12) "Snapshot schema is $snapshotSchema; current documentation requires 12"
Add-FluxIssue ($preferencesSchema -eq 10) "Preferences schema is $preferencesSchema; current documentation requires 10"
Add-FluxIssue ($snapshotHz -eq 60) "Transport snapshot cadence is $snapshotHz Hz; current contract requires 60 Hz"
Add-FluxIssue ($presentationBaseHz -eq 60) "Presentation sample base is $presentationBaseHz Hz; current contract requires 60"
Add-FluxIssue ($maximumPlayers -eq 8) "Session capacity is $maximumPlayers; current tested cap requires 8"
Add-FluxIssue (@($abilities.abilities).Count -eq 21) "Authored ability count is $(@($abilities.abilities).Count); current contract requires 21"
Add-FluxIssue ($runtimeWireIds.Count -eq 16) "Runtime-selectable spell count is $($runtimeWireIds.Count); current contract requires 16"
Add-FluxIssue (@($runtimeWireIds | Sort-Object -Unique).Count -eq $runtimeWireIds.Count) 'Runtime spell wire IDs are not unique'
Add-FluxIssue (@($runtimeWireIds | Where-Object { $abilityWireIds -notcontains $_ }).Count -eq 0) 'Runtime spell order references a missing authored ability wire ID'
Add-FluxIssue (@($reactions.reactions).Count -eq 36) "Reaction definition count is $(@($reactions.reactions).Count); first-eight coverage requires 36"
Add-FluxIssue (-not [bool]$reactions.runtime_enabled) 'Reaction mutation became enabled before the C6-C9 acceptance path'
Add-FluxIssue ($playableIds.Count -eq 3) "Playable champion count is $($playableIds.Count); current foundation requires 3"
Add-FluxIssue ($plannedIds.Count -eq 24) "Planned champion count is $($plannedIds.Count); current roster plan requires 24"
Add-FluxIssue (($plannedIds -join ',') -eq ($affinityIds -join ',')) 'Planned roster and affinity catalogs have different identity/order sets'
Add-FluxIssue (($bodyRoleIds -join ',') -eq 'small,middle,large') "Body-role IDs are $($bodyRoleIds -join ','); expected small,middle,large"
Add-FluxIssue (@($campus.stations).Count -eq 12) "Wellspring station count is $(@($campus.stations).Count); current map contract requires 12"
Add-FluxIssue (@($wellspring.district_order).Count -eq 9) "Wellspring district count is $(@($wellspring.district_order).Count); current map contract requires 9"

foreach ($champion in $plannedAffinities.champions) {
    $affinities = @($champion.affinities)
    $pointProperties = @($champion.affinity_points.PSObject.Properties)
    $pointTotal = 0
    foreach ($property in $pointProperties) { $pointTotal += [int]$property.Value }
    Add-FluxIssue ($affinities.Count -ge 2 -and $affinities.Count -le 3) "Planned champion $($champion.id) must have two or three affinities"
    Add-FluxIssue ($pointProperties.Count -eq $affinities.Count) "Planned champion $($champion.id) affinity list/point map disagree"
    Add-FluxIssue ($pointTotal -eq 3) "Planned champion $($champion.id) spends $pointTotal affinity points instead of 3"
}
foreach ($champion in $rosterPlan.champions) {
    $isPlayable = [string]$champion.availability -eq 'playable'
    Add-FluxIssue ($isPlayable -eq ($playableIds -contains [string]$champion.id)) "Roster availability disagrees with the playable catalog: $($champion.id)"
    $affinityEntry = @($plannedAffinities.champions | Where-Object { [string]$_.id -eq [string]$champion.id })
    Add-FluxIssue ($affinityEntry.Count -eq 1) "Roster identity lacks one affinity entry: $($champion.id)"
    if ($affinityEntry.Count -eq 1) {
        Add-FluxIssue ([string]$affinityEntry[0].display_name -eq [string]$champion.display_name) "Roster and affinity display names disagree: $($champion.id)"
    }
}

$readme = Read-FluxText 'README.md'
Add-FluxIssue ($readme -match '21 validated authored records; 16 have runtime wire IDs') 'README does not distinguish 21 authored abilities from 16 runtime spells'
Add-FluxIssue ($readme -match '36 symmetric definitions compile and hash; `runtime_enabled` remains false') 'README does not report compiled reactions separately from disabled mutation'
Add-FluxIssue ($readme -match '3 playable entries; 24 identities') 'README does not distinguish the playable and planned rosters'
Add-FluxIssue ($readme -match '120 Hz authoritative simulation; 60 Hz transport snapshots') 'README does not distinguish simulation and snapshot cadences'

$branch = Get-FluxGitValue @('branch', '--show-current')
$head = Get-FluxGitValue @('rev-parse', 'HEAD')
$canonicalHead = Get-FluxGitValue @('rev-parse', '--verify', 'refs/remotes/origin/main')
$compatibilityHead = Get-FluxGitValue @('rev-parse', '--verify', 'refs/remotes/origin/codex/continuous-overhaul')
$statusText = Get-FluxGitValue @('status', '--porcelain=v1', '--untracked-files=all')
$dirtyEntryCount = if ($statusText) { @($statusText -split "`r?`n").Count } else { 0 }
$releaseRoot = Join-Path $repoRoot 'exports\release'
$checksumPath = Join-Path $releaseRoot 'SHA256SUMS.txt'

$state = [ordered]@{
    schema_version = 1
    generated_at_utc = [DateTime]::UtcNow.ToString('o')
    authority = 'generated read-only report; executed source, catalogs, tests and packages remain primary'
    git = [ordered]@{
        canonical_branch = 'main'
        current_branch = $branch
        head = $head
        remote_main = $canonicalHead
        remote_compatibility = $compatibilityHead
        dirty = ($dirtyEntryCount -gt 0)
        dirty_entry_count = $dirtyEntryCount
    }
    runtime = [ordered]@{
        product = 'FLUX 2'
        platform_acceptance = 'Windows'
        godot = '4.7.1.stable.official.a13da4feb'
        protocol = $protocolVersion
        snapshot_schema = $snapshotSchema
        preferences_schema = $preferencesSchema
        simulation_hz = $simulationHz
        project_physics_hz = $projectPhysicsHz
        maximum_fps = $projectMaximumFps
        transport_snapshot_hz = $snapshotHz
        presentation_sample_base_hz = $presentationBaseHz
        maximum_players = $maximumPlayers
    }
    content = [ordered]@{
        abilities_authored = @($abilities.abilities).Count
        spells_runtime_selectable = $runtimeWireIds.Count
        runtime_spell_wire_ids = $runtimeWireIds
        reactions_defined = @($reactions.reactions).Count
        reaction_mutation_enabled = [bool]$reactions.runtime_enabled
        champions_playable = $playableIds.Count
        playable_champion_ids = $playableIds
        champions_planned = $plannedIds.Count
        body_roles = $bodyRoleIds
        legacy_visual_size_paths = 5
        wellspring_districts = @($wellspring.district_order).Count
        wellspring_stations = @($campus.stations).Count
        hashes = [ordered]@{
            abilities = Get-FluxFileSha256 (Join-Path $repoRoot $abilityPath)
            reactions = Get-FluxFileSha256 (Join-Path $repoRoot $reactionPath)
            playable_champions = Get-FluxFileSha256 (Join-Path $repoRoot $playableChampionPath)
            planned_affinities = Get-FluxFileSha256 (Join-Path $repoRoot $plannedAffinityPath)
            roster_plan = Get-FluxFileSha256 (Join-Path $repoRoot $rosterPlanPath)
            body_roles = Get-FluxFileSha256 (Join-Path $repoRoot $bodyPath)
            wellspring = Get-FluxFileSha256 (Join-Path $repoRoot $campusPath)
        }
    }
    documents = $documentStatuses
    package = [ordered]@{
        release_directory_present = (Test-Path -LiteralPath $releaseRoot -PathType Container)
        one_file_installer_present = (Test-Path -LiteralPath (Join-Path $releaseRoot 'FLUX.exe') -PathType Leaf)
        portable_zip_present = (Test-Path -LiteralPath (Join-Path $releaseRoot 'FLUX2-Windows-x86_64.zip') -PathType Leaf)
        checksum_manifest_present = (Test-Path -LiteralPath $checksumPath -PathType Leaf)
        checksum_manifest_sha256 = if (Test-Path -LiteralPath $checksumPath -PathType Leaf) { Get-FluxFileSha256 $checksumPath } else { $null }
    }
    check = [ordered]@{
        passed = ($issues.Count -eq 0)
        issue_count = $issues.Count
        issues = @($issues)
    }
}

$outputDirectory = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
$stateJson = $state | ConvertTo-Json -Depth 12
[System.IO.File]::WriteAllText($OutputPath, $stateJson + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))

if ($Json) {
    Write-Output $stateJson
} elseif (-not $Quiet) {
    Write-Output ("FLUX state: protocol {0}, 120 Hz, {1}/{2} runtime/authored abilities, {3} reactions ({4}), {5}/{6} playable/planned champions, {7} players." -f $protocolVersion, $runtimeWireIds.Count, @($abilities.abilities).Count, @($reactions.reactions).Count, $(if ($reactions.runtime_enabled) { 'enabled' } else { 'gated' }), $playableIds.Count, $plannedIds.Count, $maximumPlayers)
    Write-Output "Report: $OutputPath"
}

if ($Check -and $issues.Count -gt 0) {
    foreach ($issue in $issues) { Write-Error $issue }
    throw "Current-state drift check failed with $($issues.Count) issue(s)."
}
if ($Check -and -not $Quiet) {
    Write-Output 'PASS: current runtime, content and documentation invariants agree.'
}
