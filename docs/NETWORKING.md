# Friend-session networking

## Current runnable boundary

FLUX 2 protocol 19 / snapshot schema 6 exposes two walk-up Farflow stations, a
Farflow Charter and a Session Hearth in
the eastern Wellspring:

| Station | Current action |
| --- | --- |
| **Farflow Charter** | Before opening a gate, cycles three bounded host-owned social/combat profiles with visible capacity, traveller-damage and Bell-reset rules |
| **Host Farflow** | Opens an ENet server on UDP `24872`, enforces the sealed Charter capacity, and shows the live count/profile |
| **Join Farflow** | Connects to the configured address, verifies compatibility, and shows seeking/joined/refused state |
| **Session Hearth** | Shows connected/returning travellers and readiness; all connected travellers ready here before the host begins a three-second synchronized Proving Court start |
| **Proving Court** | Receives the intact connected roster at authored spawns, assigns combat teams and wards, scores knockouts, respawns defeated travellers, resolves score/time results and returns the company to the Hearth |

| Charter | Places | Traveller damage | Practice Bell |
| --- | ---: | --- | --- |
| **Open Commons** | 8 | Off; champions share a team | Any traveller |
| **Sparring Circle** | 4 | On; each champion has an individual team | Any traveller |
| **Duel Knot** | 2 | On; each champion has an individual team | Host only |

The host seals the current Charter when opening Farflow; it cannot change while
any peer is online. Guests receive and validate its ID, exact profile hash and
capacity during acceptance. The physical ENet ceiling remains eight so an
excess guest completes guarded hello and receives a readable `Session is full`
refusal instead of a generic socket error. The Charter catalog contributes to
build compatibility, while the selected profile remains host-owned session
state. Practice actors use distinct teams so every charter can still exercise
both champions against the effigy.

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
guest HUD. A representative two-player combat snapshot and the post-Hearth
round-start boundary stay within one 1,392-byte ENet MTU. Each guest also predicts
only its own movement from at most
48 sent inputs; a separate one-MTU ordered reconciliation carries full movement
state and the last host-processed sequence. Small draw corrections decay,
unsafe corrections snap, and combat/resources remain authoritative.
Semantic combat/social events carry stable IDs for four consecutive snapshots;
the client keeps a bounded 64-ID inbox, so superseded unreliable packets do not
silently erase feedback and redundant arrivals never replay the cue.

If a guest connection drops, the host keeps that exact actor safely idle for 15
seconds. Selecting Join Farflow again within that window uses a memory-only,
endpoint/build-scoped 256-bit return capability; the original name must match,
the capability rotates on success and expiry removes the actor/releases the
slot. Tokens never enter snapshots, rosters, logs or files. Closing/restarting
the client therefore does not preserve a return capability yet.

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

`--session-charter=open_commons|sparring_circle|duel_knot` is a diagnostic host
override; normal players turn the in-world Farflow Charter before hosting.

For repeatable local diagnostics, `--farflow=host` or `--farflow=join` opens the
same station action immediately after boot. These switches exist for automated
Windows/Linux smoke tests and do not introduce a detached player-facing menu.
`--farflow-smoke-emote` asks a diagnostic joining process to send one emote after
its first snapshot so the reliable request/confirmation path can be exercised.
`--farflow-smoke-prediction` adds a brief rightward input and reports only after
host-authoritative movement returns through reconciliation.
`--farflow-smoke-reconnect` closes the guest once, waits briefly, and reports
only after it returns as the same session entity.
`--farflow-smoke-hearth` gathers the diagnostic pair at the real station,
submits readiness through the normal guarded request path, and reports only
after the guest receives the host-owned shared start.
`--farflow-smoke-round` additionally reports only after that guest validates an
active packed round and appears in the same Proving Court serial as the host.

The maintained two-process acceptance wrappers combine those diagnostics in a
safe order—HELLO request, authoritative movement/reconciliation, Hearth
readiness, Proving Court entry, leave, then exact-actor return—and always clean up their processes:

```bat
scripts\smoke-farflow.cmd
scripts\smoke-farflow.cmd -Executable exports\windows\flux2.exe
```

```bash
scripts/smoke-farflow.sh
FLUX2_EXECUTABLE=exports/linux/flux2.x86_64 scripts/smoke-farflow.sh
```

Use `-Charter sparring_circle` on Windows or
`FLUX2_SESSION_CHARTER=sparring_circle` on Linux to exercise a non-default
profile through the same complete journey.

The wrapper is a localhost acceptance gate, not proof of router forwarding or a
second operating system. A remote friend must still use the host's real address
and the same commit/package while the host allows UDP 24872 (or the chosen port).

## Trust and compatibility boundary

The server is authoritative from the first packet. A client sends a handshake
containing a display name and SHA-256 compatibility identity derived from:

- simulation protocol version;
- fixed tick rate;
- campus/map content hash;
- ability catalog hash;
- champion catalog hash.
- Farflow Charter catalog hash.

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
| Return continuity | Implemented on Windows localhost: 15-second exact-actor reservation, random memory-only capability, name binding, rotation, expiry and explicit host loss |
| Diegetic session charter | Implemented: three in-world profiles, 2/4/8 capacity, host-authoritative traveller damage teams, Bell-reset policy, handshake assignment and explicit full/incompatible refusal |
| Session Hearth | Implemented: compact connected/returning roster, per-traveller readiness, host-owned countdown, roster-change cancellation and monotonic shared reset events/ticks |
| First arena round | Playable foundation: one authored bounded court with individual combat teams, spawn wards, first-to-three/90-second scoring, authoritative knockout/respawn, result freeze and automatic Hearth return; explicit rematch presentation remains |
| Court readability/rematch | Next: pre-round rules/spawn presentation, stronger result language and a deliberate repeat-round flow from the same Hearth roster |
| Remote platform smoke | Windows and Garuda Linux direct-IP packages connect, move, leave and reconnect with diagnostics |
| Later continuity | Client-process persistence, host restart, moderation, spectators and eventual host migration |

The public lobby cap remains eight while the architecture reserves a later
32-player scaling gate; no higher count is advertised until measured.
