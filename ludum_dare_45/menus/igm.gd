extends Control

var clicked := false

func _ready() -> void:
	$menu.connect("pressed", self, "_menu")
	$exit.connect("pressed", self, "_exit")

func show_game_over(moved : int) -> void:
	$game_over/moved.text = "You moved " + String(moved) + " Passengers."
	$game_over.visible = true
	get_tree().paused = true

func _menu():
	if (clicked):
		return
	clicked = true
	$click.play()
	yield($click, "finished")
	get_tree().paused = false
	Globals.set_scene("res://menus/main_menu.tscn")

func _exit():
	if (clicked):
		return
	clicked = true
	$click.play()
	yield($click, "finished")
	get_tree().paused = false
	get_tree().quit()
