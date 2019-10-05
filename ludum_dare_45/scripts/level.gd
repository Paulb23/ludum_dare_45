extends TileMap

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

func _ready() -> void:
	for x in range(0, 100):
		for y in range(0, 100):
			set_cell(x ,y, 0)

func place_tile(x : int, y : int) -> void:
	set_cell(x ,y, NO_CONNECTIONS)
	_update_cell(x , y)
	_update_cell(x - 1 , y)
	_update_cell(x + 1, y)
	_update_cell(x , y - 1)
	_update_cell(x , y + 1)

func _update_cell(x : int, y : int):
	if (get_cell(x, y) <= 0 || x < 0 || y < 0):
		return

	var connections := [0, 0, 0, 0]

	if (x > 0 && get_cell(x - 1, y) > 0):
		connections[LEFT] = 1

	if (get_cell(x + 1, y) > 0):
		connections[RIGHT] = 1

	if (y > 0 && get_cell(x, y - 1) > 0):
		connections[UP] = 1

	if (get_cell(x, y + 1) > 0):
		connections[DOWN] = 1

	var total_connections = connections.count(1)

	if (total_connections == 0):
		set_cell(x , y, NO_CONNECTIONS)
		return

	if (total_connections == 4):
		set_cell(x , y, QUAD_CONNECIONS)
		return

	if (total_connections == 1):
		set_cell(x ,y, SINGLE_CONNECTION, connections[RIGHT], connections[DOWN], connections[RIGHT] || connections[LEFT])
		return

	if (total_connections == 3):
		set_cell(x ,y, THREE_CONNECTIONS, connections[RIGHT], !connections[UP], (connections[UP] && !connections[DOWN]) || (!connections[UP] && connections[DOWN]))
		return

	if (total_connections == 2):
		if ((connections[LEFT] && connections[RIGHT]) || (connections[UP] && connections[DOWN])):
			set_cell(x ,y, STRAIGHT_CONNECION, connections[RIGHT], connections[DOWN], connections[RIGHT] || connections[LEFT])
			return
		set_cell(x ,y, RIGHT_ANGLE_CONNECTION, connections[RIGHT], connections[DOWN], connections[RIGHT] || connections[LEFT])
		return
