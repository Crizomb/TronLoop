extends Node
class_name TimeManager

var time := 0.0

func _process(delta: float) -> void:
	time += delta
	
