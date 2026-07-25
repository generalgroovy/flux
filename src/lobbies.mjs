import { randomBytes } from "node:crypto";

import { getCharacter, getMap, getMode } from "./content.mjs";
import {
  addMatchPlayer,
  createMatch,
  removeMatchPlayer,
  sanitizeCommand,
  stepMatch,
} from "./match.mjs";

const LOBBY_CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const MAX_MESSAGE_RATE = 180;
const MAX_LOBBIES_PER_CLIENT = 2;

export class LobbyService {
  constructor({ now = () => Date.now(), codeFactory = createLobbyCode } = {}) {
    this.now = now;
    this.codeFactory = codeFactory;
    this.lobbies = new Map();
    this.clientLobby = new Map();
    this.clientRate = new Map();
    this.snapshotAccumulator = 0;
  }

  list() {
    return [...this.lobbies.values()]
      .filter((lobby) => lobby.public)
      .map((lobby) => this.describe(lobby))
      .sort((left, right) => right.createdAt - left.createdAt);
  }

  host(clientId, candidate = {}, send = () => {}) {
    const ownedCount = [...this.lobbies.values()].filter(
      (lobby) => lobby.hostId === clientId,
    ).length;
    if (ownedCount >= MAX_LOBBIES_PER_CLIENT) {
      return failure("host-limit", "Leave an existing hosted lobby first.");
    }
    this.leave(clientId);
    const code = this.uniqueCode();
    const mode = getMode(candidate.modeId);
    const map = getMap(candidate.mapId);
    const member = normalizeMember(clientId, candidate, send);
    const maxPlayers = clampInteger(candidate.maxPlayers, 2, 4, 4);
    const state = createMatch({
      modeId: mode.id,
      mapId: map.id,
      botCount: clampInteger(candidate.botCount, 0, 7, mode.botCount),
      players: [
        {
          id: `remote-${shortId(clientId)}`,
          clientId,
          name: member.name,
          characterId: member.characterId,
          team: "alpha",
          human: true,
        },
      ],
    });
    member.entityId = state.entities[0].id;
    const lobby = {
      code,
      name: cleanText(candidate.name, "OPEN ARENA", 30),
      public: candidate.public !== false,
      hostId: clientId,
      maxPlayers,
      createdAt: this.now(),
      state,
      members: new Map([[clientId, member]]),
      networkTick: 0,
    };
    this.lobbies.set(code, lobby);
    this.clientLobby.set(clientId, code);
    return success({
      lobby: this.describe(lobby),
      entityId: member.entityId,
      snapshot: createNetworkSnapshot(lobby, member),
    });
  }

  join(clientId, codeCandidate, candidate = {}, send = () => {}) {
    const code = String(codeCandidate ?? "").trim().toUpperCase();
    const lobby = this.lobbies.get(code);
    if (!lobby) return failure("not-found", "Lobby not found or already closed.");
    if (lobby.members.size >= lobby.maxPlayers) {
      return failure("full", "That lobby is full.");
    }
    this.leave(clientId);
    const member = normalizeMember(clientId, candidate, send);
    if (lobby.state.status === "match-over") {
      this.restartLobby(lobby, [...lobby.members.values(), member]);
    } else {
      const entity = addMatchPlayer(lobby.state, {
        id: `remote-${shortId(clientId)}`,
        clientId,
        name: member.name,
        characterId: member.characterId,
        team: lobby.state.modeId === "survival" ? "alpha" : undefined,
      });
      if (!entity) return failure("closed", "The match cannot accept players.");
      member.entityId = entity.id;
    }
    lobby.members.set(clientId, member);
    this.clientLobby.set(clientId, code);
    this.broadcast(lobby, {
      type: "presence",
      action: "joined",
      name: member.name,
      players: lobby.members.size,
    });
    return success({
      lobby: this.describe(lobby),
      entityId: member.entityId,
      snapshot: createNetworkSnapshot(lobby, member),
    });
  }

  leave(clientId) {
    const code = this.clientLobby.get(clientId);
    this.clientLobby.delete(clientId);
    this.clientRate.delete(clientId);
    if (!code) return false;
    const lobby = this.lobbies.get(code);
    if (!lobby) return false;
    const member = lobby.members.get(clientId);
    lobby.members.delete(clientId);
    if (member?.entityId) removeMatchPlayer(lobby.state, member.entityId);
    if (lobby.members.size === 0) {
      this.lobbies.delete(code);
      return true;
    }
    if (lobby.hostId === clientId) {
      lobby.hostId = lobby.members.keys().next().value;
      this.broadcast(lobby, {
        type: "host-migrated",
        hostId: lobby.hostId,
      });
    }
    this.broadcast(lobby, {
      type: "presence",
      action: "left",
      name: member?.name ?? "Player",
      players: lobby.members.size,
    });
    return true;
  }

  input(clientId, sequence, candidate) {
    const lobby = this.lobbies.get(this.clientLobby.get(clientId));
    const member = lobby?.members.get(clientId);
    if (!lobby || !member) return failure("not-in-lobby", "Join a lobby first.");
    if (!Number.isInteger(sequence) || sequence <= member.lastSequence) {
      return failure("stale-input", "Input sequence must increase.");
    }
    if (!this.allowMessage(clientId)) {
      return failure("rate-limit", "Input rate exceeded.");
    }
    member.lastSequence = sequence;
    member.command = sanitizeCommand(candidate);
    member.lastInputAt = this.now();
    return success({ sequence });
  }

