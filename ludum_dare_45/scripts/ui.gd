extends Control

signal build_rail_toggled
signal place_train_toggled

var updating_buttons := false

func _ready() -> void:
	$build_rail.connect("toggled", self, "build_rail_toggled")
	$place_train.connect("toggled", self, "place_train_toggled")

func _reset_buttons():
	updating_buttons = true;
	$place_train.set_pressed(false)
	$build_rail.set_pressed(false)
	updating_buttons = false;

func build_rail_toggled(toggled : bool) -> void:
	emit_signal("build_rail_toggled", toggled)
	if (toggled):
		$place_train.set_pressed(false)

func place_train_toggled(toggled : bool) -> void:
	emit_signal("place_train_toggled", toggled)
	if (toggled):
		$build_rail.set_pressed(false)
