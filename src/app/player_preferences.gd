class_name PlayerPreferences
extends RefCounted


const SCHEMA_VERSION: int = 10
const DEFAULT_PATH: String = "user://player_preferences_v1.json"
const DEFAULT_FARFLOW_JOIN_ADDRESS: String = "127.0.0.1"
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
const MIN_CAMERA_ZOOM_PERCENT: int = 50
const MAX_CAMERA_ZOOM_PERCENT: int = 100
const DEFAULT_CAMERA_ZOOM_PERCENT: int = 75
const LEGACY_DEFAULT_KEYBOARD_BINDINGS: Dictionary[StringName, int] = {
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
const SCHEMA_V2_DEFAULT_KEYBOARD_BINDINGS: Dictionary[StringName, int] = {
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"move_up": KEY_W,
	&"move_down": KEY_S,
	&"sprint": KEY_ALT,
	&"jump": KEY_SPACE,
	&"technique": KEY_V,
	&"primary": 0,
	&"active_1": KEY_E,
	&"reset_match": KEY_R,
	&"toggle_debug_overlay": KEY_F1,
	&"toggle_tick_rate": KEY_F6,
	&"toggle_movement_reference": KEY_F7,
	&"toggle_pov_mode": KEY_F8,
	&"adjust_pov_angle": KEY_F9,
	&"adjust_pov_range": KEY_F10,
}
const SCHEMA_V3_DEFAULT_KEYBOARD_BINDINGS: Dictionary[StringName, int] = {
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"move_up": KEY_W,
	&"move_down": KEY_S,
	&"sprint": KEY_SHIFT,
	&"slide": KEY_CTRL,
	&"jump": KEY_SPACE,
	&"technique": KEY_V,
	&"primary": 0,
	&"active_1": KEY_E,
	&"reset_match": KEY_R,
	&"toggle_debug_overlay": KEY_F1,
	&"toggle_tick_rate": KEY_F6,
	&"toggle_movement_reference": KEY_F7,
	&"toggle_pov_mode": KEY_F8,
	&"adjust_pov_angle": KEY_F9,
	&"adjust_pov_range": KEY_F10,
}
const DEFAULT_KEYBOARD_BINDINGS: Dictionary[StringName, int] = {
	&"practice_trace": KEY_F2,
	&"practice_retry": KEY_F3,
	&"evade": KEY_Q,
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"move_up": KEY_W,
	&"move_down": KEY_S,
	&"sprint": KEY_SHIFT,
	&"slide": KEY_C,
	&"jump": KEY_SPACE,
	&"technique": KEY_V,
	&"primary": 0,
	&"active_1": KEY_E,
	&"interact": KEY_F,
	&"emote": KEY_T,
	&"spell_1": KEY_1,
	&"spell_2": KEY_2,
	&"spell_3": KEY_3,
	&"spell_4": KEY_4,
	&"spell_layer_ctrl": KEY_CTRL,
	&"spell_layer_alt": KEY_ALT,
	&"reset_match": KEY_R,
	&"toggle_debug_overlay": KEY_F1,
	&"toggle_movement_reference": KEY_F7,
	&"toggle_pov_mode": KEY_F8,
	&"adjust_pov_angle": KEY_F9,
	&"adjust_pov_range": KEY_F10,
	&"adjust_camera_zoom": KEY_F11,
}
const SCHEMA_V4_DEFAULT_MOUSE_BINDINGS: Dictionary[StringName, int] = {
	&"primary": MOUSE_BUTTON_LEFT,
	&"active_1": MOUSE_BUTTON_RIGHT,
	&"jump": MOUSE_BUTTON_WHEEL_UP,
	&"slide": MOUSE_BUTTON_WHEEL_DOWN,
}
const DEFAULT_MOUSE_BINDINGS: Dictionary[StringName, int] = {
	&"practice_trace": 0,
	&"practice_retry": 0,
	&"evade": 0,
	&"move_left": 0,
	&"move_right": 0,
	&"move_up": 0,
	&"move_down": 0,
	&"sprint": 0,
	&"slide": MOUSE_BUTTON_WHEEL_DOWN,
	&"jump": MOUSE_BUTTON_WHEEL_UP,
	&"technique": 0,
	&"primary": MOUSE_BUTTON_LEFT,
	&"active_1": MOUSE_BUTTON_RIGHT,
	&"interact": 0,
	&"emote": 0,
	&"spell_1": 0,
	&"spell_2": 0,
	&"spell_3": 0,
	&"spell_4": 0,
	&"spell_layer_ctrl": 0,
	&"spell_layer_alt": 0,
}
const DEFAULT_CONTROLLER_BINDINGS: Dictionary = {
	&"practice_trace": {"kind": "none", "index": -1, "direction": 0},
	&"practice_retry": {"kind": "none", "index": -1, "direction": 0},
	&"evade": {"kind": "axis", "index": JOY_AXIS_TRIGGER_LEFT, "direction": 1},
	&"move_left": {"kind": "axis", "index": JOY_AXIS_LEFT_X, "direction": -1},
	&"move_right": {"kind": "axis", "index": JOY_AXIS_LEFT_X, "direction": 1},
	&"move_up": {"kind": "axis", "index": JOY_AXIS_LEFT_Y, "direction": -1},
	&"move_down": {"kind": "axis", "index": JOY_AXIS_LEFT_Y, "direction": 1},
	&"sprint": {"kind": "button", "index": JOY_BUTTON_LEFT_SHOULDER, "direction": 0},
	&"slide": {"kind": "button", "index": JOY_BUTTON_A, "direction": 0},
	&"jump": {"kind": "button", "index": JOY_BUTTON_RIGHT_SHOULDER, "direction": 0},
	&"technique": {"kind": "button", "index": JOY_BUTTON_B, "direction": 0},
	&"primary": {"kind": "axis", "index": JOY_AXIS_TRIGGER_RIGHT, "direction": 1},
	&"active_1": {"kind": "button", "index": JOY_BUTTON_X, "direction": 0},
	&"interact": {"kind": "button", "index": JOY_BUTTON_Y, "direction": 0},
	&"emote": {"kind": "button", "index": JOY_BUTTON_DPAD_UP, "direction": 0},
	&"spell_1": {"kind": "none", "index": -1, "direction": 0},
	&"spell_2": {"kind": "none", "index": -1, "direction": 0},
	&"spell_3": {"kind": "none", "index": -1, "direction": 0},
	&"spell_4": {"kind": "none", "index": -1, "direction": 0},
	&"spell_layer_ctrl": {"kind": "none", "index": -1, "direction": 0},
	&"spell_layer_alt": {"kind": "none", "index": -1, "direction": 0},
}

var movement_reference: String = MOVEMENT_WORLD_RELATIVE
var pov_mode: String = POV_FULL
var pov_angle_degrees: int = DEFAULT_POV_ANGLE_DEGREES
var pov_range: int = DEFAULT_POV_RANGE
var camera_zoom_percent: int = DEFAULT_CAMERA_ZOOM_PERCENT
var keyboard_bindings: Dictionary[StringName, int] = {}
var mouse_bindings: Dictionary[StringName, int] = {}
var controller_bindings: Dictionary = {}
var reduced_motion: bool = false
var high_contrast: bool = false
var farflow_join_address: String = DEFAULT_FARFLOW_JOIN_ADDRESS
var last_error: String = ""


func _init() -> void:
	reset_to_defaults()


func reset_to_defaults() -> void:
	movement_reference = MOVEMENT_WORLD_RELATIVE
	pov_mode = POV_FULL
	pov_angle_degrees = DEFAULT_POV_ANGLE_DEGREES
	pov_range = DEFAULT_POV_RANGE
	camera_zoom_percent = DEFAULT_CAMERA_ZOOM_PERCENT
	keyboard_bindings = DEFAULT_KEYBOARD_BINDINGS.duplicate()
	mouse_bindings = DEFAULT_MOUSE_BINDINGS.duplicate()
	controller_bindings = DEFAULT_CONTROLLER_BINDINGS.duplicate(true)
	reduced_motion = false
	high_contrast = false
	farflow_join_address = DEFAULT_FARFLOW_JOIN_ADDRESS
	last_error = ""


func apply_control_preset(preset_id: String) -> bool:
	if not is_valid_movement_reference(preset_id):
		last_error = "Unknown control preset: %s" % preset_id
		return false
	movement_reference = preset_id
	last_error = ""
	return true


func apply_dictionary(data: Dictionary) -> bool:
	var raw_schema: Variant = data.get("schema_version", -1)
	if not _is_whole_number(raw_schema):
		last_error = "Player preferences require schema_version 1 through 10"
		return false
	var requested_schema: int = int(raw_schema)
	if requested_schema < 1 or requested_schema > SCHEMA_VERSION:
		last_error = "Player preferences require schema_version 1 through 10"
		return false
	var requested_movement: String = str(data.get("movement_reference", ""))
	var requested_pov_mode: String = str(data.get("pov_mode", ""))
	var requested_reduced_motion: bool = false
	if requested_schema >= 2:
		var raw_reduced_motion: Variant = data.get("reduced_motion", false)
		if not raw_reduced_motion is bool:
			last_error = "reduced_motion must be a boolean"
			return false
		requested_reduced_motion = raw_reduced_motion
	var requested_high_contrast: bool = false
	if requested_schema >= 8:
		var raw_high_contrast: Variant = data.get("high_contrast", false)
		if not raw_high_contrast is bool:
			last_error = "high_contrast must be a boolean"
			return false
		requested_high_contrast = raw_high_contrast
	var requested_farflow_join_address: String = DEFAULT_FARFLOW_JOIN_ADDRESS
	if requested_schema >= 9:
		var raw_farflow_join_address: Variant = data.get("farflow_join_address", "")
		if not raw_farflow_join_address is String or not is_valid_farflow_join_address(raw_farflow_join_address):
			last_error = "farflow_join_address must be a valid host or IP address"
			return false
		requested_farflow_join_address = String(raw_farflow_join_address)
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
	var requested_camera_zoom: int = DEFAULT_CAMERA_ZOOM_PERCENT
	if requested_schema >= 7:
		if not _is_whole_number(data.get("camera_zoom_percent")):
			last_error = "camera_zoom_percent must be an integer"
			return false
		requested_camera_zoom = int(data["camera_zoom_percent"])
	if requested_angle < MIN_POV_ANGLE_DEGREES or requested_angle > MAX_POV_ANGLE_DEGREES:
		last_error = "pov_angle_degrees must be between %d and %d" % [MIN_POV_ANGLE_DEGREES, MAX_POV_ANGLE_DEGREES]
		return false
	if requested_range < MIN_POV_RANGE or requested_range > MAX_POV_RANGE:
		last_error = "pov_range must be between %d and %d" % [MIN_POV_RANGE, MAX_POV_RANGE]
		return false
	if requested_camera_zoom < MIN_CAMERA_ZOOM_PERCENT or requested_camera_zoom > MAX_CAMERA_ZOOM_PERCENT:
		last_error = "camera_zoom_percent must be between %d and %d" % [MIN_CAMERA_ZOOM_PERCENT, MAX_CAMERA_ZOOM_PERCENT]
		return false
	var requested_bindings: Dictionary[StringName, int]
	if requested_schema == 1:
		requested_bindings = LEGACY_DEFAULT_KEYBOARD_BINDINGS.duplicate()
	elif requested_schema == 2:
		requested_bindings = SCHEMA_V2_DEFAULT_KEYBOARD_BINDINGS.duplicate()
	elif requested_schema == 3:
		requested_bindings = SCHEMA_V3_DEFAULT_KEYBOARD_BINDINGS.duplicate()
	else:
		requested_bindings = DEFAULT_KEYBOARD_BINDINGS.duplicate()
	var binding_data: Variant = data.get("keyboard_bindings", {})
	if not binding_data is Dictionary:
		last_error = "keyboard_bindings must be an object"
		return false
	for raw_action: Variant in binding_data:
		var action := StringName(str(raw_action))
		if action == &"toggle_tick_rate":
			# Schema 1-9 saves may retain the retired F6 cadence toggle. The
			# canonical 120 Hz runtime ignores it during lossless migration.
			continue
		if requested_schema <= 6 and action == &"spell_5":
			continue
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
	for action: StringName in DEFAULT_KEYBOARD_BINDINGS:
		if not requested_bindings.has(action):
			requested_bindings[action] = DEFAULT_KEYBOARD_BINDINGS[action]
	requested_bindings.erase(&"toggle_tick_rate")
	if requested_schema == 1:
		if requested_bindings[&"jump"] == LEGACY_DEFAULT_KEYBOARD_BINDINGS[&"jump"]:
			requested_bindings[&"jump"] = DEFAULT_KEYBOARD_BINDINGS[&"jump"]
		if requested_bindings[&"primary"] == LEGACY_DEFAULT_KEYBOARD_BINDINGS[&"primary"]:
			requested_bindings[&"primary"] = DEFAULT_KEYBOARD_BINDINGS[&"primary"]
	if requested_schema <= 2:
		if requested_bindings[&"sprint"] == KEY_ALT:
			requested_bindings[&"sprint"] = DEFAULT_KEYBOARD_BINDINGS[&"sprint"]
		requested_bindings[&"slide"] = DEFAULT_KEYBOARD_BINDINGS[&"slide"]
	elif requested_schema == 3 and requested_bindings[&"slide"] == SCHEMA_V3_DEFAULT_KEYBOARD_BINDINGS[&"slide"]:
		requested_bindings[&"slide"] = DEFAULT_KEYBOARD_BINDINGS[&"slide"]
	if requested_schema <= 6:
		_preserve_legacy_modifier_binding(requested_bindings, &"spell_layer_ctrl", KEY_CTRL)
		_preserve_legacy_modifier_binding(requested_bindings, &"spell_layer_alt", KEY_ALT)
	if requested_schema < 10:
		# Never steal a player's existing custom key when adding a new intent.
		for added_action: StringName in [&"evade", &"practice_trace", &"practice_retry"]:
			for action: StringName in requested_bindings:
				if action != added_action and requested_bindings[action] == requested_bindings[added_action]:
					requested_bindings[added_action] = 0
	var binding_error: String = validate_keyboard_bindings(requested_bindings)
	if not binding_error.is_empty():
		last_error = binding_error
		return false
	var requested_mouse_bindings: Dictionary[StringName, int] = DEFAULT_MOUSE_BINDINGS.duplicate()
	var mouse_binding_data: Variant = data.get("mouse_bindings", {})
	if not mouse_binding_data is Dictionary:
		last_error = "mouse_bindings must be an object"
		return false
	for raw_action: Variant in mouse_binding_data:
		var action := StringName(str(raw_action))
		if requested_schema <= 6 and action == &"spell_5":
			continue
		if not DEFAULT_MOUSE_BINDINGS.has(action):
			last_error = "Unknown mouse action: %s" % action
			return false
		if not _is_whole_number(mouse_binding_data[raw_action]):
			last_error = "Mouse binding for %s must be an integer button" % action
			return false
		requested_mouse_bindings[action] = int(mouse_binding_data[raw_action])
	var mouse_binding_error: String = validate_mouse_bindings(requested_mouse_bindings)
	if not mouse_binding_error.is_empty():
		last_error = mouse_binding_error
		return false
	var requested_controller_bindings: Dictionary = DEFAULT_CONTROLLER_BINDINGS.duplicate(true)
	var controller_binding_data: Variant = data.get("controller_bindings", {})
	if not controller_binding_data is Dictionary:
		last_error = "controller_bindings must be an object"
		return false
	for raw_action: Variant in controller_binding_data:
		var action := StringName(str(raw_action))
		if requested_schema <= 6 and action == &"spell_5":
			continue
		if not DEFAULT_CONTROLLER_BINDINGS.has(action):
			last_error = "Unknown controller action: %s" % action
			return false
		if not controller_binding_data[raw_action] is Dictionary:
			last_error = "Controller binding for %s must be an object" % action
			return false
		var raw_descriptor: Dictionary = controller_binding_data[raw_action]
		if not _is_whole_number(raw_descriptor.get("index", -1)) or not _is_whole_number(raw_descriptor.get("direction", 0)):
			last_error = "Controller binding for %s requires integer index and direction" % action
			return false
		requested_controller_bindings[action] = {
			"kind": String(raw_descriptor.get("kind", "")),
			"index": int(raw_descriptor.get("index", -1)),
			"direction": int(raw_descriptor.get("direction", 0)),
		}
	if requested_schema < 10:
		for action: StringName in requested_controller_bindings:
			if action != &"evade" and requested_controller_bindings[action] == requested_controller_bindings[&"evade"]:
				requested_controller_bindings[&"evade"] = {"kind": "none", "index": -1, "direction": 0}
	var controller_binding_error: String = validate_controller_bindings(requested_controller_bindings)
	if not controller_binding_error.is_empty():
		last_error = controller_binding_error
		return false
	movement_reference = requested_movement
	pov_mode = requested_pov_mode
	pov_angle_degrees = requested_angle
	pov_range = requested_range
	camera_zoom_percent = requested_camera_zoom
	keyboard_bindings = requested_bindings
	mouse_bindings = requested_mouse_bindings
	controller_bindings = requested_controller_bindings
	reduced_motion = requested_reduced_motion
	high_contrast = requested_high_contrast
	farflow_join_address = requested_farflow_join_address
	last_error = ""
	return true


func to_dictionary() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"movement_reference": movement_reference,
		"pov_mode": pov_mode,
		"pov_angle_degrees": pov_angle_degrees,
		"pov_range": pov_range,
		"camera_zoom_percent": camera_zoom_percent,
		"keyboard_bindings": keyboard_bindings,
		"mouse_bindings": mouse_bindings,
		"controller_bindings": controller_bindings,
		"reduced_motion": reduced_motion,
		"high_contrast": high_contrast,
		"farflow_join_address": farflow_join_address,
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


func set_camera_zoom_percent(requested_zoom_percent: int) -> void:
	camera_zoom_percent = clampi(requested_zoom_percent, MIN_CAMERA_ZOOM_PERCENT, MAX_CAMERA_ZOOM_PERCENT)


static func is_valid_movement_reference(requested_reference: String) -> bool:
	return requested_reference == MOVEMENT_WORLD_RELATIVE or requested_reference == MOVEMENT_AIM_RELATIVE


static func is_valid_pov_mode(requested_mode: String) -> bool:
	return requested_mode == POV_FULL or requested_mode == POV_CONE


static func is_valid_farflow_join_address(address: String) -> bool:
	var safe_address := address.strip_edges()
	if safe_address.is_empty() or safe_address.length() > 255 or safe_address != address:
		return false
	for character: String in safe_address:
		if character.unicode_at(0) <= 32 or character in "/\\":
			return false
	return true


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


static func validate_mouse_bindings(requested_bindings: Dictionary) -> String:
	var used_buttons: Dictionary[int, StringName] = {}
	for raw_action: Variant in requested_bindings:
		var action := StringName(str(raw_action))
		if not DEFAULT_MOUSE_BINDINGS.has(action):
			return "Unknown mouse action: %s" % action
		var button: int = int(requested_bindings[raw_action])
		if button < 0 or button > MOUSE_BUTTON_XBUTTON2:
			return "Mouse binding for %s is outside the supported button range" % action
		if button == 0:
			continue
		if used_buttons.has(button):
			return "Mouse actions %s and %s conflict on button %d" % [used_buttons[button], action, button]
		used_buttons[button] = action
	return ""


static func validate_controller_bindings(requested_bindings: Dictionary) -> String:
	var used_inputs: Dictionary[String, StringName] = {}
	for raw_action: Variant in requested_bindings:
		var action := StringName(str(raw_action))
		if not DEFAULT_CONTROLLER_BINDINGS.has(action):
			return "Unknown controller action: %s" % action
		var descriptor_value: Variant = requested_bindings[raw_action]
		if not descriptor_value is Dictionary:
			return "Controller binding for %s must be an object" % action
		var descriptor: Dictionary = descriptor_value
		var kind := String(descriptor.get("kind", ""))
		var index: int = int(descriptor.get("index", -1))
		var direction: int = int(descriptor.get("direction", 0))
		if kind == "none":
			if index != -1 or direction != 0:
				return "Unbound controller action %s has invalid fields" % action
			continue
		if kind == "button":
			if index < 0 or index > 31 or direction != 0:
				return "Controller button for %s is outside the supported range" % action
		elif kind == "axis":
			if index < 0 or index > 15 or direction not in [-1, 1]:
				return "Controller axis for %s is outside the supported range" % action
		else:
			return "Controller binding for %s has an unknown kind" % action
		var signature := "%s:%d:%d" % [kind, index, direction]
		if used_inputs.has(signature):
			return "Controller actions %s and %s conflict on %s" % [used_inputs[signature], action, signature]
		used_inputs[signature] = action
	return ""


static func unbound_controller_binding() -> Dictionary:
	return {"kind": "none", "index": -1, "direction": 0}


static func _preserve_legacy_modifier_binding(bindings: Dictionary, modifier_action: StringName, keycode: int) -> void:
	for raw_action: Variant in bindings:
		var action := StringName(str(raw_action))
		if action != modifier_action and int(bindings[raw_action]) == keycode:
			bindings[modifier_action] = 0
			return


static func _is_whole_number(value: Variant) -> bool:
	if value is int:
		return true
	if value is float:
		return is_finite(value) and value == floorf(value)
	return false
