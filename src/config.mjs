export const CONFIG = Object.freeze({
  simulation: Object.freeze({
    tickRate: 120,
    maxFrameDelta: 0.1,
  }),
  arena: Object.freeze({
    width: 1600,
    height: 900,
    inset: 48,
  }),
  player: Object.freeze({
    radius: 22,
    maxSpeed: 430,
    acceleration: 2600,
    deceleration: 3200,
  }),
  checkpoints: Object.freeze({
    radius: 46,
    positions: Object.freeze([
      Object.freeze({ x: 430, y: 250 }),
      Object.freeze({ x: 800, y: 690 }),
      Object.freeze({ x: 1170, y: 250 }),
      Object.freeze({ x: 1390, y: 610 }),
    ]),
  }),
  presentation: Object.freeze({
    playerColor: "#f5f8ff",
    playerAccent: "#6ef7c8",
    targetColor: "#ffce48",
    inactiveTargetColor: "#30445f",
  }),
});
