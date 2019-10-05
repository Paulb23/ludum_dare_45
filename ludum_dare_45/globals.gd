extends Node2D

const screen_width := 1920
const screen_height := 1080
const tile_width := 32
const tile_height := 32

var varibles := {}

var current_scene : Node = null

func _ready() -> void:
	randomize()
	current_scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() -1)
	set_screen_res(screen_width, screen_height)
	set_globals()

func set_scene(new_scene_path : String) -> void:
	current_scene.queue_free()
	current_scene.set_name( current_scene.get_name() + "_deleted" )
	var new_scene := ResourceLoader.load(new_scene_path)
	current_scene = new_scene.instance()
	get_tree().get_root().add_child(current_scene)

func set_screen_res(width : int, height : int) -> void:
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(width , height))

func set_globals() -> void:
	Globals.set("SCREEN_WIDTH", screen_width)
	Globals.set("SCREEN_HEIGHT", screen_height)
	Globals.set("TILE_WIDTH", tile_width)
	Globals.set("TILE_HEIGHT", tile_height)

func set(name : String, value) -> void:
	varibles[name] = value

func get(name : String):
	if varibles.has(name):
		return varibles[name]
	else:
		return ""
