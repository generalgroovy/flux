# Farflow address editing refinement

Scope: the published FLUX source at `65373db774ea0837ffa22ad80a6af1621e2d8896`.
This small change repairs the existing Farflow join-address field. It does not
promote a build, installer, selected checkpoint, or the separate local overhaul.

When the saved address is selected for replacement, typing now replaces it even
at the allowed 255-character limit. Backspace clears that selection; otherwise
it still deletes one character. Ctrl+A selects the existing address again.
Unrecognized Ctrl/Alt/Meta shortcuts no longer insert their letter into the
address. The existing instruction line explains when typing will replace the
saved value. Clipboard validation, Enter-to-join, Escape-to-cancel, the length
limit, and network protocol remain unchanged.

## Evidence, September 27, 2026

- Actual input-handler regression events reproduced eight failing assertions
  before the fix; the harness skips game startup and preference persistence.
- Pinned Godot `4.7.1.stable.official.a13da4feb` imported the isolated clone with
  exit 0 and empty stderr. The initial cold-import attempt hit the existing
  runner's 180-second limit; a bounded 600-second retry completed successfully.
- Input routing, control binding, and preference suites: 3 suites, 697
  assertions, zero failures and empty stderr.
- Entire headless suite: 74 suites, 60,240 assertions, zero failures and empty
  stderr.
- Isolated headless bootstrap initialized at the configured 120 Hz, protocol
  39, and exited successfully with empty stderr. This is a startup check, not a
  runtime-capacity measurement.
- Raw local logs are retained in `.godot/consolidation-checks/`. The test process
  used an isolated APPDATA folder inside `.godot/consolidation-profile/`.

Visual/human interaction acceptance and physical multiplayer were not run.
The separate active development checkout, its dirty assets, personal profiles,
selected P48 fallback, and implementation queue were left untouched.
