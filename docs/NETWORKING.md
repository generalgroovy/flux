# Friend-session networking

## Current runnable boundary

FLUX 2 protocol 15 / snapshot schema 3 exposes two walk-up Farflow stations in
the eastern Wellspring:

| Station | Current action |
| --- | --- |
| **Host Farflow** | Opens an ENet server on UDP `24872`, accepts at most seven remote clients, and shows the live count |
| **Join Farflow** | Connects to the configured address, verifies compatibility, and shows seeking/joined/refused state |

This checkpoint includes a first playable shared-movement loop. The host maps
accepted peers to stable entities 2-8, gives the first guest S. Wayne beside the
host's Oh Tipi, consumes only validated inputs, simulates every traveller, and
publishes compact snapshots at 60 Hz. Each client follows its assigned actor,
renders the named remote traveller, and receives authoritative resources,
movement, projectiles, training-target health and semantic feedback. `T` /
controller D-pad up sends a shared HELLO bubble; the host also authorizes
Practice Bell resets and per-actor Champion Loom attunement from authoritative
station proximity. The render snapshot keeps the 8 KiB cap at eight travellers,
26 projectile lanes, four targets and 12 events; overflow is explicit in the
guest HUD. A representative two-player combat snapshot stays within one
1,392-byte ENet MTU. Each guest also predicts only its own movement from at most
48 sent inputs; a separate one-MTU ordered reconciliation carries full movement
state and the last host-processed sequence. Small draw corrections decay,
unsafe corrections snap, and combat/resources remain authoritative.
Semantic combat/social events carry stable IDs for four consecutive snapshots;
the client keeps a bounded 64-ID inbox, so superseded unreliable packets do not
silently erase feedback and redundant arrivals never replay the cue.

## Windows and Linux direct-IP smoke

The host launches normally, walks east to **Host Farflow**, and presses F. A
friend launches the same commit and tick rate with an address override, walks
to **Join Farflow**, and presses F:

```bash
godot --path . -- --join-address=192.0.2.10 --session-port=24872 --player-name="River Guest"
```

Use the host's actual LAN address for a LAN test. Internet hosting currently
requires the host/router/firewall to allow and forward **UDP**, not TCP, port
`24872`; there is no discovery, relay, NAT traversal or automatic port mapping
yet. Only test with trusted friends: transport authentication and encryption
are deliberately not claimed by this early direct-IP slice.

`--session-port=1024..65535` changes both the station's host port and join target.
`--player-name=` accepts one to 24 non-control characters. Without overrides,
Join Farflow targets `127.0.0.1`, making two local processes a safe first test.
Pressing F at either Farflow station again closes the local peer cleanly.

For repeatable local diagnostics, `--farflow=host` or `--farflow=join` opens the
same station action immediately after boot. These switches exist for automated
Windows/Linux smoke tests and do not introduce a detached player-facing menu.
`--farflow-smoke-emote` asks a diagnostic joining process to send one emote after
its first snapshot so the reliable request/confirmation path can be exercised.
`--farflow-smoke-prediction` adds a brief rightward input and reports only after
host-authoritative movement returns through reconciliation.

## Trust and compatibility boundary

The server is authoritative from the first packet. A client sends a handshake
containing a display name and SHA-256 compatibility identity derived from:

- simulation protocol version;
- fixed tick rate;
- campus/map content hash;
- ability catalog hash;
- champion catalog hash.

Mismatches fail before the peer enters the session roster. Incoming variants
are decoded without object construction, capped at 8 KiB, processed under a
64-packet poll budget, and validated by exact type/range. At most 28 accepted
inputs can wait for host consumption; each peer's sequence must increase, so
duplicate or replayed actions are discarded. Remote peers never choose their
trusted sender ID, tick, position, damage, cooldown, resource, score or outcome.

Reliable interaction requests have their own monotonic sequence and bounded
queue. The host stamps the peer's trusted entity ID, checks action type,
authoritative station distance and emote cooldown, performs the mutation, then
publishes a semantic confirmation or refusal. Guests never reset the court or
change a champion speculatively.

## Implementation order from here

| Slice | Acceptance |
| --- | --- |
| Transport/handshake | Implemented: real ENet loopback, match/refusal, bounded input and disconnect cleanup |
| Authoritative presence | Implemented: host registers/removes named peer actors and maps network peers to stable entities 2-8 |
| Movement snapshots | Implemented: host stamps inputs to its tick, simulates all actors, bounds stale input and sends 60 Hz snapshots; guest interpolates presentation |
| Shared projectiles | Implemented: compact projectile lanes and bounded cast/hit/graze events render on guests while outcomes remain host-owned |
| Shared Wellspring interaction | Implemented: host authorizes HELLO, Practice Bell and Champion Loom requests; confirmations/refusals and target state replicate |
| Prediction/reconciliation | Implemented: 48-input movement-only history, peer-scoped processed-sequence acknowledgement, deterministic replay, bounded correction and ACK/correction HUD without client outcome authority |
| Remote platform smoke | Windows and Garuda Linux direct-IP packages connect, move, leave and reconnect with diagnostics |
| Session continuity | Join-in-progress, timeouts, reconnect token, host shutdown, moderation and later host migration |

The public lobby cap remains eight while the architecture reserves a later
32-player scaling gate; no higher count is advertised until measured.
