import { CONFIG } from "./config.mjs";
import {
  createInitialState,
  formatTime,
  stepSimulation,
} from "./simulation.mjs";

const canvas = document.querySelector("#game");
const context = canvas.getContext("2d");
const objective = document.querySelector("#objective");
const timer = document.querySelector("#timer");
const progress = document.querySelector("#progress");
const healthValue = document.querySelector("#health-value");
const healthFill = document.querySelector("#health-fill");
const coach = document.querySelector("#coach");
const hint = document.querySelector("#hint");
const dashCharge = document.querySelector("#dash-charge");
const result = document.querySelector("#result");
const resultTime = document.querySelector("#result-time");
const resultLabel = document.querySelector("#result-label");
const resultMessage = document.querySelector("#result-message");
const restartButton = document.querySelector("#restart");

const keys = new Set();
const pointer = { x: 0, y: 0, active: false, firing: false };
const effects = [];
const trail = [];
const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
let state = createInitialState();
let dashQueued = false;
let accumulator = 0;
let previousTime = performance.now();
let screenShake = 0;
let view = { scale: 1, offsetX: 0, offsetY: 0 };

buildProgress();
resize();
updateInterface();
requestAnimationFrame(frame);

window.addEventListener("resize", resize);
window.addEventListener("keydown", (event) => {
  const key = event.key.toLowerCase();
  if (
    ["w", "a", "s", "d", "arrowup", "arrowdown", "arrowleft", "arrowright", " "].includes(
      key,
    )
  ) {
    event.preventDefault();
    keys.add(key);
  }
  if (key === "shift" && !event.repeat) dashQueued = true;
  if (key === "r") restart();
});
window.addEventListener("keyup", (event) => keys.delete(event.key.toLowerCase()));
window.addEventListener("blur", clearInput);
canvas.addEventListener("contextmenu", (event) => event.preventDefault());
canvas.addEventListener("pointermove", (event) => {
  const bounds = canvas.getBoundingClientRect();
  pointer.x = (event.clientX - bounds.left) * (canvas.width / bounds.width);
  pointer.y = (event.clientY - bounds.top) * (canvas.height / bounds.height);
  pointer.active = true;
});
canvas.addEventListener("pointerdown", (event) => {
  if (event.button === 0) {
    pointer.firing = true;
    canvas.setPointerCapture(event.pointerId);
  }
});
canvas.addEventListener("pointerup", (event) => {
  if (event.button === 0) pointer.firing = false;
});
canvas.addEventListener("pointerleave", () => {
  pointer.active = false;
  pointer.firing = false;
});
restartButton.addEventListener("click", restart);

function frame(now) {
  const frameDelta = Math.min(
    (now - previousTime) / 1000,
    CONFIG.simulation.maxFrameDelta,
  );
  previousTime = now;
  accumulator += frameDelta;

  const fixedDelta = 1 / CONFIG.simulation.tickRate;
  while (accumulator >= fixedDelta) {
    stepSimulation(state, readInput(), fixedDelta);
    processEvents();
    if (state.started) addTrailPoint();
    accumulator -= fixedDelta;
  }

  updateEffects(frameDelta);
  updateInterface();
  render(now / 1000);
  requestAnimationFrame(frame);
}

function readInput() {
  const moveX =
    Number(keys.has("d") || keys.has("arrowright")) -
    Number(keys.has("a") || keys.has("arrowleft"));
  const moveY =
    Number(keys.has("s") || keys.has("arrowdown")) -
    Number(keys.has("w") || keys.has("arrowup"));
  const pointerWorld = screenToWorld(pointer.x, pointer.y);
  const input = {
    moveX,
    moveY,
    aimX: pointer.active ? pointerWorld.x - state.player.x : moveX,
    aimY: pointer.active ? pointerWorld.y - state.player.y : moveY,
    fire: pointer.firing || keys.has(" "),
    dash: dashQueued,
  };
  dashQueued = false;
  return input;
}

function clearInput() {
  keys.clear();
  pointer.firing = false;
  dashQueued = false;
}

function restart() {
  state = createInitialState();
  effects.length = 0;
  trail.length = 0;
  clearInput();
  screenShake = 0;
  accumulator = 0;
  previousTime = performance.now();
  updateInterface();
}

