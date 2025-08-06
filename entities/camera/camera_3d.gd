extends Camera3D

@export var cameraPreview : SplinePath
@export var followPoint : Node3D
@export var previewUi : Control

@export var follow_speed := 10.0
@export var rotation_speed := 8.0
@export var total_preview_time := 5.0
@export var go_to_first_point_time := 2.0
@export var lerp_speed_preview_coeff := 0.1
@export var lerp_speed_go_to_first_point_coeff := 0.1

var t := 0.0
var is_in_preview := true
@onready var curve_length := cameraPreview.curve.get_baked_length()
@onready var path_preview_time := total_preview_time - go_to_first_point_time

signal preview_ended

func follow_trans(delta : float, trans : Transform3D, speed_coeff := 1.0) -> void:
	var target_basis = trans.basis
	var current_basis = global_transform.basis
	global_transform.origin = global_transform.origin.lerp(trans.origin, follow_speed * delta * speed_coeff)
	global_transform.basis = current_basis.slerp(target_basis, rotation_speed * delta * speed_coeff)

func go_to_first_point(delta):
	var trans = cameraPreview.curve.sample_baked_with_rotation(0, true, true)
	var global_trans = (cameraPreview.transform*trans).orthonormalized().rotated_local(Vector3.UP, PI)
	follow_trans(delta, global_trans, lerp_speed_go_to_first_point_coeff)
	
func follow_preview_path(delta):
	var pt = t - go_to_first_point_time
	var offset = lerpf(0, curve_length, 1-pt/path_preview_time)
	var trans = cameraPreview.curve.sample_baked_with_rotation(offset, true, true)
	var global_trans = (cameraPreview.transform*trans).orthonormalized().rotated_local(Vector3.UP, PI)
	follow_trans(delta, global_trans, lerp_speed_preview_coeff)
	
func _physics_process(delta: float) -> void:
	if is_in_preview && Input.is_action_pressed("skip_intro"):
		t = total_preview_time
	t += delta
	if t < go_to_first_point_time:
		go_to_first_point(delta)
	elif  t < total_preview_time:
		follow_preview_path(delta)
	else:
		follow_trans(delta, followPoint.global_transform)
		if is_in_preview:
			is_in_preview = false
			previewUi.queue_free()
			preview_ended.emit()
