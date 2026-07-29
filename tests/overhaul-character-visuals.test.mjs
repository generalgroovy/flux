import test from "node:test";
import assert from "node:assert/strict";

import { CHARACTERS } from "../src/content.mjs";
import {
  ANCESTRY_VISUAL_TEMPLATES,
  composeCharacterVisualProfile,
  drawAncestryFeatures,
  traceAncestryBody,
  validateAncestryVisualTemplates,
} from "../src/ancestry-visual-templates.mjs";
import {
  LEGACY_CONCEPT_TRANSFERS,
  OVERHAUL_CHARACTER_VISUAL_STATES,
  getOverhaulCharacterVisualProfile,
  resolveOverhaulCharacterVisualState,
} from "../src/overhaul-character-visuals.mjs";

test("all twenty ancestry templates are valid, renderable, and champion-neutral", () => {
  assert.deepEqual(validateAncestryVisualTemplates(), []);
  assert.equal(ANCESTRY_VISUAL_TEMPLATES.length, 20);
  const context = fakeContext();
  for (const ancestry of ANCESTRY_VISUAL_TEMPLATES) {
    assert.equal(traceAncestryBody(context, ancestry, 24), true, ancestry.id);
    assert.equal("roleRead" in ancestry, false, `${ancestry.id}: role belongs to champion profile`);
    const profile = composeCharacterVisualProfile({
      id: `test-${ancestry.id}`,
      name: `Test ${ancestry.name}`,
      ancestryId: ancestry.id,
      roleRead: "test role",
      focusProp: "test prop",
      body: "#888888",
      mantle: "#555555",
      ink: "#111111",
      earth: "#999966",
      fire: "#cc6633",
      light: "#ddcc66",
    });
    assert.equal(profile.ancestryTemplate, ancestry);
    assert.equal(drawAncestryFeatures(context, profile, 24), true, ancestry.id);
  }
});

test("one ancestry template composes multiple independent champion profiles", () => {
  const first = composeCharacterVisualProfile({ id: "one", name: "One", ancestryId: "dwarf", roleRead: "anchor", focusProp: "shield" });
  const second = composeCharacterVisualProfile({ id: "two", name: "Two", ancestryId: "dwarf", roleRead: "shaper", focusProp: "hammer" });
  assert.equal(first.ancestryTemplate, second.ancestryTemplate);
  assert.notEqual(first.roleRead, second.roleRead);
  assert.notEqual(first.focusProp, second.focusProp);
});

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

function fakeContext() {
  return {
    save() {}, restore() {}, beginPath() {}, moveTo() {}, lineTo() {}, closePath() {},
    fill() {}, stroke() {}, arc() {}, quadraticCurveTo() {}, rect() {}, fillRect() {},
  };
}
