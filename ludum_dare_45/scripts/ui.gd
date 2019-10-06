extends Control

signal edit_signal_zone

signal build_rail_toggled
signal place_train_toggled
signal place_signal_toggled

var updating_buttons := false
var clicked := false

signal save_train

func _ready() -> void:
	$build_rail.connect("toggled", self, "build_rail_toggled")
	$place_train.connect("toggled", self, "place_train_toggled")
	$place_signal.connect("toggled", self, "place_signal_toggled")
	$train_controller.connect("save_train", self, "save_train")
	$signal_editor.connect("edit_signal_zone", self, "edit_signal_zone")

func game_over(moved : int) -> void:
	$igm.show_game_over(moved)

func _reset_buttons():
	updating_buttons = true;
	$place_train.set_pressed(false)
	$build_rail.set_pressed(false)
	$place_signal.set_pressed(false)
	updating_buttons = false;

func build_rail_toggled(toggled : bool) -> void:
	if ($signal_editor.visible || $train_controller.visible):
		_reset_buttons()
		return
	emit_signal("build_rail_toggled", toggled)
	if (toggled):
		$place_train.set_pressed(false)
		$place_signal.set_pressed(false)

func place_train_toggled(toggled : bool) -> void:
	if ($signal_editor.visible || $train_controller.visible):
		_reset_buttons()
		return
	emit_signal("place_train_toggled", toggled)
	if (toggled):
		$build_rail.set_pressed(false)
		$place_signal.set_pressed(false)

func place_signal_toggled(toggled : bool) -> void:
	if ($signal_editor.visible || $train_controller.visible):
		_reset_buttons()
		return
	emit_signal("place_signal_toggled", toggled)
	if (toggled):
		$build_rail.set_pressed(false)
		$place_train.set_pressed(false)

func edit_train(instructions : Array, stations : Array) -> void:
	$train_controller.edit(instructions, stations)

func edit_signal(signal_to_edit) -> void:
	$signal_editor.edit(signal_to_edit)

func edit_signal_zone(signal_to_edit, editing) -> void:
	emit_signal("edit_signal_zone", signal_to_edit, editing)

func save_train(instructions : Array) -> void:
	emit_signal("save_train", instructions)
