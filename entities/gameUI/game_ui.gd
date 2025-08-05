extends Control
class_name GameUI

@export var timeManager : TimeManager
@export var checkPointManager : CheckPointManager

@onready var lap_label: Label = $VBoxContainer/LapLabel
@onready var time_label: Label = $VBoxContainer/TimeLabel
	
func _process(delta: float) -> void:
	lap_label.text = "Lap " + str(checkPointManager.current_lap) + "/" + str(checkPointManager.max_lap)
	time_label.text = str(round(timeManager.time*100)/100)
