# FLUX runtime visual system

The runtime visual system is presentation-only. It may interpret authoritative
state, but it never decides movement, collision, visibility, resources, spell
membership, damage, cooldowns, score or outcomes.

## Expandable foundation

| Boundary | Canonical source | Responsibility |
| --- | --- | --- |
| Visual tokens | `content/visual/visual_language_v1.json` | Pixel grid, ordered ramps, twelve element shape/cadence identities, UI metrics, density budgets, layer order and review thresholds. |
| Validation/API | `src/presentation/visual_language.gd` | Fail-closed loading and typed access without local color invention. |
| Pixel components | `src/presentation/pixel_primitives.gd` | Stepped panels, dividers, material tiles, runes and resource treatments shared by world, spells and GUI. |
| Pixel placement | `src/presentation/pixel_presentation.gd` | Whole-output-pixel translation at 50/75/100% while simulation stays subpixel/fixed-point. |
| Gate specimen | `src/presentation/visual_specimen.gd` | Live `--visual-specimen` review of tokens and components; it is diagnostic evidence, not gameplay authority. |

Every promoted character, environment, spell and GUI slice must reuse these
boundaries or version them explicitly. A local hard-coded palette, arbitrary
layer, unbounded particle count or renderer-owned rule is a regression.

## Perspective and character read

FLUX uses top-down cardinal floors with tilted facades, not a diamond isometric
grid. Walkable tiles remain visually square; horizontal/vertical inputs map to
horizontal/vertical screen movement; wall feet, cover footprints, door
thresholds and elevation transitions stay visible. Facades may rise up to 0.85
of their readable footprint and foreground structures must cut away before they
hide legal information.

Champions use compact cartoon proportions at gameplay scale: a large expressive
head (40–45% of total body height), short sturdy limbs, chunky equipment,
1–2-pixel outlines, 3–5 colors per material and a separate grounded shadow.
South/east/north, jump, cast and hit silhouettes must read before detail is
approved. The revised concept board at
`assets/concept/visual-system-cartoon-perspective-v2.png` clarifies the intended
charm and body language, but its steep courtyard is explicitly not the runtime
camera target.

## V0 baseline

Baseline source captures were recorded on 2026-08-13 from commit `e996610` at
1280x720 and 1920x1080, camera 50/75/100%, full view, fixed 60 Hz. The 75% frame
demonstrates the primary failure clearly: flat schematic surfaces, tiny actor
scale and a text-heavy top HUD preserve rules but do not meet FLUX's charm,
material, silhouette or overview targets.

Run the live token specimen on Windows:

```powershell
scripts/run.cmd 60 --visual-specimen --pov-mode=full --camera-zoom=75
```

Or on Linux:

```bash
scripts/run.sh 60 --visual-specimen --pov-mode=full --camera-zoom=75
```

The specimen freezes vocabulary; it does not open the visual gate. V1–V6 in
`.agent/VISUAL-OVERHAUL.md` still require actual character, environment, spell,
GUI and integrated live evidence.
