extends Node2D

signal request_person
signal person_created
signal person_removed
signal too_angry

var min_wait_time = 5
var max_wait_time = 10

var can_generate = false;
var max_people = 5
var current_people = 0
var anger := 0.0

var people_types = [SQUARE, CIRCLE, TIRANGLE]
var people = []

const SQUARE = "square"
const CIRCLE = "circle"
const TIRANGLE = "triangle"

var type : String

func set_type(station_type : String) -> void:
	type = station_type
	if (station_type == SQUARE):
		$square_station.show()
	if (station_type == CIRCLE):
		$circle_station.show()
	if (station_type == TIRANGLE):
		$triangle_station.show()

	people_types.remove(people_types.find(station_type))

	$new_person_timer.connect("timeout", self, "_generate_person")
	_start_person_request_timer()

func get_type() -> String:
	return type

func get_target_pos() -> Vector2:
	return Vector2(position.x + 62, position.y + 50)

func _update_anger_bar():
	if (anger >= 1.0):
		emit_signal("too_angry")
	anger += 0.05
	$anger_bar.set_percentage(anger)


func _generate_person():
	if (current_people >= max_people):
		_update_anger_bar()
		can_generate = false
		return
	emit_signal("request_person", self)

	if (!can_generate):
		return

	can_generate = false
	var new_person = people_types[int(rand_range(0, people_types.size()))]
	_add_person(new_person)
	_start_person_request_timer()

func _add_person(person_type : String):
	people.append(person_type)
	emit_signal("person_created")
	current_people += 1

	var icon = get_node("people/"+person_type+"_person").duplicate()
	icon.visible = true
	$people.add_child(icon)

func unload_people(unloaded_people : Array):
	for person in unloaded_people:
		if (!$unload.playing):
			$unload.play()

		$load_timer.start()
		yield($load_timer, "timeout")

		var person_type = person.split(":")[0]
		if (person_type == type):
			emit_signal("person_removed")
			continue
		_add_person(person_type)

func remove_people(visiting_stations : Array, amount : int) -> Array:
	var people_to_remove = []

	for person in people:
		if (people_to_remove.size() >= amount):
			break

		var nav : Navigation2D = get_parent().get_parent().get_child(0)
		var stations = get_parent().get_parent().stations

		# if we have a valid route
		var points : PoolVector2Array = nav.get_simple_path(position, get_parent().get_parent().get_station(person).get_target_pos(), false)
		if (points.size() > 0):
			# get the stations along the path
			var valid_person = false
			var stopping_point = ""
			for point in points:
				for station in stations.values():
					if (station == self || !visiting_stations.has(station.get_type())):
						continue

					if (abs(point.distance_to(station.get_target_pos())) <= 50):
						valid_person = true
						stopping_point = station.get_type()
						break

				if (valid_person):
					break
			if (valid_person):
				people_to_remove.append(person+ ":" + stopping_point)

	for person in people_to_remove:
		if (!$load.playing):
			$load.play()

		$load_timer.start()
		yield($load_timer, "timeout")

		var person_type = person.split(":")[0]
		people.remove(people.find(person_type))
		$people.get_index()
		var node = $people.find_node("@"+person_type + "_*", false, false)
		if node != null:
			node = $people.find_node("@"+person_type + "_*", false, false)
			node.visible = false
			node.free()
			current_people -= 1

	return people_to_remove

func _start_person_request_timer():
	$new_person_timer.wait_time = rand_range(min_wait_time, max_wait_time)
	$new_person_timer.start()


