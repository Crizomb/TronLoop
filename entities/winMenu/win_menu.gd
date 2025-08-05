extends Control

@export var timeManager : TimeManager
@onready var time_label: Label = $VBoxContainer/Time


func _on_check_point_manager_end_track() -> void:
	time_label.text = str(round(timeManager.time*100)/100)+"s"
	show()
	get_tree().paused = true

func _on_main_menu_pressed() -> void:
	GameManager.launch_menu()
