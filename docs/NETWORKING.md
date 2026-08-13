# Friend-session networking

## Current runnable boundary

FLUX 2 protocol 26 / snapshot schema 10 exposes eleven walk-up Wellspring stations,
including the Farflow Charter, Session Hearth and host stewardship tools in
the eastern Wellspring:

| Station | Current action |
| --- | --- |
| **Farflow Charter** | Before opening a gate, cycles three bounded host-owned social/combat profiles with visible capacity, traveller-damage and Bell-reset rules |
| **Host Farflow** | Opens an ENet server on UDP `24872`, enforces the sealed Charter capacity, and requires a second press within three seconds before closing the company |
| **Join Farflow** | Connects to the configured address, verifies compatibility, and shows seeking/joined/refused state |
| **Session Hearth** | Shows connected/returning travellers and readiness; all connected travellers ready here before the host begins a three-second synchronized Proving Court start |
| **Company Ledger** | Lets only the host cycle connected guests in stable order; selection is visibly non-destructive and excludes returning reservations |
| **Parting Bell** | Arms release of the Ledger selection, then requires a second matching press within three seconds; the guest receives a reason and no return reservation |
| **Spell Loom** | Repositions every proven champion spell in a Plain/Ctrl/Alt 3×4 weave; the host validates actor proximity and the next snapshot confirms occupied positions |
| **Proving Court** | Receives the intact connected roster at authored spawns, assigns combat teams and wards, scores knockouts, respawns defeated travellers, resolves score/time results and returns the company to the Hearth |

After a result, the connected roster gathers at eight collision-cleared points
inside the actual Hearth interaction circle. Readiness resets, round serials
remain monotonic, the HUD names the next round and live countdown, and the same
company can start a rematch without reopening Farflow.

A friend accepted after a court starts is a next-gathering observer, not a late
participant. The host rejects their movement/ability authority, omits their
reconciliation stream and keeps them out of scoring; their camera follows a
replicated participant and Tab / controller D-pad right cycles stable available
participant IDs. The HUD names the watched champion and explains the lock. On
the synchronized Hearth return they regain their own actor, ready through the
normal host-validated request and can join the next round. The observer receives
only the existing public snapshot, so this creates no additional information
channel; future limited-information modes still require per-peer host filtering.

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
Practice Bell resets, per-actor Champion Loom attunement and 3×4 Spell Loom
placement from authoritative station proximity. The render snapshot keeps the
8 KiB expansion cap at eight travellers,
26 projectile lanes, four targets and 12 events; overflow is explicit in the
guest HUD. Snapshots are validated, FastLZ-packed into a bounded protocol-23
wire envelope, and validated again after bounded expansion. The maximum
eight-player fixture and live three-player court stay within one 1,392-byte
ENet MTU. Each participating guest also predicts
only its own movement from at most
48 sent inputs; a separate one-MTU ordered reconciliation carries full movement
state and the last host-processed sequence. Small draw corrections decay,
unsafe corrections snap, and combat/resources remain authoritative.
Semantic combat/social events carry stable IDs for four consecutive snapshots;
the client keeps a bounded 64-ID inbox, so superseded unreliable packets do not
silently erase feedback and redundant arrivals never replay the cue.

Pocket Eclipse uses a distinct bounded `beam_fired` semantic event rather than
pretending to be a projectile. The host owns startup, Flux, cooldown, cover
trace, first-target choice, damage and slow; peers receive only owner/spell,
target identity and the exact legal endpoint needed to draw the short-lived
lane. No client-authored endpoint or hit result enters simulation.

Tideline similarly publishes one bounded `spray_fired` fan endpoint/count and
one `spray_hit` event per affected actor. The host alone selects the cone set,
tests per-target cover, applies damage/launch and emits defeat outcomes. At the
eight-player cap this remains inside the existing bounded event lane.

If a guest connection drops, the host keeps that exact actor safely idle for 15
seconds. Selecting Join Farflow again within that window uses a memory-only,
endpoint/build-scoped 256-bit return capability; the original name must match,
the capability rotates on success and expiry removes the actor/releases the
slot. Tokens never enter snapshots, rosters, logs or files. Closing/restarting
the client therefore does not preserve a return capability yet.

