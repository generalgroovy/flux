# FLUX

**Flow. Learn. Unleash. eXecute.**

FLUX is an original 2D top-down magical arena shooter/fighter built around
movement mastery, aim, spacing, reactions, terrain, and disciplined resource
use. Champions from distinct ancestries shape a shared battlefield through
elemental geometry; an affinity creates options and interactions, never an
automatic damage advantage.

> **Overhaul status:** this README describes the intended overhaul product.
> The repository still carries a complete ten-character compatibility runtime
> so Windows and Linux remain playable while overhaul champions replace it one
> at a time. Future content is not selectable in normal matches unless this
> document explicitly says otherwise.

## Game overview

| Aspect | Overhaul direction |
| --- | --- |
| Genre | Responsive top-down spell arena shooter/fighter for solo, local, PvP, PvPvE, and cooperative PvE |
| Skill pillars | Aim, spacing, route choice, movement chains, timing, prediction, feints, counterplay, and resource discipline |
| Match clarity | Clean projectile lanes, compact silhouettes, explicit telegraphs, restrained effects, and fast hit confirmation |
| World | Old-world magical regions expressed through carved runes, woven banners, stone, roots, mud, water, and regional heraldry |
| Social hub | The Living Sanctum is the starting area, menu, practice space, party hub, character select, guide, and route into every mode |
| Authority | Deterministic fixed-tick simulation; clients never own position, damage, cooldowns, objectives, score, or outcomes |
| Scale | Eight-player lobbies during the current stage, with protocol and performance decisions planned for at least 32 players later |
| Fairness | No ancestry or element grants passive spell-damage superiority; power comes from execution and readable interactions |

## Movement

Movement is a shared combat language, not a character-specific privilege.
**Stamina** pays for universal movement; **Flux** pays for spells and champion
actions. Every transition is buffered, bounded, collision-safe, and readable.

| Action | Function | Commitment / counterplay |
| --- | --- | --- |
| Move + independent aim | Permanent strafing, leading, cover, crossfire, and retreat foundation | Acceleration and braking preserve readable momentum |
| Sprint | Fast pursuit, disengagement, and objective routing | Continuously spends Stamina and delays recovery |
| Jump / double jump | Clear ground pressure and vary approach height | Costs Stamina; aerial state limits later options |
| Slide | Low, fast ground commitment | Weak steering, recovery, and hard stop on cover |
| Slide jump | Convert a completed slide into a longer route | Costs more Stamina and cannot erase slide commitment |
| Air dodge | Short directional aerial escape | High Stamina cost, limited steering, punishable recovery |
| Wavedash | Convert an angled air-dodge landing into grounded momentum | Requires exact landing geometry; no free speed stacking |
| Wall jump | Rebound from a brief wall-contact window | Per-wall lockout prevents infinite loops |
| Air redirect | One bounded mid-air correction | Limited uses and explicit recovery |
| Vault | Cross authored low cover | Requires a valid obstacle and leaves a readable crest |
| Superglide | Jump during the narrow vault crest window | Precise execution, Stamina cost, and fixed speed ceiling |
| Edgeweave | Skim a hostile spell edge at speed to regain Stamina | Hits, stationary proximity, and repeated contact give nothing |

The intended movement state machine includes grounded, rising, airborne,
falling, sliding, air-dodging, wall-contact, wall-jumping, vaulting, launched,
grappled, charging, stunned, rooted, and slowed states. Character abilities may
route through these states but may not bypass collision or the speed ceiling.

## Combat resources and ability structure

| Layer | Overhaul contract |
| --- | --- |
| Health | Determines defeat; ancestry and size may change survivability only within bounded budgets |
| Flux | Abundant but exhaustible magic resource; repeated casting postpones recovery |
| Stamina | Separate movement resource for sprinting, jumps, slides, air actions, and wall routes |
| Ultimate charge | Earned through active combat and objective contribution, never passive waiting or self-farming |
| Passive | One champion-defining rule that rewards a demonstrated behavior and has an explicit lockout |
| Primary | Reliable aimed pressure that remains useful without Flux |
| Active slots | Three unique catalog abilities chosen within the mode's skill-point budget; defense, mobility, terrain, support, and damage are ability roles rather than mandatory duplicate buttons |
| Ultimate | One signature high-impact commitment with startup, ownership, safe routes, interruption or destruction rules, and recovery |

