# Q/V default revision and Small-template next artifact review

Status: independent implementation/art review complete; input/preferences focused
run passed. UI integration, current render and Full remain separate pending gates
at this review handoff. Date: 2026-09-09.

Scope: read-only production/test/art review; this document is the only file owned
by this lane. No engine, generation, assembly, import, source/test edit or public
write was performed. Existing dirty changes and historical artwork are retained.
Authority: `SPECIFICATION.md` and `.agent/OVERHAUL-IMPLEMENTATION.md`; the active
remaining-allowance floor is 33%, not the older cutoffs in checkpoint documents.

## Binding review: intent and compatibility

Requested fresh/reset defaults are **Technique V / Evade Q**. These remain two
different semantic actions: no movement cost, collision, immunity, input buffer,
network field or simulation rule should change. Controller B / left trigger and
mouse bindings remain unchanged; saved custom bindings stay authoritative.

Initial source was preferences schema11, Technique Q / Evade V. Its earlier
schema<11 full-default migration reversed the schema10 V/Q pair. Changing only
`DEFAULT_KEYBOARD_BINDINGS` would therefore make historical/default completion
depend on today's values and risk reinterpreting older saves.

The implementation owner selected an additive `keyboard_defaults_revision=1`
while retaining schema11. This avoids rejection of an entire new save by the
installed schema11 reader. Historical defaults must remain frozen: schema11 Q/V,
schema10 and earlier V/Q. Only an **unrevisioned, raw complete exact old-v11
keyboard dictionary** may migrate; a partial dictionary, changed unrelated key,
explicit unbind, or revision1 old pair preserves its existing meaning. This is
the implemented design inspected in this review. No production migration blocker
was found. The focused runtime coverage and remaining gates are recorded below.

Downgrade boundary: an older reader may ignore/drop the additive revision when
resaving. The current V/Q layout survives that round trip. If a player deliberately
chooses the exact full old-default Q/V keyboard layout, however, an old reader's
marker-stripping resave loses the distinction between that intent and an untouched
legacy default. The next new-reader load can then migrate it. Do not promise
lossless intent recovery across that information-losing downgrade.

Acceptance checklist (passed runtime scope versus pending integration is below):

- Fresh construction and Controls reset show Technique V / Evade Q, without
  duplicate physical-key triggers; router semantic commands stay unchanged.
- Complete old-v11 defaults migrate once; old-v10 defaults already retain the
  requested meanings; older added-action conflicts never steal custom keys.
- Partial saves, one unrelated custom key, explicit unbinds, and revision1 exact
  old-default layouts retain their values. Save/reload is idempotent.
- Absent revision is accepted; invalid strings, booleans, fractional/nonfinite
  numbers and unsupported revisions fail without mutating existing state.
- Invalid late mouse/controller data cannot partially commit a new revision or
  migrated keyboard dictionary. Existing sound, POV, address and other devices
  survive valid migration and old-reader-shape round trips.
- Compendium rows/Details, movement coach and Controls labels follow defaults,
  rebound keys, unbound state and controller selection. Input interruption and
  rearm behavior remains unchanged.

## Help-text dependencies for the integrating task

| Surface | Source seam / initial finding | Needed action |
| --- | --- | --- |
| Player entry | `README.md:134-135` hardcodes Evade V / Technique Q | Update current default rows to Q / V and explain custom profiles are retained |
| Controls Lectern | `src/app/bootstrap.gd:1269`, `control_binding_editor.gd:174` call `binding_label` | No new key literal; verify current preferences reach labels |
| Reset controls | `src/app/control_binding_editor.gd:132` uses current default dictionaries | Verify revision handling and resulting reset/save round trip |
| Movement table + Details | `movement_guide_model.gd:7-14` resolves `{evade}` / `{technique}`; `player_compendium.gd:66-70` rebuilds rows on open | No hardcoded Q/V edit; focused default and rebound assertions |
| Southern practice card | `movement_practice_coach.gd:13`, `:79-82` resolves keyboard/controller then mouse fallback | No hardcoded Q/V edit; verify Technique V text and retained custom labels |
| Campus movement station | `content/maps/sanctum_campus_g2_v1.json:45` names actions without Q/V | No map/content change needed |
| Earlier movement acceptance | `docs/MOVEMENT-CONTROLS-ACCEPTANCE.md:78,90-91` and `LOW-HOP-CHEMISTRY-CHECKPOINT.md:16,23` record V evade/Q technique | Preserve named-build evidence; add current-default supersession pointer if needed |
| Other old prose | `docs/PLAYER-CONTROLS-AND-POV.md:10,34,50` and `DEVELOPMENT.md:78` already say Q evade/V technique | Matching letters do not make older mechanics/claims current; avoid broad rewrite |
| Repository memory | `.agent/memory.md:53` summarizes the prior schema11 swap | Root-owned current summary update; preserve historical entries |
| Existing captures/logs | Earlier guides and preference receipts may show the old defaults | Keep historical; any new default UI proof needs a new isolated output |

`src/app/bootstrap.gd:611` uses Ctrl+V for address paste; it is not a Technique
literal and must not be changed. Searches of current `src` and `content` found
no other hardcoded Q/V movement-help copy. Test literals in preferences, router,
binding editor and older movement migration tests must distinguish current
expectations from frozen historical fixtures, not undergo a global replacement.

## Exactly one next Small-neutral artifact, proposed only

