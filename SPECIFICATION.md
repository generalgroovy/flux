# FLUX current design contract

Status: current authority, 2026-09-09; replaces the historical production specification.

Warm-style/trail amendment: the current cast-sheet art direction now applies to
the live shared body foundation, basic magic and terrain. Bodies are baked at
92% visual scale, without changing source bones, size-specific hurtboxes or
common wall clearance. Race-specific skins remain a separate production layer.
Bolt, Heavy and Wave can leave optional 16px-radius material trails lasting
0.8-1.5s; Rapid is too weak to leave trails and retains terminal matter only.
Trail + trail and same-cast combinations never react. A new terminal can
combine with a strictly older trail; sustained recipes receive 60% active time, while instant
windows, damage-per-pulse and baseline terminal recipes stay unchanged. Four
trails per owner / 32 globally share the existing 16/128 material cap. Paid
terminal reservations have priority; trail-role snapshot limits are enforced.
Each cast has one chemistry payload: a reaction spends all fragments of both
source casts and permanently zeros their still-flying material strength. Direct
projectile damage remains; prism splitting cannot replenish spent matter.
This uses the existing snapshot fields, plus a changed compiled-content fingerprint.
The current weekly cutoff is 10% remaining; older floors describe history only.

Mirror-first expansion is now authorized, starting with Earth + Earth temporary
cover usable for wallrun/kick, then bounded Ice/Charge movement opportunities
and the remaining mirror personalities. The active queue and
docs/MIRROR-AND-WORKSHOP-PLAN.md distinguish planned rules from verified runtime.
Race-wide basic visuals are next, followed by a larger interactive Wellspring
with compact access to essential options. These changes must not be claimed for
the preserved playtest-clarity portable; each needs its own acceptance evidence.

Playtest-clarity amendment: a successful paid whole-cast admission may reclaim
only the minimum oldest eligible optional trails owned by that actor. Refused
casts never erase matter. Terminal deposits, other owners, paid reservations
and anchors linked to non-expired reactions remain protected. The read-only
HUD offer uses the same admission calculation; compiled trail policy is v4.
Costs, damage, durations, caps, protocol 47 and snapshot 18 are unchanged.

Plain terminal matter and optional trails are harmless ingredients, rendered
quieter than active reaction hazards without removing footprint cells. The
HUD shows four quiet readiness/progress cells and exact protection state;
resource recovery detail appears on pointer inspection. Practice cards show
one action/effect first and expand to existing source-derived detail. Four
sparse floor stages connect Commons, Movement, Crucible and Sparring; guide
data is presentation-only and does not alter the map fingerprint or walls.

Shared-body counter-swing v3 improves garment planes and alternating arms while
retaining all fixed bone/foot registrations. Moving-cast arm variants are an
isolated feasibility candidate, not a live feature or a reason to grow runtime
texture banks. Human template acceptance still gates detailed named skins.

Awareness/tempo amendment: cone geometry uses the55-degree ground projection;
72ground-pixel near awareness reveals slightly behind the observer but never
bypasses opaque cover or chemistry concealment. The observer's body alone draws
above the mask; it creates no rectangular world reveal. Full-view default stays.
Sprint multiplier is1.60, not1.28; base walk speed and existing carry caps remain.
Three shared sprint banks add stronger stride/lean without changing size or hit
geometry. Temporary matter lasts3-5s. Sustained first-grade active windows rise
about25%; five instant reaction windows, per-pulse damage and control-lock
durations remain unchanged. All total reaction lifetimes remain at most5s.

September9 amendment: explicit gameplay-readability tuning is authorized:
all33 moving deliveries20% slower/larger, with approximately25% longer flight
lifetime to preserve reach; eight Fields and eight Heavy blast radii20% larger.
Damage, firing cadence, economy and chemistry outcomes unchanged. The southern
Wellspring movement annex is implemented; full race art remains gated by neutral
template acceptance. Current source/checkpoint evidence is separate from release.

Cursor-facing amendment: every character body pose follows current cursor or
controller aim immediately at the existing eight-direction sprite resolution.
Movement-facing stays independent and still owns neutral evasion direction;
backward/strafe cadence derives from aim versus travel. Committed shots retain
their recorded start aim; visual turning must never silently retarget them.
All voluntary movement modes permit paid casting; one occupied spell startup,
forced control, own cooldown, capacity and positive Flux remain explicit gates.
Menus/death/spectating do not grant gameplay input or free casts.

