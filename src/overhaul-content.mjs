const freeze = (value) => Object.freeze(value);
const clamp = (value, min, max) => Math.max(min, Math.min(max, value));

export const ELEMENTS = freeze([
  freeze({ id: "earth", name: "Earth", legacy: ["stone", "nature"], glyph: "◆", identity: "terrain, growth, mass", tags: ["solid", "rooted", "brittle", "grounded"] }),
  freeze({ id: "fire", name: "Fire", legacy: ["ember"], glyph: "▲", identity: "heat, ignition, pressure", tags: ["burning", "smoke", "heated"] }),
  freeze({ id: "water", name: "Water", legacy: ["tide"], glyph: "≈", identity: "flow, wet fields, redirection", tags: ["wet", "flowing", "healing"] }),
  freeze({ id: "wind", name: "Wind", legacy: ["gale"], glyph: "↝", identity: "force, lift, redirection", tags: ["gust", "lifted", "dispersed"] }),
  freeze({ id: "ice", name: "Ice", legacy: ["frost", "cold"], glyph: "✣", identity: "friction, brittle cover, freeze", tags: ["frozen", "slippery", "brittle"] }),
  freeze({ id: "charge", name: "Charge", legacy: ["volt", "electricity", "lightning"], glyph: "ϟ", identity: "conduction, interruption, stored power", tags: ["charged", "conductive", "overloaded"] }),
  freeze({ id: "light", name: "Light", legacy: ["prism", "refraction"], glyph: "◇", identity: "beams, reveal, refraction", tags: ["lit", "reflective", "refractive"] }),
  freeze({ id: "dark", name: "Dark", legacy: ["null", "veil", "void"], glyph: "●", identity: "concealment, pull, decay", tags: ["shadowed", "corrupted", "silenced"] }),
]);

export const ELEMENT_ALIASES = freeze(Object.fromEntries(
  ELEMENTS.flatMap((element) => [element.id, ...element.legacy].map((alias) => [alias, element.id])),
));

export function canonicalElement(id) {
  return ELEMENT_ALIASES[String(id ?? "").toLowerCase()] ?? null;
}

const race = ({ id, name, sizes, affinities, trait, feature, glyph, modifiers, budgetCost }) => freeze({
  id,
  name,
  sizes: freeze([...sizes]),
  affinities: freeze(affinities.map((entry) => freeze({ ...entry }))),
  trait: freeze({ ...trait }),
  feature,
  glyph,
  modifiers: freeze({ health: 1, speed: 1, flux: 1, flow: 1, knockback: 1, ...modifiers }),
  budgetCost,
});

export const RACE_ARCHETYPES = freeze([
  race({ id: "human", name: "Human", sizes: [2, 3, 4], affinities: [{ id: "light", strength: 2 }], trait: { id: "adapt", name: "Adapt", rule: "Shift one minor stat before a match." }, feature: "open circlet", glyph: "⌃", modifiers: { flux: 1.03, health: 0.99 }, budgetCost: 4 }),
  race({ id: "dwarf", name: "Dwarf", sizes: [2, 3], affinities: [{ id: "earth", strength: 2 }, { id: "light", strength: 1 }], trait: { id: "grounded", name: "Grounded", rule: "Reduced forced movement while touching solid ground." }, feature: "square beard", glyph: "⋈", modifiers: { health: 1.06, speed: 0.96, knockback: 0.88 }, budgetCost: 7 }),
  race({ id: "gnome", name: "Gnome", sizes: [1, 2], affinities: [{ id: "charge", strength: 2 }, { id: "light", strength: 1 }], trait: { id: "tinker", name: "Tinker", rule: "Personal constructs arm and rebuild slightly faster." }, feature: "high cap", glyph: "△", modifiers: { health: 0.94, speed: 1.03, flux: 1.06 }, budgetCost: 7 }),
  race({ id: "hobbit", name: "Hobbit", sizes: [1, 2], affinities: [{ id: "earth", strength: 1 }, { id: "dark", strength: 1 }], trait: { id: "low-profile", name: "Low Profile", rule: "Quicker recovery after a near miss; low mass increases knockback." }, feature: "bare feet", glyph: "∪", modifiers: { health: 0.95, speed: 1.04, knockback: 1.08 }, budgetCost: 5 }),
  race({ id: "elf", name: "Elf", sizes: [2, 3], affinities: [{ id: "wind", strength: 2 }, { id: "light", strength: 1 }, { id: "earth", strength: 1 }], trait: { id: "poise", name: "Poise", rule: "Improved air redirection and precise projectile control." }, feature: "long ears", glyph: "‹›", modifiers: { health: 0.94, speed: 1.06 }, budgetCost: 8 }),
  race({ id: "orc", name: "Orc", sizes: [3, 4, 5], affinities: [{ id: "fire", strength: 2 }, { id: "earth", strength: 1 }], trait: { id: "commit", name: "Commit", rule: "Heavy actions resist interruption after startup." }, feature: "tusks", glyph: "ᚢ", modifiers: { health: 1.07, speed: 0.96 }, budgetCost: 7 }),
  race({ id: "troll", name: "Troll", sizes: [4, 5], affinities: [{ id: "earth", strength: 2 }, { id: "water", strength: 1 }], trait: { id: "mend", name: "Mend", rule: "Recover health slowly after avoiding damage; burning pauses recovery." }, feature: "moss horns", glyph: "Y", modifiers: { health: 1.09, speed: 0.94, flux: 0.96 }, budgetCost: 8 }),
  race({ id: "minotaur", name: "Minotaur", sizes: [4, 5], affinities: [{ id: "earth", strength: 2 }, { id: "fire", strength: 1 }, { id: "light", strength: 1 }], trait: { id: "momentum", name: "Momentum", rule: "Sustained movement increases structural impact, never spell damage." }, feature: "wide horns", glyph: "⋔", modifiers: { health: 1.08, speed: 0.95, knockback: 0.84 }, budgetCost: 9 }),
  race({ id: "seakin", name: "Seakin", sizes: [2, 3, 4], affinities: [{ id: "water", strength: 2 }, { id: "ice", strength: 1 }, { id: "charge", strength: 1 }], trait: { id: "current", name: "Current", rule: "More steering in self-made water and wet routes." }, feature: "cheek fins", glyph: "⋉⋊", modifiers: { health: 0.97, flow: 1.07 }, budgetCost: 8 }),
  race({ id: "scaleheir", name: "Scaleheir", sizes: [3, 4, 5], affinities: [{ id: "fire", strength: 1 }, { id: "wind", strength: 2 }, { id: "ice", strength: 2 }], trait: { id: "wings", name: "Wings", rule: "One stronger aerial commitment; reduced FLOW capacity." }, feature: "scaled wings", glyph: "〽", modifiers: { health: 1.03, speed: 0.98, flux: 1.02, flow: 0.94, knockback: 0.86 }, budgetCost: 9 }),
  race({ id: "stonewrought", name: "Stonewrought", sizes: [3, 4, 5], affinities: [{ id: "earth", strength: 2 }, { id: "light", strength: 1 }], trait: { id: "brace", name: "Brace", rule: "Brief armor while touching a personal structure; slow recovery afterward." }, feature: "stone shoulders", glyph: "◆◆", modifiers: { health: 1.08, speed: 0.94, knockback: 0.84 }, budgetCost: 8 }),
  race({ id: "rootwarden", name: "Rootwarden", sizes: [4, 5], affinities: [{ id: "earth", strength: 2 }, { id: "wind", strength: 1 }, { id: "fire", strength: 1 }], trait: { id: "roots", name: "Roots", rule: "Stability and recovery on personal growth; sustained fire is dangerous." }, feature: "branch crown", glyph: "♜", modifiers: { health: 1.09, speed: 0.93, knockback: 0.85 }, budgetCost: 9 }),
  race({ id: "sylph", name: "Sylph", sizes: [1, 2, 3], affinities: [{ id: "wind", strength: 2 }, { id: "charge", strength: 1 }], trait: { id: "float", name: "Float", rule: "Superior air redirect and lower fall commitment; very low mass." }, feature: "streamer wings", glyph: "≋", modifiers: { health: 0.92, speed: 1.07, flow: 1.04, knockback: 1.1 }, budgetCost: 8 }),
  race({ id: "undead", name: "Undead", sizes: [2, 3, 4], affinities: [{ id: "dark", strength: 2 }, { id: "ice", strength: 1 }, { id: "fire", strength: 1 }], trait: { id: "remnant", name: "Remnant", rule: "Convert one expiring personal field into a harmless remnant; reduced healing." }, feature: "rune ribs", glyph: "≡", modifiers: { health: 1.03, flow: 0.96 }, budgetCost: 8 }),
  race({ id: "goblin", name: "Goblin", sizes: [1, 2, 3], affinities: [{ id: "fire", strength: 1 }, { id: "charge", strength: 2 }, { id: "light", strength: 1 }], trait: { id: "salvage", name: "Salvage", rule: "Opponent-destroyed personal constructs refund bounded Flux." }, feature: "tool belt", glyph: "⌁", modifiers: { health: 0.93, speed: 1.05, flux: 1.05 }, budgetCost: 8 }),
  race({ id: "nymph", name: "Nymph", sizes: [1, 2, 3], affinities: [{ id: "water", strength: 2 }, { id: "earth", strength: 1 }, { id: "light", strength: 1 }], trait: { id: "bloom", name: "Bloom", rule: "Personal support fields strengthen after a clean elemental reaction." }, feature: "petal mantle", glyph: "✿", modifiers: { health: 0.94, speed: 1.03, flux: 1.04 }, budgetCost: 8 }),
]);

