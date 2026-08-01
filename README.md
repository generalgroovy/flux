# FLUX 2

FLUX 2 is the Godot 4.x reimplementation and production-design workspace for FLUX: a fast top-down elemental arena game built around expressive movement, reactive terrain, readable systemic interactions, and hostable peer-to-peer multiplayer.

## Engine direction

The target runtime is **Godot 4.x**. Godot owns presentation, authoring, input, audio, animation, UI, platform export, and transport integration. Canonical gameplay runs in a renderer-independent deterministic simulation layer.

- Engine: Godot 4.x
- Primary scripting: typed GDScript for scenes, tools, UI, and orchestration
- Performance modules: GDExtension in Rust or C++ only after profiling identifies a hotspot
- Simulation: fixed-tick, data-oriented, deterministic, host-authoritative
- Native networking: ENet
- Web networking: WebRTC data channels
- Hosting model: player-hosted authoritative listen server with optional relay fallback
- Initial platforms: Linux and Windows
- Secondary platform: Web export where feature and performance gates pass

See [SPECIFICATION.md](SPECIFICATION.md) for the normative architecture, networking, project layout, migration plan, and acceptance gates.

## Core design documents

- [Godot 4.x production specification](SPECIFICATION.md)
- [Reactive pixel-material and chemistry system](docs/reactive-material-system.md)
- [Character sprites and skeleton reference](reference/character-sprites/README.md)

![Front view reference preview](reference/character-sprites/front-views-board.png)

## Architectural rule

Godot scene nodes are presentation and integration objects, not the canonical game state. The authoritative simulation must be executable headlessly, serializable, replayable, and testable without rendering.

```text
Input commands
      |
      v
Deterministic fixed-tick simulation
      |
      +--> authoritative snapshots / replay log
      |
      v
Godot presentation adapters
      |
      +--> sprites, animation, particles, sound, UI, camera
```

## Development phases

1. Establish the Godot project skeleton, CI, formatting, headless tests, and export presets.
2. Implement one-room local movement with deterministic input-command playback.
3. Add host/join over ENet, client prediction, reconciliation, and snapshot interpolation.
4. Add WebRTC signalling and browser-compatible hosting.
5. Integrate abilities, elemental fields, reactive materials, bots, and map tooling in bounded slices.
6. Add reconnect, spectators, migration snapshots, performance budgets, and release packaging.

## Non-negotiable acceptance gates

A feature is not production-ready until it passes deterministic replay, host-authority, reconnect, performance, gameplay readability, map-safety, and Linux/Windows parity tests. Web support is additive and may not weaken native correctness.

## Repository status

This repository currently contains specifications and production references. Runtime implementation should follow the directory and ownership rules in `SPECIFICATION.md` rather than embedding authoritative state directly in scenes.
