extends Control
class_name StartCounter

@onready var label: Label = $Label
@export var car: Car
@export var timeManager : TimeManager

var count_down_started := false
var count_down := 3.0

func _physics_process(delta: float) -> void:
	if !count_down_started: return
	if count_down < 0:
		car.freeze = false # Activating car
		timeManager.process_mode = Node.PROCESS_MODE_INHERIT
		queue_free() # Delete counter
	count_down -= delta
	label.text = str(int(count_down))
	


func _on_camera_3d_preview_ended() -> void:
	show()
	count_down_started = true
