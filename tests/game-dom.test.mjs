import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

import { parseHTML } from "linkedom";

test("browser shell boots, renders, navigates, starts, pauses, and resets cleanly", async () => {
  const html = await readFile(new URL("../index.html", import.meta.url), "utf8");
  const { window } = parseHTML(html);
  const { document } = window;
  const storage = new Map();
  const drawCalls = [];
  const mockContext = new Proxy(
    {},
    {
      get(target, property) {
        if (!(property in target)) {
          target[property] = (...args) => drawCalls.push([property, ...args]);
        }
        return target[property];
      },
      set(target, property, value) {
        target[property] = value;
        return true;
      },
    },
  );
  document.querySelector("canvas").getContext = () => mockContext;
  document.querySelector("canvas").setPointerCapture = () => {};
  document.querySelector("canvas").releasePointerCapture = () => {};

  let queuedFrame = null;
  const requestAnimationFrame = (callback) => {
    queuedFrame = callback;
    return 1;
  };
  const localStorage = {
    getItem: (key) => storage.get(key) ?? null,
    setItem: (key, value) => storage.set(key, String(value)),
    removeItem: (key) => storage.delete(key),
  };
  const fetch = async () => ({
    ok: true,
    status: 200,
    json: async () => ({ lobbies: [] }),
  });
  Object.assign(window, {
    innerWidth: 1440,
    innerHeight: 900,
    devicePixelRatio: 1,
    requestAnimationFrame,
    localStorage,
    fetch,
    setTimeout: () => 1,
    clearTimeout: () => {},
  });
  Object.defineProperty(window, "location", {
    configurable: true,
    value: { origin: "http://127.0.0.1:8000" },
  });
  Object.defineProperty(window.navigator, "getGamepads", {
    configurable: true,
    value: () => [],
  });
  const settingsForm = document.getElementById("settings-form");
  Object.defineProperty(settingsForm, "elements", {
    configurable: true,
    value: {
      namedItem: (name) => settingsForm.querySelector(`[name="${name}"]`),
    },
  });

  class DomFormData {
    constructor(form) {
      this.values = new Map();
      for (const input of form.querySelectorAll("input, select")) {
        if (!input.name || input.disabled) continue;
        if (
          (input.type === "radio" || input.type === "checkbox") &&
          !input.checked
        ) {
          continue;
        }
        this.values.set(input.name, input.value || "on");
      }
    }

    get(name) {
      return this.values.get(name) ?? null;
    }
  }

  Object.assign(globalThis, {
    window,
    document,
    localStorage,
    requestAnimationFrame,
    FormData: DomFormData,
    fetch,
  });
  Object.defineProperty(globalThis, "location", {
    configurable: true,
    value: window.location,
  });
  Object.defineProperty(globalThis, "navigator", {
    configurable: true,
    value: window.navigator,
  });

  await import(`../src/game.mjs?dom-smoke=${Date.now()}`);

  const app = document.getElementById("app");
  assert.equal(app.dataset.view, "menu");
  assert.deepEqual(window.DIFF_DEBUG.getInvariantErrors(), []);

  for (const panel of [
    "home",
    "play",
    "online",
    "agents",
    "arenas",
    "guide",
    "settings",
  ]) {
    document.querySelector(`.nav-item[data-panel="${panel}"]`).click();
    assert.equal(app.dataset.panel, panel);
    assert.equal(
      document.querySelector(`[data-menu-panel="${panel}"]`).hidden,
      false,
    );
  }
  assert.equal(document.getElementById("host-lobby").disabled, false);
  assert.equal(document.getElementById("join-lobby").disabled, false);

  document.querySelector('[data-panel="agents"]').click();
  assert.equal(app.dataset.panel, "agents");
  assert.equal(
    document.querySelector('[data-menu-panel="agents"]').hidden,
    false,
  );

  document.querySelector("[data-quick-start]").click();
  assert.equal(app.dataset.view, "game");
  assert.equal(window.DIFF_DEBUG.getState().modeId, "training");
  assert.equal(window.DIFF_DEBUG.getState().entities[0].characterId, "kite");
  assert.equal(document.getElementById("coach-progress").hidden, false);
  assert.equal(
    document.querySelector('[data-coach-step="0"]').classList.contains("active"),
    true,
  );
  assert.equal(typeof queuedFrame, "function");
  queuedFrame(performance.now() + 16);
  assert.ok(drawCalls.some((call) => call[0] === "fillRect"));
  assert.deepEqual(window.DIFF_DEBUG.getInvariantErrors(), []);

  const originalFillRect = mockContext.fillRect;
  const originalConsoleError = console.error;
  let recoveredError = "";
  mockContext.fillRect = () => {
    throw new Error("synthetic canvas loss");
  };
  console.error = (...parts) => {
    recoveredError = parts.map(String).join(" ");
  };
  queuedFrame(performance.now() + 24);
  mockContext.fillRect = originalFillRect;
  console.error = originalConsoleError;
  assert.match(recoveredError, /DIFF frame recovered/);
  const callsBeforeRecovery = drawCalls.length;
  queuedFrame(performance.now() + 32);
  assert.ok(drawCalls.length > callsBeforeRecovery);

  const escape = new window.Event("keydown");
  Object.defineProperty(escape, "key", { value: "Escape" });
  window.dispatchEvent(escape);
  assert.equal(
    document.getElementById("pause-overlay").classList.contains("hidden"),
    false,
  );
  document.querySelector('#pause-overlay [data-action="resume"]').click();
  assert.equal(
    document.getElementById("pause-overlay").classList.contains("hidden"),
    true,
  );

  window.dispatchEvent(escape);
  document.querySelector('#pause-overlay [data-action="menu"]').click();
  assert.equal(app.dataset.view, "menu");
  assert.equal(app.dataset.panel, "home");

  for (const modeId of ["duel", "control", "convergence", "survival"]) {
    document.querySelector(`[data-launch-mode="${modeId}"]`).click();
    assert.equal(app.dataset.view, "game");
    assert.equal(window.DIFF_DEBUG.getState().modeId, modeId);
    assert.deepEqual(window.DIFF_DEBUG.getInvariantErrors(), []);

    document.getElementById("info-toggle").click();
    assert.equal(
      document.getElementById("info-overlay").classList.contains("hidden"),
      false,
    );
    assert.equal(
      document.getElementById("info-operation").textContent,
      window.DIFF_DEBUG.getState().modeId === "duel"
        ? "DIFFERENCE"
        : window.DIFF_DEBUG.getState().modeId === "control"
          ? "FAULTLINE"
          : window.DIFF_DEBUG.getState().modeId === "convergence"
            ? "CONVERGENCE"
            : "PRESSURE TEST",
    );
    const fieldInfo = new window.Event("keydown");
    Object.defineProperty(fieldInfo, "key", { value: "F1" });
    window.dispatchEvent(fieldInfo);
    assert.equal(
      document.getElementById("info-overlay").classList.contains("hidden"),
      true,
    );

    window.dispatchEvent(escape);
    document.querySelector('#pause-overlay [data-action="menu"]').click();
    assert.equal(app.dataset.view, "menu");
  }

  document.querySelector('[data-panel="agents"]').click();
  document.querySelector('[data-select-agent="volt"]').click();
  assert.equal(app.dataset.panel, "play");
  assert.equal(
    document.querySelector('input[name="character"][value="volt"]').checked,
    true,
  );
  document.querySelector('[data-panel="arenas"]').click();
  document.querySelector('[data-select-map="crown"]').click();
  assert.equal(app.dataset.panel, "play");
  assert.equal(
    document.querySelector('input[name="map"][value="crown"]').checked,
    true,
  );
  assert.match(
    document.getElementById("deployment-summary").textContent,
    /VOLT · CROWN/,
  );

  document.querySelector('[data-panel="play"]').click();
  const solo = document.querySelector('input[name="format"][value="solo"]');
  const local = document.querySelector('input[name="format"][value="local"]');
  solo.checked = false;
  local.checked = true;
  local.dispatchEvent(new window.Event("change", { bubbles: true }));
  assert.equal(document.getElementById("player-two-field").hidden, false);
  const form = document.getElementById("match-form");
  form.dispatchEvent(
    new window.Event("submit", { bubbles: true, cancelable: true }),
  );
  const localState = window.DIFF_DEBUG.getState();
  assert.equal(app.dataset.view, "game");
  assert.equal(
    localState.entities.filter((entity) => entity.human).length,
    2,
  );
  assert.deepEqual(window.DIFF_DEBUG.getInvariantErrors(), []);

  queuedFrame(performance.now() + 32);
  assert.ok(window.DIFF_DEBUG.getState().tick > 0);
  const restart = new window.Event("keydown");
  Object.defineProperty(restart, "key", { value: "r" });
  window.dispatchEvent(restart);
  assert.equal(window.DIFF_DEBUG.getState().tick, 0);
  assert.ok(window.DIFF_DEBUG.getState().entities.every((entity) => entity.alive));
});
