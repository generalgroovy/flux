# Player controls and point-of-view settings

## Implemented checkpoint

FLUX 2 now loads schema-v9 preferences from the stable offline profile
`user://player_preferences_v1.json`. The legacy filename is retained so existing
schema-v1 installations are discovered and migrated in place. Godot stores it
in the current Windows user's application-data area. The file is created with
safe defaults on first launch and requires no account, network, subscription,
or cloud service.

The profile owns these independent concerns:

- physical-key bindings for every current gameplay keyboard action;
- mouse-button and wheel-direction bindings for current combat/movement actions;
- controller button and signed-axis bindings for current combat/movement actions;
- the movement reference preset;
- full-screen versus ranged-cone presentation;
- ranged-cone angle and length;
- a bounded 50/75/100% camera scale that defaults to the wider 75% view;
- the reduced-motion accessibility preference used by G3 presentation;
- the high-contrast presentation preference used by the V6 screen filter.
- the last validated Farflow host/IP address entered at the in-world Join gate.

Schema-v1/v2 profiles migrate the former defaults: C jump becomes Space jump,
Alt sprint becomes Shift sprint, and the former Space primary alias becomes
unbound. Schema-v3's default Ctrl slide becomes C. Explicit saved
alternatives, including J jump or P primary, remain unchanged. New defaults bind
Space only to semantic jump; Arc Primary keeps left mouse and controller trigger.
Schema-v4 profiles gain the controller table and newly optional mouse movement
lanes without altering established jump, slide, primary or active inputs.
Schema-v5/v6 profiles migrate to four number-button actions plus configurable
Ctrl and Alt layer actions. A retired `spell_5` entry is ignored; if a legacy
action already owns Ctrl or Alt, that new layer remains unbound rather than
creating a conflict. Missing mouse/controller lanes migrate to explicit unbound
descriptors, and old profiles gain the 75% camera default. Schema-v7 profiles
gain standard contrast without altering any existing binding or presentation
choice. Schema-v8 profiles gain the safe local Farflow address `127.0.0.1`;
schema-v9 saves a player's subsequently validated host/IP entry.

Unknown actions, unknown modes, conflicting non-zero keyboard keycodes,
fractional values, unsupported schema versions, and values outside documented
bounds fail closed. A keycode of zero intentionally removes that action's
keyboard binding without deleting its mouse or controller binding. Corrupt
preferences fall back to safe defaults with a warning instead of preventing an
offline game from starting.

Walk to the **Controls Lectern** west of the Champion Loom and press F/controller
north-face to open the in-world table. Arrow keys or D-pad select an action and
device; Enter/controller south-face captures the next matching input,
Backspace/controller west-face unbinds, R/controller north-face restores safe
defaults, and Escape/controller east-face closes. Clicking a table cell begins
capture and the mouse wheel can navigate rows. Reusing an occupied input swaps
the two actions visibly instead of silently erasing one. Each accepted change
updates the runtime map and profile immediately; movement and casts are suppressed
locally while the lectern is open, but an online host keeps the session ticking.

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

Slide, jump-chain and contextual technique press edges are retained for 180 ms.
The buffer stores intent only: speed, aerial stage, cooldown, collision target,
Stamina and control-lock requirements are rechecked every tick, and an expired
or still-illegal action changes no state and spends no resource.

Holding Space or wheel-up preserves the authored jump arc. Releasing it cuts
remaining air time to a 90 ms minimum; holding C or wheel-down while airborne advances the fall by one
additional simulation tick per tick. Fast fall costs no Stamina because the
earlier landing is its commitment, and its explicit canonical/presentation state
is replayed identically rather than inferred from animation.

V after recent contact with an authored obstacle starts a 420 ms wall skim
along the requested tangent for one 18-Stamina purchase. Stable positive wall
identity excludes outer world boundaries, a 900 ms same-surface lockout prevents
loops, and the end exposes a short recovery cue. The same semantic V press keeps
its existing vault, aerial redirect and sprint-held air-dodge roles; on open
ground it starts a 24-Stamina roll. Roll remains solid against world collision
for 240 ms and ignores hostile damage/control only during its opening 130 ms.
Jump-family actions likewise ignore hostile damage/control during their opening
90 ms, then become vulnerable before landing. A bright broken contour exposes
the exact active evasion phase; neither action passes through walls or topology.

