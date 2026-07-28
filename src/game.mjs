import {
  ABILITY_CATALOG,
  CHARACTER_ROSTER,
  CHARACTERS,
  MAPS,
  MATCH_TUNING,
  MODES,
  RACES,
  getCharacter,
  getLoadoutRule,
  getMap,
  getMode,
  getRace,
  validateLoadout,
} from "./live-content.mjs";
import {
  applyFreeplayAction,
  createMatch,
  matchInvariantErrors,
  sanitizeCommand,
  setFreeplaySettings,
  skipTutorial,
  stepMatch,
} from "./match.mjs";
import {
  NETWORK_PROBE_INTERVAL_MS,
  beginNetworkProbe,
  createNetworkDiagnostics,
  expireNetworkProbes,
  receiveNetworkProbe,
  summarizeNetworkDiagnostics,
} from "./network/quality.mjs";
import { createLobbyInvite, remoteServerFromHint } from "./network/invite.mjs";
import {
  conditionPacket,
  configurePacketConditioner,
  createPacketConditioner,
  drainPackets,
  isFreshServerTick,
  networkLabActive,
} from "./network/conditioner.mjs";

const FIXED_DELTA = 1 / MATCH_TUNING.tickRate;
const SETTINGS_KEY = "flux.presentation.v2";
const LEGACY_SETTINGS_KEY = "diff.presentation.v2";
const RECONNECT_KEY = "flux.remote.session.v1";
const LEGACY_RECONNECT_KEY = "diff.remote.session.v1";
const BINDING_ACTIONS = Object.freeze([
  "moveUp",
  "moveLeft",
  "moveDown",
  "moveRight",
  "fire",
  "tactical",
  "defense",
  "mobility",
  "sprint",
  "hop",
  "ultimate",
  "interact",
]);
const DEFAULT_BINDINGS = Object.freeze({
  moveUp: Object.freeze(["w"]),
  moveLeft: Object.freeze(["a"]),
  moveDown: Object.freeze(["s"]),
  moveRight: Object.freeze(["d"]),
  fire: Object.freeze([" ", "mouse1"]),
  tactical: Object.freeze(["e", "mouse2"]),
  defense: Object.freeze(["q"]),
  mobility: Object.freeze(["shift"]),
  sprint: Object.freeze(["alt"]),
  hop: Object.freeze(["c", "wheelup"]),
  ultimate: Object.freeze(["f"]),
  interact: Object.freeze(["x"]),
});
const BINDING_NAMES = Object.freeze({
  moveUp: "Move up",
  moveLeft: "Move left",
  moveDown: "Move down",
  moveRight: "Move right",
  fire: "Primary",
  tactical: "Tactical",
  defense: "Defense",
  mobility: "Mobility",
  sprint: "Sprint",
  hop: "Hop",
  ultimate: "Ultimate",
  interact: "Interact",
});
const PROTECTED_BINDING_KEYS = new Set([
  "escape",
  "f1",
  "r",
  "t",
  "tab",
  "enter",
  "arrowleft",
  "arrowright",
  "arrowup",
  "arrowdown",
  "i",
  "j",
  "k",
  "l",
  "u",
  "o",
  "p",
  "h",
  ",",
  ".",
]);
const DEFAULT_SETTINGS = Object.freeze({
  screenShake: 55,
  interfaceScale: 100,
  sound: 45,
  coaching: true,
  reducedMotion: false,
  highContrast: false,
  hudDetailed: false,
  bindings: DEFAULT_BINDINGS,
  networkLatency: 0,
  networkJitter: 0,
  networkLoss: 0,
});

const app = element("app");
const canvas = element("arena");
const context = canvas.getContext("2d", { alpha: false });
const frontEnd = element("front-end");
const hud = element("hud");
const pauseOverlay = element("pause-overlay");
const matchOverlay = element("match-overlay");
const menuClose = element("menu-close");
const rosterHud = element("roster-hud");
const toastStack = element("toast-stack");
const infoOverlay = element("info-overlay");
const infoToggle = element("info-toggle");
const hudDetailToggle = element("hud-detail-toggle");
const settingsForm = element("settings-form");
const matchForm = element("match-form");
const pointer = { x: 0, y: 0, active: false };
const keys = new Set();
const mouseButtons = new Set();
const wheelInputs = new Set();
const requestResolvers = new Map();
const particles = [];
const rings = [];
const trails = new Map();
const menuGamepadHeld = new Set();

let settings = loadSettings();
let bindingCapture = null;
let menuPanel = "home";
let atlasScope = "realm";
let loadoutCharacterId = null;
let loadoutModeId = null;
let draggedAbilityId = null;
const SANCTUM_PLAYER = Object.freeze({
  id: "p1",
  name: "PLAYER 1",
  characterId: "mara",
  raceId: "human",
  team: "alpha",
  human: true,
  localSlot: 0,
});

let matchState = createMatch(createSanctumOptions());
let matchKind = "local";
let lastLocalOptions = createSanctumOptions();
let paused = false;
let infoOpen = false;
let frameTime = performance.now();
let accumulator = 0;
let interfaceAccumulator = 0;
let screenShake = 0;
let lastProcessedTick = -1;
let audioContext = null;
let socket = null;
let socketBase = null;
let socketHelloResolver = null;
let remoteEntityId = null;
let remoteLobby = null;
let remoteSequence = 0;
let pendingInputs = [];
let lastSnapshotAt = 0;
let networkDiagnostics = createNetworkDiagnostics();
let networkConditioner = createPacketConditioner();
let lastAuthoritativeTick = -1;
let remoteHostId = null;
let clientId = null;
let remoteRole = "player";
let remoteServerShutdown = false;
let viewport = {
  pixelRatio: 1,
  width: 1,
  height: 1,
  scale: 1,
  offsetX: 0,
  offsetY: 0,
};

buildContentInterface();
syncSettingsForm();
applySettings();
showPanel("home");
resize();
const launchParameters = new URLSearchParams(location.search ?? "");
const linkedLobbyCode = launchParameters.get("join");
const linkedServer = launchParameters.get("server");
const hintedServer = remoteServerFromHint(linkedServer);
if (hintedServer) element("server-address").value = hintedServer;
if (linkedLobbyCode) {
  openSanctumMenu("online");
  element("join-code").value = linkedLobbyCode.toUpperCase();
  window.setTimeout(() => joinLobby(linkedLobbyCode), 0);
} else if (launchParameters.get("friends") === "1") {
  openSanctumMenu("online");
  element("lobby-public").checked = false;
  setNetworkMessage("FRIEND HOST · create a private lobby, then send the invite link.");
} else {
  enterGame();
  toast("FREEPLAY · SANCTUM");
}

window.addEventListener("resize", resize);
window.addEventListener("blur", () => {
  keys.clear();
  mouseButtons.clear();
  wheelInputs.clear();
});
window.addEventListener("keydown", handleKeyDown);
window.addEventListener("keyup", (event) => keys.delete(normalizeInputKey(event.key)));
window.addEventListener("wheel", handleWheelInput, { passive: false });
window.addEventListener("mousedown", handleBindingPointerCapture, true);
canvas.addEventListener("contextmenu", (event) => event.preventDefault());
canvas.addEventListener("pointermove", (event) => {
  pointer.x = event.clientX;
  pointer.y = event.clientY;
  pointer.active = true;
});
canvas.addEventListener("pointerdown", (event) => {
  ensureAudio();
  const token = `mouse${event.button + 1}`;
  if ((settings.bindings.interact ?? []).includes(token) && activateNearbyStation()) {
    event.preventDefault();
    return;
  }
  mouseButtons.add(event.button);
  pointer.x = event.clientX;
  pointer.y = event.clientY;
  pointer.active = true;
  canvas.setPointerCapture?.(event.pointerId);
});
canvas.addEventListener("pointerup", (event) => {
  mouseButtons.delete(event.button);
  canvas.releasePointerCapture?.(event.pointerId);
});
canvas.addEventListener("pointerleave", () => {
  mouseButtons.clear();
  pointer.active = false;
});
frontEnd.addEventListener("click", handleMenuClick);
frontEnd.addEventListener("input", handleFreeplayInput);
frontEnd.addEventListener("dragstart", handleLoadoutDragStart);
frontEnd.addEventListener("dragover", handleLoadoutDragOver);
frontEnd.addEventListener("dragleave", handleLoadoutDragLeave);
frontEnd.addEventListener("drop", handleLoadoutDrop);
pauseOverlay.addEventListener("click", handleOverlayClick);
matchOverlay.addEventListener("click", handleOverlayClick);
menuClose.addEventListener("click", resumeGame);
element("resume-sanctum").addEventListener("click", resumeGame);
element("resume-freeplay").addEventListener("click", resumeGame);
matchForm.addEventListener("submit", startConfiguredMatch);
matchForm.addEventListener("change", handleMatchFormChange);
element("bot-count").addEventListener("input", () => {
  element("bot-count-output").value = element("bot-count").value;
});
settingsForm.addEventListener("input", updateSettings);
settingsForm.addEventListener("click", handleBindingClick);
element("reset-settings").addEventListener("click", resetSettings);
element("skip-coach").addEventListener("click", () => {
  skipTutorial(matchState);
  updateInterface();
});
element("host-lobby").addEventListener("click", hostLobby);
element("copy-share-link").addEventListener("click", copyShareLink);
element("join-lobby").addEventListener("click", () =>
  joinLobby(element("join-code").value),
);
element("reconnect-lobby").addEventListener("click", reconnectLastSession);
element("refresh-lobbies").addEventListener("click", refreshLobbies);
element("rematch").addEventListener("click", restartMatch);
infoToggle.addEventListener("click", () => toggleInfo());
hudDetailToggle.addEventListener("click", toggleHudDetail);
element("info-close").addEventListener("click", () => toggleInfo(false));
element("online-agent").addEventListener("change", syncOnlineRace);

requestAnimationFrame(frame);
let lastFrameErrorAt = Number.NEGATIVE_INFINITY;

function frame(now) {
  requestAnimationFrame(frame);
  try {
    runFrame(now);
  } catch (error) {
    console.error("FLUX frame recovered", error);
    if (now - lastFrameErrorAt > 2_000) {
      toast("Presentation recovered · R still restarts", "error");
      lastFrameErrorAt = now;
    }
  }
}

function runFrame(now) {
  const rawDelta = Math.max(0, (now - frameTime) / 1000);
  const delta = Math.min(rawDelta, MATCH_TUNING.maxFrameDelta);
  frameTime = now;
  updateNetworkProbes(now);
  flushConditionedNetwork(now);
  updateMenuGamepad();
  if (app.dataset.view === "game" && !paused) {
    accumulator += delta;
    let steps = 0;
    while (accumulator >= FIXED_DELTA && steps < 16) {
      if (matchKind === "local") {
        stepMatch(matchState, readCommands(), FIXED_DELTA);
        processEvents(matchState.events, matchState.tick);
      } else if (matchKind === "remote" && matchState) {
        predictRemoteTick();
      }
      accumulator -= FIXED_DELTA;
      steps += 1;
    }
    if (steps === 16) accumulator = 0;
  } else {
    accumulator = 0;
  }
  wheelInputs.clear();
  updateEffects(delta);
  render(now / 1000);
  interfaceAccumulator += delta;
  if (interfaceAccumulator >= 1 / 20) {
    updateInterface();
    interfaceAccumulator %= 1 / 20;
  }
}

function updateMenuGamepad() {
  if (app.dataset.view !== "menu") {
    menuGamepadHeld.clear();
    return;
  }
  const gamepad = navigator.getGamepads?.()[0];
  if (!gamepad) {
    menuGamepadHeld.clear();
    return;
  }
  const actions = new Map([
    ["up", Boolean(gamepad.buttons?.[12]?.pressed || gamepad.axes?.[1] < -0.65)],
    ["down", Boolean(gamepad.buttons?.[13]?.pressed || gamepad.axes?.[1] > 0.65)],
    ["left", Boolean(gamepad.buttons?.[14]?.pressed || gamepad.axes?.[0] < -0.65)],
    ["right", Boolean(gamepad.buttons?.[15]?.pressed || gamepad.axes?.[0] > 0.65)],
    ["accept", Boolean(gamepad.buttons?.[0]?.pressed)],
  ]);
  for (const [action, pressed] of actions) {
    if (!pressed) {
      menuGamepadHeld.delete(action);
      continue;
    }
    if (menuGamepadHeld.has(action)) continue;
    menuGamepadHeld.add(action);
    activateMenuGamepadAction(action);
  }
}

function activateMenuGamepadAction(action) {
  const activeNavigation = document.querySelector(`.nav-item[data-panel="${menuPanel}"]`);
  const focused = document.activeElement;
  if (action === "accept") {
    (focused?.matches?.("button, input, select, a") ? focused : activeNavigation)?.click();
    return;
  }
  if (["up", "down"].includes(action)) {
    const navigation = [...document.querySelectorAll(".nav-item")];
    const index = Math.max(0, navigation.indexOf(activeNavigation));
    const direction = action === "down" ? 1 : -1;
    const next = navigation[(index + direction + navigation.length) % navigation.length];
    next.focus();
    showPanel(next.dataset.panel);
    return;
  }
  const key = `arrow${action}`;
  const target = focused?.closest?.(".nav-item, [data-menu-panel]") ? focused : activeNavigation;
  target?.dispatchEvent(new window.KeyboardEvent("keydown", { key, bubbles: true }));
}

function handleKeyDown(event) {
  const key = normalizeInputKey(event.key);
  if (bindingCapture) {
    captureBinding(event, key);
    return;
  }
  if (key === "f1") {
    event.preventDefault();
    if (app.dataset.view === "game") toggleInfo();
    else showPanel("guide");
    return;
  }
  if (app.dataset.view === "menu" && handleMenuKeyDown(event, key)) return;
  if (
    app.dataset.view === "game" &&
    ([
      " ",
      "arrowup",
      "arrowdown",
      "arrowleft",
      "arrowright",
      "tab",
      "alt",
    ].includes(key) || Object.values(settings.bindings).some((binding) => binding.includes(key)))
  ) {
    event.preventDefault();
  }
  if (event.repeat && ["escape", "r", "t"].includes(key)) return;
  if (key === "escape") {
    if (infoOpen) toggleInfo(false);
    else if (app.dataset.view === "game") openPause();
    else if (matchKind !== "none") resumeGame();
    return;
  }
  if (key === "r" && app.dataset.view === "game") {
    restartMatch();
    return;
  }
  if (key === "t" && app.dataset.view === "game") {
    skipTutorial(matchState);
    return;
  }
  if (
    !event.repeat && app.dataset.view === "game" &&
    (settings.bindings.interact ?? []).includes(key) &&
    activateNearbyStation()
  ) {
    return;
  }
  keys.add(key);
}

function handleMenuKeyDown(event, key) {
  if (
    !["arrowup", "arrowdown", "arrowleft", "arrowright", "enter", " "].includes(key)
  ) return false;
  const target = event.target;
  const navigation = [...document.querySelectorAll(".nav-item")];
  const navigationIndex = navigation.indexOf(target);
  if (navigationIndex >= 0 && ["arrowup", "arrowdown"].includes(key)) {
    event.preventDefault();
    const direction = key === "arrowdown" ? 1 : -1;
    const nextNavigation =
      navigation[(navigationIndex + direction + navigation.length) % navigation.length];
    nextNavigation.focus();
    showPanel(nextNavigation.dataset.panel);
    return true;
  }
  if (key === "arrowright" && navigationIndex >= 0) {
    event.preventDefault();
    document
      .querySelector(
        `[data-menu-panel="${target.dataset.panel}"] button, ` +
        `[data-menu-panel="${target.dataset.panel}"] input, ` +
        `[data-menu-panel="${target.dataset.panel}"] select`,
      )
      ?.focus();
    return true;
  }
  if (key === "arrowleft" && target.closest?.("[data-menu-panel]")) {
    event.preventDefault();
    document.querySelector(`.nav-item[data-panel="${menuPanel}"]`)?.focus();
    return true;
  }
  if (key === "enter" && menuPanel === "home" && target === document.body) {
    event.preventDefault();
    quickStart();
    return true;
  }
  return false;
}

function readCommands() {
  const commands = {};
  const localEntities = matchState.entities.filter(
    (entity) => entity.human && entity.localSlot !== null,
  );
  for (const entity of localEntities) {
    commands[entity.id] =
      entity.localSlot === 0 ? readPlayerOne(entity) : readPlayerTwo(entity);
  }
  applyGamepads(commands, localEntities);
  return commands;
}

function readPlayerOne(entity) {
  const movement = directionFromKeys(
    settings.bindings.moveLeft,
    settings.bindings.moveRight,
    settings.bindings.moveUp,
    settings.bindings.moveDown,
  );
  let aim = { x: entity.facingX, y: entity.facingY };
  if (pointer.active) {
    const world = screenToWorld(pointer.x, pointer.y);
    aim = normalize(world.x - entity.x, world.y - entity.y, aim);
  }
  return sanitizeCommand({
    ...movement,
    aimX: aim.x,
    aimY: aim.y,
    fire: actionPressed("fire"),
    special: actionPressed("tactical"),
    defend: actionPressed("defense"),
    mobility: actionPressed("mobility"),
    sprint: actionPressed("sprint"),
    hop: actionPressed("hop"),
    ultimate: actionPressed("ultimate"),
  });
}

function readPlayerTwo(entity) {
  const movement = directionFromKeys(
    "arrowleft",
    "arrowright",
    "arrowup",
    "arrowdown",
  );
  const aimKeys = directionFromKeys("j", "l", "i", "k");
  const aim =
    aimKeys.moveX !== 0 || aimKeys.moveY !== 0
      ? { x: aimKeys.moveX, y: aimKeys.moveY }
      : { x: entity.facingX, y: entity.facingY };
  return sanitizeCommand({
    ...movement,
    aimX: aim.x,
    aimY: aim.y,
    fire: keys.has("u"),
    special: keys.has("o"),
    defend: keys.has("p"),
    mobility: keys.has("enter"),
    sprint: keys.has(","),
    hop: keys.has("."),
    ultimate: keys.has("h"),
  });
}

function readRemoteCommand() {
  const entity = matchState?.entities.find(
    (candidate) => candidate.id === remoteEntityId,
  );
  if (!entity) return sanitizeCommand({});
  const command = readPlayerOne(entity);
  const gamepad = navigator.getGamepads?.()[0];
  return gamepad ? mergeGamepad(command, gamepad) : command;
}

function applyGamepads(commands, entities) {
  const gamepads = navigator.getGamepads?.() ?? [];
  for (const entity of entities) {
    const gamepad = gamepads[entity.localSlot];
    if (gamepad) {
      commands[entity.id] = mergeGamepad(commands[entity.id], gamepad);
    }
  }
}

function mergeGamepad(command, gamepad) {
  const deadzone = (value) => (Math.abs(value ?? 0) >= 0.18 ? value : 0);
  const move = normalize(deadzone(gamepad.axes[0]), deadzone(gamepad.axes[1]));
  const aim = normalize(deadzone(gamepad.axes[2]), deadzone(gamepad.axes[3]));
  return sanitizeCommand({
    moveX: move.x || command.moveX,
    moveY: move.y || command.moveY,
    aimX: aim.x || command.aimX,
    aimY: aim.y || command.aimY,
    fire: command.fire || (gamepad.buttons[7]?.value ?? 0) > 0.35,
    special: command.special || gamepad.buttons[2]?.pressed,
    defend:
      command.defend || (gamepad.buttons[6]?.value ?? 0) > 0.35,
    mobility: command.mobility || gamepad.buttons[0]?.pressed,
    sprint: command.sprint || gamepad.buttons[4]?.pressed,
    hop: command.hop || gamepad.buttons[5]?.pressed,
    ultimate: command.ultimate || gamepad.buttons[3]?.pressed,
  });
}

function inputTokenPressed(token) {
  if (token === "wheelup" || token === "wheeldown") return wheelInputs.has(token);
  if (/^mouse[1-5]$/.test(token)) return mouseButtons.has(Number(token.slice(5)) - 1);
  return keys.has(token);
}

function bindingPressed(binding) {
  const tokens = Array.isArray(binding) ? binding : [binding];
  return tokens.some(inputTokenPressed);
}

