# Ability and loadout configuration

## Scope

This checkpoint introduces validated, canonical ability configuration. It does
not cast an ability yet. The split is deliberate: network-visible identities,
resource rules, loadout legality, affinity behavior, and compatibility hashes
must be trustworthy before combat code consumes them.

Runtime boot validates:

- [`foundation_abilities_v1.json`](../content/abilities/foundation_abilities_v1.json);
- [`foundation_practitioner_v1.json`](../content/loadouts/foundation_practitioner_v1.json).

Invalid content fails boot and the headless gate. Definitions are canonicalized
with recursively sorted object keys and hashed with SHA-256. Array order remains
meaningful. Release tooling will later compile these authoring files into a
wire-ID manifest; checked IDs may be deprecated but never silently reassigned.

## Element-family gate

The catalog declares all twelve intended families so IDs can remain stable:
Earth, Fire, Water, Wind, Ice, Charge, Light, Dark, Spirit, Chaos, Gravity, and
Time. Only the first eight are runtime-enabled. An ability that references a
gated family fails validation rather than partially approximating unsupported
behavior.

Affinities implement one rule only: an aligned catalog active may receive its
declared build-point discount, with a minimum effective cost of one. An
affinity never changes raw damage, healing, duration, radius, status strength,
or resource capacity implicitly.

## Loadout shape

A standard competitive loadout contains:

| Slot | Count | Resource/budget rule |
| --- | ---: | --- |
| Passive | 1 | Champion-defining behavior; no duplicate hidden passive stack |
| Primary | 1 | Reliable aimed pressure; zero Flux cost |
| Catalog actives | 3 | Unique, positive build/Flux/cooldown/startup/recovery; total at most 13 points after affinity discounts |
| Champion mobility | 1 | Flux-paid, collision-safe, bounded route |
| Ultimate | 1 | Ultimate charge, readable startup, interruption/destruction and recovery rules |

Every ability also requires a stable string ID, positive wire ID, display name,
slot kind, element (or explicit neutral value), roles, counterplay list, and
`simulation` authority. Presentation never converts an animation frame into a
cast or hit.

The foundation loadout uses two affinities and exactly fills 13 active points:
Vector Lance 5→4 (Charge), Prism Ward 5→4 (Light), and Stone Channel 5 (Earth).
This demonstrates discounts without granting elemental damage superiority.

## Promotion sequence

1. Canonical catalog/loadout validation and boot integration — complete.
2. Match compatibility metadata and save migration for selected loadouts.
3. Deterministic resource-free Arc Primary projectile.
4. One active with startup, Flux spend, cooldown, recovery, impact, and explicit
   counterplay.
5. Training configuration UI and authoritative host ready-check.
6. One approved champion through bot, replay, network, reconnect, spectator,
   accessibility, and platform gates.

No additional catalog breadth is useful until one complete ability is playable
and readable end to end.
