tool
extends RichTextLabel
class_name RichLabelAutoSizer, "res://addons/label_font_auto_sizer/label_font_auto_sizer.svg"

#region External variables
## The number of times the auto sizer will shrink the font to try to fit the text into the control rect.
export(int, 1, 100) var _max_steps = 4 setget _set_max_steps
func _set_max_steps(value):
	_max_steps = value
	call_deferred("_check_line_count")
## The size value in pixels that the auto sizer will shrink the font during each step.
export(int, 1, 200) var _size_per_step = 2 setget _set_size_per_steps
func _set_size_per_steps(value):
	_max_steps = value
	call_deferred("_check_line_count")

## Set this to true if you want to debug the steps happening in the class. The calls are commented so you need to decomment them.
export(bool) var _print_debug_enabled = false
#endregion

#region --Internal variables--
var _base_font_size: int
var _current_font_size: int
var _last_size_state = LABEL_SIZE_STATE.IDLE
var _size_just_modified_by_autosizer: bool = false
var _label_settings_just_duplicated: bool = false
var _set_defaults: bool = false
var _autosize_manager

enum LABEL_SIZE_STATE {JUST_SHRUNK, IDLE, JUST_ENLARGED} 
#endregion


#region --Signal funcs--
## Gets called in-editor and in-game. Sets some default values if necessary.
func _ready() -> void:
	if !_set_defaults:
		set_editor_defaults()
#	else:
#		_print_debug_message(str(name) + " Base font size: " + str(_base_font_size) + "px.")
	if Engine.is_editor_hint():
		call_deferred("_connect_signals")
	_autosize_manager = get_node("/root/LabelFontAutoSizeManager")
	_autosize_manager.register_label(self)


## Gets called when there are changes in either the Theme or Label Settings resources.
## Checks if the change was made by the script of by the user and if not, sets the base font size value.
func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		#_print_debug_message(str(name) + "' Font resource changed.")
		if _size_just_modified_by_autosizer:
			_size_just_modified_by_autosizer = false ## Early return because the change wasn't made by the user.
		else:
			call_deferred("_set_base_font_size")


## Gets called whenever the size of the control rect is modified (in editor). Calls the line count check.
func _on_label_rect_resized() -> void:
	if !_set_defaults:
		return
	call_deferred("_check_line_count")


## Called by autosize manager whenever the locale_chaged() method is called, as the tr() object changes don't trigger
## the set_text() method of the label, thus the size and line_amount doesn't get checked.
func _on_locale_changed() -> void:
	call_deferred("_check_line_count")


## Gets called on scene changes and when the label is freed and erases itself from the autosize manager.
func _exit_tree() -> void:
	_autosize_manager.erase_label(self)
#endregion

#region --Private funcs--
##Only in-editor, keeps stuff in check while manually changing font resources and resizing the label.
func _connect_signals() -> void:
	if !is_connected("resized", self, "_on_label_rect_resized"):
		connect("resized", self,"_on_label_rect_resized")


## Text can be changed via either: set_text(value), or _my_label.text = value. Both will trigger a line check.
func _set(property: String, value) -> bool:
	match property:
		"text":
			text = value
			call_deferred("_check_line_count")
			return true
		_:
			return false


## Goes through the resources in the label and sets the base font size value.
## Priority: Override Theme Font Size > Theme Font Size. (RichTextLabels don't allow Label Settings)
func _set_base_font_size() -> void:
	if has_font_override("font"):
		_base_font_size = get("custom_fonts/normal_font").size
	else:
		var font = self.get_font("normal_font", "RichTextLabel")
		_base_font_size = font.size
	_current_font_size = _base_font_size
	#_print_debug_message(str(name) + " Base font size: " + str(_base_font_size) + "px.")


## Makes variables persistent without exposing them in the editor.
## Will get removed in Godot 4.3 with the upcoming @export_storage annotation.
func _get_property_list():
	var properties: Array = []
	var bool_properties: Array = ["_size_just_modified_by_autosizer","_set_defaults"]
	for name in bool_properties:
		properties.append({
			"name": name,
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_STORAGE,
		})
	var int_properties: Array = ["_base_font_size", "_current_font_size", "_last_size_state"]
	for name in int_properties:
		properties.append({
			"name": name,
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_STORAGE,
		})
	return properties


## Checks the current font size and amount of lines in the text against the visible lines inside the rect.
## Calls for the shrink or enlarge methods accordingly.
func _check_line_count() -> void:
#	_print_debug_message("Checking lines of " + str(name))
	if get_content_height() > rect_size.y and _current_font_size > max(_base_font_size - (_size_per_step * _max_steps), 1):
		_shrink_font()
		return
	elif get_content_height() <= rect_size.y and _current_font_size < _base_font_size:
		_enlarge_font()
		return
	_last_size_state = LABEL_SIZE_STATE.IDLE


## Makes the font size smaller. Rechecks or stops the cycle depending on the conditions.
func _shrink_font():
#	_print_debug_message(str(name) + "' shrink method called")
	_override_font_size(_current_font_size - _size_per_step)
#	_print_debug_message(str(name) + " shrunk " + str(_size_per_step) + "px.")
	if _last_size_state == LABEL_SIZE_STATE.JUST_ENLARGED: ## To stop infinite cycles.
		_last_size_state = LABEL_SIZE_STATE.IDLE
#		_print_debug_message(str(name) + " finished shrinking. Was just enlarged.")
	else:
		_last_size_state = LABEL_SIZE_STATE.JUST_SHRUNK
		_check_line_count()


## Makes the font size larger. Rechecks/Shrinks/stops the cycle depending on the conditions.
func _enlarge_font():
#	_print_debug_message(str(name) + "' enlarge method called")
	_override_font_size(_current_font_size + _size_per_step)
	if _last_size_state == LABEL_SIZE_STATE.JUST_SHRUNK:
		if  get_content_height() > rect_size.y:
			_last_size_state = LABEL_SIZE_STATE.JUST_ENLARGED
			_shrink_font()
		else: ## To stop infinite cycles.
#			_print_debug_message(str(name) + " finished enlarging. Was just shrunk.")
			_last_size_state = LABEL_SIZE_STATE.IDLE
	else:
		_last_size_state = LABEL_SIZE_STATE.JUST_ENLARGED
		_check_line_count()


## Applies the new font size.
func _override_font_size(new_size: int) -> void:
	_size_just_modified_by_autosizer = true
	var font = self.get_font("normal_font", "RichTextLabel").duplicate()
	font.size = new_size
	add_font_override("normal_font", font)
	_current_font_size = new_size



## Prints message on console, for debugging was used while developing. You can decomment all the calls to debug.
func _print_debug_message(message: String) -> void:
	if _print_debug_enabled:
		print(message)
#endregion


#region --Public funcs--
## Gets called in-editor and sets the default values.
func set_editor_defaults() -> void:
	_set_defaults =  true
	fit_content_height = false
	scroll_active = false
	rect_clip_content = false
	call_deferred("_set_base_font_size")
	call_deferred("_set_current_font_size_to_base")
	call_deferred("_connect_signals")

## For some reason using set_deferred() wasn't doing it after setting the base size, so this gets called deferred.
func _set_current_font_size_to_base() -> void:
	_current_font_size = _base_font_size


## Text can be changed via either: set_text(value), or _my_label.text = value. Both will trigger a line check.
func set_text(new_text: String) -> void:
	text = new_text
	call_deferred("_check_line_count")
#endregion

