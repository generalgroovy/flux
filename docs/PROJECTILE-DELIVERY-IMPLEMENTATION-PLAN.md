# Projectile delivery implementation plan

## P0 — visual/data contract

- Register delivery IDs independently from elements.
- Register visual phases and exact eight-direction presentation order.
- Validate transparent atlas dimensions, cell size, pivot, phase columns and exact mirror rows.
- Keep current elemental VFX phase contract compatible with delivery overlays.

Acceptance: invalid dimensions/order/pivot/mirror pairs fail validation; visual data cannot mutate simulation state.

## P1 — Burst simulation kernel

Current combat release creates one projectile. Replace the return shape with a deterministic spawn bundle/event list capable of creating N projectile states from one cast.

Requirements:

- true continuous aim vector remains authoritative;
- authored odd projectile count initially 3/5/7;
- authored symmetric relative-angle table or deterministic fixed-angle generator;
- equal speed/radius/lifetime unless ability explicitly overrides per-index data;
- spawn clearance checked independently for each projectile;
- stable projectile IDs ordered negative angle -> center -> positive angle;
- collision/hit/graze/expiry stays per projectile;
- blocked members fail deterministically without reordering surviving IDs;
- 60/120 Hz replay hashes match expected fixtures.

First fixture: five-shot `[-24,-12,0,+12,+24]`.

## P2 — Burst presentation

- Render each projectile independently from its simulation center.
- Select nearest of eight visual directions or use integer-safe sprite rotation only after readability comparison.
- Use neutral foundation as geometry/readability baseline.
- Apply elemental variant/overlay without changing simulation footprint.
- Drive spawn/travel/impact/residue phases from semantic projectile events, never animation authority.
- Reduced-motion mode uses compact spawn/travel/impact silhouettes without noisy residue.

Acceptance: readable at gameplay zoom, grayscale and common colour-vision checks; no false hitbox impression.

## P3 — Eight-element Burst pass

Promotion order: Fire -> Water -> Wind -> Earth -> Charge -> Ice -> Light -> Dark.

For every element validate:

- silhouette still communicates Burst delivery before colour;
- travel frame does not exceed safe readability envelope excessively;
- impact clearly differs from travel;
- residue never looks like an active damaging hit unless the simulation has an active field/residue;
- same Burst simulation fixture produces identical geometry regardless of element.

## P4 — gameplay integration / proving-ground test

Add a developer/training selector to fire neutral and each first-eight Burst variant against:

- open space;
- wall edge;
- corner;
- moving dummy;
- near-miss Edgeweave path;
- water/material test cells once chemistry is enabled.

Capture projectile count, spawn positions, velocities, hit IDs, impacts and replay hash for 60/120 Hz.

## P5 — next delivery slice

After Burst passes gameplay readability and deterministic spawn acceptance, implement Bolt using the same separation:

`single-projectile kernel -> neutral Bolt visual -> eight elemental overlays`.

Do not begin Beam/Spray/Whip runtime behavior until Bolt and Burst share the generalized delivery schema cleanly.
