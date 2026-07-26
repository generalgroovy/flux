import test from "node:test";
import assert from "node:assert/strict";

import { MATCH_TUNING } from "../src/content.mjs";
import { LobbyService } from "../src/lobbies.mjs";
import { matchInvariantErrors } from "../src/match.mjs";

function serviceFixture() {
  let now = 10_000;
  let codeIndex = 0;
  const codes = ["ABC234", "DEF567", "GHJ789"];
  return {
    service: new LobbyService({
      now: () => now,
      codeFactory: () => codes[codeIndex++],
      tokenFactory: () => `token-${codeIndex}-${now}`,
    }),
    advance(milliseconds) {
      now += milliseconds;
    },
  };
}

test("public lobbies can be hosted, listed, and joined in progress", () => {
  const { service } = serviceFixture();
  const hostMessages = [];
  const guestMessages = [];
  const hosted = service.host(
    "host-client",
    {
      name: "Deep Arena",
      modeId: "control",
      mapId: "crown",
      characterId: "orbit",
      raceId: "tideborn",
      botCount: 0,
      maxPlayers: 4,
    },
    (message) => hostMessages.push(message),
  );
  assert.equal(hosted.ok, true);
  assert.equal(hosted.lobby.code, "ABC234");
  assert.equal(hosted.snapshot.state.entities[0].raceId, "tideborn");
  assert.equal(service.list().length, 1);

  for (let tick = 0; tick < MATCH_TUNING.tickRate; tick += 1) {
    service.tick(1 / MATCH_TUNING.tickRate);
  }
  const elapsed = hosted.snapshot.state.elapsed;
  const joined = service.join(
    "guest-client",
    "abc234",
    { name: "Guest", characterId: "echo" },
    (message) => guestMessages.push(message),
  );
  assert.equal(joined.ok, true);
  assert.equal(joined.snapshot.state.status, "playing");
  assert.ok(joined.snapshot.state.elapsed >= elapsed);
  assert.equal(joined.snapshot.entityId, joined.entityId);
  assert.equal(service.list()[0].players, 2);
  assert.ok(hostMessages.some((message) => message.type === "presence"));
  assert.deepEqual(matchInvariantErrors(joined.snapshot.state), []);
});

test("host hazard configuration is authoritative and survives rematches", () => {
  const { service } = serviceFixture();
  const hosted = service.host("host", {
    modeId: "duel",
    mapId: "breakline",
    hazardsEnabled: false,
    botCount: 0,
  });
  assert.equal(hosted.ok, true);
  assert.equal(hosted.snapshot.state.rules.hazardsEnabled, false);
  assert.equal(hosted.snapshot.state.hazards.length, 0);
  const lobby = service.lobbies.get(hosted.lobby.code);
  lobby.state.status = "match-over";
  const rematch = service.rematch("host");
  assert.equal(rematch.ok, true);
  assert.equal(lobby.state.rules.hazardsEnabled, false);
  assert.equal(lobby.state.hazards.length, 0);
});

test("private lobbies stay out of discovery but remain joinable by code", () => {
  const { service } = serviceFixture();
  const hosted = service.host("host", { public: false }, () => {});
  assert.equal(hosted.ok, true);
  assert.deepEqual(service.list(), []);
  assert.equal(service.join("guest", hosted.lobby.code, {}, () => {}).ok, true);
});

test("lobby input requires monotonic sequences and enforces server sanitization", () => {
  const { service } = serviceFixture();
  service.host("host", { botCount: 0 }, () => {});
  assert.equal(
    service.input("host", 1, {
      moveX: Number.NaN,
      moveY: Number.POSITIVE_INFINITY,
      fire: "yes",
    }).ok,
    true,
  );
  assert.equal(service.input("host", 1, {}).code, "stale-input");
  assert.equal(service.input("host", 0, {}).code, "stale-input");
  assert.equal(service.input("host", 2, { moveX: 1 }).ok, true);
  service.tick(1 / MATCH_TUNING.tickRate);
  const lobby = [...service.lobbies.values()][0];
  const entity = lobby.state.entities.find((candidate) => candidate.human);
  assert.ok(entity.x > 0);
  assert.deepEqual(matchInvariantErrors(lobby.state), []);
});