Affinities reduce the build cost of thematically aligned abilities; they do not
increase raw spell damage. Every active requires a positive cost, cooldown,
startup/recovery read, role, and counterplay rule. A standard competitive
loadout targets a 13-point budget with no duplicate actives.

## Elements

The final thematic model separates physical forces, life/death magic, psyche,
chaos, gravity, and time. The current inactive data prototype validates the
first eight simplified families; **Spirit, Chaos, Gravity, and Time still need
schema, reaction, balance, and visual acceptance before runtime use**.

| Element family | Thematic range | Spatial identity |
| --- | --- | --- |
| Earth | Earth, stone, metal, growth | Mass, structures, cover, roots, fracture, and grounded routes |
| Fire | Heat, ignition, ash, smoke | Escalating pressure, spreading fields, delayed bursts, and route denial |
| Water | Water, flow, pressure | Wet routes, redirection, healing, cleansing, and displacement |
| Wind | Wind, sound, pressure | Push, lift, projectile bending, open lanes, and directional broadcasts |
| Ice | Cold, frost, brittle matter | Friction changes, frozen terrain, precise lanes, and shatter setup |
| Charge | Electricity, stored force | Conduction, linked devices, interruption, and delayed discharge |
| Light | Light, life, refraction | Beams, reveal, healing, reflection, and geometric protection |
| Dark | Death, plague, blood, shadow | Decay, pursuit marks, concealment, sacrifice, and attrition |
| Spirit | Psyche, dream, aether | Resolve, illusion, memory, possession boundaries, and dream routes |
| Chaos | Void, entropy, instability | Erasure, mutation, spatial failure, and dangerous rule disruption |
| Gravity | Weight, pull, orbit | Wells, altered trajectories, anchoring, and vertical commitment |
| Time | Delay, haste, echo | Telegraph timing, recorded states, bounded rewinds, and cooldown distortion |

### Element interactions

Reactions create neutral, readable arena state. They do not apply hidden rock-
paper-scissors multipliers, and every result must have a shape, cue, duration,
ownership rule, and escape or destruction answer.

| Combination | Result | Decision created |
| --- | --- | --- |
| Fire + Water | Steam | Obscured, marked cloud that both teams must leave or exploit |
| Water + Ice | Frozen route | Brittle low-friction surface that can be broken or avoided |
| Fire + Ice | Meltwater | Terrain changes after a crack-and-hiss warning |
| Water + Charge | Conducted water | Linked wet regions become dangerous before delayed discharge |
| Wind + Fire | Driven fire | Flame follows the shown pressure direction; cross behind the wind source |
| Wind + Charge | Charged air | Short-lived interrupt lane announced by arcs and pressure bands |
| Earth + Water | Mud | Grounded slow escaped by jumping, drying, or routing around |
| Earth + Fire | Magma / heated stone | Dangerous grounded route with visible orange fractures |
| Water + Earth growth | Bloom | New contestable growth that can be cut, burned, or used as cover |
| Light + Water / Ice | Split light / ice prism | Read and break the temporary lens angle |
| Light + Fire | Holy fire | Revealing flame that sacrifices concealment for a strongly marked lane |
| Light + Dark | Eclipse interference | Unstable high-contrast boundary crossed deliberately for positional value |
| Dark + Ice | Black ice | Concealed-looking but shape-marked brittle slide route with decay risk |
| Dark + living structure | Plague growth | Spreading decay stopped by destroying the source or cleansing the route |
| Chaos + structure | Unstable fracture | Temporary topology failure with strict limits and an obvious collapse timer |
| Gravity + Wind | Pressure well | Curved projectile and movement paths around a visible center |
| Time + field | Echo field | Repeats one recorded field phase without repeating direct hit damage |
| Spirit + Light | Sanctuary | Contestable resolve zone that protects agency rather than granting invulnerability |

