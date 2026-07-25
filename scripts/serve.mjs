import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { extname, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(fileURLToPath(new URL("../", import.meta.url)));
const port = Number.parseInt(process.env.PORT ?? "8000", 10);
const contentTypes = new Map([
  [".css", "text/css; charset=utf-8"],
  [".html", "text/html; charset=utf-8"],
  [".js", "text/javascript; charset=utf-8"],
  [".mjs", "text/javascript; charset=utf-8"],
  [".svg", "image/svg+xml"],
]);

if (!Number.isInteger(port) || port < 1 || port > 65535) {
  throw new RangeError(`PORT must be an integer from 1 to 65535; received ${port}`);
}

const server = createServer(async (request, response) => {
  try {
    const url = new URL(request.url ?? "/", "http://localhost");
    const pathname = decodeURIComponent(url.pathname);
    const requestedPath = pathname === "/" ? "/index.html" : pathname;
    const filePath = resolve(root, `.${requestedPath}`);
    const insideRoot = filePath === root || filePath.startsWith(`${root}${sep}`);

    if (!insideRoot) {
      respond(response, 403, "Forbidden");
      return;
    }

    const content = await readFile(filePath);
    response.writeHead(200, {
      "Cache-Control": "no-store",
      "Content-Type": contentTypes.get(extname(filePath)) ?? "application/octet-stream",
    });
    response.end(content);
  } catch (error) {
    if (error instanceof URIError) {
      respond(response, 400, "Bad request");
      return;
    }
    if (error?.code === "ENOENT" || error?.code === "EISDIR") {
      respond(response, 404, "Not found");
      return;
    }

    console.error("Static server request failed:", error);
    respond(response, 500, "Internal server error");
  }
});

server.listen(port, "127.0.0.1", () => {
  console.log(`Outskilled is running at http://127.0.0.1:${port}`);
});

function respond(response, status, message) {
  response.writeHead(status, { "Content-Type": "text/plain; charset=utf-8" });
  response.end(message);
}
