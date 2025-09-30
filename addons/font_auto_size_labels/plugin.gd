@tool
extends EditorPlugin


#region Virtual functions
func _enter_tree():
	add_custom_type("AutoSizeLabel", "Label", preload("auto_size_label.gd"), preload("icon.svg"))
	add_custom_type("AutoSizeRichTextLabel", "RichTextLabel", preload("auto_size_rich_text_label.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type("AutoSizeLabel")
	remove_custom_type("AutoSizeRichTextLabel")
#endregion
