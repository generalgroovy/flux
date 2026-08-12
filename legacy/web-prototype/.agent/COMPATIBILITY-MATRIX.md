# FLUX compatibility matrix

Branch: `agent/resource-hud-first-slice`

| Surface | Must remain working during each slice | Verification target |
| --- | --- | --- |
| Linux source desktop | Pull/update, locked install, tests, Electron launch, bounded shutdown | `bash scripts/pull-and-run.sh` and `npm start` |
| Windows source desktop | Pull/update, locked install, tests, Electron launch, bounded shutdown | `scripts\pull-and-run.ps1` and desktop shortcut flow |
| Linux package | AppImage launch and verified release update path | packaged smoke test |
| Windows package | NSIS install/launch and verified release update path | packaged smoke test |
| Solo | Character, map, mode, resources, objectives, reset | DOM and simulation tests |
| Local multiplayer | Two semantic input maps, equal rules, readable HUD | DOM and simulation tests |
| Bots | Ability payment, movement, fields, objectives, destruction | deterministic soak |
| Remote host/join | Server authority, input validation, snapshots, prediction | network tests |
| Join in progress | Protected spawn and exact current content state | lobby/network tests |
| Reconnect | Exact entity reclaim without duplication | network tests |
| Spectator | Read-only state and no input authority | network tests |
| Host migration | Lobby continuity and authoritative replacement | lobby/network tests |
| Saved settings | Stable IDs, migrations, corrupt-value fallback | persistence tests |
| Existing characters | Current ability names, kits, silhouettes, bots, network behavior | content and match tests |
| Approved new characters | Canonical character and ability names unchanged | content validation |
| Input | Keyboard, mouse, gamepad, semantic commands | DOM and network tests |
| Accessibility | Focus, keyboard navigation, readable labels, non-color cues | DOM tests/manual smoke |
| Freeplay modifiers | Never leak into competitive or remote standard rules | rules isolation tests |
| Flux economy | Identical local/server payment and recovery | deterministic match tests |
| Element reactions | Stable order, ownership, lifetime, cleanup | deterministic reaction tests |
| Destruction | Server-owned state, bounded work, reset/reconnect parity | simulation/network tests |

## Stable compatibility contracts

- Preserve existing internal character, race, map, and mode IDs until explicit migrations exist.
- Preserve `special` as the tactical wire alias while current protocol peers depend on it.
- Transmit semantic actions, not physical key codes.
- Rendering must not own game rules.
- Character and approved ability names are canonical content, not disposable UI copy.
- Player-facing simplification may change labels without changing stable IDs.
