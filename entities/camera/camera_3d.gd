extends Camera3D

@export var camera_preview : SplinePath
@export var follow_point : Node3D
@export var follow_speed := 10.0
@export var rotation_speed := 8.0
@export var path_preview_time := 5.0
@export var lerp_speed_preview_coeff := 0.1

var t := 0.0
@onready var curve_length := camera_preview.curve.get_baked_length()

func follow_trans(delta : float, trans : Transform3D, speed_coeff := 1.0) -> void:
	var target_basis = trans.basis
	var current_basis = global_transform.basis
	global_transform.origin = global_transform.origin.lerp(trans.origin, follow_speed * delta * speed_coeff)
	global_transform.basis = current_basis.slerp(target_basis, rotation_speed * delta * speed_coeff)


func _physics_process(delta: float) -> void:
	t += delta
	if t <= path_preview_time:
		var offset = lerpf(0, curve_length, 1-t/path_preview_time)
		var trans = camera_preview.curve.sample_baked_with_rotation(offset, true, true)
		var global_trans = (camera_preview.transform*trans).orthonormalized().rotated_local(Vector3.UP, PI)
		follow_trans(delta, global_trans, lerp_speed_preview_coeff)
	else:
		follow_trans(delta, follow_point.global_transform)
