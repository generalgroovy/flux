export const NETWORK_PROBE_INTERVAL_MS = 1_000;
export const NETWORK_PROBE_TIMEOUT_MS = 2_500;
export const NETWORK_PROBE_WINDOW = 20;

export function createNetworkDiagnostics() {
  return {
    nextSequence: 1,
    lastProbeAt: Number.NEGATIVE_INFINITY,
    records: [],
  };
}

export function beginNetworkProbe(state, now) {
  const sequence = state.nextSequence;
  state.nextSequence += 1;
  state.lastProbeAt = finiteTime(now);
  state.records.push({ sequence, sentAt: state.lastProbeAt, rtt: null, lost: false });
  trimRecords(state);
  return sequence;
}

export function receiveNetworkProbe(state, sequence, now) {
  const record = state.records.find(
    (candidate) => candidate.sequence === sequence && candidate.rtt === null && !candidate.lost,
  );
  if (!record) return false;
  record.rtt = Math.max(0, finiteTime(now) - record.sentAt);
  return true;
}

export function expireNetworkProbes(state, now) {
  const current = finiteTime(now);
  for (const record of state.records) {
    if (!record.lost && record.rtt === null && current - record.sentAt >= NETWORK_PROBE_TIMEOUT_MS) {
      record.lost = true;
    }
  }
  trimRecords(state);
}

export function summarizeNetworkDiagnostics(state) {
  const settled = state.records.filter((record) => record.lost || record.rtt !== null);
  const received = settled.filter((record) => record.rtt !== null);
  const lost = settled.length - received.length;
  if (received.length === 0) {
    return { quality: "measuring", rtt: null, jitter: null, loss: settled.length ? 100 : 0 };
  }
  const rtt = received.reduce((sum, record) => sum + record.rtt, 0) / received.length;
  let jitter = 0;
  if (received.length > 1) {
    for (let index = 1; index < received.length; index += 1) {
      jitter += Math.abs(received[index].rtt - received[index - 1].rtt);
    }
    jitter /= received.length - 1;
  }
  const loss = settled.length === 0 ? 0 : (lost / settled.length) * 100;
  const quality =
    loss >= 10 || rtt >= 180 || jitter >= 40
      ? "poor"
      : loss >= 3 || rtt >= 90 || jitter >= 20
        ? "fair"
        : "good";
  return { quality, rtt, jitter, loss };
}

function trimRecords(state) {
  if (state.records.length > NETWORK_PROBE_WINDOW) {
    state.records.splice(0, state.records.length - NETWORK_PROBE_WINDOW);
  }
}

function finiteTime(value) {
  return Number.isFinite(value) ? value : 0;
}