function buildProgress() {
  const pips = CONFIG.map.targets.map(() => {
    const pip = document.createElement("span");
    pip.className = "progress-pip";
    return pip;
  });
  const dashPip = document.createElement("span");
  dashPip.className = "progress-pip";
  dashPip.title = "Dash";
  pips.push(dashPip);
  progress.replaceChildren(...pips);
}

function updateInterface() {
  const destroyed = state.targets.filter((target) => target.destroyed).length;
  const remaining = state.targets.length - destroyed;
  objective.textContent =
    remaining > 0
      ? `Break ${remaining} target${remaining === 1 ? "" : "s"}`
      : state.tutorial.dashed
        ? "Field clear"
        : "Dash once to finish";
  timer.textContent = formatTime(state.elapsed);

  [...progress.children].forEach((pip, index) => {
    if (index < state.targets.length) {
      pip.classList.toggle("complete", state.targets[index].destroyed);
    } else {
      pip.classList.toggle("dash", state.tutorial.dashed);
    }
  });

  const hintText = getCoachHint();
  hint.textContent = hintText;
  coach.classList.toggle("hidden", hintText === "");

  const dashRatio =
    1 - state.player.dashCooldown / CONFIG.character.dash.cooldown;
  dashCharge.style.transform = `scaleX(${Math.max(0, Math.min(1, dashRatio))})`;
  const healthRatio = state.player.health / CONFIG.character.maxHealth;
  healthValue.textContent = String(state.player.health);
  healthFill.style.transform = `scaleX(${healthRatio})`;
  healthFill.classList.toggle("critical", healthRatio <= 0.34);

  const hasResult = state.status !== "playing";
  result.classList.toggle("hidden", !hasResult);
  result.setAttribute("aria-hidden", String(!hasResult));
  if (hasResult) {
    const defeated = state.status === "defeated";
    resultLabel.textContent = defeated ? "Signal lost" : "Field clear";
    resultTime.textContent = defeated ? "DOWN" : formatTime(state.elapsed);
    resultMessage.textContent = defeated
      ? "Read the lock. Break line or move before discharge."
      : "Movement. Aim. Timing. Again.";
  }
}

function getCoachHint() {
  if (state.status !== "playing") return "";
  if (!state.tutorial.moved) return "WASD — MOVE";
  if (!state.tutorial.fired) return "MOUSE + CLICK — FIRE";
  if (!state.tutorial.hit) return "TRACK THE GOLD TARGETS";
  if (!state.tutorial.dashed) return "SHIFT — DASH";
  if (!state.tutorial.threatened) return "WATCH THE RED SENTRY";
  if (state.sentry.telegraphRemaining > 0) return "BREAK LINE OR EVADE THE LOCK";
  if (state.targets.some((target) => !target.destroyed)) return "CLEAR THE FIELD";
  return "";
}

function processEvents() {
  for (const event of state.events) {
    if (event.type === "shot") {
      burst(event.x, event.y, CONFIG.presentation.playerAccent, 4, 90, 0.13);
    } else if (event.type === "blocked") {
      burst(event.x, event.y, "#8295a8", 5, 95, 0.18);
    } else if (event.type === "hit") {
      burst(event.x, event.y, CONFIG.presentation.targetDamage, 9, 180, 0.28);
      screenShake = Math.max(screenShake, reducedMotion ? 0 : 3);
    } else if (event.type === "destroyed") {
      burst(event.x, event.y, CONFIG.presentation.target, 18, 260, 0.48);
      screenShake = Math.max(screenShake, reducedMotion ? 0 : 8);
    } else if (event.type === "dash") {
      burst(event.x, event.y, CONFIG.presentation.playerAccent, 8, 130, 0.3);
      screenShake = Math.max(screenShake, reducedMotion ? 0 : 2);
    } else if (event.type === "sentryWarning") {
      burst(event.x, event.y, CONFIG.presentation.danger, 6, 75, 0.3);
    } else if (event.type === "sentryShot") {
      burst(event.targetX, event.targetY, event.blocked ? "#8295a8" : CONFIG.presentation.danger, 10, 190, 0.3);
      screenShake = Math.max(screenShake, reducedMotion ? 0 : 4);
    } else if (event.type === "playerHit") {
      burst(event.x, event.y, CONFIG.presentation.danger, 16, 230, 0.42);
      screenShake = Math.max(screenShake, reducedMotion ? 0 : 9);
    } else if (event.type === "defeated") {
      screenShake = Math.max(screenShake, reducedMotion ? 0 : 12);
    } else if (event.type === "complete") {
      screenShake = Math.max(screenShake, reducedMotion ? 0 : 5);
    }
  }
}

