# HEX

**Hunt. Evade. eXecute.**

HEX is a complete, minimal 2D top-down systemic skill arena. Aim,
spacing, movement, timing, prediction, feints, and resource discipline decide
every match. The same deterministic rules power solo play, local multiplayer,
bots, and server-authoritative remote lobbies.

The current launcher and network protocol retain their DIFF compatibility names
while the working product identity migrates to HEX.

Build 0.12.0 introduces **Flux**, raw magic separate from universal movement
FLOW. Special, defense, and character mobility now compete for a visible,
recovering Flux pool; dry fighters retain aim, primary fire, sprint, hops, and
wall kicks, so fundamentals always offer a route back. The eight current
disciplines are EMBER, TIDE, GALE, STONE, VOLT, VEIL, PRISM, and NULL. VEIL can
plant and recast-swap with a readable decoy. NULL erases nearby constructs only
during a paid, punishable special. Gale fields bend projectiles, Tide can douse
or redirect Ember, Volt conducts through Tide, and explosive mechanics shatter
Stone without becoming an element themselves. Every field uses shape/text cues,
distinct audio, authoritative lifetimes, and geometry rather than passive damage
bonuses. Aim, movement, timing, and resource reads still convert every advantage.

Hosts can disable authored map hazards and receive a shareable `?join=` URL that
opens the lobby screen and joins automatically. The link must use a server
address reachable by the other player—LAN/VPN address or a public forwarded URL.

Movement is traceable through a restrained team-shaped trail whose length and
weight scale with actual velocity, making sprints, hops, knockback, and evasive
reversals readable without filling the arena with effects.

## Run

Requires Node.js 20.19 or newer and a current desktop browser.

```bash
npm ci
npm test
npm start
```

Open <http://127.0.0.1:8000>. The game starts in its main menu.
The home screen launches every offline ruleset directly; **Choose operation**
keeps agent, arena, format, and bot setup available in one builder.

To verify a local working copy and launch it on the first free port from
`8000`–`8100`:

```bash
bash scripts/test-changes.sh
```

### Remote multiplayer

Start a server reachable by other players:

```bash
npm run start:remote
```

The server prints the local and LAN addresses. Other players open the reachable
address, choose **Host / Join**, refresh the public lobby browser, or enter the
six-character lobby code. Internet play requires TCP port `8000` to be
reachable through port forwarding or a private-network/VPN tool. A different
port can be selected cross-platform:

```bash
node scripts/serve.mjs --host=0.0.0.0 --port=8010
```

Remote matches support public/private rooms, live discovery, join-in-progress,
protected late spawns, authoritative input validation, 20 Hz snapshots,
client prediction/reconciliation, rate limits, disconnect cleanup, host
migration, and host-controlled rematches. A dropped player has 30 seconds to
reclaim the exact authoritative entity through a locally retained, rotated
reconnect token. Public lobbies also offer read-only **Watch** slots that receive
the live state without consuming a player slot or gaining input authority. The
server owns position, damage, cooldowns, projectiles, hazards, objectives,
score, and outcomes.

### Pull, verify, and run on Linux

The launcher exclusively uses `~/Projects/diff`, fast-forwards `main`, installs
the locked dependencies, runs every test, reuses a healthy DIFF server or finds
a free port, and starts the game:

```bash
bash scripts/pull-and-run.sh
```

Enable LAN/remote hosting through the same launcher:

```bash
DIFF_HOST=0.0.0.0 bash scripts/pull-and-run.sh
```

To update and run a specific development checkout/branch, pass both explicitly:

```bash
bash scripts/pull-and-run.sh /home/otp/Projects/outskilled agent/prototype-loop
```

It refuses dirty or diverged work instead of hiding local changes.

### Desktop launchers and cleanup

Install a Linux desktop entry for the current checkout and branch:

```bash
bash scripts/install-desktop-linux.sh
```

It opens a terminal, fast-forwards the selected branch, installs locked
dependencies, runs all tests, starts DIFF on a free port, and then opens the
browser. The terminal owns the server; close it or press `Ctrl+C` to stop.

