extends Control


func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("pause")):
		visible = false if visible else true
		get_tree().paused = visible


func _on_slider_main_sound_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, (value-50)/4)

func _on_slider_music_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, (value-50)/4)


func _on_slider_sfx_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, (value-50)/4)


func _on_button_pressed() -> void:
	GameManager.launch_menu()