function burst(x, y, color, count, speed, life) {
  for (let index = 0; index < count; index += 1) {
    const angle = (index / count) * Math.PI * 2 + Math.random() * 0.35;
    const velocity = speed * (0.45 + Math.random() * 0.55);
    effects.push({
      x,
      y,
      vx: Math.cos(angle) * velocity,
      vy: Math.sin(angle) * velocity,
      color,
      life,
      maxLife: life,
    });
  }
}

function updateEffects(delta) {
  for (const effect of effects) {
    effect.x += effect.vx * delta;
    effect.y += effect.vy * delta;
    effect.vx *= Math.pow(0.02, delta);
    effect.vy *= Math.pow(0.02, delta);
    effect.life -= delta;
  }
  while (effects[0]?.life <= 0) effects.shift();
  for (let index = effects.length - 1; index >= 0; index -= 1) {
    if (effects[index].life <= 0) effects.splice(index, 1);
  }

  for (const point of trail) point.life -= delta * (point.dash ? 3.2 : 2.5);
  while (trail[0]?.life <= 0) trail.shift();
  screenShake = Math.max(0, screenShake - delta * 30);
}

function addTrailPoint() {
  const last = trail.at(-1);
  if (!last || Math.hypot(last.x - state.player.x, last.y - state.player.y) > 12) {
    trail.push({
      x: state.player.x,
      y: state.player.y,
      life: 1,
      dash: state.player.dashRemaining > 0,
    });
  }
}

function resize() {
  const ratio = Math.min(window.devicePixelRatio || 1, 2);
  canvas.width = Math.floor(window.innerWidth * ratio);
  canvas.height = Math.floor(window.innerHeight * ratio);
  view.scale = Math.min(
    canvas.width / CONFIG.arena.width,
    canvas.height / CONFIG.arena.height,
  );
  view.offsetX = (canvas.width - CONFIG.arena.width * view.scale) / 2;
  view.offsetY = (canvas.height - CONFIG.arena.height * view.scale) / 2;
}

function screenToWorld(x, y) {
  return {
    x: (x - view.offsetX) / view.scale,
    y: (y - view.offsetY) / view.scale,
  };
}

function render(time) {
  context.clearRect(0, 0, canvas.width, canvas.height);
  context.save();
  const shakeX = screenShake > 0 ? Math.sin(time * 87) * screenShake : 0;
  const shakeY = screenShake > 0 ? Math.cos(time * 71) * screenShake : 0;
  context.translate(view.offsetX + shakeX, view.offsetY + shakeY);
  context.scale(view.scale, view.scale);

  drawArena();
  drawFlowLines(time);
  drawSentryBeam();
  drawObstacles();
  drawSentry(time);
  drawTargets(time);
  drawTrail();
  drawProjectiles();
  drawPlayer();
  drawEffects();
  drawCrosshair();
  context.restore();
}

function drawSentryBeam() {
  const sentry = state.sentry;
  if (sentry.telegraphRemaining <= 0 && sentry.flash <= 0) return;
  const warning = sentry.telegraphRemaining > 0;
  const progress = warning
    ? 1 - sentry.telegraphRemaining / CONFIG.sentry.telegraphDuration
    : 1;
  context.save();
  context.strokeStyle = warning ? `${CONFIG.presentation.danger}99` : "#fff4f6";
  context.lineWidth = warning ? 2 + progress * 4 : CONFIG.sentry.beamWidth;
  context.setLineDash(warning ? [9, Math.max(3, 18 - progress * 14)] : []);
  context.shadowColor = CONFIG.presentation.danger;
  context.shadowBlur = warning ? 7 + progress * 12 : 24;
  context.beginPath();
  context.moveTo(sentry.x, sentry.y);
  context.lineTo(sentry.aimX, sentry.aimY);
  context.stroke();
  context.restore();
}

