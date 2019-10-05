extends Node2D

signal place_tile

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		if (event.button_mask == BUTTON_LEFT):
			var mouse_pos := get_local_mouse_position()
			emit_signal("place_tile", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))
