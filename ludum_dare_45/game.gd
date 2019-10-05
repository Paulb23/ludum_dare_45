extends Node2D

var train = preload("res://objects/train.tscn")
var clicked_train

func _ready() -> void:
	$player.connect("place_tile", $level, "place_tile")
	$player.connect("sell_tile", $level, "sell_tile")
	$player.connect("buy_train", self, "_buy_train")

	$ui.connect("build_rail_toggled", $player, "set_building_rail")
	$ui.connect("place_train_toggled", $player, "set_place_train")
	$ui.connect("save_train", self, "_save_train")

	$level.create_station()

func _buy_train(x : int, y : int) -> void:
	var new_train = train.instance()
	new_train.position = $level.map_to_world(x, y)
	new_train.connect("clicked", self, "_train_clicked")
	$trains.add_child(new_train)

	var points = $level/nav.get_simple_path(new_train.position, $level.get_station("square").position, false)
	if (points.size() > 0 && points[0] == new_train.position):
		$Line2D.points = points

func _train_clicked(train) -> void:
	if ($player.is_performing_action()):
		return
	clicked_train = train
	$ui.edit_train(clicked_train.instructions, $level.get_station_names())

func _save_train(instructions : Array) -> void:
	clicked_train.instructions = instructions
