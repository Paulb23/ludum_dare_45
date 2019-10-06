extends Control

func _ready() -> void:
	$music_vol.connect("value_changed", self, "_music_vol_changed")
	$music_vol.value = AudioServer.get_bus_volume_db(abs(AudioServer.get_bus_index("music")))

	$sfx_vol.connect("value_changed", self, "_sfx_vol_changed")
	$sfx_vol.value = AudioServer.get_bus_volume_db(abs(AudioServer.get_bus_index("sfx")))

func _music_vol_changed(val):
	AudioServer.set_bus_volume_db(abs(AudioServer.get_bus_index("music")), val)

func _sfx_vol_changed(val):
	AudioServer.set_bus_volume_db(abs(AudioServer.get_bus_index("sfx")), val)