## Ancestries

Twenty modular ancestry templates define body geometry, anatomy hooks, material,
and motion read. Champion profiles separately own posture, equipment, palette,
affinities, aura, health wear, and team ownership. Adding a champion therefore
reuses an ancestry without copying a complete renderer or changing hitboxes.

| Ancestry | Planned champion representation | Visual / gameplay direction |
| --- | --- | --- |
| Human | Jan Wicked | Adaptable gear-led identity; no extreme body advantage |
| Dwarf | Biggy Bob, Donnok | Broad grounded silhouette, strong structure resistance, slower routes |
| Gnome | Nico Lai | Tiny device specialist; efficient constructs, low health and mass |
| Hobbit | S. Wayne | Low profile and recovery; increased knockback vulnerability |
| Elf | Hesus Christo | Tall precise posture and air control; fragile body |
| Orc | Fluup | Heavy committed actions and interruption resistance; slower recovery |
| Troll | Grimm Bow | Huge enduring body and delayed recovery; slow, readable commitments |
| Minotaur | Ba Djoh | Momentum and structural impact; poor turning and miss recovery |
| Seakin | Oh Tipi | Fins and water-route steering; strongest value depends on authored currents |
| Wyrmborn | Ha Rekt | Anthropomorphic scaled wings and one strong aerial commitment; reduced Stamina |
| Stoneborn | Dr. Apex, Urzh | Braced stone mass and structure synergy; slow movement |
| Treefolk | Treevor the Mason, Leaf the Hidden | Rooted stability and growth; large targets vulnerable to sustained fire |
| Sylph | Grace Reava | Streamer-wing air control; very low health and mass |
| Undead | The Red Baron | Rune-rib remnant play and reduced healing |
| Goblin | Steezo, Wa Bidi | Fast tool-led play and bounded salvage; fragile bodies |
| Nymph | Haara | Blooming support interactions; power depends on clean reactions |
| Vampire | Djonah Thaan | Controlled pursuit and blood/death setup; sustain must stay interruptible |
| Werewolf | Oll' I | Forward-weighted breaker; strong commitment with weak turning |
| Angel | Temporary unnamed slot | Feather-wing visual coverage only; no approved champion, lore, or mechanics |
| Demon | Spai Si | Angular redirect silhouette; no sexualized anatomy or religious caricature |

Size ranges from 1 (tiny) to 5 (huge). Size alters health, speed,
acceleration, mass, radius, knockback response, and air control, never direct
spell damage. Race traits and size must remain inside the validated power budget.

## Overhaul champion roster

The roster contains twenty-three named champions plus one explicitly temporary
Angel slot. Every champion targets **two or three affinities**. Descriptions are
role summaries only; all humorous or personal draft lore remains author-owned
and must be rewritten before appearing in-game.

