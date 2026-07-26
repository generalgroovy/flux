import test from "node:test";
import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { createServer } from "node:net";

import WebSocket from "ws";

test(
  "shipped server supports discovery, live join, spectators, reconnect, host migration, and clear shutdown",
  { timeout: 12_000 },
  async (t) => {
    const port = await freePort();
    const origin = `http://127.0.0.1:${port}`;
    const child = spawn(process.execPath, ["scripts/serve.mjs"], {
      cwd: new URL("../", import.meta.url),
      env: { ...process.env, PORT: String(port), HOST: "127.0.0.1" },
      stdio: ["ignore", "pipe", "pipe"],
    });
    let serverOutput = "";
    child.stdout.on("data", (chunk) => {
      serverOutput += chunk;
    });
    child.stderr.on("data", (chunk) => {
      serverOutput += chunk;
    });
    t.after(() => {
      child.kill("SIGTERM");
    });
    await waitForHealth(origin, child, () => serverOutput);

    const health = await fetch(`${origin}/__diff_health`).then((response) =>
      response.json(),
    );
    assert.equal(health.product, "DIFF");
    assert.equal(health.status, "ready");
    assert.equal(health.version, "0.33.0");
    assert.equal(health.protocol, 2);
    assert.match(health.instance, /^[0-9a-f-]{36}$/i);
    const initialList = await fetch(`${origin}/api/lobbies`).then((response) =>
      response.json(),
    );
    assert.deepEqual(initialList, { lobbies: [] });
    for (const route of [
      "/",
      "/styles.css",
      "/src/content.mjs",
      "/src/game.mjs",
      "/src/match.mjs",
      "/src/network-conditioner.mjs",
      "/src/network-quality.mjs",
    ]) {
      const response = await fetch(`${origin}${route}`);
      assert.equal(response.status, 200, route);
      assert.match(
        response.headers.get("content-security-policy") ?? "",
        /default-src 'self'/,
      );
      assert.equal(response.headers.get("x-content-type-options"), "nosniff");
    }
    for (const privateRoute of [
      "/package.json",
      "/scripts/serve.mjs",
      "/src/lobbies.mjs",
      "/tests/network.test.mjs",
      "/%2e%2e%2fpackage.json",
    ]) {
      const response = await fetch(`${origin}${privateRoute}`);
      assert.ok(
        response.status === 403 || response.status === 404,
        `${privateRoute}: ${response.status}`,
      );
    }

    const host = await TestClient.connect(`ws://127.0.0.1:${port}/ws`);
    host.send({ type: "probe", sequence: 7 });
    const probe = await host.waitFor(
      (message) => message.type === "probe" && message.sequence === 7,
    );
    assert.deepEqual(probe, { type: "probe", sequence: 7 });
    const hosted = await host.request("host", {
      options: {
        name: "Network Proof",
        modeId: "control",
        mapId: "crown",
        characterId: "orbit",
        botCount: 0,
        public: true,
      },
    });
    assert.equal(hosted.ok, true);
    assert.match(hosted.lobby.code, /^[A-Z2-9]{6}$/);

    const discovered = await fetch(`${origin}/api/lobbies`).then((response) =>
      response.json(),
    );
    assert.equal(discovered.lobbies.length, 1);
    assert.equal(discovered.lobbies[0].code, hosted.lobby.code);

    await host.waitFor(
      (message) =>
        message.type === "snapshot" && message.state.elapsed > 0.03,
    );
    const guest = await TestClient.connect(`ws://127.0.0.1:${port}/ws`);
    const joined = await guest.request("join", {
      code: hosted.lobby.code,
      options: { name: "Late Join", characterId: "echo" },
    });
    assert.equal(joined.ok, true);
    assert.equal(joined.snapshot.state.status, "playing");
    assert.ok(joined.snapshot.state.elapsed > 0);
    assert.equal(joined.snapshot.state.entities.some(
      (entity) => entity.clientId === guest.clientId,
    ), true);

    const observer = await TestClient.connect(`ws://127.0.0.1:${port}/ws`);
    const watched = await observer.request("spectate", {
      code: hosted.lobby.code,
      options: { name: "Caster" },
    });
    assert.equal(watched.ok, true);
    assert.equal(watched.role, "spectator");
    assert.equal(watched.entityId, null);
    const spectatorInput = await observer.request("input", {
      sequence: 1,
      command: { fire: true },
    });
    assert.equal(spectatorInput.code, "spectator-read-only");

    guest.send({
      type: "input",
      sequence: 1,
      command: {
        moveX: 1,
        moveY: 0,
        aimX: 1,
        aimY: 0,
        fire: true,
      },
    });
    const acknowledged = await guest.waitFor(
      (message) =>
        message.type === "snapshot" &&
        message.acknowledgedSequence >= 1 &&
        message.serverTick > joined.snapshot.serverTick,
    );
    assert.equal(acknowledged.entityId, joined.entityId);

    host.close();
    const migration = await guest.waitFor(
      (message) =>
        message.type === "host-migrated" &&
        message.hostId === guest.clientId,
    );
    assert.equal(migration.hostId, guest.clientId);

    const afterMigration = await fetch(`${origin}/api/lobbies`).then(
      (response) => response.json(),
    );
    assert.equal(afterMigration.lobbies[0].hostId, guest.clientId);

    const returningHost = await TestClient.connect(
      `ws://127.0.0.1:${port}/ws`,
    );
    const reconnected = await returningHost.request("reconnect", {
      token: hosted.reconnectToken,
    });
    assert.equal(reconnected.ok, true);
    assert.equal(reconnected.entityId, hosted.entityId);
    assert.equal(reconnected.lobby.hostId, guest.clientId);
    assert.equal(
      reconnected.snapshot.state.entities.some(
        (entity) => entity.id === hosted.entityId,
      ),
      true,
    );
    const shutdownNotices = [
      returningHost.waitFor((message) => message.type === "server-shutdown"),
      observer.waitFor((message) => message.type === "server-shutdown"),
      guest.waitFor((message) => message.type === "server-shutdown"),
    ];
    assert.equal(child.kill("SIGTERM"), true);
    for (const notice of await Promise.all(shutdownNotices)) {
      assert.equal(notice.code, "host-shutdown");
      assert.match(notice.message, /authoritative host shut down.*match has ended/i);
    }
    const exitCode = child.exitCode ??
      await new Promise((resolve) => child.once("exit", resolve));
    assert.equal(exitCode, 0, serverOutput);
  },
);

