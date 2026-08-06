#!/usr/bin/env python3
"""Generate the detailed champion section in the root README.

This generator deliberately distinguishes repository facts from unimplemented
or unapproved design work:

* sprite paths, body plans, sizes, affinities, equipment and visual status come
  from the current visual-production branch;
* seven preserved legacy kits expose their exact approved ability names, but do
  not claim that their mechanics are implemented;
* every other kit remains explicitly pending rather than being invented here;
* the temporary Angel slot remains a non-selectable placeholder.

Run from any directory with:

    python tools/assets/generate_character_readme_v1.py
"""
from __future__ import annotations

from pathlib import Path
from typing import Final

ROOT: Final = Path(__file__).resolve().parents[2]
README: Final = ROOT / "README.md"
START_HEADING: Final = "### Existing character design roster\n"
END_HEADING: Final = "### Champion promotion pipeline\n"
BEGIN_MARKER: Final = "<!-- BEGIN CHARACTER_ROSTER_V1 -->"
END_MARKER: Final = "<!-- END CHARACTER_ROSTER_V1 -->"

# Slot order is intentional and preserves the previously approved kit naming
# contract: passive, active I, active II, mobility, ultimate.
CONFIRMED_KITS: Final[dict[str, tuple[str, str, str, str, str]]] = {
    "oh_tipi": (
        "Living Current",
        "Tideline",
        "Flash Freeze",
        "Eel Step",
        "Stormtide Basin",
    ),
    "s_wayne": (
        "Small Target, Big Exit",
        "Pocket Tempest",
        "Burrowed Shadow",
        "Campfire Feint",
        "There and Back Again",
    ),
    "red_baron": (
        "Cold Ashes",
        "Crimson Comet",
        "Night Flak",
        "Rime Wing",
        "The Dead Sky",
    ),
    "steezo": (
        "Questionable Engineering",
        "Spark Keg",
        "Prism Tripwire",
        "Coil Hopper",
        "Perfectly Safe Machine",
    ),
    "treevor_mason": (
        "Deep Roots",
        "Root Rampart",
        "Branch Gale",
        "Ember Seed",
        "Crown of the Wildfire",
    ),
    "oll_i": (
        "Labyrinth Momentum",
        "Sunhorn Charge",
        "Furnace Stomp",
        "Mirror Bulwark",
        "The Burning Maze",
    ),
    "fluup": (
        "Stormweight",
        "Thunder Shove",
        "Squall Leap",
        "Rime Crash",
        "Bad Weather",
    ),
}

