import { createServer } from "node:net";

export async function reserveLoopbackPort() {
  const server = createServer();
  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", resolve);
  });
  const address = server.address();
  const port = typeof address === "object" && address ? address.port : 0;
  await new Promise((resolve, reject) => {
    server.close((error) => (error ? reject(error) : resolve()));
  });
  if (!Number.isInteger(port) || port < 1) {
    throw new Error("Could not reserve a local FLUX authority port.");
  }
  return port;
}

export async function waitForFlux(origin, {
  attempts = 100,
  delayMs = 50,
  fetchImpl = globalThis.fetch,
  desktopToken = null,
} = {}) {
  for (let attempt = 0; attempt < attempts; attempt += 1) {
    try {
      const response = await fetchImpl(`${origin}/__flux_health`);
      const health = await response.json();
      if (
        response.ok &&
        health.product === "FLUX" &&
        health.status === "ready" &&
        health.protocol === 2 &&
        (!desktopToken || health.desktopToken === desktopToken)
      ) {
        return health;
      }
    } catch {
      // The authority process may still be binding its socket.
    }
    await new Promise((resolve) => setTimeout(resolve, delayMs));
  }
  throw new Error(`FLUX authority did not become ready at ${origin}.`);
}

export function isTrustedGameUrl(candidate, gameOrigin) {
  try {
    const url = new URL(candidate);
    const origin = new URL(gameOrigin);
    return (
      url.origin === origin.origin &&
      (url.protocol === "http:" || url.protocol === "https:")
    );
  } catch {
    return false;
  }
}

export function desktopGameUrl(origin, {
  friends = false,
  publicOrigin = null,
  invite = null,
} = {}) {
  const url = new URL("/", origin);
  url.searchParams.set("desktop", "1");
  if (friends) {
    url.searchParams.set("friends", "1");
    if (publicOrigin) url.searchParams.set("server", new URL(publicOrigin).origin);
  }
  if (invite) {
    url.searchParams.set("join", invite.code);
    url.searchParams.set("server", invite.server);
  }
  return url.href;
}

export function parseDesktopInvite(argumentsList) {
  for (const argument of argumentsList) {
    if (typeof argument !== "string" || !argument.toLowerCase().startsWith("flux://")) continue;
    try {
      const invite = new URL(argument);
      const server = new URL(invite.searchParams.get("server") ?? "");
      const code = (invite.searchParams.get("code") ?? "").trim().toUpperCase();
      if (
        invite.hostname !== "join" ||
        server.protocol !== "https:" ||
        !/^[A-Z2-9]{6}$/.test(code)
      ) {
        continue;
      }
      return { server: server.origin, code };
    } catch {
      // Ignore unrelated or malformed process arguments.
    }
  }
  return null;
}
