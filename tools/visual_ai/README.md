# FLUX2 visual AI pipeline v3

This tool adapts the useful workflow concepts from
`blendi-remade/sprite-sheet-creator`—reference-image generation, per-animation
sheet generation, background removal, grid extraction and preview—into a
fail-closed FLUX2 production pipeline.

It does not copy that project's implementation. The reference repository has no
license file in the inspected revision, so this implementation is independent.

## Requirements

| Requirement | Value |
|---|---|
| Node | 22+ |
| Image provider | fal.ai through `@fal-ai/client` |
| Secret | `FAL_KEY` |
| Default image model | `openai/gpt-image-2` |
| Background removal | `fal-ai/bria/background/remove` |
| Generation budget | `FLUX_VISUAL_MAX_CALLS`, default 8 |

## Commands

```bash
cd tools/visual_ai
npm install --no-audit --no-fund
FAL_KEY=... npm run validate
FAL_KEY=... node src/cli.mjs run-slice --slice gold_standard_concepts --attempts 2
FAL_KEY=... node src/cli.mjs animation --id oh_tipi --animation idle --direction south --attempts 2
```

Generated images are never automatically marked final. They enter the repository
as `generated_candidate_needs_visual_review`, accompanied by contact sheets and
structural metrics. This prevents file counts or green CI from being mistaken for
artistic acceptance.

The full production order is driven by
`content/visual/visual_iteration_manifest_v3.json`.
