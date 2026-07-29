import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

import { parseHTML } from "linkedom";
import { createMatch } from "../src/match.mjs";

test("browser shell boots, renders, navigates, starts, pauses, and resets cleanly", async () => {
  const html = await readFile(new URL("../index.html", import.meta.url), "utf8");
  const { window } = parseHTML(html);
  const { document } = window;
  const storage = new Map();
  storage.set("flux.presentation.v2", JSON.stringify({
    screenShake: 55,
    interfaceScale: 100,
    sound: 45,
    coaching: true,
    bindings: {
      moveUp: "w", moveLeft: "w", moveDown: "w", moveRight: "w",
      fire: "w", tactical: "w", defense: "w", mobility: "w",
      sprint: "w", hop: "w", ultimate: "w",
    },
  }));
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
  let fakeSocket = null;
  const socketMessages = [];
  class FakeWebSocket {
    static CONNECTING = 0;
    static OPEN = 1;
    static CLOSED = 3;

    constructor() {
      this.readyState = FakeWebSocket.CONNECTING;
      this.listeners = new Map();
      fakeSocket = this;
      queueMicrotask(() => {
        this.readyState = FakeWebSocket.OPEN;
        this.emit("open", {});
        this.emitMessage({
          type: "hello",
          clientId: "browser-client",
          protocol: 2,
          version: "0.34.3",
          tickRate: 120,
        });
      });
    }

    addEventListener(type, listener) {
      const listeners = this.listeners.get(type) ?? [];
      listeners.push(listener);
      this.listeners.set(type, listeners);
    }

    removeEventListener(type, listener) {
      this.listeners.set(
        type,
        (this.listeners.get(type) ?? []).filter(
          (candidate) => candidate !== listener,
        ),
      );
    }

    emit(type, event) {
      for (const listener of this.listeners.get(type) ?? []) listener(event);
    }

    emitMessage(message) {
      this.emit("message", { data: JSON.stringify(message) });
    }

    send(raw) {
      const message = JSON.parse(raw);
      socketMessages.push(message);
      if (message.type === "probe") {
        this.emitMessage({ type: "probe", sequence: message.sequence });
      } else if (message.type === "host") {
        const state = createMatch({
          modeId: "convergence",
          mapId: "crown",
          botCount: 1,
          players: [{
            id: "remote-browser",
            clientId: "browser-client",
            characterId: "kite",
            raceId: "human",
            team: "alpha",
            human: true,
          }],
        });
        state.overtime = true;
        state.elapsed = 210;
        this.emitMessage({
          type: "result",
          requestId: message.requestId,
          action: "host",
          ok: true,
          lobby: {
            code: "ABC234",
            name: "DOM PROOF",
            hostId: "browser-client",
            players: 1,
            maxPlayers: 4,
          },
          entityId: "remote-browser",
          role: "player",
          reconnectToken: "dom-reconnect-token",
          snapshot: {
            serverTick: 0,
            acknowledgedSequence: -1,
            entityId: "remote-browser",
            state,
          },
        });
      }
    }

    close() {
      if (this.readyState === FakeWebSocket.CLOSED) return;
      this.readyState = FakeWebSocket.CLOSED;
      this.emit("close", {});
    }
  }
  Object.assign(window, {
    innerWidth: 1440,
    innerHeight: 900,
    devicePixelRatio: 1,
    requestAnimationFrame,
    localStorage,
    fetch,
    WebSocket: FakeWebSocket,
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
    WebSocket: FakeWebSocket,
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
  assert.equal(app.dataset.view, "game");
  assert.equal(window.DIFF_DEBUG.getState().modeId, "sanctum");
  assert.equal(window.DIFF_DEBUG.getState().mapId, "living_sanctum");
  assert.equal(window.DIFF_DEBUG.getInterfaceState().matchKind, "sanctum");
  assert.equal(window.DIFF_DEBUG.getInterfaceState().nearestSanctumStationId, "training");
  assert.equal(document.querySelector(".primary-nav").hidden, true);
  assert.equal(document.getElementById("front-end").matches(":not([hidden])"), true);
  assert.equal(app.classList.contains("station-open"), false);
  assert.equal(document.getElementById("sanctum-station-prompt").hidden, false);
  assert.match(document.getElementById("sanctum-station-name").textContent, /TRAINING COURT/);
  assert.equal(document.querySelector(".hero-mark"), null);
  assert.equal(document.querySelectorAll(".sanctum-sigil i").length, 8);
  assert.doesNotMatch(
    document.querySelector('[data-menu-panel="home"]').textContent,
    /(^|\s)HEX(\s|$)/i,
  );
  assert.equal(window.FLUX_DEBUG, window.DIFF_DEBUG, "legacy debug alias stays compatible");
  assert.deepEqual(window.DIFF_DEBUG.getInvariantErrors(), []);
  assert.equal(document.querySelectorAll("#agent-options .race-column").length, 13);
  assert.equal(document.querySelectorAll('#agent-options input[name="character"]').length, 10);
  assert.equal(document.querySelectorAll("#agent-options [data-character-id]").length, 10);
  assert.equal(document.querySelectorAll('#agent-options input[name="race"]').length, 0);
  assert.match(
    document.querySelector('#agent-options .race-column[aria-label="Briar Elf champions"] header').textContent,
    /leaf-point ears/,
  );
  assert.match(document.getElementById("agent-preview").textContent, /AERWYN/);
  assert.match(
    document.getElementById("agent-preview").textContent,
    /Briar Elf.*Briar gale duelist.*THREAD THE TURN/s,
  );
  assert.match(document.getElementById("agent-two-preview").textContent, /GORUM/);
  const gorumChoice = document.querySelector(
    '#agent-options [data-character-id="bulwark"]',
  );
  gorumChoice.dispatchEvent(new window.Event("pointerover", { bubbles: true }));
  assert.match(
    document.getElementById("agent-preview").textContent,
    /Iron Orc runewarden.*GORUM.*STONE/s,
  );
  assert.equal(
    document
      .querySelector('input[name="character"][value="kite"]')
      .hasAttribute("checked"),
    true,
    "hover previews without changing the locked champion",
  );
  document.getElementById("agent-options").dispatchEvent(
    new window.Event("pointerleave"),
  );
  assert.match(document.getElementById("agent-preview").textContent, /AERWYN/);
  assert.equal(document.getElementById("online-race").disabled, true);

  const stationInteract = new window.Event("keydown");
  Object.defineProperty(stationInteract, "key", { value: "e" });
  window.dispatchEvent(stationInteract);
  assert.equal(app.classList.contains("station-open"), true);
  assert.equal(app.dataset.panel, "practice");
  assert.equal(window.DIFF_DEBUG.getInterfaceState().sanctumStationOpen, true);
  document.getElementById("menu-close").click();
  assert.equal(app.classList.contains("station-open"), false);

  for (const panel of [
    "home",
    "practice",
    "play",
    "online",
    "agents",
    "arenas",
    "guide",
    "settings",
  ]) {
    assert.equal(window.DIFF_DEBUG.openSanctumStation(panel), true);
    assert.equal(app.dataset.panel, panel);
    assert.equal(
      document.querySelector(`[data-menu-panel="${panel}"]`).hidden,
      false,
    );
    assert.equal(app.classList.contains("station-open"), true);
    document.getElementById("menu-close").click();
  }
  assert.match(
    document.querySelector('[data-menu-panel="guide"]').textContent,
    /Wayseals choose the fight.*without gaining combat stats/i,
  );
  assert.equal(document.getElementById("host-lobby").disabled, false);
  assert.equal(document.getElementById("join-lobby").disabled, false);

  window.DIFF_DEBUG.openSanctumStation("settings");
  const tacticalBinding = document.querySelector('[data-bind-action="tactical"]');
  const defenseBinding = document.querySelector('[data-bind-action="defense"]');
  assert.equal(tacticalBinding.textContent, "E");
  assert.equal(defenseBinding.textContent, "Q");
  tacticalBinding.click();
  assert.equal(tacticalBinding.classList.contains("capturing"), true);
  const bindQ = new window.Event("keydown");
  Object.defineProperty(bindQ, "key", { value: "q" });
  window.dispatchEvent(bindQ);
  assert.equal(tacticalBinding.textContent, "Q");
  assert.equal(defenseBinding.textContent, "E");
  assert.match(document.getElementById("binding-status").textContent, /Defense moved to E/);

  const hopBinding = document.querySelector('[data-bind-action="hop"]');
  hopBinding.click();
  const reserved = new window.Event("keydown");
  Object.defineProperty(reserved, "key", { value: "ArrowLeft" });
  window.dispatchEvent(reserved);
  assert.equal(hopBinding.classList.contains("capturing"), true);
  assert.match(document.getElementById("binding-status").textContent, /reserved/);
  const cancelBinding = new window.Event("keydown");
  Object.defineProperty(cancelBinding, "key", { value: "Escape" });
  window.dispatchEvent(cancelBinding);
  assert.equal(hopBinding.textContent, "C");

  const techniqueBinding = document.querySelector('[data-bind-action="technique"]');
  techniqueBinding.click();
  const protectedTechnique = new window.Event("keydown");
  Object.defineProperty(protectedTechnique, "key", { value: "/" });
  window.dispatchEvent(protectedTechnique);
  assert.equal(techniqueBinding.classList.contains("capturing"), true);
  assert.match(document.getElementById("binding-status").textContent, /reserved/);
  window.dispatchEvent(cancelBinding);
  assert.equal(techniqueBinding.textContent, "V");

  const sprintBinding = document.querySelector('[data-bind-action="sprint"]');
  sprintBinding.click();
  const bindX = new window.Event("keydown");
  Object.defineProperty(bindX, "key", { value: "x" });
  window.dispatchEvent(bindX);
  assert.equal(sprintBinding.textContent, "X");
  assert.equal(
    document.querySelector('[data-binding-summary="flow"]').textContent,
    "X/C/V",
  );
  assert.equal(
    JSON.parse(storage.get("flux.presentation.v2")).bindings.tactical,
    "q",
  );
  const networkLatency = settingsForm.querySelector('[name="networkLatency"]');
  const networkJitter = settingsForm.querySelector('[name="networkJitter"]');
  const networkLoss = settingsForm.querySelector('[name="networkLoss"]');
  networkLatency.value = "120";
  networkJitter.value = "35";
  networkLoss.value = "8";
  networkLoss.dispatchEvent(new window.Event("input", { bubbles: true }));
  const savedNetworkLab = JSON.parse(storage.get("flux.presentation.v2"));
  assert.equal(savedNetworkLab.networkLatency, 120);
  assert.equal(savedNetworkLab.networkJitter, 35);
  assert.equal(savedNetworkLab.networkLoss, 8);
  assert.equal(networkLoss.parentElement.querySelector("output").value, "8");

  document.getElementById("menu-close").click();
  window.DIFF_DEBUG.openSanctumStation("agents");
  assert.equal(app.dataset.panel, "agents");
  assert.equal(
    document.querySelector('[data-menu-panel="agents"]').hidden,
    false,
  );

  document.getElementById("menu-close").click();
  window.DIFF_DEBUG.openSanctumStation("practice");
  assert.match(document.getElementById("practice-menu-reference").textContent, /Stamina.*Elements.*Selected abilities/s);
  document.querySelector('[data-practice-action="start"]').click();
  assert.equal(app.dataset.view, "game");
  assert.equal(window.DIFF_DEBUG.getState().modeId, "sanctum");
  assert.equal(window.DIFF_DEBUG.getState().mapId, "living_sanctum");
  assert.equal(window.DIFF_DEBUG.getState().entities[0].characterId, "kite");
  assert.equal(window.DIFF_DEBUG.getState().entities[0].raceId, "wood_elf");
  assert.equal(window.DIFF_DEBUG.getState().entities[1].bot, true);
  assert.equal(document.getElementById("practice-tools").hidden, false);
  assert.equal(app.classList.contains("sanctum-practice"), true);
  assert.equal(app.classList.contains("hud-detailed"), false);
  document.getElementById("hud-detail-toggle").click();
  assert.equal(app.classList.contains("hud-detailed"), true);
  assert.equal(document.getElementById("hud-detail-toggle").textContent, "Compact HUD");
  assert.equal(JSON.parse(storage.get("flux.presentation.v2")).hudDetailed, true);
  assert.equal(document.getElementById("coach-progress").hidden, true);
  assert.match(document.getElementById("coach-text").textContent, /Practice freely.*F2/i);
  assert.equal(
    document.querySelector('[data-ability="special"] > kbd').textContent,
    "Q",
  );
  assert.equal(
    document.querySelector('[data-ability="defense"] > kbd').textContent,
    "E",
  );
  const moveDown = new window.Event("keydown");
  Object.defineProperty(moveDown, "key", { value: "d" });
  window.dispatchEvent(moveDown);
  const sprintDown = new window.Event("keydown");
  Object.defineProperty(sprintDown, "key", { value: "x" });
  window.dispatchEvent(sprintDown);
  assert.equal(typeof queuedFrame, "function");
  queuedFrame(performance.now() + 16);
  assert.equal(window.DIFF_DEBUG.getState().entities[0].sprinting, true);
  assert.ok(
    window.DIFF_DEBUG.getState().entities[0].flow <
      window.DIFF_DEBUG.getState().entities[0].maxFlow,
  );
  const moveUp = new window.Event("keyup");
  Object.defineProperty(moveUp, "key", { value: "d" });
  window.dispatchEvent(moveUp);
  const sprintUp = new window.Event("keyup");
  Object.defineProperty(sprintUp, "key", { value: "x" });
  window.dispatchEvent(sprintUp);
  const fieldGuide = new window.Event("keydown");
  Object.defineProperty(fieldGuide, "key", { value: "F2" });
  window.dispatchEvent(fieldGuide);
  assert.equal(document.getElementById("practice-overview").hidden, false);
  assert.match(
    document.getElementById("practice-overview-content").textContent,
    /Double jump.*Slide jump.*Air redirect.*Air dodge.*Wavedash.*Wall jump.*Vault.*Superglide.*Elements.*Races/s,
  );
  document.querySelector('[data-practice-action="overview-close"]').click();
  assert.equal(document.getElementById("practice-overview").hidden, true);
  document.querySelector('[data-practice-action="refill"]').click();
  assert.equal(
    window.DIFF_DEBUG.getState().entities[0].flow,
    window.DIFF_DEBUG.getState().entities[0].maxFlow,
  );
  document.querySelector('[data-practice-action="next"]').click();
  assert.equal(window.DIFF_DEBUG.getState().entities[0].characterId, "bulwark");
  assert.equal(document.getElementById("practice-live-character").textContent, "GORUM");
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
  assert.match(recoveredError, /FLUX frame recovered/);
  const callsBeforeRecovery = drawCalls.length;
  queuedFrame(performance.now() + 32);
  assert.ok(drawCalls.length > callsBeforeRecovery);

  const escape = new window.Event("keydown");
  Object.defineProperty(escape, "key", { value: "Escape" });
  window.dispatchEvent(escape);
  assert.equal(
    document.getElementById("pause-overlay").classList.contains("hidden"),
    true,
  );
  window.DIFF_DEBUG.openSanctumStation("settings");
  window.dispatchEvent(escape);
  assert.equal(app.classList.contains("station-open"), false);
  window.DIFF_DEBUG.openSanctumStation("settings");
  document.getElementById("reset-settings").click();
  assert.equal(tacticalBinding.textContent, "E");
  assert.equal(defenseBinding.textContent, "Q");
  assert.equal(sprintBinding.textContent, "ALT");
  assert.equal(techniqueBinding.textContent, "V");
  assert.equal(
    JSON.parse(storage.get("flux.presentation.v2")).bindings.sprint,
    "alt",
  );
  assert.equal(networkLatency.value, "0");
  assert.equal(networkJitter.value, "0");
  assert.equal(networkLoss.value, "0");
  document.getElementById("menu-close").click();

  for (const modeId of ["duel", "control", "convergence", "survival"]) {
    window.DIFF_DEBUG.openSanctumStation("home");
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
        ? "OATH DUEL"
        : window.DIFF_DEBUG.getState().modeId === "control"
          ? "RUNEHOLD"
          : window.DIFF_DEBUG.getState().modeId === "convergence"
            ? "WILDMARCH"
            : "NIGHT SIEGE",
    );
    if (modeId === "convergence") {
      const wildmarch = window.DIFF_DEBUG.getState().wildmarch;
      assert.equal(wildmarch.routes.length, 2);
      assert.equal(wildmarch.seal.status, "dormant");
      assert.match(
        document.getElementById("info-objective").textContent,
        /WAYSEAL.*outer scoring route/i,
      );
      assert.match(
        document.getElementById("coach-text").textContent,
        /WAYSEAL.*outer scoring route/i,
      );
    }
    const fieldInfo = new window.Event("keydown");
    Object.defineProperty(fieldInfo, "key", { value: "F1" });
    window.dispatchEvent(fieldInfo);
    assert.equal(
      document.getElementById("info-overlay").classList.contains("hidden"),
      true,
    );

    window.dispatchEvent(escape);
    document.querySelector('#pause-overlay [data-action="menu"]').click();
    assert.equal(app.dataset.view, "game");
    assert.equal(window.DIFF_DEBUG.getInterfaceState().matchKind, "sanctum");
    assert.equal(window.DIFF_DEBUG.getInterfaceState().suspendedContestKind, "local");
  }

  window.DIFF_DEBUG.openSanctumStation("agents");
  document.querySelector('[data-select-agent="rimewing"]').click();
  document.querySelector('[data-launch-mode="duel"]').click();
  assert.equal(window.DIFF_DEBUG.getState().entities[0].characterId, "rimewing");
  assert.equal(document.getElementById("ultimate-ability").hidden, false);
  assert.equal(
    document.getElementById("ultimate-name").textContent,
    "THE WHITE HUNT",
  );
  document.getElementById("info-toggle").click();
  assert.match(document.getElementById("info-kit").textContent, /RIDGELINE HUNT/);
  assert.match(document.getElementById("info-kit").textContent, /THE WHITE HUNT/);
  window.dispatchEvent(escape);
  window.dispatchEvent(escape);
  document.querySelector('#pause-overlay [data-action="menu"]').click();

  window.DIFF_DEBUG.openSanctumStation("agents");
  document.querySelector('[data-select-agent="ashmaw"]').click();
  document.querySelector('[data-launch-mode="duel"]').click();
  assert.equal(window.DIFF_DEBUG.getState().entities[0].characterId, "ashmaw");
  assert.equal(document.getElementById("ultimate-ability").hidden, false);
  assert.equal(
    document.getElementById("ultimate-name").textContent,
    "THE ASHEN CROWN",
  );
  document.getElementById("info-toggle").click();
  assert.match(document.getElementById("info-kit").textContent, /PYRE-FORGED/);
  assert.match(document.getElementById("info-kit").textContent, /THE ASHEN CROWN/);
  window.dispatchEvent(escape);
  window.dispatchEvent(escape);
  document.querySelector('#pause-overlay [data-action="menu"]').click();

  window.DIFF_DEBUG.openSanctumStation("agents");
  document.querySelector('[data-select-agent="kite"]').click();
  document.querySelector('[data-launch-mode="duel"]').click();
  assert.equal(window.DIFF_DEBUG.getState().entities[0].characterId, "kite");
  assert.equal(document.getElementById("ultimate-ability").hidden, false);
  assert.equal(
    document.getElementById("ultimate-name").textContent,
    "THE TURNING SKY",
  );
  document.getElementById("info-toggle").click();
  assert.match(document.getElementById("info-kit").textContent, /THREAD THE TURN/);
  assert.match(document.getElementById("info-kit").textContent, /THE TURNING SKY/);
  window.dispatchEvent(escape);
  window.dispatchEvent(escape);
  document.querySelector('#pause-overlay [data-action="menu"]').click();

  window.DIFF_DEBUG.openSanctumStation("agents");
  document.querySelector('[data-select-agent="volt"]').click();
  assert.equal(app.dataset.panel, "play");
  assert.equal(
    document.querySelector('input[name="character"][value="volt"]').checked,
    true,
  );
  window.DIFF_DEBUG.openSanctumStation("arenas");
  document.querySelector('[data-atlas-scope="fracture"]').click();
  assert.equal(document.getElementById("map-options").dataset.scope, "fracture");
  assert.ok(document.querySelector('input[name="map"][value="ashen_ford"]'));
  document.querySelector('[data-atlas-scope="realm"]').click();
  assert.equal(document.getElementById("map-options").dataset.scope, "realm");
  document.querySelector('[data-select-map="crown"]').click();
  assert.equal(app.dataset.panel, "play");
  assert.equal(
    document.querySelector('input[name="map"][value="crown"]').checked,
    true,
  );
  assert.match(
    document.getElementById("deployment-summary").textContent,
    /NIM COPPERSPARK · THE OLD CROWN/,
  );

  window.DIFF_DEBUG.openSanctumStation("play");
  const deployClick = new window.Event("click", {
    bubbles: true,
    cancelable: true,
  });
  document.querySelector(".deploy-button").dispatchEvent(deployClick);
  assert.equal(
    deployClick.defaultPrevented,
    false,
    "menu delegation must not cancel the Play form's submit button",
  );
  const solo = document.querySelector('input[name="format"][value="solo"]');
  const local = document.querySelector('input[name="format"][value="local"]');
  solo.checked = false;
  local.checked = true;
  local.dispatchEvent(new window.Event("change", { bubbles: true }));
  assert.equal(document.getElementById("player-two-field").hidden, false);
  document.getElementById("match-hazards").checked = false;
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
  assert.equal(localState.rules.hazardsEnabled, false);
  assert.deepEqual(window.DIFF_DEBUG.getInvariantErrors(), []);

  queuedFrame(performance.now() + 32);
  assert.ok(window.DIFF_DEBUG.getState().tick > 0);
  const restart = new window.Event("keydown");
  Object.defineProperty(restart, "key", { value: "r" });
  window.dispatchEvent(restart);
  assert.equal(window.DIFF_DEBUG.getState().tick, 0);
  assert.ok(window.DIFF_DEBUG.getState().entities.every((entity) => entity.alive));

  window.dispatchEvent(escape);
  document.querySelector('#pause-overlay [data-action="menu"]').click();
  window.DIFF_DEBUG.openSanctumStation("online");
  document.getElementById("host-lobby").click();
  await new Promise((resolve) => setImmediate(resolve));
  assert.equal(window.DIFF_DEBUG.getInterfaceState().matchKind, "remote");
  assert.equal(storage.has("flux.remote.session.v1"), true);
  assert.match(
    document.getElementById("coach-text").textContent,
    /OVERTIME.*next score wins/i,
  );
  window.dispatchEvent(escape);
  document.querySelector('#pause-overlay [data-action="menu"]').click();
  assert.equal(app.dataset.view, "game");
  assert.equal(app.dataset.remoteSession, "connected");
  assert.equal(window.DIFF_DEBUG.getInterfaceState().matchKind, "sanctum");
  assert.equal(window.DIFF_DEBUG.getInterfaceState().suspendedContestKind, "remote");
  assert.equal(fakeSocket.readyState, FakeWebSocket.OPEN);
  assert.equal(socketMessages.some((message) => message.type === "leave"), false);
  for (const panel of [
    "home",
    "practice",
    "play",
    "online",
    "agents",
    "arenas",
    "guide",
    "settings",
  ]) {
    window.DIFF_DEBUG.openSanctumStation(panel);
    assert.equal(app.dataset.panel, panel);
    assert.equal(window.DIFF_DEBUG.getInterfaceState().matchKind, "sanctum");
    assert.equal(fakeSocket.readyState, FakeWebSocket.OPEN);
    document.getElementById("menu-close").click();
  }
  window.DIFF_DEBUG.openSanctumStation("home");
  assert.equal(document.getElementById("sanctum-party").hidden, false);
  document.querySelector('#sanctum-party [data-action="resume"]').click();
  assert.equal(window.DIFF_DEBUG.getInterfaceState().matchKind, "remote");
  window.dispatchEvent(escape);
  document.querySelector('#pause-overlay [data-action="menu"]').click();
  window.DIFF_DEBUG.openSanctumStation("online");
  document.getElementById("leave-lobby").click();
  assert.equal(window.DIFF_DEBUG.getInterfaceState().matchKind, "sanctum");
  assert.equal(app.dataset.remoteSession, "none");
  assert.equal(document.getElementById("sanctum-party").hidden, true);
  assert.equal(socketMessages.filter((message) => message.type === "leave").length, 1);
  document.getElementById("host-lobby").click();
  await new Promise((resolve) => setImmediate(resolve));
  assert.equal(window.DIFF_DEBUG.getInterfaceState().matchKind, "remote");
  fakeSocket.emitMessage({
    type: "server-shutdown",
    code: "host-shutdown",
    message: "The authoritative host shut down. This match has ended.",
  });
  fakeSocket.close();
  assert.equal(document.getElementById("pause-title").textContent, "Host realm closed");
  assert.match(
    document.getElementById("pause-copy").textContent,
    /host shut down.*contest has ended/i,
  );
  assert.equal(
    document.getElementById("server-status").textContent.trim(),
    "AUTHORITATIVE HOST CLOSED",
  );
  assert.equal(storage.has("flux.remote.session.v1"), false);
  assert.equal(document.getElementById("reconnect-lobby").hidden, true);
});
