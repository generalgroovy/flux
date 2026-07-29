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

test("local agent freezes mechanics and follows the visual overhaul order", async () => {
  const [agents, visual, task, backlog, launcher] = await Promise.all([
    read("AGENTS.md"),
    read(".agent/VISUAL-OVERHAUL.md"),
    read(".agent/odysseus-task.md"),
    read(".agent/backlog.md"),
    read("scripts/local-agent.sh"),
  ]);
  const contract = [agents, visual, task, backlog].join("\n");

  assert.match(contract, /mechanics (?:are )?frozen/i);
  assert.match(task, /V0 visual tokens\/specimen ->\s*V1 characters -> V2 spells -> V3 maps -> V4 GUI -> V5 integrated acceptance/);
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
  assert.match(task, /take \*\*Steezo\*\* as the next single V1\s+slice/);
  assert.match(task, /Keep Steezo source-only until an actual\s+Garuda visual review/);
});