function actionPressed(action) {
  return bindingPressed(settings.bindings[action] ?? []);
}

function directionFromKeys(left, right, up, down) {
  const direction = normalize(
    Number(bindingPressed(right)) - Number(bindingPressed(left)),
    Number(bindingPressed(down)) - Number(bindingPressed(up)),
  );
  return { moveX: direction.x, moveY: direction.y };
}

function handleWheelInput(event) {
  const token = event.deltaY < 0 ? "wheelup" : "wheeldown";
  if (bindingCapture) {
    event.preventDefault();
    commitBinding(bindingCapture, token);
    return;
  }
  if (app.dataset.view === "game") {
    if ((settings.bindings.interact ?? []).includes(token) && activateNearbyStation()) {
      event.preventDefault();
      return;
    }
    wheelInputs.add(token);
    if (Object.values(settings.bindings).some((binding) => binding.includes(token))) {
      event.preventDefault();
    }
  }
}

function handleBindingPointerCapture(event) {
  if (!bindingCapture || event.target.closest?.("[data-bind-action]")) return;
  if (event.button < 0 || event.button > 4) return;
  event.preventDefault();
  event.stopPropagation();
  commitBinding(bindingCapture, `mouse${event.button + 1}`);
}

function predictRemoteTick() {
  if (!socket || socket.readyState !== WebSocket.OPEN || !remoteEntityId) return;
  const command = readRemoteCommand();
  remoteSequence += 1;
  pendingInputs.push({ sequence: remoteSequence, command });
  if (pendingInputs.length > MATCH_TUNING.tickRate * 2) {
    pendingInputs.splice(0, pendingInputs.length - MATCH_TUNING.tickRate * 2);
  }
  sendGameplayInput({
    type: "input",
    sequence: remoteSequence,
    command,
  }, performance.now());
  stepMatch(matchState, { [remoteEntityId]: command }, FIXED_DELTA);
}

function networkLabConfig() {
  return {
    latency: settings.networkLatency,
    jitter: settings.networkJitter,
    loss: settings.networkLoss,
  };
}

function sendGameplayInput(message, now) {
  if (!socket || socket.readyState !== WebSocket.OPEN) return;
  if (!networkLabActive(networkLabConfig())) {
    socket.send(JSON.stringify(message));
    return;
  }
  conditionPacket(networkConditioner, "outgoing", message, now);
  flushConditionedNetwork(now);
}

function flushConditionedNetwork(now) {
  if (!networkLabActive(networkLabConfig())) return;
  if (socket?.readyState === WebSocket.OPEN) {
    for (const message of drainPackets(networkConditioner, "outgoing", now)) {
      socket.send(JSON.stringify(message));
    }
  }
  for (const message of drainPackets(networkConditioner, "incoming", now)) {
    deliverSocketMessage(message);
  }
}

function handleMenuClick(event) {
  const freeplayAction = event.target.closest("[data-freeplay-action]");
  if (freeplayAction) {
    runFreeplayAction(freeplayAction.dataset.freeplayAction);
    return;
  }
  const atlasButton = event.target.closest("[data-atlas-scope]");
  if (atlasButton) {
    atlasScope = atlasButton.dataset.atlasScope === "fracture" ? "fracture" : "realm";
    renderMapOptions();
    return;
  }
  const launchButton = event.target.closest("[data-launch-mode]");
  if (launchButton) {
    launchMode(launchButton.dataset.launchMode);
    return;
  }
  const agentButton = event.target.closest("[data-select-agent]");
  if (agentButton) {
    const selected = getCharacter(agentButton.dataset.selectAgent);
    selectMatchChoice("character", selected.id);
    showPanel("play");
    toast(`${getCharacter(agentButton.dataset.selectAgent).name} chosen.`);
    return;
  }
  const mapButton = event.target.closest("[data-select-map]");
  if (mapButton) {
    selectMatchChoice("map", mapButton.dataset.selectMap);
    showPanel("play");
    toast(`${getMap(mapButton.dataset.selectMap).name} selected.`);
    return;
  }
  const quickButton = event.target.closest("[data-quick-start]");
  if (quickButton) {
    quickStart();
    return;
  }
  // The app root mirrors the active panel in data-panel for presentation state.
  // Only controls are navigation targets; matching the root cancels unrelated
  // default actions such as the Muster Hall form submission.
  const panelButton = event.target.closest("a[data-panel], button[data-panel]");
  if (panelButton) {
    event.preventDefault();
    showPanel(panelButton.dataset.panel);
  }
}

function handleBindingClick(event) {
  const button = event.target.closest("[data-bind-action]");
  if (!button) return;
  event.preventDefault();
  const action = button.dataset.bindAction;
  if (!BINDING_ACTIONS.includes(action)) return;
  bindingCapture = action;
  keys.clear();
  syncBindingButtons();
  const status = element("binding-status");
  status.textContent = `${BINDING_NAMES[action]}: press a key · Esc cancels`;
  status.dataset.tone = "waiting";
}

function captureBinding(event, key) {
  event.preventDefault();
  event.stopPropagation?.();
  if (key === "escape") {
    bindingCapture = null;
    syncBindingButtons();
    const status = element("binding-status");
    status.textContent = "Binding unchanged.";
    status.dataset.tone = "";
    return;
  }
  if (key === "backspace") {
    const action = bindingCapture;
    const bindings = { ...settings.bindings, [action]: [...DEFAULT_BINDINGS[action]] };
    settings = normalizeSettings({ ...settings, bindings });
    localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
    bindingCapture = null;
    syncBindingLabels();
    syncBindingButtons();
    const status = element("binding-status");
    status.textContent = `${BINDING_NAMES[action]} reset.`;
    status.dataset.tone = "success";
    return;
  }
  if (!isBindableKey(key) || PROTECTED_BINDING_KEYS.has(key)) {
    const status = element("binding-status");
    status.textContent = "Reserved key. Use another key, mouse button, or wheel direction.";
    status.dataset.tone = "error";
    return;
  }
  commitBinding(bindingCapture, key);
}

function commitBinding(action, token) {
  const current = [...(settings.bindings[action] ?? [])];
  if (!current.includes(token)) current.push(token);
  const bindings = { ...settings.bindings, [action]: current.slice(-4) };
  settings = normalizeSettings({ ...settings, bindings });
  localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
  bindingCapture = null;
  keys.clear();
  wheelInputs.clear();
  syncBindingLabels();
  syncBindingButtons();
  const status = element("binding-status");
  status.textContent = `${BINDING_NAMES[action]}: ${keyLabel(settings.bindings[action])}. Backspace while capturing resets.`;
  status.dataset.tone = "success";
}

function createSanctumOptions() {
  return {
    modeId: "freeplay",
    mapId: "sanctum",
    botCount: 0,
    hazardsEnabled: false,
    players: [{ ...SANCTUM_PLAYER }],
  };
}

function isSanctum() {
  return matchState?.modeId === "freeplay" && matchState?.mapId === "sanctum";
}

function nearbyStation() {
  if (!isSanctum()) return null;
  const player = localPlayer();
  if (!player) return null;
  return [...(getMap(matchState.mapId).stations ?? [])]
    .filter((station) =>
      Math.hypot(player.x - station.x, player.y - station.y) <= station.radius + 70
    )
    .sort((left, right) =>
      Math.hypot(player.x - left.x, player.y - left.y) -
      Math.hypot(player.x - right.x, player.y - right.y)
    )[0] ?? null;
}

function activateNearbyStation() {
  const station = nearbyStation();
  if (!station) return false;
  const panelByKind = {
    play: "play",
    movement: "guide",
    loadout: "play",
    online: "online",
    settings: "settings",
  };
  openSanctumMenu(panelByKind[station.kind] ?? "home");
  toast(station.label);
  if (station.kind === "loadout") {
    window.setTimeout(() => document.querySelector(".loadout-builder")?.scrollIntoView?.({ block: "start" }), 0);
  }
  return true;
}

function startSanctum(panel = null, preserveReconnect = false) {
  leaveRemote(!preserveReconnect);
  const options = createSanctumOptions();
  matchState = createMatch(options);
  lastLocalOptions = structuredClone(options);
  matchKind = "local";
  paused = false;
  remoteEntityId = null;
  pendingInputs = [];
  lastProcessedTick = -1;
  clearEffects();
  enterGame();
  if (panel) openSanctumMenu(panel);
}

function openSanctumMenu(panel = "home") {
  if (!isSanctum()) {
    startSanctum(panel);
    return;
  }
  paused = true;
  app.dataset.view = "menu";
  app.dataset.sanctumMenu = "true";
  toggleInfo(false);
  pauseOverlay.classList.add("hidden");
  matchOverlay.classList.add("hidden");
  menuClose.hidden = false;
  keys.clear();
  mouseButtons.clear();
  showPanel(panel);
  syncFreeplayPanel();
}

function handleFreeplayInput(event) {
  if (!event.target.matches?.("[data-freeplay-setting]")) return;
  applyFreeplaySettingsFromControls();
}

async function applyFreeplaySettingsFromControls() {
  if (!isSanctum()) return;
  const checkbox = (id) => element(id).checked;
  const number = (id) => Number.parseFloat(element(id).value);
  const settingsUpdate = {
    godMode: checkbox("freeplay-god"),
    endlessFlux: checkbox("freeplay-flux"),
    endlessFlow: checkbox("freeplay-flow"),
    instantCooldowns: checkbox("freeplay-cooldowns"),
    endlessUltimate: checkbox("freeplay-ultimate"),
    friendlyFire: checkbox("freeplay-friendly-fire"),
    destructibility: checkbox("freeplay-destruction"),
    reactions: checkbox("freeplay-reactions"),
    freezeBots: checkbox("freeplay-freeze-bots"),
    showHitboxes: checkbox("freeplay-hitboxes"),
    showVelocity: checkbox("freeplay-velocity"),
    showMovementState: checkbox("freeplay-states"),
    damageMultiplier: number("freeplay-damage"),
    speedMultiplier: number("freeplay-speed"),
    timeScale: number("freeplay-time"),
  };
  try {
    if (matchKind === "remote") {
      if (clientId !== remoteHostId) {
        syncFreeplayPanel();
        toast("Only the host changes shared freeplay rules.", "error");
        return;
      }
      const result = await sendRequest("freeplay-settings", { settings: settingsUpdate });
      if (!result.ok) throw new Error(result.message);
    } else {
      setFreeplaySettings(matchState, settingsUpdate);
      syncFreeplayPanel();
    }
  } catch (error) {
    syncFreeplayPanel();
    toast(error.message, "error");
  }
}

function syncFreeplayPanel() {
  const controls = document.querySelector('[data-menu-panel="freeplay"]');
  if (!controls || !isSanctum()) return;
  const values = matchState.rules?.freeplaySettings ?? {};
  const checked = (id, key) => { element(id).checked = Boolean(values[key]); };
  const ranged = (id, key) => {
    element(id).value = String(values[key]);
    const output = document.querySelector(`[data-freeplay-output="${key}"]`);
    if (output) output.value = `${Number(values[key]).toFixed(values[key] < 1 ? 2 : 1)}×`;
  };
  checked("freeplay-god", "godMode");
  checked("freeplay-flux", "endlessFlux");
  checked("freeplay-flow", "endlessFlow");
  checked("freeplay-cooldowns", "instantCooldowns");
  checked("freeplay-ultimate", "endlessUltimate");
  checked("freeplay-friendly-fire", "friendlyFire");
  checked("freeplay-destruction", "destructibility");
  checked("freeplay-reactions", "reactions");
  checked("freeplay-freeze-bots", "freezeBots");
  checked("freeplay-hitboxes", "showHitboxes");
  checked("freeplay-velocity", "showVelocity");
  checked("freeplay-states", "showMovementState");
  ranged("freeplay-damage", "damageMultiplier");
  ranged("freeplay-speed", "speedMultiplier");
  ranged("freeplay-time", "timeScale");
  element("freeplay-counts").textContent =
    `${matchState.entities.length} units · ${matchState.projectiles.length} shots · ${matchState.elementFields.length} fields`;
}

async function runFreeplayAction(action) {
  if (!isSanctum()) startSanctum();
  const player = localPlayer();
  try {
    if (matchKind === "remote") {
      if (clientId !== remoteHostId) throw new Error("Only the host changes the shared sanctuary.");
      const result = await sendRequest("freeplay-action", {
        action,
        options: { entityId: player?.id },
      });
      if (!result.ok) throw new Error(result.message);
    } else if (!applyFreeplayAction(matchState, action, { entityId: player?.id })) {
      throw new Error("Freeplay action unavailable.");
    }
    syncFreeplayPanel();
    toast(action.replaceAll("-", " ").toUpperCase());
  } catch (error) {
    toast(error.message, "error");
  }
}

function handleOverlayClick(event) {
  const action = event.target.closest("[data-action]")?.dataset.action;
  if (action === "resume") resumeGame();
  else if (action === "restart") restartMatch();
  else if (action === "menu") leaveToMenu("home");
  else if (action === "online") {
    const preserveReconnect =
      matchKind === "remote" &&
      (!socket || socket.readyState !== WebSocket.OPEN);
    leaveToMenu("online", preserveReconnect);
  }
}

function showPanel(panel) {
  const candidate = document.querySelector(`[data-menu-panel="${panel}"]`);
  if (!candidate) return;
  if (panel !== "settings" && bindingCapture) {
    bindingCapture = null;
    syncBindingButtons();
    element("binding-status").textContent = "Binding unchanged.";
    element("binding-status").dataset.tone = "";
  }
  menuPanel = panel;
  app.dataset.panel = panel;
  for (const menuPanelElement of document.querySelectorAll("[data-menu-panel]")) {
    const active = menuPanelElement === candidate;
    menuPanelElement.classList.toggle("active", active);
    menuPanelElement.hidden = !active;
  }
  for (const navigation of document.querySelectorAll(".nav-item")) {
    navigation.classList.toggle("active", navigation.dataset.panel === panel);
  }
  if (panel === "online") refreshLobbies();
  if (panel === "online") refreshReconnectButton();
  if (panel === "freeplay") syncFreeplayPanel();
}

function quickStart() {
  const agent = getCharacter("kite");
  startLocal({
    modeId: "training",
    mapId: "breakline",
    botCount: 1,
    players: [
      {
        id: "p1",
        name: "PLAYER 1",
        characterId: "kite",
        raceId: agent.homeRaceId,
        team: "alpha",
        human: true,
        localSlot: 0,
      },
    ],
  });
}

function launchMode(modeId) {
  const mode = getMode(modeId);
  const mapId = selectedMatchChoice("map", "breakline");
  const characterId = selectedMatchChoice("character", "mara");
  const raceId = getCharacter(characterId).homeRaceId;
  selectMatchChoice("mode", mode.id);
  syncLoadoutBuilder();
  startLocal({
    modeId: mode.id,
    mapId,
    botCount: mode.botCount,
    players: [
      {
        id: "p1",
        name: "PLAYER 1",
        characterId,
        raceId,
        team: "alpha",
        human: true,
        localSlot: 0,
        ...selectedLoadoutSpec(characterId, mode.id),
      },
    ],
  });
}

function startConfiguredMatch(event) {
  event.preventDefault();
  const data = new FormData(matchForm);
  const format = data.get("format");
  let modeId = String(data.get("mode") ?? "duel");
  const mapId = String(data.get("map") ?? "breakline");
  const characterId = String(data.get("character") ?? "mara");
  const raceId = getCharacter(characterId).homeRaceId;
  const activeAbilityIds = ["activeOne", "activeTwo", "activeThree"].map((name) => String(data.get(name) ?? ""));
  const ultimateAbilityId = String(data.get("ultimate") ?? "");
  const rosterCharacter = CHARACTER_ROSTER.find((entry) => entry.id === characterId);
  if (rosterCharacter) {
    const loadoutErrors = validateLoadout({ characterId, modeId, activeAbilityIds, ultimateAbilityId });
    if (loadoutErrors.length) {
      toast(loadoutErrors[0], "error");
      showPanel("play");
      return;
    }
  }
  if (format === "local" && !getMode(modeId).allowLocal) {
    modeId = "duel";
    toast("THE FIRST RITE is solo; switched to OATH DUEL for local 2P.");
  }
  const players = [
    {
      id: "p1",
      name: "PLAYER 1",
      characterId,
      raceId,
      team: "alpha",
      human: true,
      localSlot: 0,
      activeAbilityIds,
      ultimateAbilityId,
    },
  ];
  if (format === "local") {
    players.push({
      id: "p2",
      name: "PLAYER 2",
      characterId: String(data.get("characterTwo") ?? "bulwark"),
      raceId: getCharacter(String(data.get("characterTwo") ?? "bulwark")).homeRaceId,
      team: modeId === "survival" ? "alpha" : "beta",
      human: true,
      localSlot: 1,
    });
  }
  startLocal({
    modeId,
    mapId,
    hazardsEnabled: data.get("hazards") === "on",
    players,
    botCount:
      format === "local"
        ? modeId === "convergence"
          ? 2
          : 0
        : Number.parseInt(element("bot-count").value, 10),
  });
}

function startLocal(options) {
  leaveRemote();
  matchState = createMatch(options);
  lastLocalOptions = structuredClone(options);
  matchKind = "local";
  paused = false;
  remoteEntityId = null;
  pendingInputs = [];
  lastProcessedTick = -1;
  clearEffects();
  enterGame();
  ensureAudio();
  toast(`${getMode(options.modeId).name} · ${getMap(options.mapId).name}`);
}

function enterGame() {
  app.dataset.view = "game";
  app.dataset.sanctumMenu = "false";
  toggleInfo(false);
  pauseOverlay.classList.add("hidden");
  matchOverlay.classList.add("hidden");
  menuClose.hidden = false;
  keys.clear();
  mouseButtons.clear();
  accumulator = 0;
  frameTime = performance.now();
  updateInterface();
}

function openPause() {
  if (isSanctum()) {
    openSanctumMenu("home");
    return;
  }
  if (!pauseOverlay.classList.contains("hidden")) {
    resumeGame();
    return;
  }
  paused = true;
  pauseOverlay.classList.remove("hidden");
  element("pause-title").textContent =
    matchKind === "remote" ? "Network menu" : "Operation held";
  element("pause-copy").textContent =
    matchKind === "remote"
      ? "The authoritative match continues while this menu is open."
      : "Local simulation is frozen.";
  keys.clear();
  mouseButtons.clear();
}

function resumeGame() {
  if (matchKind === "none") return;
  app.dataset.view = "game";
  app.dataset.sanctumMenu = "false";
  paused = false;
  pauseOverlay.classList.add("hidden");
  menuClose.hidden = false;
  frameTime = performance.now();
}

async function restartMatch() {
  if (matchKind === "remote") {
    if (!socket || socket.readyState !== WebSocket.OPEN) {
      toast("Connection is not ready.", "error");
      return;
    }
    const result = await sendRequest("rematch");
    if (!result.ok) toast(result.message, "error");
    else toast("Rematch started.");
    return;
  }
  if (lastLocalOptions) startLocal(lastLocalOptions);
}

function leaveToMenu(panel = "home", preserveReconnect = false) {
  startSanctum(panel, preserveReconnect);
}

function selectedLoadoutSpec(characterId, modeId) {
  const roster = CHARACTER_ROSTER.find((entry) => entry.id === characterId);
  if (!roster) return {};
  const activeAbilityIds = [0, 1, 2].map((index) => element(`loadout-active-${index + 1}`).value);
  const ultimateAbilityId = element("loadout-ultimate").value;
  const errors = validateLoadout({ characterId, modeId, activeAbilityIds, ultimateAbilityId });
  return errors.length ? {
    activeAbilityIds: [...roster.activeAbilityIds],
    ultimateAbilityId: roster.ultimateAbilityId,
  } : { activeAbilityIds, ultimateAbilityId };
}

function effectiveLoadoutPoints(character, ability) {
  const affinity = character.affinities?.find((entry) => entry.id === ability.element)?.strength ?? 0;
  return Math.max(1, ability.points - Math.min(3, affinity));
}

