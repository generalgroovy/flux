# Ability and loadout configuration

## Scope

This contract began as the validated canonical configuration checkpoint and now
records the boundary consumed by deterministic runtime combat. Arc Primary, Vector Lance,
Oh Tipi's Rillshot/Tideline and S. Wayne's Eclipse Disc/Pocket Eclipse cast end
to end; the remaining catalog entries
are configuration only. Network-visible identities, resource rules, loadout legality, affinity
behavior, and compatibility hashes remain trustworthy before any additional
combat code may promote an entry.

Runtime boot validates:

- [`foundation_abilities_v1.json`](../content/abilities/foundation_abilities_v1.json);
- [`foundation_champions_v1.json`](../content/champions/foundation_champions_v1.json);
- [`foundation_practitioner_v1.json`](../content/loadouts/foundation_practitioner_v1.json).

Invalid content fails boot and the headless gate. Definitions are canonicalized
with recursively sorted object keys and hashed with SHA-256. Array order remains
meaningful. Release tooling will later compile these authoring files into a
wire-ID manifest; checked IDs may be deprecated but never silently reassigned.

Schema 2 requires each ability to declare a bounded shape (`projectile`, `beam`,
`spray`, `field`, `defense`, `movement`, plus passive/ultimate), delivery,
impact, residue and planned material operation. `runtime_status` separates the
six end-to-end spells from catalog-only designs, while
`material_runtime_enabled` remains false until a deterministic grid operation,
reset rule and route-safety proof actually exist.

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
| Ordered spell bar | 5 | Unique primary, active, or mobility IDs; stable order maps to semantic actions `spell_1`…`spell_5` |

Every ability also requires a stable string ID, positive wire ID, display name,
slot kind, element (or explicit neutral value), roles, counterplay list, and
`simulation` authority. Presentation never converts an animation frame into a
cast or hit.

The foundation loadout uses two affinities and exactly fills 13 active points:
Vector Lance 5→4 (Charge), Prism Ward 5→4 (Light), and Stone Channel 5 (Earth).
This demonstrates discounts without granting elemental damage superiority.
Its schema-v2 spell bar orders Arc Primary, Vector Lance, Prism Ward, Stone
Channel, and Phase Step. Only the first two are promoted into current champion
runtime kits; unpromoted entries remain validated content rather than fake casts.
Pocket Eclipse is the first promoted non-projectile shape: a finite Light beam
resolved after all actors move for the tick, stopped by cover, and applied once
to the nearest legal target along its lane.
Tideline is the first spray: a finite Water fan resolved at the same post-move
boundary, with stable actor order, per-target cover, one hit/launch per legal
actor and no projectile-only Edgeweave behavior.

## Current Spell Loom boundary

The eleventh Wellspring station is a host-authoritative Spell Loom. It exposes
five numbered rows but only the selected champion's two end-to-end kit spells:
`PRIMARY` and `ACTIVE`. Placing one into a row swaps it with its previous row,
so the canonical state always contains each proven spell exactly once and three
zero-valued empty slots. The host accepts a bounded role/slot request only while
the actor is inside the Loom radius; guests wait for the next validated snapshot
instead of applying a speculative loadout.

The arrangement is session-scoped and resets to slots 1/2 when a champion is
attuned. Left/right click and the existing active key remain explicit legacy
access paths during migration. Catalog-only abilities never appear in the Loom,
and no material operation is enabled by rearranging a slot.

## Promotion sequence

1. Canonical catalog/loadout validation and boot integration — complete.
2. Match compatibility metadata and save migration for selected loadouts.
3. Deterministic resource-free Arc Primary projectile — complete foundation.
4. Vector Lance with startup, Flux spend, cooldown, recovery, and impact —
   complete foundation; full visual/audio counterplay acceptance remains.
5. Oh Tipi Rillshot/Tideline plus resettable sparring effigy — complete basic
   projectile/spray pair; defense, full kit, final art/audio and balance remain.
6. S. Wayne Eclipse Disc/Pocket Eclipse — complete basic pair with a canonical
   single ricochet and a cover-stopped finite beam/slow; deeper dummy and
   accessibility reads remain.
7. Host-authoritative five-row Spell Loom for the two proven kit spells —
   complete foundation; persistence and additional promoted spells remain.
8. One approved champion through bot, replay, network, reconnect, spectator,
   accessibility, and platform gates.
9. Compile optional Flux Formula variants from approved source-family,
   geometry, operation, catalyst, and constraint components; the host accepts
   stable variant IDs, never client-authored outcome parameters.

No additional catalog breadth is useful until the promoted foundation abilities
are playable and readable end to end and one complete champion passes every
vertical-slice gate.