export const RACE_ALIASES = freeze({ wood_elf: "elf", night_elf: "elf", tideborn: "seakin", reefborn: "seakin", wyrmbound: "scaleheir", stonekin: "stonewrought", cairnkin: "stonewrought", ent: "rootwarden", treefolk: "rootwarden", ash_revenant: "undead", iron_orc: "orc", moss_troll: "troll" });

export function getRaceArchetype(id) {
  const resolved = RACE_ALIASES[id] ?? id;
  return RACE_ARCHETYPES.find((entry) => entry.id === resolved) ?? null;
}

const ability = (definition) => freeze({ type: "active", tier: 1, points: 3, fluxCost: 28, cooldown: 1, startup: 0.1, recovery: 0.15, roles: freeze([]), tags: freeze([]), counterplay: freeze([]), ...definition, element: canonicalElement(definition.element), roles: freeze([...(definition.roles ?? [])]), tags: freeze([...(definition.tags ?? [])]), counterplay: freeze([...(definition.counterplay ?? [])]) });

export const ABILITY_CATALOG = freeze([
  ability({ id: "stone-shot", name: "Stone Shot", element: "earth", kind: "projectile", points: 2, fluxCost: 12, cooldown: 0.35, roles: ["damage"], tags: ["heavy", "brittle"], counterplay: ["narrow"] }),
  ability({ id: "root-rampart", name: "ROOT RAMPART", element: "earth", kind: "wall", tier: 2, points: 5, fluxCost: 42, cooldown: 4.5, startup: 0.35, recovery: 0.25, roles: ["defense", "terrain"], tags: ["solid", "rooted", "breakable"], counterplay: ["breakable", "visible-startup"] }),
  ability({ id: "furnace-stomp", name: "FURNACE STOMP", element: "earth", kind: "shockwave", tier: 2, points: 5, fluxCost: 38, cooldown: 3.8, startup: 0.32, roles: ["control", "terrain"], tags: ["heavy", "heated"], counterplay: ["close-range", "visible-startup"] }),
  ability({ id: "burrowed-shadow", name: "BURROWED SHADOW", element: "dark", kind: "blink-decoy", tier: 2, points: 5, fluxCost: 36, cooldown: 4, roles: ["mobility", "deception"], tags: ["shadowed", "anchor"], counterplay: ["visible-marker"] }),
  ability({ id: "seed-burst", name: "Seed Burst", element: "earth", kind: "mine", points: 3, fluxCost: 24, cooldown: 1.8, roles: ["control", "terrain"], tags: ["growth", "breakable"], counterplay: ["delayed", "breakable"] }),
  ability({ id: "ember-seed", name: "EMBER SEED", element: "fire", kind: "reactive-seed", tier: 2, points: 5, fluxCost: 40, cooldown: 4.2, roles: ["control", "terrain"], tags: ["growth", "burning", "reactive"], counterplay: ["delayed", "breakable"] }),
  ability({ id: "campfire-feint", name: "CAMPFIRE FEINT", element: "fire", kind: "turn-mine", points: 4, fluxCost: 30, cooldown: 2.7, roles: ["deception", "control"], tags: ["burning", "redirectable"], counterplay: ["visible-arm", "breakable"] }),
  ability({ id: "crimson-comet", name: "CRIMSON COMET", element: "fire", kind: "dash-trail", tier: 2, points: 5, fluxCost: 40, cooldown: 3.4, roles: ["mobility", "damage"], tags: ["burning", "committed"], counterplay: ["committed-line", "recovery"] }),
  ability({ id: "spark-keg", name: "SPARK KEG", element: "fire", kind: "charged-construct", tier: 2, points: 5, fluxCost: 38, cooldown: 4.5, roles: ["construct", "control"], tags: ["burning", "conductive", "breakable"], counterplay: ["breakable", "delayed"] }),
  ability({ id: "fire-fan", name: "Fire Fan", element: "fire", kind: "fan", points: 3, fluxCost: 26, cooldown: 1.2, roles: ["damage", "control"], tags: ["burning"], counterplay: ["short-range"] }),
  ability({ id: "tideline", name: "TIDELINE", element: "water", kind: "moving-field", tier: 2, points: 4, fluxCost: 32, cooldown: 3, roles: ["terrain", "control"], tags: ["wet", "flowing"], counterplay: ["narrow-route"] }),
  ability({ id: "surge", name: "Surge", element: "water", kind: "wave", points: 3, fluxCost: 24, cooldown: 1.5, roles: ["control", "support"], tags: ["wet", "push"], counterplay: ["visible-wave"] }),
  ability({ id: "spring", name: "Spring", element: "water", kind: "support-field", points: 4, fluxCost: 36, cooldown: 5, roles: ["support", "terrain"], tags: ["wet", "healing"], counterplay: ["stationary", "contestable"] }),
  ability({ id: "pocket-tempest", name: "POCKET TEMPEST", element: "wind", kind: "orbit", tier: 2, points: 5, fluxCost: 36, cooldown: 3.5, roles: ["defense", "control"], tags: ["gust", "redirect"], counterplay: ["close-radius", "duration"] }),
  ability({ id: "branch-gale", name: "BRANCH GALE", element: "wind", kind: "wide-cone", tier: 2, points: 5, fluxCost: 38, cooldown: 3.2, roles: ["control"], tags: ["gust", "push"], counterplay: ["visible-startup"] }),
  ability({ id: "squall-leap", name: "SQUALL LEAP", element: "wind", kind: "launch-redirect", tier: 2, points: 5, fluxCost: 34, cooldown: 3.8, roles: ["mobility"], tags: ["lifted", "redirect"], counterplay: ["airborne", "limited-redirect"] }),
  ability({ id: "gust-ring", name: "Gust Ring", element: "wind", kind: "ring", points: 3, fluxCost: 24, cooldown: 1.8, roles: ["control", "defense"], tags: ["gust", "push"], counterplay: ["small-safe-center"] }),
  ability({ id: "flash-freeze", name: "FLASH FREEZE", element: "ice", kind: "convert-field", tier: 2, points: 5, fluxCost: 34, cooldown: 3.8, roles: ["terrain", "control"], tags: ["frozen", "brittle"], counterplay: ["requires-wet"] }),
  ability({ id: "rime-wing", name: "RIME WING", element: "ice", kind: "air-brake", tier: 2, points: 4, fluxCost: 30, cooldown: 3, roles: ["mobility", "defense"], tags: ["frozen", "platform"], counterplay: ["short-duration", "breakable"] }),
  ability({ id: "rime-crash", name: "RIME CRASH", element: "ice", kind: "landing-fan", tier: 2, points: 5, fluxCost: 38, cooldown: 4, roles: ["control", "terrain"], tags: ["frozen", "brittle", "heavy"], counterplay: ["requires-air", "visible-landing"] }),
  ability({ id: "ice-needle", name: "Ice Needle", element: "ice", kind: "projectile", points: 2, fluxCost: 14, cooldown: 0.4, roles: ["damage", "control"], tags: ["chilled"], counterplay: ["narrow"] }),
  ability({ id: "eel-step", name: "EEL STEP", element: "charge", kind: "surface-dash", tier: 2, points: 4, fluxCost: 28, cooldown: 2.6, roles: ["mobility"], tags: ["charged", "conductive"], counterplay: ["requires-surface", "visible-end"] }),
  ability({ id: "thunder-shove", name: "THUNDER SHOVE", element: "charge", kind: "short-cone", tier: 2, points: 4, fluxCost: 30, cooldown: 2.4, roles: ["damage", "control"], tags: ["charged", "interrupt"], counterplay: ["short-range"] }),
  ability({ id: "coil-hopper", name: "COIL HOPPER", element: "charge", kind: "jump-pad", tier: 2, points: 5, fluxCost: 40, cooldown: 5, roles: ["construct", "mobility"], tags: ["charged", "breakable", "shared"], counterplay: ["shared-use", "breakable"] }),
  ability({ id: "arc-chain", name: "Arc Chain", element: "charge", kind: "chain", points: 4, fluxCost: 34, cooldown: 2.4, roles: ["damage", "interrupt"], tags: ["charged", "conductive"], counterplay: ["distance-break", "wet-risk"] }),
  ability({ id: "prism-tripwire", name: "PRISM TRIPWIRE", element: "light", kind: "refract-line", tier: 2, points: 5, fluxCost: 36, cooldown: 4, roles: ["construct", "control"], tags: ["lit", "refractive", "breakable"], counterplay: ["visible-line", "breakable"] }),
  ability({ id: "sunhorn-charge", name: "SUNHORN CHARGE", element: "light", kind: "heavy-charge", tier: 2, points: 5, fluxCost: 38, cooldown: 3.8, roles: ["mobility", "damage", "destruction"], tags: ["lit", "heavy"], counterplay: ["poor-turning", "recovery"] }),
  ability({ id: "mirror-bulwark", name: "MIRROR BULWARK", element: "light", kind: "reflect-shield", tier: 2, points: 5, fluxCost: 40, cooldown: 4.5, roles: ["defense"], tags: ["reflective", "breakable"], counterplay: ["directional", "breakable"] }),
  ability({ id: "ray", name: "Ray", element: "light", kind: "beam", points: 3, fluxCost: 26, cooldown: 1.4, roles: ["damage", "reveal"], tags: ["lit", "refractive"], counterplay: ["windup", "line"] }),
  ability({ id: "night-flak", name: "NIGHT FLAK", element: "dark", kind: "delayed-bursts", tier: 2, points: 5, fluxCost: 38, cooldown: 3.5, roles: ["control", "damage"], tags: ["shadowed", "delayed"], counterplay: ["telegraphed-zones"] }),
  ability({ id: "void-pull", name: "Void Pull", element: "dark", kind: "pull-field", points: 4, fluxCost: 34, cooldown: 3, roles: ["control"], tags: ["corrupted", "pull"], counterplay: ["visible-center", "duration"] }),
  ability({ id: "shade-swap", name: "Shade Swap", element: "dark", kind: "decoy-swap", points: 4, fluxCost: 32, cooldown: 3.4, roles: ["mobility", "deception"], tags: ["shadowed", "anchor"], counterplay: ["destroy-anchor"] }),
  ability({ id: "stone-break", name: "Stone Break", element: "dark", kind: "construct-decay", points: 5, fluxCost: 42, cooldown: 5, roles: ["control", "destruction"], tags: ["corrupted", "decay"], counterplay: ["short-range", "high-cost"] }),
  ability({ id: "the-dead-sky", name: "THE DEAD SKY", type: "ultimate", element: "dark", kind: "formation", tier: 3, points: 8, fluxCost: 0, cooldown: 0, startup: 0.8, recovery: 0.4, roles: ["control", "damage"], tags: ["shadowed", "burning", "frozen"], counterplay: ["telegraphed-lanes", "breakable-safe-routes"] }),
  ability({ id: "crown-wildfire", name: "CROWN OF THE WILDFIRE", type: "ultimate", element: "earth", kind: "living-structure", tier: 3, points: 8, fluxCost: 0, cooldown: 0, startup: 0.9, recovery: 0.4, roles: ["terrain", "control"], tags: ["growth", "gust", "burning", "breakable"], counterplay: ["breakable-parts", "telegraphed-growth"] }),
  ability({ id: "there-and-back", name: "THERE AND BACK AGAIN", type: "ultimate", element: "wind", kind: "route-dash", tier: 3, points: 8, fluxCost: 0, cooldown: 0, startup: 0.65, recovery: 0.35, roles: ["mobility", "damage"], tags: ["gust", "shadowed", "burning"], counterplay: ["marked-route"] }),
  ability({ id: "safe-machine", name: "PERFECTLY SAFE MACHINE", type: "ultimate", element: "charge", kind: "multi-construct", tier: 3, points: 8, fluxCost: 0, cooldown: 0, startup: 0.9, recovery: 0.4, roles: ["construct", "control"], tags: ["charged", "burning", "refractive", "breakable"], counterplay: ["breakable-parts"] }),
  ability({ id: "stormtide-basin", name: "STORMTIDE BASIN", type: "ultimate", element: "water", kind: "basin", tier: 3, points: 8, fluxCost: 0, cooldown: 0, startup: 0.8, recovery: 0.35, roles: ["terrain", "control"], tags: ["wet", "frozen", "charged"], counterplay: ["safe-islands", "delayed-discharge"] }),
  ability({ id: "burning-maze", name: "THE BURNING MAZE", type: "ultimate", element: "earth", kind: "maze", tier: 3, points: 8, fluxCost: 0, cooldown: 0, startup: 0.95, recovery: 0.45, roles: ["terrain", "control"], tags: ["solid", "lit", "burning", "breakable"], counterplay: ["lit-exits", "breakable-walls"] }),
  ability({ id: "bad-weather", name: "BAD WEATHER", type: "ultimate", element: "wind", kind: "storm-front", tier: 3, points: 8, fluxCost: 0, cooldown: 0, startup: 0.8, recovery: 0.4, roles: ["control", "terrain"], tags: ["gust", "charged", "frozen"], counterplay: ["marked-gust-lanes", "delayed-discharge"] }),
  ability({ id: "earthwake", name: "Earthwake", type: "ultimate", element: "earth", kind: "collapse-line", tier: 3, points: 8, fluxCost: 0, roles: ["destruction", "control"], tags: ["heavy", "brittle"], counterplay: ["long-windup"] }),
  ability({ id: "sun-grid", name: "Sun Grid", type: "ultimate", element: "light", kind: "beam-grid", tier: 3, points: 8, fluxCost: 0, roles: ["damage", "control"], tags: ["lit", "refractive"], counterplay: ["visible-grid"] }),
  ability({ id: "deep-spring", name: "Deep Spring", type: "ultimate", element: "water", kind: "support-basin", tier: 3, points: 8, fluxCost: 0, roles: ["support", "terrain"], tags: ["wet", "healing"], counterplay: ["contestable"] }),
  ability({ id: "sky-hook", name: "Sky Hook", type: "ultimate", element: "wind", kind: "grapple-web", tier: 3, points: 8, fluxCost: 0, roles: ["mobility", "control"], tags: ["gust", "tether"], counterplay: ["cuttable-lines"] }),
  ability({ id: "last-lantern", name: "Last Lantern", type: "ultimate", element: "dark", kind: "remnant-field", tier: 3, points: 8, fluxCost: 0, roles: ["support", "deception"], tags: ["shadowed", "lit"], counterplay: ["visible-anchor"] }),
  ability({ id: "stoneheart", name: "Stoneheart", type: "ultimate", element: "earth", kind: "armor-structure", tier: 3, points: 8, fluxCost: 0, roles: ["defense", "terrain"], tags: ["solid", "breakable"], counterplay: ["breakable-shell"] }),
  ability({ id: "moss-flood", name: "Moss Flood", type: "ultimate", element: "water", kind: "growth-wave", tier: 3, points: 8, fluxCost: 0, roles: ["support", "terrain"], tags: ["wet", "growth"], counterplay: ["burnable-growth"] }),
  ability({ id: "glass-moon", name: "Glass Moon", type: "ultimate", element: "light", kind: "orbit-lens", tier: 3, points: 8, fluxCost: 0, roles: ["damage", "defense"], tags: ["refractive", "breakable"], counterplay: ["breakable-lens"] }),
  ability({ id: "small-world", name: "Small World", type: "ultimate", element: "charge", kind: "gadget-ring", tier: 3, points: 8, fluxCost: 0, roles: ["construct", "control"], tags: ["charged", "breakable"], counterplay: ["shared-use"] }),
  ability({ id: "bloom", name: "Bloom", type: "ultimate", element: "earth", kind: "support-growth", tier: 3, points: 8, fluxCost: 0, roles: ["support", "terrain"], tags: ["growth", "wet", "lit"], counterplay: ["breakable-flowers"] }),
]);

