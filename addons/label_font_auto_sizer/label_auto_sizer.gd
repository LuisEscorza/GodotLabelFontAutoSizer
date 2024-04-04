@tool
extends Label
class_name LabelAutoSizer

@export var _size_per_step: int = 1
@export var _max_steps: int = 1
@export var _print_debug_enabled: bool = false
@onready var _base_font_size: Variant = null
@onready var _overriden_font_size: Variant = get("theme_override_font_sizes/font_size")

var _last_size_state: LABEL_SIZE_STATE = LABEL_SIZE_STATE.IDLE
enum LABEL_SIZE_STATE {JUST_SHRUNK, IDLE, JUST_ENLARGED} 
var _current_font_size: int

func set_label_defaults() -> void:
	clip_text = true
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _ready() -> void:
	set_label_defaults()
	#if label_settings != null:
		#_base_font_size = label_settings.font_size
	if get("theme_override_font_sizes/font_size") != null:
		_base_font_size = get("theme_override_font_sizes/font_size")
	elif get_theme_font_size("font_size") != null:
		_base_font_size = get_theme_font_size("font_size")
	else:
		push_error("Base font size not found")
	
	_current_font_size = _base_font_size
	_print_debug_message(str(name) + " Base font size: " + str(_base_font_size) + "px.")
	call_deferred("_check_line_count")


func _check_line_count() -> void:
	_print_debug_message("Checking lines of " + str(name))
	if get_line_count() > get_visible_line_count() and _current_font_size > max(_base_font_size - (_size_per_step * _max_steps), 1):
		_shrink_font()
		return
	elif get_line_count() == get_visible_line_count() and _current_font_size < _base_font_size:
		_enlarge_font()
		return
	_last_size_state = LABEL_SIZE_STATE.IDLE


func _shrink_font():
	_print_debug_message(str(name) + "' shrink method called")
	_current_font_size = _current_font_size - _size_per_step
	set("theme_override_font_sizes/font_size", _current_font_size)
	_print_debug_message(str(name) + " shrunk " + str(_size_per_step) + "px.")
	if _last_size_state == LABEL_SIZE_STATE.JUST_ENLARGED:
		_last_size_state = LABEL_SIZE_STATE.IDLE
		_print_debug_message(str(name) + " finished shrinking. Was just enlarged.")
	else:
		_last_size_state = LABEL_SIZE_STATE.JUST_SHRUNK
		_check_line_count()


func _enlarge_font():
	_print_debug_message(str(name) + "' enlarge method called")
	_current_font_size = _current_font_size + _size_per_step
	set("theme_override_font_sizes/font_size", _current_font_size)
	if _last_size_state == LABEL_SIZE_STATE.JUST_SHRUNK:
		if  get_line_count() > get_visible_line_count():
			_last_size_state = LABEL_SIZE_STATE.JUST_ENLARGED
			_shrink_font()
		else:
			_print_debug_message(str(name) + " finished enlarging. Was just shrunk.")
			_last_size_state = LABEL_SIZE_STATE.IDLE
	else:
		_last_size_state = LABEL_SIZE_STATE.JUST_ENLARGED
		_check_line_count()


func _set(property: StringName, value: Variant) -> bool:
	match property:
		"text":
			text = value
			call_deferred("_check_line_count")
			return true
		_: return false


func _print_debug_message(message: String) -> void:
	if _print_debug_enabled:
		print(message)


func set_text(new_text: String) -> void:
	text = new_text
	call_deferred("_check_line_count")
