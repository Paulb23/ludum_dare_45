extends Node2D

signal clicked

var instructions := []

func _ready() -> void:
	$Area2D.connect("input_event", self, "_clicked")

func _clicked(viewport : Viewport, event: InputEvent, shape_idx : int) -> void:
	if (event.is_action_released("place")):
		emit_signal("clicked", self)