Administrative departures are deliberately different from network loss. Only
the host transport boundary can name a connected entity for removal. A bounded
reliable reason is delivered first; the guest clears its memory-only return
capability and closes, while a 250 ms host deadline forcibly removes any client
that ignores the notice. The host then emits a final, non-reserved departure.
A client-sent administration packet is ignored. Closing the company applies the
same reason-bearing path to every guest before the host returns offline.

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
At Join Farflow, pressing F again leaves the company locally. At Host Farflow,
the first press arms company closure and the second press within three seconds
confirms; walking away or waiting lets the confirmation expire.

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
`--farflow-smoke-rematch` then resolves diagnostic Round 1 after exact-actor
return and reports only after both actors gather/ready at the Hearth and the
guest validates active Round 2.
`--farflow-smoke-steward` then confirms a host release and reports only after
the guest receives the exact reason, clears its return capability and the host
records a final departure without a reservation.
`--farflow-smoke-spectator` is reserved for the maintained late guest: it reports
only after following a participant, returning to the Hearth, readying and
entering Round 2 as a participant.

The maintained acceptance wrappers use two processes for Duel Knot and three
for the larger Charters. They combine those diagnostics in a safe order—HELLO
request, authoritative movement/reconciliation, Hearth readiness, Proving Court
entry, late observation, leave, exact-actor return, observer Hearth handoff,
rematch, then host stewardship—and always clean up their processes:

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
typed bounded value, authoritative station distance and emote cooldown,
performs the mutation, then
publishes a semantic confirmation or refusal. Guests never reset the court or
change a champion or spell order speculatively. A spell-placement value can
encode only one of five rows and one of the two proven roles; smuggled values,
duplicates and out-of-range requests fail closed.

## Implementation order from here

| Slice | Acceptance |
| --- | --- |
| Transport/handshake | Implemented: real ENet loopback, match/refusal, bounded input and disconnect cleanup |
| Authoritative presence | Implemented: host registers/removes named peer actors and maps network peers to stable entities 2-8 |
| Movement snapshots | Implemented: host stamps inputs to its tick, simulates all actors, bounds stale input and sends 60 Hz snapshots; guest interpolates presentation |
| Shared projectiles | Implemented: compact projectile lanes and bounded cast/hit/graze events render on guests while outcomes remain host-owned |
| Shared Wellspring interaction | Implemented: host authorizes HELLO, Practice Bell, Champion Loom and bounded Spell Loom requests; confirmations/refusals, target state and canonical spell order replicate |
| Prediction/reconciliation | Implemented: 48-input movement-only history, peer-scoped processed-sequence acknowledgement, deterministic replay, bounded correction and ACK/correction HUD without client outcome authority |
| Return continuity | Implemented on Windows localhost: 15-second exact-actor reservation, random memory-only capability, name binding, rotation, expiry and explicit host loss |
| Diegetic session charter | Implemented: three in-world profiles, 2/4/8 capacity, host-authoritative traveller damage teams, Bell-reset policy, handshake assignment and explicit full/incompatible refusal |
| Session Hearth | Implemented: compact connected/returning roster, per-traveller readiness, host-owned countdown, roster-change cancellation and monotonic shared reset events/ticks |
| First arena round | Playable foundation: one authored bounded court with individual combat teams, spawn wards, first-to-three/90-second scoring, authoritative knockout/respawn, result freeze and automatic Hearth return |
| Court readability/rematch | Complete foundation: persistent rules/countdown, eight validated gather positions, reset readiness, monotonic serial and same-roster Round 2 pass 60/120 Hz process journeys |
| Host stewardship | Complete foundation: stable host-only Ledger selection, separate double-confirm Parting Bell, double-confirm company close, bounded reliable reasons, revoked return capability, forged-packet refusal and live process proof |
| Late-join observer | Complete foundation: host input lock, stable participant camera cycling, explicit HUD, no prediction/reconciliation stream, automatic Hearth handoff and Round-2 participation pass 60/120 Hz three-process journeys |
| Per-peer visibility | Next: host-owned interest/LOS filtering and omission tests before any limited-information competitive mode |
| Remote platform smoke | Windows and Garuda Linux direct-IP packages connect, move, leave and reconnect with diagnostics |
| Later continuity | Client-process persistence, host restart, richer moderation and eventual host migration |

The public lobby cap remains eight while the architecture reserves a later
32-player scaling gate; no higher count is advertised until measured.
