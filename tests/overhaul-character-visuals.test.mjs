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
  OVERHAUL_CHARACTER_VISUAL_PROFILES,
  OVERHAUL_CHARACTER_VISUAL_STATES,
  drawOverhaulCharacterAura,
  drawOverhaulCharacterDefeat,
  drawOverhaulCharacterDetails,
  drawOverhaulPixelCharacter,
  getOverhaulCharacterVisualProfile,
  isOverhaulPixelCharacter,
  resolveCardinalFacing,
  resolveOverhaulCharacterVisualState,
  traceOverhaulCharacterBody,
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
  assert.equal(
    LEGACY_CONCEPT_TRANSFERS.filter((entry) => entry.status === "promoted")[0]?.legacyId,
    "volt",
  );
  assert.ok(
    LEGACY_CONCEPT_TRANSFERS.every((entry) =>
      ["compatibility-only", "promoted"].includes(entry.status),
    ),
  );
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

test("S. Wayne is a low Hobbit boundary tactician with separate Dark and Light reads", () => {
  const transfer = LEGACY_CONCEPT_TRANSFERS.find((entry) => entry.legacyId === "echo");
  const profile = getOverhaulCharacterVisualProfile(transfer.overhaulId);
  assert.equal(transfer.overhaulName, "S. Wayne");
  assert.match(transfer.retained, /decoy spacing.*swap boundaries/);
  assert.match(transfer.retired, /Gloam Elf/);
  assert.equal(profile.name, "S. Wayne");
  assert.equal(profile.plannedAncestry, "Hobbit");
  assert.match(profile.ancestryRead, /bare feet.*low split mantle/);
  assert.match(profile.affinityRead, /Dark.*Light/);
  assert.equal(profile.focusProp, "eclipse waystone");
});

test("Nico Lai is a tiny Gnome engineer with a breakable owned device read", () => {
  const transfer = LEGACY_CONCEPT_TRANSFERS.find((entry) => entry.legacyId === "volt");
  const profile = getOverhaulCharacterVisualProfile(transfer.overhaulId);
  assert.equal(transfer.overhaulId, "nico");
  assert.equal(transfer.overhaulName, "Nico Lai");
  assert.match(transfer.retained, /charge sequencing.*calibrated device/);
  assert.match(transfer.retired, /storm-scribe/);
  assert.equal(profile.name, "Nico Lai");
  assert.equal(profile.runtimeCharacterId, "volt");
  assert.equal(profile.contentCompatibilityId, "nix");
  assert.equal(profile.plannedAncestry, "Gnome");
  assert.match(profile.ancestryRead, /high cap.*tiny measured tool frame/);
  assert.match(profile.affinityRead, /Charge forks.*Light calibration diamonds/);
  assert.equal(profile.focusProp, "calibrated coil pack");
  assert.match(profile.deviceRead, /breakable coil.*team tether/);
  assert.equal(isOverhaulPixelCharacter(profile), true);
});

test("Nico pixel runtime preserves four cardinal facings and six states", () => {
  const profile = getOverhaulCharacterVisualProfile("nico");
  const context = fakeContext();
  assert.equal(resolveCardinalFacing(1, 0.2), "right");
  assert.equal(resolveCardinalFacing(-1, 0.2), "left");
  assert.equal(resolveCardinalFacing(0.2, 1), "down");
  assert.equal(resolveCardinalFacing(0.2, -1), "up");
  assert.equal(resolveCardinalFacing(Number.NaN, Number.NaN), "right");
  for (const facing of ["up", "down", "left", "right"]) {
    for (const state of OVERHAUL_CHARACTER_VISUAL_STATES) {
      assert.equal(
        drawOverhaulPixelCharacter(
          context,
          profile,
          state,
          24,
          "alpha",
          "#77f7ce",
          state === "hit" ? 0.2 : 1,
          facing,
        ),
        true,
        `${facing}:${state}`,
      );
    }
  }
  assert.equal(drawOverhaulPixelCharacter(context, null, "idle", 24, "alpha", "#fff", 1, "down"), false);
});

test("every authored character visual renders all six states through the registry", () => {
  const context = fakeContext();
  assert.deepEqual(
    Object.keys(OVERHAUL_CHARACTER_VISUAL_PROFILES).sort(),
    ["aerwyn", "nico", "samwise", "urzh"],
  );
  for (const profile of Object.values(OVERHAUL_CHARACTER_VISUAL_PROFILES)) {
    assert.equal(traceOverhaulCharacterBody(context, profile, 24), true, profile.id);
    for (const state of OVERHAUL_CHARACTER_VISUAL_STATES) {
      if (state === "defeated") {
        assert.equal(
          drawOverhaulCharacterDefeat(context, profile, 24, "#77f7ce"),
          true,
          `${profile.id}:${state}`,
        );
        continue;
      }
      assert.equal(
        drawOverhaulCharacterAura(context, profile, state, 24, 0.7, true),
        true,
        `${profile.id}:${state}:aura`,
      );
      assert.equal(
        drawOverhaulCharacterAura(context, profile, state, 24, 1.1, false),
        true,
        `${profile.id}:${state}:animated-aura`,
      );
      assert.equal(
        drawOverhaulCharacterDetails(
          context,
          profile,
          state,
          24,
          "alpha",
          "#77f7ce",
          state === "hit" ? 0.2 : 1,
        ),
        true,
        `${profile.id}:${state}:details`,
      );
    }
  }
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
  const finiteCommand = (...values) => {
    for (const value of values) {
      if (typeof value === "number") assert.equal(Number.isFinite(value), true);
    }
  };
  return {
    save() {}, restore() {}, beginPath() {}, closePath() {}, fill() {}, stroke() {},
    moveTo: finiteCommand,
    lineTo: finiteCommand,
    arc: finiteCommand,
    quadraticCurveTo: finiteCommand,
    rect: finiteCommand,
    fillRect: finiteCommand,
    translate: finiteCommand,
    scale: finiteCommand,
  };
}