test("ultimate commands remain server-authoritative through the lobby protocol", () => {
  const { service } = serviceFixture();
  service.host(
    "host",
    { characterId: "rimewing", raceId: "wyrmbound", botCount: 0 },
    () => {},
  );
  const lobby = [...service.lobbies.values()][0];
  const member = lobby.members.get("host");
  const entity = lobby.state.entities.find(
    (candidate) => candidate.id === member.entityId,
  );
  entity.ultimateCharge = entity.maxUltimate;
  assert.equal(service.input("host", 1, { ultimate: true }).ok, true);
  service.tick(1 / MATCH_TUNING.tickRate);
  assert.equal(entity.ultimateCharge, 0);
  assert.ok(entity.ultimateWindupRemaining > 0);
  assert.equal(
    lobby.state.events.some((event) => event.type === "ultimateTell"),
    true,
  );
  assert.deepEqual(matchInvariantErrors(lobby.state), []);
});

test("full and missing lobbies fail explicitly", () => {
  const { service } = serviceFixture();
  const hosted = service.host("host", { maxPlayers: 2 }, () => {});
  assert.equal(service.join("guest", hosted.lobby.code, {}, () => {}).ok, true);
  assert.equal(service.join("third", hosted.lobby.code, {}, () => {}).code, "full");
  assert.equal(service.join("lost", "ZZZZZZ", {}, () => {}).code, "not-found");
});

test("host disconnect migrates authority and the final disconnect removes lobby", () => {
  const { service } = serviceFixture();
  const messages = [];
  const hosted = service.host("host", {}, () => {});
  service.join("guest", hosted.lobby.code, {}, (message) => messages.push(message));
  assert.equal(service.leave("host"), true);
  assert.equal(service.list()[0].hostId, "guest");
  assert.ok(messages.some((message) => message.type === "host-migrated"));
  assert.equal(service.leave("guest"), true);
  assert.deepEqual(service.list(), []);
});

test("stale remote input decays to idle while snapshots continue", () => {
  const { service, advance } = serviceFixture();
  const messages = [];
  service.host("host", { botCount: 0 }, (message) => messages.push(message));
  service.input("host", 1, { moveX: 1, fire: true });
  for (let tick = 0; tick < MATCH_TUNING.tickRate; tick += 1) {
    service.tick(1 / MATCH_TUNING.tickRate);
  }
  assert.ok(messages.some((message) => message.type === "snapshot"));
  advance(2_000);
  for (let tick = 0; tick < 30; tick += 1) {
    service.tick(1 / MATCH_TUNING.tickRate);
  }
  const lobby = [...service.lobbies.values()][0];
  const member = lobby.members.get("host");
  assert.equal(member.command.moveX, 1);
  const entity = lobby.state.entities.find(
    (candidate) => candidate.id === member.entityId,
  );
  assert.ok(Math.abs(entity.vx) < entity.maxHealth * 10);
});

test("only the migrated current host can restart a completed lobby", () => {
  const { service } = serviceFixture();
  const hosted = service.host("host", { botCount: 0 }, () => {});
  service.join("guest", hosted.lobby.code, {}, () => {});
  const lobby = service.lobbies.get(hosted.lobby.code);
  lobby.state.status = "match-over";
  assert.equal(service.rematch("guest").code, "host-only");
  assert.equal(service.rematch("host").ok, true);
  assert.equal(lobby.state.status, "playing");
  assert.equal(lobby.members.size, 2);
});

test("survival lobbies keep all remote humans cooperative", () => {
  const { service } = serviceFixture();
  const hosted = service.host(
    "host",
    { modeId: "survival", botCount: 1, maxPlayers: 4 },
    () => {},
  );
  service.join("guest-one", hosted.lobby.code, {}, () => {});
  service.join("guest-two", hosted.lobby.code, {}, () => {});
  const lobby = service.lobbies.get(hosted.lobby.code);
  const humanTeams = lobby.state.entities
    .filter((entity) => entity.human)
    .map((entity) => entity.team);
  assert.deepEqual(humanTeams, ["alpha", "alpha", "alpha"]);
});