The active shared body is a clothed adventurer rasterized over the editable rig
at 92% visual scale (south heights 53/63/70px; source envelopes 58/68/76px).
All 29 playable identities use the matching shared size in gameplay
and selection; old race skins stay on disk as historical assets, never silent
fallbacks. Fixed bones and inverse-kinematic contacts support 64 travel/aim pairs
with eight distance-driven stride phases per size. Upper body follows aim;
opposed travel uses backpedal/strafe rather than a 180-degree waist twist.
Hurtbox radius comes exclusively from Small / Middle / Large (15/18/21px),
never race, skin, frame, aim or travel direction. All use 18px wall clearance.
Stats remain size/profile-driven. Visual playback does not alter authority;
complete human animation acceptance still gates later detailed character skins.

## Authority and scope

This file owns current scope. Validated content and simulation own exact executable
rules; discrepancies are defects, not permission to invent behavior. README is
the player entry, .agent/OVERHAUL-IMPLEMENTATION.md is the only task queue, and
docs/CURRENT-CAST.md is the roster. Historical checkpoints prove only their named
build. Reference artwork supplies style, never gameplay data.

| System | Current contract |
| --- | --- |
| Platform | Windows x64, pinned Godot 4.7.1, GL compatibility |
| Cadence | 120 Hz authoritative simulation; 60 Hz snapshots; independent visual interpolation |
| Session | Offline-first Farflow, host authority, maximum 8 players, same-build joining |
| World | Wellspring: screen-cardinal 3072 x 2304 campus, 9 districts, 12 stations, immutable worldbone; southern movement loop and optional wallrun line |
| Cast | 29 named playable profiles; 1 reserved Angel; Small/Middle/Large only |
| Magic | Fire, Water, Earth, Wind, Charge, Ice, Light, Dark; 57 selectable spells; 12 positions |
| Chemistry | 36 symmetric finite first-grade pairs including same-element pairs |
| Sound | Local cast and on-screen confirmed contact cues; eight editable PCM identities; four voices; adjustable 0-100%, default 30% |
| Delivery | Current verified portable EXE/PCK/ZIP selected by docs/current-checkpoint.json; older installer is explicitly historical; unified per-user installer/updater remains the delivery target |

No new element, race identity, technique, mode or larger lobby belongs to this
pass. Existing races may now receive basic visual implementations over the
shared three-size skeleton. Bounded mirror terrain/movement interactions are
authorized only through M0-M4; generic material drift/grip remains deferred.
No dual-element attacks, recursive chemistry, vaulting or landing burst is
introduced. Old serialized IDs are tombstones,
not active moves. Keep tested save/network migrations until explicitly retired.

## Gameplay invariants

Eight normalized keyboard directions; continuous analog movement/aim. Existing
walk, sprint, low jump, finite held Float, slide/slide-jump, roll, air dodge/
wavedash, wallrun/kick, air redirect, fast fall and impact tech compose through
paid transitions. Preserve costs, cooldowns, input buffers, height, protection
and per-airtime budgets during visual work.

Current keyboard defaults are V for Wall/Air Technique and Q for Roll/Air Dodge;
all other defaults and controller bindings remain unchanged. Saved customized
layouts win over defaults. Only a complete, untouched old schema11 keyboard
layout migrates automatically; partial profiles and explicit unbinds do not.
An additive keyboard-default revision keeps deliberate rebindings stable without
raising the saved-settings schema. Older readers may discard that marker; the
exact-old-default downgrade ambiguity must be documented, not silently denied.

Every attack spends positive Flux. Stamina pays movement; Health governs defeat.
Preserve independent quiet-time recovery and character stats. All characters can
use the Spell Loom's Plain 1-4, Ctrl+1-4 and Alt+1-4 positions. Seven families:
Bolt, Heavy, Rapid, Wave, Spray, Beam, Field; Vector Lance is one extra Bolt variant.

Menus and application focus loss send neutral local gameplay commands without
pausing shared simulation. Queued wheel actions are discarded. Paid actions
held during interruption require release and a fresh press before reactivation;
directional movement may resume. UI interaction must never become a delayed
jump, dodge or cast. Gallery reconfiguration clears requests and borrowed
previews and requires a deliberate reopen, even after failed validation.

