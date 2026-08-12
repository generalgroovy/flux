import test from "node:test";
import assert from "node:assert/strict";

import { cloudflaredAssetName, selectVerifiedAsset } from "../desktop/tunnel.mjs";

test("friend tunnel selects explicit Linux and Windows release assets", () => {
  assert.equal(cloudflaredAssetName("linux", "x64"), "cloudflared-linux-amd64");
  assert.equal(cloudflaredAssetName("linux", "arm64"), "cloudflared-linux-arm64");
  assert.equal(cloudflaredAssetName("win32", "x64"), "cloudflared-windows-amd64.exe");
  assert.throws(() => cloudflaredAssetName("darwin", "x64"), /not yet packaged/);
  assert.throws(() => cloudflaredAssetName("linux", "ia32"), /not yet packaged/);
});

test("friend tunnel requires an official SHA-256 release digest", () => {
  const digest = "a".repeat(64);
  const selected = selectVerifiedAsset({
    tag_name: "2026.7.3",
    assets: [{
      name: "cloudflared-linux-amd64",
      browser_download_url: "https://github.com/cloudflare/cloudflared/releases/download/example",
      digest: `sha256:${digest}`,
    }],
  }, "cloudflared-linux-amd64");
  assert.deepEqual(selected, {
    tag: "2026.7.3",
    url: "https://github.com/cloudflare/cloudflared/releases/download/example",
    digest,
  });
  assert.throws(
    () => selectVerifiedAsset({ tag_name: "latest", assets: [] }, "cloudflared-linux-amd64"),
    /lacks a verified/,
  );
});
