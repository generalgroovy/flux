# Deterministic combat foundation

## Implemented slice

The protocol-26 foundation extends the first complete command-to-impact path:

- independent scale-1000 aim and held primary input;
- pressed active-one input;
- startup, recovery, and cooldown state compiled independently at 60/120 Hz;
- positive-Flux Arc Primary/Rillshot/Eclipse Disc and paid Vector Lance,
  Tideline, Rimewake and Pocket Eclipse;
- stable projectile/entity/owner/team/source/element IDs plus canonical bounce
  count and on-hit slow strength;
- integer movement/remainders, ordered world collision, swept player hits,
  authoritative damage, lifetime, semantic events, and state hashing;
- replay verification with active primary command streams;
- Edgeweave rewards for deliberate hostile swept near-misses;
- a canonical action-transition policy covering all live movement/control modes
  and projectile, beam, spray and field spell shapes.

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
affordability check on the same tick. Generic cast recovery is presentational
state and does not block an unrelated spell. A pending startup occupies the one
execution channel, while physical control state, own cooldown, Flux, kit and
empty-slot gates emit bounded `cast_refused` reasons and spend nothing.

## Action transition contract

`content/gameplay/action_transition_matrix_v1.json` is loaded fail-closed by the
authoritative simulation. Movement can continue through spell startup and
recovery; a new legal spell can start during recovery; a second spell pressed
during startup reports `startup_commitment`. Launched, grappled, charging,
stunned and rooted actors cannot start a cast and receive a state-specific
refusal. Its canonical hash participates in state and Farflow compatibility.

The policy deliberately separates execution commitment from cooldown. A spell's
own cooldown and positive Flux cost remain legitimate pacing tools; there is no
hidden global post-cast lock. Held-primary cooldown checks remain quiet to avoid
per-tick message spam, while semantic 1–12 presses report the cooldown.

## Foundation abilities

| Ability | Wire | Cost | Startup | Cooldown | Current result |
| --- | ---: | ---: | ---: | ---: | --- |
| Arc Primary | 101 | 7 Flux | 60 ms | 200 ms | 10 Health Charge projectile, speed 1120, 1200 ms lifetime |
| Vector Lance | 110 | 24 Flux | 180 ms | 900 ms | 25 Health Charge projectile, speed 980, 1500 ms lifetime |
| Rillshot (Oh Tipi) | 140 | 6 Flux | 55 ms | 180 ms | 9 Health Water projectile, speed 1060, 1150 ms lifetime |
| Tideline (Oh Tipi) | 141 | 20 Flux | 170 ms | 900 ms | 14 Health Water spray, 280 range, 180 ms launch at speed 420 |
| Rimewake (Oh Tipi) | 144 | 24 Flux | 240 ms | 1800 ms | Ice field, 72 radius/2200 ms lifetime, one 700 ms slow per target |
| Eclipse Disc (S. Wayne) | 142 | 8 Flux | 70 ms | 230 ms | 10 Health Dark disc, speed 900, exactly one world ricochet |
| Pocket Eclipse (S. Wayne) | 143 | 18 Flux | 190 ms | 1000 ms | 8 Health Light beam, 520 range, 600 ms slow to 55% movement |

Values are integer milli-units in simulation. The ability-content suite prevents
compiled wire, Flux, startup, and cooldown values from drifting away from the
canonical catalog. Spending any runtime spell delays Flux recovery by 700 ms;
the HUD names the delay and the following recovery phase.

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
defeat/respawn, projectile clash, defense, broad status application, teams beyond
integer ownership, launch influence, pierce, fields, material reactions, bots,
network packets, or animation/audio telegraphs. Tideline is the first bounded
authoritative launch, Eclipse Disc the first bounded ricochet and Pocket Eclipse
the first bounded slow; the Nexus effigy remains the first resettable target.
Each remaining behavior stays gated rather than silently approximated.