Bolt/Heavy/Rapid/Wave terminate at collision, range or their captured endpoint
and leave finite 3-5 second deposits. Plain matter causes no direct damage/status.
Different casts can combine; Wave siblings cannot react together. Beam/Spray/
Field do not deposit. Only active reaction phases apply effects. Worldbone is
immutable. The M1 Earth mirror adds a cardinal 64 x 36px temporary movement
surface, with the same shot/ray footprint. It supports ordinary paid wallrun/
kick while active and healthy, permits escape on formation overlap, and releases
contact on destruction/decay. All teams meet the same 18px movement clearance.
Other reaction cover still blocks shots/rays, not walking. Names do not imply
unimplemented healing, burning, draining or friction changes.

The southern annex adds 576 pixels of height, an ordinary 160-pixel-wide loop,
two optional non-vaultable wallrun surfaces and an eastern return to existing
practice. Original objects, stations, targets, spawns and arena rules remain.
All body roles retain common 18-pixel wall clearance. New space is not a new
technique, timed challenge, minimap or material-assisted movement feature.

## Architecture

The player-facing learning loop is observe -> act -> combine -> counter -> reset.
Teach one reliable action before multi-action combinations. Every guide must
answer what a result does, when it applies and how to respond, using executable
values. Element names/colors alone never imply a status. Keep the distinction
between spell impact, harmless terminal matter, a Field spell and active chemistry.
Matrix selection and its detailed reader must identify the same pair. Show
warning/active/harmless-decay durations distinctly, and label base recovery versus
idle-ramped recovery. Station guides use the device that activated the station.

Context cards are read-only personal practice helpers, not objectives or new
mechanics. The Crucible recognizes actual active Radiance/Steam overlap from
separate local reaction origins; it explains conditional reveal and expiry
without asserting visibility behind worldbone. Both reactions retain their own
rules and clocks. The southern loop uses current bindings and paid movement
state for at most two next-action lines. Only deliberate gameplay input changes
its keyboard/mouse versus controller labels. Menus, focus/rearm guards, spectators,
invalid guests and non-HEARTH rounds suppress both cards; never borrow host state.

Post-cast owner material capacity may be gathered in one stateless pass for
multiple players, provided the unchanged per-owner query is an exact oracle.
Keep sequential pre-payment admission, global orphan-material accounting,
alive pending-cast reservations, player order and per-owner limits identical.
No persistent cache, raised cap or timing-dependent simulation branch is allowed.

input -> semantic command -> host/simulation -> snapshot -> presentation

| Owner | Responsibility |
| --- | --- |
| content | Validated versioned definitions, stable identity, data composition |
| sim | Deterministic movement/combat/chemistry, bounds, collision and outcomes |
| net | Admission, compatibility, prediction/reconciliation, snapshots |
| app | Input, preferences, stations, sessions and lifecycle |
| presentation | Art, motion, interpolation, GUI and feedback from permitted state |
| tools/tests | Reproducible builds, production-route scenarios and evidence |

Dependencies point toward simulation/content. No texture, render age or decoration
determines damage, geometry, visibility, timing or network results. Invalid data
fails closed. Historic internal names are not another gameplay system.

Contact-query optimization is a stateless conservative bounds rejection before
the unchanged sampled narrow phase. Strict separation only; tangencies retained;
linked paths fall through. Equivalence of contact point, ordering, authoritative
hashes and non-timing counters is required before using a measured improvement.

Projectile/actor circle contact likewise permits strict axis-separation rejection
before the unchanged clamped integer projection. Preserve tangency, truncation,
zero-length and negative-radius fallback. Evaluate both far misses and dense
near-contact overhead; a median improvement does not close the mixed p95 gate.

Projectile reactions may use a batch-local ordered candidate list only while
tick, recipe identities and membership cannot gain eligibility within that
synchronous batch. Preserve live references, duplicate/order semantics and the
inner active checks; all Heavy/cover/blast paths retain the full reaction list.
Any future within-batch formation/activation invalidates this optimization's
proof and requires a new same-input every-tick equivalence gate. Never reuse
this list between ticks or treat measured p95 as sustained120FPS acceptance.

Sound is feedback, not a sensor or new combat rule. It follows local authoritative
cast-starts and validated projectile/beam/spray/field contacts, never guessed
damage, other players' casts, chemistry activation or raw terminal deposits.
Full-view contacts require an on-screen, chemistry-visible target; cone mode
suppresses contact sounds until exact mask parity exists. Menus, spectating,
focus loss, mute and exit silence it. Six/eight-tick contact/cast admission gaps,
four fixed voices and a bounded peak prevent effect pileups; clips are generated
once, never in the simulation or per shot. Controls Lectern owns volume/mute.
The additive optional sound_volume_percent preference preserves schema 11 and
older controls; unmute restores 30%. Actual listening comfort remains a human gate.

