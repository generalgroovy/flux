import { traceAncestryBody } from "./ancestry-visual-templates.mjs";
import {
  finite,
  insideOpeningWindow,
  positive,
} from "./overhaul/character-visual-primitives.mjs";
import { NICO_LAI_VISUAL } from "./overhaul/characters/nico-lai-visual.mjs";
import { SPAI_SI_VISUAL } from "./overhaul/characters/spai-si-visual.mjs";
import { S_WAYNE_VISUAL } from "./overhaul/characters/s-wayne-visual.mjs";
import { URZH_VISUAL } from "./overhaul/characters/urzh-visual.mjs";

const freeze = (value) => Object.freeze(value);

// Presentation-only migration ledger. Legacy IDs remain live until their
// successors pass the visual and gameplay promotion gates.
export const LEGACY_CONCEPT_TRANSFERS = freeze([
  transfer("kite", "Aerwyn", "aerwyn", "Spai Si", "redirect timing, forward duelist posture, and readable wind-angle guides", "name, Briar Elf ancestry, and complete legacy kit"),
  transfer("bulwark", "Gorum", "urzh", "Urzh", "brace discipline, lane anchoring, and squared stone mass", "name, Iron Orc ancestry, and rune-warden fiction"),
  transfer("echo", "Vellyn", "samwise", "S. Wayne", "intent division, decoy spacing, and visible swap boundaries", "name, Gloam Elf ancestry, and moon-wraith fiction"),
  transfer("volt", "Nim Copperspark", "nico", "Nico Lai", "charge sequencing, interrupt windows, and calibrated device language", "name and storm-scribe fiction", "promoted"),
  transfer("cinder", "Serek Ashborn", "steezo", "Steezo", "route traps, bounded detonation chains, and backblast recovery", "name and Cinderling ancestry"),
  transfer("orbit", "Morcant", "djonah-thaan", "Djonah Thaan", "ground denial, pursuit pressure, and a return-to-fundamentals silence cue", "name, Revenant ancestry, and grave-cantor fiction"),
  transfer("mend", "Neris Pearldive", "grace-reava", "Grace Reava", "living-current redirection, narrow protection windows, and Tide rhythm", "name and Reefborn ancestry"),
  transfer("rook", "Branna Runesight", "biggy-bob", "Biggy Bob", "sightline control, a readable focus tool, and forge-prism geometry", "name and rune-sage fiction"),
  transfer("rimewing", "Yrsa Rimewing", "yrsa", "Ha Rekt", "aerial cold-line hunting, marked escapes, and committed landings", "name and exact ability package"),
  transfer("ashmaw", "Varka Ashmaw", "treevor", "Treevor the Mason", "terrain shaping, Fire liability, and a crown-state climax", "name, Wyrmbound ancestry, and pyre-exile fiction"),
]);

const CHARACTER_VISUALS = freeze([
  SPAI_SI_VISUAL,
  URZH_VISUAL,
  S_WAYNE_VISUAL,
  NICO_LAI_VISUAL,
]);

const VISUAL_BY_ID = new Map(
  CHARACTER_VISUALS.map((entry) => [entry.profile.id, entry]),
);

export const OVERHAUL_CHARACTER_VISUAL_PROFILES = freeze(
  Object.fromEntries(
    CHARACTER_VISUALS.map((entry) => [entry.profile.id, entry.profile]),
  ),
);

export const OVERHAUL_CHARACTER_VISUAL_STATES = freeze([
  "idle",
  "move",
  "commit",
  "hit",
  "defend",
  "defeated",
]);

export function getOverhaulCharacterVisualProfile(characterId) {
  return OVERHAUL_CHARACTER_VISUAL_PROFILES[characterId] ?? null;
}

export function resolveOverhaulCharacterVisualState(entity, cooldowns = {}) {
  if (!entity?.alive) return "defeated";
  if (positive(entity.hitFlash)) return "hit";
  if (positive(entity.defenseRemaining)) return "defend";
  if (
    positive(entity.ultimateWindupRemaining) ||
    insideOpeningWindow(entity.primaryCooldown, cooldowns.primary, 0.075) ||
    insideOpeningWindow(entity.specialCooldown, cooldowns.special, 0.16)
  ) {
    return "commit";
  }
  if (
    Math.hypot(finite(entity.vx), finite(entity.vy)) > 70 ||
    positive(entity.mobilityRemaining) ||
    positive(entity.slideRemaining) ||
    positive(entity.hopRemaining)
  ) {
    return "move";
  }
  return "idle";
}

export function drawOverhaulCharacterAura(
  context,
  profile,
  state,
  radius,
  time,
  reducedMotion,
) {
  if (!profile || state === "defeated") return false;
  const visual = VISUAL_BY_ID.get(profile.id);
  if (!visual) return false;
  visual.drawAura(context, profile, state, radius, time, reducedMotion);
  return true;
}

export function traceOverhaulCharacterBody(context, profile, radius) {
  if (!profile) return false;
  return traceAncestryBody(context, profile.ancestryTemplate, radius);
}

export function drawOverhaulCharacterDetails(
  context,
  profile,
  state,
  radius,
  team,
  teamColor,
  healthRatio,
) {
  const visual = profile ? VISUAL_BY_ID.get(profile.id) : null;
  if (!visual) return false;
  visual.drawDetails(
    context,
    profile,
    state,
    radius,
    team,
    teamColor,
    healthRatio,
  );
  return true;
}

export function drawOverhaulCharacterDefeat(
  context,
  profile,
  radius,
  teamColor,
) {
  const visual = profile ? VISUAL_BY_ID.get(profile.id) : null;
  return visual?.drawDefeat(context, profile, radius, teamColor) ?? false;
}

function transfer(
  legacyId,
  legacyName,
  overhaulId,
  overhaulName,
  retained,
  retired,
  status = "compatibility-only",
) {
  return freeze({
    legacyId,
    legacyName,
    overhaulId,
    overhaulName,
    retained,
    retired,
    status,
  });
}
