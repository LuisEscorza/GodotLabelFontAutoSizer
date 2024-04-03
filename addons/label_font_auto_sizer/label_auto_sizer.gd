@tool
extends Label
class_name LabelAutoSizer

@export var _max_line_amount: int = -1
@export var _decrease_per_step: int = 1
@export var _max_steps: int = 1
@export var _print_debug_enabled: bool = false
@onready var _base_font_size: Variant = null
@onready var _overriden_font_size: Variant = get("theme_override_font_sizes/font_size")


func set_label_defaults() -> void:
	clip_text = true
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	max_lines_visible = _max_line_amount


func _ready() -> void:
	set_label_defaults()
	if label_settings != null:
		_base_font_size = label_settings.font_size
	elif get("theme_override_font_sizes/font_size") != null:
		_base_font_size = get("theme_override_font_sizes/font_size")
	elif get_theme_font_size("font_size") != null:
		_base_font_size = get_theme_font_size("font_size")
	else:
		push_error("Base font size not found")
		
	if _print_debug_enabled:
		print(str(name) + " Base font size: " + str(_base_font_size) + "px.")
	check_size()


func check_size() -> void:
	if _max_line_amount == -1:
		return
	await get_tree().process_frame
	if get_line_count() > _max_line_amount:
		_overriden_font_size = _base_font_size
		set("theme_override_font_sizes/font_size", _overriden_font_size)
		_resize()
	else:
		if _print_debug_enabled:
			print(str(name) + " Didn't need resizing.")


func _resize() -> void:
	var _minimum_size: int = _base_font_size - (_decrease_per_step * _max_steps)
	var new_size: int
	while get_line_count() > _max_line_amount:
		new_size = _overriden_font_size - _decrease_per_step
		if new_size >= _minimum_size:
			_overriden_font_size = new_size
			set("theme_override_font_sizes/font_size", new_size)
			if _print_debug_enabled:
				print(str(name) + " Shrunk " + str(_decrease_per_step) + "px.")
		else:
			if _print_debug_enabled:
				print(str(name) + " Minimum size reached.")
			break
	if _print_debug_enabled:
		print(str(name) + " Finished resizing.")
		print(str(name) + " Override size: " + str(_overriden_font_size) + "px.")


func set_label_text(new_text: String) -> void:
	text = new_text
	check_size()