  changeAgent(clientId, characterId) {
    const lobby = this.lobbies.get(this.clientLobby.get(clientId));
    const member = lobby?.members.get(clientId);
    const entity = lobby?.state.entities.find(
      (candidate) => candidate.id === member?.entityId,
    );
    if (!member || !entity) return failure("not-in-lobby", "Join a lobby first.");
    if (entity.alive && lobby.state.status === "playing") {
      return failure("in-progress", "Change agent after an elimination or rematch.");
    }
    const agent = getCharacter(characterId);
    member.characterId = agent.id;
    entity.characterId = agent.id;
    entity.health = agent.health;
    entity.maxHealth = agent.health;
    return success({ characterId: agent.id });
  }

  rematch(clientId) {
    const lobby = this.lobbies.get(this.clientLobby.get(clientId));
    if (!lobby) return failure("not-in-lobby", "Join a lobby first.");
    if (lobby.hostId !== clientId) {
      return failure("host-only", "Only the current host can start a rematch.");
    }
    this.restartLobby(lobby, [...lobby.members.values()]);
    this.broadcastSnapshots(lobby, true);
    return success({ lobby: this.describe(lobby) });
  }

  tick(delta) {
    for (const lobby of this.lobbies.values()) {
      const commands = {};
      for (const member of lobby.members.values()) {
        commands[member.entityId] =
          this.now() - member.lastInputAt <= 1_500
            ? member.command
            : sanitizeCommand({});
      }
      stepMatch(lobby.state, commands, delta);
      lobby.networkTick += 1;
    }
    this.snapshotAccumulator += delta;
    if (this.snapshotAccumulator >= 1 / 20) {
      this.snapshotAccumulator %= 1 / 20;
      for (const lobby of this.lobbies.values()) this.broadcastSnapshots(lobby);
    }
  }

  describe(lobby) {
    const mode = getMode(lobby.state.modeId);
    const map = getMap(lobby.state.mapId);
    return {
      code: lobby.code,
      name: lobby.name,
      public: lobby.public,
      hostId: lobby.hostId,
      players: lobby.members.size,
      maxPlayers: lobby.maxPlayers,
      modeId: mode.id,
      modeName: mode.name,
      mapId: map.id,
      mapName: map.name,
      status: lobby.state.status,
      elapsed: lobby.state.elapsed,
      createdAt: lobby.createdAt,
    };
  }

  broadcastSnapshots(lobby, immediate = false) {
    for (const member of lobby.members.values()) {
      member.send({
        type: "snapshot",
        immediate,
        ...createNetworkSnapshot(lobby, member),
      });
    }
  }

  broadcast(lobby, message) {
    for (const member of lobby.members.values()) member.send(message);
  }

  restartLobby(lobby, members) {
    const oldState = lobby.state;
    const playerSpecs = members.map((member, index) => ({
      id: member.entityId ?? `remote-${shortId(member.clientId)}`,
      clientId: member.clientId,
      name: member.name,
      characterId: member.characterId,
      team:
        oldState.modeId === "survival"
          ? "alpha"
          : index % 2 === 0
            ? "alpha"
            : "beta",
      human: true,
    }));
    lobby.state = createMatch({
      modeId: oldState.modeId,
      mapId: oldState.mapId,
      players: playerSpecs,
      botCount: Math.max(
        0,
        oldState.entities.filter((entity) => entity.bot && !entity.neutral).length,
      ),
    });
    for (const member of members) {
      const entity = lobby.state.entities.find(
        (candidate) => candidate.clientId === member.clientId,
      );
      member.entityId = entity?.id ?? member.entityId;
      member.command = sanitizeCommand({});
      member.lastSequence = -1;
    }
  }

  allowMessage(clientId) {
    const now = this.now();
    const current = this.clientRate.get(clientId);
    if (!current || now - current.windowStart >= 1_000) {
      this.clientRate.set(clientId, { windowStart: now, count: 1 });
      return true;
    }
    current.count += 1;
    return current.count <= MAX_MESSAGE_RATE;
  }

  uniqueCode() {
    for (let attempt = 0; attempt < 30; attempt += 1) {
      const code = this.codeFactory();
      if (!this.lobbies.has(code)) return code;
    }
    throw new Error("Could not allocate a unique lobby code.");
  }
}

function normalizeMember(clientId, candidate, send) {
  return {
    clientId,
    entityId: null,
    name: cleanText(candidate.playerName ?? candidate.name, "PLAYER", 20),
    characterId: getCharacter(candidate.characterId).id,
    command: sanitizeCommand({}),
    lastSequence: -1,
    lastInputAt: 0,
    joinedAt: Date.now(),
    send,
  };
}

function createNetworkSnapshot(lobby, member) {
  return {
    lobby: {
      code: lobby.code,
      name: lobby.name,
      hostId: lobby.hostId,
      players: lobby.members.size,
      maxPlayers: lobby.maxPlayers,
    },
    serverTick: lobby.networkTick,
    acknowledgedSequence: member.lastSequence,
    entityId: member.entityId,
    state: lobby.state,
  };
}

function createLobbyCode() {
  const bytes = randomBytes(6);
  let code = "";
  for (const byte of bytes) code += LOBBY_CODE_ALPHABET[byte % LOBBY_CODE_ALPHABET.length];
  return code;
}

function cleanText(value, fallback, maximumLength) {
  const cleaned = String(value ?? "")
    .replace(/[^\p{L}\p{N} ._-]/gu, "")
    .trim()
    .slice(0, maximumLength);
  return cleaned || fallback;
}

function shortId(id) {
  return String(id).replace(/[^a-zA-Z0-9]/g, "").slice(0, 8) || "player";
}

function clampInteger(value, minimum, maximum, fallback) {
  if (!Number.isInteger(value)) return fallback;
  return Math.max(minimum, Math.min(maximum, value));
}

function success(value = {}) {
  return { ok: true, ...value };
}

function failure(code, message) {
  return { ok: false, code, message };
}
