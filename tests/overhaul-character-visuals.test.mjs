import test from "node:test";
import assert from "node:assert/strict";

import { CHARACTERS } from "../src/content.mjs";
import {
  LEGACY_CONCEPT_TRANSFERS,
  OVERHAUL_CHARACTER_VISUAL_STATES,
  getOverhaulCharacterVisualProfile,
  resolveOverhaulCharacterVisualState,
} from "../src/overhaul-character-visuals.mjs";

test("every shipped champion has exactly one explicit retirement transfer", () => {
  const shippedIds = CHARACTERS.map((agent) => agent.id).sort();
  assert.deepEqual(LEGACY_CONCEPT_TRANSFERS.map((entry) => entry.legacyId).sort(), shippedIds);
  assert.equal(new Set(LEGACY_CONCEPT_TRANSFERS.map((entry) => entry.overhaulId)).size, shippedIds.length);
  assert.ok(LEGACY_CONCEPT_TRANSFERS.every((entry) => entry.retained && entry.retired));
  assert.ok(LEGACY_CONCEPT_TRANSFERS.every((entry) => entry.status === "compatibility-only"));
});

test("Spai Si owns Aerwyn's redirect language without inheriting Aerwyn's identity", () => {
  const transfer = LEGACY_CONCEPT_TRANSFERS.find((entry) => entry.legacyId === "kite");
  const profile = getOverhaulCharacterVisualProfile(transfer.overhaulId);
  assert.equal(transfer.overhaulName, "Spai Si");
  assert.match(transfer.retained, /redirect timing/);
  assert.match(transfer.retired, /Briar Elf/);
  assert.equal(profile.name, "Spai Si");
  assert.equal(profile.plannedAncestry, "Demon");
  assert.match(profile.ancestryRead, /horns.*tail/);
});

test("Urzh inherits Gorum's anchor discipline as an original Stoneborn read", () => {
  const transfer = LEGACY_CONCEPT_TRANSFERS.find((entry) => entry.legacyId === "bulwark");
  const profile = getOverhaulCharacterVisualProfile(transfer.overhaulId);
  assert.equal(transfer.overhaulName, "Urzh");
  assert.match(transfer.retained, /lane anchoring/);
  assert.match(transfer.retired, /Iron Orc/);
  assert.equal(profile.plannedAncestry, "Stoneborn");
  assert.match(profile.ancestryRead, /squared stone frame/);
  assert.match(profile.affinityRead, /Earth.*Fire.*Charge/);
});

test("overhaul character state resolver preserves the six authored reads", () => {
  const base = { alive: true, vx: 0, vy: 0 };
  assert.deepEqual(OVERHAUL_CHARACTER_VISUAL_STATES, ["idle", "move", "commit", "hit", "defend", "defeated"]);
  assert.equal(resolveOverhaulCharacterVisualState(base), "idle");
  assert.equal(resolveOverhaulCharacterVisualState({ ...base, vx: 80 }), "move");
  assert.equal(resolveOverhaulCharacterVisualState({ ...base, primaryCooldown: 1.98 }, { primary: 2 }), "commit");
  assert.equal(resolveOverhaulCharacterVisualState({ ...base, defenseRemaining: 0.1 }), "defend");
  assert.equal(resolveOverhaulCharacterVisualState({ ...base, hitFlash: 0.1, defenseRemaining: 0.1 }), "hit");
  assert.equal(resolveOverhaulCharacterVisualState({ ...base, alive: false, hitFlash: 0.1 }), "defeated");
});
