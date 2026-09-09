# W4 — plain ingredient versus active reaction presentation

2026-09-09. Local source implementation; coordinated focused checks passed. Actual game rendering and human acceptance are not claimed here. No engine was launched by this lane.

The originally proposed `pixel_magic_effects.gd` does not exist. Root approved corrected ownership: `src/presentation/element_chemistry_presenter.gd` and `tests/unit/test_element_chemistry_presenter.gd`. The magic-library provenance pin remains root-owned.

## Bounded change

`deposit_role_profile(trail, reduced)` is a pure reusable presentation contract. Every plain element is an ingredient with no passive damage or status claim. Real deposit role selects emphasis; real radius and expiry still select coverage and lifetime.

| Role | Normal tile/core opacity | Reduced tile/core opacity | Optional accents |
| --- | --- | --- | --- |
| Terminal ingredient | .50 / .88 | .36 / .82 | Existing 2 normal / 1 reduced |
| Optional trail | .30 / .68 | .24 / .62 | 0 |

Previously both roles used .74/1.0 normal and .50/.90 reduced. The revised area texture is quieter than representative active damaging reaction texture (.68 normal/.48 reduced), while a compact identity remains readable. This is not a promise that every individual ingredient pixel is darker than every hazard: authored silhouettes, phase fades and intentionally thinning veils differ.

Unchanged: all essential tiled footprint cells, worldbone clipping, polygon vertices/UVs/triangulation, native frame size, eight distinct element assets/palettes, formation/decay sampling, active reaction rendering, hazard opacity, simulation, TTLs, budgets, authority sizes and atlas bytes. Trail geometry remains the actual 16px radius; full-strength terminal geometry remains the actual 32px radius. Removing only optional trail accents cannot remove the essential footprint.

## Checks authored

Existing exact core/tile opacity assertions were updated to the new bounded values. Added all-eight-element normal/reduced checks for the explicit harmless role, lower trail emphasis, nonzero readability floors, exact footprints, unchanged element art, no extra trail accents, retained essential cells, finite expiry and unchanged canonical authority. Actual standard/high-contrast filter selection must produce identical prefilter models and cells. A representative active Conflagration retains its existing stronger area cap.

High-contrast checks are **model/coverage invariance**, not rendered accessibility certification. The real screen filter transforms the completed image; it does not accept alternate deposit-role inputs. Root plans actual-game review using the existing warm-style-trails harness.

Coordinated result, independently run by the map/render lane: chemistry presenter **18,780 assertions**, accessibility filter **14 assertions**, both zero failures. The enclosing seven-suite run passed **71,530 assertions**, with empty stderr and clean strict import. Direct log inspection confirmed the two W4 totals and final selected-suite PASS.

- Combined log: `.godot/windows-tests/w3-combined-focused-v1-suite.log`
- Error output: `.godot/windows-tests/w3-combined-focused-v1-suite.log.err` (0 bytes)
- Structured integration lookup/receipt: `.godot/windows-tests/w3-combined-focused-v1.json`

## Small extraction opportunity, not implemented

`src/app/bootstrap.gd` configures FoundationSpellPresenter and BurstProjectilePresenter separately, then compares their direction hashes. Both presenters separately load the same direction contract; several focused tests repeat language/catalog setup and the same configure chain. A future shared validated presentation-context factory could centralize those common inputs and fail-closed startup diagnostics while leaving each presenter's role-specific asset validation intact. PixelMagicLibrary already has a shared singleton, so this is mostly consistency/maintenance work, not evidence of duplicate atlas textures or a measured performance win. Bootstrap and tests outside the approved presenter suite were not changed.

## Source identity

- Presenter raw SHA-256: `1c880a5eec39f37e7168cd49110f5c7b25d82148b17ccf599e162a19947822db`
- Focused test raw SHA-256: `bfac9df39cac14dfd28e3b2e90170e6203f218094e698149032c983a5ddebc82`
- Scoped `git diff --check`: passed.

Later integration receipts should record actual-render results separately; these source hashes describe this exact W4 revision.
