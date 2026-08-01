class_name CanonicalBytes
extends RefCounted


static func append_i64(output: PackedByteArray, value: int) -> void:
	for byte_index: int in range(8):
		output.append((value >> (byte_index * 8)) & 0xff)


static func append_string(output: PackedByteArray, value: String) -> void:
	var encoded: PackedByteArray = value.to_utf8_buffer()
	append_i64(output, encoded.size())
	output.append_array(encoded)


static func sha256_hex(payload: PackedByteArray) -> String:
	var context := HashingContext.new()
	var error: Error = context.start(HashingContext.HASH_SHA256)
	if error != OK:
		return ""
	error = context.update(payload)
	if error != OK:
		return ""
	return context.finish().hex_encode()
