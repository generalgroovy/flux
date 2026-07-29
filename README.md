# FLUX

**Flow. Learn. Unleash. eXecute.**

FLUX is a complete, minimal 2D top-down systemic skill arena. Aim,
spacing, movement, timing, prediction, feints, and resource discipline decide
every match. The same deterministic rules power solo play, local multiplayer,
bots, and server-authoritative remote lobbies.

## Current repository status

The current unification candidate is `integration/unify-flux`. `main` remains the
stable release branch and has not been rewritten or merged with the candidate.

The candidate currently includes:

- the complete 0.34.3 live game;
- reliable source launch and graceful owned-process cleanup on Windows and Linux;
- 122 passing automated checks on Windows, including the local-agent and
  visual-priority contracts, live WebSocket lifecycle, and authenticated server
  cleanup;
- Windows NSIS and Linux AppImage package jobs that emit commit-bound SHA-256
  manifests and downloadable CI artifacts;
- an independently validated future character/element/race foundation that is
  not connected to live gameplay yet.

The remaining release gates are a current-commit packaged Windows gameplay smoke,
green Windows/Linux CI after publishing `develop`, and a final review before any
merge to `main`. The separate full-overhaul branch is actively changing and is
preserved for later review; it is deliberately excluded from this stable
candidate. There is no signed public installer or dependable public relay yet.

Current development priority is visual-only: original FLUX visual tokens,
characters, spells, maps, GUI, then integrated acceptance. New mechanics remain
frozen until that ordered pass is accepted; see
[`.agent/VISUAL-OVERHAUL.md`](.agent/VISUAL-OVERHAUL.md).

Build 0.34.3 makes the verified source workflow genuinely cross-platform.
Windows launchers call `npm.cmd`, avoiding the unsigned PowerShell shim that is
blocked by common execution policies. Registered servers now stop through an
authenticated loopback request, so Windows receives the same graceful WebSocket
shutdown notice and zero exit status as Linux instead of an unavoidable forced
termination. A Windows/Ubuntu CI matrix exercises the complete test suite and
validates each platform's launcher syntax on every pull request.

Build 0.34.2 gives the fullscreen **Muster Hall** a measured readability floor.
Mode, champion, race, map, setting, and launch copy now stays near or above 12
pixels at the default scale; mode choices wrap by available width, champion
columns have room for complete names, and only the clearly marked race strip
scrolls horizontally.

Build 0.34.1 makes the desktop window permanently fullscreen and repairs the
Muster Hall's **Enter arena** action. Panel state remains on the application
root for styling, but delegated navigation now recognizes only real links and
buttons, so it cannot cancel form submission or other unrelated controls.

Build 0.34.0 makes the desktop application the primary play surface. Electron
owns one sandboxed FLUX window and a separately isolated loopback authority;
the renderer has no Node access, device/data-read permissions, popups, webviews,
or external navigation. Only sanitized invite-link clipboard writes from the
exact local game origin are allowed. Linux AppImage and Windows NSIS builds share the same runtime and
probe their configured packaged-update feed when opened. **Play with Friends** creates a private
lobby path through a temporary HTTPS/WebSocket tunnel and copies a `flux://`
desktop invite, so guests join in their own FLUX window without port forwarding
or a browser. Tunnel downloads come only from Cloudflare's official GitHub
release and must match its published SHA-256 digest. Normal close asks owned
children to stop gracefully, then targets only those exact child PIDs if they
exceed the bounded shutdown window.

Build 0.33.0 completes the FLUX identity migration. Legacy DIFF environment
variables, health routes, browser storage, and debug hooks remain readable only
as explicit compatibility aliases; all new launch and persistence paths use FLUX.

