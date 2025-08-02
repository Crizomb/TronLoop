extends Camera3D

@export var follow_point : Node3D
@export var follow_speed := 10.0
@export var rotation_speed := 8.0

func _physics_process(delta: float) -> void:
	var target_basis = follow_point.global_transform.basis
	var current_basis = global_transform.basis
	global_transform.origin = global_transform.origin.lerp(follow_point.global_position, follow_speed * delta)
	global_transform.basis = current_basis.slerp(target_basis, rotation_speed * delta)
