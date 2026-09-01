# FLUX 2 active backlog

This queue reflects the current user-ordered path to the first-eight chemistry
playtest. Completed detail belongs in `WORKLOG.md`; this file stays short,
playable, and acceptance-driven.

**Active platform scope:** Windows only. Existing Linux compatibility is
preserved but receives no new packaging or acceptance work until the user
reopens that scope. Automatic Linux CI is disabled; the source-controlled
foundation workflow is a deliberate manual Windows gate so failed development
runs cannot generate notification floods.

| Order | Complete playable slice | Acceptance |
|---:|---|---|
| 0 | **One authoritative product — complete** | Imported browser runtime retired with remote recovery recorded; README/roster truth reconciled; full Godot gate green without touching user-owned local files. |
| 1 | **Plug-and-play lifecycle — implementation complete; release acceptance gated** | `FLUX.exe` embeds the verified portable payload and owns install/repair/update/start without admin/dev tools; the current PCK boots at 120 Hz. This managed workstation blocks every newly exported unsigned EXE under Application Control, so exact-wrapper execution, signing, NAT/relay automation and physical two-PC proof remain honest gates. |
| 2 | **Whole-scene visual cohesion — complete** | Reusable Wellspring modules, eight-way body/action art, empty-hand spells and compact HUD pass the 4.64/5 D7 rubric; V10 density preserves ownership and escape lanes across zoom/accessibility profiles. |
| 3 | **Three viable body roles + Red Baron — complete in source** | Small skirmisher, middle adapter and large anchor use direction-invariant 58/68/76px body templates, shared collision, runtime scale `1.0` and universal movement on equal budget; Red Baron is selectable with eight-way body/clothing art, identity HUD portrait, Cinderbolt/Rimewake and 120 Hz combat tests. Exact interactive capture remains part of the checkpoint. |
| 4 | **Readable bullet-pattern pressure — complete in source** | Cinder Fan deterministically emits `-24,-12,0,+12,+24` lanes with ordered IDs, one cost, single-hit protection, bounded collision/snapshot work, a readable 28–46 px projectile envelope and clean evasion lanes at 120 Hz; the Proving Court floor now exposes quiet lanes and four response pockets. |
| 5 | **Eight elemental bursts — active next** | Fire, Water, Earth, Wind, Charge, Ice, Light, and Dark each provide a positive-Flux configurable burst through the global 3×4 Spell Loom; element changes presentation/chemistry identity, never hidden fan geometry or automatic damage advantage. |
| 6 | **Complete first-eight chemistry** | All 36 symmetric pairs validate, form from bounded elemental exposure, create readable spatial effects through shared primitives, decay/residue/reset deterministically, preserve worldbone and route budgets, replicate/replay, and can be tested/explained in the Elemental Crucible at 120 Hz. |
| 7 | **Playtest pause** | Package the exact green Windows build, provide the focused Wellspring → movement lane → pattern lane → Crucible → Farflow route, and wait for player feedback before roster expansion. |

## Non-negotiable slice rules

- Keep `main` launchable at every interruption boundary; maintain
  `codex/continuous-overhaul` as its unified compatibility branch.
- Prefer one reusable data contract over eight or thirty-six bespoke scripts.
- Simulation/host owns legality and outcomes; presentation owns only readable
  interpretation.
- Every attack costs Flux; movement costs Stamina only where authored.
- Every refusal explains physical state, resource, cooldown, slot, or authority.
- Preserve protocol/wire IDs or migrate versions explicitly.
- Run focused tests first, then full deterministic tests, Windows source/import
  boots, packaged boot, and relevant Farflow processes before a green checkpoint.
- Never stage/delete `node_modules/` or `scripts/firewall.ps1`.