const affinity = (id, strength) => freeze({ id: canonicalElement(id), strength });
const character = (definition) => freeze({ ...definition, affinities: freeze(definition.affinities.map(([id, strength]) => affinity(id, strength))), activeAbilityIds: freeze([...definition.activeAbilityIds]), statBonuses: freeze({ ...definition.statBonuses }), drawbacks: freeze([...(definition.drawbacks ?? [])]), passive: freeze({ ...definition.passive }) });

export const CHARACTER_ROSTER = freeze([
  character({ id: "mara", name: "Mara", raceId: "human", size: 3, affinities: [["light", 1], ["wind", 1]], identity: "adaptive mid-range captain", statBonuses: { flux: 4 }, passive: { name: "SECOND PLAN", cost: 5, rule: "Once per round, swap one active at a sanctuary station." }, activeAbilityIds: ["ray", "gust-ring", "stone-shot"], ultimateAbilityId: "sun-grid", drawbacks: ["No extreme stat edge"], drawbackCredit: 4 }),
  character({ id: "brum", name: "Brum", raceId: "dwarf", size: 3, affinities: [["earth", 2], ["light", 1]], identity: "anchored cover fighter", statBonuses: { health: 5 }, passive: { name: "HOLD FAST", cost: 6, rule: "Brief forced-movement resistance after creating cover." }, activeAbilityIds: ["root-rampart", "mirror-bulwark", "stone-shot"], ultimateAbilityId: "stoneheart", drawbacks: ["Reduced air control"], drawbackCredit: 7 }),
  character({ id: "nix", name: "Nix", raceId: "gnome", size: 1, affinities: [["charge", 2], ["light", 1]], identity: "tiny shared-device engineer", statBonuses: { flux: 5, speed: 2 }, passive: { name: "QUICK FIX", cost: 6, rule: "Repair one surviving personal construct after a clean dodge." }, activeAbilityIds: ["coil-hopper", "prism-tripwire", "arc-chain"], ultimateAbilityId: "small-world", drawbacks: ["Low health", "Low mass"], drawbackCredit: 9 }),
  character({ id: "samwise", name: "Samwise DeWayne", raceId: "hobbit", size: 1, affinities: [["wind", 2], ["dark", 1], ["fire", 1]], identity: "low-profile route trickster", statBonuses: { recovery: 4 }, passive: { name: "SMALL TARGET, BIG EXIT", cost: 7, rule: "A narrow miss grants faster recovery with a strict lockout." }, activeAbilityIds: ["pocket-tempest", "burrowed-shadow", "campfire-feint"], ultimateAbilityId: "there-and-back", drawbacks: ["Low reach", "Low durability"], drawbackCredit: 10 }),
  character({ id: "aerwyn", name: "Aerwyn", raceId: "elf", size: 2, affinities: [["wind", 2], ["light", 1], ["earth", 1]], identity: "precise redirect duelist", statBonuses: { speed: 4, control: 3 }, passive: { name: "THREAD THE TURN", cost: 7, rule: "A successful reflection guides one slower projectile." }, activeAbilityIds: ["gust-ring", "ray", "seed-burst"], ultimateAbilityId: "glass-moon", drawbacks: ["Fragile"], drawbackCredit: 7 }),
  character({ id: "fluup", name: "Fluup", raceId: "orc", size: 4, affinities: [["charge", 2], ["wind", 1], ["ice", 1]], identity: "storm momentum bruiser", statBonuses: { health: 4, impact: 4 }, passive: { name: "STORMWEIGHT", cost: 7, rule: "A redirected landing stores one bounded movement charge." }, activeAbilityIds: ["thunder-shove", "squall-leap", "rime-crash"], ultimateAbilityId: "bad-weather", drawbacks: ["Heavy recovery after misses"], drawbackCredit: 8 }),
  character({ id: "mog", name: "Mog", raceId: "troll", size: 5, affinities: [["earth", 2], ["water", 1]], identity: "regenerating route blocker", statBonuses: { health: 7 }, passive: { name: "MOSS MEND", cost: 7, rule: "Regenerate after avoiding damage; burning suspends it." }, activeAbilityIds: ["root-rampart", "surge", "seed-burst"], ultimateAbilityId: "moss-flood", drawbacks: ["Huge target", "Slow response"], drawbackCredit: 11 }),
  character({ id: "olli", name: "Oll'I", raceId: "minotaur", size: 5, affinities: [["earth", 2], ["fire", 1], ["light", 1]], identity: "structural momentum breaker", statBonuses: { health: 6, impact: 5 }, passive: { name: "LABYRINTH MOMENTUM", cost: 8, rule: "Unbroken movement increases structural impact only." }, activeAbilityIds: ["sunhorn-charge", "furnace-stomp", "mirror-bulwark"], ultimateAbilityId: "burning-maze", drawbacks: ["Poor turning during commitment", "Long miss recovery"], drawbackCredit: 12 }),
  character({ id: "oh-tipi", name: "Oh Tipi", raceId: "seakin", size: 2, affinities: [["water", 2], ["ice", 1], ["charge", 1]], identity: "conductive field skirmisher", statBonuses: { flow: 5, control: 3 }, passive: { name: "LIVING CURRENT", cost: 7, rule: "Gain steering in personal Water without a damage bonus." }, activeAbilityIds: ["tideline", "flash-freeze", "eel-step"], ultimateAbilityId: "stormtide-basin", drawbacks: ["Field-dependent peak control"], drawbackCredit: 6 }),
  character({ id: "yrsa", name: "Yrsa", raceId: "scaleheir", size: 4, affinities: [["ice", 2], ["wind", 1], ["fire", 1]], identity: "aerial cold-line hunter", statBonuses: { impact: 3, airControl: 4 }, passive: { name: "RIME DIVE", cost: 7, rule: "One committed aerial redirect primes a brittle landing." }, activeAbilityIds: ["rime-wing", "squall-leap", "fire-fan"], ultimateAbilityId: "sky-hook", drawbacks: ["Low FLOW capacity"], drawbackCredit: 8 }),
  character({ id: "gorum", name: "Gorum", raceId: "stonewrought", size: 4, affinities: [["earth", 2], ["light", 1]], identity: "living bulwark", statBonuses: { health: 6, armor: 4 }, passive: { name: "STONE SKIN", cost: 7, rule: "Personal cover grants brief armor followed by slow recovery." }, activeAbilityIds: ["root-rampart", "mirror-bulwark", "furnace-stomp"], ultimateAbilityId: "earthwake", drawbacks: ["Slow movement", "Large target"], drawbackCredit: 10 }),
  character({ id: "treevor", name: "Treevor", raceId: "rootwarden", size: 5, affinities: [["earth", 2], ["wind", 1], ["fire", 1]], identity: "giant living terrain tank", statBonuses: { health: 7, reach: 4 }, passive: { name: "DEEP ROOTS", cost: 8, rule: "Personal ground grants stability; sustained Fire remains dangerous." }, activeAbilityIds: ["root-rampart", "branch-gale", "ember-seed"], ultimateAbilityId: "crown-wildfire", drawbacks: ["Huge target", "Fire exposure"], drawbackCredit: 13 }),
  character({ id: "vey", name: "Vey", raceId: "sylph", size: 1, affinities: [["wind", 2], ["charge", 1]], identity: "weightless air-route specialist", statBonuses: { speed: 6, airControl: 5 }, passive: { name: "THIN AIR", cost: 7, rule: "One extra air redirect with sharply reduced impact resistance." }, activeAbilityIds: ["squall-leap", "eel-step", "gust-ring"], ultimateAbilityId: "sky-hook", drawbacks: ["Very fragile", "High knockback"], drawbackCredit: 12 }),
  character({ id: "rote-baron", name: "Der Rote Baron", raceId: "undead", size: 3, affinities: [["dark", 2], ["fire", 1], ["ice", 1]], identity: "airborne formation controller", statBonuses: { control: 4 }, passive: { name: "COLD ASHES", cost: 7, rule: "Expired personal Fire leaves a brief harmless chilled remnant." }, activeAbilityIds: ["crimson-comet", "night-flak", "rime-wing"], ultimateAbilityId: "the-dead-sky", drawbacks: ["Reduced conventional healing"], drawbackCredit: 7 }),
  character({ id: "steezo", name: "Steezo", raceId: "goblin", size: 1, affinities: [["fire", 1], ["charge", 2], ["light", 1]], identity: "volatile combo engineer", statBonuses: { flux: 4, speed: 3 }, passive: { name: "QUESTIONABLE ENGINEERING", cost: 7, rule: "Opponent-destroyed constructs refund bounded Flux; self-detonation does not." }, activeAbilityIds: ["spark-keg", "prism-tripwire", "coil-hopper"], ultimateAbilityId: "safe-machine", drawbacks: ["Fragile", "Construct-dependent"], drawbackCredit: 10 }),
  character({ id: "luma", name: "Luma", raceId: "nymph", size: 2, affinities: [["water", 2], ["earth", 1], ["light", 1]], identity: "reaction-driven field support", statBonuses: { flux: 4, control: 3 }, passive: { name: "AFTERBLOOM", cost: 7, rule: "A clean personal reaction strengthens the next support field, never direct damage." }, activeAbilityIds: ["spring", "seed-burst", "ray"], ultimateAbilityId: "bloom", drawbacks: ["Low stagger resistance", "Weak body pressure"], drawbackCredit: 9 }),
]);

