# The Sanctum hub contract

## Purpose

The Sanctum is FLUX 2's starting area, training campus, lobby, menu, social
space, test laboratory, and expedition threshold. It must feel vast and worth
learning without making routine configuration or matchmaking slow. Spatial
interactions and overlay menus are two views of the same application commands.

The authoritative layout seed is versioned in
[`content/maps/sanctum_hub_v1.json`](../content/maps/sanctum_hub_v1.json). The
concept image communicates atmosphere only. Final topology will be authored as
worldbone, traversal, elevation, material, presentation, and navigation layers.

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

## Traversal and safety rules

- Ordinary paths remain readable and do not demand advanced movement.
- Advanced routes reduce travel time, expose collectibles or records, and teach
  mechanics without becoming required accessibility barriers.
- Water, pits, moving machinery, and mutable laboratories reset locally and do
  not destroy profile progress or worldbone.
- Combat-capable training regions are partitioned from social/spawn safety.
- The hub supports solo use first; multiplayer presence is an additive session
  layer, not a dependency for menus or content access.
- Each district can stream independently, while transition anchors preserve
  deterministic spawn and replay metadata.

## Implementation sequence

1. Validate the map/district/travel definition and present a styled training
   room over the deterministic movement foundation.
2. Add a map shell, overlay menu state machine, one shrine interaction, and an
   authored Nexus-to-Conservatory route.
3. Add the Proving Grounds with one projectile family and a bounded 128 x 128
   chemistry laboratory.
4. Add district streaming, persistence, party consent, destination clearance,
   and replay-visible transitions.
5. Build the original modular pixel-art kit and replace foundation debug draws
   only after topology, readability, performance, and provenance gates pass.
