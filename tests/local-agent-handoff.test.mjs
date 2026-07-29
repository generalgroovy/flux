import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const read = (path) => readFile(new URL(`../${path}`, import.meta.url), "utf8");

test("local-agent handoff is portable, autonomous, and local-model only", async () => {
  const [config, handoff, prompt, common, launcher, dispatcher, setup, odysseus, state] = await Promise.all([
    read(".aider.conf.yml"),
    read(".agent/HANDOFF.md"),
    read(".agent/ODYSSEUS_PROMPT.md"),
    read("scripts/local-agent-common.sh"),
    read("scripts/local-agent.sh"),
    read("scripts/linux-agent-handoff.sh"),
    read("scripts/setup-local-agent-linux.sh"),
    read("scripts/prepare-odysseus-handoff.sh"),
    read(".odysseus/STATE.md"),
  ]);
  const trackedHandoff = [config, handoff, prompt, common, launcher, dispatcher, setup, odysseus, state].join("\n");

  assert.doesNotMatch(trackedHandoff, /\/home\/otp\/Projects\/flux/);
  assert.doesNotMatch(trackedHandoff, /agent\/prototype-loop/);
  assert.doesNotMatch(trackedHandoff, /qwen2\.5-coder:7b-instruct/);
  assert.match(config, /^auto-commits: true$/m);
  assert.match(config, /^yes-always: true$/m);
  assert.match(config, /^analytics-disable: true$/m);
  assert.match(config, /^check-update: false$/m);
  assert.match(common, /main \| master \| develop/);
  assert.match(common, /Only a loopback Ollama endpoint is allowed/);
  assert.match(common, /GIT_ALLOW_PROTOCOL=file/);
  assert.match(common, /npm_config_offline=true/);
  assert.match(launcher, /commit_changes=true/);
  assert.match(launcher, /--yes-always/);
  assert.match(launcher, /--auto-commits/);
  assert.match(launcher, /--show-diffs/);
  assert.match(launcher, /--llm-history-file/);
  assert.match(launcher, /manifest\.txt/);
  assert.match(launcher, /final-state\.txt/);
  assert.match(launcher, /committed-changes\.patch/);
  assert.match(launcher, /session\.log/);
  assert.match(launcher, /events\.tsv/);
  assert.match(launcher, /command_name.*logs/);
  assert.doesNotMatch(launcher, /git push/);
  assert.match(dispatcher, /local-agent\.sh.*chat/);
  assert.match(dispatcher, /local-agent\.sh.*run/);
  assert.match(dispatcher, /prepare-odysseus-handoff\.sh/);
  assert.match(dispatcher, /WAYLAND_DISPLAY/);
  assert.match(dispatcher, /SWAYSOCK/);
  assert.doesNotMatch(dispatcher, /git (?:pull|push|fetch)/);
  assert.match(setup, /install=false/);
  assert.match(setup, /--install/);
  assert.match(setup, /--noconfirm/);
  assert.match(odysseus, /wl-copy/);
  assert.doesNotMatch(odysseus, /git push/);
});

test("local-agent handoff supports only the approved Qwen profiles", async () => {
  const [common, settings, docs] = await Promise.all([
    read("scripts/local-agent-common.sh"),
    read(".aider.model.settings.yml"),
    read(".agent/LOCAL-MODEL-HANDOFF.md"),
  ]);

  for (const size of ["3b", "7b"]) {
    assert.match(common, new RegExp(`qwen2\\.5-coder:${size}`));
    assert.match(settings, new RegExp(`ollama_chat/qwen2\\.5-coder:${size}`));
    assert.match(docs, new RegExp(`qwen2\\.5-coder:${size}`));
  }
  assert.match(settings, /num_ctx: 16384/g);
  assert.match(common, /Unsupported model/);
});

test("local agent follows the pixel perspective, movement, then character order", async () => {
  const [agents, visual, perspective, movement, task, backlog, launcher] = await Promise.all([
    read("AGENTS.md"),
    read(".agent/VISUAL-OVERHAUL.md"),
    read(".agent/PIXEL-PERSPECTIVE-OVERHAUL.md"),
    read(".agent/MOVEMENT-INPUT-OVERHAUL.md"),
    read(".agent/odysseus-task.md"),
    read(".agent/backlog.md"),
    read("scripts/local-agent.sh"),
  ]);
  const contract = [agents, visual, perspective, movement, task, backlog].join("\n");

  assert.match(contract, /mechanics (?:are )?frozen/i);
  assert.match(task, /PIXEL-PERSPECTIVE-OVERHAUL\.md` P0-P5, then\s+`\.agent\/MOVEMENT-INPUT-OVERHAUL\.md` M0-M5, then resume V1/);
  assert.match(visual, /Do not reproduce or closely imitate/);
  assert.match(visual, /do not add or rebalance movement,/i);
  assert.match(visual, /approved future characters receive concepts only and remain inactive/i);
  assert.match(visual, /twenty-three named champions plus one explicitly temporary Angel placeholder/i);
  for (const [champion, ancestry, emphasized] of [
    ["Spai Si", "Demon", true],
    ["Fluup", "Orc", false],
    ["Oll' I", "Werewolf", true],
    ["The Red Baron", "Undead", false],
    ["Djonah Thaan", "Vampire", true],
    ["Hesus Christo", "Elf", true],
  ]) {
    const display = emphasized ? `\\*\\*${ancestry}\\*\\*` : ancestry;
    assert.match(visual, new RegExp(`\\| ${champion.replace(".", "\\.")} \\| ${display} \\|`));
  }
  assert.match(visual, /\| Unnamed Angel \(placeholder\) \| \*\*Angel\*\* \|/);
  assert.match(visual, /Runtime `raceId` values remain\s+unchanged until V1/i);
  assert.match(launcher, /--read \.agent\/VISUAL-OVERHAUL\.md/);
  assert.match(task, /P0 is accepted; the current slice is \*\*P1 only\*\*/);
  assert.match(task, /Do not begin Nico,\s+spell, GUI, movement, input, tap-strafe, or Steezo work/);
  assert.match(task, /Keep Sanctum geometry,\s+collisions, station triggers, spawn, movement, remote company/i);
  assert.match(perspective, /Ground anchor/);
  assert.match(perspective, /Do not start Steezo or another champion until P0-P5 are accepted/);
  assert.match(movement, /shadow grows wider and slightly\s+darker toward the apex/);
  assert.match(movement, /can never add\s+velocity/);
  assert.match(launcher, /--read \.agent\/PIXEL-PERSPECTIVE-OVERHAUL\.md/);
  assert.match(launcher, /--read \.agent\/MOVEMENT-INPUT-OVERHAUL\.md/);
});
