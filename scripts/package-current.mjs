import { execFileSync, spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { createReadStream, mkdirSync, readdirSync, statSync, writeFileSync } from "node:fs";
import { basename, dirname, relative, resolve } from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const requested = process.argv.find((entry) => entry.startsWith("--platform="))?.split("=")[1];
const platform = requested ?? (process.platform === "win32" ? "windows" : "linux");
if (!new Set(["windows", "linux"]).has(platform)) throw new Error("Use --platform=windows or --platform=linux");
if ((platform === "windows") !== (process.platform === "win32")) throw new Error(`Build ${platform} packages on a ${platform} host`);

function git(args) {
  return execFileSync("git", args, { cwd: root, encoding: "utf8", stdio: ["ignore", "pipe", "inherit"] }).trim();
}

if (git(["status", "--porcelain"])) throw new Error("Refusing to package a dirty worktree");

const startedAt = Date.now();
const npmArgs = ["run", platform === "windows" ? "dist:windows" : "dist:linux"];
const result = process.platform === "win32"
  ? spawnSync(process.env.ComSpec ?? "cmd.exe", ["/d", "/s", "/c", `npm.cmd ${npmArgs.join(" ")}`], { cwd: root, stdio: "inherit" })
  : spawnSync("npm", npmArgs, { cwd: root, stdio: "inherit" });
if (result.error) throw result.error;
if (result.status !== 0) process.exit(result.status ?? 1);

const dist = resolve(root, "dist");
const artifactPattern = platform === "windows" ? /-win-[^.]+\.exe$/i : /\.AppImage$/;
const artifacts = readdirSync(dist)
  .map((name) => resolve(dist, name))
  .filter((path) => statSync(path).isFile() && artifactPattern.test(basename(path)) && statSync(path).mtimeMs >= startedAt - 2000);
if (artifacts.length === 0) throw new Error(`No fresh ${platform} installer was produced`);

async function sha256(path) {
  const hash = createHash("sha256");
  for await (const chunk of createReadStream(path)) hash.update(chunk);
  return hash.digest("hex");
}

const manifest = {
  schema: 1,
  builtAt: new Date().toISOString(),
  platform,
  branch: git(["branch", "--show-current"]),
  commit: git(["rev-parse", "HEAD"]),
  node: process.version,
  artifacts: [],
};
for (const path of artifacts) {
  manifest.artifacts.push({
    path: relative(root, path).replaceAll("\\", "/"),
    bytes: statSync(path).size,
    sha256: await sha256(path),
  });
}

mkdirSync(dist, { recursive: true });
writeFileSync(resolve(dist, "build-manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`);
console.log(`Verified package manifest written for ${manifest.commit}:`);
for (const artifact of manifest.artifacts) console.log(`- ${artifact.path} (${artifact.sha256})`);