function syncLoadoutBuilder(force = false) {
  const characterId = selectedMatchChoice("character", "mara");
  const modeId = selectedMatchChoice("mode", "duel");
  const character = getCharacter(characterId);
  const roster = CHARACTER_ROSTER.find((entry) => entry.id === characterId);
  const rule = getLoadoutRule(modeId);
  const changed = force || loadoutCharacterId !== characterId || loadoutModeId !== modeId;
  loadoutCharacterId = characterId;
  loadoutModeId = modeId;

  const actives = ABILITY_CATALOG.filter(
    (ability) => ability.type === "active" && rule.elements.includes(ability.element),
  );
  const ultimates = ABILITY_CATALOG.filter(
    (ability) => ability.type === "ultimate" && rule.elements.includes(ability.element),
  );
  const defaults = roster?.activeAbilityIds ?? actives.slice(0, 3).map((entry) => entry.id);
  const defaultUltimate = roster?.ultimateAbilityId ?? ultimates[0]?.id ?? "";
  const current = [0, 1, 2].map((index) =>
    changed ? defaults[index] : element(`loadout-active-${index + 1}`).value,
  );
  const selectedUltimate = changed ? defaultUltimate : element("loadout-ultimate").value;

  for (let index = 0; index < 3; index += 1) {
    const select = element(`loadout-active-${index + 1}`);
    select.innerHTML = actives.map((ability) =>
      `<option value="${ability.id}">${ability.name} · ${effectiveLoadoutPoints(character, ability)} SP · ${ability.element}</option>`,
    ).join("");
    select.value = actives.some((ability) => ability.id === current[index])
      ? current[index]
      : defaults[index] ?? actives[index]?.id;
  }
  const ultimateSelect = element("loadout-ultimate");
  ultimateSelect.innerHTML = ultimates.map((ability) =>
    `<option value="${ability.id}">${ability.name} · ${ability.element}</option>`,
  ).join("");
  ultimateSelect.disabled = !rule.ultimates;
  ultimateSelect.value = ultimates.some((ability) => ability.id === selectedUltimate)
    ? selectedUltimate
    : defaultUltimate;

  element("loadout-catalog").innerHTML = actives.map((ability) =>
    `<button class="loadout-chip" type="button" draggable="true" data-loadout-ability="${ability.id}" title="${ability.counterplay.join(" · ")}"><b>${ability.name}</b><small>${ability.element} · ${effectiveLoadoutPoints(character, ability)} SP · ${ability.fluxCost} Flux</small></button>`,
  ).join("");
  validateCurrentLoadout();
}

function currentLoadout() {
  return {
    characterId: selectedMatchChoice("character", "mara"),
    modeId: selectedMatchChoice("mode", "duel"),
    activeAbilityIds: [0, 1, 2].map((index) => element(`loadout-active-${index + 1}`).value),
    ultimateAbilityId: element("loadout-ultimate").value,
  };
}

function validateCurrentLoadout() {
  const loadout = currentLoadout();
  const character = getCharacter(loadout.characterId);
  const roster = CHARACTER_ROSTER.find((entry) => entry.id === loadout.characterId);
  const rule = getLoadoutRule(loadout.modeId);
  const points = loadout.activeAbilityIds.reduce((sum, id) => {
    const ability = ABILITY_CATALOG.find((entry) => entry.id === id);
    return sum + (ability ? effectiveLoadoutPoints(character, ability) : 0);
  }, 0);
  element("loadout-budget").value = `${points} / ${rule.skillPoints} SP`;
  const errors = roster ? validateLoadout(loadout) : [];
  const status = element("loadout-status");
  status.textContent = errors[0] ?? (roster ? "Loadout ready." : "Legacy character uses its signature kit.");
  status.dataset.tone = errors.length ? "error" : "success";
  return errors;
}

function assignLoadoutSlot(index, abilityId) {
  const slots = [0, 1, 2].map((slot) => element(`loadout-active-${slot + 1}`));
  const target = slots[index];
  if (!target?.querySelector(`option[value="${abilityId}"]`)) return;
  const duplicate = slots.findIndex((select, slot) => slot !== index && select.value === abilityId);
  if (duplicate >= 0) slots[duplicate].value = target.value;
  target.value = abilityId;
  validateCurrentLoadout();
}

function handleLoadoutDragStart(event) {
  const chip = event.target.closest?.("[data-loadout-ability]");
  if (!chip) return;
  draggedAbilityId = chip.dataset.loadoutAbility;
  event.dataTransfer?.setData("text/plain", draggedAbilityId);
  if (event.dataTransfer) event.dataTransfer.effectAllowed = "copy";
}

function handleLoadoutDragOver(event) {
  const select = event.target.closest?.("[data-loadout-slot]");
  if (!select || !draggedAbilityId) return;
  event.preventDefault();
  select.classList.add("drag-target");
}

function handleLoadoutDragLeave(event) {
  event.target.closest?.("[data-loadout-slot]")?.classList.remove("drag-target");
}

function handleLoadoutDrop(event) {
  const select = event.target.closest?.("[data-loadout-slot]");
  if (!select) return;
  event.preventDefault();
  select.classList.remove("drag-target");
  const abilityId = event.dataTransfer?.getData("text/plain") || draggedAbilityId;
  assignLoadoutSlot(Number.parseInt(select.dataset.loadoutSlot, 10), abilityId);
  draggedAbilityId = null;
}

function handleMatchFormChange(event) {
  if (event.target.name === "format") {
    const local = event.target.value === "local";
    element("player-two-field").hidden = !local;
    element("bot-field").hidden = local;
    element("arena-step-label").textContent = `${local ? 6 : 5} · Battleground`;
    if (local && !getMode(selectedMatchChoice("mode", "duel")).allowLocal) {
      selectMatchChoice("mode", "duel");
      toast("THE FIRST RITE is solo; OATH DUEL selected for local 2P.");
    }
  }
  syncLoadoutBuilder();
  updateDeploymentSummary();
}

function selectedMatchChoice(name, fallback) {
  return (
    [...matchForm.querySelectorAll(`input[name="${name}"]`)].find(
      (input) => input.checked,
    )?.value ?? fallback
  );
}

function selectMatchChoice(name, value) {
  const inputs = [
    ...matchForm.querySelectorAll(`input[name="${name}"]`),
  ];
  const input = inputs.find((candidate) => candidate.value === value);
  if (!input) return false;
  for (const candidate of inputs) candidate.checked = candidate === input;
  input.checked = true;
  updateDeploymentSummary();
  return true;
}

function updateDeploymentSummary() {
  const mode = getMode(selectedMatchChoice("mode", "duel"));
  const agent = getCharacter(selectedMatchChoice("character", "mara"));
  const race = getRace(agent.homeRaceId);
  const map = getMap(selectedMatchChoice("map", "breakline"));
  element("deployment-summary").textContent =
    `${mode.name} · ${race.name} ${agent.name} · ${map.name}`;
  element("selected-champion-name").textContent = agent.name;
  element("selected-champion-line").textContent = `${race.name} · ${race.feature}`;
  element("selected-champion-glyph").textContent = agent.glyph;
  element("selected-mode-name").textContent = mode.name;
  element("selected-map-name").textContent = map.name;
  element("selected-element-name").textContent = `${agent.affinity.name} · ${agent.affinity.edge}`;
  element("selected-champion").dataset.element = agent.affinity.id;
}

function toggleHudDetail() {
  settings = normalizeSettings({ ...settings, hudDetailed: !settings.hudDetailed });
  localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
  applySettings();
}

function toggleInfo(force = !infoOpen) {
  infoOpen = Boolean(force) && app.dataset.view === "game";
  infoOverlay.classList.toggle("hidden", !infoOpen);
  infoToggle.setAttribute("aria-expanded", String(infoOpen));
  if (infoOpen) {
    updateInfoOverlay(getMode(matchState.modeId), getMap(matchState.mapId));
  }
}

function updateInfoOverlay(mode, map) {
  if (!infoOpen) return;
  const player =
    localPlayer() ??
    matchState.entities.find((entity) => entity.human) ??
    matchState.entities[0];
  if (!player) return;
  const agent = getCharacter(player.characterId);
  const race = getRace(player.raceId);
  const flowRatio = clamp(player.flow / player.maxFlow, 0, 1);
  element("flow-charge").style.transform = `scaleX(${flowRatio})`;
  element("flow-detail").textContent =
    player.grazeCooldown > 0
      ? `Edgeweave ${player.grazeCooldown.toFixed(1)}s`
      : player.hopCooldown > 0
      ? `Hop ${player.hopCooldown.toFixed(1)}s`
      : player.sprinting
        ? "Sprinting"
        : "Sprint / hop";
  const fluxRatio = clamp(player.flux / player.maxFlux, 0, 1);
  element("flux-charge").style.transform = `scaleX(${fluxRatio})`;
  element("flux-detail").textContent =
    player.fluxRecoveryDelay > 0
      ? `${Math.ceil(player.flux)} · committed`
      : `${Math.ceil(player.flux)} · shaping`;
  element("info-operation").textContent = mode.name;
  element("info-objective").textContent =
    matchState.status === "round-over"
      ? "Resetting clean positions for the next read."
      : matchState.status === "match-over"
        ? "Operation complete. Rematch or return to menu."
        : mode.id === "convergence"
          ? wildmarchStatusCopy()
          : modeStatusCopy(mode);
  element("info-status").textContent =
    `Round ${matchState.round} · ${map.name} · ${Math.ceil(player.health)}/${player.maxHealth} HP`;
  element("info-agent-glyph").textContent = agent.glyph;
  element("info-agent-glyph").style.color = agent.accent;
  element("info-agent-name").textContent = agent.name;
  element("info-agent-role").textContent =
    `${race.name} · ${agent.role} · ${agent.affinity.name} ELEMENT`;
  const runtimeKit = {
    special: player.kit?.special ?? agent.tactical,
    defense: player.kit?.defense ?? agent.defense,
    mobility: player.kit?.mobility ?? agent.mobility,
    ultimate: player.kit?.ultimate ?? agent.ultimate,
  };
  const kit = [
    ...(agent.passive ? [["PASSIVE", agent.passive]] : []),
    [`MB1/${keyLabel(settings.bindings.fire)}`, agent.primary],
    [`MB2/${keyLabel(settings.bindings.tactical)}`, runtimeKit.special],
    [keyLabel(settings.bindings.defense), runtimeKit.defense],
    [keyLabel(settings.bindings.mobility), runtimeKit.mobility],
    ...(runtimeKit.ultimate ? [[keyLabel(settings.bindings.ultimate), runtimeKit.ultimate]] : []),
  ];
  element("info-kit").innerHTML = kit
    .map(
      ([key, ability]) =>
        `<div><kbd>${key}</kbd><b>${ability.name}</b><span>${ability.detail}</span></div>`,
    )
    .join("");
}

function updateInterface() {
  if (!matchState) return;
  const mode = getMode(matchState.modeId);
  const map = getMap(matchState.mapId);
  element("score-alpha").textContent = formatScore(matchState.score.alpha, mode);
  element("score-beta").textContent = formatScore(matchState.score.beta, mode);
  element("mode-label").textContent = `${mode.name} · ${map.name} · R${matchState.round}`;
  const remaining = Math.max(0, mode.timeLimit - matchState.elapsed);
  element("match-clock").textContent =
    remaining === 0 && matchState.status === "playing"
      ? "OT"
      : formatClock(remaining);
  updateNetworkReadout();
  updateRoster();
  updateAbilities();
  updateCoach(mode);
  updateInfoOverlay(mode, map);

  const matchOver = matchState.status === "match-over";
  element("rematch").disabled =
    matchKind === "remote" && remoteHostId !== clientId;
  matchOverlay.classList.toggle(
    "hidden",
    !matchOver || app.dataset.view !== "game",
  );
  if (matchOver) {
    const winner =
      matchState.winner === "alpha"
        ? "ALPHA"
        : matchState.winner === "beta"
          ? "BETA"
          : "NO ONE";
    element("result-title").textContent = `${winner} CLAIMS THE OATH`;
    element("result-copy").textContent =
      matchKind === "remote" && remoteHostId !== clientId
        ? "Waiting for the current host to run it back."
        : "The read was made. Run it back instantly.";
  }
}

function updateNetworkReadout() {
  const readout = element("network-readout");
  if (matchKind !== "remote") {
    readout.textContent = "LOCAL · 120 TICK";
    readout.dataset.quality = "local";
    readout.title = "Local deterministic simulation";
    return;
  }
  const summary = summarizeNetworkDiagnostics(networkDiagnostics);
  const role = remoteRole === "spectator" ? "WATCH" : "REMOTE";
  const lab = networkLabConfig();
  const labActive = networkLabActive(lab);
  const stale = performance.now() - lastSnapshotAt > 500 + lab.latency + lab.jitter;
  const metrics =
    summary.rtt === null
      ? "MEASURING"
      : `${Math.round(summary.rtt)} MS · J${Math.round(summary.jitter)} · L${Math.round(summary.loss)}%`;
  const labCopy = labActive
    ? ` · LAB +${lab.latency}±${lab.jitter}MS/${lab.loss}%`
    : "";
  readout.textContent = `${role} ${remoteLobby?.code ?? "------"} · ${stale ? "STALE" : summary.quality.toUpperCase()} · ${metrics}${labCopy}`;
  readout.dataset.quality = stale ? "poor" : summary.quality;
  readout.title = labActive
    ? `Real round-trip metrics · deterministic gameplay lab · ${networkConditioner.dropped} dropped / ${networkConditioner.delivered} delivered`
    : "Round-trip latency · jitter · recent probe loss";
}

function updateRoster() {
  rosterHud.replaceChildren(
    ...matchState.entities
      .filter((entity) => !entity.neutral || matchState.modeId === "convergence")
      .map((entity) => {
        const agent = getCharacter(entity.characterId);
        const race = getRace(entity.raceId);
        const chip = document.createElement("div");
        chip.className = `roster-chip ${entity.alive ? "" : "dead"}`;
        chip.style.setProperty("--agent-color", agent.accent);
        const dot = document.createElement("i");
        const label = document.createElement("b");
        const carriesWayseal =
          matchState.wildmarch?.seal.status === "carried" &&
          matchState.wildmarch.seal.carrierId === entity.id;
        label.textContent =
          `${entity.name} · ${race.name} ${agent.name}${carriesWayseal ? " · WAYSEAL" : ""}`;
        const health = document.createElement("span");
        health.style.width = `${Math.max(0, (entity.health / entity.maxHealth) * 100)}%`;
        chip.append(dot, label, health);
        return chip;
      }),
  );
}

function updateAbilities() {
  const player = localPlayer();
  if (!player) return;
  const agent = getCharacter(player.characterId);
  const runtimeKit = {
    special: player.kit?.special ?? agent.tactical,
    defense: player.kit?.defense ?? agent.defense,
    mobility: player.kit?.mobility ?? agent.mobility,
    ultimate: player.kit?.ultimate ?? agent.ultimate,
  };
  for (const [key, ability] of [
    ["primary", agent.primary],
    ["special", runtimeKit.special],
    ["defense", runtimeKit.defense],
    ["mobility", runtimeKit.mobility],
  ]) {
    element(`${key}-name`).textContent = ability.name;
    element(`${key}-detail`).textContent = ability.fluxCost > 0
      ? `${ability.fluxCost} Flux · ${ability.cooldown.toFixed(1)}s`
      : `${ability.cooldown.toFixed(1)}s`;
    element(`${key}-detail`).title = ability.detail ?? "";
    const cooldown =
      key === "primary"
        ? player.primaryCooldown
        : key === "special"
          ? player.specialCooldown
          : key === "defense"
            ? player.defenseCooldown
            : player.mobilityCooldown;
    const ratio = clamp(1 - cooldown / ability.cooldown, 0, 1);
    element(`${key}-charge`).style.transform = `scaleX(${ratio})`;
  }
  const ultimateSlot = element("ultimate-ability");
  ultimateSlot.hidden = !runtimeKit.ultimate;
  if (runtimeKit.ultimate) {
    const ultimate = runtimeKit.ultimate;
    const ready = player.ultimateCharge >= ultimate.chargeRequired;
    const channeling = player.ultimateWindupRemaining > 0;
    element("ultimate-name").textContent = ultimate.name;
    ultimateSlot.style.setProperty("--ultimate-color", agent.accent);
    element("ultimate-detail").textContent = channeling
      ? `Committed · ${player.ultimateWindupRemaining.toFixed(1)}s`
      : ready
        ? "READY"
        : `${Math.floor(player.ultimateCharge)} / ${ultimate.chargeRequired}`;
    element("ultimate-charge").style.transform =
      `scaleX(${clamp(player.ultimateCharge / ultimate.chargeRequired, 0, 1)})`;
    ultimateSlot.classList.toggle("ready", ready);
    ultimateSlot.classList.toggle("channeling", channeling);
  } else {
    ultimateSlot.classList.remove("ready", "channeling");
    ultimateSlot.style.removeProperty("--ultimate-color");
  }
}

function updateCoach(mode) {
  const coach = element("coach");
  if (!settings.coaching || app.dataset.view !== "game") {
    coach.classList.add("hidden");
    return;
  }
  coach.classList.remove("hidden");
  const text = element("coach-text");
  const skip = element("skip-coach");
  const progress = element("coach-progress");
  if (mode.id === "training" && !matchState.tutorial.skipped) {
    skip.hidden = false;
    progress.hidden = false;
    for (const item of progress.children) {
      const itemStep = Number(item.dataset.coachStep);
      item.classList.toggle("complete", itemStep < matchState.tutorial.step);
      item.classList.toggle("active", itemStep === matchState.tutorial.step);
      item.setAttribute(
        "aria-label",
        `${item.textContent.trim()} — ${itemStep < matchState.tutorial.step ? "complete" : itemStep === matchState.tutorial.step ? "current" : "upcoming"}`,
      );
    }
    if (matchState.tutorial.step === 0) {
      text.textContent = !matchState.tutorial.sprinted
        ? `Hold ${keyLabel(settings.bindings.sprint)} while moving to build sprint speed.`
        : !matchState.tutorial.slid
          ? `At speed, hold ${keyLabel(settings.bindings.sprint)} + ${keyLabel(settings.bindings.hop)} together to commit to a slide.`
          : !matchState.tutorial.hopped
            ? `Release ${keyLabel(settings.bindings.sprint)}, then tap ${keyLabel(settings.bindings.hop)} to hop and carry your angle.`
            : "FLOW chain learned.";
    } else if (matchState.tutorial.step === 1) {
      text.textContent = `MOVE while aiming. Land pressure with MB1 or ${keyLabel(settings.bindings.fire)}.`;
    } else if (matchState.tutorial.step === 2) {
      text.textContent = !matchState.tutorial.mobility
        ? `Tap ${keyLabel(settings.bindings.mobility)} to evade and reset the angle.`
        : !matchState.tutorial.defended
          ? `The spar marks a safe spell. Time ${keyLabel(settings.bindings.defense)} as it arrives.`
          : "Defense read proven.";
    } else if (matchState.tutorial.step === 3) {
      text.textContent = tacticalTrialCopy(localPlayer());
    } else {
      text.textContent = "Language learned. Read the spar and finish the fight.";
    }
  } else {
    skip.hidden = true;
    progress.hidden = true;
    if (matchState.status === "round-over") {
      text.textContent = "Resetting positions. The next read starts clean.";
    } else if (mode.id === "convergence") {
      text.textContent = wildmarchStatusCopy();
    } else if (matchState.objective.contested) {
      text.textContent = "Objective contested. Create space before you score.";
    } else if (matchState.objective.controllingTeam) {
      text.textContent = `${matchState.objective.controllingTeam.toUpperCase()} controls the field.`;
    } else {
      text.textContent =
        mode.id === "duel"
          ? "First to five. Cover, cooldowns, and commitment decide the round."
          : modeStatusCopy(mode);
    }
  }
}

