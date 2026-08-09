class_name PlayerPreferences
extends RefCounted


const SCHEMA_VERSION: int = 1
const DEFAULT_PATH: String = "user://player_preferences_v1.json"
const MOVEMENT_WORLD_RELATIVE: String = "world_relative"
const MOVEMENT_AIM_RELATIVE: String = "aim_relative"
const POV_FULL: String = "full"
const POV_CONE: String = "cone"
const MIN_POV_ANGLE_DEGREES: int = 15
const MAX_POV_ANGLE_DEGREES: int = 360
const MIN_POV_RANGE: int = 160
const MAX_POV_RANGE: int = 4096
const DEFAULT_POV_ANGLE_DEGREES: int = 120
const DEFAULT_POV_RANGE: int = 720
const DEFAULT_KEYBOARD_BINDINGS: Dictionary[StringName, int] = {
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"move_up": KEY_W,
	&"move_down": KEY_S,
	&"sprint": KEY_ALT,
	&"jump": KEY_C,
	&"technique": KEY_V,
	&"primary": KEY_SPACE,
	&"active_1": KEY_E,
	&"reset_match": KEY_R,
	&"toggle_debug_overlay": KEY_F1,
	&"toggle_tick_rate": KEY_F6,
	&"toggle_movement_reference": KEY_F7,
	&"toggle_pov_mode": KEY_F8,
	&"adjust_pov_angle": KEY_F9,
	&"adjust_pov_range": KEY_F10,
}

var movement_reference: String = MOVEMENT_WORLD_RELATIVE
var pov_mode: String = POV_FULL
var pov_angle_degrees: int = DEFAULT_POV_ANGLE_DEGREES
var pov_range: int = DEFAULT_POV_RANGE
var keyboard_bindings: Dictionary[StringName, int] = {}
var last_error: String = ""


func _init() -> void:
	reset_to_defaults()


func reset_to_defaults() -> void:
	movement_reference = MOVEMENT_WORLD_RELATIVE
	pov_mode = POV_FULL
	pov_angle_degrees = DEFAULT_POV_ANGLE_DEGREES
	pov_range = DEFAULT_POV_RANGE
	keyboard_bindings = DEFAULT_KEYBOARD_BINDINGS.duplicate()
	last_error = ""


func apply_control_preset(preset_id: String) -> bool:
	if not is_valid_movement_reference(preset_id):
		last_error = "Unknown control preset: %s" % preset_id
		return false
	movement_reference = preset_id
	last_error = ""
	return true


func apply_dictionary(data: Dictionary) -> bool:
	if int(data.get("schema_version", -1)) != SCHEMA_VERSION:
		last_error = "Player preferences require schema_version %d" % SCHEMA_VERSION
		return false
	var requested_movement: String = str(data.get("movement_reference", ""))
	var requested_pov_mode: String = str(data.get("pov_mode", ""))
	if not is_valid_movement_reference(requested_movement):
		last_error = "Invalid movement_reference: %s" % requested_movement
		return false
	if not is_valid_pov_mode(requested_pov_mode):
		last_error = "Invalid pov_mode: %s" % requested_pov_mode
		return false
	if not _is_whole_number(data.get("pov_angle_degrees")):
		last_error = "pov_angle_degrees must be an integer"
		return false
	if not _is_whole_number(data.get("pov_range")):
		last_error = "pov_range must be an integer"
		return false
	var requested_angle: int = int(data["pov_angle_degrees"])
	var requested_range: int = int(data["pov_range"])
	if requested_angle < MIN_POV_ANGLE_DEGREES or requested_angle > MAX_POV_ANGLE_DEGREES:
		last_error = "pov_angle_degrees must be between %d and %d" % [MIN_POV_ANGLE_DEGREES, MAX_POV_ANGLE_DEGREES]
		return false
	if requested_range < MIN_POV_RANGE or requested_range > MAX_POV_RANGE:
		last_error = "pov_range must be between %d and %d" % [MIN_POV_RANGE, MAX_POV_RANGE]
		return false
	var requested_bindings: Dictionary[StringName, int] = DEFAULT_KEYBOARD_BINDINGS.duplicate()
	var binding_data: Variant = data.get("keyboard_bindings", {})
	if not binding_data is Dictionary:
		last_error = "keyboard_bindings must be an object"
		return false
	for raw_action: Variant in binding_data:
		var action := StringName(str(raw_action))
		if not DEFAULT_KEYBOARD_BINDINGS.has(action):
			last_error = "Unknown keyboard action: %s" % action
			return false
		if not _is_whole_number(binding_data[raw_action]):
			last_error = "Keyboard binding for %s must be an integer keycode" % action
			return false
		var keycode: int = int(binding_data[raw_action])
		if keycode < 0 or keycode > 0x7fffffff:
			last_error = "Keyboard binding for %s is outside the supported keycode range" % action
			return false
		requested_bindings[action] = keycode
	var binding_error: String = validate_keyboard_bindings(requested_bindings)
	if not binding_error.is_empty():
		last_error = binding_error
		return false
	movement_reference = requested_movement
	pov_mode = requested_pov_mode
	pov_angle_degrees = requested_angle
	pov_range = requested_range
	keyboard_bindings = requested_bindings
	last_error = ""
	return true


