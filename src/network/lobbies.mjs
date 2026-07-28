import { randomBytes } from "node:crypto";

import { getCharacter, getMap, getMode, getRace } from "../live-content.mjs";
import {
  addMatchPlayer,
  applyFreeplayAction,
  configureMatchPlayer,
  createMatch,
  releaseMatchPlayerObjectives,
  removeMatchPlayer,
  sanitizeCommand,
  setFreeplaySettings,
  stepMatch,
} from "../match.mjs";

const LOBBY_CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const MAX_MESSAGE_RATE = 180;
const MAX_LOBBIES_PER_CLIENT = 2;
const MAX_SPECTATORS = 24;
const RECONNECT_GRACE_MS = 30_000;

export class LobbyService {
  constructor({
    now = () => Date.now(),
    codeFactory = createLobbyCode,
    tokenFactory = createReconnectToken,
  } = {}) {
    this.now = now;
    this.codeFactory = codeFactory;
    this.tokenFactory = tokenFactory;
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
    const member = normalizeMember(
      clientId,
      candidate,
      send,
      this.tokenFactory(),
    );
    const maximumForMode = mode.id === "battle_royale" ? 12 : mode.id === "freeplay" ? 8 : 6;
    const defaultForMode = mode.id === "battle_royale" ? 8 : mode.id === "freeplay" ? 6 : 4;
    const maxPlayers = clampInteger(candidate.maxPlayers, 2, maximumForMode, defaultForMode);
    const teamSize = mode.id === "battle_royale"
      ? clampInteger(candidate.teamSize, 1, 3, 1)
      : mode.id === "survival" ? maxPlayers : 1;
    const state = createMatch({
      modeId: mode.id,
      mapId: map.id,
      botCount: clampInteger(candidate.botCount, 0, 7, mode.botCount),
      hazardsEnabled: candidate.hazardsEnabled !== false,
      freeplaySettings: candidate.freeplaySettings,
      players: [
        {
          id: `remote-${shortId(clientId)}`,
          clientId,
          name: member.name,
          characterId: member.characterId,
          raceId: member.raceId,
          activeAbilityIds: member.activeAbilityIds,
          ultimateAbilityId: member.ultimateAbilityId,
          team: teamForIndex(mode.id, 0, teamSize),
          human: true,
        },
      ],
    });
    member.entityId = state.entities[0].id;
    syncMemberFromEntity(member, state.entities[0]);
    const lobby = {
      code,
      name: cleanText(candidate.name, "OPEN ARENA", 30),
      public: candidate.public !== false,
      hostId: clientId,
      maxPlayers,
      teamSize,
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
      role: member.role,
      reconnectToken: member.reconnectToken,
      snapshot: createNetworkSnapshot(lobby, member),
    });
  }

  join(clientId, codeCandidate, candidate = {}, send = () => {}) {
    const code = String(codeCandidate ?? "").trim().toUpperCase();
    const lobby = this.lobbies.get(code);
    if (!lobby) return failure("not-found", "Lobby not found or already closed.");
    if (playerCount(lobby) >= lobby.maxPlayers) {
      return failure("full", "That lobby is full.");
    }
    this.leave(clientId);
    const member = normalizeMember(
      clientId,
      candidate,
      send,
      this.tokenFactory(),
    );
    if (lobby.state.status === "match-over") {
      this.restartLobby(lobby, [...lobby.members.values(), member]);
    } else {
      const entity = addMatchPlayer(lobby.state, {
        id: `remote-${shortId(clientId)}`,
        clientId,
        name: member.name,
        characterId: member.characterId,
        raceId: member.raceId,
        activeAbilityIds: member.activeAbilityIds,
        ultimateAbilityId: member.ultimateAbilityId,
        team: teamForIndex(lobby.state.modeId, playerCount(lobby), lobby.teamSize),
      });
      if (!entity) return failure("closed", "The match cannot accept players.");
      member.entityId = entity.id;
      syncMemberFromEntity(member, entity);
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
      role: member.role,
      reconnectToken: member.reconnectToken,
      snapshot: createNetworkSnapshot(lobby, member),
    });
  }

  spectate(clientId, codeCandidate, candidate = {}, send = () => {}) {
    const code = String(codeCandidate ?? "").trim().toUpperCase();
    const lobby = this.lobbies.get(code);
    if (!lobby) return failure("not-found", "Lobby not found or already closed.");
    if (spectatorCount(lobby) >= MAX_SPECTATORS) {
      return failure("spectator-full", "That lobby has no spectator slots left.");
    }
    this.leave(clientId);
    const member = normalizeMember(
      clientId,
      candidate,
      send,
      this.tokenFactory(),
      "spectator",
    );
    lobby.members.set(clientId, member);
    this.clientLobby.set(clientId, code);
    this.broadcast(lobby, {
      type: "presence",
      action: "watching",
      name: member.name,
      players: playerCount(lobby),
      spectators: spectatorCount(lobby),
    });
    return success({
      lobby: this.describe(lobby),
      entityId: null,
      role: member.role,
      reconnectToken: member.reconnectToken,
      snapshot: createNetworkSnapshot(lobby, member),
    });
  }

  reconnect(clientId, tokenCandidate, send = () => {}) {
    const token = String(tokenCandidate ?? "");
    if (!token) return failure("invalid-token", "Reconnect token required.");
    for (const lobby of this.lobbies.values()) {
      const found = [...lobby.members.entries()].find(
        ([, member]) => member.reconnectToken === token,
      );
      if (!found) continue;
      const [previousClientId, member] = found;
      if (member.connected) {
        return failure("already-connected", "That session is already connected.");
      }
      if (
        member.disconnectedAt === null ||
        this.now() - member.disconnectedAt > RECONNECT_GRACE_MS
      ) {
        this.removeMember(lobby, previousClientId, "expired");
        return failure("expired-token", "Reconnect window expired.");
      }
      this.leave(clientId);
      lobby.members.delete(previousClientId);
      this.clientLobby.delete(previousClientId);
      member.clientId = clientId;
      member.reconnectToken = this.tokenFactory();
      member.connected = true;
      member.disconnectedAt = null;
      member.send = send;
      member.command = sanitizeCommand({});
      member.lastSequence = -1;
      member.lastInputAt = this.now();
      lobby.members.set(clientId, member);
      this.clientLobby.set(clientId, lobby.code);
      if (lobby.hostId === previousClientId) lobby.hostId = clientId;
      const entity = lobby.state.entities.find(
        (candidate) => candidate.id === member.entityId,
      );
      if (entity) entity.clientId = clientId;
      this.broadcast(lobby, {
        type: "presence",
        action: "reconnected",
        name: member.name,
        players: playerCount(lobby),
        spectators: spectatorCount(lobby),
      });
      return success({
        lobby: this.describe(lobby),
        entityId: member.entityId,
        role: member.role,
        reconnectToken: member.reconnectToken,
        snapshot: createNetworkSnapshot(lobby, member),
      });
    }
    return failure("invalid-token", "Reconnect session was not found.");
  }

  disconnect(clientId) {
    const code = this.clientLobby.get(clientId);
    this.clientLobby.delete(clientId);
    this.clientRate.delete(clientId);
    if (!code) return false;
    const lobby = this.lobbies.get(code);
    const member = lobby?.members.get(clientId);
    if (!lobby || !member || !member.connected) return false;
    member.connected = false;
    member.disconnectedAt = this.now();
    member.command = sanitizeCommand({});
    member.send = () => {};
    const releasedObjective = releaseMatchPlayerObjectives(
      lobby.state,
      member.entityId,
      "disconnect",
    );
    if (lobby.hostId === clientId) this.migrateHost(lobby, clientId);
    this.broadcast(lobby, {
      type: "presence",
      action: "disconnected",
      name: member.name,
      players: playerCount(lobby),
      spectators: spectatorCount(lobby),
    });
    if (releasedObjective) {
      lobby.networkTick += 1;
      this.broadcastSnapshots(lobby, true);
    }
    return true;
  }

  leave(clientId) {
    const code = this.clientLobby.get(clientId);
    this.clientLobby.delete(clientId);
    this.clientRate.delete(clientId);
    if (!code) return false;
    const lobby = this.lobbies.get(code);
    if (!lobby) return false;
    return this.removeMember(lobby, clientId, "left");
  }

  input(clientId, sequence, candidate) {
    const lobby = this.lobbies.get(this.clientLobby.get(clientId));
    const member = lobby?.members.get(clientId);
    if (!lobby || !member) return failure("not-in-lobby", "Join a lobby first.");
    if (member.role === "spectator") {
      return failure("spectator-read-only", "Spectators cannot send gameplay input.");
    }
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
    if (member?.role === "spectator") {
      return failure("spectator-read-only", "Spectators do not select active agents.");
    }
    if (!member || !entity) return failure("not-in-lobby", "Join a lobby first.");
    if (!lobby.state.rules?.freeplay && entity.alive && lobby.state.status === "playing") {
      return failure("in-progress", "Change agent after an elimination or rematch.");
    }
    const agent = getCharacter(characterId);
    const result = configureMatchPlayer(lobby.state, entity.id, {
      characterId: agent.id,
      raceId: member.raceId,
      restore: true,
    });
    if (!result.ok) return failure("invalid-agent", result.errors.join("; "));
    syncMemberFromEntity(member, entity);
    this.broadcastSnapshots(lobby, true);
    return success(result);
  }

  changeLoadout(clientId, candidate = {}) {
    const lobby = this.lobbies.get(this.clientLobby.get(clientId));
    const member = lobby?.members.get(clientId);
    const entity = lobby?.state.entities.find((entry) => entry.id === member?.entityId);
    if (member?.role === "spectator") {
      return failure("spectator-read-only", "Spectators do not select active loadouts.");
    }
    if (!lobby || !member || !entity) return failure("not-in-lobby", "Join a lobby first.");
    if (!lobby.state.rules?.freeplay && entity.alive && lobby.state.status === "playing") {
      return failure("in-progress", "Change loadout after an elimination or rematch.");
    }
    const result = configureMatchPlayer(lobby.state, entity.id, {
      characterId: candidate.characterId ?? member.characterId,
      raceId: candidate.raceId ?? member.raceId,
      activeAbilityIds: normalizeAbilityIds(candidate.activeAbilityIds),
      ultimateAbilityId: normalizeAbilityId(candidate.ultimateAbilityId),
      restore: lobby.state.rules?.freeplay === true,
    });
    if (!result.ok) return failure("invalid-loadout", result.errors.join("; "));
    syncMemberFromEntity(member, entity);
    this.broadcastSnapshots(lobby, true);
    return success(result);
  }

  configureFreeplay(clientId, candidate = {}) {
    const lobby = this.lobbies.get(this.clientLobby.get(clientId));
    if (!lobby) return failure("not-in-lobby", "Join a lobby first.");
    if (lobby.hostId !== clientId) return failure("host-only", "Only the host changes shared freeplay rules.");
    if (!lobby.state.rules?.freeplay) return failure("wrong-mode", "This lobby is not freeplay.");
    if (!setFreeplaySettings(lobby.state, candidate)) return failure("invalid-settings", "Freeplay settings rejected.");
    this.broadcastSnapshots(lobby, true);
    return success({ settings: { ...lobby.state.rules.freeplaySettings } });
  }

  runFreeplayAction(clientId, action, options = {}) {
    const lobby = this.lobbies.get(this.clientLobby.get(clientId));
    if (!lobby) return failure("not-in-lobby", "Join a lobby first.");
    if (lobby.hostId !== clientId) return failure("host-only", "Only the host changes the shared sanctuary.");
    if (!applyFreeplayAction(lobby.state, cleanText(action, "", 32), options)) {
      return failure("invalid-action", "Freeplay action rejected.");
    }
    this.broadcastSnapshots(lobby, true);
    return success({ action });
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
    for (const lobby of [...this.lobbies.values()]) {
      for (const [clientId, member] of [...lobby.members.entries()]) {
        if (
          !member.connected &&
          member.disconnectedAt !== null &&
          this.now() - member.disconnectedAt > RECONNECT_GRACE_MS
        ) {
          this.removeMember(lobby, clientId, "expired");
        }
      }
      if (!this.lobbies.has(lobby.code)) continue;
      const commands = {};
      for (const member of lobby.members.values()) {
        if (member.role === "spectator" || !member.connected) continue;
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
      players: playerCount(lobby),
      connectedPlayers: connectedPlayerCount(lobby),
      spectators: spectatorCount(lobby),
      maxPlayers: lobby.maxPlayers,
      teamSize: lobby.teamSize,
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
      if (!member.connected) continue;
      member.send({
        type: "snapshot",
        immediate,
        ...createNetworkSnapshot(lobby, member),
      });
    }
  }

  broadcast(lobby, message) {
    for (const member of lobby.members.values()) {
      if (member.connected) member.send(message);
    }
  }

  restartLobby(lobby, members) {
    const oldState = lobby.state;
    const players = members.filter((member) => member.role === "player");
    const playerSpecs = players.map((member, index) => ({
      id: member.entityId ?? `remote-${shortId(member.clientId)}`,
      clientId: member.clientId,
      name: member.name,
      characterId: member.characterId,
      raceId: member.raceId,
      activeAbilityIds: member.activeAbilityIds,
      ultimateAbilityId: member.ultimateAbilityId,
      team: teamForIndex(oldState.modeId, index, lobby.teamSize),
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
      hazardsEnabled: oldState.rules?.hazardsEnabled !== false,
      freeplaySettings: oldState.rules?.freeplaySettings,
    });
    for (const member of players) {
      const entity = lobby.state.entities.find(
        (candidate) => candidate.clientId === member.clientId,
      );
      member.entityId = entity?.id ?? member.entityId;
      if (entity) syncMemberFromEntity(member, entity);
      member.command = sanitizeCommand({});
      member.lastSequence = -1;
    }
  }

  migrateHost(lobby, previousHostId) {
    const replacement = [...lobby.members.values()].find(
      (member) => member.role === "player" && member.connected,
    );
    if (!replacement) return;
    lobby.hostId = replacement.clientId;
    this.broadcast(lobby, {
      type: "host-migrated",
      previousHostId,
      hostId: lobby.hostId,
    });
  }

  removeMember(lobby, clientId, action) {
    const member = lobby.members.get(clientId);
    if (!member) return false;
    lobby.members.delete(clientId);
    this.clientLobby.delete(clientId);
    this.clientRate.delete(clientId);
    if (member.entityId) removeMatchPlayer(lobby.state, member.entityId);
    if (lobby.members.size === 0) {
      this.lobbies.delete(lobby.code);
      return true;
    }
    if (playerCount(lobby) === 0) {
      this.broadcast(lobby, {
        type: "lobby-closed",
        reason: "No active or reserved players remain.",
      });
      for (const remainingId of lobby.members.keys()) {
        this.clientLobby.delete(remainingId);
        this.clientRate.delete(remainingId);
      }
      this.lobbies.delete(lobby.code);
      return true;
    }
    if (lobby.hostId === clientId) this.migrateHost(lobby, clientId);
    this.broadcast(lobby, {
      type: "presence",
      action,
      name: member.name,
      players: playerCount(lobby),
      spectators: spectatorCount(lobby),
    });
    return true;
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

function normalizeMember(
  clientId,
  candidate,
  send,
  reconnectToken,
  role = "player",
) {
  return {
    clientId,
    entityId: null,
    role,
    name: cleanText(candidate.playerName ?? candidate.name, "PLAYER", 20),
    characterId: getCharacter(candidate.characterId).id,
    raceId: getRace(candidate.raceId).id,
    activeAbilityIds: normalizeAbilityIds(candidate.activeAbilityIds),
    ultimateAbilityId: normalizeAbilityId(candidate.ultimateAbilityId),
    reconnectToken,
    connected: true,
    disconnectedAt: null,
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
      players: playerCount(lobby),
      spectators: spectatorCount(lobby),
      maxPlayers: lobby.maxPlayers,
      teamSize: lobby.teamSize,
    },
    serverTick: lobby.networkTick,
    acknowledgedSequence: member.lastSequence,
    entityId: member.entityId,
    state: lobby.state,
  };
}

function normalizeAbilityIds(candidate) {
  if (!Array.isArray(candidate)) return undefined;
  return candidate
    .map((value) => normalizeAbilityId(value))
    .filter(Boolean)
    .slice(0, 3);
}

function normalizeAbilityId(candidate) {
  const value = String(candidate ?? "").trim().toLowerCase();
  return /^[a-z0-9-]{1,40}$/.test(value) ? value : undefined;
}

function teamForIndex(modeId, index, teamSize = 1) {
  if (modeId === "survival") return "alpha";
  if (modeId === "battle_royale") {
    return `squad-${Math.floor(index / Math.max(1, teamSize)) + 1}`;
  }
  return index % 2 === 0 ? "alpha" : "beta";
}

function syncMemberFromEntity(member, entity) {
  member.characterId = entity.characterId;
  member.raceId = entity.raceId;
  member.activeAbilityIds = [...(entity.activeAbilityIds ?? [])];
  member.ultimateAbilityId = entity.ultimateAbilityId ?? null;
}

function createLobbyCode() {
  const bytes = randomBytes(6);
  let code = "";
  for (const byte of bytes) code += LOBBY_CODE_ALPHABET[byte % LOBBY_CODE_ALPHABET.length];
  return code;
}

function createReconnectToken() {
  return randomBytes(24).toString("base64url");
}

function playerCount(lobby) {
  return [...lobby.members.values()].filter((member) => member.role === "player")
    .length;
}

function connectedPlayerCount(lobby) {
  return [...lobby.members.values()].filter(
    (member) => member.role === "player" && member.connected,
  ).length;
}

function spectatorCount(lobby) {
  return [...lobby.members.values()].filter(
    (member) => member.role === "spectator" && member.connected,
  ).length;
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
