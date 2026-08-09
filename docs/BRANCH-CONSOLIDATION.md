# Repository and branch consolidation

## Canonical Godot spine

The 2026-08-09 unification uses
`origin/agent/visual-assets-production-v1` at `1e8c531` as the canonical Godot
tree. It contains the complete `origin/main` foundation, skeleton-animation
library, deterministic visual generators, runtime registries, Wellspring
catalogs, champion candidates and their validators. A clean baseline passed
12,070 assertions plus 60 and 120 Hz launches on Godot 4.7.1.

All fetched FLUX2 histories remain reachable:

- `origin/main` at `863bf89`, the Aider foundation, local-workflow, architecture
  and initial character-reference branches are ancestors of the selected spine;
- `origin/agent/skeleton-animation-foundation-v1` at `b7aa7ab` is a merge-only
  tip whose tree adds nothing beyond the selected spine;
- `origin/agent/fix-rendered-sprite-reference-images` at `a6ca114` contains
  earlier concept-only reference boards superseded by the versioned production
  catalogs and the current user-approved style target;
- `origin/agent/odysseus-20260801-033835-48571` at `a6060ed` contains obsolete
  placeholder agent files and an empty command log.

The final three tips are joined as history while retaining the validated current
tree. Their files are still recoverable from Git and the verified all-ref bundle;
none was deleted, rebased or force-pushed.

## Import hygiene

Godot 4.7.1 generated twelve stable script UID sidecars that were missing from
the visual-production branch. They are tracked so a fresh import does not dirty
the canonical checkout. `.godot/` remains an ignored machine-local cache.

## Cross-repository layout

The distinct legacy JavaScript FLUX history is preserved as a web-prototype
lineage and will be imported beneath `legacy/web-prototype/` after its complete
DOM test dependency is prepared. Godot remains the authoritative root described
by `SPECIFICATION.md`; legacy presentation and simulation code does not become
canonical merely because its history is retained.

Dirty work from the former `/home/otp/Projects/flux2` checkout is applied only
after its binary patch/archive recovery state is verified. Tool caches and chat
history are preserved in the backup but never committed into the canonical
repository.
