extends Button

@export var _labels: Array[Label]

static var added_numbers: Array[int]= []

func _on_button_clicked():
	var random_num = randi_range(0, 100)
	added_numbers.append(random_num)  # Add the random number to the list
	update_labels()


func update_labels() -> void:
	for label in _labels:
		label.set_label_text("")
		for num in added_numbers:
			label.text += str(num) + " "
		label.check_size()
