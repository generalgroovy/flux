# Windows delivery evidence - 2026-09-08

This evidence belongs to the exact local `FLUX.exe` in
`exports/windows-cast-gallery-p47-20260908/release/`, not the older
`exports/release/` artifact and not a published GitHub release.

| Evidence | Meaning |
|---|---|
| [installer-journey-receipt.json](installer-journey-receipt.json) | Successful 16-stage native journey; installer hash, isolated paths and distinct baseline-update flag |
| [SHA256SUMS.txt](SHA256SUMS.txt) | Exact installer and portable ZIP identities |
| [BUILD-STATE.json](BUILD-STATE.json) | Exported PCK hash and executed content identity: protocol 47, 27 playable profiles, 57 spells |
| [Actual game boot](logs/actual-game-boot.log) | Stored launcher starts real release executable; 120 Hz initialization and current catalog hashes |
| [User-data isolation](logs/12-userdata-argv-probe.stdout.log) | No-write pinned-editor probe confirms test-root app-data mapping before bounded release boot |
| [Installed PCK identity](logs/14-installed-runtime-state.stdout.log) | Runtime catalog report executed from the installed PCK, not the checkout |
| `logs/00-*` through `logs/15-*` | Exact command lines, stdout and stderr for individual subprocess stages |

The original receipt retains absolute scratch paths for provenance. Their log
basenames are copied into this evidence folder so review does not depend on
retaining the large test installation. No game binaries, preferences or generated
test installers are included here.

Coverage: read-only preflight, new installation in a path with spaces, inferred
stored launcher root, healthy reuse, actual PCK byte corruption, empty-manifest
rejection/repair, reuse after repair, empty argument and unowned folder refusal,
distinct baseline update retaining the old version, isolated app-data, compiled
formatter/native Windows argv round trip (20 assertions), installed-PCK inspection,
and actual installed launcher -> game startup. Baseline is a synthetic current-game
fixture with an extra authenticated marker; no historical compatibility is claimed.

Successful subprocess stderr is empty. The two refusal stages deliberately return
nonzero codes and explanatory stderr. The native argv stage runs in-process, so
has a receipt entry but no separate child stdout/stderr files.

The game boot is headless and bounded to three frames. Real shortcut creation,
window-close interaction, human visual/gameplay acceptance, fresh-PC publisher
trust and physical remote multiplayer were not exercised by this harness. No
real home installation or user shortcuts were changed. This build is unsigned
and its updater requires opening a newer supplied installer; no internet update
service or automatic rollback picker is implemented.

Earlier harness attempts failed because of identity/pointer assumptions and a
tools-only `--script` argument on the release executable. Their scratch receipts
remain separate from this passing run; they are not suppressed or counted green.

Full handoff: [Windows delivery checkpoint](../../WINDOWS-DELIVERY-CHECKPOINT.md).
