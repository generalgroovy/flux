export function remoteServerFromHint(candidate) {
  try {
    const server = new URL(candidate);
    return server.protocol === "https:" ? server.origin : null;
  } catch {
    return null;
  }
}

export function createLobbyInvite(serverBase, lobbyCode, { desktop = false } = {}) {
  const server = new URL(serverBase);
  const code = String(lobbyCode).trim().toUpperCase();
  if (!["http:", "https:"].includes(server.protocol) || !/^[A-Z2-9]{6}$/.test(code)) {
    throw new Error("Cannot create an invite from an invalid server or lobby code.");
  }
  if (desktop && server.protocol === "https:") {
    const invite = new URL("flux://join");
    invite.searchParams.set("server", server.origin);
    invite.searchParams.set("code", code);
    return invite.href;
  }
  const invite = new URL("/", server.origin);
  invite.searchParams.set("join", code);
  return invite.href;
}