| Champion | Ancestry | Affinities | Combat identity |
| --- | --- | --- | --- |
| Oh Tipi | Seakin | Water, Ice, Charge | Conductive-field skirmisher and current rider |
| S. Wayne | Hobbit | Dark, Light | Eclipse-boundary tactician and decoy router |
| The Red Baron | Undead | Void, Fire, Ice | Airborne formation controller with punishable landings |
| Steezo | Goblin | Fire, Charge, Light | Volatile construct engineer and detonation sequencer |
| Treevor the Mason | Treefolk | Earth, Wind, Fire | Terrain mason who creates routes, cover, and fire liabilities |
| Oll' I | Werewolf | Earth, Fire, Light | Forward structural breaker with high commitment |
| Fluup | Orc | Charge, Wind, Ice | Storm bruiser who converts committed landings |
| Wa Bidi | Goblin | Charge, Wind, Fire | Fast battlecry route specialist with visual and audio cues |
| Grace Reava | Sylph | Wind, Water, Light | Luminous-current aerial duelist |
| Nico Lai | Gnome | Charge, Light | Precision shared-device engineer |
| Spai Si | Demon | Wind, Light, Earth | Redirect duelist who converts hostile intent into angles |
| Leaf the Hidden | Treefolk | Water, Earth, Light | Concealed grove support and planned-route grower |
| Ha Rekt | Wyrmborn | Ice, Wind, Fire | Aerial cold-line hunter with marked escape routes |
| Dr. Apex | Stoneborn | Earth, Light, Water | Armored combat medic with contestable support zones |
| Haara | Nymph | Light, Wind, Spirit | Bloom planner with flexible resource routing |
| Hesus Christo | Elf | Earth, Water | Tall renewal vanguard who rebuilds broken routes |
| Grimm Bow | Troll | Void, Earth, Water | Terrain archer who converts displacement into precision, never bonus damage |
| Biggy Bob | Dwarf | Earth, Fire, Light | Brown-haired forge-line breacher and masonry specialist |
| Jan Wicked | Human | Ice, Dark, Charge | Black-ice circuit hunter |
| Ba Djoh | Minotaur | Earth, Fire, Water | Three-current charge breaker |
| Urzh | Stoneborn | Earth, Fire, Charge | Conductive kiln bulwark and lane anchor |
| Donnok | Dwarf | Earth, Fire, Water | Forge-rhythm terrain shaper |
| Djonah Thaan | Vampire | Dark, Charge, Fire | Grave-current pursuit controller |
| Unnamed Angel | Angel | Wind, Light, Spirit | Visual placeholder only; permanent identity and kit unapproved |

The validated future data catalog currently contains sixteen of these concepts;
the visual plan contains all twenty-four slots. The two sources must be unified
before any roster-wide runtime migration. The Angel slot must be named and
approved or removed—visual coverage is not character completion.

## World, maps, and modes

### The Living Sanctum

The Sanctum is the first overhaul location foundation and the intended shared
social shell. Its current menu chambers already let players inspect champions,
configure matches, browse the realm and guide, tune controls, host or join
friends, and return to an active contest without dissolving the remote party;
the Living Sanctum is also the rendered starting place behind every menu.
Its local Practice chamber launches a dedicated rune court with a Stamina
circuit, movement cloister, spell court, and mirror ward. Players can switch
champions without leaving the floor, enable a stationary target, restore every
resource and cooldown, reset the court, and toggle the complete movement,
element, champion, ancestry, and selected-ability field guide with `F2`.
Character selection uses a fighting-game grid: ancestry columns contain
champion portraits, and hover or keyboard focus reveals the kit without
changing the locked choice.

The practice court exposes the complete movement set currently implemented in
the compatibility runtime: independent move/aim, counter-strafe, Stamina
sprint, committed slide, hop, landing cut, wall kick, champion mobility, and
Edgeweave. The broader movement table above remains the overhaul target; its
double jump, air dodge, wavedash, vault, superglide, and air redirect entries
are not yet runtime claims.

### Battleground design

Each map must provide meaningful routes, cover, hazards, spawns, objectives,
regional materials, landmarks, and elemental interaction space. Maps use
authored destruction with bounded active regions and work limits; competitive
telegraphs, objective edges, and collision boundaries always outrank decoration.

The compatibility build's eight arenas—The Sundered Road, Ashen Ford, Pilgrim
Steps, Oathscar Vale, Windglass Moor, The Old Crown, Drowned Halls, and Wyrmfall
Aerie—remain test harnesses until their V3 overhaul passes visual acceptance.

### Mode order

| Gate | Mode scope |
| --- | --- |
| Fundamentals | Freeplay/practice, First Rite introduction, one complete champion, and one complete map |
| PvP | Duel, team combat, control, draft/mirror variants, bots, scoring, rounds, rematch, and authoritative host/join |
| PvPvE | Shared neutral threats, contestable objectives, bounded rewards, late join, and extraction/convergence rules |
| PvE | Survival and siege with enemy families, encounter grammar, elites, bosses, co-op, difficulty, and save stability |
| Later scale | Small Battle Royale slice first; only expand after authority, recovery, readability, and performance pass |

