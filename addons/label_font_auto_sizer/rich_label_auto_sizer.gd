tool
extends RichTextLabel
class_name RichLabelAutoSizer, "res://addons/label_font_auto_sizer/label_font_auto_sizer.svg"

## The maximum size value in pixels that the font will grow to.
export(int, 1, 1024, 1) var _max_size = 64 setget _set_max_size
func _set_max_size(value) -> void:
	if value > _min_size:
		_max_size = value
	else:
		_max_size = _min_size
	call_deferred("_check_line_count")
## The minimum size value in pixels that the font will shrink to.
export(int, 1, 1024, 1) var _min_size = 64 setget _set_min_size
func _set_min_size(value) -> void:
	if value < _max_size:
		_min_size = value
	else:
		_min_size = _max_size
	call_deferred("_check_line_count")
export(bool) var _lock_size_in_editor =  false setget _set_lock_size_in_editor
func _set_lock_size_in_editor(value) -> void:
	_lock_size_in_editor = value
	if value == false:
		call_deferred("_check_line_count")

var _current_font_size: int
var _last_size_state = LABEL_SIZE_STATE.IDLE
var _size_just_modified_by_autosizer: bool = false
var _label_settings_just_duplicated: bool = false
var _editor_defaults_set: bool = false
var _autosize_manager

enum LABEL_SIZE_STATE {JUST_SHRUNK, IDLE, JUST_ENLARGED} 


## Gets called in-editor and in-game. Sets some default values if necessary.
func _ready() -> void:
	if !_editor_defaults_set:
		set_editor_defaults()
	if Engine.is_editor_hint():
		call_deferred("_connect_signals")
	_autosize_manager = get_node("/root/LabelFontAutoSizeManager")
	_autosize_manager.register_label(self)


## Gets called when there are changes in either the Theme or Label Settings resources.
## Checks if the change was made by the script of by the user and if not, sets the base font size value.
func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		if _size_just_modified_by_autosizer:
			_size_just_modified_by_autosizer = false ## Early return because the change wasn't made by the user.
		else:
			_apply_font_size(_current_font_size)


## Gets called whenever the size of the control rect is modified (in editor). Calls the line count check.
func _on_label_rect_resized() -> void:
	if !_editor_defaults_set:
		return
	call_deferred("_check_line_count")


## Called by autosize manager whenever the locale_chaged() method is called, as the tr() object changes don't trigger
## the set_text() method of the label, thus the size and line_amount doesn't get checked.
func _on_locale_changed() -> void:
	call_deferred("_check_line_count")


## Gets called on scene changes and when the label is freed and erases itself from the autosize manager.
func _exit_tree() -> void:
	_autosize_manager.erase_label(self)


##Only in-editor, keeps stuff in check while manually changing font resources and resizing the label.
func _connect_signals() -> void:
	if !is_connected("resized", self, "_on_label_rect_resized"):
		connect("resized", self,"_on_label_rect_resized")


## Text can be changed via either: set_text(value)/set_bbcode(value), or _my_label.text = value / _my_label.bbcode_text = value. Both will trigger a line check.
##**If you're doing some testing/developing, if you are changing the text from withit one of the label classes themselves, do it like self.set_text(value) or self.text = value, othersise it doesn't trigger a size check.
##In a real scenario you wouldn't be changing the text from within the class itself though.**
func _set(property: String, value) -> bool:
	match property:
		"text":
			text = value
			call_deferred("_check_line_count")
			return true
		"bbcode_text":
			text = value
			call_deferred("_check_line_count")
			return true
		_:
			return false


## Goes through the resources in the label and sets the base font size value.
## Priority: Override Theme Font Size > Theme Font Size. (RichTextLabels don't allow Label Settings)
func _check_font_size() -> void:
	if has_font_override("font"):
		_current_font_size = get("custom_fonts/normal_font").size
	else:
		var font = self.get_font("normal_font", "RichTextLabel")
		_current_font_size = font.size


## Makes variables persistent without exposing them in the editor.
## Will get removed in Godot 4.3 with the upcoming @export_storage annotation.
func _get_property_list():
	var properties: Array = []
	var bool_properties: Array = ["_size_just_modified_by_autosizer","_editor_defaults_set"]
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
	if Engine.is_editor_hint() and _lock_size_in_editor:
		return
	
	if _current_font_size > _max_size and _current_font_size > _min_size:
		_shrink_font()
		return
	elif get_content_height() > rect_size.y:
		if _current_font_size > _min_size:
			_shrink_font()
			return
	
	if _current_font_size < _max_size and _current_font_size < _min_size:
		_enlarge_font()
		return
	elif get_content_height() <= rect_size.y:
		if _current_font_size < _max_size:
			_enlarge_font()
			return
	_last_size_state = LABEL_SIZE_STATE.IDLE


## Makes the font size smaller. Rechecks or stops the cycle depending on the conditions.
func _shrink_font():
	_apply_font_size(_current_font_size - 1)
	if _last_size_state == LABEL_SIZE_STATE.JUST_ENLARGED: ## To stop infinite cycles.
		_last_size_state = LABEL_SIZE_STATE.IDLE
	else:
		_last_size_state = LABEL_SIZE_STATE.JUST_SHRUNK
		call_deferred("_check_line_count")


## Makes the font size larger. Rechecks/Shrinks/stops the cycle depending on the conditions.
func _enlarge_font():
	_apply_font_size(_current_font_size + 1)
	if _last_size_state == LABEL_SIZE_STATE.JUST_SHRUNK:
		if  get_content_height() > rect_size.y:
			_last_size_state = LABEL_SIZE_STATE.JUST_ENLARGED
			_shrink_font()
		else: ## To stop infinite cycles.
			_last_size_state = LABEL_SIZE_STATE.IDLE
	else:
		_last_size_state = LABEL_SIZE_STATE.JUST_ENLARGED
		call_deferred("_check_line_count")


## Applies the new font size.
func _apply_font_size(new_size: int) -> void:
	_size_just_modified_by_autosizer = true
	var font = self.get_font("normal_font", "RichTextLabel").duplicate()
	font.size = new_size
	add_font_override("normal_font", font)
	_current_font_size = new_size


## Gets called in-editor and sets the default values.
func set_editor_defaults() -> void:
	_editor_defaults_set =  true
	fit_content_height = false
	scroll_active = false
	rect_clip_content = false
	_check_font_size()
	_connect_signals()
	set_deferred("_max_size", _current_font_size)


## Text can be changed via either: set_text(value)/set_bbcode(value), or _my_label.text = value / _my_label.bbcode_text = value. Both will trigger a line check.
##**If you're doing some testing/developing, if you are changing the text from withit one of the label classes themselves, do it like self.set_text(value) or self.text = value, othersise it doesn't trigger a size check.
##In a real scenario you wouldn't be changing the text from within the class itself though.**
func set_text(new_text: String) -> void:
	text = new_text
	call_deferred("_check_line_count")


func set_bbcode(new_text: String) -> void:
	bbcode_text = new_text
	call_deferred("_check_line_count")

