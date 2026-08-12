class_name SimConfig
extends RefCounted


const PROTOCOL_VERSION: int = 21
const FIXED_SCALE: int = 1000
const MIN_TICK_RATE: int = 60
const MAX_TICK_RATE: int = 120

var tick_rate: int


func _init(requested_tick_rate: int = 60) -> void:
	tick_rate = requested_tick_rate if is_supported_tick_rate(requested_tick_rate) else 0


static func is_supported_tick_rate(value: int) -> bool:
	return value == MIN_TICK_RATE or value == MAX_TICK_RATE


func is_valid() -> bool:
	return is_supported_tick_rate(tick_rate)


func milliseconds_to_ticks(milliseconds: int) -> int:
	if not is_valid() or milliseconds <= 0:
		return 0
	@warning_ignore("integer_division")
	return maxi(1, (milliseconds * tick_rate + 999) / 1000)


func per_tick(value_per_second: int) -> int:
	if not is_valid():
		return 0
	@warning_ignore("integer_division")
	return value_per_second / tick_rate