function drawSentry(time) {
  const sentry = state.sentry;
  const warning = sentry.telegraphRemaining > 0;
  const angle = Math.atan2(sentry.aimY - sentry.y, sentry.aimX - sentry.x);
  context.save();
  context.translate(sentry.x, sentry.y);
  context.rotate(angle);
  context.fillStyle = warning ? "#ff5d7338" : "#111c27";
  context.strokeStyle = warning || sentry.flash > 0 ? CONFIG.presentation.danger : "#8fa8c0";
  context.lineWidth = 4;
  context.shadowColor = CONFIG.presentation.danger;
  context.shadowBlur = warning ? 18 + Math.sin(time * 22) * 5 : 5;
  context.beginPath();
  context.arc(0, 0, CONFIG.sentry.radius, 0, Math.PI * 2);
  context.fill();
  context.stroke();
  context.fillStyle = context.strokeStyle;
  context.fillRect(5, -5, CONFIG.sentry.radius + 13, 10);
  context.restore();
}

function drawArena() {
  const { width, height, inset } = CONFIG.arena;
  const gradient = context.createRadialGradient(
    width * 0.5,
    height * 0.48,
    30,
    width * 0.5,
    height * 0.48,
    width * 0.65,
  );
  gradient.addColorStop(0, "#142231");
  gradient.addColorStop(1, CONFIG.presentation.background);
  context.fillStyle = gradient;
  context.fillRect(0, 0, width, height);

  context.strokeStyle = CONFIG.presentation.grid;
  context.lineWidth = 1;
  for (let x = inset; x <= width - inset; x += 64) {
    context.beginPath();
    context.moveTo(x, inset);
    context.lineTo(x, height - inset);
    context.stroke();
  }
  for (let y = inset; y <= height - inset; y += 64) {
    context.beginPath();
    context.moveTo(inset, y);
    context.lineTo(width - inset, y);
    context.stroke();
  }

  context.strokeStyle = "#8fa8c02f";
  context.lineWidth = 3;
  context.strokeRect(inset, inset, width - inset * 2, height - inset * 2);
}

function drawFlowLines(time) {
  context.save();
  context.strokeStyle = "#77f7ce0e";
  context.lineWidth = 2;
  context.setLineDash([16, 24]);
  context.lineDashOffset = -time * 45;
  for (const y of [250, 450, 650]) {
    context.beginPath();
    context.moveTo(CONFIG.arena.inset, y);
    context.lineTo(CONFIG.arena.width - CONFIG.arena.inset, y);
    context.stroke();
  }
  context.restore();
}

function drawObstacles() {
  for (const obstacle of CONFIG.map.obstacles) {
    const gradient = context.createLinearGradient(
      obstacle.x,
      obstacle.y,
      obstacle.x + obstacle.width,
      obstacle.y + obstacle.height,
    );
    gradient.addColorStop(0, "#24384a");
    gradient.addColorStop(1, "#111c27");
    context.fillStyle = gradient;
    context.strokeStyle = CONFIG.presentation.coverEdge;
    context.lineWidth = 3;
    context.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
    context.strokeRect(
      obstacle.x + 1.5,
      obstacle.y + 1.5,
      obstacle.width - 3,
      obstacle.height - 3,
    );
  }
}

function drawTargets(time) {
  for (const target of state.targets) {
    if (target.destroyed) continue;
    const healthRatio = target.health / CONFIG.target.health;
    const pulse = Math.sin(time * 3.5 + target.x * 0.01) * 2;
    const radius = CONFIG.target.radius + pulse;

    context.save();
    context.translate(target.x, target.y);
    context.rotate(time * 0.6);
    context.fillStyle =
      target.hitFlash > 0 ? CONFIG.presentation.targetDamage : "#ffca4f22";
    context.strokeStyle =
      target.hitFlash > 0
        ? CONFIG.presentation.targetDamage
        : CONFIG.presentation.target;
    context.lineWidth = 4;
    context.shadowColor = context.strokeStyle;
    context.shadowBlur = target.hitFlash > 0 ? 28 : 14;
    context.beginPath();
    for (let side = 0; side < 6; side += 1) {
      const angle = (side / 6) * Math.PI * 2;
      const x = Math.cos(angle) * radius;
      const y = Math.sin(angle) * radius;
      if (side === 0) context.moveTo(x, y);
      else context.lineTo(x, y);
    }
    context.closePath();
    context.fill();
    context.stroke();
    context.restore();

    context.strokeStyle = "#344658";
    context.lineWidth = 4;
    context.beginPath();
    context.arc(target.x, target.y, radius + 11, -Math.PI / 2, Math.PI * 1.5);
    context.stroke();
    context.strokeStyle = CONFIG.presentation.playerAccent;
    context.beginPath();
    context.arc(
      target.x,
      target.y,
      radius + 11,
      -Math.PI / 2,
      -Math.PI / 2 + Math.PI * 2 * healthRatio,
    );
    context.stroke();
  }
}