function modeStatusCopy(mode) {
  const player = localPlayer();
  if (mode.id === "freeplay") return `${keyLabel(settings.bindings.interact)} near a station · practice settings stay here.`;
  if (mode.id === "movement") {
    const progress = matchState.movementTrial?.progress[player?.id] ?? 0;
    const total = matchState.movementTrial?.gates.length ?? 0;
    return `GATE ${Math.min(progress + 1, total)}/${total} · movement only wins the route.`;
  }
  if (mode.id === "siege") return `BREAK ENEMY COVER · ${Math.round(matchState.score[player?.team] ?? 0)}/${matchState.siege?.targetScore ?? mode.scoreLimit}.`;
  if (mode.id === "extraction") return `CARGO ${player?.cargo ?? 0}/${matchState.extraction?.required ?? 0} · bank it at EXIT.`;
  if (mode.id === "battle_royale") return `${matchState.battleRoyale?.closing ? "ZONE CLOSING" : "ZONE STABLE"} · last team wins.`;
  if (mode.id === "mirror") return "SAME SPELLS · different movement, race, and reads.";
  if (mode.id === "draft") return "BUILD WITHIN THE SHARED POINT LIMIT.";
  if (mode.id === "team") return `TEAM ELIMS · ${mode.scoreLimit} wins.`;
  return mode.description;
}

function wildmarchStatusCopy() {
  const wildmarch = matchState.wildmarch;
  if (!wildmarch) return getMode("convergence").description;
  const overtime = matchState.overtime ? "OVERTIME · next score wins. " : "";
  const seal = wildmarch.seal;
  if (wildmarch.activeRouteId) {
    const route = wildmarch.routes.find(
      (candidate) => candidate.id === wildmarch.activeRouteId,
    );
    return `${overtime}${route?.name ?? "Outer route"} is the scoring rune for ${Math.ceil(wildmarch.routeRemaining)}s. Rotate or contest it.`;
  }
  if (seal.status === "grounded") {
    return `${overtime}The WAYSEAL is loose for ${Math.ceil(seal.returnRemaining)}s. Claim it before the wild takes it back.`;
  }
  if (seal.status === "carried") {
    const carrier = matchState.entities.find(
      (entity) => entity.id === seal.carrierId,
    );
    const carrierCopy = carrier?.id === localPlayer()?.id
      ? `You carry the WAYSEAL for ${Math.ceil(seal.returnRemaining)}s. Choose either marked outer route.`
      : `${carrier?.name ?? "A fighter"} carries the WAYSEAL. Escort or intercept the route choice.`;
    return `${overtime}${carrierCopy}`;
  }
  return `${overtime}Wild wardens bind the WAYSEAL. Defeat one, claim it, then choose an outer scoring route.`;
}

function tacticalTrialCopy(player) {
  const key = keyLabel(settings.bindings.tactical);
  const prompts = {
    kite: `Aim ${key} into open ground. Carve a Gale channel that changes the next trajectory.`,
    bulwark: `Aim ${key} into open ground. Raise Stone cover that changes the route.`,
    echo: `Cast ${key} to leave a Veil double. Recast later to swap positions.`,
    volt: `Line up the spar and land ${key}. Volt rewards exact interruption timing.`,
    cinder: `Plant ${key} in the spar's route. Hold space until the Ember rune arms.`,
    orbit: `Close the gap, then catch the spar with ${key}. Null needs a punishable window.`,
    mend: `Spend ${key} to shape Tide terrain. It redirects Ember and restores allied FLOW.`,
    rook: `Aim ${key} and land one split Prism ray. Angles create the conversion.`,
    rimewing: `Aim ${key} across the route. Rime trades traction for space control.`,
    ashmaw: `Aim ${key} to inscribe a douseable Ember route with open exits.`,
  };
  return prompts[player?.characterId] ??
    `Commit ${key} where its geometry changes the exchange.`;
}

function localPlayer() {
  if (matchKind === "remote") {
    return matchState.entities.find((entity) => entity.id === remoteEntityId);
  }
  return (
    matchState.entities.find(
      (entity) => entity.human && entity.localSlot === 0,
    ) ?? null
  );
}

function locallyControlled(entityId) {
  if (matchKind === "remote") return entityId === remoteEntityId;
  return matchState.entities.some(
    (entity) => entity.id === entityId && entity.human,
  );
}

function processEvents(events, tick) {
  if (tick <= lastProcessedTick) return;
  lastProcessedTick = tick;
  for (const event of events) {
    if (["hit", "mineBlast", "dashImpact"].includes(event.type)) {
      burst(
        event.x,
        event.y,
        event.type === "hit" ? "#ff5d73" : "#ffca4f",
        event.type === "mineBlast" ? 18 : 8,
      );
      screenShake = Math.max(
        screenShake,
        event.type === "mineBlast" ? 10 : 4,
      );
    } else if (
      ["reflect", "absorb", "counter", "projectileClash"].includes(event.type)
    ) {
      burst(event.x, event.y, "#77f7ce", 10);
      rings.push({
        x: event.x,
        y: event.y,
        radius: 12,
        life: 0.28,
        maximumLife: 0.28,
        color: "#77f7ce",
      });
    } else if (event.type === "elimination") {
      tone(90, 0.15, "sawtooth", 0.13);
      screenShake = Math.max(screenShake, 14);
    } else if (event.type === "shot") {
      tone(190, 0.025, "square", 0.035);
    } else if (event.type === "roundStart") {
      toast(`ROUND ${event.round}`);
    } else if (event.type === "tutorialStep") {
      toast(`READ ${event.step + 1} / 4`);
    } else if (event.type === "tutorialComplete") {
      tone(760, 0.12, "triangle", 0.06);
      toast("PROVEN! · CORE LANGUAGE ONLINE", "comic");
    } else if (event.type === "trainingPressure") {
      tone(285, 0.09, "triangle", 0.045);
      toast("READ! · DEFEND THE MARKED SPELL", "comic");
    } else if (event.type === "defenseRead") {
      tone(690, 0.08, "triangle", 0.055);
      toast("TURN! · DEFENSE READ PROVEN", "comic");
    } else if (event.type === "mineArmed") {
      tone(185, 0.08, "square", 0.045);
      toast("TICK! · EMBER RUNE ARMED", "comic");
    } else if (event.type === "spellGraze") {
      if (locallyControlled(event.entityId)) {
        tone(585, 0.055, "triangle", 0.04);
        burst(event.x, event.y, "#77f7ce", 7);
        toast(`EDGEWEAVE! · +${Math.round(event.amount)} FLOW`, "comic");
      }
    } else if (event.type === "wallKick") {
      toast("WALL KICK · ANGLE STOLEN");
    } else if (event.type === "counterStrafe") {
      tone(240, 0.045, "triangle", 0.035);
      toast("COUNTER-STRAFE · MOMENTUM CUT", "comic");
    } else if (event.type === "landingCut") {
      tone(360, 0.045, "triangle", 0.04);
      toast("LANDING CUT · TURN STOLEN", "comic");
    } else if (event.type === "passivePrimed") {
      tone(540, 0.055, "triangle", 0.045);
      toast(`${event.trigger} · ${event.name}`, "comic");
    } else if (event.type === "passiveSpent") {
      tone(710, 0.045, "triangle", 0.04);
      toast(`${event.name} · HONED!`, "comic");
    } else if (event.type === "passiveGuided") {
      tone(630, 0.07, "sine", 0.05);
      toast(`WHIRR! · ${event.name}`, "comic");
    } else if (event.type === "passiveConverted") {
      tone(155, 0.065, "sawtooth", 0.045);
      toast("KLANG! · PYRE-FORGED", "comic");
    } else if (event.type === "ultimateReady") {
      if (event.entityId === localPlayer()?.id) {
        tone(440, 0.12, "triangle", 0.06);
        toast(`${event.name} · READY`, "comic");
      }
    } else if (event.type === "ultimateTell") {
      tone(96, 0.22, "sawtooth", 0.07);
      const mark = event.kind === "field-crown"
        ? "RING"
        : event.kind === "wind-vortex"
          ? "VORTEX"
          : "LANE";
      toast(
        `${event.name} · ${mark} MARKED!`,
        "comic",
      );
    } else if (event.type === "ultimateCast") {
      const ember = event.element === "fire";
      const gale = event.element === "wind";
      tone(ember ? 145 : gale ? 560 : 740, 0.16, ember ? "sawtooth" : gale ? "sine" : "triangle", 0.08);
      burst(
        ["field-crown", "wind-vortex"].includes(event.kind) ? event.endX : event.x,
        ["field-crown", "wind-vortex"].includes(event.kind) ? event.endY : event.y,
        ember ? "#e87b52" : gale ? "#77f7ce" : "#cceff3",
        24,
      );
      screenShake = Math.max(screenShake, 8);
      toast(`KRAA! · ${event.name}`, "comic");
    } else if (event.type === "ultimateInterrupted") {
      tone(70, 0.12, "square", 0.055);
      toast(`BREAK! · ${event.name} INTERRUPTED`, "comic");
    } else if (event.type === "slide") {
      tone(135, 0.07, "sawtooth", 0.04);
      toast("SLIDE · LOW LINE", "comic");
    } else if (event.type === "slideImpact") {
      tone(82, 0.06, "square", 0.045);
      toast("THUD! · SLIDE BROKEN", "comic");
    } else if (event.type === "elementField") {
      const cue = {
        wind: [520, "sine"],
        earth: [105, "square"],
        ice: [760, "triangle"],
        fire: [165, "sawtooth"],
        water: [410, "sine"],
      }[event.element] ?? [300, "sine"];
      tone(cue[0], 0.09, cue[1], 0.055);
      toast(`${event.element.toUpperCase()} · TERRAIN CHANGED`, "comic");
    } else if (event.type === "fluxDry") {
      tone(72, 0.08, "square", 0.04);
      toast(`LOW FLUX · NEED ${Math.ceil(event.required)}`, "comic");
    } else if (event.type === "shrineClaim") {
      tone(660, 0.12, "triangle", 0.065);
      burst(event.x, event.y, "#efd379", 18);
      rings.push({
        x: event.x, y: event.y, radius: 16,
        life: 0.5, maximumLife: 0.5, color: "#efd379",
      });
      toast(`OATH KEPT! · +${Math.round(event.amount)} FLUX`, "comic");
    } else if (event.type === "waysealReleased") {
      tone(205, 0.11, "triangle", 0.055);
      burst(event.x, event.y, "#efd379", 14);
      toast("WAYSEAL LOOSE! · CLAIM THE WILD MARK", "comic");
    } else if (event.type === "waysealClaimed") {
      tone(520, 0.09, "triangle", 0.055);
      if (locallyControlled(event.entityId)) {
        toast("WAYSEAL CLAIMED · CHOOSE AN OUTER ROUTE", "comic");
      } else {
        toast(`${event.team.toUpperCase()} CARRIES THE WAYSEAL`, "comic");
      }
    } else if (event.type === "waysealDropped") {
      tone(115, 0.1, "square", 0.05);
      burst(event.x, event.y, "#efd379", 10);
      toast("WAYSEAL DROPPED · THE ROUTE IS OPEN", "comic");
    } else if (event.type === "waysealRouted") {
      tone(690, 0.14, "triangle", 0.07);
      burst(event.x, event.y, "#efd379", 20);
      rings.push({
        x: event.x, y: event.y, radius: 18,
        life: 0.6, maximumLife: 0.6, color: "#efd379",
      });
      toast(`${event.routeName} AWAKENS! · SCORING RUNE MOVED`, "comic");
    } else if (event.type === "waysealReturned") {
      tone(260, 0.08, "sine", 0.04);
      toast(
        event.routeId
          ? "WAYSEAL SPENT · CENTER RUNE RESTORED"
          : "WAYSEAL RETURNED TO THE WILD",
      );
    } else if (event.type === "veilDecoy") {
      tone(330, 0.08, "sine", 0.045);
      toast("VEIL · INTENT SPLIT", "comic");
    } else if (event.type === "veilSwap") {
      tone(610, 0.06, "triangle", 0.05);
      toast("FLIP! · POSITION SWAPPED", "comic");
    } else if (event.type === "elementInterrupt") {
      tone(920, 0.055, "square", 0.05);
      burst(event.x, event.y, "#45d9ff", 12);
      toast("ZAKK! · INTERRUPTED", "comic");
    } else if (event.type === "elementReaction") {
      const formed = ["vapor", "magma"].includes(event.reaction);
      const magma = event.reaction === "magma";
      tone(magma ? 120 : 280, 0.12, magma ? "sawtooth" : "sine", 0.05);
      burst(event.x, event.y, magma ? "#ff9b45" : "#d9f7ff", 14);
      toast(`${event.reaction.toUpperCase()}! · FIELD ${formed ? "FORMED" : "CLEARED"}`, "comic");
    } else if (event.type === "stateRepair") {
      toast("Simulation recovered an invalid entity state.", "error");
    }
  }
}

function updateEffects(delta) {
  const drag = Math.pow(0.02, delta);
  for (const particle of particles) {
    particle.x += particle.vx * delta;
    particle.y += particle.vy * delta;
    particle.vx *= drag;
    particle.vy *= drag;
    particle.life -= delta;
  }
  for (const ring of rings) {
    ring.radius += delta * 230;
    ring.life -= delta;
  }
  particles.splice(
    0,
    particles.length,
    ...particles.filter((particle) => particle.life > 0),
  );
  rings.splice(0, rings.length, ...rings.filter((ring) => ring.life > 0));
  screenShake = Math.max(0, screenShake - delta * 42);
}

function clearEffects() {
  particles.length = 0;
  rings.length = 0;
  trails.clear();
  screenShake = 0;
}

function burst(x, y, color, count) {
  if (!Number.isFinite(x) || !Number.isFinite(y)) return;
  for (let index = 0; index < count; index += 1) {
    const angle = (index / count) * Math.PI * 2 + (index % 3) * 0.19;
    const speed = 90 + ((index * 47) % 150);
    particles.push({
      x,
      y,
      vx: Math.cos(angle) * speed,
      vy: Math.sin(angle) * speed,
      life: 0.28 + (index % 4) * 0.04,
      maximumLife: 0.4,
      color,
    });
  }
}

function resize() {
  viewport.pixelRatio = Math.min(window.devicePixelRatio || 1, 2);
  viewport.width = Math.max(1, window.innerWidth);
  viewport.height = Math.max(1, window.innerHeight);
  canvas.width = Math.round(viewport.width * viewport.pixelRatio);
  canvas.height = Math.round(viewport.height * viewport.pixelRatio);
}

function calculateViewport(map) {
  const scale = Math.min(
    viewport.width / map.size.width,
    viewport.height / map.size.height,
  );
  viewport.scale = scale;
  viewport.offsetX = (viewport.width - map.size.width * scale) / 2;
  viewport.offsetY = (viewport.height - map.size.height * scale) / 2;
}

function screenToWorld(screenX, screenY) {
  return {
    x: (screenX - viewport.offsetX) / viewport.scale,
    y: (screenY - viewport.offsetY) / viewport.scale,
  };
}

function render(time) {
  const map = getMap(matchState.mapId);
  context.imageSmoothingEnabled = false;
  calculateViewport(map);
  context.setTransform(
    viewport.pixelRatio,
    0,
    0,
    viewport.pixelRatio,
    0,
    0,
  );
  drawBackdrop(map, time);
  const shakeStrength =
    settings.reducedMotion || app.dataset.view === "menu"
      ? 0
      : screenShake * (settings.screenShake / 100);
  const shakeX = Math.sin(time * 93) * shakeStrength;
  const shakeY = Math.cos(time * 79) * shakeStrength * 0.65;
  context.save();
  try {
    context.translate(viewport.offsetX + shakeX, viewport.offsetY + shakeY);
    context.scale(viewport.scale, viewport.scale);
    drawArena(map, time);
    drawBattleRoyaleZone(map, time);
    drawStations(map, time);
    drawModeObjectives(time);
    drawShrines(time);
    drawWildmarch(time);
    drawObjective(map, time);
    drawElementFields(time);
    drawHazards(time);
    drawDestructibles(time);
    drawObstacles(map);
    drawMines(time);
    drawTrails();
    drawProjectiles();
    drawDecoys(time);
    drawEntities(time);
    drawDiagnostics();
    drawEffects();
  } finally {
    context.restore();
  }
  if (app.dataset.view === "game" && pointer.active && localPlayer()) {
    drawCrosshair(time);
  }
}

function drawBattleRoyaleZone(map, time) {
  const zone = matchState.battleRoyale;
  if (!zone) return;
  context.save();
  try {
    context.fillStyle = "#21172bb8";
    context.beginPath();
    context.rect(0, 0, map.size.width, map.size.height);
    context.arc(zone.centerX, zone.centerY, zone.radius, 0, Math.PI * 2, true);
    context.fill("evenodd");
    context.strokeStyle = zone.closing ? "#d8a5ff" : "#a887c5";
    context.lineWidth = settings.highContrast ? 7 : 4;
    context.setLineDash([14, 9]);
    context.lineDashOffset = settings.reducedMotion ? 0 : -time * 28;
    context.beginPath();
    context.arc(zone.centerX, zone.centerY, zone.radius, 0, Math.PI * 2);
    context.stroke();
    context.setLineDash([]);
  } finally {
    context.restore();
  }
}

function drawModeObjectives(time) {
  const player = localPlayer();
  if (matchState.movementTrial) {
    const progress = matchState.movementTrial.progress[player?.id] ?? 0;
    for (const [index, gate] of matchState.movementTrial.gates.entries()) {
      context.save();
      try {
        const current = index === progress;
        const complete = index < progress;
        context.strokeStyle = complete ? "#77f7ce" : current ? "#fff0aa" : "#7690a8";
        context.fillStyle = complete ? "#77f7ce24" : current ? "#fff0aa22" : "#7690a812";
        context.lineWidth = current ? 5 : 3;
        context.setLineDash(current ? [10, 6] : []);
        context.lineDashOffset = settings.reducedMotion ? 0 : -time * 18;
        context.beginPath();
        context.arc(gate.x, gate.y, gate.radius, 0, Math.PI * 2);
        context.fill();
        context.stroke();
        context.setLineDash([]);
        context.fillStyle = complete ? "#77f7ce" : current ? "#fff0aa" : "#9db0bf";
        context.font = "800 13px ui-monospace, monospace";
        context.textAlign = "center";
        context.textBaseline = "middle";
        context.fillText(String(index + 1), gate.x, gate.y);
      } finally {
        context.restore();
      }
    }
  }
  if (matchState.extraction) {
    const exit = matchState.extraction.exit;
    context.save();
    try {
      context.strokeStyle = "#fff0aa";
      context.fillStyle = "#fff0aa18";
      context.lineWidth = 4;
      context.setLineDash([10, 7]);
      context.lineDashOffset = settings.reducedMotion ? 0 : -time * 15;
      context.beginPath();
      context.arc(exit.x, exit.y, exit.radius, 0, Math.PI * 2);
      context.fill();
      context.stroke();
      context.setLineDash([]);
      context.fillStyle = "#fff6cf";
      context.font = "800 12px ui-monospace, monospace";
      context.textAlign = "center";
      context.textBaseline = "middle";
      context.fillText(`EXIT ${player?.cargo ?? 0}/${matchState.extraction.required}`, exit.x, exit.y);
      for (const drop of matchState.extraction.drops ?? []) {
        context.fillStyle = "#77f7ce";
        context.beginPath();
        context.arc(drop.x, drop.y, 8 + Math.sin(time * 5) * 2, 0, Math.PI * 2);
        context.fill();
      }
    } finally {
      context.restore();
    }
  }
}

function drawStations(map, time) {
  const player = localPlayer();
  for (const station of map.stations ?? []) {
    const close = player && Math.hypot(player.x - station.x, player.y - station.y) <= station.radius + 70;
    context.save();
    try {
      context.translate(station.x, station.y);
      context.strokeStyle = close ? "#fff0aa" : map.visual.accent;
      context.fillStyle = close ? "#fff0aa28" : `${map.visual.accent}14`;
      context.lineWidth = close ? 5 : 3;
      context.setLineDash(close ? [] : [5, 8]);
      context.lineDashOffset = settings.reducedMotion ? 0 : -time * 10;
      context.beginPath();
      context.arc(0, 0, station.radius, 0, Math.PI * 2);
      context.fill();
      context.stroke();
      context.setLineDash([]);
      context.fillStyle = close ? "#fff6cf" : map.visual.accent;
      context.font = "800 12px ui-monospace, monospace";
      context.textAlign = "center";
      context.textBaseline = "middle";
      context.fillText(station.label, 0, 0);
      if (close) {
        context.font = "700 10px ui-monospace, monospace";
        context.fillText(`${keyLabel(settings.bindings.interact)} · OPEN`, 0, station.radius + 16);
      }
    } finally {
      context.restore();
    }
  }
}

