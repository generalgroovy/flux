import { execFileSync } from "node:child_process";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const manifestPath = resolve(root, ".agent", "unification-manifest.json");
const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
const allowDirty = process.argv.includes("--allow-dirty");
const noFetch = process.argv.includes("--no-fetch");
const phase = process.argv.find((entry) => entry.startsWith("--phase="))?.split("=")[1] ?? "cleanup";
if (!new Set(["launch", "cleanup"]).has(phase)) throw new Error("Use --phase=launch or --phase=cleanup");
const checks = [];

function git(args, options = {}) {
  return execFileSync("git", args, {
    cwd: root,
    encoding: "utf8",
    stdio: ["ignore", "pipe", options.quiet ? "pipe" : "inherit"],
  }).trim();
}

function record(name, passed, detail, blocking = true) {
  checks.push({ name, passed, blocking, detail });
  console.log(`${passed ? "PASS" : blocking ? "FAIL" : "WARN"} ${name}: ${detail}`);
}

function remoteTagCommit(tag) {
  try {
    const output = git(["ls-remote", "origin", `refs/tags/${tag}^{}`], { quiet: true });
    return output.split(/\s+/)[0] || null;
  } catch {
    return null;
  }
}

if (!noFetch) git(["fetch", "origin", "--prune", "--tags"]);

const branch = git(["branch", "--show-current"], { quiet: true });
const allowedBranches = new Set([manifest.integrationBranch, manifest.targetBranch]);
record("integration branch", allowedBranches.has(branch), branch || "detached HEAD");

const status = git(["status", "--porcelain"], { quiet: true });
record("clean worktree", allowDirty || status.length === 0, status.length === 0 ? "clean" : allowDirty ? "dirty (explicitly allowed)" : "uncommitted changes present");

let mainIsAncestor = false;
try {
  execFileSync("git", ["merge-base", "--is-ancestor", "origin/main", "HEAD"], { cwd: root, stdio: "ignore" });
  mainIsAncestor = true;
} catch {
  mainIsAncestor = false;
}
record("main ancestry", mainIsAncestor, mainIsAncestor ? "origin/main is an ancestor of HEAD" : "HEAD does not contain origin/main");

for (const candidate of manifest.cleanupCandidates) {
  const cleanupBlocking = phase === "cleanup";
  let remoteHead = null;
  try {
    remoteHead = git(["rev-parse", `refs/remotes/origin/${candidate.branch}`], { quiet: true });
  } catch {
    remoteHead = null;
  }
  record(`${candidate.branch} expected head`, remoteHead === candidate.expectedHead, remoteHead ?? "remote branch missing", cleanupBlocking);

  const archivedHead = remoteTagCommit(candidate.archiveTag);
  record(`${candidate.branch} remote archive`, archivedHead === remoteHead && remoteHead !== null, archivedHead ?? "pushed archive tag missing", cleanupBlocking);
}

const report = {
  generatedAt: new Date().toISOString(),
  repository: manifest.repository,
  phase,
  branch,
  head: git(["rev-parse", "HEAD"], { quiet: true }),
  passed: checks.every((entry) => entry.passed || !entry.blocking),
  checks,
  cleanupCandidates: manifest.cleanupCandidates.map(({ branch: name, archiveTag, pullRequest, classification }) => ({ name, archiveTag, pullRequest, classification })),
};

mkdirSync(resolve(root, "ci-results"), { recursive: true });
writeFileSync(resolve(root, "ci-results", "unification-preflight.json"), `${JSON.stringify(report, null, 2)}\n`);

if (!report.passed) {
  console.error(`\n${phase} preflight failed. Re-audit and archive every moved branch before cleanup.`);
  process.exitCode = 1;
} else {
  console.log(`\n${phase} preflight passed. ${phase === "launch" ? "Remote drift is reported but cleanup remains prohibited." : "This proves recovery coverage only; it does not authorize deletion or a main merge."}`);
}