ROSTER: Final[list[dict[str, object]]] = [
    {
        "id": "oh_tipi",
        "name": "Oh Tipi",
        "ancestry": "Seakin",
        "size": "Medium",
        "elements": "Water · Ice · Charge",
        "weapon": "Conduit",
        "role": "Conductive-field skirmisher and current rider",
        "notes": "Large head fins and a route-first silhouette distinguish water setup, freezing and current traversal.",
    },
    {
        "id": "s_wayne",
        "name": "S. Wayne",
        "ancestry": "Hobbit",
        "size": "Small",
        "elements": "Dark · Light",
        "weapon": "Eclipse disc",
        "role": "Eclipse-boundary tactician and decoy router",
        "notes": "The preserved kit names were authored under the legacy name Samwise DeWayne and require identity/affinity reconciliation before promotion.",
    },
    {
        "id": "red_baron",
        "name": "The Red Baron",
        "ancestry": "Undead",
        "size": "Medium",
        "elements": "Void (legacy, unresolved) · Fire · Ice",
        "weapon": "Sabre",
        "role": "Airborne formation controller with punishable landings",
        "notes": "The visual catalog currently tags Dark, while the design roster still says Void. Selection remains blocked until that mapping is approved.",
    },
    {
        "id": "steezo",
        "name": "Steezo",
        "ancestry": "Goblin",
        "size": "Small",
        "elements": "Fire · Charge · Light",
        "weapon": "Detonator",
        "role": "Volatile construct engineer and detonation sequencer",
        "notes": "Red skin, tool-led silhouette and readable devices are identity requirements rather than optional cosmetics.",
    },
    {
        "id": "treevor_mason",
        "name": "Treevor the Mason",
        "ancestry": "Treefolk",
        "size": "Large",
        "elements": "Earth · Wind · Fire",
        "weapon": "Mason hammer",
        "role": "Terrain mason creating routes, cover and fire liabilities",
        "notes": "Canopy, roots and masonry equipment must remain readable independently of elemental effects.",
    },
    {
        "id": "oll_i",
        "name": "Oll' I",
        "ancestry": "Werewolf",
        "size": "Large",
        "elements": "Earth · Fire · Light",
        "weapon": "Impact gauntlets",
        "role": "Forward structural breaker with high commitment",
        "notes": "Current Flux2 ancestry is Werewolf; older Minotaur imagery is migration reference, not current repository truth.",
    },
    {
        "id": "fluup",
        "name": "Fluup",
        "ancestry": "Orc",
        "size": "Large",
        "elements": "Charge · Wind · Ice",
        "weapon": "Storm maul",
        "role": "Storm bruiser converting committed landings",
        "notes": "Heavy action timing and storm effects must preserve the underlying Orc silhouette and recovery read.",
    },
    {
        "id": "wa_bidi",
        "name": "Wa Bidi",
        "ancestry": "Goblin",
        "size": "Small",
        "elements": "Charge · Wind · Fire",
        "weapon": "Battle horn",
        "role": "Fast battlecry route specialist with visible and audible cues",
        "notes": "No approved character-specific ability names are committed yet.",
    },
    {
        "id": "grace_reava",
        "name": "Grace Reava",
        "ancestry": "Sylph",
        "size": "Small",
        "elements": "Wind · Water · Light",
        "weapon": "Rapier",
        "role": "Luminous-current aerial duelist",
        "notes": "No approved character-specific ability names are committed yet.",
    },
    {
        "id": "nico_lai",
        "name": "Nico Lai",
        "ancestry": "Gnome",
        "size": "Tiny",
        "elements": "Charge · Light",
        "weapon": "Charge gauntlet",
        "role": "Precision shared-device engineer",
        "notes": "Bald crown, strong swept side-hair silhouette and oversized engineering equipment are required identity anchors.",
    },
    {
        "id": "spai_si",
        "name": "Spai Si",
        "ancestry": "Demon",
        "size": "Medium",
        "elements": "Wind · Light · Earth",
        "weapon": "Redirect blade",
        "role": "Redirect duelist converting hostile intent into angles",
        "notes": "Current design is male with short dark hair; no approved character-specific ability names are committed yet.",
    },
    {
        "id": "leaf_hidden",
        "name": "Leaf the Hidden",
        "ancestry": "Treefolk",
        "size": "Medium",
        "elements": "Water · Earth · Light",
        "weapon": "Grove staff",
        "role": "Concealed grove support and planned-route grower",
        "notes": "Legacy art may label this design Hidin Leef; Flux2 uses Leaf the Hidden.",
    },
    {
        "id": "ha_rekt",
        "name": "Ha Rekt",
        "ancestry": "Wyrmborn",
        "size": "Large",
        "elements": "Ice · Wind · Fire",
        "weapon": "Cold lance",
        "role": "Aerial cold-line hunter with marked escape routes",
        "notes": "Wyrmborn is an anthropomorphic scaled body plan, not a conventional quadrupedal wyrm.",
    },
    {
        "id": "dr_apex",
        "name": "Dr. Apex",
        "ancestry": "Stoneborn",
        "size": "Large",
        "elements": "Earth · Light · Water",
        "weapon": "Medic prism",
        "role": "Armored combat medic with contestable support zones",
        "notes": "No approved character-specific ability names are committed yet.",
    },
    {
        "id": "haara",
        "name": "Haara",
        "ancestry": "Nymph",
        "size": "Small",
        "elements": "Light · Wind · Spirit",
        "weapon": "Bloom orb",
        "role": "Bloom planner with flexible resource routing",
        "notes": "Short dark hair is the current identity direction. Spirit remains runtime gated.",
    },
    {
        "id": "hesus_christo",
        "name": "Hesus Christo",
        "ancestry": "Elf",
        "size": "Medium",
        "elements": "Earth · Water",
        "weapon": "Renewal staff",
        "role": "Tall renewal vanguard rebuilding broken routes",
        "notes": "No approved character-specific ability names are committed yet.",
    },
    {
        "id": "grimm_bow",
        "name": "Grimm Bow",
        "ancestry": "Troll",
        "size": "Huge",
        "elements": "Void (legacy, unresolved) · Earth · Water",
        "weapon": "Greatbow",
        "role": "Terrain archer converting displacement into precision, never bonus damage",
        "notes": "The visual catalog currently tags Dark, while the design roster still says Void. Selection remains blocked until that mapping is approved.",
    },
    {
        "id": "biggy_bob",
        "name": "Biggy Bob",
        "ancestry": "Dwarf",
        "size": "Medium",
        "elements": "Earth · Fire · Light",
        "weapon": "Breach hammer",
        "role": "Forge-line breacher and masonry specialist",
        "notes": "No approved character-specific ability names are committed yet.",
    },
    {
        "id": "jan_wicked",
        "name": "Jan Wicked",
        "ancestry": "Human",
        "size": "Medium",
        "elements": "Ice · Dark · Charge",
        "weapon": "Ice blade",
        "role": "Black-ice circuit hunter",
        "notes": "No approved character-specific ability names are committed yet.",
    },
    {
        "id": "ba_djoh",
        "name": "Ba Djoh",
        "ancestry": "Minotaur",
        "size": "Huge",
        "elements": "Earth · Fire · Water",
        "weapon": "Breaker",
        "role": "Three-current charge breaker",
        "notes": "No approved character-specific ability names are committed yet.",
    },
    {
        "id": "urzh",
        "name": "Urzh",
        "ancestry": "Stoneborn",
        "size": "Large",
        "elements": "Earth · Fire · Charge",
        "weapon": "Kiln shield",
        "role": "Conductive kiln bulwark and lane anchor",
        "notes": "No approved character-specific ability names are committed yet.",
    },
    {
        "id": "donnok",
        "name": "Donnok",
        "ancestry": "Dwarf",
        "size": "Medium",
        "elements": "Earth · Fire · Water",
        "weapon": "Terrain hammer",
        "role": "Forge-rhythm terrain shaper",
        "notes": "No approved character-specific ability names are committed yet.",
    },
    {
        "id": "djonah_thaan",
        "name": "Djonah Thaan",
        "ancestry": "Vampire",
        "size": "Medium",
        "elements": "Dark · Charge · Fire",
        "weapon": "Grave coil",
        "role": "Grave-current pursuit controller",
        "notes": "No approved character-specific ability names are committed yet.",
    },
    {
        "id": "unnamed_angel",
        "name": "Unnamed Angel",
        "ancestry": "Angel",
        "size": "Medium",
        "elements": "Wind · Light · Spirit",
        "weapon": "Placeholder orb",
        "role": "Visual and body-plan placeholder only",
        "notes": "Identity, lore, kit and selection status are unapproved. This slot must not become playable merely to fill the roster.",
        "placeholder": True,
    },
]