Propose a fresh **South grounded + walk A + walk B source board** at
`art_batches/character_style_v1/template_small/south-pilot-v3/source-original.png`,
with its immutable prompt and honest source-review evidence in the same new
candidate folder. This is the smallest useful contact unit: an isolated pair
does not provide the South-grounded calibration required by the shared assembler.
Do not expand to another heading, all80 cells, another body size or named art.

Current v2 inspected directly:

- `south-pilot-v2/source-original.png` is 1536x1024 **Format24bppRgb**, corner
  alpha255, SHA256 `85089fa23a7b1ecd31e48e11afba4107c40935321a0cd1eaf1ea67e54c3c7d90`.
  The painted checkerboard is opaque image content, not real transparency.
- Legs visibly exchange extended/lifted roles, but both walk poses keep the
  viewer-left arm bent near the waist. The opposite arm counter-swing is not a
  defensible A/B pair. Transparency cleanup alone cannot repair this motion defect.
- Exact camera elevation, fixed native58px anatomy and registration remain
  unestablished. No v2 cells are approved; the v1 South partial remains a1/80-cell
  technical proof, not completed Small coverage.

Reuse these existing inputs with explicit roles:

| Existing path | Role |
| --- | --- |
| `art_batches/character_style_v1/template_v2/small-south-base-v1.png` | Neutral wardrobe and actual standing reference |
| `art_batches/character_style_v1/template_v2/contact-guides-v2/small-south.png` | Current fixed-bone anatomical support/arm construction only |
| `reference/art/oh_tipi_authority_v1/oh-tipi-authoritative-reference.png` | Pixel-cluster/outline grammar only; no named identity or props |
| `scripts/build_character_style_pack.gd` | Existing neutral-aware assembler; exact IDs at217-229, South-reference/global-scale guard at264-270 |
| `scripts/test_character_style_pack.gd` | Focused shared-builder regression path |
| `scripts/review-character-sheet.ps1` and `scripts/validate-character-art-review.ps1` | Native technical inspection and hash-bound review integrity; neither certifies anatomy |
| `art_batches/character_style_v1/template_small/south-pilot-v1/source-layout.json` | Existing exact neutral identity/layout format; not permission to reuse its crop/scale for a new source |

The `template_v2/README.md` paragraphs that call neutral assembler support
"planned" are stale relative to the current implementation. Do not add a second
assembler or revive the old importer to work around that prose.

Admission for this one future artifact: genuine transparent alpha; exact South
yaw with agreed elevation; same head/torso/limb dimensions and one standing-derived
scale; anatomical-left support A and anatomical-right support B with visibly
opposed arms; practical neutral empty-hand body only. If source review passes,
the same assembler may produce an isolated three-cell **partial** native proof:
96px cells, standing58px, pivot48/84, actual occupied last row83, empty gutters,
no independent pose fitting. Review light/dark and native/game-scale A/B playback.
If alpha, arms, anatomy or yaw fail, retain a held attempt and stop, not another
generation loop. Three readable cells still do not pass B2/B5 or permit named art.

The later generation owner must read the applicable imagegen skill and required
references before the single authorized attempt. This review did not invoke
generation, assign new source crops, manufacture alpha or certify human acceptance.

## Evidence status

Completed here: current contract/queue and source inspection; direct view of the
held v2 board, current South contact guide and v1 native proof; independent v2
format/dimension/SHA check; risk messages to implementation and integration owners.

The final preferences implementation was read after the edit: frozen historical
dictionary, scalar validation, raw-complete migration predicate, staged device
validation before state commit, and revision1 serialization. The new preferences
and physical-input tests were also read. The owner ran the focused checks; this
lane read the resulting log and verified the stderr file has zero bytes.

| Evidence | Result / boundary |
| --- | --- |
| `.godot/qv-default-work/focused-v2.log` | Official Godot4.7.1; input-router593 + player-preferences849 = **1,442 assertions, zero failures** |
| `.godot/qv-default-work/focused-v2.log.err` | Zero bytes |
| Preference cases | Schema1-11; complete/partial/custom/unbound; explicit0 and JSON whole-number values; revision bounds; current/old-layout persistence; late device-failure nonmutation |
| Actual input fixture | New, migrated and customized profiles replace stale aliases; each physical Q/V event reaches only its configured paid command, with held/release edge checks |
| Old-reader compatibility | Serialized-shape test only, not execution of an installed older binary; intentional exact-old-layout marker-loss caveat remains |
| Earlier focused-v1 attempt | Owner reports a test-only extra parenthesis, corrected before v2; failed historical logs retained, not included as passing proof |
| Controls/guide/coach integration | Not certified by the two focused suites; root owns current labels/assertions and remaining runs |
| Actual Q/V UI capture, Full, export/install | Not run by this lane; no new pass claimed here |

At handoff, `tests/unit/test_control_binding_editor.gd:58-59` still expected old
Evade V / Technique Q, and `README.md:134-135` still printed the old default pair.
Both were reported to the integrating owner for correction before Full. These
were outstanding integration items, not a failure of the two passing suites.
Root subsequently corrected both, added five source-derived guide assertions,
and passed Full91/463,294 with zero failures/stderr (79.550s). Current Controls
and movement-card captures show V Technique / Q Evade. The original focused
receipt above is not relabeled as this later integrated result; see
[final Full receipt](full-receipt.json) and [checkpoint](../../QV-RUNTIME-CHECKPOINT.md).

Small v3 remains **proposed only**: not generated, assembled, accepted or promoted.
No human playtest, visual acceptance or older-installed-build execution is inferred
from the source inspection or assertion counts.
