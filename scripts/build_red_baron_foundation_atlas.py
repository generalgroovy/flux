"""Extend the reviewed foundation atlas with Red Baron's body-only rows.

The source board contains one transparent pose for each of FLUX's fixed eight
directions. This deterministic builder normalizes those poses to the shared
96px cell and feet pivot, then derives bounded action contacts without adding
spell, aura, shadow, equipment, or world pixels. Existing champion rows are
copied without resampling.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


CELL = 96
PIVOT = (48, 84)
DIRECTION_COUNT = 8
STATE_ORDER = (
    "grounded", "jump", "cast", "hit", "walk", "sprint", "slide", "roll",
    "walk_b", "sprint_b",
)
TARGET_HEIGHT = 68
MAX_WIDTH = 90


def proportional_bounds(index: int, count: int, extent: int) -> tuple[int, int]:
    return round(index * extent / count), round((index + 1) * extent / count)


def source_poses(source: Image.Image) -> list[Image.Image]:
    poses: list[Image.Image] = []
    for index in range(DIRECTION_COUNT):
        left, right = proportional_bounds(index, DIRECTION_COUNT, source.width)
        pose = source.crop((left, 0, right, source.height))
        bounds = pose.getbbox()
        if bounds is None:
            raise ValueError(f"Red Baron source direction {index} is empty")
        poses.append(pose.crop(bounds))
    scale = min(
        TARGET_HEIGHT / poses[0].height,
        TARGET_HEIGHT / max(pose.height for pose in poses),
        MAX_WIDTH / max(pose.width for pose in poses),
    )
    return [
        pose.resize(
            (max(1, round(pose.width * scale)), max(1, round(pose.height * scale))),
            Image.Resampling.LANCZOS,
        )
        for pose in poses
    ]


def paste_at_pivot(canvas: Image.Image, pose: Image.Image, pivot_y: int = PIVOT[1]) -> None:
    x = PIVOT[0] - pose.width // 2
    y = pivot_y - pose.height
    canvas.alpha_composite(pose, (x, y))


def scaled_pose(pose: Image.Image, scale_x: float, scale_y: float) -> Image.Image:
    return pose.resize(
        (max(1, round(pose.width * scale_x)), max(1, round(pose.height * scale_y))),
        Image.Resampling.LANCZOS,
    )


def sheared_pose(pose: Image.Image, amount: int) -> Image.Image:
    padding = abs(amount) + 2
    output = Image.new("RGBA", (pose.width + padding * 2, pose.height))
    for y in range(pose.height):
        progress = 1.0 - float(y) / max(1.0, float(pose.height - 1))
        offset = round(amount * progress)
        strip = pose.crop((0, y, pose.width, y + 1))
        output.alpha_composite(strip, (padding + offset, y))
    return output


def alternate_boot_contact(cell: Image.Image, phase: int, intensity: int) -> Image.Image:
    result = cell.copy()
    top = 72
    left = cell.crop((20, top, PIVOT[0], CELL))
    right = cell.crop((PIVOT[0], top, 76, CELL))
    result.paste((0, 0, 0, 0), (20, top, 76, CELL))
    left_y = top - intensity if phase == 0 else top + 1
    right_y = top + 1 if phase == 0 else top - intensity
    result.alpha_composite(left, (19 if phase == 0 else 21, left_y))
    result.alpha_composite(right, (PIVOT[0] + 1 if phase == 0 else PIVOT[0] - 1, right_y))
    return result


def action_cell(pose: Image.Image, state: str, direction_index: int) -> Image.Image:
    cell = Image.new("RGBA", (CELL, CELL))
    horizontal_sign = 1 if direction_index in (1, 2, 3) else -1 if direction_index in (5, 6, 7) else 0
    if state == "jump":
        paste_at_pivot(cell, scaled_pose(pose, 0.98, 0.91), PIVOT[1] - 3)
    elif state == "cast":
        paste_at_pivot(cell, scaled_pose(pose, 1.045, 0.985))
    elif state == "hit":
        paste_at_pivot(cell, sheared_pose(pose, -horizontal_sign * 4 if horizontal_sign else 3))
    elif state == "slide":
        paste_at_pivot(cell, scaled_pose(pose, 1.04, 0.67), PIVOT[1] + 1)
    elif state == "roll":
        paste_at_pivot(cell, scaled_pose(pose, 0.78, 0.72), PIVOT[1])
    elif state in ("sprint", "sprint_b"):
        contact_phase = 0 if state == "sprint" else 1
        paste_at_pivot(cell, sheared_pose(pose, horizontal_sign * 3))
        cell = alternate_boot_contact(cell, contact_phase, 3)
    elif state in ("walk", "walk_b"):
        contact_phase = 0 if state == "walk" else 1
        paste_at_pivot(cell, pose)
        cell = alternate_boot_contact(cell, contact_phase, 2)
    else:
        paste_at_pivot(cell, pose)
    return cell


def build(base_path: Path, source_path: Path, output_path: Path) -> None:
    base = Image.open(base_path).convert("RGBA")
    if base.size != (DIRECTION_COUNT * CELL, 2 * len(STATE_ORDER) * CELL):
        raise ValueError(f"expected 768x1920 foundation atlas, got {base.size}")
    source = Image.open(source_path).convert("RGBA")
    poses = source_poses(source)
    atlas = Image.new("RGBA", (DIRECTION_COUNT * CELL, 3 * len(STATE_ORDER) * CELL))
    atlas.alpha_composite(base, (0, 0))
    red_baron_y = base.height
    for state_index, state in enumerate(STATE_ORDER):
        for direction_index, pose in enumerate(poses):
            cell = action_cell(pose, state, direction_index)
            atlas.alpha_composite(cell, (direction_index * CELL, red_baron_y + state_index * CELL))

    alpha = atlas.getchannel("A").point(lambda value: 255 if value >= 48 else 0)
    atlas = atlas.convert("RGB").quantize(
        colors=64,
        method=Image.Quantize.FASTOCTREE,
        dither=Image.Dither.NONE,
    ).convert("RGBA")
    atlas.putalpha(alpha)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(output_path, optimize=True)
    print(
        f"built {output_path} {atlas.width}x{atlas.height}; "
        f"champions=oh_tipi,s_wayne,red_baron; states={','.join(STATE_ORDER)}"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("base", type=Path)
    parser.add_argument("red_baron_source", type=Path)
    parser.add_argument("output", type=Path)
    arguments = parser.parse_args()
    build(arguments.base, arguments.red_baron_source, arguments.output)


if __name__ == "__main__":
    main()
