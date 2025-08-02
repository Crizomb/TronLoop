@tool
extends StaticBody3D
class_name Road

@export_tool_button("create_mesh") var action_generate = generate_mesh
@export_tool_button("clear_all") var action_clear = clear_all

@export var track : RoadPath
@export var road_mesh_instance : MeshInstance3D
@export var road_shape : CollisionShape3D
@export var road_material : BaseMaterial3D
@export var segment_length := 0.1
@export var road_width : float = 1.5
@export var road_thickness : float = 0.5

var st_road = SurfaceTool.new()

func clear_all():
	st_road = SurfaceTool.new()
	st_road.clear()
	road_mesh_instance.mesh = null
	if road_shape and road_shape.shape:
		road_shape.shape = null

func generate_mesh():
	clear_all()
	st_road.begin(Mesh.PRIMITIVE_TRIANGLES)
	if road_material:
		st_road.set_material(road_material)
		
	var curve := track.curve
	var race_length = curve.get_baked_length()
	var nb_of_point : int = race_length / segment_length

	for i in range(nb_of_point+1):
		var dist1 = float(i) * segment_length
		var dist2 = float(i + 1) * segment_length
		
		
		var t1 := curve.sample_baked_with_rotation(dist1, true, true)
		var t2 := curve.sample_baked_with_rotation(dist2, true, true)

		var fwd1 = t1.basis.z.normalized()
		var fwd2 = t2.basis.z.normalized()

		var right1 = t1.basis.x.normalized()
		var right2 = t2.basis.x.normalized()
		
		var left1 = -right1
		var left2 = -right2
		
		var up1 = t1.basis.y.normalized()
		var up2 = t2.basis.y.normalized()

		var p1 := t1.origin
		var p2 := t2.origin

		# Top vertices
		var p1_right = p1 + right1 * road_width * 0.5
		var p1_left = p1 - right1 * road_width * 0.5
		var p2_right = p2 + right2 * road_width * 0.5
		var p2_left = p2 - right2 * road_width * 0.5

		# Bottom vertices
		var p1_right_bottom = p1_right - up1 * road_thickness
		var p1_left_bottom = p1_left - up1 * road_thickness
		var p2_right_bottom = p2_right - up2 * road_thickness
		var p2_left_bottom = p2_left - up2 * road_thickness

				# Top face
		create_rectangle(
			p1_right, p1_left, p2_left, p2_right,
			up1, up2,
			Vector2(1, dist1 / road_width),
			Vector2(0, dist1 / road_width),
			Vector2(0, dist2 / road_width),
			Vector2(1, dist2 / road_width)
		)

		# Bottom face
		create_rectangle(
			p1_left_bottom, p1_right_bottom, p2_right_bottom, p2_left_bottom,
			-up1, -up2,
			Vector2(0, dist1 / road_width),
			Vector2(1, dist1 / road_width),
			Vector2(1, dist2 / road_width),
			Vector2(0, dist2 / road_width)
		)

		# Right side face
		create_rectangle(
			p1_right_bottom, p1_right, p2_right, p2_right_bottom,
			right1, right2,
			Vector2(dist1 / road_thickness, 0),
			Vector2(dist1 / road_thickness, 1),
			Vector2(dist2 / road_thickness, 1),
			Vector2(dist2 / road_thickness, 0)
		)

		# Left side face
		create_rectangle(
			p1_left, p1_left_bottom, p2_left_bottom, p2_left,
			left1, left2,
			Vector2(dist1 / road_thickness, 1),
			Vector2(dist1 / road_thickness, 0),
			Vector2(dist2 / road_thickness, 0),
			Vector2(dist2 / road_thickness, 1)
		)
	var final_mesh = st_road.commit()
	road_mesh_instance.mesh = final_mesh
	
	var shape = final_mesh.create_trimesh_shape()
	road_shape.shape = shape
	


func create_rectangle(
	v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3,
	normal1: Vector3, normal2: Vector3,
	uv1: Vector2, uv2: Vector2, uv3: Vector2, uv4: Vector2
):
	# Triangle 1
	st_road.set_uv(uv1)
	st_road.set_normal(normal1)
	st_road.add_vertex(v1)

	st_road.set_uv(uv2)
	st_road.set_normal(normal1)
	st_road.add_vertex(v2)

	st_road.set_uv(uv3)
	st_road.set_normal(normal2)
	st_road.add_vertex(v3)

	# Triangle 2
	st_road.set_uv(uv3)
	st_road.set_normal(normal2)
	st_road.add_vertex(v3)

	st_road.set_uv(uv4)
	st_road.set_normal(normal1)
	st_road.add_vertex(v4)

	st_road.set_uv(uv1)
	st_road.set_normal(normal1)
	st_road.add_vertex(v1)
