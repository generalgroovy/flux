#!/usr/bin/env python3
"""Enhance the generated champion README section with the approved art baseline.

The user-supplied FLUX Champions sheet is the minimum visual-quality baseline.
This pass keeps documentation honest by presenting two distinct images per
champion:

* the larger character-detail candidate, used to inspect expression, silhouette,
  equipment and material rendering;
* the current eight-direction runtime sprite preview, linked to the actual atlas
  consumed by the Godot presentation layer.

Neither image is promoted to accepted final art merely because it appears in the
README. The runtime sprite must ultimately match or exceed the supplied baseline.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
README = ROOT / "README.md"
BEGIN = "<!-- BEGIN CHARACTER_ROSTER_V1 -->"
END = "<!-- END CHARACTER_ROSTER_V1 -->"
STYLE_BASELINE = "art/reference/flux-champions-style-baseline.png"


def enhance(section: str) -> str:
    intro_old = (
        "The 24 entries below are the current migration roster: 23 named designs\n"
        "and one deliberately unapproved Angel slot. **Ancestry** is the current\n"
        "term for race. Each card embeds the eight-direction documentation preview\n"
        "that ships beside the runtime-addressable atlas; the preview is for README\n"
        "inspection, while the linked atlas is the asset consumed by presentation\n"
        "loaders. These generated packages are integrated candidates, not accepted\n"
        "final art and not proof that a champion is selectable.\n"
    )
    intro_new = (
        "The 24 entries below are the current migration roster: 23 named designs\n"
        "and one deliberately unapproved Angel slot. **Ancestry** is the current\n"
        "term for race. The supplied FLUX Champions sheet below is the minimum\n"
        "accepted visual baseline for character expression, silhouette, equipment,\n"
        "materials, elemental framing and pixel-art density. Canonical Flux2 data\n"
        "still overrides conflicting labels visible in that reference.\n\n"
        f"![FLUX Champions minimum character-art baseline]({STYLE_BASELINE})\n\n"
        "Every roster entry therefore shows both the higher-detail character\n"
        "candidate and the current eight-direction runtime sprite. The runtime image\n"
        "is the one connected to the in-game atlas; the larger image is a visual\n"
        "review candidate. Neither is accepted final art until the runtime sprite\n"
        "matches or exceeds the baseline and passes the ordered visual-quality gate.\n"
    )
    if intro_old not in section:
        raise RuntimeError("Generated character introduction was not found")
    section = section.replace(intro_old, intro_new, 1)

    # Upgrade the compact roster index from a single low-resolution runtime strip
    # to a detail/runtime pair without changing canonical text fields.
    index_pattern = re.compile(
        r'<img src="assets/sprites/champions/(?P<id>[a-z0-9_]+)/(?P=id)_direction_preview\.png" '
        r'alt="(?P<name>[^"]+) directional in-game sprite preview" width="192">'
    )

    def index_replacement(match: re.Match[str]) -> str:
        champion_id = match.group("id")
        name = match.group("name")
        return (
            f'<img src="assets/sprites/champions_v2/{champion_id}/hero_portrait_256.png" '
            f'alt="{name} high-detail character candidate" width="128"><br>'
            f'<sub>detail candidate</sub><br>'
            f'<img src="assets/sprites/champions/{champion_id}/{champion_id}_direction_preview.png" '
            f'alt="{name} current in-game directional sprite" width="192"><br>'
            f'<sub>current runtime sprite</sub>'
        )

    section, index_count = index_pattern.subn(index_replacement, section)
    if index_count != 24:
        raise RuntimeError(f"Expected 24 roster-index sprite replacements, got {index_count}")

    # Replace the single image at the top of each detailed card with a visual
    # comparison pair. This makes the quality gap explicit rather than hiding it.
    card_pattern = re.compile(
        r'<img src="assets/sprites/champions/(?P<id>[a-z0-9_]+)/(?P=id)_direction_preview\.png" '
        r'alt="(?P<name>[^"]+) eight-direction runtime sprite preview" width="512">'
    )

    def card_replacement(match: re.Match[str]) -> str:
        champion_id = match.group("id")
        name = match.group("name")
        return (
            "<table>\n"
            "<tr>\n"
            f'<td align="center"><img src="assets/sprites/champions_v2/{champion_id}/hero_portrait_256.png" '
            f'alt="{name} high-detail character candidate" width="256"></td>\n'
            f'<td align="center"><img src="assets/sprites/champions/{champion_id}/{champion_id}_direction_preview.png" '
            f'alt="{name} current eight-direction in-game sprite" width="512"></td>\n'
            "</tr>\n"
            "<tr>\n"
            "<td align=\"center\"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>\n"
            "<td align=\"center\"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>\n"
            "</tr>\n"
            "</table>"
        )

    section, card_count = card_pattern.subn(card_replacement, section)
    if card_count != 24:
        raise RuntimeError(f"Expected 24 detailed-card sprite replacements, got {card_count}")

    portrait_row = re.compile(
        r'\| Portrait candidate \| \[`assets/sprites/champions/(?P<id>[a-z0-9_]+)/(?P=id)_portrait\.png`\]'
        r'\(assets/sprites/champions/(?P=id)/(?P=id)_portrait\.png\) \|'
    )

    def portrait_rows(match: re.Match[str]) -> str:
        champion_id = match.group("id")
        return (
            f'| Runtime portrait candidate | [`assets/sprites/champions/{champion_id}/{champion_id}_portrait.png`]'
            f'(assets/sprites/champions/{champion_id}/{champion_id}_portrait.png) |\n'
            f'| High-detail portrait candidate | [`assets/sprites/champions_v2/{champion_id}/hero_portrait_256.png`]'
            f'(assets/sprites/champions_v2/{champion_id}/hero_portrait_256.png) |\n'
            f'| Animation/keyframe board | [`assets/sprites/champions_v2/{champion_id}/keyframe_board.png`]'
            f'(assets/sprites/champions_v2/{champion_id}/keyframe_board.png) |\n'
            f'| Visual acceptance target | Must match or exceed [`{STYLE_BASELINE}`]({STYLE_BASELINE}) in expression, silhouette, material detail and charm |'
        )

    section, portrait_count = portrait_row.subn(portrait_rows, section)
    if portrait_count != 24:
        raise RuntimeError(f"Expected 24 portrait-row enhancements, got {portrait_count}")

    return section


def main() -> None:
    text = README.read_text(encoding="utf-8")
    start = text.find(BEGIN)
    end = text.find(END)
    if start < 0 or end < 0 or end <= start:
        raise RuntimeError("Generated character roster markers were not found")
    end += len(END)

    section = text[start:end]
    enhanced = enhance(section)
    updated = text[:start] + enhanced + text[end:]
    README.write_text(updated, encoding="utf-8")
    print("Enhanced 24 champion cards with detail/runtime comparisons and baseline gates")


if __name__ == "__main__":
    main()