Build 0.33.0 rebuilds the **Muster Hall** around a wide, usable configuration
flow. Every race owns one column and its difficulty-ordered champion rows;
champion ancestry is now bound consistently through local, quick, bot, and
online presentation instead of being an incoherent second selector. A persistent
summary keeps rite, field, element, bots, hazard rules, and the launch action in
view. The compact HUD can reveal full detail on demand, body text is larger, and
comic callouts use a 31% fill (69% transparency) with contrast preserved by
edges, blur, and shadow. Element labels pair a stable palette with words and
marks, while every race declares and renders a distinct physical feature such
as leaf-point ears, tusks, antlers, fins, rune ribs, or scaled wings. Empty race
columns are honest and non-interactive until complete champion kits ship.
The main navigation also responds to directional keyboard and gamepad input,
exposes a clear focus path into each panel, edge-triggers held controller
inputs, and keeps full contest and launch-summary copy visible instead of
clipping decision-critical text.

Build 0.33.0 also gives **WILDMARCH** its first distinct PvPvE objective loop.
Defeating a neutral warden releases one visible Wayseal. Any fighter can claim
it, but must deliver it within 16 seconds to one of two authored outer
waystones. That choice moves the scoring rune to the selected route for 14
seconds, then restores the center. The carrier gains no health, damage, Flux, or
FLOW; elimination or disconnect drops the seal for either team, and timeout
returns it to the wild. All eight arenas author two clear route choices. Bots,
late joins, spectators, reconnects, host migration, HUD coaching, field art,
audio/comic cues, and match invariants use the same authoritative state. A tied
clock enters sudden-score overtime. Deliberate server shutdown now ends every
client's match with explicit terminal copy and clears the unusable reconnect
offer instead of masquerading as a recoverable drop.

Build 0.32.0 adds **Edgeweave**, a universal movement read. Passing through the
narrow outer edge of a hostile spell at 260+ movement speed restores 9 FLOW.
Actual hits, marked practice pressure, stationary proximity, full FLOW, and
repeated projectiles inside a 0.22-second lockout grant nothing. Each projectile
can reward each fighter only once. The server-owned swept-path check works at
120 ticks through the existing snapshot protocol; a restrained trail burst,
comic/audio cue, live field status, and guide entry make the success legible.

Build 0.31.0 makes the final **First Rite discipline trial** behavior-driven.
Each champion receives short input-aware coaching for their real tactical:
terrain-shapers must author valid ground, Veil must leave a decoy, aimed Volt
and Prism casts must connect, Null must catch a nearby target, and Ember's trap
must finish arming. Empty or blocked casts do not pass. The spar stays
ability-restrained and nonlethal until
the proof resolves, then a comic/audio completion cue returns the player to the
full fight. This uses production simulation rules and adds no tutorial stage.

Build 0.30.0 makes the **First Rite defense read real**. Its spar now fires a
gold-diamond marked practice spell only after movement is demonstrated. The
spell deals at most 6 damage, applies no knockback, cannot eliminate or build
ultimate, and repeats no faster than every 1.1 seconds. A player advances only
by actually reflecting, guarding, phasing, absorbing, or countering the incoming
spell; adaptive input-aware coaching, comic feedback, and distinct audio expose
the timing without completing it for them. The rite remains instantly skippable.

Build 0.29.0 adds an opt-in **Deterministic network lab** under Settings. It
applies 0–250 ms seeded latency, 0–100 ms jitter, and 0–20% loss only to remote
inputs and snapshots; zero bypasses the conditioner. Real probe diagnostics stay
honest while the HUD names the synthetic profile and packet counts. Incoming
server ticks must advance monotonically, preventing jitter-reordered snapshots
from rolling prediction backward. Control/lobby traffic remains reliable.

Build 0.28.0 adds persistent Player 1 keyboard remapping in **Settings**. Choose
an action and press a key; duplicates swap, while system and Player 2 keys remain
protected. Old settings migrate to safe defaults, corrupt/duplicate maps reset,
and one reset restores presentation plus controls. The ability bar, field guide,
live field panel, and behavior-driven First Rite always show the active bindings.
Mouse, gamepad, Player 2, semantic commands, prediction, and server authority are
unchanged.

Build 0.27.0 completes **Aerwyn** as the third production champion. A successful
Turning Leaf reflection primes **Thread the Turn**: one 8%-slower Wind Needle
steers toward her live aim for 0.58 seconds at a bounded turn rate without added
damage. Combat earns **The Turning Sky**, a 0.64-second, cover-clipped target tell
that creates one shared Gale vortex. Its visible rotation bends each spell once,
moves every fighter and overlapping Ember around the rim, deals no damage, and
can be interrupted by Volt or erased by Null. The guide, vortex, bot use, HUD,
codex, comic/audio cues, and remote commands use the authoritative simulation.

