tool
extends EditorPlugin


var _current_root: Node


func _enter_tree():
	add_custom_type("AutoSizeLabel", "Label", preload("label_auto_sizer.gd"), preload("label_font_auto_sizer.svg"))
	add_custom_type("AutoSizeRichTextlabel", "RichTextLabel", preload("rich_label_auto_sizer.gd"), preload("label_font_auto_sizer.svg"))


func _exit_tree():
	remove_custom_type("AutoSizeLabel")
	remove_custom_type("AutoSizeRichTextlabel")

