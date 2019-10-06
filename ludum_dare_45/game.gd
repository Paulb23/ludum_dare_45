extends Node2D

var train = preload("res://objects/train.tscn")
var clicked_signal
var clicked_train
var first_train = true

var moved_passengers = 0

func _ready() -> void:
	$player.connect("place_tile", self, "_buy_track")
	$player.connect("can_place_track", self, "_can_place_track")
	$player.connect("can_place_train", self, "_can_place_train")
	$player.connect("can_place_signal", self, "_can_place_signal")
	$player.connect("place_signal", self, "_place_signal")
	$player.connect("sell_tile", $level, "sell_tile")
	$player.connect("buy_train", self, "_buy_train")
	$player.connect("can_place_signal_zone", self, "_can_place_signal_zone")
	$player.connect("sell_signal", self, "_sell_signal")

	$ui.connect("build_rail_toggled", $player, "set_building_rail")
	$ui.connect("place_train_toggled", $player, "set_place_train")
	$ui.connect("place_signal_toggled", $player, "set_place_signal")
	$ui.connect("save_train", self, "_save_train")
	$ui.connect("edit_signal_zone", $player, "edit_signal_zone")

	$level.connect("edit_signal", self, "_edit_signal")
	$level.connect("game_over", self, "_game_over")
	$level.connect("person_removed", self, "_person_removed")
	$level.create_station()
	$level.create_station()



func _person_removed():
	moved_passengers += 1

func _game_over():
	$ui.game_over(moved_passengers)

func _can_place_track(x : int, y : int) -> void:
	if ($level.get_tile(x, y) != $level.EMPTY):
		$player.can_place_track = false
		return

	# check for circles
	var top_left = [$level.get_tile(x - 1, y) , $level.get_tile(x - 1, y - 1), $level.get_tile(x, y - 1)]
	if (top_left.count($level.EMPTY) + top_left.count($level.STATION_TILE) < 1):
		$player.can_place_track = false
		return

	var top_right = [$level.get_tile(x + 1, y) , $level.get_tile(x + 1, y - 1), $level.get_tile(x, y - 1)]
	if (top_right.count($level.EMPTY) + top_right.count($level.STATION_TILE) < 1):
		$player.can_place_track = false
		return

	var bottom_left = [$level.get_tile(x - 1, y) , $level.get_tile(x - 1, y + 1), $level.get_tile(x, y + 1)]
	if (bottom_left.count($level.EMPTY) + bottom_left.count($level.STATION_TILE) < 1):
		$player.can_place_track = false
		return

	var bottom_right = [$level.get_tile(x + 1, y) , $level.get_tile(x + 1, y + 1), $level.get_tile(x, y + 1)]
	if (bottom_right.count($level.EMPTY) + bottom_right.count($level.STATION_TILE) < 1):
		$player.can_place_track = false
		return

	$player.can_place_track = true

func _can_place_train(x : int, y : int) -> void:
	$player.can_place_train = ($level.get_tile(x ,y) != $level.EMPTY && $level.get_tile(x ,y) != $level.STATION_TILE);

func _can_place_signal(x : int, y : int) -> void:
	$player.can_place_signal = ($level.get_tile(x ,y) != $level.EMPTY && $level.get_tile(x ,y) != $level.STATION_TILE);
	if (!$player.can_place_signal):
		return
	$player.can_place_signal = !$level.has_signal(x, y)

func _can_place_signal_zone(x : int, y : int) -> void:
	$player.can_place_signal_zone = ($level.get_tile(x ,y) != $level.EMPTY && $level.get_tile(x ,y) != $level.STATION_TILE);

func _place_signal(x : int, y: int) -> void:
	if (!$player.can_place_signal):
		if (!$bad_place.playing):
			$bad_place.play()
		return
	$level.create_signal(x, y)

func _edit_signal(signal_to_edit) -> void:
	if ($player.is_performing_action()):
		return
	clicked_signal = signal_to_edit
	$ui.edit_signal(signal_to_edit)

func _sell_signal(x : int, y: int) -> void:
	if (!$level.has_signal(x, y)):
		return
	$level.remove_signal(x, y)

func _buy_track(x : int, y: int) -> void:
	if (!$player.can_place_track):
			return
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
	new_train.connect("train_zone_check", self, "_train_zone_check")
	new_train.connect("crash", self, "_crash")
	$trains.add_child(new_train)
	if (first_train):
		$music.play()
		first_train = false

func _train_zone_check(train, zone : Array, new_route : bool) -> void:
	for other_trains in $trains.get_children():
		if (other_trains == train):
			continue
		var train_pos = $level/nav/map.world_to_map(other_trains.position)
		if (zone.has(train_pos)):
			train.train_in_path = true
			if (new_route):
				$level._update_walkable_cells(zone);
				var points = $level.find_path(train.position, $level.get_station(train.current_target).get_target_pos())

				if (points.size() > 0):
					train.set_path(points)
					train.train_in_path = false
			return
	train.train_in_path = false

func _train_clicked(train_clicked) -> void:
	if ($player.is_performing_action()):
		return
	clicked_train = train_clicked
	$ui.edit_train(clicked_train.instructions, $level.get_station_names())

func _save_train(instructions : Array) -> void:
	clicked_train.set_instructions(instructions)

func _train_request_path(train, station : String):
	$level._update_walkable_cells([]);
	var points = $level.find_path(train.position, $level.get_station(station).get_target_pos())

	if (points.size() > 0):
		train.set_path(points)

func _crash():
	if (!$crash.playing):
		$crash.play()
