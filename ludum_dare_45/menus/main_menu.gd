extends Control

func _ready() -> void:
	$exit.connect("pressed", self, "_exit")
	$play.connect("pressed", self, "_play")

func _play():
	#$click.play()
	#yield($click, "finished")
	Globals.set_scene("res://game.tscn")

func _exit():
	#$click.play()
	#yield($click, "finished")
	get_tree().quit()