## Visual direction

FLUX draws only broad mood principles from inviting top-down heroic fantasy and
crisp room-scale action games. It must not copy protected characters, assets,
symbols, layouts, maps, weapons, mechanics, animation, audio, typography, or
trade dress.

| Principle | Original FLUX expression |
| --- | --- |
| Heroic fantasy warmth | Parchment light, mineral shadows, forest and tide accents, restrained ember highlights |
| Immediate silhouettes | Compact bodies, ancestry anatomy, role posture, and one readable focus prop |
| Handcrafted spaces | Carved runes, woven banners, old stone, roots, mud, water, and regional heraldry |
| Readable magic | Geometric cores, restrained element auras, explicit tells, clean impact residue, and shape-before-color language |
| Diegetic interface | Illuminated-manuscript frames, stamped tabs, ink labels, and carved selection markers |
| Character dignity | Practical clothing, distinct faces and bodies, no sexualized presentation, and no aura that hides anatomy or attacks |

The readability hierarchy is: collision/danger, startup direction and timing,
ownership and break state, element/reaction opportunity, then decoration.
Decorative particles may drop under load; essential tells may not.

## Overhaul delivery order

Mechanical expansion is frozen while the visual-first gates are completed in
order. A direct user request allowed only the existing Sanctum and roster-grid
GUI foundation to arrive early.

| Gate | Scope | Current status |
| ---: | --- | --- |
| V0 | Visual tokens and non-shipping reference specimen | Accepted |
| V1 | All champion and ancestry concepts | In progress: Spai Si, Urzh, and S. Wayne have source-only specimens |
| V2 | Spell anticipation, travel, impact, ownership, and expiry language | Blocked by V1 |
| V3 | Map materials, landmarks, routes, hazards, objectives, and dense-fight clarity | Blocked by V2 |
| V4 | Sanctum, HUD, guide, settings, lobby, pause, results, and tutorial | Menu, roster, and integrated Practice court authorized and implemented; full gate still blocked by V3 |
| V5 | Integrated play, accessibility, eight-player stress, Windows/Linux source and package acceptance | Blocked by V4 |

After V5, mechanics proceed as complete vertical slices: Flux economy and HUD,
freeplay shell, movement foundation, elements/materials, race/size/affinity
budget, one champion at a time, destruction and multi-level maps, then expanded
modes. The game must remain launchable and playable on Windows and Linux after
every slice.

## Current implementation truth

| Area | Actual repository state |
| --- | --- |
| Compatibility runtime | Complete ten-character game remains authoritative in normal local and remote matches |
| Overhaul data | Eight-family element aliases, sixteen mechanical race archetypes, sixteen design-only champions, ability catalog, reactions, movement grammar, sizes, modes, and destruction rules are validated but inactive |
| Character visuals | Twenty modular ancestry templates exist; Spai Si, Urzh, and S. Wayne have modular six-state source-only specimens |
| Haara prototype | Headless local mechanic prototype still uses the legacy `Hara` label and stable `mara` ID behind `contentProfile: "overhaul-preview"`; normal selection and live lobbies reject it |
| Sanctum | Always-rendered Living Sanctum shell, persistent remote company, ancestry-column roster selection, and a local Practice court with movement/spell areas, stationary target, champion switch, refill/reset, and `F2` field guide are implemented |
| Platforms | Source launch and graceful cleanup work on Windows and Linux; CI builds Windows NSIS and Linux AppImage artifacts |
| Verification | 133 automated checks pass locally; PR #10 passed Windows/Linux Node 20/22 verification and both package builds for the preceding implementation commit `e472bd7`; this Sanctum commit still needs its remote CI run |
| Release blockers | Complete V1–V5 acceptance, a current packaged match smoke, signed public installers/update feed, and a dependable owned relay |

The old champions are implementation scaffolding, not overhaul characters. Their
mechanical lessons transfer only when the successor is complete:

