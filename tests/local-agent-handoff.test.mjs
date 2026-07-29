import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const read = (path) => readFile(new URL(`../${path}`, import.meta.url), "utf8");

test("local-agent handoff is portable, autonomous, and local-model only", async () => {
  const [config, handoff, prompt, common, launcher, setup, odysseus, state] = await Promise.all([
    read(".aider.conf.yml"),
    read(".agent/HANDOFF.md"),
    read(".agent/ODYSSEUS_PROMPT.md"),
    read("scripts/local-agent-common.sh"),
    read("scripts/local-agent.sh"),
    read("scripts/setup-local-agent-linux.sh"),
    read("scripts/prepare-odysseus-handoff.sh"),
    read(".odysseus/STATE.md"),
  ]);
  const trackedHandoff = [config, handoff, prompt, common, launcher, setup, odysseus, state].join("\n");

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