def md(text: object) -> str:
    """Return text safe for the simple Markdown tables generated here."""
    return str(text).replace("|", "\\|").strip()


def sprite_paths(champion_id: str) -> tuple[str, str, str]:
    base = f"assets/sprites/champions/{champion_id}"
    return (
        f"{base}/{champion_id}_direction_preview.png",
        f"{base}/{champion_id}_atlas.png",
        f"{base}/{champion_id}_portrait.png",
    )


def kit_table(champion_id: str, placeholder: bool) -> list[str]:
    if champion_id in CONFIRMED_KITS:
        passive, active_a, active_b, mobility, ultimate = CONFIRMED_KITS[champion_id]
        return [
            "| Ability slot | Preserved design name | Implementation state |",
            "| --- | --- | --- |",
            f"| Passive | **{md(passive)}** | Named design input; simulation and balance not implemented |",
            "| Champion primary | Not committed | Current Arc Primary is a shared foundation placeholder, not the final champion primary |",
            f"| Active I | **{md(active_a)}** | Named design input; simulation and balance not implemented |",
            f"| Active II | **{md(active_b)}** | Named design input; simulation and balance not implemented |",
            f"| Mobility | **{md(mobility)}** | Named design input; must obey global collision and speed limits |",
            f"| Ultimate | **{md(ultimate)}** | Named design input; charge, startup, interruption and recovery rules pending |",
        ]
    if placeholder:
        return [
            "| Ability slot | Status |",
            "| --- | --- |",
            "| Passive, primary, actives, mobility and ultimate | **Unapproved placeholder.** No names or mechanics may be inferred from the temporary artwork. |",
        ]
    return [
        "| Ability slot | Status |",
        "| --- | --- |",
        "| Passive | Pending champion promotion; no approved name or mechanic is committed |",
        "| Champion primary | Pending; Arc Primary remains the shared executable foundation |",
        "| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |",
        "| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |",
        "| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |",
    ]


