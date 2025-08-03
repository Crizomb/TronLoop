extends AudioStreamPlayer3D

@onready var car: Car = $".."

func _process(delta: float) -> void:
	pitch_scale = max(car.linear_velocity.length() * 0.1, 0.1)