On Windows, run these once from PowerShell to create the equivalent desktop
shortcut:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install-desktop-windows.ps1
```

The shortcut uses `scripts\pull-and-run.ps1` to perform the same guarded
update, test, free-port, health-check, browser-open, and shutdown flow natively.

To stop registered DIFF servers belonging to this checkout without touching
unrelated Node processes:

```bash
npm run stop
```

Server records include the checkout root and a per-process instance token, so
stale PID files cannot target another application. Servers from builds older
than 0.9.3 are not registered and must be closed from their original terminal.

## Controls

| Action | Player 1 | Player 2 | Gamepad |
| --- | --- | --- | --- |
| Move | `WASD` | Arrow keys | Left stick |
| Aim | Mouse | `IJKL` | Right stick |
| Primary | Left click / `Space` | `U` | Right trigger |
| Special | Right click / `E` | `O` | West button |
| Defense | `Q` | `P` | Left trigger |
| Mobility | `Shift` | `Enter` | South button |
| Sprint | `Alt` | `,` | Left shoulder |
| Hop / wall kick | `C` | `.` | Right shoulder |
| Pause / network menu | `Escape` | `Escape` | — |
| Instant restart | `R` | `R` | — |
| Skip introduction | `T` | — | — |
| Toggle live field info | `F1` | `F1` | — |

Every agent uses this shared input language. Sprint and hop draw from FLOW;
touch cover, then hop during the brief contact window to kick away from it.
The live field panel shows the active objective, map, health, role, full kit,
and essential controls without pausing combat.

## Agents

| Agent | Role | Primary | Special | Defense | Mobility |
| --- | --- | --- | --- | --- | --- |
| KITE | Mobility duelist | Needle | Shear | Slip reflection | Vector dash |
| BULWARK | Space anchor | Rivet | Breach | Brace guard | Ram charge |
| ECHO | Feint skirmisher | Triplet | Afterimage | Null phase | Skip blink |
| VOLT | Tempo striker | Spark | Linebreak rail | Ground absorb | Surge dash |
| CINDER | Trap zoner | Ember | Kindle mine | Temper guard | Backdraft recoil |
| ORBIT | Field controller | Gravity | Well pull | Sling reflect | Apogee blink |
| MEND | Sustain tactician | Suture | Second Wind | Triage absorb | Transfer slide |
| ROOK | Range sentinel | Mark | Crosscut volley | Check counter | Castle sidestep |

Shots clash, heavy projectiles win light clashes, reflections change ownership,
cover blocks every projectile and movement type, mines interact with hostile
positioning, and dash contact, unit collision, defenses, hazards, knockback,
death, and respawn all share one simulation authority.
Each agent also has a smaller collision body, unique oriented silhouette, glyph,
color, role, and readable kit identity.

## Maps and modes

Maps:

- **BREAKLINE** — twin rotations around a telegraphed central seam
- **CROSSWIND** — long sightlines broken by offset cover pockets
- **CROWN** — a contested center with four readable gates
- **UNDERCURRENT** — three lanes with out-of-phase side hazards

Modes:

- **FIRST CONTACT** — short, skippable, behavior-driven introduction
- **DIFFERENCE** — first-to-five duel with clean rounds and overtime
- **FAULTLINE** — objective control with contested-state scoring
- **CONVERGENCE** — PvPvE control with hostile neutral sentinels
- **PRESSURE TEST** — solo/local/remote cooperative escalating PvE waves

## Architecture

- [`src/content.mjs`](src/content.mjs) — validated agents, maps, modes, and tuning
- [`src/match.mjs`](src/match.mjs) — fixed-tick simulation and collision authority
- [`src/lobbies.mjs`](src/lobbies.mjs) — lobby lifecycle and remote command ownership
- [`src/game.mjs`](src/game.mjs) — input, prediction, menus, HUD, feedback, and rendering
- [`scripts/serve.mjs`](scripts/serve.mjs) — allowlisted static server, lobby API, and WebSockets

Rendering never owns game rules. All commands are normalized, entity identifiers
are stable, non-finite state is repaired at the simulation boundary, movement is
swept in bounded substeps, renderer state is isolated per entity, and reset
creates a fresh authoritative match.

## Verification

```bash
npm test
node --check src/content.mjs
node --check src/match.mjs
node --check src/lobbies.mjs
node --check src/game.mjs
node --check scripts/serve.mjs
node --check scripts/stop-servers.mjs
bash -n scripts/pull-and-run.sh
bash -n scripts/install-desktop-linux.sh
bash -n scripts/test-changes.sh
```

The suite covers the real DOM/canvas controller, all agent/map/mode
combinations, wall and corner dash stress, blink obstruction, unit collision,
all defense types, projectile interaction, mines, hazards, death/reset,
overtime, control, PvE waves, join-in-progress, discovery, input sequencing,
snapshots, disconnect/reconnect identity, spectator isolation, host migration,
route allowlisting, security headers, and an eight-agent two-minute
deterministic combat soak. It also clicks every main menu, launches all five
rulesets through the shipped interface, toggles live field info, and verifies
agent/map shortcuts update the deployment builder.
