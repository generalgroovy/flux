# Final template/runtime Windows delivery

Status: fresh source Full, strict Windows export and isolated native standalone
game boot passed, 2026-09-09. New installer acceptance BLOCKED by Windows
Application Control before its first preflight. No publication or user install.

Fresh source Full:91 suites /463,310 assertions /zero failures and stderr,
85,390ms. The original receipt, three stdout/stderr pairs, source-state report
and asset inventory are preserved under `full/`, after verifying their recorded
hashes. This payload includes the retained runtime reaction-filter candidate;
the earlier QV installer remains immutable and is not mislabeled as this source.

## Current playable source payload

The current source game is runnable at:

```text
C:\Users\sende\Projects\flux\exports\windows-template-runtime-p47-20260909\windows\flux2.exe
```

Keep its adjacent `flux2.pck`. The same files are in the new portable ZIP;
extract the entire archive and open PLAY-FLUX.cmd for normal portable use.

| Artifact | Bytes | SHA256 |
|---|---:|---|
| `windows/flux2.exe` |109,071,360 |`04baf75cc1d69dd93eb709533ecab4fd7770bb8a530645717017a06a9d9809fc` |
| `windows/flux2.pck` |66,211,656 |`ed7ea726c3dd51516871cf5005d6395641e1d683e59b5f4cd33813b3fe4dd316` |
| `release/FLUX2-Windows-x86_64.zip` |96,774,779 |`7cd1fbcb912cf3032492c51f0390798e77aa520003e61098c31a4b46ed6e8ee2` |
| `release/FLUX.exe` (installer BLOCKED locally) |96,800,256 |`ab3752950c81626985738ab45dbd1eff92131f7829231e629026d63c755c1760` |

Paths above are under `exports/windows-template-runtime-p47-20260909/`.
The new installer/archive version is `0.1.0-dev-a1aa028076-7cd1fbcb91`.
The executable is the exact verified official Godot4.7.1 template, not a
recompiled substitute. Authenticode reports NotSigned; official distribution
and hash identity are not a claim of digital signing.

## Passed evidence

| Gate | Result |
|---|---|
| Fresh Full |91 suites /463,310 assertions /0 failures /0 stderr;85,390ms; logs and report inputs hash-verified before copying |
| Runtime source provenance |184 authored runtime/config records in [SOURCE-STATE.json](SOURCE-STATE.json), unchanged before/after export and again after standalone boot |
| Retained combat source |Raw SHA256 `cdce33b7ee0528c57870cd1a3f5ce8faa52bee9517ec56962bdf8551b6aebd1a` |
| Strict fresh Windows export |`build-logs/strict-export.log`; warnings rejected, zero stderr |
| Executed source/PCK identity |Embedded PCK report executed outside checkout and matched current source catalog report; [BUILD-STATE.json](BUILD-STATE.json) binds pack/source snapshot/Full identity |
| Fresh defaults inside PCK |No-write probe confirms Technique V / Evade Q, schema11/revision1 |
| Independent native standalone boot |Exactly one ordinary raw-release run,3 headless frames, no source path, isolated APPDATA/LOCALAPPDATA; full120Hz/protocol47 bootstrap, zero warnings/errors/stderr |
| Saved standalone defaults |Only the isolated smoke profile was written: V Technique, Q Evade, schema11/revision1 |
| Portable archive integrity |All6 payload members stream-verified against embedded SHA256SUMS; no installer execution or extraction used for this check |
| User-data protection |[Six-path guard](user-data-guard.json): same existence, bytes, hashes and timestamps across export, blocked installer and standalone smoke |
| Retained fallback |Earlier QV installer and ZIP still match their successful delivery hashes |

The standalone boot log is [raw-game-boot.log](build-logs/raw-game-boot.log).
Its process exited and no owned raw game remained. The smoke settings live only
under the new export's `smoke-userdata/`, not the player's live settings directory.

## Blocked installer evidence

[Blocked receipt](blocked-installer-receipt.json) records **zero executed stages**.
The first read-only root preflight could not start the new installer:
Win32Exception4551, "An Application Control policy has blocked this file."
The exact command and error remain in `blocked-installer-logs/`.

Consequently clean installation, update, repair and retention were **not tested
for this new installer**. The old candidate's green16-stage journey does not
transfer to these different bytes. No alternate installer execution, retry,
renaming/recompilation to change identity, security setting change or bypass
was attempted. The separately planned ordinary standalone EXE/PCK route was
tested once and passed; this does not overcome the installer's policy gate.

The older QV installer remains at
`exports/windows-followup-p47-20260909/release/FLUX.exe`, SHA256
`4bd03fd6ee50d7161b445bc03e2c8e99477b366a44b63f8fadba084ce31b5121`.
Its historical16-stage install/update/repair journey and20 native argument
assertions remain valid only for that older QV payload. It lacks the latest
retained reaction-filter optimization. See [earlier delivery evidence](../delivery/README.md).

## Boundaries and ownership

All installer/update/repair testing is isolated with no real shortcuts or live
settings changes. Signing, physical two-PC play, source-launch import readiness
and human art/gameplay acceptance remain separate gates.

No production, launcher or shared packaging scripts changed in this lane.
The source launcher's known nonempty-cache readiness shortcut remains open;
the exported standalone game does not use that path. No new character art was
promoted by this export. A120Hz configuration/headless smoke is not sustained
120FPS, human visual/gameplay acceptance, or a physical friend-session test.
No actual user install, shortcuts, prior exports, or previous delivery evidence
were modified. New test/build artifacts are retained; no cleanup/pruning occurred.

The owned `build-final-delivery.ps1` records strict export, provenance checks,
bundling and the blocked native harness, and refuses to overwrite an existing
release. [manifest.json](manifest.json) binds the exact artifact/evidence hashes
and split acceptance status. No further trials or installer retries are planned.
