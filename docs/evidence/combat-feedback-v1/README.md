# Truthful combat feedback

Status: locally focused-tested and actual-render inspected, 2026-09-09; parent Full checkpoint, human play/readability acceptance and release remain separate.

The live cue hook now uses validated spell identity and the source element color.
Generic Beams no longer claim Slow; generic Sprays no longer borrow Tideline's
name or claim Launch; non-Ice Fields no longer call themselves Rime. Field copy
says CONTACT because a contact event does not prove control application (Slow
can be rejected during forced movement). Spell behavior itself is unchanged.

Beam hits use the actual spell name plus HIT on both host and guest: existing
guest Beam events omit damage, and optical chemistry makes base damage an unsafe
substitute. Spray/projectile damage labels use only the amount carried by their
events, retaining milli-unit precision. Unknown, mismatched or unvalidated spell
metadata gets neutral family copy rather than invented identity/color. Existing
refusal copy, cue anchors, 0.20/0.55-second lifetimes and 24-cue cap are preserved.

## Evidence

- `focused.log`: Godot 4.7.1, foundation-spell-presenter 2,957 assertions and
  session-snapshot 1,402 assertions; 4,359 total, 0 failures; original stderr 0 bytes.
  Covers all 8 elements, source/wire roundtrip parity, special spells, safe
  fallbacks, exact event damage and the actual bootstrap ingestion hook.
- `render.log` and six PNGs: actual 1280x720 OpenGL compatibility renderer output,
  all 8 elements across Beam, Spray-hit and Field-contact cues in normal/reduced
  modes. The fixture inherits the real ingestion and draw methods, samples at
  4/120 second, and keeps original 11px copy at 100% zoom. All six inspected for
  correct names, colors and unclipped labels. Spray-release naming/counts are
  unit-tested; this contact sheet does not depict full Spray cone releases.
- Shared test harness suppresses unrelated boot/session/preferences and hand
  release effects; it does not replace combat cue ingestion or drawing.

No simulation, protocol, damage, movement, balance, geometry, effect lifetime,
artwork or audio change. These are explicit event fixtures, not a match or a
claim of human comfort, multiplayer playtest acceptance, 120 FPS or new installer.

## Reproduce

Run the focused suites with the repository test entry point:

```powershell
.\scripts\test.ps1 -Tier Focused -Suite foundation-spell-presenter,session-snapshot
```

For a new hidden actual-render capture, use the pinned engine with:

```text
--path <checkout> --script res://tests/visual/capture_combat_feedback.gd -- --output=res://.godot/combat-feedback-v1/render-NEW
```

The output directory must not already exist. The fixture hides its root window;
the successful captures above used the repository's hidden-process launcher.
