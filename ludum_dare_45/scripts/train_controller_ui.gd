extends VBoxContainer

signal save_train

func _ready() -> void:
	$HBoxContainer/apply.connect("button_up", self, "_apply_clicked")
	$HBoxContainer/cancel.connect("button_up", self, "_cancel_clicked")
	$options.get_popup().connect("id_pressed", self, "_option_selected")

func edit(instructions : Array, stations : Array) -> void:
	$instructions.clear()
	for intruction in instructions:
		$instructions.add_item(intruction);

	$options.get_popup().clear()
	for station in stations:
		$options.get_popup().add_item(station)
	visible = true
	pass

func _option_selected(idx : int):
	$instructions.add_item($options.get_popup().get_item_text(idx))

func _apply_clicked() -> void:
	var instructions := []
	for i in $instructions.items.size():
		if ($instructions.get_item_text(i) != ""):
			instructions.push_back($instructions.get_item_text(i))
	print(instructions)
	emit_signal("save_train", instructions)
	visible = false

func _cancel_clicked() -> void:
	visible = false
