# Element contact imprint

Status: locally implemented and focused-validated, 2026-09-09; all 10 final actual-render sheets visually inspected. Integrated Full/import/export and human play acceptance remain with the parent task. Not a release.

The contact renderer reuses each element's existing upright flight silhouette
as a short stationary impact imprint. It holds briefly, then collapses and fades
during the first 12 source-age ticks (0.10 seconds at 120 Hz), leaving only the existing
one-shot breakup. No image, palette, projectile, balance or chemistry data changes.

The original nonlooping impact sample gates the entire result. Borrowing a
looped source image cannot extend contact lifetime, and the caller's shorter
terminal-effect deadline still wins. Valid expired contacts remain handled
without issuing draw calls, so procedural fallback effects cannot reappear.

The opening uses one guaranteed identity stamp and at most one optional breakup
stamp. Optional breakup is charged to the existing impact asset's per-instance
budget and the shared 192/96 normal/reduced decoration limits; it is not charged
to the unrestricted projectile-core role. With no optional allowance, exactly
one identity stamp remains. After the opening, exactly one original breakup
stamp remains. All stamps stay at the exact source position, upright, at or
below the existing cosmetic contact scale. No particles, range circle, active
zone or extra geometry is introduced. Reduced mode uses the same silhouette,
gentler contraction and lower opacity.

## Reproduce

```powershell
.\scripts\test.ps1 -Tier Focused -Suite burst-projectile-presenter,foundation-spell-presenter
```

For the hidden actual-render comparison, use the pinned Godot 4.7.1 executable:

```text
--path <checkout> --script res://tests/visual/capture_impact_identity.gd -- --output=res://.godot/impact-identity-v1/render-NEW
```

The output directory must be new. Each comparison draws the previous single
breakup and the new live path using the same original assets and contact state.
Standard sheets use both dark and campus-light backgrounds; family-weight sheets
use one full-height dark tile so the largest contact fits without overlap.

## Verified result

- Godot 4.7.1: **13,944 assertions, zero failures** across
  `burst-projectile-presenter` (10,987) and `foundation-spell-presenter` (2,957).
- The focused run and hidden actual-render run completed in about 9.7 seconds
  combined. Both stderr files are empty; the checked runner rejected warnings.
- All eight element source alpha silhouettes are distinct in both modes. Tests
  inspect real source texture pixels, not only element names or tint values.
- Tests cover every age of the original 43-tick one-shot, both modes and the
  Rapid/Bolt/Heavy radii (6/10.8/19.2 pixels); exact anchor, existing scale cap,
  monotonic collapse/fade, original expiry, invalid-input handling and the
  caller's shorter 24-tick terminal deadline remain intact.
- Actual draw recording confirms at most two opening stamps, one optional
  charge, one guaranteed core with zero optional allowance, and zero calls
  after expiry. Valid expiry stays handled, preventing procedural fallback
  art from being resurrected.
- Ten 1280x960 PNGs were rendered and individually inspected: normal/reduced
  at 50/75/100% zoom, both family-weight sheets and both zero-budget sheets.
  Standard sheets use 32 optional stamps, weight sheets 24; exhausted-budget
  sheets stay at their preconsumed 192/96 limits without replenishment.

## Visual review and boundary

The initial three-tick hold and collapsing core make opening impacts denser,
especially Heavy Fire, Light and Ice. Earth remains a compact rock, Fire a
flame, Water a crest, Wind a curl, Ice a spiked crystal, Charge a bolt, Light
a diamond and Dark a crescent. At 50% zoom these remain small pixel silhouettes;
the difference from the existing breakup is subtle and is not claimed as a
dramatic art overhaul. Reduced effects preserve identity with less breakup
and gentler contraction. On an exhausted optional pool, the contact remains
recognizable without adding a secondary stamp. The later breakup column is
unchanged before/after, including its existing outward fragment spread.

This slice changes only the shared pixel impact path in production. No
`burst_projectile_presenter.gd` production edit was needed: its existing
authoritative anchor, family radius and outer lifetime gate are preserved and
regression-tested. No asset PNG, atlas, global palette, simulation, protocol,
bootstrap or chemistry presenter is changed by this slice.

The screenshots below are the final corrected run, not the earlier exploratory
render. `focused.log`, `render.log` and their empty stderr companions are copied
alongside them. Source fixture: `tests/visual/capture_impact_identity.gd`.

| Mode | Zoom comparisons | Additional bounds |
| --- | --- | --- |
| Normal | [50%](normal-50.png), [75%](normal-75.png), [100%](normal-100.png) | [Family sizes](normal-100-weights.png), [zero optional budget](normal-100-zero-budget.png) |
| Reduced | [50%](reduced-50.png), [75%](reduced-75.png), [100%](reduced-100.png) | [Family sizes](reduced-100-weights.png), [zero optional budget](reduced-100-zero-budget.png) |

These are diagnostic effect comparisons, not a played match, damage-footprint
proof, physical friend session, frame-rate claim or user aesthetic acceptance.
