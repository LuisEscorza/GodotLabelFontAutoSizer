@tool
extends Label
class_name LabelAutoSizer

@export var _decrease_per_step: int = 1
@export var _max_steps: int = 1
@export var _print_debug_enabled: bool = false
@onready var _base_font_size: Variant = null
@onready var _overriden_font_size: Variant = get("theme_override_font_sizes/font_size")

func set_label_defaults() -> void:
	clip_text = true
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


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
	_check_line_count()


func _check_line_count() -> void:
	await get_tree().process_frame
	if get_line_count() > get_visible_line_count():
		_overriden_font_size = _base_font_size
		set("theme_override_font_sizes/font_size", _overriden_font_size)
		_shrink_size()
	elif get_line_count() == get_visible_line_count():
		if _overriden_font_size != null and _overriden_font_size < _base_font_size:
			_enlarge_size()



func _shrink_size() -> void:
	var _minimum_size: int = _base_font_size - (_decrease_per_step * _max_steps)
	var new_size: int
	while get_line_count() > get_visible_line_count():
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


func _enlarge_size() -> void:
	if _overriden_font_size == _base_font_size:
		return
	var new_size: int = _overriden_font_size + _decrease_per_step
	if new_size < _base_font_size:
		_overriden_font_size = new_size
		set("theme_override_font_sizes/font_size", new_size)
		_check_line_count()
	elif new_size == _base_font_size:
		remove_theme_font_size_override("font_size")
		if get_line_count() > get_visible_line_count():
			_shrink_size()


func _set(property: StringName, value: Variant) -> bool:
	match property:
		"text":
			text = value
			_check_line_count()
			return true
		_: return false


func set_text(new_text: String) -> void:
	text = new_text
	_check_line_count()
