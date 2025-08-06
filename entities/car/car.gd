extends RigidBody3D
class_name Car

@export var road_path : SplinePath

@export var forward_force: float = 100.0
@export var backward_force: float = 50.0
@export var steer_speed: float = 2.0

@export var base_lateral_friction: float = 5.0

@onready var forward_left: RayCast3D = $ForwardLeft
@onready var forward_right: RayCast3D = $ForwardRight
@onready var backward_right: RayCast3D = $BackwardRight
@onready var backward_left: RayCast3D = $BackwardLeft

@onready var forward_left_respawn: RayCast3D = $RaycastsRespawn/ForwardLeftRespawn
@onready var forward_right_respawn: RayCast3D = $RaycastsRespawn/ForwardRightRespawn
@onready var backward_right_respawn: RayCast3D = $RaycastsRespawn/BackwardRightRespawn
@onready var backward_left_respawn: RayCast3D = $RaycastsRespawn/BackwardLeftRespawn



var base_steer_speed: float
var current_steer_speed = base_steer_speed
var last_steer_input := 0.0
var rotation_angle := 0.0

var respawn_trans : Transform3D 

var thread: Thread = Thread.new()
var steer_input = 0.0

var air_time := 0.0


func custom_gravity() -> Vector3:
	var closest_offset = road_path.curve.get_closest_offset(road_path.to_local(position))
	var closest_transform = road_path.curve.sample_baked_with_rotation(closest_offset, true, true)
	var closest_point = road_path.to_global(closest_transform.origin)
	
	return -closest_transform.basis.y

func return_to_road():
	var closest_offset = road_path.curve.get_closest_offset(road_path.to_local(position))
	var closest_transform = road_path.curve.sample_baked_with_rotation(closest_offset, true, true)
	transform = respawn_trans
	position += closest_transform.basis.y * 2.0
	
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	air_time = 0.0
	
func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("restart"):
		return_to_road()
		
	if Input.is_action_just_pressed("hardRestart"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	var move_input := Input.get_axis("back", "forward")
	var steer_input_brut := Input.get_axis("right", "left")
	steer_input = lerpf(steer_input, steer_input_brut, 0.1)
	var is_on_floor := backward_left_respawn.is_colliding() || backward_right_respawn.is_colliding() || forward_left_respawn.is_colliding() || forward_right_respawn.is_colliding()
	var is_all_wheel_on_floor := backward_left_respawn.is_colliding() && backward_right_respawn.is_colliding() && forward_left_respawn.is_colliding() && forward_right_respawn.is_colliding()
	
	# Doing custom gravity like a chad
	PhysicsServer3D.area_set_param(get_viewport().find_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR, custom_gravity())
	
	if is_all_wheel_on_floor:
		respawn_trans = transform

	if !is_on_floor:
		air_time += delta
		if air_time > 3:
			return_to_road()
		return
	air_time = 0.0
		
	# Movement
	if move_input > 0.0:
		apply_central_force(global_transform.basis.z * forward_force)
	elif move_input < 0.0:
		var break_or_backward = 2*backward_force if global_transform.basis.z.dot(linear_velocity) > 0 else backward_force
		apply_central_force(global_transform.basis.z * -break_or_backward)

	# Rotation
	rotation_angle = steer_input * delta
	rotate(global_transform.basis.y, rotation_angle)
	
	var velocity = linear_velocity
	var forward_dir = global_transform.basis.z
	if forward_dir.length_squared() == 0.0:
		return 
	forward_dir = forward_dir.normalized()

	var forward_velocity = forward_dir * velocity.dot(forward_dir)
	var lateral_velocity = velocity - forward_velocity

	var lateral_friction_force = -lateral_velocity * base_lateral_friction
	apply_central_force(lateral_friction_force)
	
	
