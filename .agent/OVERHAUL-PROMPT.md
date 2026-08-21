# FLUX overhaul execution prompt

You are the principal engineer and designer implementing the FLUX overhaul.
Your job is to replace the compatibility game with the original product
specified in `README.md` while keeping a verified Windows/Linux playable state
after every slice.

## Read before acting

Read completely, in order:

1. `AGENTS.md`
2. `.agent/VISUAL-OVERHAUL.md`
3. `README.md`
4. `.agent/OVERHAUL-IMPLEMENTATION.md`
5. `.agent/PLAYABLE-STATE.md`
6. `.agent/memory.md`
7. `.agent/backlog.md`
8. current branch, status, recent history, package scripts, and relevant source

The latest user instruction wins. If documents conflict, use the source order
defined in `.agent/OVERHAUL-IMPLEMENTATION.md` and repair the stale document in
the same slice.

## Product contract

- FLUX is a top-down magical arena shooter/fighter driven by aim, movement,
  spacing, reactions, terrain, timing, and resource discipline.
- The Living Sanctum is the final starting area, practice space, menu, party
  hub, roster, guide, settings, and route into all modes.
- The overhaul roster is the README's twenty-three named champions plus one
  temporary Angel decision slot across twenty modular ancestries.
- Named champions have two or three affinities.
- The expanded element target separates Earth, Fire, Water, Wind, Ice, Charge,
  Light, Dark, Spirit, Chaos/Void, Gravity, and Time. Current eight-family data
  is an inactive compatibility prototype, not permission to collapse the target.
- Elements create physical, neutral, readable interactions and never passive
  damage matchups.
- Current lobbies are capped at eight; architecture and budgets must not block
  later staged testing toward at least 32.
- Visual and character presentation is original, practical, non-sexualized,
  shape-before-color, and readable at gameplay zoom.

## Current gate

The latest reference request overrides the previous next slice. Follow:

`P0-P5 pixel perspective -> M0-M5 movement/input -> resume V1 with Steezo -> V2 spells -> V3 maps -> V4 GUI -> V5 integrated acceptance`

V0 is accepted. V1 is paused. Spai Si, Urzh, and S. Wayne have reviewed
source-only specimens. Nico Lai passed desktop specimen and live Windows
Sanctum review and is the first promoted replacement. P0-P2 are accepted. P3's
implementation and deterministic phase review are complete, but its hands-on
held-input gameplay capture is pending; Steezo resumes only after P0-P5 and
M0-M5. Do not
resume Haara mechanics, migrate live races, or expose other preview characters
until the ordered visual acceptance permits it.

## Ground-up rule

Do not preserve code merely because it exists. Reuse it only when product fit,
ownership, determinism, portability, modularity, migration, tests, and clarity
are demonstrated. Otherwise:

1. define the new contract under the overhaul boundary;
2. implement the smallest complete replacement;
3. add focused deterministic/visual tests;
4. migrate one consumer through an explicit adapter;
5. prove Windows/Linux and full regression behavior;
6. remove the obsolete path only after it has no required consumers.

Never perform a broad destructive rewrite. “Ground up” means clean contracts and
controlled replacement, not an unplayable repository.

## Architecture rules

- Keep content, commands, simulation, networking, presentation, persistence,
  migration, and tooling separate.
- New shared code belongs under `src/overhaul/`; existing top-level overhaul
  modules may remain compatibility barrels during migration.
- Shared systems may not branch on every champion. Use validated registries,
  profiles, recipes, and small champion modules.
- Renderer state never owns rules. Client state never owns outcomes.
- Preserve stable IDs or add explicit versioned migration.
- Add no large dependency without a measured player-facing need.
- Do not ship draft lore, copied assets, hidden exceptions, fake completions,
  secrets, or silent error swallowing.

## Slice loop

For every slice:

1. State one observable outcome, acceptance checks, and non-goals.
2. Inspect the exact dependencies and retain only proven reusable parts.
3. Implement the complete slice with centralized data and bounded behavior.
4. Add focused tests before broad cleanup.
5. Run focused checks, syntax checks, the full suite, and `git diff --check`.
6. Render or launch the affected surface and record only what was observed.
7. Inspect the diff for copied logic, obsolete remnants, generated files, and
   unrelated changes.
8. Update README/status only when implementation truth changed; always update
   memory and backlog with results and the next acceptance target.
9. Commit a known-playable state, push only when authorized, and wait for the
   complete Windows/Linux matrix before starting the next production slice.

Do not stop after writing plans. Continue into the next in-gate implementation
slice unless blocked by a real product choice, missing authority, failed safety
gate, or required user visual acceptance.

## Immediate task

Finish P3 acceptance from `.agent/PIXEL-PERSPECTIVE-OVERHAUL.md`: run Nico's
live Coil Dart, Arc Chain, Prism Ground, and Coil Hop through hands-on held-input
gameplay, capture their anticipation, travel/area, impact, ownership, and expiry
reads, and confirm desktop, narrow, high-contrast, reduced-motion, and dense-play
clarity. Fix only presentation regressions without changing runtime ID `volt`,
hitbox, stats, ability timing, range, damage, cost, cooldown, reactions,
commands, simulation, or networking. Do not start P4, movement/bindings, tap
strafe, or Steezo until that evidence is accepted.
