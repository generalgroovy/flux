#!/usr/bin/env python3
"""Measure structural visual quality for Wellspring v2/v3 runtime art.

This is not a substitute for human art direction. It prevents regressions to
blank, near-monochrome, unpopulated, clipped or animation-incomplete assets and
keeps the generated baseline useful while hand-authored refinement continues.
"""
from __future__ import annotations

import json
from pathlib import Path
from statistics import mean
from typing import Any

from PIL import Image, ImageStat

import generate_visual_assets_v1 as base

ROOT = Path(__file__).resolve().parents[2]
CATALOG_PATH = ROOT / "content/visual/wellspring_visual_catalog_v2.json"
CELL = 64
BLOCK_W = 384
BLOCK_H = 512


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def resource_path(value: str) -> Path:
    if not value.startswith("res://"):
        raise ValueError(f"invalid resource path: {value}")
    return ROOT / value.removeprefix("res://")


def color_count(image: Image.Image) -> int:
    rgba = image.convert("RGBA")
    colors = rgba.getcolors(maxcolors=rgba.width * rgba.height)
    if colors is None:
        return rgba.width * rgba.height
    return len([color for count, color in colors if color[3] > 0 and count > 0])


def occupied_ratio(image: Image.Image) -> float:
    rgba = image.convert("RGBA")
    bbox = rgba.getbbox()
    if bbox is None:
        return 0.0
    area = max(0, bbox[2] - bbox[0]) * max(0, bbox[3] - bbox[1])
    return area / float(rgba.width * rgba.height)


def luminance_spread(image: Image.Image) -> float:
    rgba = image.convert("RGBA")
    background = Image.new("RGBA", rgba.size, (0, 0, 0, 255))
    background.alpha_composite(rgba)
    gray = background.convert("L")
    stat = ImageStat.Stat(gray)
    return float(stat.stddev[0])


def frame_quality(atlas: Image.Image, animation: str, direction: int, frame_index: int) -> tuple[float, int, tuple[int, int, int, int] | None]:
    block_x, block_y, _frames, _fps = base.A[animation]
    x = block_x * BLOCK_W + frame_index * CELL
    y = block_y * BLOCK_H + direction * CELL
    frame = atlas.crop((x, y, x + CELL, y + CELL)).convert("RGBA")
    return occupied_ratio(frame), color_count(frame), frame.getbbox()


def validate_character_package(entry: dict[str, Any], label: str, errors: list[str]) -> None:
    atlas_path = resource_path(str(entry["atlas"]))
    with Image.open(atlas_path) as atlas_source:
        atlas = atlas_source.convert("RGBA")
    ratios: list[float] = []
    colors: list[int] = []
    for animation, (_block_x, _block_y, frame_count, _fps) in base.A.items():
        for direction in range(8):
            for frame_index in range(frame_count):
                ratio, count, bbox = frame_quality(atlas, animation, direction, frame_index)
                ratios.append(ratio)
                colors.append(count)
                if bbox is None:
                    errors.append(f"{label}: blank frame {animation}/{direction}/{frame_index}")
                    continue
                if bbox[0] <= 0 or bbox[2] >= CELL:
                    errors.append(f"{label}: horizontal clipping risk in {animation}/{direction}/{frame_index}: {bbox}")
                if bbox[1] <= 0:
                    errors.append(f"{label}: top clipping risk in {animation}/{direction}/{frame_index}: {bbox}")
                if bbox[3] > CELL:
                    errors.append(f"{label}: invalid frame bounds in {animation}/{direction}/{frame_index}: {bbox}")
    if min(ratios, default=0.0) < 0.035:
        errors.append(f"{label}: one or more frames occupy too little of the 64 px envelope")
    if mean(ratios) < 0.10:
        errors.append(f"{label}: average frame occupancy is too low ({mean(ratios):.3f})")
    if min(colors, default=0) < 5:
        errors.append(f"{label}: one or more frames have insufficient color structure")

    for key, minimum_colors, minimum_spread in (
        ("selection_icon", 12, 20.0),
        ("hud_portrait", 14, 22.0),
        ("roster_portrait", 18, 24.0),
        ("hero_portrait", 20, 25.0),
    ):
        path = resource_path(str(entry[key]))
        with Image.open(path) as source:
            image = source.convert("RGBA")
        count = color_count(image)
        spread = luminance_spread(image)
        ratio = occupied_ratio(image)
        if count < minimum_colors:
            errors.append(f"{label}: {key} has {count} colors; expected at least {minimum_colors}")
        if spread < minimum_spread:
            errors.append(f"{label}: {key} value spread {spread:.2f} is too flat")
        if ratio < 0.70:
            errors.append(f"{label}: {key} composition occupies only {ratio:.2%}")


def validate_map(path: Path, label: str, errors: list[str]) -> None:
    with Image.open(path) as source:
        image = source.convert("RGBA")
    count = color_count(image)
    spread = luminance_spread(image)
    if count < 18:
        errors.append(f"{label}: only {count} colors; district lacks material variation")
    if spread < 18.0:
        errors.append(f"{label}: value spread {spread:.2f} is too flat")


def main() -> int:
    catalog = load_json(CATALOG_PATH)
    errors: list[str] = []

    for race_id, race in catalog.get("races", {}).items():
        validate_character_package(race["exemplar"], f"race exemplar {race_id}", errors)
        matrix_path = resource_path(str(race["matrix_preview"]))
        with Image.open(matrix_path) as source:
            matrix = source.convert("RGBA")
        if color_count(matrix) < 18:
            errors.append(f"race matrix {race_id}: insufficient palette diversity")

    for champion_id, champion in catalog.get("champions", {}).items():
        validate_character_package(champion, f"champion {champion_id}", errors)

    for district_id, district in catalog.get("wellspring", {}).get("districts", {}).items():
        validate_map(resource_path(str(district["preview"])), f"Wellspring district {district_id}", errors)

    support_images = {
        "Wellspring overview": catalog["wellspring"]["overview_1440p"],
        "Wellspring tiles": catalog["wellspring"]["tileset"],
        "Cosmic Wellspring cascade": catalog["wellspring"]["cosmic_cascade"],
        "material states": catalog["materials"]["path"],
        "prop states": catalog["props"]["path"],
        "element VFX": catalog["element_vfx"]["path"],
        "UI skin": catalog["ui"]["skin"],
        "UI surface overview": catalog["ui"]["surface_overview"],
    }
    for label, resource in support_images.items():
        path = resource_path(str(resource))
        with Image.open(path) as source:
            image = source.convert("RGBA")
        if color_count(image) < 12:
            errors.append(f"{label}: insufficient color structure")
        if luminance_spread(image) < 14.0:
            errors.append(f"{label}: insufficient value separation")

    if errors:
        print("Wellspring structural visual-quality validation failed:")
        for error in errors[:200]:
            print(f"- {error}")
        if len(errors) > 200:
            print(f"- ... {len(errors) - 200} additional errors")
        return 1

    champion_count = len(catalog.get("champions", {}))
    race_count = len(catalog.get("races", {}))
    print("Wellspring structural visual-quality validation passed")
    print(f"checked every keyframe for {champion_count} champions and {race_count} race exemplars")
    print("checked portrait color/value/occupancy and all district/support asset families")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
