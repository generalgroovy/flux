# Delivery and practice evidence

Status: actual renderer/test evidence for the local2026-09-08 source candidate; not release or human acceptance.

| File | Source and meaning |
|---|---|
|[heavy-range.png](heavy-range.png)|Production bootstrap,1280×720, frame86 of110 at120Hz; paid Cinder Shell179 expires at the locked point and hits targets900/901 for18 each at tick75; no injected damage. Final hotbar shows HEAVY/RAPID/WAVE.|
|[crucible.png](crucible.png)|Production bootstrap at1568,1440; separate target903 and chemistry practice area.|
|[spell-loom.png](spell-loom.png)|Production Spell Loom at1280×720;57 selectable spells /12 positions.|
|[elements-normal.png](elements-normal.png)|Actual renderer fixture of all eight native pixel element cores, finite impacts, deposits and Fields. Controlled fixture, not a match.|
|[elements-zero-decoration.png](elements-zero-decoration.png)|Same renderer fixture after optional decoration budget exhaustion; core identities/boundaries remain.|
|[full-receipt.json](full-receipt.json)|Executed Windows Full gate:87 suites /330,190 assertions, zero failures/warnings/stderr,120Hz source boot; dirty main at HEADa1aa02807626823d0fbc1e25e75441ca3b7f4d36.|
|[mixed-load.log](mixed-load.log)|Two paid legal-eight mixed runs and reference/stage equivalence;16,621 assertions, timing and bounded-network measurements. p95~20ms and transient-event overflow are unresolved.|

Capture invocations (from repository root):

```powershell
.\scripts\capture-visual.ps1 -Name delivery-range-final -Frames 110 -GameArguments @('--capture-spawn=2560,548','--capture-pointer=2512,352','--capture-spell-wires=179,180,146','--capture-cast-slot=1','--camera-zoom=100','--no-lan-discovery')
.\scripts\capture-visual.ps1 -Name delivery-crucible-final -Frames 4 -GameArguments @('--capture-spawn=1568,1440','--capture-pointer=1568,1248','--camera-zoom=100','--no-lan-discovery')
.\scripts\capture-visual.ps1 -Name delivery-loom-v1 -Frames 4 -GameArguments @('--capture-expanded-station=spell-loom','--no-lan-discovery')
.\scripts\test.ps1 -Tier Full -ReceiptPath .godot/receipts/delivery-checkpoint-final.json
.\scripts\smoke-farflow.ps1 -TickRate 120 -Port 24938
```

Choose new capture names when repeating; the helper refuses to overwrite.
Local Farflow passed host/join, shared greeting, movement reconciliation,
Hearth/Court transition, late join, rematch and stewardship. Detailed transient
logs remain in`.godot/farflow-smoke/`; this is not internet multiplayer acceptance.
The Full receipt predates this evidence-copy/document-only consolidation; its
historical hashes are retained, never relabeled as a later workspace fingerprint.
