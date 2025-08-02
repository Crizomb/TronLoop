extends RigidBody3D
class_name Car

@export var road_path : RoadPath

@export var forward_force: float = 100.0
@export var backward_force: float = 50.0
@export var steer_speed: float = 2.0

@export var base_lateral_friction: float = 5.0
@export var lateral_velocity_start_drift_threshold: float = 10.0
@export var lateral_velocity_total_drift_threshold: float = 15.0

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

var respawn_pos : Vector3 

var thread: Thread = Thread.new()
var steer_input = 0.0

var air_time := 0.0


func custom_gravity() -> Vector3:
	var attractor = road_path.to_global(road_path.curve.get_closest_point(road_path.to_local(position)))
	return (attractor - position).normalized()

func return_to_road():
	position = respawn_pos + 3*Vector3.UP
	rotation.z = 0
	rotation.x = 0
	
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	air_time = 0.0
	
func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("restart"):
		return_to_road()

func _physics_process(delta: float) -> void:
	var move_input := Input.get_axis("back", "forward")
	var steer_input_brut := Input.get_axis("right", "left")
	steer_input = lerpf(steer_input, steer_input_brut, 0.1)
	var is_on_floor := backward_left_respawn.is_colliding() || backward_right_respawn.is_colliding() || forward_left_respawn.is_colliding() || forward_right_respawn.is_colliding()
	var is_all_wheel_on_floor := backward_left_respawn.is_colliding() && backward_right_respawn.is_colliding() && forward_left_respawn.is_colliding() && forward_right_respawn.is_colliding()
	var is_flat : bool = transform.basis.y.dot(Vector3.UP) > 0.9
	
	# Doing custom gravity like a chad
	PhysicsServer3D.area_set_param(get_viewport().find_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR, custom_gravity())
	
	if is_all_wheel_on_floor && is_flat:
		respawn_pos = position

	if !is_on_floor:
		#$DriftParticles.emitting = false
		#$DriftParticles2.emitting = false
		#AudioServer.set_bus_volume_db(5, -80)
		air_time += delta
		if air_time > 1.5:
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
	#angular_velocity = steer_input * delta * global_transform.basis.y * 30.0
	rotate(global_transform.basis.y, rotation_angle)
	
	# Drift Simulation
	var velocity = linear_velocity
	var forward_dir = global_transform.basis.z
	if forward_dir.length_squared() == 0.0:
		return # skip drift this frame if something is invalid
	forward_dir = forward_dir.normalized()

	var forward_velocity = forward_dir * velocity.dot(forward_dir)
	var lateral_velocity = velocity - forward_velocity
	
	var drift_factor = inverse_lerp(
	lateral_velocity_total_drift_threshold,
	lateral_velocity_start_drift_threshold,
	lateral_velocity.length()
	)
	drift_factor = clamp(drift_factor, 0, 1)
	
	#$DriftParticles.emitting = drift_factor < 1 && is_on_floor
	#$DriftParticles2.emitting = drift_factor < 1 && is_on_floor
	#if drift_factor < 1 && is_on_floor:
		#AudioServer.set_bus_volume_db(5, lerp(-15, -30, drift_factor))
	#else:
		#AudioServer.set_bus_volume_db(5, -80)
	
	steer_speed = lerp(steer_speed * 2.0, base_steer_speed, drift_factor)

	var lateral_friction_force = -lateral_velocity * base_lateral_friction * drift_factor
	apply_central_force(lateral_friction_force)
	
	
