# The Sanctum hub contract

## Purpose

The Sanctum is FLUX 2's starting area, training campus, lobby, menu, social
space, test laboratory, and expedition threshold. It must feel vast and worth
learning without making routine configuration or matchmaking slow. Spatial
interactions and overlay menus are two views of the same application commands.

The original hub/function seed is versioned in
[`content/maps/sanctum_hub_v1.json`](../content/maps/sanctum_hub_v1.json). The
concept image communicates atmosphere only. Final topology will be authored as
worldbone, traversal, elevation, material, presentation, and navigation layers.
G2 now loads the separate canonical
[`sanctum_campus_g2_v1.json`](../content/maps/sanctum_campus_g2_v1.json), whose
connected district graph, bridge ownership, worldbone buildings, elevation
queries, route classes, accessible ordinary coverage, reset-zone metadata,
landmarks, spawn clearance and map hash fail closed before play. Its scrolling
procedural renderer replaces the old concentric court but does not yet pass this
contract's modular pixel-art, provenance, silhouette, density or accessibility
bar; G2 therefore remains in progress.

Living Sanctum V1 is the first product acceptance gate. The hub must be fully
usable offline and must also support privacy-safe friend presence, direct/LAN/
invite joining, hosted shared Sanctum sessions, and bounded host administration
on Garuda Linux/Sway and Windows before later gameplay modes are accepted.

## Spatial structure

The campus spans approximately 12,800 by 7,200 design units and three connected
layers:

- **Terraces:** the main plazas, specialist districts, gardens, bridges, and
  outer gates.
- **Crown:** rooftops, observatories, suspended gardens, lift termini, race
  routes, and airborne shortcuts.
- **Undercroft:** foundry machinery, flooded laboratories, utility passages,
  hidden practice rooms, and deterministic reset infrastructure.

Each major district has at least two ordinary entrances, a clear landmark, an
attunement shrine or direct shrine connection, and one movement-focused route.
Related activities share a district so the place reads as a believable campus:

| District | Combined functions | Signature traversal |
| --- | --- | --- |
| Nexus Court | arrival, onboarding, central map, attunement | fountain ring, four radial launch lines |
| Wayfarer Concourse | social, wardrobe, host/join, modes, expeditions | balcony chain and gatehouse roof route |
| Movement Conservatory | fundamentals, advanced tech, races, time trials | rails, wall-kick wells, gaps, vault and slide lines |
| Alchemical Proving Grounds | aim, bots, destructibles, chemistry, combat labs | basin rim run and crater superglide |
| Living Archive | codex, lore, builds, replays, analytics, research | book-stack vaults and observatory lift |
| Verdant Recovery | rest, ingredients, crafting, interaction, dummies | suspended garden and root-canopy path |
| Foundry Deep | fabrication, transmutation, undercroft, material reset | moving machinery line and flooded shortcut |
| Crown Observatory | settings, accessibility, diagnostics, monitoring | rooftop redirect course and lift shafts |
| Seasonal Expanse | biome pockets, private trials, weather laboratory | changing-surface route and island leaps |

## Attunement fast travel

Fast travel is infrastructure, not a loading-screen excuse.

1. The Nexus fountain is available after onboarding.
2. A district shrine unlocks when a player reaches and safely attunes it.
3. An unlocked, enabled shrine can target any other unlocked, enabled shrine.
4. Travel is refused during combat, a timed trial, an authoritative transition,
   a material reset, or when destination clearance fails.
5. The host validates multiplayer travel and moves a consenting party at one
   deterministic transition tick. Solo travel has no consumable cost.
6. Discovery, accessibility, and map UI may reveal a shrine's approximate
   location without granting teleport access.
7. Every destination has a normal route; teleportation never hides required
   onboarding or substitutes for local encounter design.

The first implementation stores travel nodes and rules as validated content.
Session ownership, transition orchestration, persistence, and destination
clearance are later slices and must fail closed until implemented.

## Starting and menu flow

```text
boot -> local profile -> accessibility/input check -> Nexus arrival
  -> continue offline / training / local bots
  -> host / join / browse modes (online capability shown explicitly)
  -> loadout and appearance -> ready check -> expedition or arena
```

Escape/Start opens the overlay for settings, accessibility, input, save/quit,
and already-attuned travel. World desks, gates, portals, and shrines open the
same focused screens with additional spatial context. Network-dependent actions
state why they are unavailable offline; offline play never waits for a service.

## Shared Sanctum and host tools

The friends/muster surface reports only privacy-approved states: offline,
online, away, in Sanctum/activity, joinable, invite-only, full, blocked, or
incompatible. Optional directory/presence/signalling/relay infrastructure is
replaceable and self-hostable; direct/LAN joining and the complete offline hub
remain first-class.

The host may manage privacy/capacity, invitations, co-host/ownership, teams,
readiness, spectators, late join, bot fill, friendly-fire/self-damage/healing/
collision policy, trials, dummies, laboratory reset, shared waypoints, safe
group travel, announcements, moderation, diagnostics, and clean end. All host
commands are typed, authorized, bounded, visible, and locally auditable. Forced
porting is limited to an explicitly opted-in host-managed practice policy with
a reason/countdown and valid state/anchor/clearance checks.

## Traversal and safety rules

- Ordinary paths remain readable and do not demand advanced movement.
- Advanced routes reduce travel time, expose collectibles or records, and teach
  mechanics without becoming required accessibility barriers.
- Water, pits, moving machinery, and mutable laboratories reset locally and do
  not destroy profile progress or worldbone.
- Combat-capable training regions are partitioned from social/spawn safety.
- Foreground terrain, roofs, foliage, buildings, and constructs fade/cut away
  or expose an ownership-readable silhouette when they cover a character inside
  authoritative LOS. Actors outside LOS receive no presentation/debug leak.
- The hub supports solo use first; multiplayer presence is an additive session
  layer, not a dependency for menus or content access.
- Each district can stream independently, while transition anchors preserve
  deterministic spawn and replay metadata.

## Implementation sequence

1. Validate the map/district/travel definition and present a styled training
   room over the deterministic movement foundation.
2. Replace the schematic court with a multi-area Nexus-to-Conservatory world
   slice using distinct silhouettes, ordinary/advanced paths, readable
   elevation, distant district context, original pixel modules, and one visible
   fast-travel destination.
3. Add the map shell, overlay parity, one shrine interaction, and the complete
   measured route through that accepted world slice.
4. Add the Proving Grounds around the existing projectile family and bounded
   128 x 128 chemistry laboratory, then promote active reactions.
5. Add district streaming, persistence, party consent, destination clearance,
   and replay-visible transitions.

The G2 art kit is deliberately narrow but shipping-oriented: ground/cliff
ramps, paths/plazas, water/shore, grass/garden edges, walls/arches, one roof
family, one shrine, and navigation landmarks. Additional districts expand that
kit only after gameplay-zoom readability, collision alignment, grayscale,
performance, provenance, and 60/120 Hz presentation smokes pass.

Composition may study the broad clarity of richly staged isometric action
environments—layered depth, memorable room silhouettes, dramatic landmarks,
responsive ambience, dense edges and clear floors—while retaining original
FLUX 2 pixel perspective, topology, materials, palette, props, lighting, UI,
animation, camera metrics, and trade dress.
