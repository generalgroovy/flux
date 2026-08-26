"""Build the reviewed four-cardinal FLUX body-only champion atlas.

Each source is a four-column by four-row matte sheet. Columns are cardinal
directions and rows are semantic action poses. The generated canvas may not be
exactly divisible by four, so cell edges are derived proportionally instead of
silently dropping border pixels. One scale is calculated per champion from its
south idle pose and bounded against every pose; action changes therefore never
resize the champion body.

Spell, aura, shadow, environment, equipment, and gameplay state are excluded.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image

from build_foundation_champion_sprites import remove_edge_matte


SOURCE_COLUMNS = 4
SOURCE_ROWS = 4
OUTPUT_CELL = 96
OUTPUT_PIVOT_Y = 84
DIRECTIONS = ("south", "east", "north", "west")
STATES = ("grounded", "jump", "cast", "hit")
CHAMPIONS = ("oh_tipi", "s_wayne")
TARGET_IDLE_HEIGHTS = (68, 58)
MAX_SPRITE_EXTENT = 92


def proportional_bounds(index: int, count: int, extent: int) -> tuple[int, int]:
    """Return adjacent rounded boundaries that retain the complete source."""
    return round(index * extent / count), round((index + 1) * extent / count)


def isolated_sprite(source: Image.Image, row: int, column: int) -> Image.Image:
    left, right = proportional_bounds(column, SOURCE_COLUMNS, source.width)
    top, bottom = proportional_bounds(row, SOURCE_ROWS, source.height)
    transparent = remove_edge_matte(source.crop((left, top, right, bottom)))
    bounds = transparent.getbbox()
    if bounds is None:
        raise ValueError(f"source cell {row},{column} contains no isolated sprite")
    return transparent.crop(bounds)


def champion_scale(sprites: list[list[Image.Image]], target_idle_height: int) -> float:
    idle = sprites[0][0]
    scale = target_idle_height / idle.height
    widest = max(sprite.width for row in sprites for sprite in row)
    tallest = max(sprite.height for row in sprites for sprite in row)
    return min(scale, MAX_SPRITE_EXTENT / widest, MAX_SPRITE_EXTENT / tallest)


def fit_sprite(sprite: Image.Image, scale: float) -> Image.Image:
    size = (max(1, round(sprite.width * scale)), max(1, round(sprite.height * scale)))
    return sprite.resize(size, Image.Resampling.LANCZOS)


def build(source_paths: tuple[Path, Path], output_path: Path) -> None:
    atlas = Image.new(
        "RGBA",
        (len(DIRECTIONS) * OUTPUT_CELL, len(CHAMPIONS) * len(STATES) * OUTPUT_CELL),
    )
    for champion_index, source_path in enumerate(source_paths):
        source = Image.open(source_path).convert("RGB")
        if source.width < 4 or source.height < 4:
            raise ValueError(f"source sheet is too small: {source_path} {source.size}")
        sprites = [
            [isolated_sprite(source, row, column) for column in range(SOURCE_COLUMNS)]
            for row in range(SOURCE_ROWS)
        ]
        scale = champion_scale(sprites, TARGET_IDLE_HEIGHTS[champion_index])
        for state_index, row in enumerate(sprites):
            atlas_row = champion_index * len(STATES) + state_index
            for direction_index, sprite in enumerate(row):
                fitted = fit_sprite(sprite, scale)
                x = direction_index * OUTPUT_CELL + (OUTPUT_CELL - fitted.width) // 2
                y = atlas_row * OUTPUT_CELL + OUTPUT_PIVOT_Y - fitted.height
                atlas.alpha_composite(fitted, (x, y))

    alpha = atlas.getchannel("A").point(lambda value: 255 if value >= 48 else 0)
    atlas = atlas.convert("RGB").quantize(
        colors=48,
        method=Image.Quantize.FASTOCTREE,
        dither=Image.Dither.NONE,
    ).convert("RGBA")
    atlas.putalpha(alpha)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(output_path, optimize=True)
    print(
        f"built {output_path} {atlas.width}x{atlas.height}; "
        f"columns={','.join(DIRECTIONS)}; states={','.join(STATES)}"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("oh_tipi_source", type=Path)
    parser.add_argument("s_wayne_source", type=Path)
    parser.add_argument("output", type=Path)
    arguments = parser.parse_args()
    build(
        (arguments.oh_tipi_source, arguments.s_wayne_source),
        arguments.output,
    )


if __name__ == "__main__":
    main()