function drawDestructibles(time) {
  const materialColors = {
    wood: ["#70543c", "#c4925c"],
    glass: ["#6ca9a7", "#bcefea"],
    stone: ["#5f6570", "#b6bbc3"],
  };
  for (const piece of matchState.destructibles ?? []) {
    const [fill, stroke] = materialColors[piece.material] ?? ["#655d51", "#c7b88f"];
    context.save();
    try {
      const lift = piece.level === "upper" ? -8 : 0;
      context.translate(0, lift);
      if (piece.destroyed) {
        context.globalAlpha = 0.35;
        context.strokeStyle = stroke;
        context.lineWidth = 3;
        for (let index = 0; index < 4; index += 1) {
          const x = piece.x + (index + 0.5) * piece.width / 4;
          context.beginPath();
          context.moveTo(x - 8, piece.y + piece.height * 0.2);
          context.lineTo(x + 8, piece.y + piece.height * 0.8);
          context.stroke();
        }
        continue;
      }
      const ratio = clamp(piece.health / piece.maxHealth, 0, 1);
      const ownerStroke = piece.ownerTeam === "alpha"
        ? "#77f7ce"
        : piece.ownerTeam === "beta"
          ? "#ff5d73"
          : stroke;
      context.fillStyle = fill;
      context.strokeStyle = ownerStroke;
      context.lineWidth = settings.highContrast ? 4 : 2;
      context.fillRect(piece.x, piece.y, piece.width, piece.height);
      context.strokeRect(piece.x, piece.y, piece.width, piece.height);
      if (piece.ownerTeam) {
        context.fillStyle = ownerStroke;
        context.font = "800 10px ui-monospace, monospace";
        context.textAlign = "center";
        context.textBaseline = "middle";
        context.fillText(piece.ownerTeam === "alpha" ? "A" : "B", piece.x + piece.width / 2, piece.y + piece.height / 2);
      }
      context.globalAlpha = 0.32 + (1 - ratio) * 0.55;
      context.strokeStyle = "#fff6cf";
      context.lineWidth = 1.5;
      const cracks = Math.max(0, piece.damageStage ?? Math.floor((1 - ratio) * 3));
      for (let index = 0; index < cracks; index += 1) {
        const x = piece.x + piece.width * (index + 1) / (cracks + 1);
        context.beginPath();
        context.moveTo(x, piece.y);
        context.lineTo(x - 6, piece.y + piece.height * 0.45);
        context.lineTo(x + 4, piece.y + piece.height);
        context.stroke();
      }
      if (piece.level === "upper") {
        context.globalAlpha = 0.75;
        context.fillStyle = "#00000055";
        context.fillRect(piece.x + 7, piece.y + piece.height + 8, piece.width, 6);
      }
    } finally {
      context.restore();
    }
  }
}

function drawDiagnostics() {
  const debug = matchState.rules?.freeplaySettings;
  if (!matchState.rules?.freeplay || !debug) return;
  for (const entity of matchState.entities) {
    if (!entity.alive) continue;
    const agent = getCharacter(entity.characterId);
    context.save();
    try {
      if (debug.showHitboxes) {
        context.strokeStyle = "#ffffffaa";
        context.lineWidth = 1;
        context.beginPath();
        context.arc(entity.x, entity.y, agent.radius, 0, Math.PI * 2);
        context.stroke();
      }
      if (debug.showVelocity) {
        context.strokeStyle = "#ffe27a";
        context.lineWidth = 2;
        context.beginPath();
        context.moveTo(entity.x, entity.y);
        context.lineTo(entity.x + entity.vx * 0.16, entity.y + entity.vy * 0.16);
        context.stroke();
      }
      if (debug.showMovementState) {
        context.fillStyle = "#fff";
        context.font = "700 9px ui-monospace, monospace";
        context.textAlign = "center";
        context.fillText(entity.movementState ?? "grounded", entity.x, entity.y - agent.radius - 24);
      }
    } finally {
      context.restore();
    }
  }
  if (debug.showElementData) {
    for (const field of matchState.elementFields ?? []) {
      const x = field.element === "earth" ? field.x + field.width / 2 : field.x;
      const y = field.element === "earth" ? field.y + field.height / 2 : field.y;
      context.fillStyle = "#ffffffdd";
      context.font = "700 9px ui-monospace, monospace";
      context.textAlign = "center";
      context.fillText(`${field.element} ${Math.max(0, field.duration).toFixed(1)}`, x, y + 18);
    }
  }
}

function drawShrines(time) {
  for (const shrine of matchState.shrines ?? []) {
    context.save();
    try {
      context.translate(shrine.x, shrine.y);
      const ready = shrine.readyIn === 0;
      context.fillStyle = ready ? "#d3b65b24" : "#30291d99";
      context.strokeStyle = ready ? "#efd379" : "#766746";
      context.lineWidth = settings.highContrast ? 5 : 3;
      context.setLineDash(ready ? [5, 7] : [2, 12]);
      context.lineDashOffset = settings.reducedMotion ? 0 : -time * (ready ? 18 : 5);
      context.beginPath();
      context.arc(0, 0, shrine.radius, 0, Math.PI * 2);
      context.fill();
      context.stroke();
      context.setLineDash([]);
      context.fillStyle = ready ? "#f1dfac" : "#897a55";
      context.font = "700 12px Georgia, serif";
      context.textAlign = "center";
      context.textBaseline = "middle";
      context.fillText(ready ? "SPRINT THE OATH" : `${Math.ceil(shrine.readyIn)}s`, 0, 0);
    } finally {
      context.restore();
    }
  }
}

function drawWildmarch(time) {
  const wildmarch = matchState.wildmarch;
  if (!wildmarch) return;
  for (const route of wildmarch.routes) {
    const active = wildmarch.activeRouteId === route.id;
    context.save();
    try {
      context.translate(route.x, route.y);
      context.fillStyle = active ? "#efd3792e" : "#30291d73";
      context.strokeStyle = active ? "#efd379" : "#8b774c";
      context.lineWidth = settings.highContrast ? 5 : active ? 4 : 2;
      context.setLineDash(active ? [10, 5] : [3, 10]);
      context.lineDashOffset = settings.reducedMotion ? 0 : -time * (active ? 22 : 7);
      context.beginPath();
      context.arc(0, 0, route.radius, 0, Math.PI * 2);
      context.fill();
      context.stroke();
      context.setLineDash([]);
      context.fillStyle = active ? "#fff1be" : "#a48f61";
      context.font = "700 11px Georgia, serif";
      context.textAlign = "center";
      context.textBaseline = "middle";
      context.fillText(
        active
          ? `${route.name} · ${Math.ceil(wildmarch.routeRemaining)}s`
          : route.name,
        0,
        route.radius + 16,
      );
    } finally {
      context.restore();
    }
  }

  const seal = wildmarch.seal;
  if (seal.status === "dormant") return;
  if (seal.status === "carried") {
    context.save();
    try {
      context.strokeStyle = "#efd379";
      context.lineWidth = 1.5;
      context.globalAlpha = 0.34;
      context.setLineDash([5, 9]);
      for (const route of wildmarch.routes) {
        context.beginPath();
        context.moveTo(seal.x, seal.y);
        context.lineTo(route.x, route.y);
        context.stroke();
      }
    } finally {
      context.restore();
    }
  }
  context.save();
  try {
    context.translate(seal.x, seal.y);
    const lift = seal.status === "carried" ? -35 : 0;
    context.translate(0, lift);
    context.rotate(
      settings.reducedMotion ? Math.PI / 4 : time * 0.9 + Math.PI / 4,
    );
    const radius = MATCH_TUNING.wildmarch.sealRadius;
    context.fillStyle = "#efd379";
    context.strokeStyle = "#fff1be";
    context.lineWidth = settings.highContrast ? 4 : 2;
    context.shadowColor = "#efd379";
    context.shadowBlur = seal.status === "routed" ? 18 : 10;
    context.fillRect(-radius * 0.55, -radius * 0.55, radius * 1.1, radius * 1.1);
    context.strokeRect(-radius * 0.55, -radius * 0.55, radius * 1.1, radius * 1.1);
  } finally {
    context.restore();
  }
}

function drawBackdrop(map, time) {
  context.fillStyle = map.visual.void;
  context.fillRect(0, 0, viewport.width, viewport.height);
  context.save();
  try {
    context.globalAlpha = settings.highContrast ? 0.28 : 0.13;
    context.strokeStyle = map.visual.accent;
    context.lineWidth = 1;
    context.setLineDash([2, 18]);
    context.lineDashOffset = settings.reducedMotion ? 0 : -time * 8;
    const spacing = 72;
    for (let offset = -viewport.height; offset < viewport.width; offset += spacing) {
      context.beginPath();
      context.moveTo(offset, viewport.height);
      context.lineTo(offset + viewport.height, 0);
      context.stroke();
    }
  } finally {
    context.restore();
  }
}

function drawArena(map, time) {
  const { width, height, inset } = map.size;
  context.fillStyle = map.visual.floor;
  context.fillRect(0, 0, width, height);
  context.strokeStyle = settings.highContrast ? "#a99055" : map.visual.grid;
  context.lineWidth = 1;
  context.globalAlpha = 0.34;
  context.beginPath();
  for (let x = inset; x <= width - inset; x += 80) {
    for (let y = inset; y < height - inset; y += 80) {
      context.moveTo(x - 3, y + 40);
      context.lineTo(x + 3, y + 40);
    }
  }
  for (let y = inset; y <= height - inset; y += 80) {
    for (let x = inset; x < width - inset; x += 80) {
      context.moveTo(x + 40, y - 3);
      context.lineTo(x + 40, y + 3);
    }
  }
  context.stroke();
  context.globalAlpha = 1;
  drawMapDecor(map, time);
  drawLandmarks(map);
  context.strokeStyle = map.visual.accent;
  context.lineWidth = 4;
  context.strokeRect(inset, inset, width - inset * 2, height - inset * 2);
  context.globalAlpha = 0.3;
  context.strokeStyle = map.visual.accent;
  context.setLineDash([4, 10]);
  context.lineDashOffset = settings.reducedMotion ? 0 : -time * 10;
  context.strokeRect(inset + 10, inset + 10, width - inset * 2 - 20, height - inset * 2 - 20);
  context.setLineDash([]);
  context.globalAlpha = 1;
}

function drawMapDecor(map, time) {
  context.save();
  try {
    if (map.id === "sanctum") {
      context.fillStyle = "#b9ca8b";
      for (let y = 64; y < map.size.height - 64; y += 32) {
        for (let x = 64; x < map.size.width - 64; x += 32) {
          if (((x / 32 + y / 32) & 3) !== 0) continue;
          context.fillRect(x, y, 4, 3);
          context.fillRect(x + 9, y + 7, 3, 3);
        }
      }
      context.fillStyle = "#d6c88f";
      context.fillRect(760, 655, 680, 90);
      context.fillRect(1055, 250, 90, 900);
      context.fillStyle = "#79a8a2";
      context.fillRect(90, 515, 230, 370);
      context.strokeStyle = "#d8eed1";
      context.lineWidth = 5;
      context.strokeRect(90, 515, 230, 370);
      for (const [x, y, scale] of [
        [180, 180, 1], [520, 180, 0.9], [1680, 180, 1], [2020, 180, 0.9],
        [180, 1220, 0.9], [520, 1220, 1], [1680, 1220, 0.9], [2020, 1220, 1],
        [500, 690, 0.75], [1700, 690, 0.75],
      ]) {
        context.fillStyle = "#594733";
        context.fillRect(x - 7 * scale, y + 9 * scale, 14 * scale, 22 * scale);
        context.fillStyle = "#446b49";
        context.fillRect(x - 22 * scale, y - 18 * scale, 44 * scale, 34 * scale);
        context.fillStyle = "#75975a";
        context.fillRect(x - 15 * scale, y - 27 * scale, 31 * scale, 20 * scale);
      }
      for (const [x, y] of [[690, 335], [1510, 335], [690, 1065], [1510, 1065]]) {
        context.fillStyle = "#69583d";
        context.fillRect(x - 5, y, 10, 28);
        context.fillStyle = 0.65 + Math.sin(time * 5 + x) * 0.1 > 0.6 ? "#ffe795" : "#e4b85d";
        context.fillRect(x - 8, y - 12, 16, 14);
      }
      context.fillStyle = "#d7868e";
      for (const [x, y] of [[405, 430], [455, 390], [1750, 430], [1800, 390], [440, 990], [1760, 990]]) {
        context.fillRect(x - 3, y - 3, 6, 6);
      }
    } else if (map.id === "rift") {
      const regions = [
        [60, 60, map.size.width / 2 - 90, map.size.height / 2 - 90, "#607957"],
        [map.size.width / 2 + 30, 60, map.size.width / 2 - 90, map.size.height / 2 - 90, "#6e6b55"],
        [60, map.size.height / 2 + 30, map.size.width / 2 - 90, map.size.height / 2 - 90, "#50717a"],
        [map.size.width / 2 + 30, map.size.height / 2 + 30, map.size.width / 2 - 90, map.size.height / 2 - 90, "#6b596e"],
      ];
      context.globalAlpha = 0.32;
      for (const [x, y, width, height, color] of regions) {
        context.fillStyle = color;
        context.fillRect(x, y, width, height);
      }
      context.globalAlpha = 1;
    }
  } finally {
    context.restore();
  }
}

function drawLandmarks(map) {
  for (const landmark of map.landmarks ?? []) {
    context.save();
    try {
      context.fillStyle = map.visual.grid;
      context.strokeStyle = map.visual.accent;
      context.globalAlpha = landmark.type === "rune" ? 0.22 : 0.15;
      context.lineWidth = landmark.type === "rune" ? 3 : 2;
      if (landmark.type === "rune") {
        context.beginPath();
        context.arc(landmark.x, landmark.y, landmark.radius, 0, Math.PI * 2);
        context.moveTo(landmark.x - landmark.radius, landmark.y);
        context.lineTo(landmark.x + landmark.radius, landmark.y);
        context.moveTo(landmark.x, landmark.y - landmark.radius);
        context.lineTo(landmark.x, landmark.y + landmark.radius);
        context.stroke();
      } else {
        context.fillRect(landmark.x, landmark.y, landmark.width, landmark.height);
        context.strokeRect(landmark.x, landmark.y, landmark.width, landmark.height);
      }
      context.globalAlpha = 0.28;
      context.fillStyle = "#f1dfac";
      context.font = "700 12px Georgia, serif";
      context.textAlign = "center";
      context.textBaseline = "middle";
      context.fillText(
        landmark.label,
        landmark.type === "rune" ? landmark.x : landmark.x + landmark.width / 2,
        landmark.type === "rune" ? landmark.y : landmark.y + landmark.height / 2,
      );
    } finally {
      context.restore();
    }
  }
}

function drawObjective(map, time) {
  const mode = getMode(matchState.modeId);
  if (mode.id !== "control" && mode.id !== "convergence") return;
  const objective = matchState.objective ?? map.objective;
  const team = matchState.objective.controllingTeam;
  context.save();
  try {
    context.translate(objective.x, objective.y);
    context.strokeStyle = matchState.objective.contested
      ? "#ffca4f"
      : team === "alpha"
        ? "#77f7ce"
        : team === "beta"
          ? "#ff5d73"
          : "#52657a";
    context.fillStyle =
      team === "alpha"
        ? "#77f7ce10"
        : team === "beta"
          ? "#ff5d7310"
          : "#52657a0b";
    context.lineWidth = settings.highContrast ? 5 : 3;
    context.beginPath();
    context.arc(0, 0, objective.radius, 0, Math.PI * 2);
    context.fill();
    context.stroke();
    context.strokeStyle = "#ffffff13";
    context.lineWidth = 1;
    context.beginPath();
    context.arc(
      0,
      0,
      objective.radius - 12 + Math.sin(time * 2) * 3,
      0,
      Math.PI * 2,
    );
    context.stroke();
  } finally {
    context.restore();
  }
}

function drawHazards(time) {
  for (const hazard of matchState.hazards) {
    context.save();
    try {
      const active = hazard.phase === "active";
      const warning = hazard.phase === "warning";
      context.fillStyle = active
        ? settings.highContrast
          ? "#ff4058aa"
          : "#ff5d735c"
        : warning
          ? "#ffca4f36"
          : "#23334645";
      context.strokeStyle = active
        ? "#ff5d73"
        : warning
          ? "#ffca4f"
          : "#34465a";
      context.lineWidth = active ? 4 : 2;
      context.fillRect(hazard.x, hazard.y, hazard.width, hazard.height);
      context.strokeRect(hazard.x, hazard.y, hazard.width, hazard.height);
      context.globalAlpha = active ? 0.7 : 0.25;
      context.strokeStyle = active ? "#fff" : "#ffca4f";
      context.setLineDash([14, 11]);
      context.lineDashOffset = -time * 70;
      for (let y = hazard.y + 10; y < hazard.y + hazard.height; y += 18) {
        context.beginPath();
        context.moveTo(hazard.x, y);
        context.lineTo(hazard.x + hazard.width, y);
        context.stroke();
      }
    } finally {
      context.restore();
    }
  }
}

function drawElementFields(time) {
  const colors = {
    wind: "#b8ffe8",
    earth: "#d6a769",
    ice: "#9fe7ff",
    fire: "#ff795c",
    water: "#5cbcff",
    charge: "#ffe45c",
    light: "#fff6b5",
    dark: "#8e6bc8",
    mud: "#8a6948",
    "shadow-edge": "#d2b7ff",
    vapor: "#d8f1dd",
    magma: "#ff8b3d",
  };
  const marks = {
    wind: ">>>", earth: "###", ice: "* *", fire: "^^^", water: "~~~",
    charge: "ϟϟ", light: "◇◇", dark: "●", mud: "..", "shadow-edge": "◐",
    vapor: ".:.:", magma: "<> <>",
  };
  for (const field of matchState.elementFields ?? []) {
    context.save();
    try {
      const color = colors[field.element] ?? "#fff";
      context.fillStyle = `${color}24`;
      context.strokeStyle = color;
      context.lineWidth = settings.highContrast ? 4 : 2;
      context.setLineDash(
        field.element === "ice" ? [8, 7]
          : field.element === "vapor" || field.element === "dark" ? [2, 6]
            : field.element === "light" && field.shape === "refracted" ? [12, 4, 2, 4]
              : [],
      );
      context.lineDashOffset = settings.reducedMotion ? 0 : -time * 28;
      context.beginPath();
      if (field.element === "earth") {
        context.rect(field.x, field.y, field.width, field.height);
      } else {
        context.arc(field.x, field.y, field.radius, 0, Math.PI * 2);
      }
      context.fill();
      context.stroke();
      context.setLineDash([]);
      if (field.element === "wind" && field.shape === "vortex") {
        const spin = field.spin === -1 ? -1 : 1;
        context.save();
        context.translate(field.x, field.y);
        context.rotate(settings.reducedMotion ? 0 : time * 0.8 * spin);
        context.lineWidth = settings.highContrast ? 5 : 3;
        for (let index = 0; index < 4; index += 1) {
          const angle = index * Math.PI / 2;
          context.beginPath();
          context.arc(0, 0, field.radius * 0.62, angle, angle + spin * 0.72);
          context.stroke();
          const tip = angle + spin * 0.72;
          context.save();
          context.translate(Math.cos(tip) * field.radius * 0.62, Math.sin(tip) * field.radius * 0.62);
          context.rotate(tip + spin * Math.PI / 2);
          context.fillStyle = color;
          context.beginPath();
          context.moveTo(0, -6);
          context.lineTo(12 * spin, 0);
          context.lineTo(0, 6);
          context.closePath();
          context.fill();
          context.restore();
        }
        context.restore();
      }
      context.fillStyle = color;
      context.font = "700 13px ui-monospace, monospace";
      context.textAlign = "center";
      context.textBaseline = "middle";
      const labelX = field.element === "earth" ? field.x + field.width / 2 : field.x;
      const labelY = field.element === "earth" ? field.y + field.height / 2 : field.y;
      context.fillText(
        field.element === "wind" && field.shape === "vortex"
          ? (field.spin === -1 ? "↺" : "↻")
          : marks[field.element] ?? field.element,
        labelX,
        labelY,
      );
    } finally {
      context.restore();
    }
  }
}