Build 0.26.0 expands Wyrmbound into an opposed champion pair. **Varka Ashmaw**
uses Ember to inscribe a douseable Pyre Furrow; while standing in allied fire,
**Pyre-Forged** trades Cinder Tooth speed for size, knockback, and heavy-spell
clash weight without adding damage. **The Ashen Crown** spends combat-earned
charge on a 0.72-second distant ring tell whose six fire sigils deliberately
leave escape seams. Tide opens breaches, Gale moves the fire, Null can erase the
ring, Volt can interrupt the commitment, cover limits its target, and its damage
cannot recharge itself. Varka has a unique maw silhouette, authored bot use,
conditional HUD/codex state, and the same authoritative local/remote rules as
Yrsa.

Build 0.25.0 establishes the production passive/tactical/ultimate contract with
Yrsa as its first complete champion. **Ridgeline Hunt** turns a demonstrated wall
kick or landing cut into one faster, tighter Rime Fangs cast without adding
damage. Dealing damage—not waiting—earns **The White Hunt**; pressing `F` marks a
fixed lane for 0.58 seconds before a rime fan freezes its route. Cover, sidesteps,
Volt interruption, Ember melting, Tide extension, Null cancellation, and the
shared slippery surface all retain counterplay. Charge, commitment, fields,
projectiles, bot use, remote input, HUD state, telegraphs, and feedback remain
authoritative and deterministic. Other champions retain their complete existing
kits; their ultimate slot stays absent until each receives an equally complete
authored contract.

Build 0.24.0 locks the first movement grammar with deterministic chain and exploit
coverage. Slides cannot be hop-cancelled before commitment ends; completed slides
can route into hops; and neither hop nor slide can start invisibly beneath a
character mobility action. A 600-tick adversarial chain remains finite,
collision-safe, and within the universal speed ceiling.

Build 0.23.0 streamlined the First Rite around demonstrated FLOW behavior. Its
opening read now requires a real sprint, committed slide, and separate hop while
keeping the existing four-stage structure. The live prompt names only the next
missing behavior; bots cannot complete it, and players may still skip instantly.

Build 0.22.0 completed the first universal movement-grammar pass with a one-use
landing cut. After a hop fully resolves, a 110 ms true reversal gains 18% extra
counter-strafe authority and immediately consumes the window. It never shortens
the hop, inherits ice's reduced control, and cannot be held for repeated turns.

Build 0.21.0 introduced a complete thirteenth people: the **Wyrmbound**. Their
scaled bodies take 14% less forced movement, but their heavy commitment costs 6%
FLOW capacity and 2% speed. Native champion **Yrsa Rimewing** shapes Tide as
Frost through paired ranged shards, a ground-freezing breath cone, a precise
counter, and an armored leap. Her unique wing silhouette and **Wyrmfall Aerie**
home battleground ship through local, bot, and authoritative remote play. The
new ancestry changes spacing without reducing damage or granting affinity wins.

Build 0.20.0 added universal ground slides without another input binding. Hold
sprint and hop together after building speed to spend 22 FLOW on a fast 0.3
second low line. Slides steer only 32%, break on cover, have a clear cooldown,
and cannot replace ordinary hops unless both inputs remain intentionally held.
The simulation, networking, silhouette, trail, comic/audio feedback, controls,
and First Rite all share the same rule.

Build 0.19.0 added bounded hop momentum carry. Crossing the hop direction with
existing velocity preserves up to 35% of that lateral motion, capped at 180
units. Players can shape evasive arcs and wall approaches, but cannot stack
unbounded speed; collision, ice control, FLOW cost, and authoritative state all
retain their existing meaning.

