extends Node2D

var train = preload("res://objects/train.tscn")

func _ready() -> void:
	$player.connect("place_tile", $level, "place_tile")
	$player.connect("sell_tile", $level, "sell_tile")
	$player.connect("buy_train", self, "_buy_train")

	$ui.connect("build_rail_toggled", $player, "set_building_rail")
	$ui.connect("place_train_toggled", $player, "set_place_train")

func _buy_train(x : int, y : int) -> void:
	var new_train = train.instance()
	new_train.position = $level/nav/map.map_to_world(Vector2(x,y))
	$trains.add_child(new_train)

	var points = $level/nav.get_simple_path(new_train.position, $level/stations/station.position, false)
	if (points.size() > 0 && points[0] == new_train.position):
		$Line2D.points = points