export const SIZE_RULES = freeze({
  1: freeze({ label: "Tiny", health: 0.9, speed: 1.08, acceleration: 1.12, mass: 0.72, radius: 0.78, knockback: 1.15, airControl: 1.12, budgetCost: 5 }),
  2: freeze({ label: "Small", health: 0.95, speed: 1.04, acceleration: 1.07, mass: 0.86, radius: 0.9, knockback: 1.08, airControl: 1.06, budgetCost: 3 }),
  3: freeze({ label: "Medium", health: 1, speed: 1, acceleration: 1, mass: 1, radius: 1, knockback: 1, airControl: 1, budgetCost: 0 }),
  4: freeze({ label: "Large", health: 1.08, speed: 0.95, acceleration: 0.92, mass: 1.2, radius: 1.13, knockback: 0.9, airControl: 0.92, budgetCost: 5 }),
  5: freeze({ label: "Huge", health: 1.16, speed: 0.9, acceleration: 0.84, mass: 1.45, radius: 1.28, knockback: 0.8, airControl: 0.84, budgetCost: 8 }),
});

export const REACTION_RULES = freeze([
  freeze({ id: "steam", priority: 10, inputs: ["burning", "wet"], output: "steam", duration: 1.8, consumes: ["burning"], cue: "white burst", counterplay: "leave the marked cloud" }),
  freeze({ id: "freeze", priority: 20, inputs: ["wet", "frozen"], output: "ice", duration: 3.2, consumes: [], cue: "blue crystal edge", counterplay: "break or avoid the brittle surface" }),
  freeze({ id: "melt", priority: 30, inputs: ["burning", "frozen"], output: "meltwater", duration: 2, consumes: ["burning", "frozen"], cue: "crack and hiss", counterplay: "reposition before the surface changes" }),
  freeze({ id: "conduct", priority: 40, inputs: ["wet", "charged"], output: "conducted", duration: 0.7, consumes: ["charged"], cue: "branching arcs", counterplay: "leave connected wet regions before discharge" }),
  freeze({ id: "fan-fire", priority: 50, inputs: ["burning", "gust"], output: "driven-fire", duration: 1.4, consumes: [], cue: "flame direction arrow", counterplay: "cross behind the wind source" }),
  freeze({ id: "clear-smoke", priority: 60, inputs: ["smoke", "gust"], output: "clear", duration: 0, consumes: ["smoke"], cue: "fast dispersal", counterplay: "none; smoke ownership already paid" }),
  freeze({ id: "mud", priority: 70, inputs: ["wet", "grounded"], output: "mud", duration: 2.8, consumes: [], cue: "dark ripples", counterplay: "jump, route around, or dry it" }),
  freeze({ id: "growth", priority: 80, inputs: ["wet", "rooted"], output: "growth", duration: 4, consumes: [], cue: "green pulse", counterplay: "cut or burn the new growth" }),
  freeze({ id: "magma", priority: 90, inputs: ["burning", "solid"], output: "heated-stone", duration: 2.4, consumes: ["burning"], cue: "orange cracks", counterplay: "avoid grounded contact" }),
  freeze({ id: "refract-water", priority: 100, inputs: ["refractive", "wet"], output: "split-light", duration: 0.5, consumes: [], cue: "forked ray", counterplay: "read the lens angle" }),
  freeze({ id: "refract-ice", priority: 110, inputs: ["refractive", "frozen"], output: "ice-prism", duration: 1, consumes: [], cue: "crystal ray", counterplay: "break the lens" }),
  freeze({ id: "light-dark", priority: 120, inputs: ["lit", "shadowed"], output: "interference", duration: 1.2, consumes: [], cue: "high-contrast edge", counterplay: "cross the unstable boundary deliberately" }),
  freeze({ id: "void-decay", priority: 130, inputs: ["corrupted", "breakable"], output: "decaying", duration: 1.6, consumes: ["corrupted"], cue: "dark fracture", counterplay: "destroy the void source or repair after decay" }),
  freeze({ id: "shatter", priority: 140, inputs: ["heavy", "brittle"], output: "shattered", duration: 0, consumes: ["brittle"], cue: "large fracture", counterplay: "move before the committed heavy hit" }),
]);

