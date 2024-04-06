extends Button

@export var _labels: Array[Label]

static var added_numbers: Array[int]= []

func _on_button_clicked(_adds_number : bool):
	if _adds_number:
		var random_num = randi_range(0, 100)
		added_numbers.append(random_num)  # Add the random number to the list
	else:
		if added_numbers.size() > 0:
			added_numbers.remove_at(added_numbers.size() - 1)
	update_labels()


func update_labels() -> void:
	for label in _labels:
		label.text = ""
		for num in added_numbers:
			label.text += str(num) + " "

