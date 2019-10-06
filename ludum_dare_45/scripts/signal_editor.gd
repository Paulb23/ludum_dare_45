extends VBoxContainer

signal edit_signal_zone

var signal_editing
var editing_zone

func _ready() -> void:
	$HBoxContainer/edit_zone.connect("button_up", self, "_set_editing_zone")
	editing_zone = false

	$HBoxContainer/train_diriection.add_item("Up")
	$HBoxContainer/train_diriection.add_item("Down")
	$HBoxContainer/train_diriection.add_item("Left")
	$HBoxContainer/train_diriection.add_item("Right")
	$HBoxContainer/train_diriection.connect("item_selected", self, "_update_train_check")

	$HBoxContainer/ok.connect("pressed", self, "_apply_clicked")

func edit(signal_to_edit) -> void:
	signal_editing = signal_to_edit
	$HBoxContainer/train_diriection.select(signal_editing.train_direction_check)
	visible = true
	pass

func _update_train_check(dir : int) -> void:
	signal_editing.train_direction_check = dir

func _set_editing_zone():
	emit_signal("edit_signal_zone", signal_editing, true)
	editing_zone = true
	signal_editing.draw_zones(true)

func _apply_clicked() -> void:
	emit_signal("edit_signal_zone", signal_editing, false)
	editing_zone = false
	signal_editing.draw_zones(false)
	visible = false

