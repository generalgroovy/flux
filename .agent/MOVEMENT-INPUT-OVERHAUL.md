# FLUX movement and input overhaul

## Scheduling

This is the second task and begins only after
`.agent/PIXEL-PERSPECTIVE-OVERHAUL.md` P0-P5 acceptance. It may refine movement
and input directly because the user explicitly requested it, but it must preserve
authoritative fixed-tick ownership, bounded Stamina costs, stable command IDs,
network prediction/reconciliation, collision safety, and accessibility.

## Existing baseline versus requested work

| Movement | Current state | Next-task action |
| --- | --- | --- |
| Cardinal/diagonal ground movement | Implemented with independent aim | Preserve; add digital/cardinal input tests and pixel-facing animation |
| Jump/double jump | Implemented as bounded arcs | Preserve mechanics; replace the weak presentation with body lift plus an enlarging soft ground shadow as explicitly requested |
| Sprint/counter-strafe | Implemented | Preserve; move to conventional bindings and improve input prompts |
| Slide/slide jump | Implemented | Preserve conversion windows; give slide a dedicated default button |
| Wall jump | Implemented internally as wall kick | Standardize player-facing naming and prompts; preserve wall-memory lockout |
| Air redirect/aerial turn | One bounded redirect implemented | Refine into one clear analog/digital aerial-turn grammar |
| Air dodge/wavedash | Implemented | Preserve timing and speed ceilings; make the default chord/button discoverable |
| Vault/superglide | Implemented only at marked rails | Preserve fail-closed collision and marked-route requirement |
| Tap strafe | No distinct live mechanic | Add one bounded edge-triggered aerial turn that consumes the redirect allowance and never adds speed |

## Proposed remappable defaults

All actions remain semantic commands so keyboard/mouse and controller produce
the same authoritative input. Player 2 may use a second controller; fixed
secondary-keyboard bindings remain available as a fallback but do not dictate
the primary layout.

| Action | Keyboard/mouse | Controller |
| --- | --- | --- |
| Move | `WASD` | Left stick / D-pad |
| Aim | Mouse | Right stick |
| Jump / double / wall jump | `Space` | South face button |
| Sprint | `Left Shift` | Left-stick click |
| Slide / air dodge | `Left Ctrl` | East face button |
| Movement technique / redirect / vault | `Left Alt` | Left shoulder |
| Primary | Left mouse | Right trigger |
| Tactical | Right mouse | Right shoulder |
| Defense | `Q` | Left trigger |
| Champion mobility | `X` or Mouse 4 | West face button |
| Ultimate | `F` | North face button |
| Interact | `E` | D-pad up |
| Field guide | `F1` / `F2` | View/Select + D-pad up |
| Pause / close station | `Escape` | Menu/Start |

No technique may require a mouse-only side button. Every chord receives a
single-button remapping option and an on-screen glyph for the active device.
Device switching must be immediate and may not clear held/pressed edges into a
phantom command.

## Jump presentation

The world position stays at the feet. During a jump, render the champion body on
a vertical presentation offset while retaining a soft oval at the ground
anchor. Per the user's requested read, the shadow grows wider and slightly
darker toward the apex, then contracts into the landing frame; its center never
moves away from the collision position. The offset/shadow curve derives only
from deterministic jump phase, never wall-clock animation. It applies to jump,
double jump, wall jump, slide jump, air dodge, vault, and superglide with
distinct bounded profiles. High contrast adds an outline; reduced motion keeps
the state change but limits lift/stretch.

## Bounded tap-strafe / aerial-turn rule

Tap strafe is an original deterministic **aerial turn**, not a replication of a
reference game's engine exploit. After jump, slide jump, wall jump, or vault,
one fresh directional edge inside a short authored window may rotate carried
horizontal momentum toward that direction. It:

- consumes the existing one-per-airtime redirect allowance and an explicit
  Stamina cost;
- accepts keyboard edges or an analog stick crossing a tested activation
  threshold;
- caps turn angle and blend, preserves or reduces speed, and can never add
  velocity;
- is unavailable during fixed-lane air dodge, wavedash commitment, knockback,
  stun, or ability-owned forced movement;
- resolves through the same command, prediction, server validation, snapshot,
  replay, bot, and reconnect paths;
- emits one concise cue and exposes timing in the Training Court.

## Delivery order and acceptance

| Slice | Observable result |
| ---: | --- |
| M0 | Semantic input/action matrix, device glyphs, remapping migration, duplicate/reserved-key handling, and no phantom edges |
| M1 | Conventional keyboard/controller defaults with complete Sanctum and contest prompts |
| M2 | Pixel-facing walk/run plus deterministic body-lift/enlarging-shadow jump presentation |
| M3 | Existing slide jump, wall jump, air redirect, air dodge, wavedash, vault, and superglide revalidated under both devices |
| M4 | New bounded tap-strafe/aerial-turn slice with deterministic unit, network, soak, and collision tests |
| M5 | Training Court teaching route, accessibility, controller disconnect/reconnect, latency, Windows/Linux, and hands-on feel acceptance |

Acceptance requires no diagonal speed advantage, no infinite wall/air loop, no
free velocity, no unmarked-cover crossing, no camera-dependent outcome, no
keyboard/controller rules divergence, no lost reconnect state, and no obscured
ground anchor. Tune windows only from captured test/feel evidence.