export const MOVEMENT_GRAMMAR = freeze({
  states: freeze(["grounded", "rising", "airborne", "falling", "sliding", "air-dodging", "wall-contact", "wall-jumping", "vaulting", "launched", "grappled", "charging", "stunned", "rooted", "slowed"]),
  actions: freeze({
    sprint: freeze({ flowCostPerSecond: 30, startup: 0, recovery: 0.08, momentum: 1 }), jump: freeze({ flowCost: 20, startup: 0.04, active: 0.18, recovery: 0.1, buffer: 0.11, coyote: 0.09 }), doubleJump: freeze({ flowCost: 28, startup: 0.03, active: 0.16, recovery: 0.12, limit: 1 }), slide: freeze({ flowCost: 18, startup: 0.03, active: 0.32, recovery: 0.16, steering: 0.28 }), slideJump: freeze({ flowCost: 24, startup: 0.03, active: 0.2, recovery: 0.14, momentum: 1.12 }), airDodge: freeze({ flowCost: 34, startup: 0.03, active: 0.13, recovery: 0.28, steering: 0.18 }), wavedash: freeze({ flowCost: 0, startup: 0, active: 0.16, recovery: 0.12, requires: "angled air-dodge landing" }), wallJump: freeze({ flowCost: 22, startup: 0.03, active: 0.18, recovery: 0.12, lockout: 0.22 }), redirect: freeze({ flowCost: 16, startup: 0, active: 0.1, recovery: 0.18, limit: 1 }), vault: freeze({ flowCost: 10, startup: 0.05, active: 0.2, recovery: 0.1 }), superglide: freeze({ flowCost: 18, startup: 0, active: 0.18, recovery: 0.2, window: 0.08, requires: "jump at vault crest" }),
  }),
  limits: freeze({ maximumSpeed: 1350, wallLoopLockout: 0.22, collisionSubsteps: 16, inputBuffer: 0.11 }),
});

