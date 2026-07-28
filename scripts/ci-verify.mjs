import { mkdirSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { spawnSync } from "node:child_process";
import process from "node:process";

const label = `${process.platform}-node${process.versions.node.split(".")[0]}`;
const lines = [`CI ${label}`];
let failed = false;

function run(name, command, args) {
  const result = spawnSync(command, args, {
    encoding: "utf8",
    env: process.env,
  });
  lines.push(`\n## ${name}\nexit=${result.status ?? "null"}`);
  if (result.stdout) lines.push(result.stdout.trim());
  if (result.stderr) lines.push(`STDERR\n${result.stderr.trim()}`);
  if (result.error) lines.push(`ERROR\n${result.error.stack ?? result.error.message}`);
  if (result.status !== 0) failed = true;
}

function moduleFiles(directory) {
  const files = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) files.push(...moduleFiles(path));
    else if (entry.isFile() && entry.name.endsWith(".mjs")) files.push(path);
  }
  return files;
}

if (process.platform === "win32") {
  run("npm test", process.env.ComSpec ?? "cmd.exe", ["/d", "/s", "/c", "npm.cmd test"]);
} else {
  run("npm test", "npm", ["test"]);
}
for (const file of ["desktop", "scripts", "src", "tests"].flatMap(moduleFiles).sort()) {
  run(`node --check ${file}`, process.execPath, ["--check", file]);
}

mkdirSync("ci-results", { recursive: true });
const output = lines.join("\n").slice(-160_000);
writeFileSync(`ci-results/${label}.log`, output);
console.log(output.slice(-12_000));
process.exitCode = failed ? 1 : 0;
