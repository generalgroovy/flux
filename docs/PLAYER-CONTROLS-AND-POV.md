# Player controls and point-of-view settings

## Implemented checkpoint

FLUX 2 now loads schema-v2 preferences from the stable offline profile
`user://player_preferences_v1.json`. The legacy filename is retained so existing
schema-v1 installations are discovered and migrated in place. On Linux it
normally resolves below
`~/.local/share/godot/app_userdata/FLUX 2/`; Godot selects the equivalent user
data location on other platforms. The file is created with safe defaults on the
first launch and requires no account, network, subscription, or cloud service.

The profile owns five independent concerns:

- physical-key bindings for every current keyboard action;
- the movement reference preset;
- full-screen versus ranged-cone presentation;
- ranged-cone angle and length.
- the reduced-motion accessibility preference used by G3 presentation.

Schema-v1 profiles migrate only the former default bindings: C jump becomes
Space jump and the former Space primary alias becomes unbound. Explicit saved
alternatives, including J jump or P primary, remain unchanged. New defaults bind
Space only to semantic jump; Arc Primary keeps left mouse and controller trigger.

Unknown actions, unknown modes, conflicting non-zero keyboard keycodes,
fractional values, unsupported schema versions, and values outside documented
bounds fail closed. A keycode of zero intentionally removes that action's
keyboard binding without deleting its mouse or controller binding. Corrupt
preferences fall back to safe defaults with a warning instead of preventing an
offline game from starting.

## Movement reference presets

| ID | Meaning | Intended use |
| --- | --- | --- |
| `world_relative` | W/A/S/D always map to the screen/world axes; aim remains independent | Classic top-down shooter movement and maximum spatial consistency |
| `aim_relative` | Mouse/right-stick aim is forward; W/S move along that facing and A/D strafe perpendicular to it | Character-relative movement, forward pressure, and players accustomed to facing-led controls |

Both presets emit the same bounded semantic movement vector. They do not alter
acceleration, Stamina costs, collision, speed ceilings, ability outcomes,
network authority, replay bytes, or tick-rate behavior. If the pointer overlaps
the player exactly, aim-relative movement retains the last valid aim direction
rather than producing an undefined basis.

## View modes

`full` leaves the complete viewport visible. `cone` presents only the selected
aim-facing angle inside the selected range:

- angle: any whole degree from 15 through 360;
- range/length: 160 through 4096 world units;
- 360 degrees plus a finite range creates a circular ranged view;
- full view is a distinct mode and has no artificial range boundary.

The current checkpoint is a local presentation/accessibility policy in the
offline Sanctum. It does not yet claim wall occlusion or conceal networked
entities. A competitive or PvPvE mode that restricts information must enforce
visibility on the authoritative host and replicate no hidden actor state; a
client preference may make that view more restrictive, never less restrictive.
Chemistry work budgets and simulation decisions never depend on the camera or
view mask.

Perspective cutaway is a separate later system. A roof, high wall, foliage,
building, or construct that visually overlaps a character inside authoritative
LOS must fade/cut away or yield to a restrained ownership-readable silhouette.
Cone/full preference does not itself grant LOS. A character outside permitted
LOS receives no silhouette, nameplate, shadow, effect, audio marker, material
cue, or diagnostic leak.

## Runtime configuration

| Input | Action |
| --- | --- |
| `Space` | Semantic jump / movement-chain press |
| Left mouse | Arc Primary; no default Space alias |
| `E` / right mouse | Vector Lance |
| `F7` | Toggle world-relative / aim-relative movement and save |
| `F8` | Toggle full / cone view and save |
| `F9` / `Shift+F9` | Increase / decrease cone angle by 15 degrees and save |
| `F10` / `Shift+F10` | Increase / decrease cone range by 80 units and save |

Exact session overrides are also available from the normal launcher:

```bash
scripts/run.sh --movement-reference=aim_relative --pov-mode=cone \
  --pov-angle=135 --pov-range=960
```

Command-line values clamp to the supported numeric bounds and do not require
editing project data. Exact persistent values and physical-key codes can be
changed in the generated JSON file while the game is stopped. A controller-
friendly Settings station, interactive event capture, sensitivity/dead-zone
curves, per-device profiles, conflict explanation, reset-by-category, and
import/export are the next presentation layer over this same schema.

The schema persists `reduced_motion` strictly as a boolean. It defaults to false,
fails closed on malformed values, and does not alter canonical simulation. G3's
body-lift/shadow slice will consume it through an equivalent readable
presentation path.

## Acceptance and authority

- Movement transforms are deterministic integer operations before command
  construction; replay stores the resulting world vector and independent aim.
- Saved profiles round-trip without network access.
- Both 60 and 120 Hz boot with the same selected preferences.
- The mask is drawn after world actors but before HUD/debug panels, so it cannot
  hide configuration state or create simulation authority.
- Future server-enforced vision must be hashed mode content and tested for
  spectator, reconnect, late-join, replay, bot, and anti-information-leak paths.
