# FLUX 2

A Godot elemental arena game centered on Wellspring, a walkable academy for movement practice, spell selection and direct-IP multiplayer.

This repository contains the published **protocol 39 / snapshot 14** source line. It is separate from the later local overhaul. Source changes do not update an existing installer or promote a release checkpoint. Historical acceptance reports describe their own dated builds.

## Run from source on Windows

Use **Godot 4.7.1**, pinned by `.godot-version`. The launch scripts check the exact engine version. No npm install is required.

1. Clone this repository and open a terminal in its root.
2. Install the pinned Godot build. If it is not in the expected development location, set its executable path:

   ```powershell
   $env:FLUX2_GODOT_BIN = 'C:\Tools\Godot_v4.7.1-stable_win64.exe'
   ```

3. Check the environment and launch:

   ```powershell
   .\flux.cmd doctor
   .\flux.cmd play
   ```

The first launch imports assets and can take longer than later launches. Engine export templates are needed for packaging, not ordinary source play. Windows is the active release target; the preserved Linux scripts are not a current Linux acceptance claim.

## First session

You begin in Wellspring. Move to a station and press **F** to interact. Use the Controls Lectern for bindings and accessibility settings, the Spell Loom for spell positions, and the nearby practice routes and targets to learn movement and attacks. **F4** opens the movement guide and character compendium; controller **Select/Back** opens it too.

| Action | Keyboard / mouse default |
| --- | --- |
| Move / aim | WASD / mouse |
| Primary / active spell | Left mouse / right mouse or E |
| Sprint | Shift |
| Jump | Space or wheel up; hold for a higher paid jump |
| Slide / fast fall | C or wheel down; hold for paid sustain |
| Evade | Q |
| Context technique | V |
| Interact | F |
| Spell positions | 1–4, Ctrl+1–4, Alt+1–4 |
| Speech wheel | Hold T and choose a direction |
| Practice trace / next run | F2 / F3 |
| Movement guide and compendium | F4 |
| Camera zoom | F11 |

Controller movement and aim use the left and right sticks. Gameplay bindings can be changed at the Controls Lectern. Movement, attack and spell-layer combinations share the same configured bindings; Ctrl and Alt are spell layers, while slide defaults to C. Empty spell positions refuse the cast without spending resources.

## Host and join Farflow

Use the same source revision on every machine. The host opens **Host Farflow**; guests use **Join Farflow**. LAN discovery can show compatible hosts. For direct joining, enter the host address and press Enter. Typing replaces the preselected saved address; Ctrl+A selects it again, Backspace deletes the selection, Ctrl+V pastes, and Escape cancels.

The default session port is **UDP 24872**. Internet reachability depends on the host's routing, NAT and firewall; a room is not a hosted public service. Use Session Hearth for ready/start/results/rematch. Use the in-world leave/close/exit actions to end a session cleanly. The host owns authoritative simulation; host closure ends the company.

The configured limit is 2–8 players. Headless tests and same-machine checks do not prove physical multi-PC connectivity, internet capacity, balance, or rendered frame timing.

## What is saved

Bindings, accessibility/view settings and the last join address are local preferences in Godot's `user://player_preferences_v1.json` (normally under `%APPDATA%\Godot\app_userdata\FLUX 2` on Windows). There is no cloud profile or saved multiplayer match. Keep a copy of personal preferences before manual edits; the game reports preference read/write failures. Do not replace another checkout's profile while testing a source candidate.

## Development and checks

```powershell
.\flux.cmd check
.\flux.cmd assets
.\flux.cmd list-tests
.\flux.cmd test -Tier Focused -Suite input-router
.\flux.cmd test -Tier Full
```

Focused runs require the import cache to exist; use a normal launch or Fast check first on a fresh clone. `Fast` performs import and configured-120Hz boot, `Full` adds every headless suite and asset checks, and `Release` additionally packages. Use `Release` only when deliberately validating an export. Logs are written beneath `.godot/windows-tests`.

For multiple focused suite IDs, call the PowerShell script directly with an array:

```powershell
.\scripts\test.ps1 -Tier Focused -Suite @('input-router', 'player-preferences')
```

Cold imports can exceed the runner's 180-second limit on some machines. Preserve the failed log, complete a pinned-editor import, then retry. A startup log saying 120 Hz confirms configuration, not sustained runtime capacity.

## Implemented source scope

| Area | Meaning in this source line |
| --- | --- |
| Abilities | 46 validated effective records; 41 have runtime wire IDs |
| Chemistry | 36 symmetric definitions compile and hash; `runtime_enabled` remains false |
| Roster | 5 playable entries; 24 identities in the planning catalog |
| Cadence | 120 Hz authoritative simulation; 60 Hz transport snapshots |

Compiled chemistry definitions, planned characters, reference art and old exports must not be presented as newly playable or freshly verified content.

## Documentation map

- [Join-address regression and verification](docs/JOIN-ADDRESS-EDITING.md): bounded input fix and exact evidence.
- [Team foundation acceptance](docs/TEAM-FOUNDATION-ACCEPTANCE.md): historical published foundation results and open gates.
- [Movement acceptance](docs/WELLSPRING-MOVEMENT-ACCEPTANCE.md): movement/control design and dated evidence.
- [Visual refinement acceptance](docs/VISUAL-REFINEMENT-ACCEPTANCE.md): visual work and remaining human review.
- [Specification](SPECIFICATION.md): design contract for this checkout.
- [Implementation queue](.agent/OVERHAUL-IMPLEMENTATION.md): repository-local work plan.

The source layout separates application/input code in `src/app`, deterministic simulation in `src/sim`, transport in `src/net`, authored data in `content`, and test suites in `tests`. Edit only the intended source line; do not copy newer local overhaul assets or checkpoint metadata into this revision.
