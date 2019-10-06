extends Node2D

signal place_tile
signal sell_tile

signal place_signal

signal buy_train
signal can_place_track
signal can_place_train
signal can_place_signal
signal can_place_signal_zone
signal sell_signal

var signal_edit

var building_rail := false
var placing_train := false
var placing_signal := false
var placing_signal_zone := false

var can_place_track := false
var can_place_train := false
var can_place_signal := false
var can_place_signal_zone := false

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
			if (placing_signal):
				emit_signal("can_place_signal", mouse_pos.x, mouse_pos.y)
			if (placing_signal_zone):
				emit_signal("can_place_signal_zone", mouse_pos.x, mouse_pos.y)
			$place_tile_icon.position = Vector2(mouse_pos.x * Globals.tile_width, mouse_pos.y * Globals.tile_height)

		if (building_rail):
			if (event.button_mask == BUTTON_LEFT):
				var mouse_pos := get_local_mouse_position()
				if (floor(mouse_pos.y / Globals.tile_height) > 28):
					return
				emit_signal("place_tile", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))

		if (placing_signal):
			if (event.is_action_released("place")):
				var mouse_pos := get_local_mouse_position()
				if (floor(mouse_pos.y / Globals.tile_height) > 28):
					return
				emit_signal("place_signal", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))

		if (placing_train):
			if (event.is_action_released("place")):
				var mouse_pos := get_local_mouse_position()
				if (floor(mouse_pos.y / Globals.tile_height) > 28):
					return
				emit_signal("buy_train", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))

		if (placing_signal_zone):
			if (event.button_mask == BUTTON_LEFT):
				var mouse_pos := get_local_mouse_position()
				if (floor(mouse_pos.y / Globals.tile_height) > 28):
					return
				if (can_place_signal_zone):
					signal_edit.add_zone_check(floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))

		if (event.button_mask == BUTTON_RIGHT):
			var mouse_pos := get_local_mouse_position()
			if (placing_signal_zone):
				signal_edit.remove_zone_check(floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))
				return
			if (placing_signal):
				emit_signal("sell_signal", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))
				return
			emit_signal("sell_tile", floor(mouse_pos.x / Globals.tile_width), floor(mouse_pos.y / Globals.tile_height))

func set_building_rail(enabled : bool) -> void:
	building_rail = enabled;
	can_place_track = false

func edit_signal_zone(signal_to_edit, editing) -> void:
	signal_edit = signal_to_edit
	placing_signal_zone = editing

func set_place_train(enabled : bool) -> void:
	placing_train = enabled
	can_place_train = false

func set_place_signal(enabled : bool) -> void:
	placing_signal = enabled
	can_place_signal = false

func is_performing_action() -> bool:
	return building_rail || placing_train || placing_signal
