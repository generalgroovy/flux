# Visual asset tooling

Generate and validate the complete committed v1 foundation:

```bash
python tools/assets/generate_visual_assets_v1.py
python tools/assets/validate_visual_assets_v1.py
```

The generator is deterministic and writes runtime PNGs, the singular-animation
ZIP, the first visual map layout, registry and SHA-256 manifest. The validator
checks dimensions, canonical counts, archive integrity and every recorded hash.

The branch-scoped workflow `.github/workflows/generate-visual-assets-v1.yml`
performs the same generation inside GitHub and commits changed outputs. It is
triggered only by `.agent/run-visual-assets-v1` on the dedicated production
branch and does not merge into `main`.
