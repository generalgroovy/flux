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
const prompt = document.querySelector("#prompt");
const result = document.querySelector("#result");
const resultTime = document.querySelector("#result-time");
const restartButton = document.querySelector("#restart");

const keys = new Set();
const pointer = { x: 0, y: 0, active: false };
const trail = [];
let state = createInitialState();
let accumulator = 0;
let previousTime = performance.now();
let view = { scale: 1, offsetX: 0, offsetY: 0 };

buildProgress();
resize();
updateInterface(true);
requestAnimationFrame(frame);

window.addEventListener("resize", resize);
window.addEventListener("keydown", (event) => {
  const key = event.key.toLowerCase();
  if (["w", "a", "s", "d", "arrowup", "arrowdown", "arrowleft", "arrowright"].includes(key)) {
    event.preventDefault();
    keys.add(key);
  }
  if (key === "r") restart();
});
window.addEventListener("keyup", (event) => keys.delete(event.key.toLowerCase()));
window.addEventListener("blur", () => keys.clear());
canvas.addEventListener("pointermove", (event) => {
  const bounds = canvas.getBoundingClientRect();
  pointer.x = (event.clientX - bounds.left) * (canvas.width / bounds.width);
  pointer.y = (event.clientY - bounds.top) * (canvas.height / bounds.height);
  pointer.active = true;
});
canvas.addEventListener("pointerleave", () => {
  pointer.active = false;
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
    const previousStatus = state.status;
    const previousCheckpoint = state.checkpointIndex;
    const movementJustStarted = !state.movementStarted;
    stepSimulation(state, readInput(), fixedDelta);
    if (state.movementStarted) addTrailPoint();
    if (
      previousStatus !== state.status ||
      previousCheckpoint !== state.checkpointIndex ||
      (movementJustStarted && state.movementStarted)
    ) {
      updateInterface();
    }
    accumulator -= fixedDelta;
  }

  updateTrail(frameDelta);
  timer.textContent = formatTime(state.elapsed);
  render(now / 1000);
  requestAnimationFrame(frame);
}

function readInput() {
  return {
    x:
      Number(keys.has("d") || keys.has("arrowright")) -
      Number(keys.has("a") || keys.has("arrowleft")),
    y:
      Number(keys.has("s") || keys.has("arrowdown")) -
      Number(keys.has("w") || keys.has("arrowup")),
  };
}

function restart() {
  state = createInitialState();
  trail.length = 0;
  accumulator = 0;
  previousTime = performance.now();
  updateInterface(true);
}

function buildProgress() {
  progress.replaceChildren(
    ...CONFIG.checkpoints.positions.map(() => {
      const pip = document.createElement("span");
      pip.className = "progress-pip";
      return pip;
    }),
  );
}

