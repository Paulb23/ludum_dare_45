extends Node2D

signal clicked

const UP = 0
const DOWN = 1
const LEFT = 2
const RIGHT = 3

const TRAIN_CHECK = 0
const ZONE_CHECK = 1

var train_direction_check = 2

var zoned_tiles = []

func _ready() -> void:
	$clicked.connect("button_up", self, "_clicked")
	$zones.set_as_toplevel(true)

func add_zone_check(x : int, y : int) -> void:
	if (!zoned_tiles.has(Vector2(x ,y))):
		zoned_tiles.push_back(Vector2(x ,y))
	$zones.set_cell(x, y, ZONE_CHECK)

func get_zone() -> Array:
	return zoned_tiles

func draw_zones(vis : bool) -> void:
	$zones.visible = vis

func _clicked() -> void:
	emit_signal("clicked", self)