## Visual contract

Original Oh Tipi supports neutral construction's natural proportions, crisp pixels,
layered practical clothing and empty-hand casting. The newer cast sheet in
`reference/art/cast_style_post_templates_v1` is now the live shared-foundation
style target; named skins still require complete template playback/user acceptance.
It adds no identity, affinity, camera, size or gameplay authority. S. Wayne stays dark-skinned;
Biggy Bob has brown hair. No staff/wand, projectile, aura, shadow or environment
pixels in body sheets.

Three source body envelopes 58/68/76 px, displayed at 92% about the feet pivot;
shared 96 x 96 cell and feet pivot (48, 84), fixed
body scale across all actions/directions. Small/Middle/Large retain distinct core
stats and fixed hurtboxes; wall clearance stays identical for all three. Neither
hurtboxes nor wall clearance may be inferred from pose pixels or animation scale.
The size/footprint follow-up is tracked in the active queue until verified. Directions
S/SE/E/NE/N/NW/W/SW; south faces camera symmetrically. Reuse pose guides/timing,
but preserve unique anatomy, clothing and silhouettes. Filled cells do not prove
quality: opposite walk contacts and derived motion must be reviewed and labeled.

Art heading labels use South=0/360, SE=45, E=90, NE=135, N=180, NW=225,
W=270, SW=315, distinct from mathematical aim angles. Head, shoulders, hips and
feet must agree on the selected world-plane yaw. Side profiles are not acceptable
rear-quarter substitutes. Gallery now inspects actual grounded cells in these
eight steps without rotating/blending artwork; this does not certify source poses.

Production order is generic Small, then Middle, then Large, including complete
eight-direction action/contact coverage and user visual acceptance of the basic
templates together. Character-specific repairs/additions are deferred until that
gate. Fixed-bone construction references and partial cells are not finished art.
Coverage must include reviewed playback of every live movement/action mapping in
all eight headings; merely filling80 cells or repeating a held pose is insufficient.
Reuse one assembler and live presenter; review assets never become roster IDs.

Walking cadence follows actual ground travel, not a free-running idle clock or
prediction correction offsets; contact/pivot phases agree and persist through
ordinary direction and walk/sprint changes. Two authored contacts remain labeled
as such. Portraits use the exact top third of occupied South-grounded sprite
bounds, proportionally nearest-fit with transparency, not separate portrait art.

Menus favor compact source-derived tables/matrices and visual element identifiers.
Movement lists inputs, base costs/drain, protection and cooldown; chemistry shows
the complete8x8 matrix with concise selection feedback. Complete rules stay under
Details; presentation must not invent effects or imply unconditional invincibility.
The shared visual-language validator uses the same three heights, eight headings
and ten rows as production. Its twelve compatibility palettes explicitly separate
eight active elements from four reserved styles; compatibility is not new scope.

About 55-degree illustrated elevation over unrotated screen-cardinal floors;
50/75/100% zoom; no automatic worldbone fade. Quiet routes; actors/threats/
interactive matter/scenery in that priority. Element identity uses shape, value
and motion as well as color. Reduced effects preserve extent, phase and identity.
No unborn/expired effect is displayed as active.

Element deposits and reaction fields express their occupied area with repeated
native-pixel material, not separate range circles, outlines or perimeter markers.
Fire fills the area with flame tongues; Steam spreads billows; Earth uses stone
chunks and actual cover silhouettes. Tile placements stay world-anchored and are
clipped by authoritative geometry. Reduced/zero optional decoration retains this
essential material coverage. Earth artwork never invents walking collision.

## Acceptance

Scoped diff -> focused tests -> applicable actual-render/network proof -> Full
checkpoint -> exact receipt/state/queue. Keep the last working build. New art
needs alpha, gutters, fixed scale/pivot, eight-direction action coverage and
gameplay-scale review. Never call a portrait/tint a complete unique sprite.

Source, packaged, locally tested, human-accepted and publicly released are
separate states. 120 Hz configuration does not certify 120 FPS. Mixed-player timing,
physical friend-session proof, signing and public online updates remain open.