function updateInterface(resetPrompt = false) {
  if (resetPrompt) prompt.classList.remove("dismissed");
  if (state.movementStarted) prompt.classList.add("dismissed");

  const pips = [...progress.children];
  pips.forEach((pip, index) => {
    pip.classList.toggle("complete", index < state.checkpointIndex);
  });

  const isComplete = state.status === "complete";
  objective.textContent = isComplete
    ? "Trial complete"
    : `Reach signal ${state.checkpointIndex + 1} of ${CONFIG.checkpoints.positions.length}`;
  result.classList.toggle("hidden", !isComplete);
  result.setAttribute("aria-hidden", String(!isComplete));
  if (isComplete) resultTime.textContent = formatTime(state.elapsed);
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

function render(time) {
  context.clearRect(0, 0, canvas.width, canvas.height);
  context.save();
  context.translate(view.offsetX, view.offsetY);
  context.scale(view.scale, view.scale);

  drawArena();
  drawRoute();
  drawCheckpoints(time);
  drawTrail();
  drawPlayer();
  context.restore();
}

function drawArena() {
  const { width, height, inset } = CONFIG.arena;
  const gradient = context.createRadialGradient(
    width / 2,
    height / 2,
    50,
    width / 2,
    height / 2,
    width * 0.65,
  );
  gradient.addColorStop(0, "#122138");
  gradient.addColorStop(1, "#080c15");
  context.fillStyle = gradient;
  context.fillRect(0, 0, width, height);

  context.strokeStyle = "#8eabd211";
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

  context.strokeStyle = "#88a8d92e";
  context.lineWidth = 3;
  context.strokeRect(inset, inset, width - inset * 2, height - inset * 2);
}

function drawRoute() {
  const points = [
    { x: CONFIG.arena.inset + 90, y: CONFIG.arena.height / 2 },
    ...CONFIG.checkpoints.positions,
  ];
  context.setLineDash([8, 14]);
  context.lineWidth = 2;
  context.strokeStyle = "#7f9aba2a";
  context.beginPath();
  context.moveTo(points[0].x, points[0].y);
  for (const point of points.slice(1)) context.lineTo(point.x, point.y);
  context.stroke();
  context.setLineDash([]);
}

function drawCheckpoints(time) {
  CONFIG.checkpoints.positions.forEach((checkpoint, index) => {
    const active = index === state.checkpointIndex;
    const complete = index < state.checkpointIndex;
    const pulse = active ? Math.sin(time * 4) * 5 : 0;
    const radius = CONFIG.checkpoints.radius + pulse;

    context.save();
    context.translate(checkpoint.x, checkpoint.y);
    context.strokeStyle = complete
      ? CONFIG.presentation.playerAccent
      : active
        ? CONFIG.presentation.targetColor
        : CONFIG.presentation.inactiveTargetColor;
    context.fillStyle = complete
      ? "#6ef7c81a"
      : active
        ? "#ffce4816"
        : "#30445f12";
    context.lineWidth = active ? 5 : 3;
    context.shadowColor = context.strokeStyle;
    context.shadowBlur = active ? 22 : complete ? 10 : 0;
    context.beginPath();
    context.arc(0, 0, radius, 0, Math.PI * 2);
    context.fill();
    context.stroke();

    context.shadowBlur = 0;
    context.fillStyle = context.strokeStyle;
    context.font = "800 18px ui-sans-serif, system-ui, sans-serif";
    context.textAlign = "center";
    context.textBaseline = "middle";
    context.fillText(complete ? "✓" : String(index + 1), 0, 1);
    context.restore();
  });
}

function drawTrail() {
  for (const point of trail) {
    context.globalAlpha = point.life * 0.25;
    context.fillStyle = CONFIG.presentation.playerAccent;
    context.beginPath();
    context.arc(point.x, point.y, CONFIG.player.radius * point.life, 0, Math.PI * 2);
    context.fill();
  }
  context.globalAlpha = 1;
}

function drawPlayer() {
  const { x, y, vx, vy } = state.player;
  const speed = Math.hypot(vx, vy);
  const movementAngle = speed > 2 ? Math.atan2(vy, vx) : 0;
  const pointerWorldX = (pointer.x - view.offsetX) / view.scale;
  const pointerWorldY = (pointer.y - view.offsetY) / view.scale;
  const aimAngle = pointer.active
    ? Math.atan2(pointerWorldY - y, pointerWorldX - x)
    : movementAngle;

  context.save();
  context.translate(x, y);
  context.rotate(aimAngle);
  context.fillStyle = CONFIG.presentation.playerColor;
  context.shadowColor = CONFIG.presentation.playerAccent;
  context.shadowBlur = 18;
  context.beginPath();
  context.arc(0, 0, CONFIG.player.radius, 0, Math.PI * 2);
  context.fill();
  context.shadowBlur = 0;
  context.fillStyle = CONFIG.presentation.playerAccent;
  context.beginPath();
  context.moveTo(CONFIG.player.radius + 13, 0);
  context.lineTo(CONFIG.player.radius - 3, -7);
  context.lineTo(CONFIG.player.radius - 3, 7);
  context.closePath();
  context.fill();
  context.restore();
}

function addTrailPoint() {
  const last = trail.at(-1);
  if (
    !last ||
    Math.hypot(last.x - state.player.x, last.y - state.player.y) > 13
  ) {
    trail.push({ x: state.player.x, y: state.player.y, life: 1 });
  }
}

function updateTrail(delta) {
  for (const point of trail) point.life -= delta * 2.4;
  while (trail[0]?.life <= 0) trail.shift();
}