function drawObstacles(map) {
  for (const obstacle of map.obstacles) {
    context.fillStyle = "#30291d";
    context.strokeStyle = settings.highContrast ? "#d2bd82" : "#766746";
    context.lineWidth = settings.highContrast ? 3 : 2;
    context.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
    context.strokeRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
    context.fillStyle = "#f1dfac12";
    context.fillRect(
      obstacle.x + 7,
      obstacle.y + 7,
      obstacle.width - 14,
      4,
    );
  }
}

function drawMines(time) {
  for (const mine of matchState.mines) {
    context.save();
    try {
      context.translate(mine.x, mine.y);
      const armed = mine.armedIn === 0;
      context.strokeStyle = armed ? "#ff6e5f" : "#71554e";
      context.fillStyle = armed ? "#ff6e5f24" : "#312421";
      context.lineWidth = 3;
      context.rotate(time * (armed ? 1.6 : 0.5));
      context.fillRect(-13, -13, 26, 26);
      context.strokeRect(-13, -13, 26, 26);
      if (armed) {
        context.globalAlpha = 0.32 + Math.sin(time * 8) * 0.12;
        context.beginPath();
        context.arc(0, 0, mine.triggerRadius, 0, Math.PI * 2);
        context.stroke();
      }
    } finally {
      context.restore();
    }
  }
}

function drawTrails() {
  for (const entity of matchState.entities) {
    if (!entity.alive) continue;
    const points = trails.get(entity.id) ?? [];
    const speed = Math.hypot(entity.vx, entity.vy);
    if (speed > 70) points.push({ x: entity.x, y: entity.y, speed });
    else if (points.length > 0) points.shift();
    if (points.length > (settings.reducedMotion ? 3 : 10)) points.shift();
    trails.set(entity.id, points);
    if (points.length < 2) continue;
    const agent = getCharacter(entity.characterId);
    context.save();
    try {
      context.strokeStyle = agent.accent;
      context.lineWidth = 4;
      context.globalAlpha = Math.min(0.24, 0.07 + speed / 6000);
      context.beginPath();
      for (const [index, point] of points.entries()) {
        if (index === 0) context.moveTo(point.x, point.y);
        else context.lineTo(point.x, point.y);
      }
      context.stroke();
    } finally {
      context.restore();
    }
  }
}

function drawProjectiles() {
  for (const projectile of matchState.projectiles) {
    context.save();
    try {
      context.translate(projectile.x, projectile.y);
      const color =
        projectile.team === "alpha"
          ? "#77f7ce"
          : projectile.team === "beta"
            ? "#ff5d73"
            : "#ffca4f";
      context.fillStyle = color;
      context.shadowColor = color;
      context.shadowBlur = projectile.heavy ? 18 : 9;
      context.beginPath();
      context.arc(0, 0, projectile.radius, 0, Math.PI * 2);
      context.fill();
      if (projectile.source === "training") {
        context.shadowBlur = 0;
        context.strokeStyle = "#ffca4f";
        context.lineWidth = 2;
        context.beginPath();
        context.moveTo(0, -projectile.radius - 8);
        context.lineTo(projectile.radius + 8, 0);
        context.lineTo(0, projectile.radius + 8);
        context.lineTo(-projectile.radius - 8, 0);
        context.closePath();
        context.stroke();
      }
      const direction = normalize(projectile.vx, projectile.vy);
      context.strokeStyle = color;
      context.globalAlpha = 0.42;
      context.lineWidth = projectile.radius * 0.8;
      context.beginPath();
      context.moveTo(0, 0);
      context.lineTo(
        -direction.x * (projectile.heavy ? 30 : 18),
        -direction.y * (projectile.heavy ? 30 : 18),
      );
      context.stroke();
      if (projectile.guidedRemaining > 0) {
        context.globalAlpha = 0.9;
        context.lineWidth = 2;
        context.beginPath();
        context.arc(0, 0, projectile.radius + 6, -1.1, 1.1);
        context.stroke();
        context.beginPath();
        context.moveTo(-direction.x * 7 - direction.y * 7, -direction.y * 7 + direction.x * 7);
        context.lineTo(-direction.x * 14, -direction.y * 14);
        context.lineTo(-direction.x * 7 + direction.y * 7, -direction.y * 7 - direction.x * 7);
        context.stroke();
      }
    } finally {
      context.restore();
    }
  }
}

function drawEntities(time) {
  for (const entity of matchState.entities) {
    const agent = getCharacter(entity.characterId);
    const race = getRace(entity.raceId ?? agent.homeRaceId);
    context.save();
    try {
      context.translate(entity.x, entity.y);
      context.globalAlpha = 1;
      context.globalCompositeOperation = "source-over";
      if (!entity.alive) {
        context.strokeStyle = "#667588";
        context.globalAlpha = 0.4;
        context.lineWidth = 2;
        context.beginPath();
        context.arc(0, 0, agent.radius + 5, 0, Math.PI * 2);
        context.stroke();
        context.beginPath();
        context.moveTo(-10, -10);
        context.lineTo(10, 10);
        context.moveTo(10, -10);
        context.lineTo(-10, 10);
        context.stroke();
        continue;
      }

      const teamColor =
        entity.team === "alpha"
          ? "#77f7ce"
          : entity.team === "beta"
            ? "#ff5d73"
            : "#ffca4f";
      if (agent.ultimate && entity.ultimateCharge >= agent.ultimate.chargeRequired) {
        context.save();
        context.strokeStyle = agent.accent;
        context.lineWidth = 3;
        context.globalAlpha = 0.62;
        context.setLineDash([5, 6]);
        context.lineDashOffset = settings.reducedMotion ? 0 : -time * 18;
        context.beginPath();
        context.arc(0, 0, agent.radius + 14, 0, Math.PI * 2);
        context.stroke();
        context.setLineDash([]);
        context.restore();
      }
      if (entity.passiveRemaining > 0 || entity.passiveActive) {
        context.save();
        context.strokeStyle = agent.accent;
        context.lineWidth = 2;
        context.globalAlpha = 0.75;
        context.beginPath();
        context.arc(0, 0, agent.radius + 8, -0.7, 0.7);
        context.stroke();
        context.restore();
      }
      if (agent.ultimate && entity.ultimateWindupRemaining > 0) {
        const progress = 1 - entity.ultimateWindupRemaining / agent.ultimate.windup;
        context.save();
        context.fillStyle = `${agent.accent}20`;
        context.strokeStyle = agent.accent;
        context.lineWidth = settings.highContrast ? 5 : 3;
        context.setLineDash([12, 8]);
        context.lineDashOffset = settings.reducedMotion ? 0 : -time * 35;
        if (agent.ultimate.kind === "line-volley") {
          context.rotate(Math.atan2(entity.ultimateAimY, entity.ultimateAimX));
          context.beginPath();
          context.moveTo(agent.radius + 4, -32);
          context.lineTo(agent.ultimate.range, -72);
          context.lineTo(agent.ultimate.range, 72);
          context.lineTo(agent.radius + 4, 32);
          context.closePath();
          context.fill();
          context.stroke();
          context.setLineDash([]);
          context.fillStyle = agent.accent;
          context.fillRect(
            agent.radius + 6,
            -3,
            (agent.ultimate.range - agent.radius - 6) * progress,
            6,
          );
        } else if (agent.ultimate.kind === "field-crown") {
          const targetX = entity.ultimateTargetX - entity.x;
          const targetY = entity.ultimateTargetY - entity.y;
          context.beginPath();
          context.moveTo(0, 0);
          context.lineTo(targetX, targetY);
          context.stroke();
          for (let index = 0; index < agent.ultimate.fieldCount; index += 1) {
            const mark = (index / agent.ultimate.fieldCount) * Math.PI * 2;
            context.beginPath();
            context.arc(
              targetX + Math.cos(mark) * agent.ultimate.crownRadius,
              targetY + Math.sin(mark) * agent.ultimate.crownRadius,
              agent.ultimate.fieldRadius,
              0,
              Math.PI * 2,
            );
            context.fill();
            context.stroke();
          }
          context.setLineDash([]);
          context.lineWidth = 6;
          context.beginPath();
          context.arc(
            targetX,
            targetY,
            agent.ultimate.crownRadius,
            -Math.PI / 2,
            -Math.PI / 2 + Math.PI * 2 * progress,
          );
          context.stroke();
        } else if (agent.ultimate.kind === "wind-vortex") {
          const targetX = entity.ultimateTargetX - entity.x;
          const targetY = entity.ultimateTargetY - entity.y;
          context.beginPath();
          context.moveTo(0, 0);
          context.lineTo(targetX, targetY);
          context.stroke();
          context.beginPath();
          context.arc(targetX, targetY, agent.ultimate.fieldRadius, 0, Math.PI * 2);
          context.fill();
          context.stroke();
          context.setLineDash([]);
          context.lineWidth = 7;
          context.beginPath();
          context.arc(
            targetX,
            targetY,
            agent.ultimate.fieldRadius * 0.68,
            -Math.PI / 2,
            -Math.PI / 2 + agent.ultimate.spin * Math.PI * 2 * progress,
            agent.ultimate.spin < 0,
          );
          context.stroke();
          context.fillStyle = agent.accent;
          context.font = "700 20px ui-monospace, monospace";
          context.textAlign = "center";
          context.textBaseline = "middle";
          context.fillText(agent.ultimate.spin < 0 ? "↺" : "↻", targetX, targetY);
        }
        context.setLineDash([]);
        context.restore();
      }
      if (entity.hopRemaining > 0) {
        const progress = 1 - entity.hopRemaining / MATCH_TUNING.flow.hopDuration;
        const lift = Math.sin(progress * Math.PI) * 11;
        context.fillStyle = "#00000066";
        context.beginPath();
        context.ellipse(
          0,
          5,
          agent.radius * 0.9,
          agent.radius * 0.42,
          0,
          0,
          Math.PI * 2,
        );
        context.fill();
        context.translate(0, -lift);
      } else if (entity.slideRemaining > 0) {
        context.rotate(Math.atan2(entity.slideY, entity.slideX));
        context.scale(1.28, 0.72);
      }
      const defense = agent.defense;
      if (entity.spawnProtection > 0) {
        context.strokeStyle = "#ffffff";
        context.globalAlpha = 0.3 + Math.sin(time * 10) * 0.12;
        context.lineWidth = 2;
        context.setLineDash([5, 5]);
        context.beginPath();
        context.arc(0, 0, agent.radius + 10, 0, Math.PI * 2);
        context.stroke();
        context.setLineDash([]);
        context.globalAlpha = 1;
      }
      if (entity.defenseRemaining > 0) {
        context.strokeStyle =
          defense.kind === "guard"
            ? "#ffca4f"
            : defense.kind === "phase"
              ? "#c38cff"
              : agent.accent;
        context.globalAlpha = 0.82;
        context.lineWidth = defense.kind === "guard" ? 7 : 3;
        if (defense.kind === "phase") context.setLineDash([6, 5]);
        context.beginPath();
        context.arc(0, 0, agent.radius + 8, 0, Math.PI * 2);
        context.stroke();
        context.setLineDash([]);
        context.globalAlpha = 1;
      }
      context.fillStyle = entity.hitFlash > 0 ? "#ffffff" : agent.color;
      context.strokeStyle = teamColor;
      context.lineWidth = settings.highContrast ? 5 : 3;
      context.shadowColor = agent.accent;
      context.shadowBlur = entity.mobilityRemaining > 0 ? 20 : 7;
      context.save();
      try {
        context.rotate(Math.atan2(entity.facingY, entity.facingX));
        traceAgentBody(agent);
        context.fill();
        context.stroke();
        context.shadowBlur = 0;
        drawRaceFeature(race, agent.radius, teamColor);
        context.fillStyle = agent.accent;
        context.font = `900 ${Math.max(11, agent.radius * 0.78)}px ui-monospace, monospace`;
        context.textAlign = "center";
        context.textBaseline = "middle";
        context.fillText(agent.glyph, 0, 0);
      } finally {
        context.restore();
      }

      const healthRatio = clamp(entity.health / entity.maxHealth, 0, 1);
      context.fillStyle = "#06080c";
      context.fillRect(-23, -agent.radius - 16, 46, 4);
      context.fillStyle =
        healthRatio > 0.5 ? teamColor : healthRatio > 0.25 ? "#ffca4f" : "#ff5d73";
      context.fillRect(-23, -agent.radius - 16, 46 * healthRatio, 4);
      context.fillStyle = "#cbd5df";
      context.font = "700 10px ui-monospace, monospace";
      context.textBaseline = "alphabetic";
      context.textAlign = "center";
      const nameLabel = settings.hudDetailed || entity.id === localPlayer()?.id
        ? `${entity.name} · ${agent.name}`
        : entity.name;
      context.fillText(nameLabel, 0, agent.radius + 21);
    } finally {
      context.restore();
    }
  }
}

function drawDecoys(time) {
  for (const decoy of matchState.decoys ?? []) {
    const agent = getCharacter(decoy.characterId);
    context.save();
    try {
      context.translate(decoy.x, decoy.y);
      context.rotate(Math.atan2(decoy.facingY, decoy.facingX));
      context.globalAlpha = 0.38 + Math.sin(time * 7) * 0.08;
      context.fillStyle = `${agent.accent}33`;
      context.strokeStyle = agent.accent;
      context.lineWidth = 2;
      context.setLineDash([5, 4]);
      traceAgentBody(agent);
      context.fill();
      context.stroke();
      drawRaceFeature(getRace(decoy.raceId ?? agent.homeRaceId), agent.radius, agent.accent);
      context.setLineDash([]);
      context.rotate(-Math.atan2(decoy.facingY, decoy.facingX));
      context.fillStyle = "#fff";
      context.font = "800 9px ui-monospace, monospace";
      context.textAlign = "center";
      context.fillText("DECOY", 0, agent.radius + 16);
    } finally {
      context.restore();
    }
  }
}

function traceAgentBody(agent) {
  const radius = agent.radius;
  if (agent.silhouette === "kite") {
    tracePolygon([
      [radius * 1.18, 0],
      [0, radius * 0.78],
      [-radius * 0.92, 0],
      [0, -radius * 0.78],
    ]);
  } else if (agent.silhouette === "block") {
    tracePolygon([
      [radius * 0.82, -radius * 0.72],
      [radius, -radius * 0.32],
      [radius, radius * 0.62],
      [radius * 0.42, radius],
      [-radius * 0.78, radius * 0.76],
      [-radius, 0],
      [-radius * 0.78, -radius * 0.76],
    ]);
  } else if (agent.silhouette === "split") {
    context.beginPath();
    context.arc(-radius * 0.34, 0, radius * 0.72, 0, Math.PI * 2);
    context.moveTo(radius * 1.06, 0);
    context.arc(radius * 0.34, 0, radius * 0.72, 0, Math.PI * 2);
  } else if (agent.silhouette === "bolt") {
    tracePolygon([
      [radius * 1.18, -radius * 0.2],
      [radius * 0.18, radius * 0.08],
      [radius * 0.62, radius],
      [-radius * 1.02, radius * 0.2],
      [-radius * 0.12, -radius * 0.08],
      [-radius * 0.5, -radius],
    ]);
  } else if (agent.silhouette === "flare") {
    const points = [];
    for (let index = 0; index < 16; index += 1) {
      const angle = (index / 16) * Math.PI * 2;
      const extent = index % 2 === 0 ? radius : radius * 0.72;
      points.push([Math.cos(angle) * extent, Math.sin(angle) * extent]);
    }
    tracePolygon(points);
  } else if (agent.silhouette === "cross") {
    const inner = radius * 0.42;
    tracePolygon([
      [inner, -radius],
      [inner, -inner],
      [radius, -inner],
      [radius, inner],
      [inner, inner],
      [inner, radius],
      [-inner, radius],
      [-inner, inner],
      [-radius, inner],
      [-radius, -inner],
      [-inner, -inner],
      [-inner, -radius],
    ]);
  } else if (agent.silhouette === "rook") {
    tracePolygon([
      [radius, 0],
      [radius * 0.62, radius * 0.84],
      [-radius * 0.58, radius * 0.84],
      [-radius, radius * 0.32],
      [-radius, -radius * 0.84],
      [-radius * 0.35, -radius * 0.58],
      [0, -radius],
      [radius * 0.35, -radius * 0.58],
    ]);
  } else if (agent.silhouette === "wing") {
    tracePolygon([
      [radius * 1.1, 0],
      [radius * 0.35, radius * 0.28],
      [radius * 0.72, radius],
      [0, radius * 0.55],
      [-radius * 0.82, radius * 0.9],
      [-radius * 0.58, 0],
      [-radius * 0.82, -radius * 0.9],
      [0, -radius * 0.55],
      [radius * 0.72, -radius],
      [radius * 0.35, -radius * 0.28],
    ]);
  } else if (agent.silhouette === "maw") {
    tracePolygon([
      [radius * 1.12, -radius * 0.34],
      [radius * 0.38, -radius * 0.18],
      [radius * 0.82, -radius],
      [-radius * 0.2, -radius * 0.62],
      [-radius, -radius * 0.8],
      [-radius * 0.68, 0],
      [-radius, radius * 0.8],
      [-radius * 0.2, radius * 0.62],
      [radius * 0.82, radius],
      [radius * 0.38, radius * 0.18],
      [radius * 1.12, radius * 0.34],
      [radius * 0.62, 0],
    ]);
  } else if (agent.silhouette?.startsWith("overhaul-")) {
    const raceId = agent.homeRaceId;
    if (["gnome", "hobbit", "goblin"].includes(raceId)) {
      tracePolygon([[radius, 0], [radius * 0.2, radius * 0.82], [-radius, radius * 0.55], [-radius * 0.78, 0], [-radius, -radius * 0.55], [radius * 0.2, -radius * 0.82]]);
    } else if (["minotaur", "troll", "rootwarden"].includes(raceId)) {
      tracePolygon([[radius, -radius * 0.55], [radius * 0.72, radius * 0.82], [0, radius], [-radius * 0.86, radius * 0.65], [-radius, 0], [-radius * 0.82, -radius * 0.72], [0, -radius]]);
    } else if (["sylph", "elf", "scaleheir"].includes(raceId)) {
      tracePolygon([[radius * 1.18, 0], [radius * 0.25, radius * 0.56], [-radius * 0.72, radius], [-radius * 0.5, 0], [-radius * 0.72, -radius], [radius * 0.25, -radius * 0.56]]);
    } else if (raceId === "seakin") {
      tracePolygon([[radius * 1.15, 0], [radius * 0.1, radius * 0.82], [-radius, radius * 0.52], [-radius * 0.72, 0], [-radius, -radius * 0.52], [radius * 0.1, -radius * 0.82]]);
    } else if (["dwarf", "stonewrought"].includes(raceId)) {
      context.beginPath();
      context.rect(-radius, -radius * 0.72, radius * 1.85, radius * 1.44);
    } else if (raceId === "undead") {
      const inner = radius * 0.45;
      tracePolygon([[radius, -inner], [inner, -inner], [inner, -radius], [-inner, -radius], [-inner, -inner], [-radius, -inner], [-radius, inner], [-inner, inner], [-inner, radius], [inner, radius], [inner, inner], [radius, inner]]);
    } else if (raceId === "nymph") {
      const points = [];
      for (let index = 0; index < 12; index += 1) {
        const angle = index / 12 * Math.PI * 2;
        const extent = index % 2 === 0 ? radius : radius * 0.68;
        points.push([Math.cos(angle) * extent, Math.sin(angle) * extent]);
      }
      tracePolygon(points);
    } else {
      context.beginPath();
      context.arc(0, 0, radius, 0, Math.PI * 2);
    }
  } else {
    context.beginPath();
    context.arc(0, 0, radius, 0, Math.PI * 2);
  }
}

