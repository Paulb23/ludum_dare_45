extends Node2D

export var FULL_COLOR = Color(0, 0, 0)
export var EMPTY_COLOR = Color(0.88, 0.88,0.88)
export var BORDER_COLOR = Color(0.66, 0.66, 0.66)
export var BORDER_SIZE = 0.01

var rect = Rect2(0, 86, 128, 10)
var innerRect
var borderColor
var percentage : float


func _ready():
	percentage = 0
	var scale = get_scale()
	var borderX = rect.size.x * BORDER_SIZE / scale.x
	var borderY = rect.size.y * BORDER_SIZE / scale.y
	var innerPos = Vector2(rect.position.x + borderX, rect.position.y + borderY)
	var innerSize = Vector2(rect.size.x - borderX * 2.0, rect.size.y - borderY * 2.0)
	innerRect = Rect2(innerPos, innerSize)


func _draw():
	draw_rect(rect, BORDER_COLOR)
	var percentageRect = Rect2(innerRect.position, innerRect.size)
	percentageRect.size.x *= percentage
	draw_rect(percentageRect, EMPTY_COLOR.linear_interpolate(FULL_COLOR, percentage))
	update()


func set_percentage(percentage : float):
	if (percentage < 0):
		percentage = 0
	self.percentage = percentage
	update()
