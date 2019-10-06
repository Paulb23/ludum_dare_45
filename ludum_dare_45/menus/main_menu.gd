extends Control

var clicked

func _ready() -> void:
	clicked = false
	$exit.connect("pressed", self, "_exit")
	$play.connect("pressed", self, "_play")

func _play():
	if (clicked):
		return
	clicked = true
	$click.play()
	yield($click, "finished")
	Globals.set_scene("res://game.tscn")

func _exit():
	if (clicked):
		return
	clicked = true
	$click.play()
	yield($click, "finished")
	get_tree().quit()