function drawRaceFeature(race, radius, teamColor) {
  context.save();
  context.shadowBlur = 0;
  context.strokeStyle = "#fff1c7";
  context.fillStyle = teamColor;
  context.lineWidth = settings.highContrast ? 3 : 2;
  context.lineCap = "round";
  context.lineJoin = "round";
  context.beginPath();
  if (race.id === "human") {
    context.arc(radius * 0.18, 0, radius * 0.48, -0.85, 0.85);
  } else if (race.id === "orc") {
    context.moveTo(radius * 0.62, -radius * 0.48);
    context.lineTo(radius * 1.12, -radius * 0.25);
    context.lineTo(radius * 0.72, -radius * 0.12);
    context.moveTo(radius * 0.62, radius * 0.48);
    context.lineTo(radius * 1.12, radius * 0.25);
    context.lineTo(radius * 0.72, radius * 0.12);
  } else if (race.id === "troll") {
    context.moveTo(-radius * 0.25, -radius * 0.62);
    context.lineTo(-radius * 0.62, -radius * 1.1);
    context.lineTo(-radius * 0.82, -radius * 0.78);
    context.moveTo(-radius * 0.25, radius * 0.62);
    context.lineTo(-radius * 0.62, radius * 1.1);
    context.lineTo(-radius * 0.82, radius * 0.78);
  } else if (race.id === "elf" || race.id === "wood_elf" || race.id === "night_elf") {
    const reach = race.id === "wood_elf" ? 1.42 : 1.25;
    context.moveTo(0, -radius * 0.7);
    context.lineTo(-radius * 0.2, -radius * reach);
    context.lineTo(radius * 0.42, -radius * 0.72);
    context.moveTo(0, radius * 0.7);
    context.lineTo(-radius * 0.2, radius * reach);
    context.lineTo(radius * 0.42, radius * 0.72);
  } else if (race.id === "dwarf") {
    context.moveTo(radius * 0.22, -radius * 0.48);
    context.lineTo(radius * 0.82, 0);
    context.lineTo(radius * 0.22, radius * 0.48);
    context.moveTo(radius * 0.42, -radius * 0.26);
    context.lineTo(radius * 0.1, 0);
    context.lineTo(radius * 0.42, radius * 0.26);
  } else if (race.id === "gnome") {
    context.moveTo(-radius * 0.45, -radius * 0.45);
    context.lineTo(radius * 0.62, 0);
    context.lineTo(-radius * 0.45, radius * 0.45);
    context.closePath();
  } else if (race.id === "undead") {
    for (let row = -1; row <= 1; row += 1) {
      context.moveTo(-radius * 0.5, row * radius * 0.3);
      context.lineTo(radius * 0.38, row * radius * 0.3);
    }
  } else if (race.id === "sylph") {
    context.moveTo(-radius * 0.42, -radius * 0.5);
    context.quadraticCurveTo(-radius * 1.4, -radius, -radius * 1.05, -radius * 1.35);
    context.moveTo(-radius * 0.42, radius * 0.5);
    context.quadraticCurveTo(-radius * 1.4, radius, -radius * 1.05, radius * 1.35);
  } else if (race.id === "hobbit") {
    context.arc(-radius * 0.5, -radius * 0.45, radius * 0.2, 0, Math.PI * 2);
    context.moveTo(-radius * 0.3, radius * 0.5);
    context.arc(-radius * 0.5, radius * 0.45, radius * 0.2, 0, Math.PI * 2);
  } else if (race.id === "minotaur") {
    context.moveTo(radius * 0.15, -radius * 0.7);
    context.quadraticCurveTo(radius * 0.9, -radius * 1.25, radius * 1.25, -radius * 0.62);
    context.moveTo(radius * 0.15, radius * 0.7);
    context.quadraticCurveTo(radius * 0.9, radius * 1.25, radius * 1.25, radius * 0.62);
  } else if (race.id === "seakin" || race.id === "tideborn") {
    context.moveTo(radius * 0.1, -radius * 0.72);
    context.lineTo(-radius * 0.38, -radius * 1.18);
    context.lineTo(radius * 0.55, -radius * 0.82);
    context.moveTo(radius * 0.1, radius * 0.72);
    context.lineTo(-radius * 0.38, radius * 1.18);
    context.lineTo(radius * 0.55, radius * 0.82);
  } else if (race.id === "scaleheir") {
    context.moveTo(-radius * 0.15, -radius * 0.55);
    context.lineTo(-radius * 1.18, -radius * 1.05);
    context.lineTo(-radius * 0.72, -radius * 0.12);
    context.moveTo(-radius * 0.15, radius * 0.55);
    context.lineTo(-radius * 1.18, radius * 1.05);
    context.lineTo(-radius * 0.72, radius * 0.12);
  } else if (race.id === "stonewrought" || race.id === "stonekin") {
    context.rect(-radius * 0.42, -radius * 1.08, radius * 0.72, radius * 0.42);
    context.rect(-radius * 0.42, radius * 0.66, radius * 0.72, radius * 0.42);
  } else if (race.id === "rootwarden") {
    context.moveTo(-radius * 0.2, -radius * 0.45);
    context.lineTo(-radius * 1.2, -radius * 0.95);
    context.moveTo(-radius * 0.25, 0);
    context.lineTo(-radius * 1.35, 0);
    context.moveTo(-radius * 0.2, radius * 0.45);
    context.lineTo(-radius * 1.2, radius * 0.95);
  } else if (race.id === "goblin") {
    context.moveTo(radius * 0.1, -radius * 0.5);
    context.lineTo(-radius * 1.25, -radius * 0.85);
    context.lineTo(-radius * 0.65, -radius * 0.15);
    context.moveTo(radius * 0.1, radius * 0.5);
    context.lineTo(-radius * 1.25, radius * 0.85);
    context.lineTo(-radius * 0.65, radius * 0.15);
  } else if (race.id === "nymph") {
    for (let index = 0; index < 4; index += 1) {
      const angle = index * Math.PI / 2;
      context.moveTo(Math.cos(angle) * radius * 0.55, Math.sin(angle) * radius * 0.55);
      context.lineTo(Math.cos(angle) * radius * 1.25, Math.sin(angle) * radius * 1.25);
    }
  } else if (race.id === "ashling") {
    context.moveTo(-radius * 0.45, 0);
    context.lineTo(-radius * 0.85, -radius * 0.36);
    context.lineTo(-radius * 1.18, 0);
    context.lineTo(-radius * 0.85, radius * 0.36);
  } else if (race.id === "wyrmbound") {
    context.moveTo(-radius * 0.25, -radius * 0.55);
    context.lineTo(-radius * 1.18, -radius * 1.18);
    context.lineTo(-radius * 0.82, -radius * 0.22);
    context.moveTo(-radius * 0.25, radius * 0.55);
    context.lineTo(-radius * 1.18, radius * 1.18);
    context.lineTo(-radius * 0.82, radius * 0.22);
  }
  context.stroke();
  context.restore();
}

function tracePolygon(points) {
  context.beginPath();
  for (const [index, point] of points.entries()) {
    if (index === 0) context.moveTo(point[0], point[1]);
    else context.lineTo(point[0], point[1]);
  }
  context.closePath();
}

function drawEffects() {
  for (const ring of rings) {
    context.save();
    try {
      context.strokeStyle = ring.color;
      context.globalAlpha = clamp(ring.life / ring.maximumLife, 0, 1);
      context.lineWidth = 3;
      context.beginPath();
      context.arc(ring.x, ring.y, ring.radius, 0, Math.PI * 2);
      context.stroke();
    } finally {
      context.restore();
    }
  }
  for (const particle of particles) {
    context.save();
    try {
      context.globalAlpha = clamp(
        particle.life / particle.maximumLife,
        0,
        1,
      );
      context.fillStyle = particle.color;
      context.fillRect(particle.x - 2, particle.y - 2, 4, 4);
    } finally {
      context.restore();
    }
  }
}

function drawCrosshair(time) {
  const scale = settings.interfaceScale / 100;
  context.save();
  try {
    context.translate(pointer.x, pointer.y);
    context.strokeStyle = "#eaf5f1";
    context.lineWidth = 1.5;
    context.globalAlpha = 0.84;
    context.rotate(time * 0.25);
    const inner = 8 * scale;
    const outer = 14 * scale;
    context.beginPath();
    context.arc(0, 0, inner, 0, Math.PI * 2);
    for (let index = 0; index < 4; index += 1) {
      const angle = (index / 4) * Math.PI * 2;
      context.moveTo(Math.cos(angle) * (inner + 3), Math.sin(angle) * (inner + 3));
      context.lineTo(Math.cos(angle) * outer, Math.sin(angle) * outer);
    }
    context.stroke();
  } finally {
    context.restore();
  }
}

function buildContentInterface() {
  element("mode-options").innerHTML = MODES.map(
    (mode, index) => `
      <label class="choice-card">
        <input type="radio" name="mode" value="${mode.id}" ${index === 1 ? "checked" : ""}>
        <b>${mode.name}</b>
        <small>${mode.description}</small>
        <em>${mode.category}</em>
      </label>`,
  ).join("");
  renderMapOptions();
  element("agent-options").innerHTML = raceChampionMatrix("character", "mara");
  element("agent-two-options").innerHTML = raceChampionMatrix(
    "characterTwo",
    "bulwark",
  );
  element("agent-codex").innerHTML = CHARACTERS.map(agentCard).join("");
  element("map-codex").innerHTML = MAPS.map(
    (map) => `
      <article class="codex-card">
        <em>${map.region} · ${map.scale}</em>
        <b>${map.name}</b>
        <p><strong>${map.terrain}.</strong> ${map.identity} ${map.lore}</p>
        <small>${map.obstacles.length} hard-cover ruins · ${map.spawns.length} warded mustering stones · ${map.hazards.length ? `${map.hazards.length} active hazard` : "no authored hazard"}${map.shrines?.length ? ` · ${map.shrines.length} movement shrine` : ""}</small>
        <button class="text-button codex-action" type="button" data-select-map="${map.id}">Travel here →</button>
      </article>`,
  ).join("");
  element("mode-codex").innerHTML = MODES.map(
    (mode) => `
      <article class="codex-card">
        <em>${mode.category}</em>
        <b>${mode.name}</b>
        <p>${mode.description} Target: ${mode.scoreLimit}; time limit: ${Math.round(mode.timeLimit / 60)} minutes.</p>
        <button class="text-button codex-action" type="button" data-launch-mode="${mode.id}">Play now →</button>
      </article>`,
  ).join("");
  const agentOptions = CHARACTERS.map(
    (agent) => `<option value="${agent.id}">${agent.name} — ${agent.role}</option>`,
  ).join("");
  element("online-agent").innerHTML = agentOptions;
  element("online-race").innerHTML = RACES.map(
    (race) => `<option value="${race.id}">${race.name} — ${race.trait}</option>`,
  ).join("");
  syncOnlineRace();
  element("online-mode").innerHTML = MODES.filter(
    (mode) => mode.id !== "training",
  )
    .map((mode) => `<option value="${mode.id}">${mode.name}</option>`)
    .join("");
  element("online-map").innerHTML = MAPS.map(
    (map) => `<option value="${map.id}">${map.name}</option>`,
  ).join("");
  element("server-address").value = location.origin;
  syncLoadoutBuilder(true);
  updateDeploymentSummary();
}

function renderMapOptions() {
  const selected = selectedMatchChoice("map", "breakline");
  const maps = atlasScope === "fracture"
    ? MAPS.filter((map) => map.regionId === "fracture")
    : MAPS.filter((map) => map.regionId !== "fracture" || map.id === "breakline");
  const visibleSelected = maps.some((map) => map.id === selected) ? selected : maps[0].id;
  element("map-options").dataset.scope = atlasScope;
  element("map-options").innerHTML = maps.map(
    (map, index) => `
      <label class="choice-card atlas-node" style="--atlas-x:${atlasScope === "fracture" ? map.atlas.regionX : map.atlas.x}%;--atlas-y:${atlasScope === "fracture" ? map.atlas.regionY : map.atlas.y}%;--atlas-color:${map.visual.accent}" title="${map.region} · ${map.terrain} · ${map.identity} ${map.lore}">
        <input type="radio" name="map" value="${map.id}" ${map.id === visibleSelected || (!visibleSelected && index === 0) ? "checked" : ""}>
        <b>${map.name}</b>
        <small>${map.region} · ${map.scale} · ${map.terrain}</small>
        <em>${map.heraldry}</em>
      </label>`,
  ).join("");
  for (const button of document.querySelectorAll("[data-atlas-scope]")) {
    button.classList.toggle("active", button.dataset.atlasScope === atlasScope);
  }
  element("atlas-caption").textContent = atlasScope === "fracture"
    ? "The Fracture · duel, small, medium, and large battlegrounds"
    : "The known realm · choose a region or descend into The Fracture";
}

function raceChampionMatrix(name, selected) {
  return RACES.map((race) => {
    const champions = CHARACTERS
      .filter((agent) => agent.homeRaceId === race.id)
      .sort((left, right) => left.difficulty - right.difficulty || left.name.localeCompare(right.name));
    return `
      <section class="race-column" aria-label="${race.name} champions">
        <header title="${race.trait}: ${race.boon}; ${race.drawback}">
          <i aria-hidden="true">${race.featureGlyph}</i>
          <b>${race.name}</b>
          <span>${race.trait} · ${race.feature}</span>
          <small>${race.boon} / ${race.drawback}</small>
        </header>
        <div class="race-column-roster">
          ${champions.length ? champions.map((agent) => `
            <label class="agent-choice" data-element="${agent.affinity.id}" style="--agent-color:${agent.accent}" title="${agent.role} · ${agent.affinity.name}: ${agent.style}">
              <input type="radio" name="${name}" value="${agent.id}" ${agent.id === selected ? "checked" : ""}>
              <span class="agent-choice-glyph" aria-hidden="true">${agent.glyph}</span>
              <b>${agent.name}</b>
              <small>${agent.affinity.name} · ${"◆".repeat(agent.difficulty)}</small>
            </label>`).join("") : `<p class="empty-roster">No sworn champion yet</p>`}
        </div>
      </section>`;
  }).join("");
}

function syncOnlineRace() {
  const champion = getCharacter(element("online-agent").value || "kite");
  for (const option of element("online-race").querySelectorAll("option")) {
    if (option.value === champion.homeRaceId) option.setAttribute("selected", "");
    else option.removeAttribute("selected");
  }
}

function agentCard(agent) {
  return `
    <article class="agent-card" style="--agent-color:${agent.accent};--agent-wash:${agent.accent}22">
      <div class="agent-identity"><i class="agent-glyph" aria-hidden="true">${agent.glyph}</i><b>${agent.name}</b><span>${getRace(agent.homeRaceId).name} · ${agent.role} · ${"◆".repeat(agent.difficulty)}</span></div>
      <div class="agent-data">
        <p>${agent.style}</p>
        <p><strong>${agent.affinity.name} ELEMENT</strong> · ${agent.affinity.edge}</p>
        <div class="kit-list">
          ${[
            agent.passive,
            agent.primary,
            agent.tactical,
            agent.defense,
            agent.mobility,
            agent.ultimate,
          ]
            .filter(Boolean)
            .map(
              (ability) =>
                `<div><b>${ability.name}</b><span>${ability.detail}</span></div>`,
            )
            .join("")}
        </div>
        <button class="text-button codex-action" type="button" data-select-agent="${agent.id}">Select champion →</button>
      </div>
    </article>`;
}

async function hostLobby() {
  setNetworkMessage("Connecting to authoritative server…");
  try {
    await connectNetwork(readServerBase());
    const result = await sendRequest("host", {
      options: {
        name: element("lobby-name").value,
        playerName: element("online-name").value,
        modeId: element("online-mode").value,
        mapId: element("online-map").value,
        characterId: element("online-agent").value,
        raceId: element("online-race").value,
        public: element("lobby-public").checked,
        hazardsEnabled: element("lobby-hazards").checked,
        maxPlayers: element("online-mode").value === "battle_royale" ? 12
          : element("online-mode").value === "freeplay" ? 8 : 6,
        teamSize: element("online-mode").value === "battle_royale" ? 1 : undefined,
        botCount: element("online-mode").value === "freeplay" ? 0 : 1,
        ...selectedLoadoutSpec(),
        freeplaySettings: element("online-mode").value === "freeplay"
          ? matchState?.rules?.freeplaySettings
          : undefined,
      },
    });
    if (!result.ok) throw new Error(result.message);
    beginRemote(result);
    const serverBase = readServerBase();
    element("share-link").value = createLobbyInvite(serverBase, result.lobby.code, {
      desktop: launchParameters.get("desktop") === "1",
    });
    element("share-link-row").hidden = false;
    await copyShareLink();
    toast(`LOBBY ${result.lobby.code} · LINK READY`);
  } catch (error) {
    setNetworkMessage(error.message, "error");
  }
}

async function copyShareLink() {
  const value = element("share-link").value;
  if (!value) return;
  try {
    await navigator.clipboard?.writeText(value);
    setNetworkMessage(`Share link ready: ${value}`);
  } catch {
    setNetworkMessage(`Copy this link: ${value}`);
  }
}

async function joinLobby(code) {
  const normalizedCode = String(code ?? "").trim().toUpperCase();
  if (!normalizedCode) {
    setNetworkMessage("Enter or select a lobby code.", "error");
    return;
  }
  setNetworkMessage(`Joining ${normalizedCode}…`);
  try {
    await connectNetwork(readServerBase());
    const result = await sendRequest("join", {
      code: normalizedCode,
      options: {
        name: element("online-name").value,
        characterId: element("online-agent").value,
        raceId: element("online-race").value,
        ...selectedLoadoutSpec(),
      },
    });
    if (!result.ok) throw new Error(result.message);
    beginRemote(result);
  } catch (error) {
    setNetworkMessage(error.message, "error");
  }
}

async function spectateLobby(code) {
  const normalizedCode = String(code ?? "").trim().toUpperCase();
  if (!normalizedCode) return;
  setNetworkMessage(`Opening observer feed for ${normalizedCode}…`);
  try {
    const base = readServerBase();
    await connectNetwork(base);
    const result = await sendRequest("spectate", {
      code: normalizedCode,
      options: { name: element("online-name").value },
    });
    if (!result.ok) throw new Error(result.message);
    beginRemote(result);
    toast(`WATCHING ${result.lobby.code} · read-only observer`);
  } catch (error) {
    setNetworkMessage(error.message, "error");
  }
}

async function reconnectLastSession() {
  const session = readReconnectSession();
  if (!session) {
    refreshReconnectButton();
    setNetworkMessage("No recoverable remote session.", "error");
    return;
  }
  setNetworkMessage(`Reconnecting to ${session.code}…`);
  try {
    element("server-address").value = session.base;
    await connectNetwork(session.base);
    const result = await sendRequest("reconnect", { token: session.token });
    if (!result.ok) throw new Error(result.message);
    beginRemote(result);
    toast(
      result.role === "spectator"
        ? "Observer feed restored."
        : "Authoritative player session restored.",
    );
  } catch (error) {
    if (/expired|not found|invalid/i.test(error.message)) clearReconnectSession();
    setNetworkMessage(error.message, "error");
  }
}

function beginRemote(result) {
  matchKind = "remote";
  lastLocalOptions = null;
  remoteEntityId = result.entityId;
  remoteRole = result.role ?? (result.entityId ? "player" : "spectator");
  remoteLobby = result.lobby;
  remoteHostId = result.lobby.hostId;
  remoteSequence = 0;
  pendingInputs = [];
  configurePacketConditioner(networkConditioner, networkLabConfig());
  lastAuthoritativeTick = Number.isInteger(result.snapshot.serverTick)
    ? result.snapshot.serverTick
    : -1;
  matchState = structuredClone(result.snapshot.state);
  app.dataset.spectating = String(remoteRole === "spectator");
  lastSnapshotAt = performance.now();
  lastProcessedTick = matchState.tick - 1;
  setNetworkMessage(
    `${remoteRole === "spectator" ? "Watching" : "Connected to"} ${result.lobby.name} · code ${result.lobby.code}`,
    "success",
  );
  if (result.reconnectToken) {
    writeReconnectSession({
      base: socketBase,
      code: result.lobby.code,
      token: result.reconnectToken,
      role: remoteRole,
    });
  }
  clearEffects();
  enterGame();
}