Every completed aerial route and wall-skim exit records a bounded 0–1000 landing
intensity in canonical state. Presentation turns that truth into the champion's
land strip, a short shadow squash and an expanding four-mark rune ring; heavier
routes and fast fall read more strongly without changing collision or recovery.
Reduced motion preserves the timing cue with a smaller, thinner, dimmer pulse.

## View modes

`full` leaves the complete viewport visible. `cone` presents only the selected
aim-facing angle inside the selected range:

- angle: any whole degree from 15 through 360;
- range/length: 160 through 4096 world units;
- 360 degrees plus a finite range creates a circular ranged view;
- full view is a distinct mode and has no artificial range boundary.

The current checkpoint is a local presentation/accessibility policy in the
offline Sanctum. In cone mode every authored `los_cutaway` building projects a
bounded presentation shadow through its silhouette corners; low traversal rails
remain explicitly non-occluding. It does not yet conceal networked entities. A
competitive or PvPvE mode that restricts information must enforce
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
| `Shift` | Sprint while held |
| `C` / wheel down | Dedicated grounded slide press; airborne input commits fast fall |
| `Space` / wheel up | Semantic jump / movement-chain press |
| `V` | Contextual vault, recent-contact wall skim, open-ground roll, air redirect, sprint-held air dodge, or buffered 18-Stamina impact tech |
| `F` | Activate the nearest walk-up Wellspring station; controller north-face is equivalent |
| Left mouse | Arc Primary; no default Space alias |
| `E` / right mouse | Vector Lance |
| `1`–`4` | Request the corresponding position in the active spell layer |
| `Ctrl` + `1`–`4` | Request one of four configurable Ctrl-layer positions |
| `Alt` + `1`–`4` | Request one of four configurable Alt-layer positions; Alt wins if both layer actions are held |
| `F7` | Toggle world-relative / aim-relative movement and save |
| `F8` | Toggle full / cone view and save |
| `F9` / `Shift+F9` | Increase / decrease cone angle by 15 degrees and save |
| `F10` / `Shift+F10` | Increase / decrease cone range by 80 units and save |
| `F11` / `Shift+F11` | Cycle camera scale through 50/75/100% forward or backward and save |

Exact session overrides are also available from the normal launcher:

```bash
scripts/run.sh --movement-reference=aim_relative --pov-mode=cone \
  --pov-angle=135 --pov-range=960 --camera-zoom=75
```

Command-line values clamp to the supported numeric bounds and do not require
editing project data. Exact persistent values and physical-key codes can also
be changed in the generated JSON file while the game is stopped.
Sensitivity/dead-zone curves, named per-device profiles, reset-by-category and
profile import/export remain later presentation layers over this same schema.

The schema persists `reduced_motion` and `high_contrast` strictly as booleans.
Both default to false, fail closed on malformed values, and do not alter
canonical simulation. While the Controls Lectern is open, M/controller L3
toggles reduced effects and H/controller R3 toggles high contrast; the header
shows both states and normal player changes save immediately. When reduced
effects are enabled, the G3 presentation sampler uses a seven-pixel maximum
whole-pixel body
lift and a lower-scale but still broader/darker shadow cue, instead of the
normal 28-pixel apex lift. Timing and authoritative movement remain identical.

Exact command-line movement, POV, angle, range and camera overrides are
transient diagnostics. They affect that process only and are not written to the
player profile on exit.

## Acceptance and authority

- Movement transforms are deterministic integer operations before command
  construction; replay stores the resulting world vector and independent aim.
- Saved profiles round-trip without network access.
- Both 60 and 120 Hz boot with the same selected preferences.
- Equivalent normalized jump samples at 60/120 Hz produce the same body lift,
  shadow width, and shadow opacity across all current aerial traversal modes.
- Jump presentation sampling does not mutate position, collision radius,
  canonical values, replay data, camera focus, or POV origin.
- The mask is drawn after world actors but before HUD/debug panels, so it cannot
  hide configuration state or create simulation authority.
- Future server-enforced vision must be hashed mode content and tested for
  spectator, reconnect, late-join, replay, bot, and anti-information-leak paths.
