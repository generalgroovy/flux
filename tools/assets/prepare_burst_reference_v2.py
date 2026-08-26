#!/usr/bin/env python3
"""Validate/split FLUX Burst v2 combined reference atlases. Presentation-only."""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[2]
REF_ROOT = ROOT / "reference/art/projectiles/burst_v2"
ELEMENTS = ("neutral", "fire", "water", "wind", "earth", "charge", "ice", "light", "dark")
REF_CELL = 64
RUNTIME_CELL = 32
COLS = 16
DIR_ROWS = 8

def cell(image: Image.Image, col: int, row: int, size: int) -> Image.Image:
    return image.crop((col*size,row*size,(col+1)*size,(row+1)*size))

def assert_mirror(image: Image.Image, base_row: int, source: int, target: int, transpose: Image.Transpose, cell_size: int) -> None:
    for col in range(COLS):
        expected = cell(image,col,base_row+source,cell_size).transpose(transpose)
        actual = cell(image,col,base_row+target,cell_size)
        if ImageChops.difference(expected,actual).getbbox() is not None:
            raise SystemExit(f"mirror validation failed base={base_row} rows {source}->{target} col={col}")

def validate(image: Image.Image, cell_size: int) -> None:
    expected=(COLS*cell_size,len(ELEMENTS)*DIR_ROWS*cell_size)
    if image.size != expected:
        raise SystemExit(f"expected {expected}, got {image.size}")
    for idx,_element in enumerate(ELEMENTS):
        base=idx*DIR_ROWS
        assert_mirror(image,base,0,4,Image.Transpose.FLIP_TOP_BOTTOM,cell_size)
        assert_mirror(image,base,3,5,Image.Transpose.FLIP_LEFT_RIGHT,cell_size)
        assert_mirror(image,base,2,6,Image.Transpose.FLIP_LEFT_RIGHT,cell_size)
        assert_mirror(image,base,1,7,Image.Transpose.FLIP_LEFT_RIGHT,cell_size)

def main() -> None:
    reference=Image.open(REF_ROOT/"burst_all_elements_reference_64.png").convert("RGBA")
    runtime=Image.open(REF_ROOT/"burst_all_elements_runtime_candidate_32.png").convert("RGBA")
    validate(reference,REF_CELL)
    validate(runtime,RUNTIME_CELL)
    out=REF_ROOT/"generated"
    out.mkdir(exist_ok=True)
    for idx,element in enumerate(ELEMENTS):
        y0=idx*DIR_ROWS*RUNTIME_CELL
        y1=(idx+1)*DIR_ROWS*RUNTIME_CELL
        runtime.crop((0,y0,runtime.width,y1)).save(out/f"burst_{element}_runtime_candidate_32.png", optimize=True, compress_level=9)
        print((out/f"burst_{element}_runtime_candidate_32.png").relative_to(ROOT))

if __name__ == "__main__":
    main()