func to_dictionary() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"movement_reference": movement_reference,
		"pov_mode": pov_mode,
		"pov_angle_degrees": pov_angle_degrees,
		"pov_range": pov_range,
		"keyboard_bindings": keyboard_bindings,
	}


func load_from_file(path: String = DEFAULT_PATH) -> bool:
	reset_to_defaults()
	if not FileAccess.file_exists(path):
		return true
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_error = "Could not read player preferences: %s" % path
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		last_error = "Player preferences must contain one JSON object"
		return false
	return apply_dictionary(parsed)


func save_to_file(path: String = DEFAULT_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		last_error = "Could not write player preferences: %s" % path
		return false
	file.store_string(JSON.stringify(to_dictionary(), "\t") + "\n")
	file.flush()
	last_error = ""
	return true


func set_pov_mode(requested_mode: String) -> bool:
	if not is_valid_pov_mode(requested_mode):
		last_error = "Invalid pov_mode: %s" % requested_mode
		return false
	pov_mode = requested_mode
	last_error = ""
	return true


func set_pov_angle_degrees(requested_angle: int) -> void:
	pov_angle_degrees = clampi(requested_angle, MIN_POV_ANGLE_DEGREES, MAX_POV_ANGLE_DEGREES)


func set_pov_range(requested_range: int) -> void:
	pov_range = clampi(requested_range, MIN_POV_RANGE, MAX_POV_RANGE)


static func is_valid_movement_reference(requested_reference: String) -> bool:
	return requested_reference == MOVEMENT_WORLD_RELATIVE or requested_reference == MOVEMENT_AIM_RELATIVE


static func is_valid_pov_mode(requested_mode: String) -> bool:
	return requested_mode == POV_FULL or requested_mode == POV_CONE


static func validate_keyboard_bindings(requested_bindings: Dictionary) -> String:
	var used_keycodes: Dictionary[int, StringName] = {}
	for raw_action: Variant in requested_bindings:
		var action := StringName(str(raw_action))
		if not DEFAULT_KEYBOARD_BINDINGS.has(action):
			return "Unknown keyboard action: %s" % action
		var keycode: int = int(requested_bindings[raw_action])
		if keycode == 0:
			continue
		if used_keycodes.has(keycode):
			return "Keyboard actions %s and %s conflict on keycode %d" % [used_keycodes[keycode], action, keycode]
		used_keycodes[keycode] = action
	return ""


static func _is_whole_number(value: Variant) -> bool:
	if value is int:
		return true
	if value is float:
		return is_finite(value) and value == floorf(value)
	return false
