extends Node2D

signal place_tile
signal sell_tile

signal buy_train
signal can_place_track
signal can_place_train

var building_rail := false
var placing_train := false

var can_place_track := false
var can_place_train := false

func _input(event: InputEvent) -> void:
	if (event is InputEventMouse):
		if (event is InputEventMouseMotion ):
			var mouse_pos := get_local_mouse_position()
			mouse_pos.x = floor(mouse_pos.x / Globals.tile_width)
			mouse_pos.y = floor(mouse_pos.y / Globals.tile_height)
			if (building_rail):
				emit_signal("can_place_track", mouse_pos.x, mouse_pos.y)
			if (placing_train):
				emit_signal("can_place_train", mouse_pos.x, mouse_pos.y)
			$place_tile_icon.position = Vector2(mouse_pos.x * Globals.tile_width, mouse_pos.y * Globals.tile_height)

		if (building_rail):
			if (event.button_mask == BUTTON_LEFT):
				var mouse_pos := get_local_mouse_position()
				if (floor(mouse_pos.y / Globals.tile_height) > 28):
					return
				emit_signal("place_tile", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))

		if (placing_train):
			if (event.is_action_released("place")):
				var mouse_pos := get_local_mouse_position()
				if (floor(mouse_pos.y / Globals.tile_height) > 28):
					return
				emit_signal("buy_train", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))

		if (event.button_mask == BUTTON_RIGHT):
			var mouse_pos := get_local_mouse_position()
			emit_signal("sell_tile", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))

func set_building_rail(enabled : bool) -> void:
	building_rail = enabled;
	can_place_track = false


func set_place_train(enabled : bool) -> void:
	placing_train = enabled
	can_place_train = false

func is_performing_action() -> bool:
	return building_rail || placing_train
