extends Node
class_name TimeManager

var time := 0.0
var started := true

func _process(delta: float) -> void:
	if !started: return
	
	time += delta
	
