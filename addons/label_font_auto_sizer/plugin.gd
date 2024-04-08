@tool
extends EditorPlugin

var _current_root: Node


## Class setup.
func _ready() -> void:
	await _set_root(EditorInterface.get_edited_scene_root())
	scene_changed.connect(_on_scene_changed.bind())
	call_deferred("_check_nodes_in_scene")


## Called whenever a new node is added to the scene. Calls for a label check.
func _on_child_entered_tree(node: Node) -> void:
	if !node.child_entered_tree.is_connected(_on_child_entered_tree.bind()): ##Keeps checking for nested children, looking for labels.
			node.child_entered_tree.connect(_on_child_entered_tree.bind())
	if !node.child_exiting_tree.is_connected(_on_child_exiting_tree.bind()):
			node.child_exiting_tree.connect(_on_child_exiting_tree.bind())
	_check_label(node)


## Called when changing scene. Gets the new root and calls for a node scan in the tree.
func _on_scene_changed(root: Node) -> void:
	if _current_root != null and is_instance_valid(_current_root):
		if _current_root.child_entered_tree.is_connected(_on_child_entered_tree.bind()):
			_current_root.child_entered_tree.disconnect(_on_child_entered_tree.bind())
	_current_root = root
	await _set_root(root)
	call_deferred("_check_nodes_in_scene")


## Gets called whenever any node is deleted, and when user changes scene.
func _on_child_exiting_tree(node: Node) -> void:
	if node.child_exiting_tree.is_connected(_on_child_exiting_tree):
		node.child_exiting_tree.disconnect(_on_child_exiting_tree)
	if node.child_entered_tree.is_connected(_on_child_entered_tree):
		node.child_entered_tree.disconnect(_on_child_entered_tree)


## Gets called whenever a label is deleted, and whenever user changes scene.
func _on_label_exiting_tree(label: Node) -> void:
	if label.tree_exiting.is_connected(_on_label_exiting_tree.bind(label)):
		label.tree_exiting.disconnect(_on_label_exiting_tree.bind(label))
	if label.script_changed.is_connected(_on_label_script_changed.bind(label)):
		label.script_changed.disconnect(_on_label_script_changed.bind(label))


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
		await _check_root()
	if !_current_root.child_entered_tree.is_connected(_on_child_entered_tree.bind()):
			_current_root.child_entered_tree.connect(_on_child_entered_tree.bind())


## If no root is found (all scenes are closed) it keeps checking until one is opened.
func _check_root() -> void:
	while _current_root == null:
		await get_tree().process_frame
		_current_root = EditorInterface.get_edited_scene_root()


## Goes through every node in the scene, children included. Calls for a label check.
## get_children(true) is not returning nested children so it needs to be done manually.
func _check_nodes_in_scene() -> void:
	var nodes_to_check: Array[Node] = []
	nodes_to_check.append(_current_root)
	while nodes_to_check.size() > 0:
		var current_node: Node = nodes_to_check.pop_front()
		if !current_node.child_entered_tree.is_connected(_on_child_entered_tree.bind()):
			current_node.child_entered_tree.connect(_on_child_entered_tree.bind())
		if !current_node.child_exiting_tree.is_connected(_on_child_exiting_tree.bind()):
			current_node.child_exiting_tree.connect(_on_child_exiting_tree.bind())
		_check_label(current_node)
		if current_node.get_child_count() > 0:
			for child_node in current_node.get_children():
				nodes_to_check.append(child_node)


## Checks if the node is a label, starts listening for its attatched script.
## If the node has the script already attached, it sets the defaults directly.
func _check_label(node: Node) -> void:
	if node is Label or node is RichTextLabel:
		if !node.tree_exiting.is_connected(_on_label_exiting_tree.bind(node)):
			node.tree_exiting.connect(_on_label_exiting_tree.bind(node))
		if !node.script_changed.is_connected(_on_label_script_changed.bind(node)):
			node.script_changed.connect(_on_label_script_changed.bind(node))
		if node is LabelAutoSizer or node is RichLabelAutoSizer:
			node.set_editor_defaults()
