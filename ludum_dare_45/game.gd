extends Node2D

var train = preload("res://objects/train.tscn")
var clicked_train
var first_train = true

func _ready() -> void:
	$player.connect("place_tile", self, "_buy_track")
	$player.connect("can_place_track", self, "_can_place_track")
	$player.connect("can_place_train", self, "_can_place_train")
	$player.connect("sell_tile", $level, "sell_tile")
	$player.connect("buy_train", self, "_buy_train")

	$ui.connect("build_rail_toggled", $player, "set_building_rail")
	$ui.connect("place_train_toggled", $player, "set_place_train")
	$ui.connect("save_train", self, "_save_train")

	$level.create_station()

func _can_place_track(x : int, y : int) -> void:
	$player.can_place_track = ($level.get_tile(x ,y) == $level.EMPTY);

func _can_place_train(x : int, y : int) -> void:
	$player.can_place_train = ($level.get_tile(x ,y) != $level.EMPTY && $level.get_tile(x ,y) != $level.STATION_TILE);

func _buy_track(x : int, y: int) -> void:
	if (!$build_1.playing && !$build_2.playing):
		if (rand_range(0, 1) > 0.5):
			$build_1.play()
		else:
			$build_2.play()
	$level.place_tile(x, y)

func _buy_train(x : int, y : int) -> void:
	if (!$player.can_place_train):
		if (!$bad_place.playing):
			$bad_place.play()
		return

	var new_train = train.instance()
	new_train.position = $level.map_to_world(x, y)
	new_train.connect("clicked", self, "_train_clicked")
	new_train.connect("request_path", self, "_train_request_path")
	$trains.add_child(new_train)
	if (first_train):
		$music.play()
		first_train = false

func _train_clicked(train) -> void:
	if ($player.is_performing_action()):
		return
	clicked_train = train
	$ui.edit_train(clicked_train.instructions, $level.get_station_names())

func _save_train(instructions : Array) -> void:
	clicked_train.set_instructions(instructions)

func _train_request_path(train, station : String):
	var points = $level/nav.get_simple_path(train.position, $level.get_station(station).get_target_pos(), false)
	if (points.size() > 0 && points[0] == train.position):
		points.remove(0)
		train.set_path(points)
