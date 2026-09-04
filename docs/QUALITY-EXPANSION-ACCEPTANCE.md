# Quality expansion acceptance program

Status: **active; Q0-Q1.2 are green source slices, Q2 spell matrix is next**.

This program orders the current usability, movement, spell-grid and animation
requests into independently playable checkpoints. The aim is a crisp,
room-readable bullet-pattern action game with FLUX's own old-world identity—not
a copy of any reference game's assets, rooms, interface, weapons or mechanics.

| Gate | Player-facing outcome | Required proof |
|---:|---|---|
| Q0 honest world — green | Only authoritative worldbone, functional stations and combat targets appear as physical map objects; no object fades when approached. | All 14 visible buildings compile one-for-one into collision; 91 walk-through decorations and six collisionless landmarks are withheld; focused map/occlusion suites pass; `honest-world-75-v1` inspected. |
| Q1 momentum language — green | Held Jump reaches a 54 px paid apex over a 28 px tap; held Slide can continue from 150 to 480 ms; takeoff/conversion retains earned planar speed; airborne wallrun and wallrun-to-air-dodge work. | 1,294 movement and 797 transition assertions pass at 120 Hz; the 900-unit speed cap and short opening protection windows remain authoritative. |
| Q1.1 combo economy — green | A compact HUD cue exposes the next continuation premium; cost rises 10% per action to 40%, then resets after 333 ms without continuation. | Host prediction/replay canonical state and packed schema-13 snapshots share the counters; refused inputs and holds do not increment them; eight-player packet remains below the 1392-byte MTU. |
| Q1.2 resource retune — green | Every champion gains a body-role-appropriate Stamina reserve; spell Flux costs fall 14–20% while every attack still costs Flux. | Catalog/body bounds and accepted definition signatures updated; 4,210 focused resource/combat assertions pass. |
| Q2 spell matrix | The Loom lists elements by row and delivery families by column; every first-eight element has one validated spell for each accepted attack family. | Stable unique wire IDs; deterministic catalog order; no empty matrix cell; all spells globally configurable; packet/entity/work budgets pass at eight-player pressure. |
| Q3 elemental casting clarity | Cast hands, release cue, projectile body, trail, impact and field boundary share one unmistakable element grammar and distinct delivery silhouette. | Normal/high-contrast/reduced-effects review; color is reinforced by shape and motion; no dual-element attacks before chemistry acceptance. |
| Q4 crisp character motion | Nearest-neighbor silhouettes retain stable size/pivot and use natural bounded contacts/transitions in all eight directions. | No filtered edge, frame-size drift or spell pixels in bodies; sequence review proves leg alternation and readable jump/slide/roll phases. |
| Q5 integrated checkpoint | Windows source/package remains one-step playable and remote-session compatible at the published protocol. | Full and Release gates, truthful captures, Farflow host/join/reconcile/quit, then human playtest pause. |

## Constraints

Worldbone truth beats decoration. Momentum can be retained but never generated
without an authored impulse, and all speeds remain bounded. Combo escalation is
an explicit Stamina price, not a hidden input lock. Each attack remains paid;
lower Flux costs must increase expression without enabling permanent lane
coverage. The spell matrix expands through shared delivery kernels and reusable
presentation assets, never one bespoke script per spell.

## Current evidence

| Check | Actual result |
|---|---|
| Honest-world focused | `wellspring-illustrated-kit`, campus layout, sight occlusion and natural-map suites: 327 assertions, zero failures/stderr |
| Momentum/network focused | Movement, transitions and snapshot: 2,170 assertions, zero failures/stderr; broader eight-suite movement/network/HUD set also green |
| Resource/combat focused | Ability data, compiled definitions, combat, champions, body profiles and resources: 4,210 assertions, zero failures/stderr |
| Full repository | 67 suites, 22,906 assertions, source import and protocol-36 120 Hz boot; zero failures/stderr in 36,885 ms; `.godot/receipts/honest-world-momentum-full.json` |
| Visual review | Truthful 75% capture `.godot/visual-captures/honest-world-75-v1`; collisionless scenery withheld and no approach fade |
