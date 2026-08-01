# Deterministic combat foundation

## Implemented slice

Protocol 3 introduces the first complete command-to-impact path:

- independent scale-1000 aim and held primary input;
- pressed active-one input;
- startup, recovery, and cooldown state compiled independently at 60/120 Hz;
- resource-free Arc Primary and Flux-paid Vector Lance;
- stable projectile/entity/owner/team/source/element IDs;
- integer movement/remainders, ordered world collision, swept player hits,
  authoritative damage, lifetime, semantic events, and state hashing;
- replay verification with active primary command streams;
- Edgeweave rewards for deliberate hostile swept near-misses.

Combat state lives in `src/sim/combat/` and `PlayerState`. Presentation reads
projectiles and events but never creates damage, spends Flux, finishes startup,
or decides impact.

## Tick order

For each authoritative tick:

1. validate and order player commands by entity ID;
2. advance Health/Flux recovery state;
3. resolve universal movement and collision;
4. advance or begin casts, snapshotting quantized aim at startup;
5. assign projectile IDs in player order;
6. advance projectiles in ID order, resolve world/player collision and
   Edgeweave, then retain deterministic survivors;
7. hash player and projectile state.

The current order intentionally lets resource recovery complete before a cast
affordability check on the same tick. Tests lock recovery when proving a refused
cast.

## Foundation abilities

| Ability | Wire | Cost | Startup | Cooldown | Current result |
| --- | ---: | ---: | ---: | ---: | --- |
| Arc Primary | 101 | 0 Flux | 60 ms | 220 ms | 10 Health projectile, speed 1120, 1200 ms lifetime |
| Vector Lance | 110 | 24 Flux | 180 ms | 1400 ms | 25 Health projectile, speed 980, 1500 ms lifetime |

Values are integer milli-units in simulation. The ability-content suite prevents
compiled wire, Flux, startup, and cooldown values from drifting away from the
canonical catalog.

## Edgeweave invariants

The migration preserves the proven FLUX contract:

- only a hostile runtime projectile can reward;
- the swept path must enter a 16-unit outer band without entering the inner hit
  volume;
- the fighter must move at least 260 units/second;
- the fighter must be below maximum Stamina and outside a 220 ms lockout;
- one projectile records each rewarded fighter ID and can never pay them twice;
- simultaneous shots cannot stack because the fighter lockout begins on the
  first ordered reward;
- a reward restores at most 9 Stamina, restarts the ordinary recovery delay,
  applies no damage, and emits a semantic event;
- hits and training/non-runtime projectiles never reward.

## Deliberate limitations

This is a combat kernel, not the full champion slice. It does not yet implement
defeat/respawn, projectile clash, defense, status application, teams beyond
integer ownership, knockback, pierce, fields, material reactions, bots, network
packets, or animation/audio telegraphs. The two projectiles use foundation
debug visuals. Each missing behavior remains gated rather than silently
approximated.
