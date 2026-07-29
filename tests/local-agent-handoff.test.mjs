import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const read = (path) => readFile(new URL(`../${path}`, import.meta.url), "utf8");

test("local-agent handoff is portable and safe by default", async () => {
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
  assert.match(config, /^auto-commits: false$/m);
  assert.match(config, /^yes-always: false$/m);
  assert.match(common, /main \| master \| develop/);
  assert.match(launcher, /commit_changes=false/);
  assert.match(launcher, /push_changes=false/);
  assert.match(setup, /install=false/);
  assert.match(setup, /--install/);
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
