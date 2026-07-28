# FLUX integration map

Date: 2026-07-28

This map identifies the authoritative source per system before branch
integration. `main` means the stable `78805f1` implementation. `runtime` means
the verified `d77c0b2` Windows/Linux commit. `foundation` means the real
`894f677` + `412b22e` + `addc876` overhaul commits, which remain inactive data
contracts until a later tested vertical slice connects them to production.

| System | Authoritative source | Integration decision |
| --- | --- | --- |
| Live content and character definitions | `main:src/content.mjs` | Preserve stable IDs, ten playable champions, thirteen races, maps, and current kits. |
| Future race/element/ability definitions | `foundation:src/overhaul-content.mjs` | Preserve as validated future schema; do not silently replace live content. |
| Simulation and deterministic tick | `main:src/match.mjs` | No checkpoint patch. Preserve current fixed-tick authority and invariants. |
| Movement | `main:src/match.mjs` | Preserve shipped sprint, hop, slide, wall-kick, landing cut, and speed ceilings. Future movement grammar is descriptive only. |
| Abilities and loadouts | Live: `main`; future catalog: `foundation` | Preserve shipped action/network IDs. Test the future catalog independently until integrated. |
| Fields and reactions | `main` | Preserve authoritative Tide/Ember vapor, Stone/Ember magma, and existing counterplay. Future reaction table is non-live. |
| Destruction | Live behavior: `main`; future bounds: `foundation` | Do not claim checkpoint destruction features. Preserve only validated data limits. |
| Game modes | `main` | Preserve duel, control, WILDMARCH, NIGHT SIEGE, lobby state, and stable mode IDs. Future labels/rules remain compatibility-mapped data. |
| Freeplay / sanctuary | `main` current launch surface | No verified sanctuary implementation exists in real commits; checkpoint version is rejected. |
| Rendering | `main:src/game.mjs` | Preserve fullscreen readability, silhouettes, fields, and error recovery. |
| HUD and menus | `main` | Preserve working Muster Hall and semantic controls. Overhaul HUD documents are design constraints, not executable UI. |
| Input and keybindings | `main` | Preserve persistent remapping, gamepad navigation, and semantic command transport. |
| Bots | `main` | Preserve shipped combat, objective, ultimate, and Wayseal behaviors. |
| Lobbies | `main:src/network/lobbies.mjs` | Preserve discovery, private codes, join-in-progress, and authoritative options. |
| WebSocket server | `runtime` | Preserve authenticated loopback source shutdown and graceful IPC lifecycle. |
| Reconnect | `main` | Preserve opaque token rotation and exact entity reclaim. |
| Spectators | `main` | Preserve read-only slots and zero player-capacity cost. |
| Host migration | `main` | Preserve immediate connected-player promotion and shutdown distinction. |
| Linux launcher | `runtime` | Preserve version 0.34.3 health guard and LF policy. |
| Windows launcher | `runtime` | Preserve `npm.cmd`, native parser validation, and shortcut flow. |
| Electron runtime and security | `main` plus `runtime` release metadata | Preserve sandbox, origin lock, owned children, fullscreen guard, protocol invites, and updater error isolation. |
| Packaging | `runtime:package.json` | Preserve AppImage and NSIS targets; verify both again on unified source. |
| Updater | `main` | Preserve GitHub-provider configuration and known private/no-release limitation. No unverified rollback claim. |
| Tests | `main` + `runtime` + `foundation` | Run all shipped tests plus overhaul data tests. Keep graceful shutdown; reject forced-exit expectations. |
| CI | `runtime` workflow, manually reconciled with pre-transport verification intent | One canonical Windows/Ubuntu workflow; no checkpoint application or tested-source snapshot job. |
| Documentation | Reconciled | Keep actual evidence and limitations; remove stale branch names and contradictory pass claims. |

## Semantic integration groups

1. Use `d77c0b2` as the verified baseline (already the integration branch base).
2. Preserve focused overhaul constraints and compatibility decisions without
   branch-specific transport instructions.
3. Cherry-pick the real foundation code/test commits.
4. Manually reconcile CI into one canonical workflow.
5. Replace stale playable-state claims with unified commands and observed
   results.
6. Verify before publishing `develop`; do not merge `develop` into `main`.

## Explicitly rejected alternatives

- No octopus or wholesale branch merges.
- No `ours`/`theirs` conflict resolution.
- No checkpoint Base64, ready marker, snapshot artifact, or one-shot apply job.
- No Windows forced-termination acceptance when graceful shutdown is available.
- No implicit replacement of current stable content/network/save IDs by future
  schema IDs.

