# South annex: focused map evidence

Captured locally on Windows, 2026-09-09, with official Godot 4.7.1. This is an
uncommitted implementation checkpoint, not release or human play acceptance.
The original logs and PNGs were copied byte-for-byte; `manifest.json` records
their original workspace paths, lengths and verified SHA-256 file hashes.

## Recorded result

`focused-v1.log` records **15,739 assertions, zero failures**: campus layout
3,772; Conservatory route 3,902; illustrated kit 159; pixel map library 7,906.
Both focused and capture stderr files are empty. The focused command rejected
warnings. The capture log identifies the actual ANGLE/AMD renderer.

The campus expands to 3072 x 2304 while preserving the previous authored spawn,
stations, dummies, arena, obstacles, routes and rules. The preservation test
reconstructs the prior content and checks its canonical hash:

`1977f644057dd6a10c7bb3e08f2fd656456bc322a54d1281cf8179368aa45abf`

Captured expanded map identity:

`9e98cfe69c06deee0e6ed836f8cc6a8a55d9869915f19a6bb97f36edfbf6d726`

The new connected walking loop, bridge and Bell return have common 18 px
collision clearance. Walls 115/116 exercise the existing wall-run, wall-kick and
paid air-turn rules, with a wide ordinary bypass. Tests cover real authoritative
120 Hz traversal and camera clamping at 50/75/100 percent zoom. Existing 32 px
terrain composition and its 128-cell-per-axis cap remain unchanged.

## Captures

- `overview-normal.png`: actual 3072 x 2304 production campus render.
- `overview-reduced.png`: the same campus through the reduced-effects path.
- `annex-native.png`: actual 1280 x 720 southern wall view, without image resizing.

`capture-v1.log` contains decoded RGBA image-data hashes. These intentionally
differ from the PNG file hashes in `manifest.json`.

## Reproduce

From the repository, run the current focused suites with the pinned engine:

```powershell
. ./scripts/flux2-common.ps1
$mapEvidenceEngine = Get-FluxGodot
& $mapEvidenceEngine --headless --path . --script res://tests/run_all.gd -- --suite=sanctum-campus-layout,conservatory-route,wellspring-illustrated-kit,pixel-map-library
```

For a new actual-render capture, use a fresh output suffix; never overwrite this
historical evidence. The helper launches the engine with its window hidden:

```powershell
$mapEvidenceTag = Get-Date -Format 'yyyyMMdd-HHmmss'
$mapEvidenceOutput = "res://.godot/south-annex-capture-$mapEvidenceTag"
$mapEvidenceLog = Join-Path (Get-Location).Path ".godot/south-annex-capture-$mapEvidenceTag.log"
Invoke-FluxGodotChecked $mapEvidenceEngine @('--path', (Get-Location).Path, '--rendering-method', 'gl_compatibility', '--script', 'res://tests/visual/capture_south_annex.gd', '--', "--output=$mapEvidenceOutput") $mapEvidenceLog -RejectWarnings
```

The archived focused log came from a temporary runner selecting exactly these
four suites. Current sources can change assertion counts or visuals; a rerun
tests the current working copy, not an archived executable.

## Limits

These are map-only rendered fixtures, without actors, dummy respawn, gameplay
HUD, live camera movement or network peers. They do not establish eight-player
performance, human route feel, readability during combat or multiplayer
compatibility between builds with different map hashes. No minimap was added.
No physics, abilities, elements, friction or resource-economy rules were changed
by the annex. Full/export results, if later recorded, are separate evidence.