export const FREEPLAY_DEFAULTS = freeze({ godMode: false, endlessFlux: false, endlessFlow: false, instantCooldowns: false, endlessUltimate: false, damageMultiplier: 1, speedMultiplier: 1, gravityMultiplier: 1, airControlMultiplier: 1, friendlyFire: false, destructibility: true, reactions: true, freezeBots: false, timeScale: 1, showHitboxes: false, showVelocity: false, showMovementState: false, showElementData: false, networkProfile: "local" });

export const MODE_LOADOUT_RULES = freeze([
  freeze({ id: "freeplay", name: "Freeplay", skillPoints: 99, elements: ELEMENTS.map((entry) => entry.id), ultimates: true, mirrored: false, draft: false, earnInMatch: false, teams: [1, 2, 3] }),
  freeze({ id: "duel", name: "Duel", skillPoints: 13, elements: ELEMENTS.map((entry) => entry.id), ultimates: true, mirrored: false, draft: false, earnInMatch: false, teams: [1] }),
  freeze({ id: "team", name: "Team", skillPoints: 13, elements: ELEMENTS.map((entry) => entry.id), ultimates: true, mirrored: false, draft: false, earnInMatch: false, teams: [2, 3] }),
  freeze({ id: "control", name: "Control", skillPoints: 14, elements: ELEMENTS.map((entry) => entry.id), ultimates: true, mirrored: false, draft: false, earnInMatch: false, teams: [2, 3] }),
  freeze({ id: "convergence", name: "PvPvE", skillPoints: 14, elements: ELEMENTS.map((entry) => entry.id), ultimates: true, mirrored: false, draft: false, earnInMatch: true, teams: [1, 2, 3] }),
  freeze({ id: "survival", name: "Survival", skillPoints: 16, elements: ELEMENTS.map((entry) => entry.id), ultimates: true, mirrored: false, draft: false, earnInMatch: true, teams: [1, 2, 3] }),
  freeze({ id: "movement", name: "Movement", skillPoints: 8, elements: ["earth", "water", "wind", "ice", "charge", "light", "dark"], ultimates: false, mirrored: true, draft: false, earnInMatch: false, teams: [1] }),
  freeze({ id: "draft", name: "Draft", skillPoints: 13, elements: ELEMENTS.map((entry) => entry.id), ultimates: true, mirrored: false, draft: true, earnInMatch: false, teams: [1, 2, 3] }),
  freeze({ id: "mirror", name: "Mirror", skillPoints: 13, elements: ELEMENTS.map((entry) => entry.id), ultimates: true, mirrored: true, draft: false, earnInMatch: false, teams: [1, 2, 3] }),
  freeze({ id: "siege", name: "Siege", skillPoints: 15, elements: ELEMENTS.map((entry) => entry.id), ultimates: true, mirrored: false, draft: false, earnInMatch: true, teams: [2, 3] }),
  freeze({ id: "extraction", name: "Extraction", skillPoints: 12, elements: ELEMENTS.map((entry) => entry.id), ultimates: true, mirrored: false, draft: false, earnInMatch: true, teams: [1, 2, 3] }),
  freeze({ id: "battle_royale", name: "Battle Royale", skillPoints: 10, elements: ELEMENTS.map((entry) => entry.id), ultimates: true, mirrored: false, draft: false, earnInMatch: true, teams: [1, 2, 3] }),
]);

