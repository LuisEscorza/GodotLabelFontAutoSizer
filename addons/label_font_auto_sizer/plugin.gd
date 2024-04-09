tool
extends EditorPlugin
signal set_root_completed
signal check_root_completed

var _current_root: Node


## Class setup.
func _ready() -> void:
	add_autoload_singleton("LabelFontAutoSizeManager", "res://addons/label_font_auto_sizer/label_font_auto_size_manager.gd")
	_set_root(get_editor_interface().get_edited_scene_root())
	yield(self, "set_root_completed")
	connect("scene_changed", self, "_on_scene_changed")
	call_deferred("_check_nodes_in_scene")


## Called whenever a new node is added to the scene. Calls for a label check.
func _on_child_entered_tree(node: Node) -> void:
	if !node.is_connected("child_entered_tree", self, "_on_child_entered_tree"):##Keeps checking for nested children, looking for labels.
		node.connect("child_entered_tree", self,"_on_child_entered_tree")
	if !node.is_connected("child_exiting_tree", self, "_on_child_exiting_tree"):
		node.connect("child_exiting_tree", self,"_on_child_exiting_tree")
	_check_label(node)


## Called when changing scene. Gets the new root and calls for a node scan in the tree.
func _on_scene_changed(root: Node) -> void:
	if _current_root != null and is_instance_valid(_current_root):
		if _current_root.is_connected("child_exiting_tree", self, "_on_child_exiting_tree"):
			_current_root.disconnect("child_entered_tree", self, "_on_child_entered_tree")
	_current_root = root
	_set_root(root)
	yield(self, "set_root_completed")
	call_deferred("_check_nodes_in_scene")


## Gets called whenever any node is deleted, and when user changes scene.
func _on_child_exiting_tree(node: Node) -> void:
	if node.is_connected("child_exiting_tree", self, "_on_child_exiting_tree"):
		node.disconnect("child_exiting_tree", self, "_on_child_exiting_tree")
	if node.is_connected("child_entered_tree", self, "_on_child_entered_tree"):
		node.disconnect("child_entered_tree", self, "_on_child_entered_tree")


## Gets called whenever a label is deleted, and whenever user changes scene.
func _on_label_exiting_tree(label: Node) -> void:
	if label.is_connected("tree_exiting", self, "_on_label_exiting_tree"):
		label.disconnect("tree_exiting", self, "_on_label_exiting_tree")
	if label.is_connected("script_changed", self, "_on_label_script_changed"):
		label.disconnect("script_changed", self, "_on_label_script_changed")


## Gets called whenever any label on the scene gets a (new) script or is removed from it.
## If it finds an autosizer added to the label, it sets the default values automatically (basically the reason of this class).
func _on_label_script_changed(label: Node):
	var script: Script = label.get_script()
	if script == null:
		return
	elif script.resource_path.ends_with("label_auto_sizer.gd"):
		label.set_editor_defaults()


## Sets the current scene root and listens for nodes entering in the tree.
func _set_root(root: Node) -> void:
	_current_root = root
	if _current_root == null:
		_check_root()
		yield(self, "check_root_completed")
	if !_current_root.is_connected("child_entered_tree", self, "_on_child_entered_tree"):
		_current_root.connect("child_entered_tree", self, "_on_child_entered_tree")
	emit_signal("set_root_completed")


## If no root is found (all scenes are closed) it keeps checking until one is opened.
func _check_root() -> void:
	while _current_root == null:
		yield(get_tree(), "idle_frame")
		_current_root = get_editor_interface().get_edited_scene_root()
	emit_signal("check_root_completed")


## Goes through every node in the scene, children included. Calls for a label check.
## get_children(true) is not returning nested children so it needs to be done manually.
func _check_nodes_in_scene() -> void:
	var nodes_to_check: Array = []
	nodes_to_check.append(_current_root)
	while nodes_to_check.size() > 0:
		var current_node: Node = nodes_to_check.pop_front()
		if !current_node.is_connected("child_entered_tree", self, "_on_child_entered_tree"):
			current_node.connect("child_entered_tree", self,"_on_child_entered_tree")
		if !current_node.is_connected("child_exiting_tree", self, "_on_child_exiting_tree"):
			current_node.connect("child_exiting_tree", self,"_on_child_exiting_tree")
		_check_label(current_node)
		if current_node.get_child_count() > 0:
			for child_node in current_node.get_children():
				nodes_to_check.append(child_node)


## Checks if the node is a label, starts listening for its attatched script.
## If the node has the script already attached, it sets the defaults directly.
func _check_label(node: Node) -> void:
	if node is Label or node is RichTextLabel:
		if !node.is_connected("tree_exiting", self, "_on_label_exiting_tree"):
			node.connect("tree_exiting", self, "_on_label_exiting_tree", [node])
		if !node.is_connected("script_changed", self, "_on_label_script_changed"):
			node.connect("script_changed", self, "_on_label_script_changed", [node])
			
		var script: Script = node.get_script()
		if script != null and script.resource_path.ends_with("label_auto_sizer.gd"):
			node.set_editor_defaults()

