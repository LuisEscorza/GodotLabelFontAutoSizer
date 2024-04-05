@tool
extends Label
class_name LabelAutoSizer

@export_range(1,100) var _max_steps: int = 1:
	set(value):
		_max_steps = value
		call_deferred("_check_line_count")
@export_range(1,100) var _size_per_step: int = 2:
	set(value):
		_size_per_step = value
		call_deferred("_check_line_count")
@export var _print_debug_enabled: bool = true
var _base_font_size: int
var _last_size_state: LABEL_SIZE_STATE = LABEL_SIZE_STATE.IDLE
var _current_font_size: int
var _size_just_modified_by_autosizer: bool = false
var _label_settings_just_duplicated: bool = false

enum LABEL_SIZE_STATE {JUST_SHRUNK, IDLE, JUST_ENLARGED} 


func _set_base_font_size() -> void:
	if label_settings != null:
		_base_font_size = label_settings.font_size
	elif get("theme_override_font_sizes/font_size") != null:
		_base_font_size = get("theme_override_font_sizes/font_size")
	elif get_theme_font_size("font_size") != null:
		_base_font_size = get_theme_font_size("font_size")
	_print_debug_message(str(name) + " Base font size: " + str(_base_font_size) + "px.")


func _ready() -> void:
	if Engine.is_editor_hint():
		_connect_signals()
	LabelFontAutoSizeManager.register_label(self)
	_print_debug_message(str(name) + " Base font size: " + str(_base_font_size) + "px.")
	call_deferred("_check_line_count")


func _on_label_settings_changed() -> void:
	_print_debug_message(str(name) + "' Label Settings changed.")
	if _size_just_modified_by_autosizer:
		_size_just_modified_by_autosizer = false
	else:
		call_deferred("_set_base_font_size")


func _on_theme_changed() -> void:
	_print_debug_message(str(name) + "' Theme changed.")
	if _size_just_modified_by_autosizer:
		_size_just_modified_by_autosizer = false ## Early return because the change wasn't made by the user.
	else:
		if label_settings != null: ## Early return because label settings have priority over themes.
			_print_debug_message(str(name) + " Base font size: " + str(_base_font_size) + "px.")
			return
		call_deferred("_set_base_font_size")


func _on_font_resouce_changed() -> void:
	if _size_just_modified_by_autosizer:
		_size_just_modified_by_autosizer = false
	else:
		call_deferred("_set_base_font_size")


func _on_label_rect_resized() -> void:
	call_deferred("_check_line_count")


func _on_locale_changed() -> void:
	call_deferred("_check_line_count")

func _exit_tree() -> void:
	LabelFontAutoSizeManager.erase_label(self)


func _get_property_list():
	var properties = []
	var bool_properties = ["_size_just_modified_by_autosizer"]
	for name in bool_properties:
		properties.append({
			"name": name,
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_STORAGE,
		})
	var int_properties = ["_base_font_size", "_current_font_size", "_last_size_state"]
	for name in int_properties:
		properties.append({
			"name": name,
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_STORAGE,
		})
	return properties


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
	_override_font_size(_current_font_size - _size_per_step)
	_print_debug_message(str(name) + " shrunk " + str(_size_per_step) + "px.")
	if _last_size_state == LABEL_SIZE_STATE.JUST_ENLARGED:
		_last_size_state = LABEL_SIZE_STATE.IDLE
		_print_debug_message(str(name) + " finished shrinking. Was just enlarged.")
	else:
		_last_size_state = LABEL_SIZE_STATE.JUST_SHRUNK
		_check_line_count()


func _enlarge_font():
	_print_debug_message(str(name) + "' enlarge method called")
	_override_font_size(_current_font_size + _size_per_step)
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
		"label_settings":
			if _label_settings_just_duplicated: ## Need to check because this gets called whenever we duplicate the resource as well.
				_label_settings_just_duplicated = false
				return true
			else: 
				if value != null:
					label_settings = value
					_label_settings_just_duplicated = true
					label_settings = label_settings.duplicate() ## These are not unique by default, so we it gets duplicated to not override every instance.
					if !label_settings.changed.is_connected(_on_label_settings_changed):
						label_settings.changed.connect(_on_label_settings_changed)
				else:
					label_settings = null
				call_deferred("_set_base_font_size")
			return true
		_:
			return false


func _override_font_size(new_size: int) -> void:
	_size_just_modified_by_autosizer = true
	if label_settings != null:
		label_settings.font_size = new_size
	else:
		set("theme_override_font_sizes/font_size", new_size)
	_current_font_size = new_size


func _connect_signals() -> void:
	if label_settings != null:
		if !label_settings.changed.is_connected(_on_label_settings_changed):
			label_settings.changed.connect(_on_label_settings_changed)
	if !theme_changed.is_connected(_on_theme_changed):
		theme_changed.connect(_on_theme_changed)
	if !resized.is_connected(_on_label_rect_resized):
		resized.connect(_on_label_rect_resized)


func _print_debug_message(message: String) -> void:
	if _print_debug_enabled:
		print(message)


func set_editor_defaults() -> void:
	clip_text = true
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if label_settings != null:
		label_settings = label_settings.duplicate() ## These are not unique by default, so we it gets duplicated to not override every instance.
		label_settings.changed.connect(_on_label_settings_changed)
	_set_base_font_size()
	call_deferred("_set_base_font_size")
	set_deferred("_current_font_size", _base_font_size)
	call_deferred("_connect_signals")



func set_text(new_text: String) -> void:
	text = new_text
	call_deferred("_check_line_count")

