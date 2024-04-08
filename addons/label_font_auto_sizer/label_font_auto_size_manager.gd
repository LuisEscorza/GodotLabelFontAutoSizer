tool
extends Node

var _active_labels : Array


func register_label(label: Control) -> void:
	_active_labels.append(label)


func erase_label(label: Control) -> void:
	_active_labels.erase(label)


## This function is to be called by the user after manually changing the locale of the game.
## Will cause to check the size of all the active labels, useful after changing the language of text pieces.
## Call it with: LabelFotAutoSizeManager.locale_changed()
func locale_chaged() -> void:
	for label in _active_labels:
		label._on_locale_changed()
