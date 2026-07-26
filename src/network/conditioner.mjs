export const NETWORK_LAB_LIMITS = Object.freeze({
  latency: 250,
  jitter: 100,
  loss: 20,
});

export function normalizeNetworkLab(candidate = {}) {
  const source = candidate && typeof candidate === "object" ? candidate : {};
  return {
    latency: bounded(source.latency, 0, NETWORK_LAB_LIMITS.latency),
    jitter: bounded(source.jitter, 0, NETWORK_LAB_LIMITS.jitter),
    loss: bounded(source.loss, 0, NETWORK_LAB_LIMITS.loss),
  };
}

export function networkLabActive(config) {
  const normalized = normalizeNetworkLab(config);
  return normalized.latency > 0 || normalized.jitter > 0 || normalized.loss > 0;
}

export function isFreshServerTick(lastAccepted, candidate) {
  const previous = Number.isInteger(lastAccepted) ? lastAccepted : -1;
  return Number.isInteger(candidate) && candidate > previous;
}

export function createPacketConditioner(config = {}, seed = 0x484558) {
  return {
    config: normalizeNetworkLab(config),
    seed: Number.isInteger(seed) ? seed >>> 0 : 0x484558,
    nextId: 1,
    queue: [],
    enqueued: 0,
    delivered: 0,
    dropped: 0,
  };
}

export function configurePacketConditioner(state, config, { reset = true } = {}) {
  state.config = normalizeNetworkLab(config);
  if (reset) {
    state.nextId = 1;
    state.queue = [];
    state.enqueued = 0;
    state.delivered = 0;
    state.dropped = 0;
  }
  return state;
}

export function conditionPacket(state, direction, payload, now) {
  const packetDirection = direction === "incoming" ? "incoming" : "outgoing";
  const id = state.nextId;
  state.nextId += 1;
  state.enqueued += 1;
  const lossRoll = sample(state.seed, id, packetDirection, 0);
  if (lossRoll < state.config.loss / 100) {
    state.dropped += 1;
    return { id, dropped: true, dueAt: null };
  }
  const jitterRoll = sample(state.seed, id, packetDirection, 1) * 2 - 1;
  const delay = Math.max(0, state.config.latency + jitterRoll * state.config.jitter);
  const dueAt = finiteTime(now) + delay;
  state.queue.push({ id, direction: packetDirection, payload, dueAt });
  if (state.queue.length > 2_048) {
    state.queue.splice(0, state.queue.length - 2_048);
    state.dropped += 1;
  }
  return { id, dropped: false, dueAt };
}

export function drainPackets(state, direction, now) {
  const packetDirection = direction === "incoming" ? "incoming" : "outgoing";
  const current = finiteTime(now);
  const ready = [];
  const waiting = [];
  for (const packet of state.queue) {
    if (packet.direction === packetDirection && packet.dueAt <= current) ready.push(packet);
    else waiting.push(packet);
  }
  ready.sort((left, right) => left.dueAt - right.dueAt || left.id - right.id);
  state.queue = waiting;
  state.delivered += ready.length;
  return ready.map((packet) => packet.payload);
}

function sample(seed, id, direction, stream) {
  let value = seed ^ Math.imul(id + stream * 0x9e37, 0x85ebca6b);
  value ^= direction === "incoming" ? 0x51f15e5d : 0x68bc21eb;
  value ^= value >>> 16;
  value = Math.imul(value, 0x7feb352d);
  value ^= value >>> 15;
  value = Math.imul(value, 0x846ca68b);
  value ^= value >>> 16;
  return (value >>> 0) / 0x1_0000_0000;
}

function bounded(value, minimum, maximum) {
  const number = Number(value);
  return Number.isFinite(number)
    ? Math.max(minimum, Math.min(maximum, number))
    : minimum;
}

function finiteTime(value) {
  return Number.isFinite(value) ? value : 0;
}
