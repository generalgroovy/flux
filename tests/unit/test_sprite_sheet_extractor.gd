extends FluxTestSuite


const RAW_CANDIDATE_PATH: String = "res://assets/concept/champion_keypose_candidates/oh_tipi/oh_tipi_keypose_imagegen_v1.png"


func run() -> int:
	_test_repository_candidate_fails_before_output()
	_test_valid_grid_normalizes_deterministically()
	_test_source_is_immutable_and_failed_reuse_clears_state()
	_test_invalid_inputs_fail_closed()
	return finish("sprite-sheet-extractor")


func _test_repository_candidate_fails_before_output() -> void:
	var candidate := Image.new()
	var bytes := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(RAW_CANDIDATE_PATH))
	equal(candidate.load_png_from_buffer(bytes), OK, "quarantined Oh Tipi study loads for structural rejection")
	var extractor := SpriteSheetExtractor.new()
	check(not extractor.extract(candidate, 5, 5, 25), "1254-square candidate fails exact five-by-five extraction")
	check("divide exactly" in extractor.last_error, "unequal-grid rejection is actionable")
	equal(extractor.normalized_frames.size(), 0, "rejected candidate emits no normalized frames")
	equal(extractor.manifest, {}, "rejected candidate emits no promotion-shaped manifest")


func _test_valid_grid_normalizes_deterministically() -> void:
	var source := _valid_sheet()
	var first := SpriteSheetExtractor.new()
	var second := SpriteSheetExtractor.new()
	check(first.extract(source, 5, 5, 25), "valid transparent exact grid extracts: %s" % first.last_error)
	check(second.extract(source, 5, 5, 25), "repeat extraction succeeds: %s" % second.last_error)
	equal(first.normalized_frames.size(), 25, "all declared frames are normalized")
	equal(first.manifest.get("schema_version"), 1, "extraction manifest is versioned")
	equal(first.manifest.get("authority"), "presentation_only", "extracted art cannot own gameplay")
	check(not bool(first.manifest.get("runtime_approved", true)), "extraction never grants runtime approval")
	equal(first.manifest.get("target_dimensions"), [96, 96], "runtime frame dimensions are normalized")
	equal(first.manifest.get("pivot"), [48, 92], "shared pivot is bottom-center above the margin")
	equal(String(first.manifest.get("source_rgba8_png_sha256", "")).length(), 64, "decoded source image has SHA-256 evidence")
	equal(first.manifest.get("source_rgba8_png_sha256"), second.manifest.get("source_rgba8_png_sha256"), "repeat extraction source hash is deterministic")
	var first_records: Array = first.manifest.get("frames", [])
	var second_records: Array = second.manifest.get("frames", [])
	equal(first_records.size(), 25, "manifest records every ordered frame")
	for index: int in first_records.size():
		var record: Dictionary = first_records[index]
		var repeat: Dictionary = second_records[index]
		equal(int(record.get("index", -1)), index, "frame ordering remains row-major")
		equal(record.get("pivot"), [48, 92], "frame pivot matches manifest pivot")
		equal(String(record.get("sha256", "")).length(), 64, "frame PNG has SHA-256 evidence")
		equal(record.get("sha256"), repeat.get("sha256"), "repeat extraction hash is deterministic")
		var offset: Array = record.get("offset", [])
		var size: Array = record.get("normalized_size", [])
		equal(int(offset[1]) + int(size[1]), 92, "visible content is aligned to the bottom pivot")
		equal(first.normalized_frames[index].get_size(), Vector2i(96, 96), "normalized image is 96 square")
	check(String((first_records[0] as Dictionary).get("sha256")) != String((first_records[1] as Dictionary).get("sha256")), "different ordered frames retain distinct pixel hashes")


func _test_source_is_immutable_and_failed_reuse_clears_state() -> void:
	var source := _valid_sheet()
	var original_format := source.get_format()
	var original_bytes := source.save_png_to_buffer()
	var extractor := SpriteSheetExtractor.new()
	check(extractor.extract(source, 5, 5, 25), "initial reusable extraction succeeds: %s" % extractor.last_error)
	equal(source.get_format(), original_format, "extractor does not convert the caller image in place")
	equal(source.save_png_to_buffer(), original_bytes, "extractor does not resize or modify caller pixels")
	check(not extractor.extract(source, 5, 5, 24), "later invalid reuse fails closed")
	equal(extractor.normalized_frames.size(), 0, "failed reuse clears previously normalized frames")
	equal(extractor.manifest, {}, "failed reuse clears the previous success manifest")
	check("exactly match" in extractor.last_error, "failed reuse replaces stale success with actionable error evidence")


func _test_invalid_inputs_fail_closed() -> void:
	var valid := _valid_sheet()
	var invalid_cases: Array[Dictionary] = [
		{"name": "zero grid", "image": valid, "columns": 0, "rows": 5, "count": 25, "error": "positive"},
		{"name": "wrong count", "image": valid, "columns": 5, "rows": 5, "count": 24, "error": "exactly match"},
		{"name": "unequal dimensions", "image": _valid_sheet(Vector2i(51, 50)), "columns": 5, "rows": 5, "count": 25, "error": "divide exactly"},
		{"name": "opaque", "image": _opaque_sheet(), "columns": 1, "rows": 1, "count": 1, "error": "transparent"},
		{"name": "empty", "image": _empty_sheet(), "columns": 1, "rows": 1, "count": 1, "error": "no visible"},
		{"name": "edge clipped", "image": _edge_clipped_sheet(), "columns": 1, "rows": 1, "count": 1, "error": "cell edge"},
	]
	for invalid: Dictionary in invalid_cases:
		var extractor := SpriteSheetExtractor.new()
		check(not extractor.extract(invalid["image"], invalid["columns"], invalid["rows"], invalid["count"]), "%s input fails closed" % invalid["name"])
		check(String(invalid["error"]) in extractor.last_error, "%s rejection is actionable" % invalid["name"])
		equal(extractor.normalized_frames.size(), 0, "%s input emits no frames" % invalid["name"])
		equal(extractor.manifest, {}, "%s input emits no manifest" % invalid["name"])


func _valid_sheet(size: Vector2i = Vector2i(50, 50)) -> Image:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	if size != Vector2i(50, 50):
		return image
	for index: int in 25:
		var origin := Vector2i((index % 5) * 10, (index / 5) * 10)
		var color := Color(float(index + 1) / 26.0, 0.35, 1.0 - float(index + 1) / 52.0, 1.0)
		for y: int in range(2, 8):
			for x: int in range(3, 7):
				image.set_pixel(origin.x + x, origin.y + y, color)
	return image


func _opaque_sheet() -> Image:
	var image := Image.create(10, 10, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return image


func _empty_sheet() -> Image:
	var image := Image.create(10, 10, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	return image


func _edge_clipped_sheet() -> Image:
	var image := _empty_sheet()
	for y: int in range(3, 7):
		image.set_pixel(0, y, Color.WHITE)
	return image