export const MATERIAL_TAGS = freeze(["solid", "brittle", "wet", "frozen", "burning", "conductive", "rooted", "smoke", "steam", "charged", "reflective", "refractive", "shadowed", "corrupted", "unstable", "weakened", "healing", "slippery"]);
export const DESTRUCTION_RULES = freeze({ gridSize: 32, maxActiveRegions: 96, maxReactionsPerTick: 64, maxStructuralEventsPerTick: 24, levels: freeze(["lower", "ground", "upper", "roof"]), materials: freeze({ wood: freeze({ health: 60, fracture: 20, tags: ["solid", "burning"] }), stone: freeze({ health: 130, fracture: 45, tags: ["solid", "brittle"] }), glass: freeze({ health: 35, fracture: 14, tags: ["solid", "brittle", "refractive"] }), growth: freeze({ health: 55, fracture: 18, tags: ["solid", "rooted", "burning"] }), ice: freeze({ health: 45, fracture: 12, tags: ["solid", "frozen", "brittle", "slippery"] }) }) });

const statCost = (stats) => Object.values(stats).reduce((sum, value) => sum + Math.max(0, Number(value) || 0), 0);
const affinityCost = (affinities) => affinities.reduce((sum, entry) => sum + entry.strength * 5, 0) + Math.max(0, affinities.length - 1) * 3;

export function calculateCharacterBudget(candidate) {
  const raceEntry = getRaceArchetype(candidate.raceId);
  const sizeRule = SIZE_RULES[candidate.size];
  if (!raceEntry || !sizeRule) return Number.POSITIVE_INFINITY;
  const activeCost = candidate.activeAbilityIds.reduce((sum, id) => { const entry = ABILITY_CATALOG.find((item) => item.id === id && item.type === "active"); return sum + (entry?.tier ?? 4) * 2; }, 0);
  const ultimate = ABILITY_CATALOG.find((item) => item.id === candidate.ultimateAbilityId && item.type === "ultimate");
  return raceEntry.budgetCost + sizeRule.budgetCost + affinityCost(candidate.affinities) + statCost(candidate.statBonuses) + (candidate.passive?.cost ?? 0) + activeCost + (ultimate?.tier ?? 5) * 3 - (candidate.drawbackCredit ?? 0);
}