Build 0.18.0 deepened universal footwork with counter-strafing. Reversing against
committed momentum brakes and redirects at a bounded 1.7× control rate, creating
sharper bait-and-repeek decisions without erasing acceleration. A restrained
comic/audio cue teaches the successful cut; ice still reduces the maneuver's
authority, so elemental terrain and movement mastery remain physically coherent.

Build 0.17.0 added the first movement-reactive world objective. The Broken
Covenant shrine in Oathscar Vale restores bounded Flux only when a fighter who
has spent magic crosses it at high speed. Its exposed central route, strict
entry-speed read, visible seven-second shared lockout, and zero direct damage
make movement execution and timing—not elemental affinity—the source of value.

Build 0.16.0 completed the first nested region. Enter **The Fracture** from the
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

Build 0.13.0 added the original twelve playable fantasy races as a second, bounded build axis:
Human, Iron Orc, Moss Troll, Briar Elf, Gloam Elf, Forge Dwarf, Copper Gnome,
Ash Revenant, Cloud Sylph, Reefborn, Cairnkin, and Cinderling. Each trades no
more than 10% across health, speed, Flux, and FLOW, advertises its boon and
drawback before selection, and remains authoritative through remote joins and
rematches. Build 0.33.0 supersedes that independent build axis: each race now
owns a column of difficulty-ordered home champions, keeping ancestry and
silhouette coherent across every launch path. Arena
selection is now a spatial atlas with authored region/scale coordinates and
hover/focus summaries, establishing the UI contract for nested world regions.

Build 0.12.0 introduced **Flux**, raw magic separate from universal movement
FLOW. Tactical, defense, and character mobility now compete for a visible,
recovering Flux pool; dry fighters retain aim, primary fire, sprint, hops, and
wall kicks, so fundamentals always offer a route back. The eight current
disciplines are EMBER, TIDE, GALE, STONE, VOLT, VEIL, PRISM, and NULL. VEIL can
plant and recast-swap with a readable decoy. NULL erases nearby constructs only
during a paid, punishable tactical. Gale fields bend projectiles, Tide can douse
or redirect Ember, Volt conducts through Tide, and explosive mechanics shatter
Stone without becoming an element themselves. Every field uses shape/text cues,
distinct audio, authoritative lifetimes, and geometry rather than passive damage
bonuses. Aim, movement, timing, and resource reads still convert every advantage.
Direct Tide–Ember overlap now consumes both fields into a short neutral vapor
cloud that damages any fighter who remains inside. Directed Tide still pushes a
misaligned Ember field instead, preserving aim and spacing as the deciding read.
Stone–Ember overlap consumes both constructs into a short neutral magma patch.
Magma deals no damage and slows grounded movement to 62%, so a hop escapes it
cleanly and neither elemental owner receives a passive matchup advantage.

Hosts can disable authored map hazards and receive a shareable `?join=` URL that
opens the lobby screen and joins automatically. The link must use a server
address reachable by the other player—LAN/VPN address or a public forwarded URL.

Movement is traceable through a restrained team-shaped trail whose length and
weight scale with actual velocity, making sprints, hops, knockback, and evasive
reversals readable without filling the arena with effects.

## Run

Running from source requires Node.js 20.19 or newer. On Windows, use `npm.cmd`
from PowerShell to avoid execution-policy conflicts with the unsigned npm
PowerShell shim.

Windows:

```powershell
npm.cmd ci
npm.cmd test
npm.cmd start
```

Linux:

```bash
npm ci
npm test
npm start
```

`npm start` opens FLUX in its own desktop window. No browser tab is used. The
home screen launches every offline ruleset directly; **Choose contest**
keeps champion, ancestry, arena, format, and bot setup available in one builder.

### Windows setup for friends

