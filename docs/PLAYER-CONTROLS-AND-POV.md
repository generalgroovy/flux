# Player controls and point-of-view settings

## Implemented checkpoint

FLUX 2 now loads schema-v6 preferences from the stable offline profile
`user://player_preferences_v1.json`. The legacy filename is retained so existing
schema-v1 installations are discovered and migrated in place. On Linux it
normally resolves below
`~/.local/share/godot/app_userdata/FLUX 2/`; Godot selects the equivalent user
data location on other platforms. The file is created with safe defaults on the
first launch and requires no account, network, subscription, or cloud service.

The profile owns five independent concerns:

- physical-key bindings for every current gameplay keyboard action;
- mouse-button and wheel-direction bindings for current combat/movement actions;
- controller button and signed-axis bindings for current combat/movement actions;
- the movement reference preset;
- full-screen versus ranged-cone presentation;
- ranged-cone angle and length.
- the reduced-motion accessibility preference used by G3 presentation.

Schema-v1/v2 profiles migrate the former defaults: C jump becomes Space jump,
Alt sprint becomes Shift sprint, and the former Space primary alias becomes
unbound. Schema-v3's default Ctrl slide becomes C; Ctrl and Alt are left free
for later spell binding. Explicit saved
alternatives, including J jump or P primary, remain unchanged. New defaults bind
Space only to semantic jump; Arc Primary keeps left mouse and controller trigger.
Schema-v4 profiles gain the controller table and newly optional mouse movement
lanes without altering established jump, slide, primary or active inputs.
Schema-v5 profiles gain five independent spell actions on number keys 1–5;
missing mouse/controller spell lanes migrate to explicit unbound descriptors.

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
its existing vault, aerial redirect and sprint-held air-dodge roles.

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
| `V` | Contextual vault, recent-contact wall skim, air redirect, or sprint-held air dodge |
| `F` | Activate the nearest walk-up Wellspring station; controller north-face is equivalent |
| Left mouse | Arc Primary; no default Space alias |
| `E` / right mouse | Vector Lance |
| `1`–`5` | Request the corresponding canonical spell slot; the Spell Loom can place either proven champion spell in any slot and every empty slot refuses without spending Flux |
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
editing project data. Exact persistent values and physical-key codes can also
be changed in the generated JSON file while the game is stopped.
Sensitivity/dead-zone curves, named per-device profiles, reset-by-category and
profile import/export remain later presentation layers over this same schema.

The schema persists `reduced_motion` strictly as a boolean. It defaults to false,
fails closed on malformed values, and does not alter canonical simulation. The
G3 presentation sampler consumes it with a seven-pixel maximum whole-pixel body
lift and a lower-scale but still broader/darker shadow cue, instead of the
normal 28-pixel apex lift. Timing and authoritative movement remain identical.

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
