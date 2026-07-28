# FLUX focused overhaul directive

## Purpose

Evolve FLUX through small, verified vertical slices. Preserve working gameplay, deterministic simulation, remote authority, Linux and Windows launch paths, stable identifiers, and the last known playable state. Change only systems required by the requested feature or systems whose adaptation directly improves its synergy.

## Canonical names

Character names and the previously approved character ability names are canonical and must not be simplified, renamed, abbreviated in content data, or replaced with generic labels. They may be shown compactly in the HUD and fully in tooltips, menus, the loadout builder, and the guide.

### Der Rote Baron
- Passive: COLD ASHES
- Actives: CRIMSON COMET, NIGHT FLAK, RIME WING
- Ultimate: THE DEAD SKY

### Treevor
- Passive: DEEP ROOTS
- Actives: ROOT RAMPART, BRANCH GALE, EMBER SEED
- Ultimate: CROWN OF THE WILDFIRE

### S. Wayne
- Human; Void / Light affinities
- Passive: BETWEEN SHADOWS
- Actives: PRISM TRIPWIRE, BURROWED SHADOW, Ray
- Ultimate: Sun Grid

### Steezo
- Passive: QUESTIONABLE ENGINEERING
- Actives: SPARK KEG, PRISM TRIPWIRE, COIL HOPPER
- Ultimate: PERFECTLY SAFE MACHINE

### Oh Tipi
- Passive: LIVING CURRENT
- Actives: TIDELINE, FLASH FREEZE, EEL STEP
- Ultimate: STORMTIDE BASIN

### Oll'I
- Passive: LABYRINTH MOMENTUM
- Actives: SUNHORN CHARGE, FURNACE STOMP, MIRROR BULWARK
- Ultimate: THE BURNING MAZE

### Fluup
- Passive: STORMWEIGHT
- Actives: THUNDER SHOVE, SQUALL LEAP, RIME CRASH
- Ultimate: BAD WEATHER

## Simple system names

Use short, direct player-facing names. Preserve stable internal IDs and add compatibility aliases when renaming existing content.

Primary elements:
- Earth
- Fire
- Water
- Wind
- Ice
- Charge
- Light
- Void

Primary races:
- Human
- Dwarf
- Gnome
- Hobbit
- Elf
- Orc
- Troll
- Minotaur
- Seakin
- Wyrm
- Stoneborn
- Treefolk
- Sylph
- Undead
- Goblin
- Nymph

Preferred mode labels:
- Freeplay
- Duel
- Control
- Wild
- Survival
- Siege
- Draft
- Battle Royale

Avoid ceremonial synonyms when a standard gameplay term is clearer. Internal legacy mode IDs may remain unchanged for saves and network compatibility.

## Minimal text policy

Gameplay should communicate primarily through shape, color, animation, sound, spatial changes, icons, meters, cooldown masks, targeting previews, and short notifications.

During live play, show text only when it changes an immediate decision:
- objective changes;
- successful or failed interaction reads;
- interrupts, reflects, breaks, revives, eliminations, reconnects, and round states;
- ability unavailable reason when the player attempts it;
- concise tutorial prompts;
- critical network state.

Do not show persistent prose over combat. Long descriptions belong in menus, hover/focus tooltips, loadout inspection, freeplay settings, and the guide.

Notification rules:
- Prefer one to three words.
- Merge repeated events.
- Use a short lockout to prevent notification spam.
- Never obscure aim, targets, hazards, cooldowns, or movement routes.
- Use icons with text as a secondary clarification.

## HUD and GUI direction

Use the information hierarchy of mature action RTS/MOBA interfaces without copying their art or exact layout.

Live HUD:
- compact character portrait or silhouette;
- health and Flux as the dominant resource bars;
- FLOW as a smaller movement meter;
- centered or lower action bar with primary, three active slots, and ultimate;
- hotkey in each slot;
- clear cooldown sweep;
- exact Flux cost when relevant;
- disabled-state reason on attempted use or hover;
- ultimate charge ring or bar;
- small objective and score strip at the top;
- compact team roster;
- small event feed at an edge;
- contextual target, interaction, or status indicators near the world object rather than paragraphs in the HUD.

Menus:
- dense but readable panels;
- icon-first choices;
- progressive disclosure;
- short labels;
- hover/focus tooltips for full mechanics;
- immediate preview of stat, cost, and loadout changes;
- no decorative text that competes with choices.

The action bar must remain usable with mouse, keyboard, and controller. It must display semantic bindings, including multiple bindings where configured.

## Flux economy

The player should feel wealthy in Flux and able to choose among several useful actions, but repeated unplanned casts must exhaust that freedom and create a punishable recovery period.

Target economy:
- a visibly large maximum pool;
- enough starting Flux for a varied opening sequence, not unlimited cycling;
- ability costs scaled by potential effect, reliability, range, area, persistence, mobility, defense, control, interaction potential, and counterplay;
- repeated casts reset or extend the recovery delay;
- recovery becomes meaningful after the player pauses casting;
- cooldowns prevent a single optimal spell from consuming the whole action language;
- misses, blocked casts, and invalid placements provide no reward;
- successful high-skill reads may grant small, bounded refunds or recovery acceleration;
- ordinary aim, primary fire, movement fundamentals, and positioning remain available at zero Flux;
- reaching zero Flux is a tactical state, not helplessness.

Initial tuning direction for the first tested slice:
- raise base maximum Flux substantially above the current 100;
- raise non-primary costs proportionally but not linearly;
- lengthen the post-cast recovery delay;
- keep recovery rate high enough that deliberate disengagement restores options;
- show projected cost and remaining casts in tooltips/freeplay diagnostics;
- add tests that reject unpayable abilities and verify a bounded burst-versus-recovery rhythm.

Do not add a hidden escalating tax. If later tests require anti-chain pressure beyond recovery delay and cooldowns, expose it as a clear meter or state.

## Freeplay start

The long-term startup target remains a cozy playable freeplay sanctuary that also provides host, join, match setup, loadouts, settings, controls, practice, spell experiments, bots, destruction reset, god mode, unlimited resources, cooldown controls, and debug overlays. Introduce it incrementally without removing currently working launch paths until the replacement is complete.

## Engineering loop

For each vertical slice:
1. inspect current implementation and tests;
2. state exact scope and non-goals;
3. implement the smallest coherent change;
4. preserve stable IDs or add migration;
5. update deterministic tests;
6. run syntax and relevant test suites;
7. launch the real desktop and server paths where available;
8. review the diff for unrelated changes;
9. record exact verification and limitations in `.agent/PLAYABLE-STATE.md`;
10. commit only a known-playable state.

Never claim a test or launch succeeded unless it was actually executed.