export function affinityStrength(characterEntry, elementId) { const canonical = canonicalElement(elementId); return characterEntry.affinities.find((entry) => entry.id === canonical)?.strength ?? 0; }
export function effectiveAbilityPoints(characterEntry, abilityEntry) { return Math.max(1, abilityEntry.points - clamp(affinityStrength(characterEntry, abilityEntry.element), 0, 3)); }

export function validateLoadout({ characterId, modeId, activeAbilityIds, ultimateAbilityId }) {
  const errors = [];
  const characterEntry = CHARACTER_ROSTER.find((entry) => entry.id === characterId);
  const mode = MODE_LOADOUT_RULES.find((entry) => entry.id === modeId);
  if (!characterEntry) errors.push("unknown character");
  if (!mode) errors.push("unknown mode");
  if (!Array.isArray(activeAbilityIds) || activeAbilityIds.length !== 3) errors.push("loadout needs three active abilities");
  if (new Set(activeAbilityIds ?? []).size !== (activeAbilityIds ?? []).length) errors.push("active abilities must be unique");
  const actives = (activeAbilityIds ?? []).map((id) => ABILITY_CATALOG.find((entry) => entry.id === id && entry.type === "active"));
  if (actives.some((entry) => !entry)) errors.push("unknown active ability");
  const ultimate = ABILITY_CATALOG.find((entry) => entry.id === ultimateAbilityId && entry.type === "ultimate");
  if (!ultimate) errors.push("unknown ultimate");
  if (mode && !mode.ultimates && ultimateAbilityId) errors.push("ultimates are disabled");
  if (mode && [...actives, ultimate].filter(Boolean).some((entry) => !mode.elements.includes(entry.element))) errors.push("element is not allowed");
  if (mode && characterEntry) { const total = actives.filter(Boolean).reduce((sum, entry) => sum + effectiveAbilityPoints(characterEntry, entry), 0); if (total > mode.skillPoints) errors.push(`skill point budget exceeded: ${total}/${mode.skillPoints}`); }
  return errors;
}

export function validateOverhaulContent() {
  const errors = [];
  const unique = (items, label) => { const ids = items.map((entry) => entry.id); if (new Set(ids).size !== ids.length) errors.push(`${label} ids must be unique`); };
  unique(ELEMENTS, "element"); unique(RACE_ARCHETYPES, "race"); unique(ABILITY_CATALOG, "ability"); unique(CHARACTER_ROSTER, "character");
  if (ELEMENTS.length !== 8) errors.push("exactly eight elements are required");
  if (RACE_ARCHETYPES.length !== 16) errors.push("exactly sixteen races are required");
  if (CHARACTER_ROSTER.length < RACE_ARCHETYPES.length) errors.push("at least one character per race is required");
  for (const raceEntry of RACE_ARCHETYPES) {
    if (!raceEntry.sizes.every((size) => SIZE_RULES[size])) errors.push(`${raceEntry.id} has an invalid size range`);
    if (!raceEntry.affinities.every((entry) => canonicalElement(entry.id) && entry.strength >= 1 && entry.strength <= 3)) errors.push(`${raceEntry.id} has invalid affinities`);
    for (const [key, value] of Object.entries(raceEntry.modifiers)) { const min = key === "knockback" ? 0.8 : 0.9; if (!Number.isFinite(value) || value < min || value > 1.1) errors.push(`${raceEntry.id}.${key} is outside bounded race modifiers`); }
  }
  const coveredRaces = new Set(CHARACTER_ROSTER.map((entry) => entry.raceId));
  for (const raceEntry of RACE_ARCHETYPES) if (!coveredRaces.has(raceEntry.id)) errors.push(`missing character for ${raceEntry.id}`);
  for (const characterEntry of CHARACTER_ROSTER) {
    const raceEntry = getRaceArchetype(characterEntry.raceId);
    if (!raceEntry) errors.push(`${characterEntry.id} has unknown race`);
    if (raceEntry && !raceEntry.sizes.includes(characterEntry.size)) errors.push(`${characterEntry.id} size is outside race range`);
    if (characterEntry.affinities.length < 1 || characterEntry.affinities.length > 5) errors.push(`${characterEntry.id} needs one to five affinities`);
    if (characterEntry.activeAbilityIds.length !== 3) errors.push(`${characterEntry.id} needs three signature actives`);
    if (characterEntry.activeAbilityIds.some((id) => !ABILITY_CATALOG.some((entry) => entry.id === id && entry.type === "active"))) errors.push(`${characterEntry.id} references an unknown active`);
    if (!ABILITY_CATALOG.some((entry) => entry.id === characterEntry.ultimateAbilityId && entry.type === "ultimate")) errors.push(`${characterEntry.id} references an unknown ultimate`);
    const budget = calculateCharacterBudget(characterEntry); if (!Number.isFinite(budget) || budget > 100) errors.push(`${characterEntry.id} exceeds power budget: ${budget}`);
  }
  for (const element of ELEMENTS) if (!RACE_ARCHETYPES.some((raceEntry) => raceEntry.affinities.some((entry) => entry.id === element.id && entry.strength >= 2))) errors.push(`no race has strong ${element.id} affinity`);
  const requiredNames = ["COLD ASHES", "CRIMSON COMET", "NIGHT FLAK", "RIME WING", "THE DEAD SKY", "DEEP ROOTS", "ROOT RAMPART", "BRANCH GALE", "EMBER SEED", "CROWN OF THE WILDFIRE", "SMALL TARGET, BIG EXIT", "POCKET TEMPEST", "BURROWED SHADOW", "CAMPFIRE FEINT", "THERE AND BACK AGAIN", "QUESTIONABLE ENGINEERING", "SPARK KEG", "PRISM TRIPWIRE", "COIL HOPPER", "PERFECTLY SAFE MACHINE", "LIVING CURRENT", "TIDELINE", "FLASH FREEZE", "EEL STEP", "STORMTIDE BASIN", "LABYRINTH MOMENTUM", "SUNHORN CHARGE", "FURNACE STOMP", "MIRROR BULWARK", "THE BURNING MAZE", "STORMWEIGHT", "THUNDER SHOVE", "SQUALL LEAP", "RIME CRASH", "BAD WEATHER"];
  const shippedNames = new Set([...ABILITY_CATALOG.map((entry) => entry.name), ...CHARACTER_ROSTER.map((entry) => entry.passive.name)]);
  for (const name of requiredNames) if (!shippedNames.has(name)) errors.push(`missing canonical ability name ${name}`);
  return errors;
}
