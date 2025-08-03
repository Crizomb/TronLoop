extends Control
class_name GameUI

var time : float
var lap : int

@onready var lap_label: Label = $VBoxContainer/LapLabel
@onready var time_label: Label = $VBoxContainer/TimeLabel

func _ready():
	time = 0
	lap = 0.0
	
func _process(delta: float) -> void:
	time += delta
	lap_label.text = "Lap " + str(lap) + "/3"
	time_label.text = str(round(time*100)/100)

func _on_check_point_manager_new_lap(value: Variant) -> void:
	lap = value
