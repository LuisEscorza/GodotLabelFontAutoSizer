extends Control

export(Array, NodePath) var _labelPaths


var added_numbers: Array = []

func _on_button_clicked(_adds_number : bool):
	if _adds_number:
		var random_num = randi() % 101
		added_numbers.append(random_num)  # Add the random number to the list
	else:
		if added_numbers.size() > 0:
			added_numbers.remove(added_numbers.size() - 1)
	update_labelPaths()


func update_labelPaths() -> void:
	for path in _labelPaths:
		get_node(path).text = ""
		for num in added_numbers:
			get_node(path).text += str(num) + " "

