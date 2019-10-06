extends VBoxContainer

signal save_train

func _ready() -> void:
	$HBoxContainer/apply.connect("button_up", self, "_apply_clicked")
	$HBoxContainer/cancel.connect("button_up", self, "_cancel_clicked")
	$options.get_popup().connect("id_pressed", self, "_option_selected")
	$instructions.connect("button_pressed", self, "_delete_item")

func edit(instructions : Array, stations : Array) -> void:
	$instructions.clear()
	var root = $instructions.create_item();
	for intruction in instructions:
		var item = $instructions.create_item();
		item.set_text(0, intruction)
		item.add_button(0, load("res://icons/delete_icon.png"))

	$options.get_popup().clear()
	for station in stations:
		$options.get_popup().add_item(station)
	visible = true
	pass

func _delete_item(item: TreeItem, column: int, id: int) -> void:
	$instructions.get_root().remove_child(item)


func _option_selected(idx : int):
	var item = $instructions.create_item();
	item.set_text(0, $options.get_popup().get_item_text(idx))
	item.add_button(0, load("res://icons/delete_icon.png"))

func _apply_clicked() -> void:
	var instructions := []

	var child = $instructions.get_root().get_children()
	while child != null:
		instructions.push_back(child.get_text(0))
		child = child.get_next()
	emit_signal("save_train", instructions)
	visible = false

func _cancel_clicked() -> void:
	visible = false