| Compatibility source | Overhaul successor | Retained design lesson |
| --- | --- | --- |
| Aerwyn | Spai Si | Redirect timing and Wind-angle readability |
| Gorum | Urzh | Brace discipline and lane anchoring |
| Vellyn | S. Wayne | Decoy spacing and visible swap boundaries |
| Nim Copperspark | Nico Lai | Charge sequencing and calibrated devices |
| Serek Ashborn | Steezo | Traps, detonation, and backblast recovery |
| Morcant | Djonah Thaan | Ground denial, pursuit pressure, and silence cues |
| Neris Pearldive | Grace Reava | Current redirection and brief protection |
| Branna Runesight | Biggy Bob | Sightline control and forge-prism geometry |
| Yrsa Rimewing | Ha Rekt | Aerial cold-line hunting and committed landings |
| Varka Ashmaw | Treevor the Mason | Terrain shaping, Fire liability, and climax structure |

## Run the current development build

Node.js 20.19 or newer is required. The current build is the compatibility
harness used to keep the overhaul continuously playable.

Windows PowerShell:

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

`npm start` opens the sandboxed Electron desktop application. Stop only FLUX
processes registered to this checkout with:

```bash
npm run stop
```

The game opens in the Living Sanctum. Choose **Practice**, select a champion,
optionally keep the stationary target enabled, and choose **Enter the Practice
Floor**. Use the top practice strip to switch champions, refill Stamina/Flux and
cooldowns, reset the floor, or return to the Sanctum; press `F2` for the complete
field guide.

### Setup for friends on Windows

Until signed installers are public, install Git, Node.js 20.19+, and GitHub CLI,
then run:

```powershell
gh auth login --hostname github.com --git-protocol https --web
git clone https://github.com/generalgroovy/flux.git "$HOME\Projects\flux"
Set-Location "$HOME\Projects\flux"
git switch integration/unify-flux
npm.cmd ci
npm.cmd test
powershell -ExecutionPolicy Bypass -File scripts\install-desktop-windows.ps1
```

This creates **FLUX Arena** and **FLUX Arena - Play with Friends** desktop
shortcuts. The guarded launcher refuses dirty or diverged source, fast-forwards
the selected branch, installs the lockfile, runs tests, and then opens the game.

### Linux desktop handoff

```bash
git clone https://github.com/generalgroovy/flux.git "$HOME/Projects/flux"
cd "$HOME/Projects/flux"
git switch integration/unify-flux
npm ci
npm test
bash scripts/install-desktop-linux.sh
```

Use the guarded update-and-launch path with:

```bash
bash scripts/pull-and-run.sh "$HOME/Projects/flux" integration/unify-flux
```

### Remote play

Open the friend-host desktop shortcut or run:

```bash
npm run start:friends
```

Choose **Friends**, open a lobby, and send the generated `flux://` invite after
the private route reports ready. The temporary tunnel exists only while the host
stays open and is a development fallback, not release-grade infrastructure.

For LAN/VPN development hosting:

```bash
npm run start:remote
```

Remote authority supports public/private rooms, lobby codes, join-in-progress,
spectators, reconnect tokens, host migration, prediction/reconciliation, input
sequences, snapshots, rate limits, diagnostics, and explicit shutdown behavior.

## Current compatibility controls

These bindings operate the test harness and may be remapped as the overhaul
loadout and movement grammar become live.

| Action | Player 1 | Player 2 | Gamepad |
| --- | --- | --- | --- |
| Move | `WASD` | Arrow keys | Left stick |
| Aim | Mouse | `IJKL` | Right stick |
| Primary | Left click / `Space` | `U` | Right trigger |
| Tactical | Right click / `E` | `O` | West button |
| Defense | `Q` | `P` | Left trigger |
| Champion mobility | `Shift` | `Enter` | South button |
| Ultimate | `F` | `H` | North button |
| Sprint | `Alt` | `,` | Left shoulder |
| Hop / wall kick | `C` | `.` | Right shoulder |
| Slide | Sprint + hop | Sprint + hop | Both shoulders |
| Pause / network menu | `Escape` | `Escape` | — |
| Restart | `R` | `R` | — |
| Skip First Rite | `T` | — | — |
| Toggle field information | `F1` | `F1` | — |
| Toggle Sanctum practice guide | `F2` | `F2` | — |