function drawTrail() {
  for (const point of trail) {
    context.globalAlpha = point.life * (point.dash ? 0.45 : 0.14);
    context.fillStyle = CONFIG.presentation.playerAccent;
    context.beginPath();
    context.arc(
      point.x,
      point.y,
      CONFIG.character.radius * point.life * (point.dash ? 1.1 : 0.75),
      0,
      Math.PI * 2,
    );
    context.fill();
  }
  context.globalAlpha = 1;
}

function drawProjectiles() {
  for (const projectile of state.projectiles) {
    context.strokeStyle = "#77f7ce66";
    context.lineWidth = projectile.radius * 1.4;
    context.beginPath();
    context.moveTo(
      projectile.x - projectile.vx * 0.018,
      projectile.y - projectile.vy * 0.018,
    );
    context.lineTo(projectile.x, projectile.y);
    context.stroke();
    context.fillStyle = CONFIG.presentation.projectile;
    context.shadowColor = CONFIG.presentation.playerAccent;
    context.shadowBlur = 12;
    context.beginPath();
    context.arc(projectile.x, projectile.y, projectile.radius, 0, Math.PI * 2);
    context.fill();
    context.shadowBlur = 0;
  }
}

function drawPlayer() {
  const player = state.player;
  const angle = Math.atan2(player.facingY, player.facingX);
  context.save();
  if (player.hitInvulnerability > 0 && Math.floor(player.hitInvulnerability * 24) % 2 === 0) {
    context.globalAlpha = 0.42;
  }
  context.translate(player.x, player.y);
  context.rotate(angle);
  context.fillStyle = CONFIG.presentation.player;
  context.shadowColor = CONFIG.presentation.playerAccent;
  context.shadowBlur = state.player.dashRemaining > 0 ? 26 : 14;
  context.beginPath();
  context.moveTo(CONFIG.character.radius + 9, 0);
  context.lineTo(-CONFIG.character.radius * 0.7, -CONFIG.character.radius * 0.8);
  context.lineTo(-CONFIG.character.radius * 0.35, 0);
  context.lineTo(-CONFIG.character.radius * 0.7, CONFIG.character.radius * 0.8);
  context.closePath();
  context.fill();
  context.shadowBlur = 0;
  context.strokeStyle = CONFIG.presentation.playerAccent;
  context.lineWidth = 3;
  context.stroke();
  context.restore();
}

function drawEffects() {
  for (const effect of effects) {
    const ratio = Math.max(0, effect.life / effect.maxLife);
    context.globalAlpha = ratio;
    context.fillStyle = effect.color;
    context.fillRect(effect.x - 2, effect.y - 2, 4 + ratio * 4, 4 + ratio * 4);
  }
  context.globalAlpha = 1;
}

function drawCrosshair() {
  if (!pointer.active) return;
  const world = screenToWorld(pointer.x, pointer.y);
  context.save();
  context.translate(world.x, world.y);
  context.strokeStyle = "#e8fff8c7";
  context.lineWidth = 2 / view.scale;
  context.beginPath();
  context.arc(0, 0, 10, 0, Math.PI * 2);
  context.moveTo(-16, 0);
  context.lineTo(-7, 0);
  context.moveTo(16, 0);
  context.lineTo(7, 0);
  context.moveTo(0, -16);
  context.lineTo(0, -7);
  context.moveTo(0, 16);
  context.lineTo(0, 7);
  context.stroke();
  context.restore();
}