def build_section() -> str:
    ids = [str(entry["id"]) for entry in ROSTER]
    if len(ROSTER) != 24 or len(ids) != len(set(ids)):
        raise RuntimeError("Champion README generation requires exactly 24 unique roster slots")
    if set(CONFIRMED_KITS) - set(ids):
        raise RuntimeError("A confirmed kit references a champion missing from the roster")

    missing: list[str] = []
    for champion_id in ids:
        for relative in sprite_paths(champion_id):
            if not (ROOT / relative).is_file():
                missing.append(relative)
    if missing:
        raise FileNotFoundError("Missing champion visual assets:\n" + "\n".join(missing))

    lines: list[str] = [
        START_HEADING.rstrip(),
        "",
        BEGIN_MARKER,
        "",
        "The 24 entries below are the current migration roster: 23 named designs",
        "and one deliberately unapproved Angel slot. **Ancestry** is the current",
        "term for race. Each card embeds the eight-direction documentation preview",
        "that ships beside the runtime-addressable atlas; the preview is for README",
        "inspection, while the linked atlas is the asset consumed by presentation",
        "loaders. These generated packages are integrated candidates, not accepted",
        "final art and not proof that a champion is selectable.",
        "",
        "![Current runtime-addressable champion sprite roster](assets/sprites/champions/roster_overview_v1.png)",
        "",
        "| Repository fact | Current meaning |",
        "| --- | --- |",
        "| Executable shared combat foundation | Arc Primary and Vector Lance exist, but they are not final per-champion kits |",
        "| Preserved named kits | Oh Tipi, S. Wayne, The Red Baron, Steezo, Treevor the Mason, Oll' I and Fluup retain approved ability names; mechanics remain unimplemented |",
        "| Remaining named champions | Identity, ancestry, elements, role and sprite package exist; character-specific ability names remain pending |",
        "| Void terminology | The Red Baron and Grimm Bow still carry legacy Void design data while visual generation currently uses Dark; this must be reconciled explicitly |",
        "| Angel slot | Body-plan and visual placeholder only; identity, lore and kit remain unapproved and non-selectable |",
        "",
        "### Character roster index",
        "",
        "| Sprite | Champion | Ancestry (race) | Size | Elements | Intended role | Kit state |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]

    for entry in ROSTER:
        champion_id = str(entry["id"])
        preview, _, _ = sprite_paths(champion_id)
        kit_state = (
            "Named design kit; not implemented"
            if champion_id in CONFIRMED_KITS
            else "Unapproved placeholder"
            if bool(entry.get("placeholder", False))
            else "Kit pending"
        )
        lines.append(
            f'| <img src="{preview}" alt="{md(entry["name"])} directional in-game sprite preview" width="192"> '
            f'| **{md(entry["name"])}** | {md(entry["ancestry"])} | {md(entry["size"])} '
            f'| {md(entry["elements"])} | {md(entry["role"])} | {kit_state} |'
        )

    lines.extend(["", "### Detailed character cards", ""])

    for entry in ROSTER:
        champion_id = str(entry["id"])
        preview, atlas, portrait = sprite_paths(champion_id)
        placeholder = bool(entry.get("placeholder", False))
        lines.extend(
            [
                f'<details id="champion-{champion_id}">',
                f'<summary><strong>{md(entry["name"])}</strong> — {md(entry["ancestry"])} · {md(entry["elements"])}</summary>',
                "",
                f'<img src="{preview}" alt="{md(entry["name"])} eight-direction runtime sprite preview" width="512">',
                "",
                "| Field | Repository state |",
                "| --- | --- |",
                f'| Ancestry / legacy race | **{md(entry["ancestry"])}** |',
                f'| Visual size class | **{md(entry["size"])}** |',
                f'| Draft affinities | **{md(entry["elements"])}** |',
                f'| Signature equipment | **{md(entry["weapon"])}** |',
                f'| Core gameplay identity | {md(entry["role"])} |',
                f'| Identity and migration notes | {md(entry["notes"])} |',
                f'| Runtime atlas | [`{atlas}`]({atlas}) |',
                f'| Portrait candidate | [`{portrait}`]({portrait}) |',
                "| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |",
                "",
                *kit_table(champion_id, placeholder),
                "",
                "</details>",
                "",
            ]
        )

    lines.extend(
        [
            "New arachnoid champions occupy expansion slots only after the body plans,",
            "names, lore, silhouettes, skeletons, movement clearance, trait budgets and",
            "one complete kit are reviewed. No placeholder becomes selectable merely to",
            "fill a roster column.",
            "",
            END_MARKER,
        ]
    )
    return "\n".join(lines).rstrip() + "\n\n"


def main() -> None:
    original = README.read_text(encoding="utf-8")
    start = original.find(START_HEADING)
    end = original.find(END_HEADING)
    if start < 0 or end < 0 or end <= start:
        raise RuntimeError("README champion section boundaries were not found")

    generated = build_section()
    updated = original[:start] + generated + original[end:]
    if updated == original:
        print("README character roster already current")
        return

    README.write_text(updated, encoding="utf-8")
    print(f"Updated README with {len(ROSTER)} detailed champion cards")


if __name__ == "__main__":
    main()
