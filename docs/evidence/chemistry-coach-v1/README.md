# Crucible chemistry coach evidence

Status: local focused suite and hidden actual-gameplay rendering passed, 2026-09-09; integrated Full checkpoint, human learning/feel acceptance and release remain separate.

The coach observes the local actor at the authored `crucible-experiment` practice
group. It does not issue commands, pay or reward resources, create matter,
advance timers, or mark success. It distinguishes invitation, harmless terminal
matter, harmless formation warning, active reaction and harmless decay.

## Focused verification

`focused.log`: pinned Godot 4.7.1, `chemistry-practice-coach` **4,086 assertions,
0 failures**, with 0 bytes of stderr. In addition to the model's complete 36-pair
coverage, integration tests exercise inherited bootstrap gating for all four
menus/Gallery, address entry, visual specimen, focus interruption, input rearm,
death, out-of-group position, active/result rounds, host free practice and guest
spectating. The client must own a present replicated actor; a missing guest actor
cannot fall back to coaching the host. This regression was found by these tests
and fixed in the production hook before the final passing run.

Two real paid Fire/Water projectile casts at the authored firing anchor produce
terminal matter, then Steam, through ordinary 120 Hz `SimWorld.step` calls.
The tests check exact positive costs, formation, activation, decay and expiry,
and ordinary `SessionSnapshot.capture/apply_to_world` parity at those boundaries.
A separate real guest-owned pair uses entity 2, crosses the normal snapshot
boundary, and shows that guest's lesson without borrowing the out-of-area host.
Repeated coach observations leave player and world snapshots unchanged.

Every title, phase and text line for all 36 reactions is measured against the
actual 412px text lane using the renderer's 14/11/12px fonts. Crystal Lens retains
the conditional split wording and spare-capacity/damage caveat.

## Actual gameplay captures

`render.log` and 13 PNGs were produced through the inherited **entire bootstrap
gameplay draw**, including campus, character, chemistry, HUD and the coach:

| Stage | Real world tick | Paid casts | Captures |
| --- | ---: | ---: | --- |
| Invitation | 0 | 0 | Normal/reduced, 100% zoom |
| Fire matter | 23 | 1 | Normal/reduced, 100% zoom |
| Steam forming | 45 | 2 | Normal/reduced, 100% zoom |
| Steam active | 73 | 2 | Normal/reduced, 100%; normal 50% and 75% zoom |
| Harmless decay | 325 | 2 | Normal/reduced, 100% zoom |
| Expired, invitation again | 385 | 2 | Normal, 100% zoom |

All images are actual 1280x720 OpenGL compatibility output and were visually
inspected. Coach text is unclipped, remains UI-scaled across world zoom, and
does not cover the player, reaction at the chosen endpoint, resource bars or
spell hotbar. Normal/reduced use the same truthful phase and instruction text.

The fixture initializes the real campus collision and Oh Tipi profile, equips
existing Fire and Water spells, and disables only fixture resource recovery to
make payment accounting exact (the HUD may therefore read `+0/s`). Boot,
network sockets, preference persistence, audio and automatic frame-driven
simulation are suppressed. It does not override the coach model/gates or
gameplay drawing, and it never constructs fictitious matter/reaction states for
these screenshots. Broader cast art quality, human learning during motion,
listening comfort, physical friend networking and performance acceptance are
not established by these scripted captures.

## Reproduce

```powershell
.\scripts\test.ps1 -Tier Focused -Suite chemistry-practice-coach
```

Use the pinned engine via a hidden process for actual rendering:

```text
--path <checkout> --script res://tests/visual/capture_chemistry_coach.gd -- --output=res://.godot/chemistry-coach-v1/render-NEW
```

The output directory must be new. The fixture also hides the root game window.