test("joining a completed lobby starts a clean rematch for every member", () => {
  const { service } = serviceFixture();
  const hosted = service.host("host", { botCount: 0, maxPlayers: 4 }, () => {});
  service.join("guest", hosted.lobby.code, {}, () => {});
  const lobby = service.lobbies.get(hosted.lobby.code);
  lobby.state.status = "match-over";
  lobby.state.score.alpha = 5;
  const late = service.join("late", hosted.lobby.code, {}, () => {});
  assert.equal(late.ok, true);
  assert.equal(lobby.state.status, "playing");
  assert.deepEqual(lobby.state.score, { alpha: 0, beta: 0 });
  assert.equal(lobby.members.size, 3);
  assert.ok(
    [...lobby.members.values()].every((member) =>
      lobby.state.entities.some((entity) => entity.id === member.entityId),
    ),
  );
});

test("disconnect reserves an exact player session and reconnect restores it", () => {
  const { service, advance } = serviceFixture();
  const hosted = service.host(
    "host",
    { characterId: "volt", botCount: 0 },
    () => {},
  );
  const lobby = service.lobbies.get(hosted.lobby.code);
  const entity = lobby.state.entities.find(
    (candidate) => candidate.id === hosted.entityId,
  );
  entity.health = 37;
  service.tick(1 / MATCH_TUNING.tickRate);
  const elapsed = lobby.state.elapsed;

  assert.equal(service.disconnect("host"), true);
  assert.equal(service.list()[0].connectedPlayers, 0);
  advance(5_000);
  const resumed = service.reconnect(
    "host-new-socket",
    hosted.reconnectToken,
    () => {},
  );
  assert.equal(resumed.ok, true);
  assert.notEqual(resumed.reconnectToken, hosted.reconnectToken);
  assert.equal(resumed.entityId, hosted.entityId);
  assert.equal(resumed.snapshot.state.elapsed, elapsed);
  assert.equal(
    resumed.snapshot.state.entities.find(
      (candidate) => candidate.id === hosted.entityId,
    ).health,
    37,
  );
  assert.equal(service.list()[0].hostId, "host-new-socket");
  assert.equal(
    service.input("host-new-socket", 1, { moveX: 1 }).ok,
    true,
  );
});

test("expired reconnect reservations are removed deterministically", () => {
  const { service, advance } = serviceFixture();
  const hosted = service.host("host", { botCount: 0 }, () => {});
  service.disconnect("host");
  advance(30_001);
  service.tick(1 / MATCH_TUNING.tickRate);
  assert.deepEqual(service.list(), []);
  assert.equal(
    service.reconnect("new-socket", hosted.reconnectToken, () => {}).code,
    "invalid-token",
  );
});

test("spectators receive snapshots without consuming or controlling player slots", () => {
  const { service } = serviceFixture();
  const messages = [];
  const hosted = service.host("host", { maxPlayers: 2, botCount: 0 }, () => {});
  const watched = service.spectate(
    "observer",
    hosted.lobby.code,
    { name: "Caster" },
    (message) => messages.push(message),
  );
  assert.equal(watched.ok, true);
  assert.equal(watched.role, "spectator");
  assert.equal(watched.entityId, null);
  assert.equal(service.list()[0].players, 1);
  assert.equal(service.list()[0].spectators, 1);
  assert.equal(
    service.input("observer", 1, { fire: true }).code,
    "spectator-read-only",
  );
  assert.equal(
    service.changeAgent("observer", "echo").code,
    "spectator-read-only",
  );
  service.tick(1 / 20);
  assert.ok(messages.some((message) => message.type === "snapshot"));
  assert.equal(service.join("guest", hosted.lobby.code, {}, () => {}).ok, true);
});

test("a playerless lobby closes instead of stranding observers", () => {
  const { service } = serviceFixture();
  const observerMessages = [];
  const hosted = service.host("host", { botCount: 0 }, () => {});
  service.spectate(
    "observer",
    hosted.lobby.code,
    {},
    (message) => observerMessages.push(message),
  );
  assert.equal(service.leave("host"), true);
  assert.deepEqual(service.list(), []);
  assert.ok(
    observerMessages.some((message) => message.type === "lobby-closed"),
  );
  assert.equal(
    service.input("observer", 1, {}).code,
    "not-in-lobby",
  );
});
