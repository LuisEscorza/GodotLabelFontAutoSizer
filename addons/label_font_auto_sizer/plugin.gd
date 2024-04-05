@tool
extends EditorPlugin

var _current_root: Node

func _ready() -> void:
	_current_root = EditorInterface.get_edited_scene_root()
	if _current_root == null:
		while _current_root == null:
			await get_tree().process_frame
			_current_root = EditorInterface.get_edited_scene_root()
	_current_root.child_entered_tree.connect(_on_child_entered_tree.bind())
	scene_changed.connect(_on_scene_changed.bind())
	call_deferred("_check_nodes_in_scene")


func _on_child_entered_tree(node: Node) -> void:
	if node is Label or node is RichTextLabel:
		node.tree_exiting.connect(_on_label_exiting_tree.bind(node))
		node.script_changed.connect(_on_label_script_changed.bind(node))


func _on_scene_changed(root: Node) -> void:
	if _current_root != null:
		_current_root.child_entered_tree.disconnect(_on_child_entered_tree.bind())
	_current_root = root
	if _current_root == null:
		while _current_root == null:
			await get_tree().process_frame
			_current_root = EditorInterface.get_edited_scene_root()
	_current_root.child_entered_tree.connect(_on_child_entered_tree.bind())
	call_deferred("_check_nodes_in_scene")


func _check_nodes_in_scene() -> void:
	var nodes_to_check: Array[Node] = []
	nodes_to_check.append(_current_root)
	while nodes_to_check.size() > 0:
		var current_node: Node = nodes_to_check.pop_front()
		if current_node is Label or current_node is RichTextLabel:
			current_node.tree_exiting.connect(_on_label_exiting_tree.bind(current_node))
			current_node.script_changed.connect(_on_label_script_changed.bind(current_node))
		if current_node.get_child_count() > 0:
			for child_node in current_node.get_children():
				nodes_to_check.append(child_node)


func _on_label_exiting_tree(label: Node) -> void:
	label.tree_exiting.disconnect(_on_label_exiting_tree.bind(label))
	label.script_changed.disconnect(_on_label_script_changed.bind(label))


func _on_label_script_changed(label: Node):
	var script: Script = label.get_script()
	if script == null:
		return
	elif script.resource_path.ends_with("label_auto_sizer.gd"):
		label.set_editor_defaults()
