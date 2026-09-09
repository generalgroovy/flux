# Local elemental audio: focused evidence

Recorded locally on Windows, 2026-09-09, using official Godot 4.7.1. These logs
are the accepted focused checkpoint before later header/input test additions,
not release, device-playback or listening acceptance. They were copied without
editing; `manifest.json` records original paths and verified lengths/SHA-256.

## Recorded result

Follow-on `header-focused.log`: element-audio2,673 assertions,0failures and
empty stderr, adding47 regressions for header geometry, actual mouse/key routes,
capture priority and whole-preference preservation. Six additional actual GL
Controls captures are included at1280x720 and1920x1080, volumes0/30/100. Root
reviewed100%volume at720p andmute at1080p after correcting header vertical placement;
all six saved successfully (`sound-controls-v2.log`). These additions are not
listed in the earlier manifest, which intentionally preserves its original scope.

`focused-v3.log`: **2,943 assertions, zero failures** across element-audio
(2,626) and player-preferences (317). The run took about 4.1 seconds; stderr is
empty and warnings were rejected. Earlier fixture-development attempts remain
in `.godot/element-audio-work/`; this package retains the final passing run.

The PCM log gives peak, RMS, mean and largest adjacent-sample change for all
16 cached clips: eight elements, each with startup and confirmed-contact cues.
Maximum single-clip peak was 0.20536 full scale; largest absolute mean/DC value
was 0.000922. Each clip has exact-zero first/last samples, non-looping mono
16-bit PCM at 22050 Hz, bounded duration and gain, distinct deterministic content,
and tested attack/tail ramps. Ice's high harmonic explains its 0.12796 maximum
adjacent-sample change; that metric alone is not an audible-pop diagnosis.

Coverage includes the four-voice pool, cleanup, full-pool rejection/reuse,
6-/8-tick contact/startup spacing, mute, backwards-tick reset and 30 percent
default gain. Every playable runtime wire is checked against its actual catalog
element and contact family. Wrong families, remote owners and unknown events
are rejected. All **eight elements x four families** (Bolt, Spray, Field, Beam)
also execute real paid casts and authoritative target confirmations, including
snapshot-encoded/decoded events. Presentation ingestion leaves simulation hashes
unchanged and does not alter actual Flux costs.

Inherited bootstrap tests cover menu/focus/rearm, defeated actor, missing target,
spectator and missing-guest fallback gates. Contacts fail closed in optional
cone view and outside the current camera rectangle. Chemistry concealment denies
contacts; authoritative reveal restores eligible on-screen confirmations. Own
startup cues remain available independently of target visibility.

Optional `sound_volume_percent` retains preference schema 11. Tests cover missing
field defaults for schemas 1-11, explicit zero/mute, whole JSON numbers, customized
keyboard/mouse/controller retention, persistence, and atomic rejection of NaN,
infinity, fractional, string, boolean, null, collection and out-of-range values.

## Reproduce

From the repository, select only these suites with the pinned engine:

```powershell
. ./scripts/flux2-common.ps1
$audioEvidenceEngine = Get-FluxGodot
& $audioEvidenceEngine --headless --path . --script res://tests/run_all.gd -- --suite=element-audio,player-preferences
```

The original run used a temporary deferred SceneTree runner selecting the same
two suites. The registered runner also defers until the tree is ready. The
bootstrap harness uses disabled-render SubViewports for actual camera geometry
and `prepare(false)` for all event/real-cast tests. A separate unattached-node
test allocates playback children to verify ownership/cleanup; it never ingests
an event, enters the tree or calls playback. No user settings file is touched.

## Limits

Separate actual-node probe: `element-audio-playback-v2.log` passes16 real voice
starts/mutes plus owned-node cleanup with `--headless --audio-driver Dummy`.
It waits one mixer retirement cycle before exit; no sound reaches speakers.
Reproduce with `--script res://tests/scenarios/element_audio_playback_probe.gd`.
This checks the production stream/play/stop route, not audible quality.

Numerical signal checks do not establish timbre quality, audible click absence,
mix comfort, element recognizability, speaker/headphone behavior or accessibility
adequacy. No device audio was played during this focused run. Schema compatibility
tests preserve the old document shape but do not execute an installed older
binary. This is not a live network, Full, rendered-controls or export test.
Later tests may increase assertion counts; rerunning current sources checks the
current working copy, not an archived executable.
