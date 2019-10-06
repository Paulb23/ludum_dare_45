extends Node2D

signal edit_signal

const STATION_SQUARE = 0
const STATION_CIRCLE = 1

const UP = 0
const DOWN = 1
const LEFT = 2
const RIGHT = 3

const EMPTY = 0
const NO_CONNECTIONS = 1
const SINGLE_CONNECTION = 2
const THREE_CONNECTIONS = 3
const STRAIGHT_CONNECION = 4
const RIGHT_ANGLE_CONNECTION = 5
const QUAD_CONNECIONS = 6
const STATION_TILE = 7

onready var map = $nav/map

var max_people = 10
var current_people = 0
var station = preload("res://objects/station.tscn")
var stations = {}

var signal_scene = preload("res://objects/signal.tscn")

func _ready() -> void:
	for x in range(0, 100):
		for y in range(0, 100):
			map.set_cell(x ,y, 0)

func create_signal(x : int, y : int) -> void:
	var new_signal = signal_scene.instance()
	new_signal.position = Vector2(x * 32, y * 32)
	new_signal.connect("clicked", self, "signal_clicked")
	$signals.add_child(new_signal)

func signal_clicked(clicked_signal) -> void:
	emit_signal("edit_signal", clicked_signal)

func create_station() -> void:
	_create_station("square", 12*32, 12*32)
	_create_station("circle", 42*32, 12*32)
	_create_station("triangle", 34*32, 24*32)

func _create_station(type : String, x : int, y : int) -> void:
	var new_station = station.instance()
	new_station.position = Vector2(x, y)
	new_station.connect("request_person", self, "_request_person")
	new_station.connect("person_created", self, "_person_created")
	new_station.connect("person_removed", self, "_person_removed")
	stations[type] = new_station
	$stations.add_child(new_station)
	new_station.set_type(type)
	var start_tile_x = floor(x / Globals.tile_width)
	var start_tile_y = floor(y / Globals.tile_height)
	for i in range(start_tile_x, start_tile_x + 4):
		for j in range(start_tile_y, start_tile_y + 3):
			map.set_cell(i , j, STATION_TILE)

func get_station_names() -> Array:
	return stations.keys()

func get_station(type : String) -> Vector2:
	return stations[type]

func _request_person(requesting_station):
	if current_people < max_people:
		requesting_station.can_generate = true;
		if (!$spawn_1.playing && !$spawn_2.playing):
			if (rand_range(0, 1) > 0.5):
				$spawn_1.play()
			else:
				$spawn_2.play()

func _person_created():
	current_people += 1

func _person_removed():
	current_people -= 1

func place_tile(x : int, y : int) -> void:
	map.set_cell(x ,y, NO_CONNECTIONS)
	_update_cell(x , y)
	_update_cell(x - 1 , y)
	_update_cell(x + 1, y)
	_update_cell(x , y - 1)
	_update_cell(x , y + 1)

func get_tile(x : int, y : int) -> int:
	return map.get_cell(x ,y)

func sell_tile(x : int, y : int) -> void:
	map.set_cell(x ,y, EMPTY)
	_update_cell(x - 1 , y)
	_update_cell(x + 1, y)
	_update_cell(x , y - 1)
	_update_cell(x , y + 1)

func _update_cell(x : int, y : int) -> void:
	if (map.get_cell(x, y) <= 0 || map.get_cell(x, y) == STATION_TILE || x < 0 || y < 0):
		return

	var connections := [0, 0, 0, 0]

	if (x > 0 && map.get_cell(x - 1, y) > 0):
		connections[LEFT] = 1

	if (map.get_cell(x + 1, y) > 0):
		connections[RIGHT] = 1

	if (y > 0 && map.get_cell(x, y - 1) > 0):
		connections[UP] = 1

	if (map.get_cell(x, y + 1) > 0):
		connections[DOWN] = 1

	var total_connections = connections.count(1)

	if (total_connections == 0):
		map.set_cell(x , y, NO_CONNECTIONS)
		return

	if (total_connections == 4):
		map.set_cell(x , y, QUAD_CONNECIONS)
		return

	if (total_connections == 1):
		map.set_cell(x ,y, SINGLE_CONNECTION, connections[RIGHT], connections[DOWN], connections[RIGHT] || connections[LEFT])
		return

	if (total_connections == 3):
		map.set_cell(x ,y, THREE_CONNECTIONS, connections[RIGHT], !connections[UP], (connections[UP] && !connections[DOWN]) || (!connections[UP] && connections[DOWN]))
		return

	if (total_connections == 2):
		if ((connections[LEFT] && connections[RIGHT]) || (connections[UP] && connections[DOWN])):
			map.set_cell(x ,y, STRAIGHT_CONNECION, connections[RIGHT], connections[DOWN], connections[RIGHT] || connections[LEFT])
			return
		map.set_cell(x ,y, RIGHT_ANGLE_CONNECTION, connections[RIGHT], connections[DOWN], connections[RIGHT] || connections[LEFT])
		return

func map_to_world(x : int, y :int) -> Vector2:
	return map.map_to_world(Vector2(x, y))


###############################################################################

onready var astar := AStar2D.new();
onready var _half_cell_size = Vector2(16, 16)

func _update_walkable_cells(obs : Array) -> void:
	var walkable_cells := []
	astar.clear()
	for x in range(0, 100):
		for y in range(0, 100):
			var cell_type : int = map.get_cell(x, y);
			if (cell_type == EMPTY):
				continue

			var point := Vector2(x, y)
			if (obs.has(point)):
				continue

			walkable_cells.append(point)
			var point_index : int = _calculate_point_index(point)
			astar.add_point(point_index, point)

	for point in walkable_cells:
		var point_index = _calculate_point_index(point)

		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y + 1),
			Vector2(point.x, point.y - 1)])
		for point_relative in points_relative:
			var point_relative_index : int = _calculate_point_index(point_relative)
			if is_outside_map_bounds(point_relative):
				continue
			if not astar.has_point(point_relative_index):
				continue
			astar.connect_points(point_index, point_relative_index, true)

func is_outside_map_bounds(point : Vector2) -> bool:
	return point.x < 0 or point.y < 0 or point.x >= 100 or point.y >= 100

func find_path(start : Vector2, end : Vector2) -> PoolVector2Array:
	var start_pos = map.world_to_map(start)
	var end_pos = map.world_to_map(end)
	var tile_points = astar.get_point_path(_calculate_point_index(start_pos), _calculate_point_index(end_pos))
	var points : PoolVector2Array
	for tile_point in tile_points:
		var point_world = map_to_world(tile_point.x, tile_point.y) + _half_cell_size
		points.append(point_world)
	return points

func _calculate_point_index(point : Vector2) -> int:
	return int(point.x + 100 * point.y)

