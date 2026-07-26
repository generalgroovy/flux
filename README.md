# HEX

**Hunt. Evade. eXecute.**

HEX is a complete, minimal 2D top-down systemic skill arena. Aim,
spacing, movement, timing, prediction, feints, and resource discipline decide
every match. The same deterministic rules power solo play, local multiplayer,
bots, and server-authoritative remote lobbies.

The current launcher and network protocol retain their DIFF compatibility names
while the working product identity migrates to HEX.

Build 0.16.0 completes the first nested region. Enter **The Fracture** from the
realm chart to choose a full gameplay-scale ladder: Sundered Road for duel,
Ashen Ford for small fights, Pilgrim Steps for medium contests, and Oathscar Vale
for large encounters. Each is fully selectable in solo, local, and remote play;
each has authored routes, safe spawns, cover, landmarks, and deterministic
hazards where the route decision benefits from one.

Build 0.15.0 turned the arena atlas into the first authored realm chart. Every
shipped battleground now declares terrain, regional lore, heraldry, and layered
landmarks. The field renderer replaces its technical grid and synthetic cover
with quiet tile marks, roads, courts, moors, water halls, runic sites, and stone
ruins while keeping collision and danger boundaries unambiguous.

Build 0.14.0 completed the first old-world identity pass. Eight named champions
now belong to the peoples and regions that shaped their magic; contests,
arenas, interface materials, and spell language use an illuminated chronicle
and woven-banner vocabulary instead of modern operators and deployments.
Stable internal identifiers remain intact for saved settings and network peers.

Build 0.13.0 added twelve playable fantasy races as a second, bounded build axis:
Human, Iron Orc, Moss Troll, Briar Elf, Gloam Elf, Forge Dwarf, Copper Gnome,
Ash Revenant, Cloud Sylph, Reefborn, Cairnkin, and Cinderling. Each trades no
more than 10% across health, speed, Flux, and FLOW, advertises its boon and
drawback before selection, and remains authoritative through remote joins and
rematches. Race columns sit above the difficulty-ordered champion grid. Arena
selection is now a spatial atlas with authored region/scale coordinates and
hover/focus summaries, establishing the UI contract for nested world regions.

Build 0.12.0 introduced **Flux**, raw magic separate from universal movement
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
The home screen launches every offline ruleset directly; **Choose contest**
keeps champion, ancestry, arena, format, and bot setup available in one builder.

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

Every champion uses this shared input language. Sprint and hop draw from FLOW;
touch cover, then hop during the brief contact window to kick away from it.
The live field panel shows the active objective, map, health, role, full kit,
and essential controls without pausing combat.

## Race champions

| Champion | People / discipline | Primary | Special | Defense | Mobility |
| --- | --- | --- | --- | --- | --- |
| AERWYN | Briar Elf / Gale | Wind Needle | Shearwind | Turning Leaf | Gale Step |
| GORUM | Iron Orc / Stone | Slingstone | Faultline | Ironroot | War Tusk |
| VELLYN | Gloam Elf / Veil | Moon Shards | Mirror Wraith | Dusk Mantle | Shadow Step |
| NIM COPPERSPARK | Copper Gnome / Volt | Quick Arc | Chain Rune | Grounding Sigil | Storm Hop |
| SEREK ASHBORN | Cinderling / Ember | Coal Star | Hearth Trap | Ashen Ward | Backblast |
| MORCANT | Ash Revenant / Null | Grave Orb | Silence Well | Spellturn | Grave Step |
| NERIS PEARLDIVE | Reefborn / Tide | Dew Lance | Wellspring | Tideshield | Current Step |
| BRANNA RUNESIGHT | Forge Dwarf / Prism | Rune Ray | Sunsplit | Facet Parry | Runestep |

Shots clash, heavy projectiles win light clashes, reflections change ownership,
cover blocks every projectile and movement type, mines interact with hostile
positioning, and dash contact, unit collision, defenses, hazards, knockback,
death, and respawn all share one simulation authority.
Each champion also has a compact collision body, unique oriented silhouette, glyph,
color, role, and readable kit identity.

## Maps and modes

Maps:

- **THE SUNDERED ROAD** — twin rotations around a telegraphed central seam
- **ASHEN FORD** — three fast crossings around an intermittently kindled ford
- **PILGRIM STEPS** — offset terraces with exposed climbs and rapid flanks
- **OATHSCAR VALE** — four long rotations around a dangerous covenant ring
- **WINDGLASS MOOR** — long sightlines broken by offset cover pockets
- **THE OLD CROWN** — a contested center with four readable gates
- **DROWNED HALLS** — three lanes with out-of-phase side hazards

Each battleground is located on the interactive realm chart; The Fracture can be
opened as its own regional chart. Every location carries an
authored terrain identity, short history, regional heraldry, and at least two
field landmarks. These layers are readable orientation anchors only; hard cover,
hazards, elemental constructs, and objectives retain distinct gameplay edges.

Modes:

- **THE FIRST RITE** — short, skippable, behavior-driven introduction
- **OATH DUEL** — first-to-five duel with clean rounds and overtime
- **RUNEHOLD** — objective control with contested-state scoring
- **WILDMARCH** — PvPvE control with hostile wild wardens
- **NIGHT SIEGE** — solo/local/remote cooperative escalating PvE waves

## Architecture

- [`src/content.mjs`](src/content.mjs) — validated champions, races, maps, modes, and tuning
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

The suite covers the real DOM/canvas controller, all champion/map/mode
combinations, wall and corner dash stress, blink obstruction, unit collision,
all defense types, projectile interaction, mines, hazards, death/reset,
overtime, control, PvE waves, join-in-progress, discovery, input sequencing,
snapshots, disconnect/reconnect identity, spectator isolation, host migration,
route allowlisting, security headers, and an eight-champion two-minute
deterministic combat soak. It also clicks every main menu, launches all five
rulesets through the shipped interface, toggles live field info, and verifies
champion/map shortcuts update the contest builder.