class TestClient {
  constructor(socket) {
    this.socket = socket;
    this.clientId = null;
    this.messages = [];
    this.waiters = [];
    this.requestIndex = 0;
    socket.on("message", (raw) => {
      const message = JSON.parse(raw.toString());
      this.messages.push(message);
      if (message.type === "hello") this.clientId = message.clientId;
      this.flush();
    });
  }

  static async connect(url) {
    const socket = new WebSocket(url);
    const client = new TestClient(socket);
    await new Promise((resolve, reject) => {
      socket.once("open", resolve);
      socket.once("error", reject);
    });
    await client.waitFor((message) => message.type === "hello");
    return client;
  }

  request(type, payload = {}) {
    const requestId = `request-${++this.requestIndex}`;
    this.send({ type, requestId, ...payload });
    return this.waitFor(
      (message) =>
        message.type === "result" && message.requestId === requestId,
    );
  }

  send(message) {
    this.socket.send(JSON.stringify(message));
  }

  waitFor(predicate, timeout = 4_000) {
    const existing = this.messages.find(predicate);
    if (existing) return Promise.resolve(existing);
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.waiters = this.waiters.filter((waiter) => waiter.resolve !== resolve);
        reject(new Error("Timed out waiting for WebSocket message."));
      }, timeout);
      this.waiters.push({
        predicate,
        resolve: (message) => {
          clearTimeout(timer);
          resolve(message);
        },
      });
    });
  }

  flush() {
    for (const waiter of [...this.waiters]) {
      const message = this.messages.find(waiter.predicate);
      if (!message) continue;
      this.waiters = this.waiters.filter((candidate) => candidate !== waiter);
      waiter.resolve(message);
    }
  }

  close() {
    this.socket.close();
  }
}

async function freePort() {
  const server = createServer();
  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", resolve);
  });
  const address = server.address();
  await new Promise((resolve) => server.close(resolve));
  return address.port;
}

async function waitForHealth(origin, child, output) {
  for (let attempt = 0; attempt < 80; attempt += 1) {
    if (child.exitCode !== null) {
      throw new Error(`Server exited early:\n${output()}`);
    }
    try {
      const response = await fetch(`${origin}/__diff_health`);
      if (response.ok) return;
    } catch {
      // Startup race: retry with a bounded delay.
    }
    await new Promise((resolve) => setTimeout(resolve, 25));
  }
  throw new Error(`Server did not become ready:\n${output()}`);
}