Until a signed installer is published, friends need [Git](https://git-scm.com/),
[Node.js 20.19+](https://nodejs.org/), and the
[GitHub CLI](https://cli.github.com/). In PowerShell:

```powershell
gh auth login --hostname github.com --git-protocol https --web
git clone https://github.com/generalgroovy/flux.git "$HOME\Projects\flux"
Set-Location "$HOME\Projects\flux"
git switch integration/unify-flux
npm.cmd ci
npm.cmd test
powershell -ExecutionPolicy Bypass -File scripts\install-desktop-windows.ps1
```

This creates **FLUX Arena** and **FLUX Arena - Play with Friends** shortcuts on
the desktop. Each shortcut refuses dirty or diverged source, fast-forwards its
pinned branch, installs the lockfile, runs the full tests, and only then opens
the game. Send a `flux://` invite only after **Create and deploy** reports that
the private route is ready. The host window must remain open for the invite to
work.

Create a private remote session from a desktop window:

```bash
npm run start:friends
```

Choose the lobby settings, press **Create and deploy**, then send the copied
`flux://` invite. A friend with FLUX installed can open it to launch the app and
join directly. First use downloads about 40 MB of checksum-verified tunnel
tooling into FLUX's user-data directory. The temporary link exists only while
the host window is open. Quick Tunnels have no uptime guarantee; a stable owned
relay remains required before treating this path as competitive infrastructure.
Packaged auto-update also remains release-blocked until the repository exposes
a signed, player-accessible update feed; source desktop launchers already
fast-forward and verify their configured branch before every launch.

The legacy browser/server development path remains available with
`npm run start:server`, then <http://127.0.0.1:8000>.

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

The launcher exclusively uses `~/Projects/flux`, fast-forwards `main`, installs
the locked dependencies, runs every test, and opens the desktop game:

```bash
bash scripts/pull-and-run.sh
```

Enable LAN/remote hosting through the same launcher:

```bash
FLUX_DESKTOP=0 FLUX_HOST=0.0.0.0 bash scripts/pull-and-run.sh
```

To update and run a specific checkout/branch, pass both explicitly:

```bash
bash scripts/pull-and-run.sh "$HOME/Projects/flux" integration/unify-flux
```

It refuses dirty or diverged work instead of hiding local changes.

### Desktop launchers and cleanup

Install a Linux desktop entry for the current checkout and branch:

```bash
bash scripts/install-desktop-linux.sh
```

It installs two launchers. Both fast-forward the selected branch, install locked
dependencies, and run all tests before opening FLUX in its own window. **FLUX
Arena · Play with Friends** additionally creates the private invite path.
Closing the game stops only the authority and tunnel processes owned by it.

On Windows, run these once from PowerShell to create the equivalent desktop
shortcut:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install-desktop-windows.ps1
```

The two shortcuts use `scripts\pull-and-run.ps1` to perform the same guarded
update, verification, desktop launch, friend-host, and bounded shutdown flow
natively.

To stop registered FLUX servers belonging to this checkout without touching
unrelated Node processes:

```bash
npm run stop
```

## Local AI handoff

Garuda Sway can run a fully local FLUX coding handoff with Ollama,
Qwen2.5-Coder 3B/7B, and Aider. Odysseus may provide the workspace UI and
scheduler, but uses the same tracked prompt, state, branch guard, lock, and test
gate. Setup is the only networked phase; normal agent runtime is local-only.

Diagnose or install the local stack:

```bash
bash scripts/setup-local-agent-linux.sh --check
bash scripts/setup-local-agent-linux.sh --install --pull --model auto --backend cpu
```

Start an interactive code session or one bounded implementation/test pass:

```bash
bash scripts/local-agent.sh chat --model auto
bash scripts/local-agent.sh run --model auto --iterations 1
bash scripts/prepare-odysseus-handoff.sh --clipboard
bash scripts/local-agent.sh logs
```

The runner refuses `main`, `master`, `develop`, detached HEAD, dirty trees, and
concurrent FLUX agents. It auto-approves local tools, tests and commits without
confirmation, remains open for interactive follow-ups, and never pushes. Use
`--no-commit` when a bounded run should leave a reviewable diff. Stop it with
`bash scripts/local-agent.sh stop` or `Ctrl+C`. The complete setup, model sizing,
private audit trail, Odysseus handoff, and review flow is
documented in [`.agent/LOCAL-MODEL-HANDOFF.md`](.agent/LOCAL-MODEL-HANDOFF.md).

Server records include the checkout root and a per-process instance token, so
stale PID files cannot target another application. Servers from builds older
than 0.9.3 are not registered and must be closed from their original terminal.

## Controls

| Action | Player 1 | Player 2 | Gamepad |
| --- | --- | --- | --- |
| Move | `WASD` | Arrow keys | Left stick |
| Aim | Mouse | `IJKL` | Right stick |
| Primary | Left click / `Space` | `U` | Right trigger |
| Tactical | Right click / `E` | `O` | West button |
| Defense | `Q` | `P` | Left trigger |
| Mobility | `Shift` | `Enter` | South button |
| Ultimate (authored champions) | `F` | `H` | North button |
| Sprint | `Alt` | `,` | Left shoulder |
| Hop / wall kick | `C` | `.` | Right shoulder |
| Slide | Sprint + hop | Sprint + hop | Both shoulders |
| Pause / network menu | `Escape` | `Escape` | — |
| Instant restart | `R` | `R` | — |
| Skip introduction | `T` | — | — |
| Toggle live field info | `F1` | `F1` | — |

Every champion uses this shared input language. Sprint and hop draw from FLOW;
touch cover, then hop during the brief contact window to kick away from it.
The live field panel shows the active objective, map, health, role, full kit,
and essential controls without pausing combat.
Player 1 keyboard bindings can be changed under **Settings**; the table lists
defaults. Reserved match and Player 2 keys cannot be stolen.

## Compatibility roster scheduled for retirement

These ten champions keep the current build playable while the visual-first
overhaul is produced. They are not permanent overhaul-roster entries; each is
removed only when its mapped successor is complete and the replacement build
passes selection, authority, migration, launch, and regression checks.

| Champion | People / discipline | Primary | Tactical | Defense | Mobility | Passive / ultimate |
| --- | --- | --- | --- | --- | --- | --- |
| AERWYN | Briar Elf / Gale | Wind Needle | Shearwind | Turning Leaf | Gale Step | Thread the Turn / The Turning Sky |
| GORUM | Iron Orc / Stone | Slingstone | Faultline | Ironroot | War Tusk | — |
| VELLYN | Gloam Elf / Veil | Moon Shards | Mirror Wraith | Dusk Mantle | Shadow Step | — |
| NIM COPPERSPARK | Copper Gnome / Volt | Quick Arc | Chain Rune | Grounding Sigil | Storm Hop | — |
| SEREK ASHBORN | Cinderling / Ember | Coal Star | Hearth Trap | Ashen Ward | Backblast | — |
| MORCANT | Ash Revenant / Null | Grave Orb | Silence Well | Spellturn | Grave Step | — |
| NERIS PEARLDIVE | Reefborn / Tide | Dew Lance | Wellspring | Tideshield | Current Step | — |
| BRANNA RUNESIGHT | Forge Dwarf / Prism | Rune Ray | Sunsplit | Facet Parry | Runestep | — |
| YRSA RIMEWING | Wyrmbound / Tide-Frost | Rime Fangs | White Breath | Scale Turn | Wyrmbound | Ridgeline Hunt / The White Hunt |
| VARKA ASHMAW | Wyrmbound / Ember | Cinder Tooth | Pyre Furrow | Smoke Shed | Talon Vault | Pyre-Forged / The Ashen Crown |

Shots clash, heavy projectiles win light clashes, reflections change ownership,
cover blocks every projectile and movement type, mines interact with hostile
positioning, and dash contact, unit collision, defenses, hazards, knockback,
death, and respawn all share one simulation authority.
Each champion also has a compact collision body, unique oriented silhouette, glyph,
color, role, and readable kit identity.

### Visual overhaul development

V0 now centralizes FLUX's value ladder, old-world palette roles, outlines,
materials, spacing, and motion timings in `styles.css`. Review the deliberately
non-shipping reference board with:

```bash
npm run visual:specimen
```

Then open `http://127.0.0.1:4173/tools/visual-specimen.html`. The specimen is
available from the source server for review but is excluded from desktop
packages. V0 is accepted and V1 character production has begun. Review the
first presentation-only slices at
`http://127.0.0.1:4173/tools/spai-si-specimen.html` and
`http://127.0.0.1:4173/tools/urzh-specimen.html`; this styling work changes no
simulation or network behavior.

| Source being retired | Overhaul successor | What survives |
| --- | --- | --- |
| Aerwyn | Spai Si | Redirect timing and Wind-angle readability |
| Gorum | Urzh | Brace and lane-anchor discipline |
| Vellyn | S. Wayne | Decoy spacing and swap boundaries |
| Nim Copperspark | Nico Lai | Charge sequencing and devices |
| Serek Ashborn | Steezo | Traps, detonation, and backblast recovery |
| Morcant | Djonah Thaan | Ground denial and pursuit pressure |
| Neris Pearldive | Grace Reava | Current redirection and brief protection |
| Branna Runesight | Biggy Bob | Sightline and forge-prism geometry |
| Yrsa Rimewing | Ha Rekt | Aerial cold-line hunting |
| Varka Ashmaw | Treevor the Mason | Terrain shaping and Fire liability |

### Future overhaul roster — not playable yet

The integration branch currently contains sixteen validated design records in
`src/overhaul-content.mjs`; the approved V1 visual plan now contains twenty-three
named champions, one temporary Angel placeholder, and twenty ancestry
foundations. The seven later named concepts, placeholder decision, and new
ancestry assignments must be unified into validated content only after
the character-visual gate is accepted. They replace the compatibility roster
only when a future vertical slice implements and verifies each character end to
end. See [`.agent/VISUAL-OVERHAUL.md`](.agent/VISUAL-OVERHAUL.md) for the
authoritative distribution and migration boundary.
All current character-description text is retained as draft placeholder copy for
an author rewrite; it is not approved for in-game display.

Implementation has begun with a local, headless Hara prototype in
`src/overhaul-runtime.mjs`. It is available only to tests and programmatic
matches that explicitly request `contentProfile: "overhaul-preview"`; the menu,
normal local matches, and live lobbies still fail closed to the shipped roster.
Ray, Stone Shot, SECOND PLAN, Gust Ring, Sun Grid, and basic bot behavior are
implemented and deterministically tested. Rendering, input/UI exposure, remote
preview authority, accessibility review, and packaged smoke testing remain
required before Hara can be considered playable.

| Character | Planned ancestry | Affinities | Identity |
| --- | --- | --- | --- |
| Oh Tipi | Seakin | Water, Ice, Charge | Conductive-field skirmisher |
| S. Wayne | Hobbit | Void, Light | Eclipse boundary tactician |
| The Red Baron | Undead | Void, Fire, Ice | Airborne formation controller |
| Steezo | Goblin | Fire, Charge, Light | Volatile combo engineer |
| Treevor the Mason | Treefolk | Earth, Wind, Fire | Mud-and-herb terrain mason |
| Oll' I | **Werewolf** | Earth, Fire, Light | Structural momentum breaker |
| Fluup | Orc | Charge, Wind, Ice | Storm momentum bruiser |
| Wa Bidi | Goblin | Charge, Wind, Fire | Battlecry air-route specialist |
| Grace Reava | Sylph | Wind, Water, Light | Luminous-current route duelist |
| Nico Lai | Gnome | Charge, Light | Precision shared-device engineer |
| Spai Si | **Demon** | Wind, Light, Earth | Cryptic redirect duelist |
| Leaf the Hidden | Treefolk | Water, Earth, Light | Concealed grove support |
| Ha Rekt | Wyrmborn | Ice, Wind, Fire | Aerial cold-line hunter |
| Dr. Apex | Stoneborn | Earth, Light, Water | Armored combat medic |
| Haara | Nymph | Light, Wind, Spirit | Resourceful bloom planner |
| Hesus Christo | **Elf** | Earth, Water | Towering renewal vanguard |
| Grimm Bow | Troll | Void, Earth, Water | Displacement-to-precision terrain archer |
| Biggy Bob | Dwarf | Earth, Fire, Light | Grounded forge-line breacher |
| Jan Wicked | Human | Ice, Void, Charge | Black-ice circuit hunter |
| Ba Djoh | Minotaur | Earth, Fire, Water | Three-current charge breaker |
| Urzh | Stoneborn | Earth, Fire, Charge | Conductive kiln bulwark |
| Donnok | Dwarf | Earth, Fire, Water | Forge-rhythm terrain shaper |
| Djonah Thaan | **Vampire** | Void, Charge, Fire | Grave-current pursuit controller |
| Unnamed Angel | **Angel placeholder** | Wind, Light, Spirit | Visual coverage only; identity and kit unapproved |

## Maps and modes

Maps:

- **THE SUNDERED ROAD** — twin rotations around a telegraphed central seam
- **ASHEN FORD** — three fast crossings around an intermittently kindled ford
- **PILGRIM STEPS** — offset terraces with exposed climbs and rapid flanks
- **OATHSCAR VALE** — four long rotations around a dangerous covenant ring
- **WINDGLASS MOOR** — long sightlines broken by offset cover pockets
- **THE OLD CROWN** — a contested center with four readable gates
- **DROWNED HALLS** — three lanes with out-of-phase side hazards
- **WYRMFALL AERIE** — high rotations around a narrow rime-vented nave

Each battleground is located on the interactive realm chart; The Fracture can be
opened as its own regional chart. Every location carries an
authored terrain identity, short history, regional heraldry, and at least two
field landmarks. These layers are readable orientation anchors only; hard cover,
hazards, elemental constructs, and objectives retain distinct gameplay edges.

Modes:

- **THE FIRST RITE** — short, skippable, behavior-driven introduction
- **OATH DUEL** — first-to-five duel with clean rounds and overtime
- **RUNEHOLD** — objective control with contested-state scoring
- **WILDMARCH** — hunt wardens, carry the shared Wayseal, and choose which outer
  route becomes the scoring rune
- **NIGHT SIEGE** — solo/local/remote cooperative escalating PvE waves

## Architecture

- [`src/content.mjs`](src/content.mjs) — validated champions, races, maps, modes, and tuning
- [`src/match.mjs`](src/match.mjs) — fixed-tick simulation and collision authority
- [`src/network/lobbies.mjs`](src/network/lobbies.mjs) — lobby lifecycle and remote command ownership
- [`src/network/conditioner.mjs`](src/network/conditioner.mjs) — seeded adverse-network scheduling and tick freshness
- [`src/network/quality.mjs`](src/network/quality.mjs) — rolling application-level connection diagnostics
- [`src/game.mjs`](src/game.mjs) — input, prediction, menus, HUD, feedback, and rendering
- [`scripts/serve.mjs`](scripts/serve.mjs) — allowlisted static server, lobby API, and WebSockets
- [`src/overhaul-content.mjs`](src/overhaul-content.mjs) — validated future-only content contracts; not live simulation data
- [`scripts/unification-preflight.mjs`](scripts/unification-preflight.mjs) — fail-closed launch and branch-cleanup audit
- [`scripts/package-current.mjs`](scripts/package-current.mjs) — clean-tree packaging with commit and SHA-256 manifest

Rendering never owns game rules. All commands are normalized, entity identifiers
are stable, non-finite state is repaired at the simulation boundary, movement is
swept in bounded substeps, renderer state is isolated per entity, and reset
creates a fresh authoritative match.

## Verification

Complete cross-platform source verification:

```bash
node scripts/ci-verify.mjs
```

Launch preparation and verified packaging on Windows:

```powershell
npm.cmd run preflight:unify -- --phase=launch
npm.cmd run package:windows:verified
Get-Content -Raw dist\build-manifest.json
```

Branch deletion uses the stricter cleanup phase and must remain blocked while an
unarchived source branch is moving:

```powershell
npm.cmd run preflight:unify -- --phase=cleanup
```

Individual checks remain available:

```bash
npm test
node --check src/content.mjs
node --check src/match.mjs
node --check src/network/lobbies.mjs
node --check src/network/conditioner.mjs
node --check src/network/quality.mjs
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
route allowlisting, security headers, and an eight-fighter two-minute
deterministic combat soak. It also clicks every main menu, launches all five
rulesets through the shipped interface, toggles live field info, and verifies
champion/map shortcuts update the contest builder.
