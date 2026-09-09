# Windows follow-up delivery evidence

Status: local Windows delivery candidate verified, 2026-09-09; no publication,
actual user installation, signing or human acceptance.

This bounded slice repackages only the exact QV runtime EXE/PCK recorded in
`docs/evidence/qv-runtime-v1/checkpoint.json`. The nine recorded source hashes
and both payload hashes matched before building. The embedded PCK's runtime
report executed outside the checkout and matched the current source catalog
report before a new BUILD-STATE was embedded. A separate no-write PCK probe
verified Technique V / Evade Q, preferences schema11 and keyboard revision1.

## Runnable artifacts

New output, preserving all prior exports:

| Artifact | Bytes | SHA256 |
|---|---:|---|
| `exports/windows-followup-p47-20260909/release/FLUX.exe` |96,787,968 |`4bd03fd6ee50d7161b445bc03e2c8e99477b366a44b63f8fadba084ce31b5121` |
| `exports/windows-followup-p47-20260909/release/FLUX2-Windows-x86_64.zip` |96,762,699 |`a4fca5fa645f856a069f500a787e3767460fc2565a864f5a51b7a87fd0e78389` |

Embedded version: `0.1.0-dev-a1aa028076-a4fca5fa64`. The payload hash
distinguishes this dirty-source checkpoint from other builds sharing that HEAD.
The packaged PCK remains66,211,176 bytes, SHA256
`9d8cc66320a73c3f544c70489f443709807d84128a12b82d5fa322d07869e967`.

Player workflow: open the new FLUX.exe to install/update and play, or extract
the entire portable ZIP and open PLAY-FLUX.cmd. A supplied newer installer is
the offline update mechanism. Close any running game normally before updating.
Keep all portable files together and use the same build on every peer.

This is a fresh installer/archive of the accepted QV payload, not a new engine
export. The inherited source gate was Full91 suites /463,294 assertions, zero
failures/stderr. Full was not rerun for this packaging-only slice. No source,
simulation, launcher or shared packaging-script changes were needed.

## Executed acceptance

[Installer receipt](installer-journey-receipt.json) records all16 stages passing,
including the expected negative refusal exits. Its original absolute scratch
paths are preserved; matching log basenames are durable under `logs/`.

| Gate | Evidence |
|---|---|
| Source/payload identity |`build-logs/runtime-source.log`, `build-logs/runtime-pack.log`, [BUILD-STATE.json](BUILD-STATE.json) |
| Fresh defaults inside actual PCK |`build-logs/pack-defaults.log`; Technique V, Evade Q, schema11/revision1 |
| Clean install and healthy reuse |Stages00-03 in an isolated path with spaces; stored launcher infers the same root |
| Actual corruption repair |Stage04 flips a byte in only the test PCK; stage05 empties only the test manifest; both select newly verified immutable folders and retain previous folders |
| Refusal safety |Empty install-root exit2; unowned nonempty root exit1 with unchanged sentinel |
| Real historical update |Stages09-11 install the receipt-matched hardened September8 installer, then this candidate; distinct prior version retained |
| Native argument integrity |20 compiled formatter / Windows CommandLineToArgvW assertions, including spaces, empty values, quotes and backslashes |
| Installed content |Stage14 executes the actual installed PCK: protocol47, snapshot18, preferences11,120Hz,8-player capacity,27 champions,57 spells,12 positions,36 reactions |
| Installed launch |Stage15 uses the copied FLUX.exe to start the release game for3 headless frames; complete120Hz/protocol47 bootstrap, zero warnings/errors, no remaining test game process |
| Isolated saved defaults |The release boot writes only test-root preferences: Technique86(V), Evade81(Q), schema11, revision1, sound30 |
| User-data protection |[Guard](user-data-guard.json) compares existence, bytes, SHA256 and UTC mtime before/after on six exact live settings/install-pointer/launcher/marker/shortcut paths; all unchanged |

Successful child-process stderr is empty. The two refusal stages intentionally
emit33 and225 bytes of diagnostic stderr. The argv stage executes in-process,
so it has a stage receipt but no separate subprocess stream. Logs, BUILD-STATE,
checksums and the guard are hash-bound in [manifest.json](manifest.json).

All installation tests use isolated owned roots, quiet mode and no shortcuts.
The actual installed game, live settings and prior exports are not update targets.
The genuine hardened September8 installer is the distinct update baseline;
no synthetic marker fixture is presented as historical delivery. Its installer
and ZIP still match their original receipt hashes after the test. Large test
installations remain under `.godot/bootstrap-test/run 633592f8222244fba64875b4629d1378`
for inspection; no cleanup or pruning was performed.

## Boundaries still open

The source launcher's nonempty-import-cache shortcut remains an independently
recorded limitation. This self-contained exported payload does not use that
source-launch path. No source-readiness fix, new art promotion, public release,
trusted signing, automatic online updating, physical two-PC acceptance or human
gameplay acceptance is implied by this evidence.

Previous-version retention is tested, not automatic rollback or a rollback UI.
Real Desktop/Start Menu creation, fresh-PC trust policy, interactive window-close
behavior, human sound/visual comfort, internet connectivity and sustained120FPS
are not certified by this isolated headless journey. The installer is unsigned;
do not bypass an operating-system or organizational execution refusal.

The owned `exports/windows-followup-p47-20260909/build-verified-delivery.ps1`
records the exact checkpoint-verifying bundle/build/test invocation and refuses
to overwrite an existing release. Its `verify-pack-defaults.gd` helper performs
no save or gameplay mutation. Root runtime/art research remains separate unless
it is explicitly promoted into a later verified source export.
