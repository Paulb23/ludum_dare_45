extends Node2D

signal clicked
signal request_path

var base_speed = 100
var speed = 100
var max_speed = 150
var current_target : String
var current_instruction = 0
var instructions := []

var max_people = 6
var current_people = 0
var people  = []
var loading_people = false
var path : PoolVector2Array

func _ready() -> void:
	$Control.connect("button_up", self, "_clicked")
	$Area2D.connect("area_entered", self, "_area_entered")
	$Area2D.connect("area_exited", self, "_area_exited")
	$speed_up.connect("timeout", self, "_speed_up")

func _speed_up() -> void:
	if (loading_people || path.size() == 0 || instructions.size() == 0 || speed == max_speed):
		return
	speed += 5

func _clicked() -> void:
	emit_signal("clicked", self)

func set_instructions(new_instructions : Array):
	instructions = new_instructions
	current_instruction = 0
	_update_path()

func _get_visiting_stations() -> Array:
	var stations = []
	for instruction in instructions:
		if (!stations.has(stations)):
			stations.push_back(instruction)
	return stations;

func set_path(new_path : PoolVector2Array):
	path = new_path

func _update_path():
	if (instructions.size() == 0):
		path.resize(0)
		return

	emit_signal("request_path", self, instructions[current_instruction])
	current_target = instructions[current_instruction]

func _physics_process(delta: float) -> void:
	if (instructions.size() == 0):
		return

	if (path.size() == 0):
		_update_path()
		current_instruction += 1;
		if (current_instruction >= instructions.size()):
			current_instruction = 0;
		if (path.size() == 0):
			return

	if (loading_people):
		return

	# normalise target pos to grid
	var target_tile = Vector2(floor(path[0].x / Globals.tile_width), floor(path[0].y / Globals.tile_height))
	var target_pos = Vector2(target_tile.x * Globals.tile_width, target_tile. y * Globals.tile_height)

	rotation = lerp(rotation, position.angle_to_point(target_pos), delta * 10)
	var pos = Vector2(position.x, position.y);
	var distance = pos.distance_to(target_pos)
	if (distance > 2):
		pos = pos.linear_interpolate(target_pos, (speed * delta) / distance)
	else:
		pos = target_pos
		path.remove(0)
	position = Vector2(pos.x, pos.y)

func _area_entered(body):
	if (body == null && body.get_parent() == null):
		return

	var main_node = body.get_parent()
	if (main_node.get_name().find("station") != -1):
		visible = false
		if (main_node.get_type() != current_target):
			return
		speed = base_speed
		loading_people = true

		var people_to_unload = []
		var station_type = main_node.get_type()
		for person in people:
			var person_dest = person.split(":")[1]
			if (person_dest == station_type):
				people_to_unload.append(person)

		for person in people_to_unload:
			people.remove(person)
			current_people -= 1

		main_node.unload_people(people_to_unload)

		$load_timer.start()
		yield($load_timer, "timeout")

		var ret = main_node.remove_people(_get_visiting_stations(), max_people - current_people)
		if ret is GDScriptFunctionState:
			var state = ret
			ret = yield(state, "completed")
			people += ret
		_clear_icons()
		_load_icons()
		current_people = people.size()

		loading_people = false

func _clear_icons():
	for child in $people.get_children():
		if (child.get_name().find("@") != -1):
			child.visible = false
			child.free()

func _load_icons():
	for person in people:
		var icon = get_node("people/"+person.split(":")[0]+"_person").duplicate()
		icon.visible = true
		$people.add_child(icon)

func _area_exited(body):
	if (body == null && body.get_parent() == null):
		return

	var main_node = body.get_parent()
	if (main_node.get_name().find("station") != -1):
		visible = true
