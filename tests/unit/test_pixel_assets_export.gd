extends FluxTestSuite

const Sources = preload("res://addons/pixel_assets_export/atlas_source_contract.gd")


func run() -> int:
	var result := Sources.collect_sources()
	equal(result.error, "", "all seven immutable source atlases are available to the exporter")
	equal(result.files.size(), 7, "export hook adds only seven live raw atlas files")
	equal(result.total_bytes, Sources.TOTAL_BYTES, "original raw payload stays bounded to118849 bytes")
	var seen: Dictionary = {}
	for index: int in range(Sources.SOURCES.size()):
		var source: Dictionary = Sources.SOURCES[index]
		var path: String = source.path
		check(not seen.has(path), "each export virtual path is unique")
		seen[path] = true
		check(path.begins_with("res://art_batches/pixel_v1/") and path.contains("/export/") and path.ends_with(".png") and not path.contains(".."), "allowlist excludes source documents and path escapes")
		var bytes := FileAccess.get_file_as_bytes(path)
		check(Sources.validate_bytes(index, bytes), "exported bytes have pinned source size and SHA256")
		var changed := bytes.duplicate()
		changed[changed.size() - 1] ^= 1
		check(not Sources.validate_bytes(index, changed), "same-size mutation cannot pass export validation")
		changed = bytes.slice(0, bytes.size() - 1)
		check(not Sources.validate_bytes(index, changed), "truncated atlas cannot pass export validation")
		check(not Sources.validate_bytes(index, PackedByteArray()), "missing atlas cannot pass export validation")
	check(not Sources.validate_bytes(-1, PackedByteArray()), "negative source index is rejected")
	check(not Sources.validate_bytes(7, PackedByteArray()), "unknown source index is rejected")
	var missing := Sources.collect_sources(func(_path: String) -> PackedByteArray: return PackedByteArray())
	check(not String(missing.error).is_empty(), "missing source is reported clearly")
	equal(missing.files.size(), 0, "missing first source never produces a partial export list")
	var last_path: String = Sources.SOURCES[6].path
	var partial := Sources.collect_sources(func(path: String) -> PackedByteArray:
		return PackedByteArray() if path == last_path else FileAccess.get_file_as_bytes(path)
	)
	check(not String(partial.error).is_empty(), "missing last source fails after validating preceding files")
	equal(partial.files.size(), 0, "late failure discards the complete pending export list")
	equal(partial.total_bytes, 0, "late failure cannot report a usable partial byte count")
	return finish("pixel-assets-export")
