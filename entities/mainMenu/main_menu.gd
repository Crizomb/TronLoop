extends Control

func _ready():
	MusicManager.launch_menu_music()

func _on_button_1_pressed() -> void:
	GameManager.launch_level(0)

func _on_button_2_pressed() -> void:
	GameManager.launch_level(1)

func _on_button_3_pressed() -> void:
	GameManager.launch_level(2)
