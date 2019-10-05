extends Node2D

signal place_tile
signal sell_tile

signal buy_train

var building_rail := false
var placing_train := false

func _input(event: InputEvent) -> void:
	if (event is InputEventMouse):
		if (building_rail):
			if (event.button_mask == BUTTON_LEFT):
				var mouse_pos := get_local_mouse_position()
				emit_signal("place_tile", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))

		if (placing_train):
			if (event.button_mask == BUTTON_LEFT):
				var mouse_pos := get_local_mouse_position()
				emit_signal("buy_train", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))

		if (event is InputEventMouseMotion ):
			var mouse_pos := get_local_mouse_position()
			mouse_pos.x = floor(mouse_pos.x / Globals.tile_width) * Globals.tile_width
			mouse_pos.y = floor(mouse_pos.y / Globals.tile_height) * Globals.tile_height
			$place_tile_icon.position = mouse_pos

		if (event.button_mask == BUTTON_RIGHT):
			var mouse_pos := get_local_mouse_position()
			emit_signal("sell_tile", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))



func set_building_rail(enabled : bool) -> void:
	building_rail = enabled;


func set_place_train(enabled : bool) -> void:
	placing_train = enabled

func is_performing_action() -> bool:
	return building_rail || placing_train
