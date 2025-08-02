extends Node3D

@export var rotating_speed := 1.0

func _process(delta: float) -> void:
	rotate(Vector3.UP, delta*rotating_speed)
