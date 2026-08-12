class_name SpriteSheetExtractor
extends RefCounted


const SCHEMA_VERSION: int = 1
const TARGET_SIZE: int = 96
const CONTENT_MARGIN: int = 4
const PIVOT: Vector2i = Vector2i(TARGET_SIZE / 2, 84)
const ALPHA_THRESHOLD: float = 1.0 / 255.0

var normalized_frames: Array[Image] = []
var manifest: Dictionary = {}
var last_error: String = ""


func extract(source: Image, columns: int, rows: int, frame_count: int) -> bool:
	normalized_frames.clear()
	manifest.clear()
	last_error = ""
	if source == null or source.is_empty():
		return _fail("Sprite sheet source image is empty")
	if columns < 1 or rows < 1:
		return _fail("Sprite sheet grid dimensions must be positive")
	if frame_count != columns * rows:
		return _fail("Sprite sheet frame count must exactly match the declared grid")
	if source.get_width() % columns != 0 or source.get_height() % rows != 0:
		return _fail("Sprite sheet dimensions must divide exactly into the declared grid")

	var working := source.duplicate()
	if working.get_format() != Image.FORMAT_RGBA8:
		working.convert(Image.FORMAT_RGBA8)
	var source_digest := _png_sha256(working)
	if source_digest.is_empty():
		return _fail("Sprite sheet source image could not be hashed")
	var cell_size := Vector2i(working.get_width() / columns, working.get_height() / rows)
	if cell_size.x < 3 or cell_size.y < 3:
		return _fail("Sprite sheet cells are too small for transparent clipping margins")

	var frame_records: Array[Dictionary] = []
	var pending_frames: Array[Image] = []
	for index: int in frame_count:
		var cell_origin := Vector2i((index % columns) * cell_size.x, (index / columns) * cell_size.y)
		var cell: Image = working.get_region(Rect2i(cell_origin, cell_size))
		var inspection := _inspect_cell(cell)
		if not bool(inspection.get("valid", false)):
			return _fail("Sprite sheet frame %d %s" % [index, String(inspection.get("error", "is invalid"))])
		var bounds: Rect2i = inspection["bounds"]
		var content: Image = cell.get_region(bounds)
		var available_width := TARGET_SIZE - CONTENT_MARGIN * 2
		var available_height := PIVOT.y - CONTENT_MARGIN
		var scale := minf(float(available_width) / float(content.get_width()), float(available_height) / float(content.get_height()))
		var normalized_size := Vector2i(
			maxi(1, int(floor(float(content.get_width()) * scale))),
			maxi(1, int(floor(float(content.get_height()) * scale)))
		)
		content.resize(normalized_size.x, normalized_size.y, Image.INTERPOLATE_NEAREST)
		var offset := Vector2i((TARGET_SIZE - normalized_size.x) / 2, PIVOT.y - normalized_size.y)
		if offset.x < CONTENT_MARGIN or offset.y < CONTENT_MARGIN:
			return _fail("Sprite sheet frame %d cannot fit inside normalized margins" % index)
		var normalized := Image.create(TARGET_SIZE, TARGET_SIZE, false, Image.FORMAT_RGBA8)
		normalized.fill(Color(0.0, 0.0, 0.0, 0.0))
		normalized.blit_rect(content, Rect2i(Vector2i.ZERO, normalized_size), offset)
		var digest := _png_sha256(normalized)
		if digest.is_empty():
			return _fail("Sprite sheet frame %d could not be hashed" % index)
		pending_frames.append(normalized)
		frame_records.append({
			"index": index,
			"source_cell": [cell_origin.x, cell_origin.y, cell_size.x, cell_size.y],
			"content_bounds": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y],
			"visible_pixels": int(inspection["visible_pixels"]),
			"normalized_size": [normalized_size.x, normalized_size.y],
			"offset": [offset.x, offset.y],
			"pivot": [PIVOT.x, PIVOT.y],
			"sha256": digest,
		})

	normalized_frames = pending_frames
	manifest = {
		"schema_version": SCHEMA_VERSION,
		"authority": "presentation_only",
		"runtime_approved": false,
		"source_dimensions": [working.get_width(), working.get_height()],
		"source_rgba8_png_sha256": source_digest,
		"grid": [columns, rows],
		"frame_count": frame_count,
		"target_dimensions": [TARGET_SIZE, TARGET_SIZE],
		"pivot": [PIVOT.x, PIVOT.y],
		"frames": frame_records,
	}
	return true


func _inspect_cell(cell: Image) -> Dictionary:
	var minimum := Vector2i(cell.get_width(), cell.get_height())
	var maximum := Vector2i(-1, -1)
	var visible_pixels: int = 0
	var transparent_pixels: int = 0
	for y: int in cell.get_height():
		for x: int in cell.get_width():
			if cell.get_pixel(x, y).a <= ALPHA_THRESHOLD:
				transparent_pixels += 1
				continue
			visible_pixels += 1
			minimum.x = mini(minimum.x, x)
			minimum.y = mini(minimum.y, y)
			maximum.x = maxi(maximum.x, x)
			maximum.y = maxi(maximum.y, y)
	if transparent_pixels == 0:
		return {"valid": false, "error": "background must contain transparent pixels"}
	if visible_pixels == 0:
		return {"valid": false, "error": "contains no visible sprite pixels"}
	if minimum.x == 0 or minimum.y == 0 or maximum.x == cell.get_width() - 1 or maximum.y == cell.get_height() - 1:
		return {"valid": false, "error": "has visible pixels clipped against a cell edge"}
	return {
		"valid": true,
		"visible_pixels": visible_pixels,
		"bounds": Rect2i(minimum, maximum - minimum + Vector2i.ONE),
	}


func _png_sha256(image: Image) -> String:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	if context.update(image.save_png_to_buffer()) != OK:
		return ""
	return context.finish().hex_encode()


func _fail(message: String) -> bool:
	normalized_frames.clear()
	manifest.clear()
	last_error = message
	return false
