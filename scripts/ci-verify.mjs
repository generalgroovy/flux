import { mkdirSync, writeFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import process from "node:process";

const label = `${process.platform}-node${process.versions.node.split(".")[0]}`;
const lines = [`CI ${label}`];
let failed = false;

function run(name, command, args) {
  const result = spawnSync(command, args, {
    encoding: "utf8",
    shell: process.platform === "win32",
    env: process.env,
  });
  lines.push(`\n## ${name}\nexit=${result.status ?? "null"}`);
  if (result.stdout) lines.push(result.stdout.trim());
  if (result.stderr) lines.push(`STDERR\n${result.stderr.trim()}`);
  if (result.error) lines.push(`ERROR\n${result.error.stack ?? result.error.message}`);
  if (result.status !== 0) failed = true;
}

run("npm test", "npm", ["test"]);
for (const file of [
  "src/content.mjs",
  "src/overhaul-content.mjs",
  "src/match.mjs",
  "src/game.mjs",
  "src/network/lobbies.mjs",
  "scripts/serve.mjs",
]) {
  run(`node --check ${file}`, process.execPath, ["--check", file]);
}

mkdirSync("ci-results", { recursive: true });
const output = lines.join("\n").slice(-120_000);
writeFileSync(`ci-results/${label}.log`, output);
console.log(output.slice(-8_000));
process.exitCode = failed ? 1 : 0;