## Visual review and verification

Run the source-only visual boards:

```bash
npm run visual:specimen
```

Then open:

- `http://127.0.0.1:4173/tools/visual-specimen.html`
- `http://127.0.0.1:4173/tools/ancestry-template-specimen.html`
- `http://127.0.0.1:4173/tools/spai-si-specimen.html`
- `http://127.0.0.1:4173/tools/urzh-specimen.html`
- `http://127.0.0.1:4173/tools/s-wayne-specimen.html`

Complete repository verification:

```bash
node scripts/ci-verify.mjs
```

Verified packaging requires a clean commit:

```powershell
npm.cmd run package:windows:verified
```

```bash
npm run package:linux:verified
```

## Architecture

| Path | Responsibility |
| --- | --- |
| `src/overhaul-content.mjs` | Inactive elements, races, characters, abilities, reactions, movement, modes, and destruction contracts |
| `src/ancestry-visual-templates.mjs` | Twenty reusable presentation-only ancestry foundations |
| `src/overhaul-character-visuals.mjs` | Champion visual profiles, six-state reads, and compatibility transfers |
| `src/overhaul-runtime.mjs` | Fail-closed Haara mechanic preview, still using the legacy Hara label and stable `mara` ID |
| `src/content.mjs` | Temporary authoritative compatibility roster, maps, modes, and tuning |
| `src/match.mjs` | Deterministic simulation and collision authority |
| `src/network/lobbies.mjs` | Authoritative lobby lifecycle and command ownership |
| `src/game.mjs` | Input, prediction, Sanctum, HUD, feedback, and rendering |
| `.agent/VISUAL-OVERHAUL.md` | Authoritative visual order and 24-slot roster distribution |
| `.agent/OVERHAUL-IMPLEMENTATION.md` | Per-system implementation matrix |
| `.agent/PLAYABLE-STATE.md` | Exact known-playable state and release blockers |

Rendering never owns game rules. Content migrations preserve stable identifiers
or provide explicit versioned adapters. No overhaul champion replaces a
compatibility source until selection, simulation, bots, networking, reconnect,
spectating, accessibility, Windows/Linux launch, packaging, and regression tests
all pass on the same commit.

## Local AI handoff

Garuda Sway can run a transparent local-only coding handoff with Ollama,
Qwen2.5-Coder 3B/7B, Aider, and optional Odysseus:

```bash
bash scripts/setup-local-agent-linux.sh --check
bash scripts/setup-local-agent-linux.sh --install --pull --model auto --backend cpu
bash scripts/local-agent.sh chat --model auto
bash scripts/local-agent.sh run --model auto --iterations 1
bash scripts/prepare-odysseus-handoff.sh --clipboard
bash scripts/local-agent.sh logs
```

The runner refuses protected branches, detached HEAD, dirty trees, and concurrent
agents; it records prompts, events, transcripts, raw model history, patches,
tests, and final state. It may commit locally but never pushes. Full instructions
live in [`.agent/LOCAL-MODEL-HANDOFF.md`](.agent/LOCAL-MODEL-HANDOFF.md).

## Development references

- [Visual overhaul contract](.agent/VISUAL-OVERHAUL.md)
- [Overhaul implementation matrix](.agent/OVERHAUL-IMPLEMENTATION.md)
- [Overhaul plan](.agent/OVERHAUL-PLAN.md)
- [Concept and balance notes](.agent/CONCEPT-ITERATION.md)
- [Playable-state ledger](.agent/PLAYABLE-STATE.md)
- [Gate-ordered backlog](.agent/backlog.md)
- [Windows/Linux launch and unification runbook](.agent/LAUNCH-AND-UNIFY-RUNBOOK.md)
