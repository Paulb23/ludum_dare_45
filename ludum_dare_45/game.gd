extends Node2D


func _ready() -> void:
	$player.connect("place_tile", $level, "place_tile")
