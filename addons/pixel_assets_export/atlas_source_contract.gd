@tool
extends RefCounted

# Source PNGs are immutable acceptance inputs, not replacements for Godot's
# imported textures. Deliberately allowlist only the seven live atlas files.
const SOURCES: Array[Dictionary] = [
	{"path": "res://art_batches/pixel_v1/magic/export/magic_00.png", "size": 30651, "sha256": "e59c854dc6e685ad5be478a3fc1536509844f74add25d0d0f137ed46cf43636a"},
	{"path": "res://art_batches/pixel_v1/magic/export/magic_01.png", "size": 41412, "sha256": "822e7a6c2f875fb3577e07d83c68fc283812d2a58101f14627cc7e3fb6efe3f6"},
	{"path": "res://art_batches/pixel_v1/magic/export/magic_02.png", "size": 16673, "sha256": "fc0e3844c226af1b4d6e2cd31a555f9e86b3a8d832aa76316730a13a84e5457b"},
	{"path": "res://art_batches/pixel_v1/map/export/terrain/atlas.png", "size": 3139, "sha256": "9ecd13274c76979357befde01af4322bbb515c03a75b806a713ec7d7ef48a6be"},
	{"path": "res://art_batches/pixel_v1/map/export/architecture/atlas.png", "size": 13000, "sha256": "a3ad3658a846940b1277c1ca7145801829d8fbb2eeee8f0999d027f0377c0686"},
	{"path": "res://art_batches/pixel_v1/map/export/props/atlas.png", "size": 9104, "sha256": "3bb037b3038e49c18936ff98b90fa60b568744838a68a599b05f8678fb7c1eaf"},
	{"path": "res://art_batches/pixel_v1/map/export/ambient/atlas.png", "size": 4870, "sha256": "7c8051cc8a48fec7cf75fedbdda93222c91160de2791cfe9d38b50a31f42fdec"},
]
const TOTAL_BYTES: int = 118849


static func validate_bytes(index: int, bytes: PackedByteArray) -> bool:
	if index < 0 or index >= SOURCES.size():
		return false
	var source: Dictionary = SOURCES[index]
	if bytes.size() != int(source.size):
		return false
	var digest := HashingContext.new()
	if digest.start(HashingContext.HASH_SHA256) != OK:
		return false
	if digest.update(bytes) != OK:
		return false
	return digest.finish().hex_encode() == String(source.sha256)


static func collect_sources(reader: Callable = Callable()) -> Dictionary:
	var files: Array[Dictionary] = []
	var total_bytes := 0
	for index: int in range(SOURCES.size()):
		var path: String = SOURCES[index].path
		var bytes: PackedByteArray
		if reader.is_valid():
			bytes = reader.call(path)
		elif FileAccess.file_exists(path):
			bytes = FileAccess.get_file_as_bytes(path)
		if not validate_bytes(index, bytes):
			return {"error": "Missing or modified original atlas: " + path, "files": [], "total_bytes": 0}
		files.append({"path": path, "bytes": bytes})
		total_bytes += bytes.size()
	return {"error": "", "files": files, "total_bytes": total_bytes}
