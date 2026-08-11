# Friend-session networking

## Current runnable boundary

FLUX 2 now exposes two walk-up Farflow stations in the eastern Wellspring:

| Station | Current action |
| --- | --- |
| **Host Farflow** | Opens an ENet server on UDP `24872`, accepts at most seven remote clients, and shows the live count |
| **Join Farflow** | Connects to the configured address, verifies compatibility, and shows seeking/joined/refused state |

This checkpoint includes a first playable shared-movement loop. The host maps
accepted peers to stable entities 2-8, gives the first guest S. Wayne beside the
host's Oh Tipi, consumes only validated inputs, simulates every traveller, and
publishes compact snapshots at 60 Hz. Each client follows its assigned actor,
renders the named remote traveller, and receives authoritative resources,
movement, projectiles and semantic cast/hit/graze feedback. The render snapshot
keeps the 8 KiB cap at eight travellers, 26 projectile lanes and 12 events;
overflow is explicit in the guest HUD. Authorized shared station requests and
prediction/reconciliation remain the next slices.

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

## Implementation order from here

| Slice | Acceptance |
| --- | --- |
| Transport/handshake | Implemented: real ENet loopback, match/refusal, bounded input and disconnect cleanup |
| Authoritative presence | Implemented: host registers/removes named peer actors and maps network peers to stable entities 2-8 |
| Movement snapshots | Implemented: host stamps inputs to its tick, simulates all actors, bounds stale input and sends 60 Hz snapshots; guest interpolates presentation |
| Shared projectiles | Implemented: compact projectile lanes and bounded cast/hit/graze events render on guests while outcomes remain host-owned |
| Shared Wellspring interaction | Host authorizes reset/emote/station requests and all peers see the confirmed result |
| Remote platform smoke | Windows and Garuda Linux direct-IP packages connect, move, leave and reconnect with diagnostics |
| Session continuity | Join-in-progress, timeouts, reconnect token, host shutdown, moderation and later host migration |

The public lobby cap remains eight while the architecture reserves a later
32-player scaling gate; no higher count is advertised until measured.