async function refreshLobbies() {
  const list = element("lobby-list");
  list.innerHTML = '<p class="empty-state">Scanning server…</p>';
  try {
    const response = await fetch(`${readServerBase()}/api/lobbies`, {
      cache: "no-store",
      signal: AbortSignal.timeout(4_000),
    });
    if (!response.ok) throw new Error(`Server returned ${response.status}.`);
    const body = await response.json();
    renderLobbyList(Array.isArray(body.lobbies) ? body.lobbies : []);
    setServerStatus("ready", "LOBBY SERVICE READY");
  } catch (error) {
    renderLobbyList([]);
    setNetworkMessage(
      `Lobby service unavailable: ${error.message}. Local play still works.`,
      "error",
    );
    setServerStatus("offline", "LOBBY SERVICE OFFLINE");
  }
}

function renderLobbyList(lobbies) {
  const list = element("lobby-list");
  list.replaceChildren();
  if (lobbies.length === 0) {
    const empty = document.createElement("p");
    empty.className = "empty-state";
    empty.textContent = "No public lobbies on this server. Host the first.";
    list.append(empty);
    return;
  }
  for (const lobby of lobbies) {
    const entry = document.createElement("article");
    entry.className = "lobby-entry";
    const copy = document.createElement("div");
    const name = document.createElement("b");
    name.textContent = lobby.name;
    const detail = document.createElement("span");
    detail.textContent = `${lobby.modeName} · ${lobby.mapName} · ${lobby.players}/${lobby.maxPlayers} · ${lobby.status}`;
    copy.append(name, detail);
    const actions = document.createElement("div");
    actions.className = "lobby-actions";
    const join = document.createElement("button");
    join.className = "button";
    join.type = "button";
    join.textContent = `Join ${lobby.code}`;
    join.disabled = lobby.players >= lobby.maxPlayers;
    join.addEventListener("click", () => joinLobby(lobby.code));
    const watch = document.createElement("button");
    watch.className = "button button-quiet";
    watch.type = "button";
    watch.textContent = "Watch";
    watch.addEventListener("click", () => spectateLobby(lobby.code));
    actions.append(join, watch);
    entry.append(copy, actions);
    list.append(entry);
  }
}

function readServerBase() {
  let value = element("server-address").value.trim() || location.origin;
  if (!/^https?:\/\//i.test(value)) value = `http://${value}`;
  const url = new URL(value);
  return `${url.protocol}//${url.host}`;
}

async function connectNetwork(base) {
  if (
    socket &&
    socketBase === base &&
    socket.readyState === WebSocket.OPEN &&
    clientId
  ) {
    return;
  }
  leaveRemote(false);
  socketBase = base;
  remoteServerShutdown = false;
  const webSocketUrl = new URL(base);
  webSocketUrl.protocol = webSocketUrl.protocol === "https:" ? "wss:" : "ws:";
  webSocketUrl.pathname = "/ws";
  setServerStatus("connecting", "CONNECTING");
  await new Promise((resolve, reject) => {
    const connection = new WebSocket(webSocketUrl);
    socket = connection;
    const timeout = window.setTimeout(() => {
      connection.close();
      reject(new Error("Connection timed out."));
    }, 5_000);
    socketHelloResolver = () => {
      window.clearTimeout(timeout);
      socketHelloResolver = null;
      setServerStatus("ready", "AUTHORITATIVE SERVER CONNECTED");
      resolve();
    };
    connection.addEventListener("message", handleSocketMessage);
    connection.addEventListener("error", () => {
      window.clearTimeout(timeout);
      reject(new Error("Could not reach the lobby server."));
    });
    connection.addEventListener("close", () => {
      if (socket !== connection) return;
      const wasRemote = matchKind === "remote";
      socket = null;
      clientId = null;
      setServerStatus(
        "offline",
        remoteServerShutdown
          ? "AUTHORITATIVE HOST CLOSED"
          : "NETWORK DISCONNECTED",
      );
      for (const pending of requestResolvers.values()) {
        pending.reject(new Error("Connection closed."));
      }
      requestResolvers.clear();
      if (wasRemote) {
        paused = true;
        pauseOverlay.classList.remove("hidden");
        element("pause-title").textContent = remoteServerShutdown
          ? "Host realm closed"
          : "Connection lost";
        element("pause-copy").textContent = remoteServerShutdown
          ? "The authoritative host shut down, so this match has ended. Return to Host / Join to begin another."
          : "Your slot is reserved for 30 seconds. Open Host / Join and reconnect the last session.";
      }
    });
  });
}

function handleSocketMessage(event) {
  let message;
  try {
    message = JSON.parse(event.data);
  } catch {
    return;
  }
  if (
    message.type === "snapshot" && matchKind === "remote" &&
    networkLabActive(networkLabConfig())
  ) {
    const now = performance.now();
    conditionPacket(networkConditioner, "incoming", message, now);
    flushConditionedNetwork(now);
    return;
  }
  deliverSocketMessage(message);
}

function deliverSocketMessage(message) {
  if (message.type === "hello") {
    clientId = message.clientId;
    networkDiagnostics = createNetworkDiagnostics();
    sendNetworkProbe(performance.now());
    socketHelloResolver?.();
    return;
  }
  if (message.type === "probe") {
    receiveNetworkProbe(networkDiagnostics, message.sequence, performance.now());
    return;
  }
  if (message.type === "result") {
    const resolver = requestResolvers.get(message.requestId);
    if (resolver) {
      requestResolvers.delete(message.requestId);
      resolver.resolve(message);
    }
    return;
  }
  if (message.type === "snapshot" && matchKind === "remote") {
    acceptRemoteSnapshot(message);
    return;
  }
  if (message.type === "server-shutdown") {
    remoteServerShutdown = true;
    clearReconnectSession();
    setServerStatus("offline", "AUTHORITATIVE HOST CLOSED");
    setNetworkMessage(
      message.message ?? "The authoritative host shut down. This match has ended.",
      "error",
    );
    if (matchKind === "remote") {
      paused = true;
      pauseOverlay.classList.remove("hidden");
      element("pause-title").textContent = "Host realm closed";
      element("pause-copy").textContent =
        "The authoritative host shut down, so this match has ended. Return to Host / Join to begin another.";
    }
    toast("AUTHORITATIVE HOST CLOSED · MATCH ENDED", "error");
    return;
  }
  if (message.type === "presence") {
    toast(`${message.name} ${message.action} · ${message.players} connected`);
  } else if (message.type === "host-migrated") {
    remoteHostId = message.hostId;
    toast(
      message.hostId === clientId
        ? "You are now the lobby host."
        : "Lobby host migrated cleanly.",
    );
  } else if (message.type === "lobby-closed") {
    toast(message.reason ?? "Lobby closed.", "error");
    leaveToMenu("online");
  } else if (message.type === "error") {
    toast(message.message, "error");
  }
}

function acceptRemoteSnapshot(message) {
  if (!isFreshServerTick(lastAuthoritativeTick, message.serverTick)) return;
  lastAuthoritativeTick = message.serverTick;
  const authoritative = structuredClone(message.state);
  remoteLobby = message.lobby;
  remoteHostId = message.lobby.hostId;
  remoteEntityId = message.entityId;
  pendingInputs = pendingInputs.filter(
    (pending) => pending.sequence > message.acknowledgedSequence,
  );
  for (const pending of pendingInputs) {
    stepMatch(
      authoritative,
      { [remoteEntityId]: pending.command },
      FIXED_DELTA,
    );
  }
  matchState = authoritative;
  lastSnapshotAt = performance.now();
  processEvents(message.state.events ?? [], message.serverTick);
}

function sendRequest(type, payload = {}) {
  if (!socket || socket.readyState !== WebSocket.OPEN) {
    return Promise.reject(new Error("Network connection is not ready."));
  }
  const requestId = `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;
  return new Promise((resolve, reject) => {
    const timeout = window.setTimeout(() => {
      requestResolvers.delete(requestId);
      reject(new Error(`${type} request timed out.`));
    }, 5_000);
    requestResolvers.set(requestId, {
      resolve: (message) => {
        window.clearTimeout(timeout);
        resolve(message);
      },
      reject: (error) => {
        window.clearTimeout(timeout);
        reject(error);
      },
    });
    socket.send(JSON.stringify({ type, requestId, ...payload }));
  });
}

function updateNetworkProbes(now) {
  expireNetworkProbes(networkDiagnostics, now);
  if (
    socket?.readyState === WebSocket.OPEN &&
    now - networkDiagnostics.lastProbeAt >= NETWORK_PROBE_INTERVAL_MS
  ) {
    sendNetworkProbe(now);
  }
}

function sendNetworkProbe(now) {
  if (!socket || socket.readyState !== WebSocket.OPEN) return;
  const sequence = beginNetworkProbe(networkDiagnostics, now);
  socket.send(JSON.stringify({ type: "probe", sequence }));
}

function leaveRemote(forgetSession = true) {
  if (socket && socket.readyState === WebSocket.OPEN && matchKind === "remote") {
    socket.send(JSON.stringify({ type: "leave" }));
  }
  if (socket) {
    socket.removeEventListener("message", handleSocketMessage);
    socket.close();
  }
  socket = null;
  socketBase = null;
  clientId = null;
  remoteEntityId = null;
  remoteLobby = null;
  remoteHostId = null;
  remoteRole = "player";
  remoteServerShutdown = false;
  pendingInputs = [];
  configurePacketConditioner(networkConditioner, networkLabConfig());
  lastAuthoritativeTick = -1;
  networkDiagnostics = createNetworkDiagnostics();
  app.dataset.spectating = "false";
  if (forgetSession) clearReconnectSession();
  else refreshReconnectButton();
}

function writeReconnectSession(session) {
  try {
    localStorage.setItem(RECONNECT_KEY, JSON.stringify(session));
  } catch {
    // Remote play remains available when storage is blocked.
  }
  refreshReconnectButton();
}

function readReconnectSession() {
  try {
    const parsed = JSON.parse(
      localStorage.getItem(RECONNECT_KEY) ??
      localStorage.getItem(LEGACY_RECONNECT_KEY) ??
      "null",
    );
    if (
      parsed &&
      typeof parsed.base === "string" &&
      typeof parsed.code === "string" &&
      typeof parsed.token === "string"
    ) {
      return parsed;
    }
  } catch {
    // Invalid or unavailable storage means there is no resumable session.
  }
  return null;
}

function clearReconnectSession() {
  try {
    localStorage.removeItem(RECONNECT_KEY);
    localStorage.removeItem(LEGACY_RECONNECT_KEY);
  } catch {
    // Nothing else is required when storage is blocked.
  }
  refreshReconnectButton();
}

function refreshReconnectButton() {
  const button = element("reconnect-lobby");
  if (!button) return;
  const session = readReconnectSession();
  button.hidden = !session;
  if (session) {
    button.textContent = `Reconnect ${session.code}${session.role === "spectator" ? " as observer" : ""}`;
  }
}

function setNetworkMessage(message, type = "") {
  const output = element("network-message");
  output.textContent = message;
  output.className = `network-message ${type}`;
}

function setServerStatus(status, copy) {
  const display = element("server-status");
  display.className = `server-status ${status === "ready" ? "" : status}`;
  display.querySelector("span").textContent = copy;
}

function updateSettings() {
  const data = new FormData(settingsForm);
  settings = normalizeSettings({
    screenShake: Number(data.get("screenShake")),
    interfaceScale: Number(data.get("interfaceScale")),
    sound: Number(data.get("sound")),
    coaching: data.get("coaching") === "on",
    reducedMotion: data.get("reducedMotion") === "on",
    highContrast: data.get("highContrast") === "on",
    hudDetailed: settings.hudDetailed,
    bindings: settings.bindings,
    networkLatency: Number(data.get("networkLatency")),
    networkJitter: Number(data.get("networkJitter")),
    networkLoss: Number(data.get("networkLoss")),
  });
  for (const input of settingsForm.querySelectorAll('input[type="range"]')) {
    input.parentElement.querySelector("output").value = input.value;
  }
  localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
  applySettings();
}

function resetSettings() {
  bindingCapture = null;
  settings = { ...DEFAULT_SETTINGS, bindings: { ...DEFAULT_BINDINGS } };
  localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
  syncSettingsForm();
  applySettings();
  element("binding-status").textContent = "Default controls restored.";
  element("binding-status").dataset.tone = "success";
  toast("Presentation and controls restored.");
}

function syncSettingsForm() {
  for (const [key, value] of Object.entries(settings)) {
    const input = settingsForm.elements.namedItem(key);
    if (!input) continue;
    if (input.type === "checkbox") input.checked = value;
    else {
      input.value = value;
      input.parentElement.querySelector("output").value = value;
    }
  }
}

function applySettings() {
  document.documentElement.style.setProperty(
    "--scale",
    String(settings.interfaceScale / 100),
  );
  app.classList.toggle("high-contrast", settings.highContrast);
  app.classList.toggle("reduced-motion", settings.reducedMotion);
  app.classList.toggle("hud-detailed", settings.hudDetailed);
  hudDetailToggle.textContent = settings.hudDetailed ? "Compact HUD" : "Show details";
  hudDetailToggle.setAttribute("aria-pressed", String(settings.hudDetailed));
  syncBindingLabels();
  syncBindingButtons();
  const lab = networkLabConfig();
  if (
    networkConditioner.config.latency !== lab.latency ||
    networkConditioner.config.jitter !== lab.jitter ||
    networkConditioner.config.loss !== lab.loss
  ) {
    configurePacketConditioner(networkConditioner, lab);
  }
}

function loadSettings() {
  try {
    return normalizeSettings(JSON.parse(
      localStorage.getItem(SETTINGS_KEY) ??
      localStorage.getItem(LEGACY_SETTINGS_KEY),
    ));
  } catch {
    return { ...DEFAULT_SETTINGS, bindings: { ...DEFAULT_BINDINGS } };
  }
}

function normalizeSettings(candidate) {
  const source = candidate && typeof candidate === "object" ? candidate : {};
  return {
    screenShake: boundedNumber(source.screenShake, 0, 100, 55),
    interfaceScale: boundedNumber(source.interfaceScale, 80, 130, 100),
    sound: boundedNumber(source.sound, 0, 100, 45),
    coaching:
      typeof source.coaching === "boolean" ? source.coaching : true,
    reducedMotion:
      typeof source.reducedMotion === "boolean"
        ? source.reducedMotion
        : false,
    highContrast:
      typeof source.highContrast === "boolean" ? source.highContrast : false,
    hudDetailed:
      typeof source.hudDetailed === "boolean" ? source.hudDetailed : false,
    bindings: normalizeBindings(source.bindings),
    networkLatency: boundedNumber(source.networkLatency, 0, 250, 0),
    networkJitter: boundedNumber(source.networkJitter, 0, 100, 0),
    networkLoss: boundedNumber(source.networkLoss, 0, 20, 0),
  };
}

function normalizeBindings(candidate) {
  const source = candidate && typeof candidate === "object" ? candidate : {};
  const bindings = {};
  for (const action of BINDING_ACTIONS) {
    const raw = Array.isArray(source[action])
      ? source[action]
      : typeof source[action] === "string"
        ? [source[action]]
        : DEFAULT_BINDINGS[action];
    const tokens = [...new Set(raw
      .map(normalizeInputKey)
      .filter((key) => isBindableKey(key) && !PROTECTED_BINDING_KEYS.has(key)))]
      .slice(0, 4);
    bindings[action] = tokens.length ? tokens : [...DEFAULT_BINDINGS[action]];
  }
  return bindings;
}

function normalizeInputKey(value) {
  return typeof value === "string" ? value.toLowerCase() : "";
}

function isBindableKey(key) {
  return key.length === 1 ||
    ["shift", "alt", "control"].includes(key) ||
    /^mouse[1-5]$/.test(key) ||
    ["wheelup", "wheeldown"].includes(key);
}

function keyLabel(key) {
  if (Array.isArray(key)) return key.map(keyLabel).join(" / ");
  const named = {
    " ": "SPACE",
    shift: "SHIFT",
    alt: "ALT",
    control: "CTRL",
    mouse1: "MB1",
    mouse2: "MB2",
    mouse3: "MB3",
    mouse4: "MB4",
    mouse5: "MB5",
    wheelup: "WHEEL↑",
    wheeldown: "WHEEL↓",
  };
  return named[key] ?? String(key).toUpperCase();
}

function syncBindingButtons() {
  for (const button of settingsForm.querySelectorAll("[data-bind-action]")) {
    const action = button.dataset.bindAction;
    const capturing = bindingCapture === action;
    button.textContent = capturing ? "PRESS KEY" : keyLabel(settings.bindings[action]);
    button.classList.toggle("capturing", capturing);
    button.setAttribute("aria-pressed", String(capturing));
  }
}

function syncBindingLabels() {
  for (const label of document.querySelectorAll("[data-binding-label]")) {
    label.textContent = keyLabel(settings.bindings[label.dataset.bindingLabel]);
  }
  const summaries = {
    move: ["moveUp", "moveLeft", "moveDown", "moveRight"]
      .map((action) => keyLabel(settings.bindings[action]))
      .join("/"),
    flow: `${keyLabel(settings.bindings.sprint)}/${keyLabel(settings.bindings.hop)}`,
    primary: `MB1/${keyLabel(settings.bindings.fire)}`,
    coachFlow: `${keyLabel(settings.bindings.sprint)} + ${keyLabel(settings.bindings.hop)} / slide`,
    coachFire: `Move + ${keyLabel(settings.bindings.fire)}`,
    coachDefense: `${keyLabel(settings.bindings.mobility)} + ${keyLabel(settings.bindings.defense)}`,
    coachTactical: `Commit ${keyLabel(settings.bindings.tactical)}`,
  };
  for (const label of document.querySelectorAll("[data-binding-summary]")) {
    label.textContent = summaries[label.dataset.bindingSummary] ?? label.textContent;
  }
}

function ensureAudio() {
  if (!audioContext) {
    const AudioContext = window.AudioContext ?? window.webkitAudioContext;
    if (AudioContext) audioContext = new AudioContext();
  }
  if (audioContext?.state === "suspended") audioContext.resume();
}

function tone(frequency, duration, waveform, volume) {
  if (!audioContext || settings.sound === 0) return;
  const oscillator = audioContext.createOscillator();
  const gain = audioContext.createGain();
  oscillator.type = waveform;
  oscillator.frequency.value = frequency;
  gain.gain.setValueAtTime(
    volume * (settings.sound / 100),
    audioContext.currentTime,
  );
  gain.gain.exponentialRampToValueAtTime(
    0.0001,
    audioContext.currentTime + duration,
  );
  oscillator.connect(gain).connect(audioContext.destination);
  oscillator.start();
  oscillator.stop(audioContext.currentTime + duration);
}

function toast(message, type = "") {
  const item = document.createElement("div");
  item.className = `toast ${type}`;
  item.textContent = message;
  toastStack.append(item);
  window.setTimeout(() => item.remove(), 3_200);
}

function formatScore(score, mode) {
  return mode.id === "control" || mode.id === "convergence"
    ? String(Math.floor(score)).padStart(2, "0")
    : String(Math.floor(score));
}

function formatClock(seconds) {
  const total = Math.max(0, Math.ceil(seconds));
  return `${String(Math.floor(total / 60)).padStart(2, "0")}:${String(total % 60).padStart(2, "0")}`;
}

function normalize(x, y, fallback = { x: 0, y: 0 }) {
  const safeX = Number.isFinite(x) ? x : 0;
  const safeY = Number.isFinite(y) ? y : 0;
  const magnitude = Math.hypot(safeX, safeY);
  return magnitude > 1e-8
    ? { x: safeX / magnitude, y: safeY / magnitude }
    : fallback;
}

function boundedNumber(value, minimum, maximum, fallback) {
  return Number.isFinite(value)
    ? clamp(value, minimum, maximum)
    : fallback;
}

function clamp(value, minimum, maximum) {
  return Math.max(minimum, Math.min(maximum, value));
}

function element(id) {
  const found = document.getElementById(id);
  if (!found) throw new Error(`Missing required interface element #${id}`);
  return found;
}

window.FLUX_DEBUG = Object.freeze({
  getState: () => structuredClone(matchState),
  getInvariantErrors: () => matchInvariantErrors(matchState),
  getInterfaceState: () => ({
    infoOpen,
    menuPanel,
    matchKind,
    view: app.dataset.view,
    sanctum: isSanctum(),
  }),
  launchMode,
  activateMenuGamepadAction,
  quickStart,
  showPanel,
  openSanctumMenu,
  runFreeplayAction,
  toggleInfo,
});
window.DIFF_DEBUG = window.FLUX_DEBUG;
