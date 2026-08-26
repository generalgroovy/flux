# Player-experience overhaul

This is the compact delivery contract for download-to-play, controls, spells,
codex, expression and gameplay-scale visual replacement. Runtime truth and
acceptance status remain in `README.md`, `.agent/memory.md` and the worklog.

| Surface | Current playable truth | Next accepted state |
| --- | --- | --- |
| Get the game | One Windows setup verifies and installs a versioned per-user build without admin or developer tools | Signing, clean uninstall UI, public update discovery and two-PC release proof remain gated |
| Start/close | Game starts in the Wellspring; explicit close flushes preferences and network | Every UI/OS/host-loss exit path uses the same tested lifecycle and leaves no helper process |
| Host/join | Walk-up Host/Join Farflow supports direct-IP ENet and eight players; Join accepts type/paste and saves the last valid address | Copyable host card, automatic NAT/relay and physical two-machine package proof remain gated |
| Controls | The in-world lectern captures keyboard, mouse button/wheel and controller input with visible swap/unbind/reset/cancel, reduced-effects/high-contrast toggles and immediate persistence; camera zoom persists at 50/75/100% | Add sensitivity/dead-zone and named-profile layers after the 3×4 spell weave stabilizes |
| Spells | Protocol 26 carries twelve Plain/Ctrl/Alt positions over buttons 1–4; all seven live spells pay positive Flux, three cadence tiers fail closed, the HUD names WAIT/RISING, and the Loom repositions proven projectile/beam/spray/field spells while honest empties refuse | Persist chosen arrangements, then promote one complete four-role element at a time |
| Information | HUD/station bubbles expose immediate state; README holds full tables | One derived translucent codex exposes only canonical playable content and never obscures urgent combat state |
| Expression | One replicated semantic emote exists | Eight-way hold/aim/release radial intent with original lines per champion and visibility-safe translucent bubbles |
| Visuals | V0–V6 provide original compact champions, tilted facades, clean floors, material reads, restrained auras, compact HUD and reviewed standard/accessibility/Farflow frames | Keep animation response and charm improving inside each playable slice without giving presentation rule authority |

| Order | Complete slice | Minimum proof before checkpoint |
| ---: | --- | --- |
| 1 | Windows setup/update + safe lifecycle — complete | Template identity, runtime-only export, checksums, atomic version switch, packaged boot/close, no stray process |
| 2 | Preference schema 9 + defaults — complete | Migration, conflicts, wheel edges, four buttons/two modifier layers, zoom, accessibility, saved join address, controller persistence, save/reload, 60/120 Hz |
| 3 | Wellspring Controls lectern — complete | Input capture/cancel/swap/unbind/reset, inspected 1280×720 capture, offline/full-suite proof; package smoke remains a release-gate recheck |
| 4 | Twelve semantic spell positions — complete foundation | Content validation, deterministic commands/replay, mismatch refusal, layered HUD, host-authoritative Loom configuration and inspected 720p state |
| 5 | Spell/material fixtures | One readable example per enabled element, authority, bounded work/reset and material safety tests |
| 6 | Derived player codex | Registry consistency, keyboard/controller navigation, combat suppression and accessibility checks |
| 7 | Expression radial | Eight stable intents, cooldown bounds, cancel behavior, replication and non-leakage |
| 8 | Gameplay-scale pixel kit | Character → spell → map → GUI → integrated captures, alignment, cutaways and frame budgets |

The supplied games and images are mood/readability references only. FLUX ships
no copied pixels, maps, camera metrics, layouts, symbols, palettes, sprites,
characters, interface, animation, audio, mechanics or trade dress.
