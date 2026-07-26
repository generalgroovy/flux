import {
  CHARACTERS,
  MAPS,
  MATCH_TUNING,
  MODES,
  RACES,
  getCharacter,
  getMap,
  getMode,
  getRace,
} from "./content.mjs";
import {
  createMatch,
  matchInvariantErrors,
  sanitizeCommand,
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
} from "./network-quality.mjs";

const FIXED_DELTA = 1 / MATCH_TUNING.tickRate;
const SETTINGS_KEY = "diff.presentation.v2";
const RECONNECT_KEY = "diff.remote.session.v1";
const DEFAULT_SETTINGS = Object.freeze({
  screenShake: 55,
  interfaceScale: 100,
  sound: 45,
  coaching: true,
  reducedMotion: false,
  highContrast: false,
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
const settingsForm = element("settings-form");
const matchForm = element("match-form");
const pointer = { x: 0, y: 0, active: false };
const keys = new Set();
const mouseButtons = new Set();
const requestResolvers = new Map();
const particles = [];
const rings = [];
const trails = new Map();

let settings = loadSettings();
let menuPanel = "home";
let matchState = createMatch({
  modeId: "training",
  mapId: "breakline",
  botCount: 0,
});
let matchKind = "none";
let lastLocalOptions = null;
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
let remoteHostId = null;
let clientId = null;
let remoteRole = "player";
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
updateInterface();
const linkedLobbyCode = new URLSearchParams(location.search ?? "").get("join");
if (linkedLobbyCode) {
  showPanel("online");
  element("join-code").value = linkedLobbyCode.toUpperCase();
  window.setTimeout(() => joinLobby(linkedLobbyCode), 0);
}

window.addEventListener("resize", resize);
window.addEventListener("blur", () => {
  keys.clear();
  mouseButtons.clear();
});
window.addEventListener("keydown", handleKeyDown);
window.addEventListener("keyup", (event) => keys.delete(event.key.toLowerCase()));
canvas.addEventListener("contextmenu", (event) => event.preventDefault());
canvas.addEventListener("pointermove", (event) => {
  pointer.x = event.clientX;
  pointer.y = event.clientY;
  pointer.active = true;
});
canvas.addEventListener("pointerdown", (event) => {
  ensureAudio();
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
pauseOverlay.addEventListener("click", handleOverlayClick);
matchOverlay.addEventListener("click", handleOverlayClick);
menuClose.addEventListener("click", resumeGame);
matchForm.addEventListener("submit", startConfiguredMatch);
matchForm.addEventListener("change", handleMatchFormChange);
element("bot-count").addEventListener("input", () => {
  element("bot-count-output").value = element("bot-count").value;
});
settingsForm.addEventListener("input", updateSettings);
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
element("info-close").addEventListener("click", () => toggleInfo(false));

requestAnimationFrame(frame);
let lastFrameErrorAt = Number.NEGATIVE_INFINITY;

function frame(now) {
  requestAnimationFrame(frame);
  try {
    runFrame(now);
  } catch (error) {
    console.error("DIFF frame recovered", error);
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
  updateEffects(delta);
  render(now / 1000);
  interfaceAccumulator += delta;
  if (interfaceAccumulator >= 1 / 20) {
    updateInterface();
    interfaceAccumulator %= 1 / 20;
  }
}

function handleKeyDown(event) {
  const key = event.key.toLowerCase();
  if (key === "f1") {
    event.preventDefault();
    if (app.dataset.view === "game") toggleInfo();
    else showPanel("guide");
    return;
  }
  if (
    app.dataset.view === "game" &&
    [
      " ",
      "arrowup",
      "arrowdown",
      "arrowleft",
      "arrowright",
      "tab",
      "alt",
    ].includes(key)
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
    key === "enter" &&
    app.dataset.view === "menu" &&
    menuPanel === "home" &&
    event.target === document.body
  ) {
    quickStart();
    return;
  }
  keys.add(key);
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
  const movement = directionFromKeys("a", "d", "w", "s");
  let aim = { x: entity.facingX, y: entity.facingY };
  if (pointer.active) {
    const world = screenToWorld(pointer.x, pointer.y);
    aim = normalize(world.x - entity.x, world.y - entity.y, aim);
  }
  return sanitizeCommand({
    ...movement,
    aimX: aim.x,
    aimY: aim.y,
    fire: mouseButtons.has(0) || keys.has(" "),
    special: mouseButtons.has(2) || keys.has("e"),
    defend: keys.has("q"),
    mobility: keys.has("shift"),
    sprint: keys.has("alt"),
    hop: keys.has("c"),
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
  });
}

function directionFromKeys(left, right, up, down) {
  const direction = normalize(
    Number(keys.has(right)) - Number(keys.has(left)),
    Number(keys.has(down)) - Number(keys.has(up)),
  );
  return { moveX: direction.x, moveY: direction.y };
}

function predictRemoteTick() {
  if (!socket || socket.readyState !== WebSocket.OPEN || !remoteEntityId) return;
  const command = readRemoteCommand();
  remoteSequence += 1;
  pendingInputs.push({ sequence: remoteSequence, command });
  if (pendingInputs.length > MATCH_TUNING.tickRate * 2) {
    pendingInputs.splice(0, pendingInputs.length - MATCH_TUNING.tickRate * 2);
  }
  socket.send(
    JSON.stringify({
      type: "input",
      sequence: remoteSequence,
      command,
    }),
  );
  stepMatch(matchState, { [remoteEntityId]: command }, FIXED_DELTA);
}

function handleMenuClick(event) {
  const launchButton = event.target.closest("[data-launch-mode]");
  if (launchButton) {
    launchMode(launchButton.dataset.launchMode);
    return;
  }
  const agentButton = event.target.closest("[data-select-agent]");
  if (agentButton) {
    selectMatchChoice("character", agentButton.dataset.selectAgent);
    showPanel("play");
    toast(`${getCharacter(agentButton.dataset.selectAgent).name} selected.`);
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
  const panelButton = event.target.closest("[data-panel]");
  if (panelButton) {
    event.preventDefault();
    showPanel(panelButton.dataset.panel);
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
}

function quickStart() {
  startLocal({
    modeId: "training",
    mapId: "breakline",
    botCount: 1,
    players: [
      {
        id: "p1",
        name: "PLAYER 1",
        characterId: "kite",
        raceId: "human",
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
  const characterId = selectedMatchChoice("character", "kite");
  const raceId = selectedMatchChoice("race", "human");
  selectMatchChoice("mode", mode.id);
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
  const characterId = String(data.get("character") ?? "kite");
  const raceId = String(data.get("race") ?? "human");
  if (format === "local" && !getMode(modeId).allowLocal) {
    modeId = "duel";
    toast("FIRST CONTACT is solo; switched to DIFFERENCE for local 2P.");
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
    },
  ];
  if (format === "local") {
    players.push({
      id: "p2",
      name: "PLAYER 2",
      characterId: String(data.get("characterTwo") ?? "bulwark"),
      raceId: String(data.get("raceTwo") ?? "orc"),
      team: modeId === "survival" ? "alpha" : "beta",
      human: true,
      localSlot: 1,
    });
  }
  startLocal({
    modeId,
    mapId,
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
  leaveRemote(!preserveReconnect);
  matchKind = "none";
  paused = false;
  app.dataset.view = "menu";
  toggleInfo(false);
  pauseOverlay.classList.add("hidden");
  matchOverlay.classList.add("hidden");
  menuClose.hidden = true;
  keys.clear();
  mouseButtons.clear();
  showPanel(panel);
}

function handleMatchFormChange(event) {
  if (event.target.name === "format") {
    const local = event.target.value === "local";
    element("player-two-field").hidden = !local;
    element("bot-field").hidden = local;
    if (local && !getMode(selectedMatchChoice("mode", "duel")).allowLocal) {
      selectMatchChoice("mode", "duel");
      toast("FIRST CONTACT is solo; DIFFERENCE selected for local 2P.");
    }
  }
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
  const agent = getCharacter(selectedMatchChoice("character", "kite"));
  const race = getRace(selectedMatchChoice("race", "human"));
  const map = getMap(selectedMatchChoice("map", "breakline"));
  element("deployment-summary").textContent =
    `${mode.name} · ${race.name} ${agent.name} · ${map.name}`;
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
    player.hopCooldown > 0
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
        : mode.description;
  element("info-status").textContent =
    `Round ${matchState.round} · ${map.name} · ${Math.ceil(player.health)}/${player.maxHealth} HP`;
  element("info-agent-glyph").textContent = agent.glyph;
  element("info-agent-glyph").style.color = agent.accent;
  element("info-agent-name").textContent = agent.name;
  element("info-agent-role").textContent =
    `${race.name} · ${agent.role} · ${agent.affinity.name} ELEMENT`;
  element("info-kit").innerHTML = [
    ["MB1", agent.primary],
    ["E", agent.special],
    ["Q", agent.defense],
    ["⇧", agent.mobility],
  ]
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
    element("result-title").textContent = `${winner} MADE THE DIFFERENCE`;
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
  const stale = performance.now() - lastSnapshotAt > 500;
  const metrics =
    summary.rtt === null
      ? "MEASURING"
      : `${Math.round(summary.rtt)} MS · J${Math.round(summary.jitter)} · L${Math.round(summary.loss)}%`;
  readout.textContent = `${role} ${remoteLobby?.code ?? "------"} · ${stale ? "STALE" : summary.quality.toUpperCase()} · ${metrics}`;
  readout.dataset.quality = stale ? "poor" : summary.quality;
  readout.title = "Round-trip latency · jitter · recent probe loss";
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
        label.textContent = `${entity.name} · ${race.name} ${agent.name}`;
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
  for (const [key, ability] of [
    ["primary", agent.primary],
    ["special", agent.special],
    ["defense", agent.defense],
    ["mobility", agent.mobility],
  ]) {
    element(`${key}-name`).textContent = ability.name;
    element(`${key}-detail`).textContent =
      ability.fluxCost > 0
        ? `${ability.detail} · ${ability.fluxCost} Flux`
        : ability.detail;
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
      text.textContent = "Hold ALT to sprint. Tap C to preserve momentum through a hop.";
    } else if (matchState.tutorial.step === 1) {
      text.textContent = "MOVE while aiming. Land pressure with MB1.";
    } else if (matchState.tutorial.step === 2) {
      text.textContent = "SHIFT changes the angle. Q answers incoming pressure.";
    } else if (matchState.tutorial.step === 3) {
      text.textContent = "Commit E up close. Miss, and you surrender tempo.";
    } else {
      text.textContent = "Language learned. Read the spar and finish the fight.";
    }
  } else {
    skip.hidden = true;
    progress.hidden = true;
    if (matchState.status === "round-over") {
      text.textContent = "Resetting positions. The next read starts clean.";
    } else if (matchState.objective.contested) {
      text.textContent = "Objective contested. Create space before you score.";
    } else if (matchState.objective.controllingTeam) {
      text.textContent = `${matchState.objective.controllingTeam.toUpperCase()} controls the field.`;
    } else {
      text.textContent =
        mode.id === "duel"
          ? "First to five. Cover, cooldowns, and commitment decide the round."
          : mode.description;
    }
  }
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
      toast("CORE MOVEMENT + COMBAT ONLINE");
    } else if (event.type === "wallKick") {
      toast("WALL KICK · ANGLE STOLEN");
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
      tone(280, 0.12, "sine", 0.05);
      burst(event.x, event.y, "#d9f7ff", 14);
      toast(`${event.reaction.toUpperCase()}! · FIELD CLEARED`, "comic");
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
    drawObjective(map, time);
    drawElementFields(time);
    drawHazards(time);
    drawObstacles(map);
    drawMines(time);
    drawTrails();
    drawProjectiles();
    drawDecoys(time);
    drawEntities(time);
    drawEffects();
  } finally {
    context.restore();
  }
  if (app.dataset.view === "game" && pointer.active && localPlayer()) {
    drawCrosshair(time);
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
  context.strokeStyle = settings.highContrast ? "#52677e" : map.visual.grid;
  context.lineWidth = 1;
  context.beginPath();
  for (let x = inset; x <= width - inset; x += 80) {
    context.moveTo(x, inset);
    context.lineTo(x, height - inset);
  }
  for (let y = inset; y <= height - inset; y += 80) {
    context.moveTo(inset, y);
    context.lineTo(width - inset, y);
  }
  context.stroke();
  context.strokeStyle = map.visual.accent;
  context.lineWidth = 2;
  context.strokeRect(inset, inset, width - inset * 2, height - inset * 2);
  context.globalAlpha = 0.22;
  context.strokeStyle = map.visual.accent;
  context.setLineDash([18, 22]);
  context.lineDashOffset = -time * 30;
  context.strokeRect(inset + 10, inset + 10, width - inset * 2 - 20, height - inset * 2 - 20);
  context.setLineDash([]);
  context.globalAlpha = 1;
}

function drawObjective(map, time) {
  const mode = getMode(matchState.modeId);
  if (mode.id !== "control" && mode.id !== "convergence") return;
  const objective = map.objective;
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
  };
  const marks = { wind: ">>>", earth: "###", ice: "* *", fire: "^^^", water: "~~~" };
  for (const field of matchState.elementFields ?? []) {
    context.save();
    try {
      const color = colors[field.element] ?? "#fff";
      context.fillStyle = `${color}24`;
      context.strokeStyle = color;
      context.lineWidth = settings.highContrast ? 4 : 2;
      context.setLineDash(field.element === "ice" ? [8, 7] : []);
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
      context.fillStyle = color;
      context.font = "700 13px ui-monospace, monospace";
      context.textAlign = "center";
      context.textBaseline = "middle";
      const labelX = field.element === "earth" ? field.x + field.width / 2 : field.x;
      const labelY = field.element === "earth" ? field.y + field.height / 2 : field.y;
      context.fillText(marks[field.element] ?? field.element, labelX, labelY);
    } finally {
      context.restore();
    }
  }
}

function drawObstacles(map) {
  for (const obstacle of map.obstacles) {
    context.fillStyle = "#182534";
    context.strokeStyle = settings.highContrast ? "#7490aa" : "#40536a";
    context.lineWidth = settings.highContrast ? 3 : 2;
    context.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
    context.strokeRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
    context.fillStyle = "#ffffff08";
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
    } finally {
      context.restore();
    }
  }
}

function drawEntities(time) {
  for (const entity of matchState.entities) {
    const agent = getCharacter(entity.characterId);
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
      context.fillText(
        `${entity.name} · ${getRace(entity.raceId).name} ${agent.name}`,
        0,
        agent.radius + 21,
      );
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
  } else {
    context.beginPath();
    context.arc(0, 0, radius, 0, Math.PI * 2);
  }
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
  element("map-options").innerHTML = MAPS.map(
    (map, index) => `
      <label class="choice-card atlas-node" style="--atlas-x:${map.atlas.x}%;--atlas-y:${map.atlas.y}%" title="${map.region} · ${map.scale} · ${map.identity}">
        <input type="radio" name="map" value="${map.id}" ${index === 0 ? "checked" : ""}>
        <b>${map.name}</b>
        <small>${map.region} · ${map.scale}</small>
        <em>${map.hazards.length ? `${map.hazards.length} hazard${map.hazards.length > 1 ? "s" : ""}` : "Pure geometry"}</em>
      </label>`,
  ).join("");
  element("agent-options").innerHTML = agentPicker("character", "kite");
  element("race-options").innerHTML = racePicker("race", "human");
  element("agent-two-options").innerHTML = agentPicker(
    "characterTwo",
    "bulwark",
  );
  element("race-two-options").innerHTML = racePicker("raceTwo", "orc");
  element("agent-codex").innerHTML = CHARACTERS.map(agentCard).join("");
  element("map-codex").innerHTML = MAPS.map(
    (map) => `
      <article class="codex-card">
        <em>${map.hazards.length ? "ACTIVE FIELD" : "GEOMETRY FIELD"}</em>
        <b>${map.name}</b>
        <p>${map.identity} ${map.obstacles.length} pieces of hard cover, ${map.spawns.length} protected spawn anchors.</p>
        <button class="text-button codex-action" type="button" data-select-map="${map.id}">Select arena →</button>
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
  element("online-mode").innerHTML = MODES.filter(
    (mode) => mode.id !== "training",
  )
    .map((mode) => `<option value="${mode.id}">${mode.name}</option>`)
    .join("");
  element("online-map").innerHTML = MAPS.map(
    (map) => `<option value="${map.id}">${map.name}</option>`,
  ).join("");
  element("server-address").value = location.origin;
  updateDeploymentSummary();
}

function agentPicker(name, selected) {
  return CHARACTERS.map(
    (agent) => `
      <label class="agent-choice" style="--agent-color:${agent.accent}" title="${agent.role} · ${agent.affinity.name}: ${agent.style}">
        <input type="radio" name="${name}" value="${agent.id}" ${agent.id === selected ? "checked" : ""}>
        <span class="agent-choice-glyph" aria-hidden="true">${agent.glyph}</span>
        <b>${agent.name}</b>
      </label>`,
  ).join("");
}

function racePicker(name, selected) {
  return RACES.map(
    (race) => `
      <label class="race-choice" title="${race.trait}: ${race.boon}; ${race.drawback}">
        <input type="radio" name="${name}" value="${race.id}" ${race.id === selected ? "checked" : ""}>
        <b>${race.name}</b><span>${race.boon}</span><small>${race.drawback}</small>
      </label>`,
  ).join("");
}

function agentCard(agent) {
  return `
    <article class="agent-card" style="--agent-color:${agent.accent};--agent-wash:${agent.accent}22">
      <div class="agent-identity"><i class="agent-glyph" aria-hidden="true">${agent.glyph}</i><b>${agent.name}</b><span>${agent.role} · ${"◆".repeat(agent.difficulty)}</span></div>
      <div class="agent-data">
        <p>${agent.style}</p>
        <p><strong>${agent.affinity.name} ELEMENT</strong> · ${agent.affinity.edge}</p>
        <div class="kit-list">
          ${[
            agent.primary,
            agent.special,
            agent.defense,
            agent.mobility,
          ]
            .map(
              (ability) =>
                `<div><b>${ability.name}</b><span>${ability.detail}</span></div>`,
            )
            .join("")}
        </div>
        <button class="text-button codex-action" type="button" data-select-agent="${agent.id}">Select agent →</button>
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
        maxPlayers: 4,
        botCount: 1,
      },
    });
    if (!result.ok) throw new Error(result.message);
    beginRemote(result);
    const shareUrl = new URL("/", readServerBase());
    shareUrl.searchParams.set("join", result.lobby.code);
    element("share-link").value = shareUrl.href;
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
      setServerStatus("offline", "NETWORK DISCONNECTED");
      for (const pending of requestResolvers.values()) {
        pending.reject(new Error("Connection closed."));
      }
      requestResolvers.clear();
      if (wasRemote) {
        paused = true;
        pauseOverlay.classList.remove("hidden");
        element("pause-title").textContent = "Connection lost";
        element("pause-copy").textContent =
          "Your slot is reserved for 30 seconds. Open Host / Join and reconnect the last session.";
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
  pendingInputs = [];
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
    const parsed = JSON.parse(localStorage.getItem(RECONNECT_KEY) ?? "null");
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
  });
  for (const input of settingsForm.querySelectorAll('input[type="range"]')) {
    input.parentElement.querySelector("output").value = input.value;
  }
  localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
  applySettings();
}

function resetSettings() {
  settings = { ...DEFAULT_SETTINGS };
  localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
  syncSettingsForm();
  applySettings();
  toast("Presentation defaults restored.");
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
}

function loadSettings() {
  try {
    return normalizeSettings(JSON.parse(localStorage.getItem(SETTINGS_KEY)));
  } catch {
    return { ...DEFAULT_SETTINGS };
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
  };
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

window.DIFF_DEBUG = Object.freeze({
  getState: () => structuredClone(matchState),
  getInvariantErrors: () => matchInvariantErrors(matchState),
  getInterfaceState: () => ({
    infoOpen,
    menuPanel,
    matchKind,
    view: app.dataset.view,
  }),
  launchMode,
  quickStart,
  showPanel,
  toggleInfo,
});
